---
id: op-422
state: draft
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-016
gate: both
authority: stage: overlays onto copies of the op-388 image with the verbatim dd78a31 helper copy in build/op391/helper-dd78a31; guest boots: up to 3 (at most two probe preflights, then one cell); doas: load vmm.ko if absent, and the runner's bhyve calls; push rmx-gatekeeper1 main
updated: 2026-10-02T07:00Z
---
# op-422 — Gatekeeper 1: PID-1 reaper cell under the kernel-side contract — fixed collector, probe preflight, then one cell (redo of op-405)

## Outcome

Context: ordinary debugging of our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source launchd as PID 1). The test checks whether launchd records each child's exit status
correctly. Everything runs in disposable bhyve guests with no network.

Finish what op-405 started (rmx-gatekeeper1 `664bff8`, `00bd1c8`) and return the reaper verdict.
op-405's classifier passed all 22 Tier-2 controls (`build/op405/tier2-r4/results.json`; classifier
sha256 recorded there), and the bhyve exit-status fix works. Its probe preflight boot stopped
because your own D collector did not compile: `kernel.d:6` passes the `uint64_t` `timestamp` to
`%lld`.

The contract is unchanged: op-318, op-322, op-377 and op-380 at rmx-explorer1 `be1a3fb`, with Tier U
replaced by the kernel-side observation and its six added controls (rmx-explorer1 `a04db00`,
`findings/nx-r64z/20261001-op401-tier-u-kernel-side.md`).

1. **Collector, host-only.** Fix the format arguments (explicit matching casts). Compile every D
   script with `dtrace -e -s` on the host before any boot, and run the classifier against the
   22 controls again if you change it. Classify the cell with the passing classifier's exact file.
2. **Probe preflight boot (no waves):** every probe the note needs enables and records data for
   PID 1 (`syscall::wait4` with `pid == 1`, `fbt::proc_reap`, `fbt::proc_reparent`, `proc:::create`
   and `exit`, calibrated `profile-997`), and the detached thread is identified by its
   `wait4(-1, NULL, WNOWAIT)` pattern. A failure in your own harness is fixed on the host and the
   preflight rerun within the budget; a probe that cannot work stops the op with the exact step.
3. **Cell boot:** one attempt with the waves, a 30-minute cap, then classification. Quote any
   panic message and its backtrace.

This is a pre-fix baseline on the alpha2 image (op-388). Mach batch 1's timebase fix (N1) is not in
it, so launchd's respawn timing is alpha2's.

Evidence by path; hash only the overlay images and each boot's raw serial log. Commits on origin.

## Limits

- No product edits. Earlier op-391 to op-405 evidence stays as recorded.

Re-read OPS.md first: defaults and the REPORT block.
