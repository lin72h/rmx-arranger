# Implicit-Close Investigation Review

Date: 2026-04-17
Reviewer: Claude (wip-claude)

## 1. Overall Verdict

You stopped at the correct boundary. The fork/exit probe shape was the wrong
direction, and you correctly diagnosed this rather than pushing forward on a
broken assumption. But the reason you stopped is more interesting than you
think: **the batch 15 local send-once close result is NOT a bug signal** —
it shows correct Mach behavior that my previous review did not predict.

The `mach_port_close` concern from my earlier review was **overstated for the
near-term**. The issue is real in principle, but:
1. Mach fds are not inherited across fork, which eliminates the simple
   cross-task reproduction path
2. The same-process implicit close through `ipc_object_destroy` IS doing the
   right thing semantically
3. The `ip_sorights` counter you're reading is behaving correctly

Your experimental `mach_port_close` patch is conceptually correct. The
per-port observability sysctl is good work and should be committed. The
remaining confusion is about what the counters mean, not about whether the
cleanup is broken.

## 2. What the Current Evidence Really Says

### Batch 14: Fork/exit — fd NOT inherited

**Fact:** Child exit code 75 means `fcntl(send_once_name, F_GETFD) == -1`.
The Mach fd-backed name does not exist in the child's fd table after fork.

**This is an important structural discovery.** In the NextBSD fd-bridge
model, Mach port names are fd numbers. FreeBSD `fork()` copies the fd table.
So the child should have the fd, yet it doesn't.

The most likely explanation: look at when `mach_task_init` (the
`process_init` handler) fires relative to the fd table copy during fork. If
`process_init` fires AFTER the fd table is copied to the child, and if
`mach_task_init` closes or invalidates Mach-typed fds as part of creating a
fresh IPC space, the child would lose the fd.

Alternatively: the fd might exist in the child but have been invalidated by
the fresh-IPC-space creation, making `fcntl` return -1 for a different reason
than expected.

**Regardless of the cause:** this means the simple "parent creates right,
child inherits fd, child exits, implicit close fires" reproduction path does
not work. The fork/exit implicit-close theory needs a different shape.

### Batch 14: send-right `insert_copy_send_right_fresh` — KERN_RIGHT_EXISTS

**Fact:** `rc=21` from `insert_copy_send_right_fresh` means the fresh-name
send-right setup failed with `KERN_RIGHT_EXISTS`.

This is a separate issue from the implicit-close question. Either:
- `insert_right` with `MACH_MSG_TYPE_COPY_SEND` doesn't work for
  fresh-name explicit slots
- Or the candidate name range `poly_name+1..+63` all collide with existing
  entries

This blocks the send-right fork/exit probe but is unrelated to the
send-once close behavior.

### Batch 15: Local same-process send-once close

**Fact:** After `close(send_once_name)`:
- `send_name_type=0x40000` (MACH_PORT_TYPE_SEND_ONCE) — correct
- `send_name_receiver_current=1` — the port IS received by current task
- `before_sorights=1, after_sorights=1` — unchanged
- `before_refs=2, after_refs=2` — unchanged
- `after_active=1` — port still active

**This is NOT a bug.** Here's why:

The experimental `mach_port_close` patch routes SEND_ONCE through
`ipc_object_destroy(object, MACH_MSG_TYPE_PORT_SEND_ONCE)`. This calls
`ipc_notify_send_once(port)`, which is the correct Mach behavior for
consuming a send-once right without using it to send a real message.

`ipc_notify_send_once` constructs a `MACH_NOTIFY_SEND_ONCE` notification
kmsg and delivers it to the port via `ipc_mqueue_send_always`. The
notification message is now **queued on the port's mqueue**.

The `ip_sorights` counter tracks outstanding send-once rights. In Mach
semantics, the send-once right is consumed by the notification send — the
notification IS the consumption. But `ip_sorights` is not decremented at
send time. It is decremented when:
- The notification message is **received** (via `mach_msg_receive` →
  `ipc_kmsg_copyout_header`)
- Or the port is **destroyed** (via `ipc_port_destroy` which destroys
  queued messages)

Since the probe never receives from the port, `ip_sorights` stays at 1.
This is correct.

Similarly, `ip_references=2` stays at 2 because:
- One ref from the receive entry
- One ref now held by the queued notification message (transferred from the
  send-once entry)

The notification message replaced the send-once entry's reference. The count
is unchanged because a reference was transferred, not dropped.

**Proof that `ipc_right_destroy` has the same behavior:** Look at
`ipc_right.c:685-690`:
```c
} else if (type & MACH_PORT_TYPE_SEND_ONCE) {
    assert(port->ip_sorights > 0);
    OBJECT_CLEAR(entry, name);
    ip_unlock(port);
    ipc_entry_dealloc(space, name, entry);
    ipc_notify_send_once(port); /* consumes our ref */
}
```

`ipc_right_destroy` also does NOT decrement `ip_sorights`. It does exactly
the same thing as your experimental patch: calls `ipc_notify_send_once`.
If you ran the explicit `mach_port_destroy(send_once_name)` and measured the
same counters from the receive name, you would see the same
`after_sorights=1, after_refs=2`.

## 3. Whether the `mach_port_close` Theory Is Still Credible

### The experimental patch is conceptually correct

For SEND_ONCE: routes through `ipc_object_destroy` →
`ipc_notify_send_once` → same path as `ipc_right_destroy`.

For SEND: routes through `ipc_object_destroy` →
`ipc_port_release_send` → decrements `ip_srights`, handles no-senders.
This is the correct accounting.

The `IP_CONTEXT_FILE` early-return in `ipc_object_destroy` is irrelevant for
normal IPC ports — `IP_CONTEXT_FILE` is a special flag for FreeBSD file
descriptors wrapped as Mach ports for cross-process file passing via
messages. Normal IPC ports created by `mach_port_allocate` do not have this
flag.

### The original `mach_port_close` concern is still real, but narrower

The original `mach_port_close`:
```c
if (port->ip_receiver == current_space()) {
    ip_lock(port);
    ipc_port_clear_receiver(port);
    ipc_port_destroy(port);
} else {
    ip_release(port);
}
```

The `else` branch (`ip_release` only) is the problem. It fires when the
current task holds a send or send-once right to **another task's** port.
This case can only arise through:

1. `mach_msg` — transferring rights via messages (not yet tested)
2. Kernel-granted rights — task port, host port, bootstrap port, exception
   ports (inherited via `ipc_task_init` → `ipc_port_copy_send`)
3. Explicit cross-task `insert_right` (not yet available)

Since Mach fds are not inherited across fork, the simplest cross-task
reproduction path is blocked. The concern remains valid for:
- Process exit when the process holds kernel-granted send rights (task_self,
  host_self, etc.)
- Future message-based right transfer

But this is a **lower-urgency** concern than my previous review suggested.
The kernel-granted rights (task_self, host_self) go through
`ipc_port_copy_send` which bumps `ip_srights`. On process exit, those fds
would hit the `ip_release` path instead of `ipc_port_release_send`, leaving
`ip_srights` elevated on the kernel ports. This is a real leak, but kernel
ports are long-lived, so the practical impact is small until you have many
short-lived processes.

### What this means for priority

The implicit-close fix should still happen, but it is **not the immediate
blocker** I previously claimed. The correct priority is:

1. Commit the per-port observability sysctl (useful regardless)
2. Commit the experimental `mach_port_close` patch (correct improvement)
3. Verify the existing batches still pass with the patch
4. Move on to the next actual frontier (message-adjacent or the
   `insert_copy_send` issue)

## 4. Best Next Diagnostic Sequence

### Immediate: Separate "is the patch correct" from "are my counters right" (1-2h)

**Step 1: Add a verification probe for `ipc_right_destroy` send-once
counters.** This takes 15 minutes and eliminates the confusion:

```
- allocate receive → receive_name
- insert_make_send_once_fresh → send_once_name
- read port status via receive_name (before)
- mach_port_destroy(send_once_name)   ← explicit destroy, not close()
- read port status via receive_name (after)
```

Expected result: `before_sorights=1, after_sorights=1`. If this matches
the batch 15 result, it confirms the behavior is correct Mach semantics,
not a `mach_port_close` bug.

**Step 2: Add a `printf` or counter inside `mach_port_close`.** This is the
cheapest way to confirm that `close()` actually reaches `mach_port_close`
and to see what `ie_bits` type is observed:

```c
if (mach_debug_enable)
    printf("mach_port_close: name=%d type=0x%x object=%p receiver_is_current=%d\n",
        (int)entry->ie_name, type, object,
        port ? (port->ip_receiver == current_space()) : -1);
```

Run batch 15 with `mach.debug_enable=1` and check serial output. This
definitively answers "did the experimental type-dispatch actually fire?"

### Short-term: Investigate why fds aren't inherited across fork (1-2h)

**Step 3:** Add a trivial probe that:
1. Parent opens a regular file → gets fd N
2. Parent allocates a Mach receive right → gets fd M
3. Fork
4. Child checks `fcntl(N, F_GETFD)` and `fcntl(M, F_GETFD)`
5. Report both results

This separates "Mach fds specifically aren't inherited" from "something
weird is happening with ALL fds during fork."

**Step 4:** If only Mach fds are not inherited, check whether the
`process_init` or `process_fork` event handler ordering interacts with fd
table copying. Add a `printf` in `mach_task_init` that logs the fd table
state.

### Medium-term: Investigate `insert_copy_send_right_fresh` failure (1-2h)

**Step 5:** The `KERN_RIGHT_EXISTS` error on fresh-name `COPY_SEND` is a
separate issue worth understanding. Try:
- A smaller candidate range starting further from the receive name
- Check whether `COPY_SEND` disposition works at all for `insert_right` in
  the donor code
- Check whether this is the same `ipc_entry_alloc_name` issue that commit
  `1ef60e70d942` fixed, but for a different case

### Commit sequence (1h)

**Step 6:** Once the verification probe confirms correct behavior:
1. Commit the per-port observability sysctl (standalone improvement)
2. Commit the experimental `mach_port_close` type-dispatch patch
   (correct improvement, harmless if the close path wasn't broken for
   same-task cases)
3. Commit the new probe batches (14, 15, plus the verification probe)
4. Re-run existing batches to confirm no regressions

## 5. What to Avoid

1. **Do not continue debugging batch 15 as a bug.** It's not a bug.
   The `ip_sorights` behavior is correct Mach semantics. Confirm this with
   the explicit-destroy verification probe (step 1) and move on.

2. **Do not assume fork/exit is the primary implicit-close reproduction
   path.** The fd non-inheritance makes this the wrong shape. The real
   cross-task implicit-close scenario requires `mach_msg` or
   kernel-granted rights, neither of which is currently testable.

3. **Do not defer committing the per-port observability.** It's useful
   regardless of the implicit-close question. Get it committed so
   future work builds on clean HEAD.

4. **Do not try to add `mach_msg` probes yet.** The message path is a
   much larger surface. The current frontier should be fully resolved
   (commit clean patches, understand the fd inheritance question) before
   opening the message-path lane.

5. **Do not investigate `swtch` yet.** Still orthogonal.

6. **Do not treat "my previous review was wrong" as "the fd bridge is
   safe."** The `ip_release`-only path in the original `mach_port_close`
   IS a real semantic deficiency for cross-task rights. But it's not
   the urgent crisis I framed it as, because the reproduction path I
   suggested doesn't exist. The fix is still correct and should be
   committed, but the priority has shifted.

## 6. Open Assumptions

1. **Why Mach fds are not inherited across fork is unknown.** This is the
   most important open question from this investigation. FreeBSD `fork()`
   should copy the fd table. If Mach fds are specifically excluded, there
   must be a mechanism doing it — possibly in the `process_init` or
   `process_fork` handler ordering, possibly in the fd table copy itself.
   This needs investigation (step 3-4 above).

2. **The `insert_copy_send_right_fresh` failure might be a real donor-lane
   gap.** If `MACH_MSG_TYPE_COPY_SEND` doesn't work for fresh explicit
   names, that limits the available probe shapes for cross-task testing.
   This should be investigated before trying further cross-task probes.

3. **`ip_sorights` is only decremented during message receive or port
   destruction.** I traced this through the code but did not find the
   explicit decrement point in the receive path. The verification probe
   (step 1) will confirm this empirically. If `mach_port_destroy` on the
   receive name shows `ip_sorights` dropping during port destruction,
   the model is confirmed.

4. **The `mach_port_close` patch might have ordering issues during
   `ipc_entry_list_close`.** During process exit, entries are closed in fd
   order. If a send-once entry (higher fd) points to a port whose receive
   entry (lower fd) was already destroyed, the experimental patch calls
   `ipc_object_destroy` on a dead port. `ipc_notify_send_once` would then
   try to send a notification to a dead port, which `ipc_mqueue_send`
   handles by destroying the kmsg. This should be safe, but the ordering
   interaction is worth a brief review.

5. **The `ie_bits` clearing in `ipc_entry_dealloc` might interact with
   `mach_port_close`.** Commit `0f22881fe02f` added
   `entry->ie_bits &= IE_BITS_GEN_MASK` in `ipc_entry_dealloc` before
   `ipc_entry_close`. If the close path goes through `ipc_entry_dealloc`
   (explicit destroy) rather than direct `close()`, the type bits would
   be cleared before `mach_port_close` sees them. This is fine for the
   explicit-destroy path (where `ipc_right_destroy` already did the right
   accounting). But it means the experimental type-dispatch in
   `mach_port_close` would see `type=0` for entries cleaned via the
   dealloc path, falling through to the old `ip_receiver` check. This is
   actually correct behavior — it means the experimental patch only fires
   for raw `close()` calls, not for the already-correct explicit-destroy
   path.

## Correction to Previous Review

My previous review (`donor-lane-next-risk-review.md`) made three claims that
need correction:

1. **"Silent corruption the moment you do any cross-task right transfer"** —
   too strong. The fd non-inheritance means the simple fork/exit path doesn't
   create cross-task implicit close. Cross-task rights via `mach_msg` would
   still be affected, but that surface isn't reachable yet.

2. **"Before moving into message-adjacent work, fix `mach_port_close`"** —
   priority was wrong. The fix is correct and should be committed, but it's
   not a blocker for same-task lifecycle work. It becomes relevant when
   `mach_msg`-based right transfer is tested.

3. **"`ip_sorights` stays elevated, no notification"** — incorrect for the
   same-process case. The notification IS sent (via `ipc_notify_send_once`).
   The counter stays elevated because the notification message is queued,
   not because the accounting is broken.

The per-port observability recommendation was correct and the instrument is
well-implemented. The experimental `mach_port_close` patch is correct and
should be committed.
