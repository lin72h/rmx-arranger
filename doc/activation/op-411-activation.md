---
id: op-411
state: hold
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-046
needs: op-410
gate: self
authority: guest boots: up to 6 on copies of op409-base-tests.raw and op409-fixed-tests.raw, 5-minute cap each; doas: load vmm.ko if absent, and the runner's bhyve calls; push rmx-gatekeeper1 main
updated: 2026-10-02T02:57Z
---
# op-411 — Gatekeeper 1: finish the op-395 test proof on op-409's images (null_fd, the base FAIL/PASS cases, the fixed suite)

## Outcome

Context: ordinary bug fixing in our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source Mach IPC). Some regression tests stop the kernel on the unfixed code; that is their
expected "before" result. Everything runs in disposable bhyve guests with no network.

Finish the before/after proof that op-408 began (rmx-gatekeeper1 `18f721d`). op-408's B01-B13
(13 expected base panics) stand. The fixture module now loads: op-409 rebuilt it with kernel
relocations (`wip-rmxos@acfc34cd`) and restaged both images. Only the fixture and the stage marker
changed; all 13 test programs are byte-identical to op-395's.

Images (work on copies):
- base + tests: `/Users/me/wip-mach/stage/images/op409-base-tests.raw` sha256 `41c81b17e2f8c176cc76d423aac9b4cf4d812286d19d2d9f094f3082611c38c3`
- fixed + tests: `/Users/me/wip-mach/stage/images/op409-fixed-tests.raw` sha256 `088c490a2d7412512fd3649d974678c4a87c6e7c5a76111e89596bbac18dfd5a`

Run, by direct ATF invocation as in op-408:
1. Base: `mach_proc_info_test:null_fd` alone (expected PANIC).
2. Base: every case expected to FAIL or PASS, in one boot.
3. Fixed: the whole suite (27 cases), in one boot.

Result: one table of all 27 cases on both images (op-408's B01-B13 plus this run), expected
against observed, with the serial line or ATF result file for each, and every mismatch listed.

Evidence by path; hash only each boot's raw serial log. Commits on origin.

## Limits

- No product edits. If one case cannot run, record it and finish the others.

Re-read OPS.md first: defaults and the REPORT block.
