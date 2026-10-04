---
id: op-475
state: closed
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-046
needs: op-470
authority: 4 boots max on copies of the op468 pair, 5 min each; doas vmm.ko, bhyve; push rmx-gatekeeper1 main
expected: 1h
issued-at: 2026-10-04T10:25Z
updated: 2026-10-04T10:47Z
---
# op-475 — Gatekeeper 1: proof of op-468 (libdispatch adaptation)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 1 hour.**

Prove op-468's libdispatch changes before and after, with the whole
Mach suite on the fixed image. Branch `mach-fixes-5` at `015e7723`
(11 commits on `0924690c`, which your op-464 proved). Expected
results: `/Users/me/wip-mach/rmx-implementer/docs/op468-libdispatch.md`
(§ Final self-check, the per-case table) and the one-line
expectations in the images at `/usr/tests/lib/libdispatch/`.

Images (work on copies; the test program and its Kyuafile are
byte-identical in both, and only `libdispatch.so.5`, `libdispatch.a`
and its debug file differ; check this from the two BOMs):
- base = `0924690c` libdispatch + the tests:
  `/Users/me/wip-mach/stage/images/op468-base-tests.raw`
  sha256 `a455d2ac24c9a8504f5e62802e3df7f7200da0c33dbd667ab0b5120aa8fbe8d4`
  BOM `/Users/me/wip-mach/stage/artifacts/op468-base-tests-stage-r10/bom.json`
- fixed = `015e7723` libdispatch + the tests:
  `/Users/me/wip-mach/stage/images/op468-fixed-tests.raw`
  sha256 `d90981a41d4f8672f266ae9aa4c50b095eb46a1d6a7baef1c4a1a9fa125535f8`
  BOM `/Users/me/wip-mach/stage/artifacts/op468-fixed-tests-stage-r10/bom.json`

Use your op-464 harness, extended to the six new cases in
`/usr/tests/lib/libdispatch/dispatch_mach_test` (`channel_two`,
`set_large_retry`, `stale_readiness`, `cancel_copied`,
`send_death_registration`, `late_death`); check every command against
the image first.
1. Base: one boot with the six new cases. Expected: the first five
   FAIL with their recorded reason; `late_death` PASSES (a control
   that the kernel's lifetime handling already satisfies).
2. Fixed: one boot with all 61 cases (your 55 Mach cases from op-464
   and the six new ones), all expected to PASS; none should hang.

Result: one table, expected against observed, with the serial line
for each case, each FAIL's printed reason, and every mismatch listed.
The Implementer's own self-check was fixed 61/61, base as above.

Evidence by path; hash only each boot's raw serial log. Commits on
origin.

## Limits

- No product edits. If one case cannot run, record it and finish the
  others.

Re-read OPS.md first: defaults and the reply block.
