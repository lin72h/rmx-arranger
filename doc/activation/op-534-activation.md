---
id: op-534
state: hold
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-046
needs: op-532
authority: 3 boots max on copies of the op532 ZFS pair, 5 min each; doas vmm.ko, bhyve; push rmx-gatekeeper1 main
expected: 1h
updated: 2026-10-07T05:11Z
---
# op-534 — Gatekeeper 1: proof of mach-fixes-6@ea254222 (readiness-only Mach kevents, clean ZFS pair)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 1 hour.**

Your op-521 ran op-515/op-518's pair. Since then: a fix for a recovered
receive right losing readiness (`ab26bbed`) and its test
(`mach_recovered_readiness_test:recovered_receive`), and op-521's
three `launchd control reply missing` failures turned out to predate
`mach-fixes-6`: they reproduce on the `2de5f1d4` kernel you proved in
op-511 (`/Users/me/wip-mach/rmx-implementer/docs/op529-launchd-reply.md`).
That problem is id-061.

Images: the op-532 pair, base = `mach-fixes-6-op532-base`, fixed =
`mach-fixes-6@ea254222`; paths, hashes and BOMs in
`/Users/me/wip-mach/rmx-implementer/docs/op532-clean-pair.md` (ZFS,
work on copies; test files identical, only the kernel and `mach.ko`
differ; check from the BOMs).

Use your op-521 harness, extended to the new case; check every command
against the image first.
1. Base: one boot with the seven op-521 base cases and
   `recovered_receive`: `native_modes`, `members`, `attach_enqueue`,
   `buffers`, `short_buffer`, `recovered_receive` expected FAIL with
   their recorded reasons; `scans`, `silent_close` expected PASS.
2. Fixed: one boot with all 88 cases, all expected to PASS.
id-061 handling: if a launchd consumer case fails with
`launchd control reply missing` (the guest may then not power off),
record it as id-061 with its serial line, use the spare boot for
one more fixed run, and report both runs. Any other mismatch counts.

Result: one table, expected against observed, with the serial line for
each case, each FAIL's printed reason, and every mismatch listed.

Evidence by path; hash only each boot's raw serial log. Commits on
origin.

## Limits

- No product edits. If one case cannot run, record it and finish the
  others.

Re-read OPS.md first: defaults and the reply block.
