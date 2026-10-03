---
id: op-446
state: dropped
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-046
gate: self
authority: guest boots: up to 4 on copies of op444-base-tests.raw and op444-fixed-tests.raw, a 5-minute cap each except the repeat boot (10 minutes); doas: load vmm.ko if absent, and the runner's bhyve calls; push rmx-gatekeeper1 main
updated: 2026-10-03T05:30Z
---
# op-446 — Gatekeeper 1: final Mach batch-3 proof on op-444's images (41 cases, plus thread_control_death x20)

## Outcome

Context: ordinary bug fixing in our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source Mach IPC). Everything runs in disposable bhyve guests with no network.

Final proof of Mach batch 3 (`mach-fixes-3` at `844112f4`). Since your op-443, only
`thread_control_death` changed: the fixture lookup that panicked is gone, and the case now polls
up to 15 seconds for the exited thread's control port to go inactive and prints the elapsed time.
The Implementer's own guest self-check gave base 10/10 as expected, fixed 41/41, and 20/20 repeats
at 4.9-10.0 s (`/Users/me/wip-mach/rmx-implementer/docs/op444-thread-control-selfcheck.md`).
Expectations: `tests/sys/mach/EXPECTATIONS.md` at `844112f4`.

Images (work on copies; the test files are byte-identical in both, and only the kernel and `mach.ko` differ):
- base: `/Users/me/wip-mach/stage/images/op444-base-tests.raw` sha256 `1b6238b705f3ac7337b8ddf3752071ccff57230ddd40bb99d97a98d54d9fd739`
- fixed: `/Users/me/wip-mach/stage/images/op444-fixed-tests.raw` sha256 `160c3843816a9cabcc046936b255a546d4f145f700e124212f70d728dac08789`

With your op-443 harness (per-case outer timeout above 25 seconds):
1. Base: the 10 batch-3 cases, as recorded.
2. Fixed: all 41 cases PASS (`failed_creation` with `observed_constructed=1`).
3. Fixed, repeat boot (10-minute cap): `thread_control_death` 20 times; record elapsed ms and PASS/FAIL.

Result: the 41-case table (expected, observed, serial line, each FAIL's reason, every mismatch)
and the 20-run table.

Evidence by path; hash only each boot's raw serial log. Commits on origin.

## Limits

- No product edits. If one case cannot run, record it and finish the others.

Re-read OPS.md first: defaults and the REPORT block.
