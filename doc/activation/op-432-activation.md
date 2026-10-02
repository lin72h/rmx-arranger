---
id: op-432
state: issued
agent: validator2
repo: rmx-validator2
idq: id-016
gate: self
authority: none beyond the defaults: read-only; no guests
updated: 2026-10-02T12:27Z
---
# op-432 — Validator 2: review op-429 — PID-1 reaper verdict PREMISE-NOT-OBSERVED

## Outcome

Context: ordinary debugging of our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source launchd as PID 1). The test checks whether launchd records each child's exit status
correctly, inside a disposable VM with no network.

Review op-429 (gatekeeper1, `rmx-gatekeeper1@b54600027e80e0750f34c8c581e58c5eb0060629`). You are one
of two reviewers; do not read the other's notes before your REPORT. Your lens: falsification: where the evidence could support a wrong verdict.

op-429 reports **PREMISE-NOT-OBSERVED** for launchd's detached reaper on the alpha2 PID-1 image:
failure modes (a), (b) and (c) are all NOT-OBSERVED across 50 child exits (W1-W5). Findings:
`/Users/me/wip-mach/rmx-gatekeeper1/build/op429/findings.md`. Cell serial log:
`build/op429/runtime/rmx-op429-cell-20261002T120329Z-76994/serial.raw` sha256
`b1882605e6bd20381ea4f11778f51bc5110a570614bcb8872efba37dcf31cbf8`.

The contract: op-318, op-322, op-377 and op-380 at rmx-explorer1 `be1a3fb`, with Tier U replaced by
the kernel-side observation and its six added controls at `a04db00`
(`findings/nx-r64z/20261001-op401-tier-u-kernel-side.md`).

Claims to check:
1. **Verdict grammar:** each NOT-OBSERVED axis meets the contract's NOT-OBSERVED rule, with
   complete records: thread mapping (detached thread `100067`, main thread `100002`), kernel
   statuses, managed statuses, adoption of W4 and W5, and profile coverage of every window,
   including idle recovery.
2. **The classifier change:** `classify-indexed.exs` (sha256 `78899afa…`) reproduces the original
   (`build/op391/classify.exs`, `8bca5ac0…`) on all 22 Tier-2 controls (`build/op429/tier2-indexed/results.json`),
   ran on them before the cell, and its predicates are the original's.
3. **Harness fixes:** the transcript is complete (1,105 markers in serial and guest file); PID 1
   is checked by `ps -p 1`; managed statuses come from GetJobs with exact label selection, which
   avoids the id-059 bug.
4. **Workload validity:** identity, the BOM and the op-388 image hash hold, and the waves ran as
   the contract requires.

Distinguishing question: could any failure mode have occurred in this cell without the evidence
showing it?

Re-read OPS.md first: defaults and the REPORT block.
