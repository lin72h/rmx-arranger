---
id: op-441
state: closed
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-046
gate: self
authority: guest boots: up to 4 on copies of op437-base-tests.raw and op437-fixed-tests.raw, 5-minute cap each; doas: load vmm.ko if absent, and the runner's bhyve calls; push rmx-gatekeeper1 main
updated: 2026-10-03T05:30Z
---
# op-441 — Gatekeeper 1: Mach batch-3 before/after proof, redo on op-437's images (41 cases)

## Outcome

Context: ordinary bug fixing in our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source Mach IPC). Everything runs in disposable bhyve guests with no network.

Redo your op-434 proof on the remediated batch 3 (`mach-fixes-3` at `cf398822`, op-437). Expected
results: `tests/sys/mach/EXPECTATIONS.md` on that branch and
`/Users/me/wip-mach/rmx-implementer/docs/op437-mach-lifetime-remediation.md` § "Commits and coverage".

Images (work on copies; the test files are byte-identical in both, and only the kernel and `mach.ko` differ):
- base = batch-2 code + the tests: `/Users/me/wip-mach/stage/images/op437-base-tests.raw` sha256 `e5887d54b99c590f1d82454933d4e0aec2112d8f2882e688a18a02b287385d5b`
- fixed = remediated batch 3 + the tests: `/Users/me/wip-mach/stage/images/op437-fixed-tests.raw` sha256 `69c5b8715627e230a02ad8e40170f219f27e45dfb80543e6b8635d07a6ff0212`

Run by direct ATF invocation, with the same harness as op-434 (check commands against the image first):
1. Base: one boot with the 10 batch-3 cases (the 8 from op-434 plus `failed_creation` and
   `parked_reply`). Expected as recorded: FAIL, except `failed_creation`, which passes on base with
   `constructed=0`. Every case must reach its named check; none should hang.
2. Fixed: one boot with all 41 cases, all expected to PASS. For `failed_creation`, also confirm
   `observed_constructed=1`.

Result: one table, expected against observed, with the serial line or ATF result file for each,
each FAIL's printed reason, and every mismatch listed.

Evidence by path; hash only each boot's raw serial log. Commits on origin.

## Limits

- No product edits. If one case cannot run, record it and finish the others.

Re-read OPS.md first: defaults and the REPORT block.
