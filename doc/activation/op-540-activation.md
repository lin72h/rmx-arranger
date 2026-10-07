---
id: op-540
state: closed
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-046
authority: 3 boots max on copies of the op516 ZFS pair, 5 min each; doas vmm.ko, bhyve; push rmx-gatekeeper1 main
expected: 1h
issued-at: 2026-10-07T09:41Z
updated: 2026-10-07T09:55Z
---
# op-540 — Gatekeeper 1: proof of op-516 (launchd's child-task setters, ZFS pair)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 1 hour.**

Your op-534 proved `mach-fixes-6@ea254222` (88 cases). op-516 makes
launchd's two task setters act on the child task that sent launchd its
own task port, instead of on launchd (`4de4d9ae`; test commits on
both branches). New test program `mach_child_setters_test`: `special`,
`exception`, `refused`, `stale_exit`, `stale_exec`. Three existing
cases were corrected: `mach_identity_test:kernel_reply_audit`,
`mach_entry_knote_test:revoked_port`, `:revoked_set`. Expected
results: `/Users/me/wip-mach/rmx-implementer/docs/op516-child-task-setters.md`.

Images (ZFS, work on copies; test files identical, only
`/boot/RMXOS-RELEASE/kernel` and `/boot/RMXOS-RELEASE/mach.ko` differ;
check from the BOMs):
- base = `mach-fixes-6-op516-base@9a46cdc2` (`ea254222` + the tests):
  `/Users/me/wip-mach/stage/images/op516-base-tests-r2.raw`
  sha256 `0aa978699b4d7482bece7c3ad12f0d70d0e0483f36b9e24912ed102fd114b730`
  BOM `/Users/me/wip-mach/stage/artifacts/op516-base-tests-r2/bom.json`
- fixed = `mach-fixes-6@4de4d9ae`:
  `/Users/me/wip-mach/stage/images/op516-fixed-tests-r2.raw`
  sha256 `e294310b4bf8c0726b0f0210d1a5dd98e59f4678534f7788cf716e8242f3b830`
  BOM `/Users/me/wip-mach/stage/artifacts/op516-fixed-tests-r2/bom.json`

Use your op-534 harness, extended to the new program; check every
command against the image first.
1. Base: one boot with the five new cases and the three corrected
   ones: `special`, `exception`, `refused` expected FAIL with their
   recorded reasons; `stale_exit`, `stale_exec`, `kernel_reply_audit`,
   `revoked_port`, `revoked_set` expected PASS (the base kernel already
   has those behaviours).
2. Fixed: one boot with all 93 cases, all expected to PASS.
id-061 handling: if a launchd consumer case fails with
`launchd control reply missing` (the guest may then not power off),
record it as id-061 with its serial line, use the spare boot for one
more fixed run, and report both runs. Any other mismatch counts.

Result: one table, expected against observed, with the serial line for
each case, each FAIL's printed reason, and every mismatch listed.

Evidence by path; hash only each boot's raw serial log. Commits on
origin.

## Limits

- No product edits. If one case cannot run, record it and finish the
  others.

Re-read OPS.md first: defaults and the reply block.
