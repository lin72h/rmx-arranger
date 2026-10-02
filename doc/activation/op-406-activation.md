---
id: op-406
state: draft
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-046
gate: self
authority: guest boots: up to 20 on copies of the two op-395 images (one per case expected to stop the kernel on the base image, one for the rest, one for the fixed image), 5-minute cap each; doas: load vmm.ko if absent, and the runner's bhyve calls; push rmx-gatekeeper1 main
updated: 2026-10-02T00:35Z
---
# op-406 — Gatekeeper 1: run the Mach regression suite on op-395's two images — fails before, passes after

## Outcome

Context: ordinary bug fixing in our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source Mach IPC). Some regression tests stop the kernel on the unfixed code; that is their
expected "before" result. Everything runs in disposable bhyve guests with no network.

Prove op-395's regression tests: each one gives its expected result on the unfixed base image and
passes on the fixed image. The expected results are in `tests/sys/mach/EXPECTATIONS.md` on
`mach-fixes-1` (`wip-rmxos@5fa02fb5`), 27 cases in 13 ATF programs run by Kyua
(`/usr/tests/sys/mach`).

Images (work on copies; leave these files unchanged):
- base + tests: `/Users/me/wip-mach/stage/images/op395-base-tests-v4.raw` sha256 `d7cf45062ae8d0ed08b30e82315e2e93b5a0a827a810c5bd7f8c727ce2d27697`
- fixed + tests: `/Users/me/wip-mach/stage/images/op395-fixed-tests-v5.raw` sha256 `ca61f2fa046dee5d248a3415c0fdeb21ae79a94177412dd4fe6a09d415df271b`

Run plan, with your existing runner (exit status 1 means powered off):
- Base image: one boot per case expected to stop the kernel, running only that case
  (`kyua test mach/<program>:<case>`). Then one boot running every case expected to FAIL or PASS.
  A stopped kernel shows as a panic message on the serial console; record the message and the
  backtrace after it, then end the boot.
- Fixed image: one boot running the whole suite.

Result: one table with every case, its expected and observed result on each image, and the serial
line or Kyua report behind each observation. List every mismatch separately. A case that does not
fail on the base image does not prove its fix.

Evidence by path; hash only each boot's raw serial log. Commits on origin.

## Limits

- No product edits and no image changes beyond run copies. If the runner cannot start a boot,
  report and stop.

Re-read OPS.md first: defaults and the REPORT block.
