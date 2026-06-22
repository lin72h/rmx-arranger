# Donor Lane Next-Risk Review

Date: 2026-04-17
Reviewer: Claude (wip-claude)

## 1. Overall Verdict

Your interpretation is mostly sound, but you're **underestimating the severity**
of the fd-bridge concern. It's not just that current-task observability misses
global/object state. There is a concrete, structural correctness defect in the
process-exit cleanup path that silently corrupts port reference counts and
suppresses notification delivery in any cross-task scenario. This defect is in
the code right now, and it will bite the moment you test anything
multi-process beyond the trivial fork/exit smoke.

The single-task lifecycle lane is genuinely strong. The teardown-adjacent
split was high-quality work. But the evidence has now exhausted what
single-task testing can prove. The next frontier is not "harder single-task
cases" — it is cross-task right accounting, and the first thing you'll find
there is that the fd bridge bypasses the Mach right-accounting layer during
implicit cleanup.

## 2. What the Current Strongest Evidence Actually Proves

### Proven (strong confidence)

1. **Single-task IPC namespace lifecycle works under WITNESS.** Allocate,
   use, explicit-destroy returns to baseline for receive, send, send-once,
   port-set, and combined entries. WITNESS sees no lock-order violations on
   committed head.

2. **The fd bridge correctly maps and unmaps entries for explicit destroy
   paths.** `ipc_right_destroy` → `ipc_entry_dealloc` → `ipc_entry_close`
   properly tears down the fd, removes the entry from the space list, and
   clears visible state before deferred close.

3. **Concurrent single-task lifecycle works.** 4×64 and 4×128 shared-task
   contention passes with baseline return and `diagnostic_count: 0`.

4. **Current-task observability is trustworthy for the tested cases.** The
   sysctl correctly reads live entry state from `is_entry_list`, correctly
   tracks fd count via the bridge, and correctly shows mid-flight state.

5. **Notification delivery works for explicit destroy.** Send-once destroy
   triggers `ipc_notify_send_once`, which constructs a kmsg and delivers it
   via `ipc_mqueue_send_always`. The batch 12D clean pass confirms this path
   completes without panic or WITNESS violation.

### Not proven (and cannot be proven with current instruments)

1. **Port object reference counts are correct after teardown.** The
   current-task sysctl sees entry-level state (what names exist in the
   space). It does NOT see `ip_srights`, `ip_sorights`, `ip_references`,
   `ip_msgcount`, or any other port-object-level counter. A "baseline return"
   in the sysctl means the entry list is empty, not that the underlying port
   objects are properly freed.

2. **Process-exit cleanup does proper right accounting.** (See section 3.)

3. **Notification delivery works on implicit cleanup.** No-senders
   notifications, dead-name notifications, and send-once notifications are
   all supposed to fire during teardown. The explicit-destroy path tests this
   for send-once. But the process-exit path does not go through
   `ipc_right_destroy` at all.

4. **Cross-task right transfer and accounting are correct.** No test
   currently has process A hold a send right to process B's port and verify
   the right is properly cleaned up when A exits.

5. **Fork inheritance is correct beyond trivial smoke.** The fork/exit
   smoke has the child allocate its own fresh ports. It does NOT test
   inherited rights from parent, cross-task cleanup, or inherited
   notification state.

## 3. The Most Fundamental Remaining Problem

### The `mach_port_close` fd-bridge bypass

The fd bridge's `fo_close` handler is `mach_port_close` at
`ipc_entry.c:232-270`. This is what runs when any Mach IPC file descriptor
is closed — either explicitly or during process exit via
`ipc_entry_list_close`.

Here is the problem. For **non-receive rights** (send, send-once,
dead-name), `mach_port_close` does:

```c
} else {
    port = (ipc_port_t)object;
    if (port->ip_receiver == current_space()) {
        ip_lock(port);
        ipc_port_clear_receiver(port);
        ipc_port_destroy(port);
    } else {
        ip_release(port);     /* <-- THIS IS THE BUG */
    }
}
```

When `port->ip_receiver != current_space()` (i.e., we hold a send right to
someone else's port, or a send-once right), the cleanup is just
`ip_release(port)`. This drops one reference, but it does **none** of the
following:

1. **Does not decrement `ip_srights`.** The port's send-right count stays
   elevated even though no holder exists. `ip_srights > 0` permanently.

2. **Does not check for and send no-senders notification.** If this was the
   last send right and the port has an `ip_nsrequest`, the no-senders
   notification never fires.

3. **Does not decrement `ip_sorights`.** Send-once rights leak their count.

4. **Does not send send-once notification.** When a send-once right is
   consumed, the receiver should get a `MACH_NOTIFY_SEND_ONCE` message.
   `mach_port_close` never sends it.

5. **Does not handle dead-name notification requests.** If there are
   registered dead-name notification requests, they are silently dropped.

Compare this with the proper teardown in `ipc_right_destroy`
(ipc_right.c:597-713), which handles all of these cases per right type.

### Why this matters

Every current test uses explicit `mach_port_destroy` via the syscall trap.
This goes through `ipc_right_destroy`, which does proper accounting. The
tests pass because they use the correct path.

But **process exit** goes through `ipc_entry_list_close` →
`kern_last_close` → `fdrop` ��� `mach_port_close`. This bypasses the entire
Mach right-accounting layer.

Concrete consequence: if process A holds a send right to process B's port,
and A exits:
- A's IPC space will appear clean (entries removed from list)
- B's port will have a permanently elevated `ip_srights` count
- B will never receive a no-senders notification
- B's port object leaks a "phantom" send right indefinitely

This is not a theoretical concern. It is a structural defect in the existing
code that will produce silent corruption the moment you do any cross-task
right transfer or multi-process lifecycle testing.

### Why current-task observability cannot see this

`mach.current_task_space_stats` reads from `space->is_entry_list`. After
`mach_port_close` runs, the entry is removed from the list and the entry
struct is freed. The sysctl will correctly show zero entries. But the
underlying port object (which lives independently of any entry) still has
wrong reference counts.

To see this, you need **port-object-level** observability: the ability to
read `ip_srights`, `ip_sorights`, `ip_references` for a given port.

## 4. Best Next-Step Sequence

### Tier 1: Confirm the defect (1-2 hours)

1. **Add per-port reference count observability.** Extend the donor sysctl
   (or add a new one) that, given a Mach port name, reports:
   - `ip_references`
   - `ip_srights`
   - `ip_sorights`
   - `ip_mscount`
   - `ip_msgcount`
   - `ip_active`

   This is a small kernel change — look up the entry by name, read the
   port's fields under `ip_lock`, report them.

2. **Write a cross-task right-accounting probe:**
   - Parent allocates a receive right
   - Parent creates a send right via `MAKE_SEND`
   - Parent reads port refcounts (should see `ip_srights=1`)
   - Parent forks
   - Child receives the send right (via the fd bridge inheritance)
   - Child exits
   - Parent reads port refcounts again
   - **Expected (correct):** `ip_srights` returns to pre-child value and
     no-senders notification fires if appropriate
   - **Expected (current bug):** `ip_srights` stays elevated, no
     notification

   This probe will confirm the defect.

### Tier 2: Fix the defect (2-3 hours)

3. **Fix `mach_port_close` to do proper right accounting.** The fix is NOT
   to call `ipc_right_destroy` directly (it has different locking
   expectations). Instead, `mach_port_close` needs to:

   - For send rights: decrement `ip_srights` under `ip_lock`, check for
     and send no-senders notification
   - For send-once rights: decrement `ip_sorights`, send
     `ipc_notify_send_once`
   - For dead-name: nothing beyond what it already does
   - For receive: current code is correct (`ipc_port_clear_receiver` +
     `ipc_port_destroy`)

   This mirrors what `ipc_right_destroy` does for each type, adapted to
   the fd-close context where the space lock is NOT held.

4. **Re-run the entire lifecycle suite under debug** to confirm no
   regressions. The explicit-destroy tests should still pass because
   `mach_port_close` only runs during implicit cleanup.

### Tier 3: Verify the fix (1-2 hours)

5. **Re-run the cross-task right-accounting probe.** Confirm `ip_srights`
   returns to correct value after child exit.

6. **Write a notification delivery probe for process exit:**
   - Parent allocates receive right, registers no-senders request
   - Child gets send right, exits
   - Parent checks whether no-senders notification was delivered

7. **Run the fork/exit smoke under the new per-port observability** to
   verify that the existing fork/exit test also shows correct port-level
   state, not just space-level state.

### Tier 4: Extend (remaining time)

8. **Document the findings.** Record the defect, fix, and verification
   evidence in a findings doc.

9. **If time remains:** begin message-adjacent setup characterization.
   The notification delivery path already exercises `ipc_mqueue_send_always`
   → `ipc_mqueue_send`, so there is some indirect message-path evidence.
   The next useful explicit message work would be a trivial
   send-to-self via `mach_msg_trap` with a minimal inline payload.

## 5. What to Avoid

1. **Do not attempt `mach_msg` work before fixing `mach_port_close`.** The
   message path will create cross-task right transfers, which will exercise
   the broken cleanup path. Fix the foundation before building on it.

2. **Do not add more single-task teardown probes.** That lane is genuinely
   exhausted. The remaining value is in cross-task scenarios, and the first
   thing you'll find is the `mach_port_close` defect.

3. **Do not try to fix `swtch` yet.** It remains orthogonal. The
   scheduler-lock ownership panic (`mutex sched lock 1 not owned`) is a
   FreeBSD scheduler integration issue, not an IPC issue.

4. **Do not widen observability to global scope before fixing the known
   defect.** A global port audit is useful later, but right now the minimum
   useful instrument is per-port refcount visibility so you can confirm
   and verify the `mach_port_close` fix.

5. **Do not try to make `ipc_entry_list_close` call `ipc_right_destroy`
   directly.** The locking is wrong — `ipc_right_destroy` expects the
   space to be write-locked and unlocks it internally, but
   `ipc_entry_list_close` is iterating the fd table without the space lock.
   The fix belongs in `mach_port_close`, not in the exit handler.

6. **Do not test fork inheritance of user-visible Mach port names.** The
   fork path creates a fresh IPC space for the child (via
   `ipc_task_create` in `mach_task_init`). The child does NOT inherit the
   parent's user-created Mach port names. What it inherits (via
   `ipc_task_init` → `ipc_port_copy_send`) are task-level kernel ports
   (exception ports, bootstrap port, registered ports). Test those
   specifically, not generic name inheritance.

## 6. Open Assumptions

1. **`ipc_entry_list_close` runs before the normal fd table teardown.**
   It's registered as a `process_exit` event handler. I'm assuming FreeBSD's
   process exit sequence runs event handlers before the final fd table
   destruction. If the ordering is different, the cleanup path may have
   additional issues. Worth verifying with a `printf` or DTrace probe.

2. **`mach_port_close` is the only implicit cleanup path.** There's also
   the `process_exec` registration. If exec properly tears down the old
   Mach state and creates fresh state, exec should have the same issue as
   exit. But exec may also have additional complications around which task
   state survives.

3. **The `ref_count = 2` overwrite in `task_init_internal` is benign.**
   `mach_task_init` (process_init handler) calls `task_create_internal`
   which sets `ref_count = 2`. Then `mach_task_fork` (process_fork handler)
   calls `task_init_internal` which also sets `ref_count = 2`. If both
   handlers fire for the same child process, the second overwrite is safe
   only if no other code has taken additional references in between. This
   should be verified.

4. **Notification delivery via `ipc_mqueue_send_always` is safe without
   a receiver.** When a notification is sent to a dead or inactive port,
   `ipc_mqueue_send` checks `!ip_active(port)` and destroys the kmsg. This
   should be correct, but the notification path hasn't been explicitly
   tested under process exit conditions where the target port may be
   mid-teardown.

5. **The `MACH_SEND_ALWAYS` flag bypasses queue limits.** Notification
   delivery uses this flag, meaning notifications can be delivered even when
   the queue is full. Under heavy notification load (many ports being torn
   down simultaneously), this could cause unbounded memory allocation via
   `ikm_alloc`. This is probably not a near-term risk but is worth knowing.

## Answers to Specific Questions

### Q1: Is the current interpretation sound?

Yes, with one correction. You're right that current-task observability
doesn't see global state, and you're right that the fd bridge is the main
hazard. But you're framing it as "observability may miss something." The
reality is stronger: there is a known structural defect in `mach_port_close`
that will produce wrong results in any cross-task scenario. It's not
"I might miss a leak" — it's "the cleanup code is objectively incomplete."

### Q2: What does the evidence prove/not prove?

See section 2.

### Q3: Single most fundamental next risk?

The `mach_port_close` right-accounting bypass. See section 3. This is more
fundamental than any of the alternatives you listed because it's not a
risk — it's a known defect.

Among your listed risks, ranked:

1. **FreeBSD fd-bridge semantic mismatch** — this IS the risk, and
   `mach_port_close` is the first concrete instance
2. **Current-task-only observability** — real gap, but it's an instrument
   problem, not a correctness problem
3. **Cross-task / inheritance cleanup** — will expose the
   `mach_port_close` defect immediately
4. **Notification / send-once / no-senders** — downstream consequence of
   the `mach_port_close` defect
5. **Message-queue initialization** — not yet reachable without fixing the
   above
6. **Something else** — the `task_init_internal` ref_count overwrite is a
   secondary concern

### Q4: Best next milestone?

See section 4. The sequence is: add per-port observability → confirm the
defect with a cross-task probe → fix `mach_port_close` → verify → then
message-adjacent.

### Q5: Do I need stronger observability?

Yes. The minimum useful addition is a per-port reference count sysctl. Given
a Mach port name, report `ip_references`, `ip_srights`, `ip_sorights`,
`ip_mscount`, `ip_active`. This is a small extension of the existing
donor-only sysctl pattern.

### Q6: Is the fd bridge the main hazard?

Yes. The specific class of bug to expect: any code path that implicitly
destroys Mach rights (process exit, exec, or future fd inheritance
shortcuts) that goes through the fd-close path instead of
`ipc_right_destroy`. The fd bridge creates a parallel cleanup path that
doesn't speak the Mach right-accounting protocol.

### Q7: Should `swtch` remain isolated?

Yes. The evidence is unambiguous: `swtch` panics with
`mutex sched lock 1 not owned`, which is a scheduler-lock ownership issue in
`_swtch_pri` → `sys_swtch`. This is about FreeBSD scheduler integration,
not IPC. Deferring it is not becoming a mistake — there is higher-value work
to do first.

### Q8: 6-10 hour implementation block?

See section 4. Exact sequence:

| Step | Time | What |
| --- | --- | --- |
| 1 | 1.5h | Add per-port refcount sysctl to donor kernel |
| 2 | 1h | Write cross-task right-accounting probe |
| 3 | 0.5h | Run probe, confirm `mach_port_close` defect |
| 4 | 2h | Fix `mach_port_close` right accounting per type |
| 5 | 1h | Re-run full lifecycle suite under debug |
| 6 | 1h | Run cross-task probe again, verify fix |
| 7 | 1h | Write and run notification delivery probe |
| 8 | 1h | Document findings |

### Q9: What to avoid?

See section 5.
