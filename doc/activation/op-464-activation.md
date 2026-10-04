---
id: op-464
state: draft
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-046
gate: self
authority: 4 boots max on copies of the r2 pair, 5 min each; doas vmm.ko, bhyve
expected: 90m
updated: 2026-10-04T01:32Z
---
# op-464 — Gatekeeper 1: proof of op-461 (Mach step 4 part 1 remediation)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

Prove the op-461 changes before and after, with the whole Mach suite
on the fixed image. Branch `mach-fixes-4` at `0924690c` (five commits
on `b1ef1670`, which your op-457 proved). Expected results:
`/Users/me/wip-mach/rmx-implementer/docs/op461-mach-remediation.md`.

Images (work on copies; the tests are byte-identical in both, and only
the kernel and `mach.ko` differ):
- base = `b1ef1670` + the tests:
  `/Users/me/wip-mach/stage/images/op461-base-tests-r2.raw`
  sha256 `0128ee8cde7dfd9ea297669f11a3990104c3a31688696dc4e0686ae046ffae81`
- fixed = `0924690c` + the tests:
  `/Users/me/wip-mach/stage/images/op461-fixed-tests-r2.raw`
  sha256 `02452dd37e4bce74540266f3cc2a44a0ccf8342f583f4c7d91d0a36535472e9d`

Use your op-457 harness, extended to the three new cases
(`mach_entry_knote_test:revoked_port`, `:revoked_set`,
`mach_identity_test:kernel_reply_audit`); check every command against
the image first.
1. Base: one boot with the three new cases, all expected to FAIL with
   their recorded reason.
2. Fixed: one boot with all 55 cases (the 52 from op-457 and the three
   new ones), all expected to PASS; none should hang.

Result: one table, expected against observed, with the serial line for
each case, each FAIL's printed reason, and every mismatch listed. The
Implementer's own self-check was fixed 55/55, base 3/3.

Evidence by path; hash only each boot's raw serial log. Commits on
origin.

## Limits

- No product edits. If one case cannot run, record it and finish the
  others.

Re-read OPS.md first: defaults and the reply block.
