---
id: op-407
state: issued
agent: validator2
repo: rmx-validator2
idq: id-046
gate: self
authority: none beyond the defaults: read-only; no guests
updated: 2026-10-02T01:00Z
---
# op-407 — Validator 2: review op-395 — 13 Mach fixes and their regression tests

## Outcome

Context: ordinary bug fixing in our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source Mach IPC). Review the code, not attack scenarios.

Review op-395 (Implementer). You are the only reviewer. It fixes 13 Mach defects on `mach-fixes-1`,
13 commits from `2884304b` to `wip-rmxos@5fa02fb5b0ebead338aa20e94e4dfe4bd586f5dd`, each with a
regression test under `tests/sys/mach` (expectations in `tests/sys/mach/EXPECTATIONS.md`). The
defects and the brief's 13 fix descriptions are in op-389
(`/Users/me/wip-mach/rmx-advisor2/op-389-mach-freebsd12-assumptions-alpha2.md`), op-392 and op-393
(`/Users/me/wip-mach/rmx-advisor1/op-392-mach-freebsd15-assumptions-findings.md`,
`op-393-mach-remaining-areas-findings.md`).

For each commit, check:
1. It fixes the defect it names, at the right place, without changing unrelated behaviour.
2. Its test would detect the defect: it exercises the defective path, and its expected result on
   alpha2 follows from the code.
3. It holds in the standalone `mach.ko` build, where `CAPABILITIES` and `INVARIANTS` are undefined
   (fix 10 in particular).
4. Lock, reference and lifetime rules around the changed lines still hold.

Gatekeeper op-406 checks runtime results separately; you need not run anything.

Distinguishing question: does any of the 13 commits leave its defect reachable, or introduce a new
one on the changed path?

Re-read OPS.md first: defaults and the REPORT block.
