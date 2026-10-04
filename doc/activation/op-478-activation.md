---
id: op-478
state: returned
agent: implementer
repo: rmx-implementer
idq: id-046
gate: self
authority: libdispatch builds (no world); 2 images; 3 self-check boots; no push
expected: 3h
issued-at: 2026-10-04T10:40Z
updated: 2026-10-04T11:13Z
---
# op-478 — Implementer: op-468 remediation — release resources after a partial receive

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 3 hours** (tests 1 h, fix 30 min, two images
and self-checks 1 h, record 30 min).

validator3 reviewed op-468 (`mach-fixes-5@015e7723`): the cancellation
fence and the readiness after the 32-attempt bound hold. One defect
to fix and one test to add. Continue on `mach-fixes-5` in
`build/op468/source`.

1. **Fix: resources left after a partial receive**
   (`lib/libdispatch/src/source.c:2793-2797`). When the manager's
   aggregate `mach_msg` returns `MACH_RCV_BODY_ERROR`, the kernel has
   still copied the message into the buffer with the rights and
   out-of-line memory it already transferred
   (`sys/compat/mach/ipc/mach_msg.c:436-443`, `ipc_kmsg_put` on that
   path). The manager logs the error and breaks, so those rights and
   mappings are never released. Release what was received (for
   example `mach_msg_destroy` on the buffer, or the existing
   destruction path), free a grown buffer as today, and keep
   draining or stop as the other errors do; say which and why.
   Test first: a case where a receive returns `MACH_RCV_BODY_ERROR`
   with rights already in the buffer, then checks that each of those
   rights is released (urefs back to the expected count) and the
   manager stays responsive. A real partial copyout is hard to force
   in a guest; your `coordination.c` already wraps `mach_msg`, so it
   may do the real receive and report `MACH_RCV_BODY_ERROR` for one
   chosen message. Say which method you used and what it shows.
2. **Test only: unregister with a request still pending**
   (`source.c:2969-2995`). Cancel a still-live send-possible or
   dead-name watch whose notification request is pending: the
   request returns a send-once right in `previous`, which libdispatch
   consumes with its existing `consume_send_once_right` message
   (`source.c:2994`, handled by `init.c:1281`). This stays as it is:
   it is the upstream mechanism and releases exactly that right.
   The test checks the returned right is released, the watched
   owner's uref is untouched, and the source ends with one
   cancellation. Expected to pass on both images (a control).

Then two images, reusing the existing world: base = `015e7723` +
the new tests, fixed = the fix + the same tests (test files
byte-identical). Self-check: test 1 fails on base and passes on
fixed; test 2 passes on both; all 61 earlier cases still pass on
fixed. Keep op-468's image pair: gatekeeper1 is proving it now.

Evidence: the commits; your op record with the fix, both tests and
their base and fixed results; both image hashes and BOMs (by path);
the `selfcheck:` line.

## Limits

- libdispatch and its tests only: no kernel, launchd or libxpc
  change. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
