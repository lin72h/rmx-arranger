---
id: op-498
state: draft
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-046
authority: 3 boots max on copies of the op495 ZFS pair, 5 min each; doas vmm.ko, bhyve; push rmx-gatekeeper1 main
expected: 45m
updated: 2026-10-05T04:00Z
---
# op-498 — Gatekeeper 1: proof of op-495 (launchd job-port setup, ZFS pair)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 45 minutes.**

Your op-493 proved op-484 (`mach-fixes-5@10a3fd65`). op-495 adds two
launchd fixes on top (`0f1f76d5`, test commit `68e847c3`): a job's
port name is published only after its setup succeeds, and the drain
releases a partly received message. New case:
`launchd_consumer_test:setup_retry`. Expected results:
`/Users/me/wip-mach/rmx-implementer/docs/op495-launchd.md`.

Images (ZFS, work on copies; test files byte-identical, only
`/sbin/launchd` and its debug file differ; check from the BOMs):
- base = `68e847c3` (`10a3fd65` + the new test):
  `/Users/me/wip-mach/stage/images/op495-base-tests-r1.raw`
  sha256 `1ef992bec62b8f273074965b44c7c3fb28130538680da327e86a2e0c832ec2c0`
  BOM `/Users/me/wip-mach/stage/artifacts/op495-base-tests-r1/bom.json`
- fixed = `0f1f76d5`:
  `/Users/me/wip-mach/stage/images/op495-fixed-tests-r1.raw`
  sha256 `aca18a6b8b5511fd6ed693142ead67f54446ac7b22123b22604b9858bf7e7c57`
  BOM `/Users/me/wip-mach/stage/artifacts/op495-fixed-tests-r1/bom.json`

Use your op-493 harness, extended to `setup_retry`; check every
command against the image first.
1. Base: one boot with `setup_retry`, expected FAIL with its recorded
   reason.
2. Fixed: one boot with all 69 cases (your 68 from op-493 and
   `setup_retry`), all expected to PASS; none should hang.

Result: one table, expected against observed, with the serial line
for each case, the FAIL's printed reason, and every mismatch listed.
The Implementer's self-check was base 1/1 as expected, fixed 69/69.

Evidence by path; hash only each boot's raw serial log. Commits on
origin.

## Limits

- No product edits. If one case cannot run, record it and finish the
  others.

Re-read OPS.md first: defaults and the reply block.
