---
id: op-511
state: issued
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-046
authority: 3 boots max on copies of the op507 ZFS pair, 5 min each; doas vmm.ko, bhyve; push rmx-gatekeeper1 main
expected: 45m
issued-at: 2026-10-07T00:00Z
updated: 2026-10-07T00:00Z
---
# op-511 — Gatekeeper 1: proof of op-507 (libxpc reconnect, ZFS pair)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 45 minutes.**

Your op-505 proved `mach-fixes-5@8cc4b37a` (77 cases). op-507 adds a
libxpc fix on top (`2de5f1d4`, test commit `004eb90b`) with four new
cases in `xpc_receive_test`: `suspended_barrier`, `handler_barrier`,
`target_barrier`, `process_watcher`. Expected results:
`/Users/me/wip-mach/rmx-implementer/docs/op507-libxpc.md`.

Images (ZFS, work on copies; test files byte-identical, only libxpc's
shared library, archive and debug file differ; check from the BOMs):
- base = `004eb90b` (`8cc4b37a` + the new tests):
  `/Users/me/wip-mach/stage/images/op507-base-tests-r1.raw`
  sha256 `1147204f8d54213a21f69d2ceebf9aca2775442b6e4dca4c8ae6d0a4759ee7da`
  BOM `/Users/me/wip-mach/stage/artifacts/op507-base-tests-r1/bom.json`
- fixed = `2de5f1d4`:
  `/Users/me/wip-mach/stage/images/op507-fixed-tests-r1.raw`
  sha256 `791ae666dbe60f1e7ba9f1bf1bccc95ef76fc05cd8f2f71988846338f9869986`
  BOM `/Users/me/wip-mach/stage/artifacts/op507-fixed-tests-r1/bom.json`

Use your op-505 harness, extended to the four new cases; check every
command against the image first.
1. Base: one boot with the four new cases, each expected to FAIL
   within its bound with its recorded reason; none should hang.
2. Fixed: one boot with all 81 cases (your 77 from op-505 and the
   four new ones), all expected to PASS; none should hang.
One spare boot, only for a boot that fails before the tests run.

Result: one table, expected against observed, with the serial line
for each case, each FAIL's printed reason, and every mismatch listed.
The Implementer's self-check was base 4/4 as expected, fixed 81/81.

Evidence by path; hash only each boot's raw serial log. Commits on
origin.

## Limits

- No product edits. If one case cannot run, record it and finish the
  others.

Re-read OPS.md first: defaults and the reply block.
