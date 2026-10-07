---
id: op-526
state: issued
agent: implementer
repo: rmx-implementer
idq: id-046
authority: test and mach.ko/kernel builds as needed (no world); restage both ZFS images; 5 self-check boots; no push
expected: 4h
issued-at: 2026-10-07T02:38Z
updated: 2026-10-07T02:38Z
---
# op-526 — Implementer: op-524 continuation (descriptor reservation by dup2; rerun the pair; catch op-521's missing launchd reply)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 4 hours** (test fix and restage 1 h, pair
self-checks 1 h, repeat runs 1 h, record 1 h).

op-524 stopped correctly (`docs/op524-recovered-readiness.md`). Its
kernel fix `ab26bbed` is right and its base run showed the defect
(scans zero, set receives `MACH_RCV_TIMED_OUT`, messages still queued),
but the new test assumed `open("/dev/null")` takes the retired
descriptor number, so the run was rejected. op-521's three
`launchd control reply missing` failures and the shutdown that did not
finish are still unexplained. This op finishes both on `mach-fixes-6`.

1. **Test fix.** In `mach_recovered_readiness_test:recovered_receive`,
   reserve the retired descriptor explicitly with `dup2` (check the
   returned target, keep it open until the case ends). Commit it on
   the base branch `mach-fixes-6-op524-base` and on `mach-fixes-6`, so
   both images get identical test files. No kernel change.
2. **Pair.** Restage both images with the corrected test (base kernel
   `0facf74b`, fixed kernel `ab26bbed`; METALOG/BOM diff: only the
   kernel, `mach.ko` and the test binary versus op-524's images).
   Self-check: base `recovered_receive` FAIL with its readiness reason
   only; fixed, all cases in your order, then all cases in
   gatekeeper1's op-521 order; all PASS, normal power-off after each.
3. **op-521's missing reply.** Every earlier gatekeeper1 proof on the
   older kernel passed these launchd cases (op-498, op-505, op-511);
   they failed once on op-518's kernel and passed in your runs. launchd
   watches its demand set with `EVFILT_MACHPORT`
   (`sbin/launchd/runtime.c:247`), so an occasional lost readiness
   notification in the new publication path
   (`ipc_pset_signal`, `ipc_pset_work`, `ipc_pset_publish`,
   `ipc_pset.c:154-260`) would look exactly like this. With your
   remaining boots on the fixed image, run the launchd consumer cases
   repeatedly in gatekeeper1's order, and at the first missing reply,
   before the case exits, capture PID 1's kernel stacks
   (`procstat -kk 1`), its kevent registrations if available, and the
   demand set's members and their message counts
   (`mach_port_get_set_status` / `mach_port_get_attributes` from a
   small fixture). Report what PID 1 was waiting for and whether a
   queued message had no readiness. Do not fix it in this op; if you
   find a cause in the source, describe it with file:line.

Evidence: the commit(s); an addendum to
`docs/op524-recovered-readiness.md` with the test fix, both images'
hashes and BOMs, base and fixed results, and the repeat-run record
(iterations, any failure, the captured state); the `selfcheck:` line.

## Limits

- Test files and the self-check fixture only; no kernel, launchd,
  libdispatch or libxpc change. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
