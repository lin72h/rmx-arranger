---
id: op-443
state: closed
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-046
gate: self
authority: guest boots: up to 4 on copies of op442-base-tests.raw and op442-fixed-tests.raw, a 5-minute cap each except the repeat boot (10 minutes); doas: load vmm.ko if absent, and the runner's bhyve calls; push rmx-gatekeeper1 main
updated: 2026-10-03T05:30Z
---
# op-443 — Gatekeeper 1: Mach batch-3 proof on op-442's images, plus thread_control_death repeated 20 times

## Outcome

Context: ordinary bug fixing in our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source Mach IPC). Everything runs in disposable bhyve guests with no network.

Repeat your op-441 proof on op-442's images. Only `mach_lifetime_test:thread_control_death`
changed: it now checks, right after `pthread_join`, that the thread's control port can no longer be
converted (fixture result 4 on fixed, 0 on base), then waits up to 15 seconds for the port to go
inactive and prints the elapsed time. Its ATF timeout is 25 seconds, so set the per-case outer
timeout above that. Record: `/Users/me/wip-mach/rmx-implementer/docs/op442-thread-control-death.md`;
expectations: `tests/sys/mach/EXPECTATIONS.md` at `mach-fixes-3@885be9ea`.

Images (work on copies; the test files are byte-identical in both, and only the kernel and `mach.ko` differ):
- base: `/Users/me/wip-mach/stage/images/op442-base-tests.raw` sha256 `024bb03fdd4569cf94de55727eaed30b6f17fb9f287b8a70e98ada41337f505b`
- fixed: `/Users/me/wip-mach/stage/images/op442-fixed-tests.raw` sha256 `0c810513807e1af9effd4ca40062453fe8c4b1639399d2662a9c417faa40f2fd`

Runs, by direct ATF invocation with your op-441 harness:
1. Base: one boot with the 10 batch-3 cases, expected as recorded (`thread_control_death` now
   fails at the immediate conversion check).
2. Fixed: one boot with all 41 cases, all expected to PASS (`failed_creation` with
   `observed_constructed=1`).
3. Fixed, repeat boot (10-minute cap): `thread_control_death` 20 times in a row. For each run, record
   the immediate conversion result and the elapsed time to inactive.
   Why: FreeBSD's `thr_exit` wakes the joiner before the exit hook marks the thread dying
   (`kern_thr.c:337-342`), so the immediate check could, rarely, see the port still convertible.
   We want to know whether that window shows up in practice.

Result: the 41-case table (expected, observed, serial line, each FAIL's reason, every mismatch),
and the 20-run table (run, conversion result, elapsed ms, PASS/FAIL).

Evidence by path; hash only each boot's raw serial log. Commits on origin.

## Limits

- No product edits. If one case cannot run, record it and finish the others.

Re-read OPS.md first: defaults and the REPORT block.
