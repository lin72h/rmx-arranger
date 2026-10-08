---
id: op-555
state: hold
agent: implementer
repo: rmx-implementer
idq: id-061
needs: op-552
authority: libmach or test changes if the cause is there; existing op547 images and copies; 5 self-check boots; no push
expected: 3h
updated: 2026-10-08T02:41Z
---
# op-555 — Implementer: op-550 mismatch, xpc_receive_test:peer_pending fact 13 (2 references instead of 1) on op-547's fixed image

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 3 hours.**

gatekeeper1's proof of op-547 (op-550,
`/Users/me/wip-mach/rmx-gatekeeper1/build/op550/findings.md`,
`results-r2.md`) passed everything except one earlier case on the
fixed image: `xpc_receive_test:peer_pending`, phase
`peer_send_error`, `fact=13 expected=1 observed=2` (the remaining
remote reference count), serial
`/Users/me/wip-mach/rmx-gatekeeper1/build/op550/runtime/rmx-op550-fixed-all-20261008T021726Z-79358/serial.raw:5405`.
That case passed in every earlier proof (op-505, op-511, op-534,
op-540) and in your op-547 self-check. Port names are file descriptors
in our kernel, and op-547 now creates and frees one reply-port name
per thread, so name reuse timing changed; that is one possibility,
not a finding.

1. **Is it op-547?** The op-547 pair differs only in libmach
   (`build/op547/r2/images/op547-{base,fixed}-tests-r2.raw`). On a copy
   of each, run `xpc_receive_test:peer_pending` repeatedly (for
   example 50 times per boot) and record every fact-13 value. If it
   fails only on fixed, the change is involved; if on both, it is an
   older intermittent problem.
2. **Cause.** From the test (`tests/lib/libxpc/xpc_receive.zig`, the
   `peer_send_error` phase and its `report`), libxpc's send-error path
   and libmach, say what holds the second reference when fact 13 reads
   2: a real extra right, or the test's count observing a reused name
   or a reference still in flight. Name it with file:line.
3. **Fix within scope.** If the cause is in libmach (op-547's change)
   or is a test assumption about timing or names, fix it in this op
   (test fixes on both branches, identical), rerun the repeat on both,
   and run the full fixed suite once. If the cause is in libxpc, the
   kernel or launchd, stop and report it with file:line.

Evidence: commits; your op record (`docs/op555-peer-pending.md`) with
the repeat counts per image, the cause, the change if any, and the
results; any new image hashes and BOMs (by path); the `selfcheck:`
line.

## Limits

- libmach and tests only; no kernel, libxpc, libdispatch or launchd
  change. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
