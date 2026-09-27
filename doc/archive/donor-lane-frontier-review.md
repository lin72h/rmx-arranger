# Donor Lane Frontier Review

Date: 2026-04-17
Reviewer: Claude (wip-claude)

## 1. Overall Verdict

Your interpretation is sound. The donor debug lane has genuinely strong
evidence now for the surfaces it has covered, and the decision space has
narrowed correctly. The single-task lifecycle lane and kernel-self-port
lane are both exhausted. The implicit-close local concern is resolved.

The next real frontier is `mach_msg`. Not message-adjacent setup. Not
fresh-name `COPY_SEND`. Not another proxy for cross-task behavior. The
actual message path. Here's why.

## 2. What the Current Strongest Evidence Actually Proves

### Proven (strong confidence)

1. **Single-task IPC lifecycle is debug-clean under WITNESS.** Allocate,
   use, explicit-destroy for receive, send, send-once, port-set, combined
   entries, and concurrent variants — all return to baseline with
   `diagnostic_count: 0` on committed, non-dirty HEAD.

2. **The fd bridge correctly maps and unmaps entries for explicit destroy.**
   Both the standard `ipc_right_destroy` path and the experimental
   `mach_port_close` type-dispatch path do correct right accounting for
   same-task entries.

3. **Kernel-granted send names (task_self, thread_self, host_self) use
   reverse-map reuse.** Repeated calls return the same fd-backed name with
   incremented entry refs. `mach_port_deallocate` drops those refs.
   Final `close()` retires the name and returns to baseline. The entry-ref
   model is now understood.

4. **`DTYPE_MACH_IPC` file descriptors are NOT inherited across fork.**
   This is a structural property of the bridge, confirmed by clean
   committed evidence: FreeBSD `kern_descrip.c` only copies entries with
   `DFLAG_FORK` or `DFLAG_PASSABLE`, and Mach fileops has `fo_flags = 0`.

5. **Local implicit close matches explicit destroy for same-task
   send-once rights.** The `close()` path through the experimental
   `mach_port_close` dispatch produces the same queued-notification
   counter state as `mach_port_destroy`, confirming they're semantically
   equivalent for same-task rights.

6. **Per-port object-level observability works.** `ip_srights`,
   `ip_sorights`, `ip_references`, `ip_msgcount`, `entry_refs` — all
   readable from userspace for any current-task port name.

### Not proven (and structurally cannot be proven without `mach_msg`)

1. **Cross-task right transfer.** No test has ever moved a port right
   from one task to another. The only mechanism for doing so in Mach IPC
   is message passing. The bridge prevents fd inheritance, and
   `insert_right` is same-task only.

2. **Message copyin/copyout correctness.** `ipc_kmsg_copyin` and
   `ipc_kmsg_copyout` are the core functions that translate between
   user-space port names and kernel port references during message
   send/receive. These have never been exercised.

3. **Message queueing and delivery.** `ipc_mqueue_send` has been
   exercised indirectly (notifications), but `ipc_mqueue_deliver` to a
   real waiting receiver has never been tested.

4. **Blocking receive.** `mach_msg_receive` → `ipc_mqueue_receive` with
   `thread_block()` has never been tested. This is a deep scheduler
   integration point.

5. **Send-right transfer semantics across tasks.** Whether
   `ipc_kmsg_copyin_header` correctly handles `MACH_MSG_TYPE_COPY_SEND`,
   `MACH_MSG_TYPE_MAKE_SEND`, etc. in the message header under the fd
   bridge.

6. **Any behavior that depends on two cooperating processes.** Every
   single test so far has been single-process (or trivial fork/exit with
   the child doing nothing Mach-related). No test has had two processes
   communicate via Mach IPC.

## 3. The Most Fundamental Remaining Risk

**The message path through the fd bridge.**

This is not a vague "message semantics might be hard." It's specific:

`mach_msg_send` calls `ipc_kmsg_get` (copyin from user) →
`ipc_kmsg_copyin` (translate port names to kernel refs) →
`ipc_mqueue_send` (deliver). The copyin path calls
`ipc_kmsg_copyin_header` which does:

1. Look up `msgh_remote_port` by name in the current space
2. Look up `msgh_local_port` by name (reply port)
3. Acquire the appropriate rights based on `msgh_bits`
4. Convert user port names to kernel `ipc_port_t` pointers

Every one of these steps goes through the fd bridge's `ipc_entry_lookup`,
which calls `fget()` to find the fd, checks `DTYPE_MACH_IPC`, and returns
the entry. This is the same path that has already produced multiple bugs
(double-unlock, WITNESS reversal, stale visible state, explicit-name
mismatch, reverse-map lock order). The message path is the MOST complex
consumer of this bridge.

On the receive side, `ipc_kmsg_copyout_header` does the reverse: converts
kernel port refs to user-space names in the receiver's space. This calls
`ipc_object_copyout`, which is the reverse-map path that already needed a
lock-order fix (batch 16).

**The message path is where the fd bridge bugs concentrate** because it's
the only path that:
- Translates names to kernel refs (copyin)
- Translates kernel refs back to names (copyout)
- Handles multiple right types in a single operation
- Operates across spaces (sender and receiver)
- Must handle both the happy path and error cleanup

Every prior fd-bridge bug was found by exercising a new consumer of the
bridge. The message path is the largest untested consumer.

### Ranking of your listed risks

1. **Message-path semantics** — this IS the risk. Everything else is
   downstream of it.
2. **Valid right-transfer semantics across tasks** — requires
   `mach_msg` to test. Not independently testable.
3. **Another fd-bridge semantic mismatch** — yes, and the message path
   is where you'll find it.
4. **Fresh-name `COPY_SEND` gaps** — minor. `COPY_SEND` in
   `insert_right` is a convenience; the real `COPY_SEND` path is in
   `ipc_kmsg_copyin_header`.
5. **Notification / no-senders under real transfer** — downstream of
   message-based transfer working.
6. **Something else** — `swtch` remains separate and not strategically
   urgent.

## 4. Best Next-Step Sequence

### The minimal honest `mach_msg` probe

The smallest useful `mach_msg` test is **same-process send-to-self with
an inline-only message.** This avoids cross-process complexity while
exercising the full message path:

```
1. Allocate receive right → recv_name
2. Make send right → combined SEND|RECEIVE entry
3. Construct minimal message:
   - msgh_remote_port = recv_name (send to our own port)
   - msgh_local_port = MACH_PORT_NULL (no reply)
   - msgh_bits = MACH_MSGH_BITS(MACH_MSG_TYPE_COPY_SEND, 0)
   - msgh_size = sizeof(mach_msg_header_t) + small inline payload
   - msgh_id = arbitrary test ID
4. mach_msg(MACH_SEND_MSG) → sends the message
5. Read port status → msgcount should be 1
6. mach_msg(MACH_RCV_MSG) on recv_name → receives the message
7. Verify received header matches sent header
8. Read port status → msgcount should be 0
9. Destroy recv_name → returns to baseline
```

This is the right first probe because:
- It exercises `ipc_kmsg_get`, `ipc_kmsg_copyin`, `ipc_mqueue_send`,
  `ipc_mqueue_deliver` (send side)
- It exercises `ipc_mqueue_copyin`, `ipc_mqueue_receive`,
  `ipc_kmsg_copyout`, `ipc_kmsg_put` (receive side)
- It avoids complex descriptors (no OOL memory, no port descriptors)
- It avoids blocking (message is already queued when we receive)
- It avoids cross-process (same task, same space)
- The per-port observability can verify `msgcount` at each step
- If it panics, the WITNESS/INVARIANTS lane will catch the locking issue

### If send-to-self works: add reply port

```
1. Allocate recv_name (for request)
2. mach_reply_port() → reply_name
3. Send message with:
   - msgh_remote_port = recv_name
   - msgh_local_port = reply_name
   - msgh_bits = MACH_MSGH_BITS(MACH_MSG_TYPE_COPY_SEND,
                                 MACH_MSG_TYPE_MAKE_SEND_ONCE)
4. Receive from recv_name → verify reply port name appears in received msg
5. Send reply to the reply port name from the received message
6. Receive reply from reply_name
7. Verify round-trip
```

This tests the reply-port path, which involves `MAKE_SEND_ONCE`
disposition in the message header — a send-once right transfer via the
copyin path.

### If reply-port works: add cross-process

```
1. Parent allocates recv_name
2. Parent creates pipe for synchronization
3. Fork
4. Child: mach_reply_port() → child_reply
5. Child: needs parent's recv_name — BUT fds aren't inherited
```

This is where the bridge constraint matters. The child cannot use the
parent's port names because `DTYPE_MACH_IPC` fds aren't inherited. To
do cross-process Mach IPC in this bridge, you need a bootstrap
mechanism:

- **Option A:** Use `task_self`/`host_self` as the initial contact port
  (both sides can independently acquire send rights to known kernel
  ports)
- **Option B:** Use a side channel (pipe, shared memory) to pass the
  port name integer, then have the child call a kernel trap that
  translates it
- **Option C:** Investigate whether the bootstrap port
  (`itk_bootstrap`) is inherited and usable

But cross-process is tier 3. Don't plan for it in this block. Get
same-process `mach_msg` working first.

### Recommended 6-10 hour block

| Step | Time | What |
|------|------|------|
| 1 | 1h | Write same-process send-to-self probe (inline-only, no reply port) |
| 2 | 1h | Build and run under MACHDEBUGDEBUG |
| 3 | 2h | Debug whatever breaks (expect fd-bridge issues in copyin/copyout) |
| 4 | 1h | Once send-to-self passes: add reply-port variant |
| 5 | 1h | Run reply-port variant, debug |
| 6 | 1h | Add per-port observability checks around message ops (msgcount, srights changes) |
| 7 | 1h | Document findings, commit clean evidence |
| 8 | 1h | If time: investigate bootstrap port inheritance for cross-process path |

### What I expect to break

Based on the pattern of prior bugs, the most likely failure points are:

1. **`ipc_kmsg_copyin_header` → `ipc_entry_lookup`** — the message
   header copyin translates port names to kernel refs. This goes through
   the fd bridge's `fget()` path. Any mismatch between the entry's
   `ie_bits` type and the requested disposition will fail here.

2. **`ipc_kmsg_copyout_header` → `ipc_object_copyout`** — on the receive
   side, converting kernel port refs back to user names. This is the
   reverse-map path that already needed a WITNESS fix. Under message
   receive, the locking context may be different (mqueue locked,
   receiver waking up).

3. **`ipc_mqueue_receive` → `thread_block`** — if the message isn't
   already queued when receive is called (shouldn't happen in send-to-self,
   but edge cases exist).

4. **WITNESS lock-order violations** — new locking combinations that
   only occur in the message path. The copyin/copyout paths acquire space
   locks, port locks, and entry locks in combinations that the pure
   lifecycle path never exercises.

## 5. What to Avoid

1. **Do not try to build a cross-process probe before same-process
   `mach_msg` works.** Cross-process adds fd-inheritance problems,
   synchronization complexity, and bootstrap bootstrapping. Same-process
   send-to-self is the honest first step.

2. **Do not try to fix `COPY_SEND` for `insert_right` first.** The
   `KERN_RIGHT_EXISTS` failure in `insert_copy_send_right_fresh` is
   irrelevant for the message path. `COPY_SEND` in the message header
   is handled by `ipc_kmsg_copyin_header`, not by `insert_right`. The
   probe doesn't need `insert_right` at all.

3. **Do not add more lifecycle probes.** The single-task lifecycle lane
   is genuinely exhausted. Adding more variants of alloc/destroy/churn
   will not find new bugs.

4. **Do not add more observability before trying `mach_msg`.** The
   current per-port and per-space observability is sufficient for the
   first message probe. If `mach_msg` breaks, the WITNESS lane and
   serial log will tell you where. Additional observability can be added
   in response to specific needs.

5. **Do not investigate `swtch` yet.** It remains a scheduler-lock
   issue orthogonal to IPC. The message path is higher priority.

6. **Do not try to make the message probe "complete" on the first
   attempt.** Start with the absolute minimum: send one inline message
   to yourself, receive it, check the header. No OOL data, no complex
   descriptors, no port-in-message, no reply port, no timeout, no
   blocking. Add complexity only after the minimum works.

## 6. Open Assumptions

1. **The `mach_msg_trap` syscall wiring is correct.** The trap is
   registered via `SYSCALL_INIT_HELPER(mach_msg_trap)` and dispatches
   through `sys_mach_msg_trap` → `sys_mach_msg_overwrite_trap` →
   `mach_msg_overwrite_trap`. This looks correct from the code, but the
   user-space headers need to expose the right syscall number and
   argument layout.

2. **`ipc_kmsg_get` copyin works for FreeBSD 15 user processes.**
   The message copyin uses `copyinmsg()` with legacy header translation.
   This should work on amd64 FreeBSD 15, but the
   `LEGACY_HEADER_SIZE_DELTA` / `CAST_MACH_NAME_TO_PORT` handling might
   have surprises.

3. **The probe can call `mach_msg_trap` directly via `syscall()`.** The
   probe already calls other Mach traps via `syscall()`. The message
   trap takes more arguments (up to 9 for `mach_msg_overwrite_trap`),
   so argument passing needs to work correctly for this syscall width.

4. **`ipc_mqueue_receive` without blocking works.** For same-process
   send-then-receive, the message should already be queued. The receive
   path should find it immediately via `ipc_mqueue_receive` without
   entering `thread_block`. But if the fast path is broken, the probe
   might hang instead of panic.

5. **Timeout handling works for safety.** Use `MACH_RCV_TIMEOUT` with
   a short timeout on the receive side so a broken receive path returns
   an error instead of hanging the guest.

## Delta Since Last Review

The last review (`implicit-close-investigation-review.md`) identified
three corrections to the first review:
1. Fork/exit implicit-close path doesn't work (fds not inherited)
2. Local send-once close is correct (queued notification semantics)
3. `mach_port_close` fix priority was wrong (not a blocker)

Since that review, the project:
- Committed the per-port observability and `mach_port_close` dispatch
- Confirmed fork fd non-inheritance with clean committed evidence
- Characterized kernel-self-port reverse-map semantics (batch 16)
- Fixed another WITNESS lock-order issue in `ipc_object_copyout`

The net effect: all pre-message lifecycle work is now clean. The
decision space has collapsed to "try `mach_msg` or don't." The
recommendation is: try it. It's the only remaining path that exercises
untested bridge consumers.
