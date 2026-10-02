---
id: op-429
state: draft
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-016
gate: both
authority: stage: overlays onto copies of the op-388 image with the verbatim dd78a31 helper copy in build/op391/helper-dd78a31; guest boots: up to 3 (at most two preflights, then one cell); doas: load vmm.ko if absent, and the runner's bhyve calls; push rmx-gatekeeper1 main
updated: 2026-10-02T11:44Z
---
# op-429 — Gatekeeper 1: PID-1 reaper cell, redo — op-422's three harness fixes, preflight with the full driver sequence, then one cell

## Outcome

Context: ordinary debugging of our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source launchd as PID 1). The test checks whether launchd records each child's exit status
correctly. Everything runs in disposable bhyve guests with no network.

Return the reaper verdict that op-422 (rmx-gatekeeper1 `2db74d1`, `build/op422/findings.md`) came
close to. Its probe preflight passed and its kernel-side records looked sound, but the cell was not
accepted, for three reasons. Fix all three before any boot:

1. **The driver transcript stopped after `OP422_CELL_DRIVER_STARTED`.** The driver does redirect
   to `/dev/console` (`cell-driver.sh:45`), so the cause is not established: the driver may have
   stopped or hung, or the console output may have been lost. Make the next run diagnosable: write
   every marker both to `/dev/console` and to a file inside the guest that you collect after
   power-off, and give each marker a sequence number. The preflight must run the driver's complete
   marker sequence, with no waves, and show every marker in both places.
2. **`pgrep -x launchd` excludes ancestors**, so it cannot find PID 1. Use `ps -p 1 -o comm=` (or
   `pgrep -a`), and check it on the host first.
3. **`launchctl dump LABEL` returns the caller's own job on this image.** That is a launchd bug
   (id-059), fixed on `launchd-fixes-1` but not present in op-388's alpha2 launchd. Read each managed
   job's `LastExitStatus` through `GetJobs` (`launchctl dump` with no label) and select the job by
   its exact label, as op-422 proposed. The preflight must show this selection on a managed test job.

The contract is unchanged: op-318, op-322, op-377 and op-380 at rmx-explorer1 `be1a3fb`, with the
kernel-side observation and its six added controls at `a04db00`. Classify with the passing classifier
(`build/op391/classify.exs`, sha256 `8bca5ac0a7f30c7677bd4a8c1bcfa726a20d006af61b51ca5ba111ccd18be293`).
If you change it, run the 22 Tier-2 controls again first.

Then one cell boot (30-minute cap) and the classification. Quote any panic message and its
backtrace. This is a pre-fix baseline on op-388 (no Mach batch fixes, no N1 timebase fix).

Evidence by path; hash only the overlay images and each boot's raw serial log. Commits on origin.

## Limits

- No product edits. A problem in your own harness is fixed on the host and the preflight rerun
  within the budget.

Re-read OPS.md first: defaults and the REPORT block.
