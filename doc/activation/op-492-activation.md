---
id: op-492
state: closed
agent: validator3
repo: rmx-validator3
idq: id-046
authority: none beyond the defaults: read-only; no guests
expected: 2h
issued-at: 2026-10-05T01:03Z
updated: 2026-10-05T01:03Z
---
# op-492 — Validator 3: review of op-484 (launchd consumer fixes, step 4 part 2b)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Review the source.

**Expected time: about 2 hours.**

op-484 adapts launchd to the step 4 contract you reviewed for
libdispatch in op-474 (no EOF; an owner keeps a receive name and its
set membership until its own cancellation completes; watched names
are released with `mach_port_deallocate`). 10 commits on
`mach-fixes-5`, from `b2d5f5b7` to `wip-rmxos@10a3fd65`. Source
(clean at that commit):
`/Users/me/wip-mach/rmx-implementer/build/op468/source`. The
Implementer's record with its change-to-test table:
`/Users/me/wip-mach/rmx-implementer/docs/op484-launchd.md`. Its
self-check: fixed 68/68 (65 earlier + `demand_removed`,
`close_unregistered`, `late_dead_name`); base: `demand_removed` fails
as recorded, `late_dead_name` passes, `close_unregistered` not run on
base.

Check:
1. **Demand lookup** (`sbin/launchd/runtime.c` `mportset_callback`,
   around 598-615): a set member with messages but no current job is
   skipped; no other job's callback runs for it; the scan still
   handles the next member correctly.
2. **Closing receive rights** (`launchd_mport_close_recv`, around
   861-875, and `runtime_remove_mport`, around 834-845): the right
   leaves `demand_port_set` / `ipc_port_set` before it is destroyed,
   for registered and unregistered names and for a right already
   outside any set; `MACH_PORT_INDEX(name)` is bounded before the
   callback table is used. Check every caller of
   `launchd_mport_close_recv` in `core.c` against the new order.
3. **Message drain** (`core.c` `machservice_drain_port`, around
   7338-7394; no runtime test in this op, so this review is its
   check): the receive now uses the allocated request and reply
   buffers with their real sizes; both are freed on every path;
   with `drain_all` the loop ends on any result other than
   `MACH_MSG_SUCCESS`; `mach_msg_destroy` is applied only to a
   successfully received message; the exception-server branch
   (`launchd_exc_runtime_once`) gets correct buffers and sizes.
4. **Dead names** (`runtime.c` `do_mach_notify_dead_name`, unchanged):
   the extra dead-name uref is released once, also when no job record
   remains.
5. **Test hooks:** `sbin/launchd/Makefile`, `core.c` and `runtime.c`
   gain blocks under `LAUNCHD_CONSUMER_TESTING`, enabled only when
   `LAUNCHD_CONSUMER_FIXTURE` is set, plus `--wrap` link options.
   Confirm a normal build compiles none of it and links no test
   library, and that the wrappers only observe.
6. **Tests and scope:** would `demand_removed` and
   `close_unregistered` detect their defects at `b2d5f5b7`? Is
   `late_dead_name` a useful control? Only `sbin/launchd` and its
   tests changed.

Distinguishing question: is there a path where launchd, as PID 1,
uses a receive name or table slot after the right is gone, or runs a
callback for a job other than the one that owns the port?

Re-read OPS.md first: defaults and the reply block.
