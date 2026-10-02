---
id: op-425
state: issued
agent: implementer
repo: rmx-implementer
idq: id-059
gate: self
authority: build: launchd from the branch; no image staging; no guest runs; no push
updated: 2026-10-02T09:07Z
---
# op-425 — Implementer: launchd GetJob exports the requested job, not the caller (id-059)

## Outcome

Context: ordinary bug fixing in our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source launchd).

`sbin/launchd/ipc.c` (alpha2 `2884304b`) has two `LAUNCH_KEY_GETJOB` handlers. The one at line 441
exports the job it found, `job_export(j)`. The one at line 566 finds `j` but exports `ctx->j`, the
caller's own job (line 570), so `launchctl dump LABEL` reports the caller (found by gatekeeper1 in
op-422, `build/op422/findings.md`, item 3).

1. Check Apple's launchd sources for the intended behaviour, and say whether this line came from the
   donor or from rmxOS.
2. Fix it as one commit on a new branch `launchd-fixes-1` from `mach-fixes-1` (`903c8fc2`).
3. Add a regression test that asks for a named job and checks the returned `Label` is that job's, in
   the project's test style (Zig for the low level; see `tests/sys/mach` for the ATF wiring). Record
   its expected result before and after the fix.
4. Build launchd and the test. No image staging and no guest run in this op.

Evidence: the commit, the donor check, and the test with its expectations.

## Limits

- Only this handler. No push of `wip-rmxos`.

Re-read OPS.md first: defaults and the REPORT block.
