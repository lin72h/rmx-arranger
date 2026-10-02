---
id: op-424
state: closed
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-046
needs: []
gate: self
authority: guest boots: up to 8 on copies of op420-final-base-tests.raw and op420-fixed-tests-reviewed.raw, 5-minute cap each; doas: load vmm.ko if absent, and the runner's bhyve calls; push rmx-gatekeeper1 main
updated: 2026-10-02T09:55Z
---
# op-424 — Gatekeeper 1: Mach batch-2 before/after proof on op-420's images, plus the full batch-1 suite on the fixed image

## Outcome

Context: ordinary bug fixing in our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source Mach IPC). Some regression tests stop the kernel on the unfixed code; that is their
expected "before" result. Everything runs in disposable bhyve guests with no network.

Prove Mach batch 2 (op-420, `wip-rmxos` branch `mach-fixes-2` at `ee883a74`) the way op-418 proved
batch 1. The new tests and their expected results are in
`/Users/me/wip-mach/rmx-implementer/docs/op420-mach-entry-handling.md` and `tests/sys/mach` on
`mach-fixes-2`.

Images (work on copies):
- base = batch-1 code + the new tests: `/Users/me/wip-mach/stage/images/op420-final-base-tests.raw` sha256 `010a1a393d6cc1fea8414fb0dad7fca8972b701d3c7cfcaca8b3f6689cf85a16`
- fixed = batch-2 code + the tests: `/Users/me/wip-mach/stage/images/op420-fixed-tests-reviewed.raw` sha256 `2541e8a4c99c7cd6da7791e69273d1057e961c333904627c24805f376436d36b`

Run, by direct ATF invocation:
1. Base: each new case expected to PANIC in its own boot; then one boot with the other new cases.
2. Fixed: one boot with every new case **and** the whole batch-1 suite (27 cases), so batch 2
   shows no regression.

Result: one table, expected against observed, with the serial line or ATF result file for each,
each FAIL's printed reason, and every mismatch listed.

Evidence by path; hash only each boot's raw serial log. Commits on origin.

## Limits

- No product edits. If one case cannot run, record it and finish the others.

Re-read OPS.md first: defaults and the REPORT block.
