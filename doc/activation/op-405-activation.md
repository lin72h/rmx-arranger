---
id: op-405
state: closed
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-016
gate: both
authority: stage: overlays onto copies of the op-388 image with the verbatim dd78a31 helper copy in build/op391/helper-dd78a31; guest boots: 2 (one probe preflight, one cell); doas: load vmm.ko if absent, and the runner's bhyve calls; push rmx-gatekeeper1 main
updated: 2026-10-02T07:00Z
---
# op-405 — Gatekeeper 1: PID-1 reaper cell under the kernel-side contract — probe preflight boot, then one cell

## Outcome

Context: ordinary debugging of our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source launchd as PID 1). The test checks whether launchd records each child's exit status
correctly. Everything runs in disposable bhyve guests with no network.

Run the PID-1 reaper cell under the amended contract and return one verdict, as op-399 set out.
Tier U is now the kernel-side observation in rmx-explorer1 `a04db00`,
`findings/nx-r64z/20261001-op401-tier-u-kernel-side.md`, including its op-404 addendum. Everything
else in the contract is unchanged (op-318, op-322, op-377 and op-380 at `be1a3fb`).

1. **Classifier, host-only.** Update `build/op391/classify.exs` to the amended records, and run
   Tier 2: op-322's eight controls as updated by the note, plus the note's six addendum controls.
   Record the classifier hash that passes, and classify the cell with that file.
2. **Probe preflight boot (feasibility, no waves).** On a copy of the op-388 image, check that
   every probe the note needs can be enabled and records data for PID 1:
   - `syscall::wait4:entry` and `:return` with `pid == 1`;
   - `fbt::proc_reap:entry` and `fbt::proc_reparent:entry/return`;
   - `proc:::create` and `proc:::exit`;
   - `profile-997`, calibrated against an ordinary busy child and an ordinary sleeping child.

   Also identify the detached thread by its `wait4(-1, NULL, WNOWAIT)` pattern. If any of this
   fails, stop and report the exact failing step; do not use the cell boot.
3. **Cell boot.** One attempt on the overlay, with the waves as before, a 30-minute cap, then
   classification. Quote any panic message and its backtrace.

Fix the runner's reading of bhyve's exit status first: per bhyve(8), 1 means powered off, which is
the expected end of a run.

Evidence (by path; hash only the overlay images and each boot's raw serial log): the Tier-2 results
with the classifier hash, the preflight results, the cell's records and the classifier output.
Commits on origin.

## Limits

- No product edits. If the preflight shows a probe cannot work, report the smallest alternative
  and stop.

Re-read OPS.md first: defaults and the REPORT block.
