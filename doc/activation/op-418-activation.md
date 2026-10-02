---
id: op-418
state: draft
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-046
gate: self
authority: guest boots: up to 5 on copies of op416-base-tests.raw and op416-fixed-tests.raw, 5-minute cap each; doas: load vmm.ko if absent, and the runner's bhyve calls; push rmx-gatekeeper1 main
updated: 2026-10-02T04:17Z
---
# op-418 — Gatekeeper 1: final Mach batch-1 test proof on op-416's images (base null_fd, base FAIL/PASS set, whole fixed suite)

## Outcome

Context: ordinary bug fixing in our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source Mach IPC). Some regression tests stop the kernel on the unfixed code; that is their
expected "before" result. Everything runs in disposable bhyve guests with no network.

Finish the batch-1 before/after proof. op-411 (rmx-gatekeeper1 `13f1212`) left seven mismatches with
three causes; op-416 (`wip-rmxos@903c8fc2`) fixed them:
- the fixture now loads: `mach.ko` declares `MODULE_VERSION(mach, 1)`; the base `mach.ko` is alpha2
  plus only that line;
- `fd_exhaustion` now returns `MACH_RCV_BODY_ERROR|MACH_MSG_IPC_SPACE`, per XNU;
- the clock tests bound their own wait.

Images (work on copies):
- base + tests: `/Users/me/wip-mach/stage/images/op416-base-tests.raw` sha256 `966c12c633b65f3614ab6e61493071fc144bfb0781f3b9a2ffb33db0a500d21b`
- fixed + tests: `/Users/me/wip-mach/stage/images/op416-fixed-tests.raw` sha256 `eb410cc771b03a7b0b09273743260e678fe927982284c895a5c731e16172e105`

Run, by direct ATF invocation as before:
1. Base: `mach_proc_info_test:null_fd` alone (expected PANIC).
2. Base: every case expected to FAIL or PASS, in one boot. This includes the fixture programs
   (`mach_translate_test`, `mach_timeout_test`): op-411's base FAILs for them came from the fixture
   not loading, so they do not count.
3. Fixed: the whole suite (27 cases), in one boot.

op-408's 13 base panics (B01-B13) stand: the base kernel code is unchanged.

Result: one final table of all 27 cases on both images, expected against observed, with the serial
line or ATF result file for each, every mismatch listed, and for each FAIL the reason the test
printed (so a load failure cannot pass as the defect).

Evidence by path; hash only each boot's raw serial log. Commits on origin.

## Limits

- No product edits. If one case cannot run, record it and finish the others.

Re-read OPS.md first: defaults and the REPORT block.
