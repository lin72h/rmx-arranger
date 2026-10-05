---
id: op-493
state: draft
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-046
authority: 4 boots max on copies of the op484 ZFS pair, 5 min each; doas vmm.ko, bhyve; push rmx-gatekeeper1 main
expected: 1h
updated: 2026-10-05T03:00Z
---
# op-493 — Gatekeeper 1: proof of op-484 (launchd consumer fixes, ZFS pair)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 1 hour.**

Prove op-484's launchd changes before and after, with the whole suite
on the fixed image. Branch `mach-fixes-5` at `10a3fd65` (10 commits on
`b2d5f5b7`, which your op-483 proved). These are the first test images
with a ZFS root (from `op417-alpha2-zfs-gpt.raw`); your harness so far
booted UFS test images, so check its boot and result-collection steps
against these first. Expected results:
`/Users/me/wip-mach/rmx-implementer/docs/op484-launchd.md`.

Images (work on copies; the test files are byte-identical in both,
and only `/sbin/launchd` and its debug file differ; check this from
the two BOMs):
- base = `b2d5f5b7` + the tests (test-only build hooks, commit
  `5565ec56`):
  `/Users/me/wip-mach/stage/images/op484-base-tests-r7.raw`
  sha256 `badd55a54a7731443df46c9fce1fb88759b3150c1d08faf34f1729ccb56e31dc`
  BOM `/Users/me/wip-mach/stage/artifacts/op484-base-tests-r7/bom.json`
- fixed = `10a3fd65` + the same tests:
  `/Users/me/wip-mach/stage/images/op484-fixed-tests-r7.raw`
  sha256 `15d1b56315754b395464025acddab61467ddab197f930402e5030016082aa036`
  BOM `/Users/me/wip-mach/stage/artifacts/op484-fixed-tests-r7/bom.json`

Use your op-483 harness, extended to the new cases in the launchd
test program (`demand_removed`, `close_unregistered`,
`late_dead_name`); check every command against the image first.
1. Base: one boot with `demand_removed` (expected FAIL with its
   recorded reason) and `late_dead_name` (expected PASS, a control).
   Do not run `close_unregistered` on base: on unfixed launchd it can
   write outside a table in PID 1 and spoil the rest of the boot.
2. Fixed: one boot with all 68 cases (your 65 from op-483 and the
   three new ones), all expected to PASS; none should hang.

Result: one table, expected against observed, with the serial line
for each case, each FAIL's printed reason, and every mismatch listed.
The Implementer's self-check was fixed 68/68, base as above.

Evidence by path; hash only each boot's raw serial log. Commits on
origin.

## Limits

- No product edits. If one case cannot run, record it and finish the
  others.

Re-read OPS.md first: defaults and the reply block.
