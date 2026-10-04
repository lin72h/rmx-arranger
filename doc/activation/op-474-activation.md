---
id: op-474
state: closed
agent: validator3
repo: rmx-validator3
idq: id-046
authority: none beyond the defaults: read-only; no guests
expected: 2h
issued-at: 2026-10-04T10:25Z
updated: 2026-10-04T10:33Z
---
# op-474 — Validator 3: review of op-468 (libdispatch adaptation, step 4 part 2a)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Review the source.

**Expected time: about 2 hours.**

Step 4 part 1 (`mach-fixes-4@0924690c`, which you closed in op-465)
changed the kernel contract: every kernel reply is queued, receives
revalidate their entry, and LARGE keeps an oversize message queued.
op-468 adapts libdispatch to it: 11 commits on `mach-fixes-5`, from
`0924690c` to `wip-rmxos@015e7723`. Source (clean, at that commit):
`/Users/me/wip-mach/rmx-implementer/build/op468/source`. The
Implementer's record, with its rule-to-test table:
`/Users/me/wip-mach/rmx-implementer/docs/op468-libdispatch.md`.
Its self-check: fixed 61/61 (55 Mach + 6 dispatch), base 5 of the 6
new cases failing as recorded and `late_death` passing on both.

The rules op-468 had to meet:
- A source keeps its borrowed receive name and its set membership
  until cancellation completes, including the manager's unregister,
  event batches already copied and queued callbacks. A cancelled
  record is dropped before any numeric member lookup or set move.
- Send-death: registered before the source is published; an invalid
  or dead name at registration, or a send error, ends the source or
  channel cleanly with one terminal callback.
- Watched send and dead names: unregister, then release only owned
  urefs with `mach_port_deallocate`; never close or destroy the name.
- Receive: no wire buffers or options in the registrations; a
  bounded manager `mach_msg` on the aggregate set, timeout zero,
  keeping LARGE on growth and the supported trailer options; DIRECT/
  DIRECT_ONCE routing, buffer and right cleanup kept; re-enable once.

Check:
1. **Cancellation and the batch fence** (`aa666f83`, `source.c:529,
   785-849,2388`): records are snapshotted before `kevent`, cookies
   retired after the drain, and cancellation completes only after the
   unregister and the fence. Is there an order of manager thread,
   cancelling thread and target queue in which a copied record still
   moves a member, runs a handler or touches a freed cookie?
2. **Send-death** (`aa666f83`, `5540c0a3`, `09fefe31`; `source.c:558-
   575,2930-2970,4032`): every registration error now reaches one
   terminal event; the reconnect path registers and routes correctly.
   Any path left with zero or two terminal callbacks, or an extra
   uref release?
3. **Watched names** (`source.c:2966,3060-3072`): only owned urefs
   and displaced send-once rights are released, by
   `mach_port_deallocate`; nothing closes or destroys a borrowed name.
4. **Receive** (`aa666f83`, `5540c0a3`; `source.c:2531,2770-2804`):
   at most 32 timeout-zero attempts with LARGE and trailer options
   kept and trailer growth aligned. When the bound is reached with
   messages still queued, does readiness fire again, or can a
   message stay queued with nothing to wake the manager? DIRECT/
   DIRECT_ONCE routing, the local-port routing and the cleanup on
   every error path.
5. **Tests** (`tests/lib/libdispatch/dispatch_mach.zig`,
   `coordination.c`, `EXPECTATIONS`): would each of the five
   base-failing cases detect its defect at `0924690c`? Is
   `late_death` (passing on both, credited to the kernel's
   lifetime handling) still a useful control? `coordination.c` wraps
   `kevent`, `mach_msg`, `mach_port_move_member`,
   `mach_port_deallocate` and `mach_port_request_notification` to
   record calls: confirm it only observes and cannot change what it
   checks.
6. **Scope:** only `lib/libdispatch` and its tests (plus test
   registration) changed.

Distinguishing question: is there an order in which a record copied
before cancellation acts on a newer, unrelated port that reuses the
same name, or in which a queued message is left with no readiness to
wake the manager?

Re-read OPS.md first: defaults and the reply block.
