---
id: op-434
state: returned
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-046
gate: self
authority: guest boots: up to 4 on copies of op430-base-tests.raw and op430-deliverable-fixed-tests.raw, 5-minute cap each; doas: load vmm.ko if absent, and the runner's bhyve calls; push rmx-gatekeeper1 main
updated: 2026-10-02T13:37Z
---
# op-434 — Gatekeeper 1: Mach batch-3 before/after proof on op-430's images, plus the batch-1 and batch-2 suites on the fixed image

## Outcome

Context: ordinary bug fixing in our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source Mach IPC). Everything runs in disposable bhyve guests with no network.

Prove Mach batch 3 (op-430, `wip-rmxos` branch `mach-fixes-3` at `db592723`) the way op-424 proved
batch 2. The new cases and their expected results are in `tests/sys/mach/EXPECTATIONS.md` § Batch 3
on `mach-fixes-3` and in `/Users/me/wip-mach/rmx-implementer/docs/op430-mach-lifetimes.md`.

Images (work on copies). The test files are byte-identical in both BOMs; only the kernel and `mach.ko` differ:
- base = batch-2 code + the tests: `/Users/me/wip-mach/stage/images/op430-base-tests.raw` sha256 `61b62ee1689a26493c87c9fcf0baa094700e369985eccf05877ec55b3926cce8`
- fixed = batch-3 code + the tests: `/Users/me/wip-mach/stage/images/op430-deliverable-fixed-tests.raw` sha256 `ac5ea35d9c08293806eb558f758bcf646a1f5e4ec03fcb29c83fc16d99ffbdcf`

Run, by direct ATF invocation (check each command against the image before booting):
1. Base: one boot with the 8 new cases (`mach_lifetime_test`: inherited_rights, shared_fd_exit,
   task_control_death, thread_control_death, rfork_unshare, rfork_clean_table, incarnation; and
   `mach_identity_test:live_credentials`). Each is expected to FAIL. If one stops the kernel
   instead, record it and run the rest in another boot.
2. Fixed: one boot with every case in `/usr/tests/sys/mach` (39: the 8 new plus the batch-1 and
   batch-2 suites), all expected to PASS, so batch 3 shows no regression.

Result: one table, expected against observed, with the serial line or ATF result file for each,
each FAIL's printed reason, and every mismatch listed.

Evidence by path; hash only each boot's raw serial log. Commits on origin.

## Limits

- No product edits. If one case cannot run, record it and finish the others.

Re-read OPS.md first: defaults and the REPORT block.
