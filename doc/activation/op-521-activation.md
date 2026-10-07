---
id: op-521
state: closed
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-046
authority: 3 boots max on copies of the op515 base and op518 fixed ZFS images, 5 min each; doas vmm.ko, bhyve; push rmx-gatekeeper1 main
expected: 1h
issued-at: 2026-10-07T01:43Z
updated: 2026-10-07T01:44Z
---
# op-521 — Gatekeeper 1: proof of op-515 + op-518 (readiness-only Mach kevents, ZFS pair)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 1 hour.**

Your op-511 proved `mach-fixes-5@2de5f1d4` (81 cases). op-515 and
op-518 change the Mach port-set kevent so it only reports readiness
(new branch `mach-fixes-6`, fixed at `0facf74b`), with a new test
program `mach_readiness_test` (`scans`, `native_modes`, `members`,
`attach_enqueue`, `buffers`, `silent_close`) and a revised
`mach_short_kevent_test:short_buffer`. Expected results:
`/Users/me/wip-mach/rmx-implementer/docs/op515-mach-readiness.md`.

Images (ZFS, work on copies; test files byte-identical; only
`/boot/RMXOS-RELEASE/kernel` (rebuilt at the new commit; no Mach code
is built into it) and `/boot/RMXOS-RELEASE/mach.ko` differ; check from
the BOMs):
- base = `2a58d7af` (`2de5f1d4` + the tests):
  `/Users/me/wip-mach/stage/images/op515-base-tests-r1.raw`
  sha256 `4db06b97db2f94840aebe08d43c93786711c79e4cfbc7e78ee0576677525a79e`
  BOM `/Users/me/wip-mach/stage/artifacts/op515-base-tests-r1/bom.json`
- fixed = `0facf74b`:
  `/Users/me/wip-mach/stage/images/op518-fixed-tests-r1.raw`
  sha256 `6995001c550edf8be595de7b60b5ed5ee58444a4260c0ed075e6de2839ca3ba0`
  BOM `/Users/me/wip-mach/stage/artifacts/op518-fixed-tests-r1/bom.json`
(op-515's own fixed image stops during boot and is not part of this
proof.)

Use your op-511 harness, extended to the new cases; check every
command against the image first.
1. Base: one boot with the six `mach_readiness_test` cases and
   `short_buffer`: `native_modes`, `members`, `attach_enqueue`,
   `buffers`, `short_buffer` expected FAIL with their recorded
   reasons; `scans` and `silent_close` expected PASS.
2. Fixed: one boot with all 87 cases, all expected to PASS; none
   should hang. The serial log should show "Mach pset notification
   worker started" once.
One spare boot, only for a boot that fails before the tests run.

Result: one table, expected against observed, with the serial line
for each case, each FAIL's printed reason, and every mismatch listed.
The Implementer's self-check matched these expectations.

Evidence by path; hash only each boot's raw serial log. Commits on
origin.

## Limits

- No product edits. If one case cannot run, record it and finish the
  others.

Re-read OPS.md first: defaults and the reply block.
