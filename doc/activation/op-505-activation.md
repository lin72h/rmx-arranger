---
id: op-505
state: issued
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-046
authority: 4 boots max on copies of the op500 and op502 ZFS pairs, 5 min each; doas vmm.ko, bhyve; push rmx-gatekeeper1 main
expected: 1h
issued-at: 2026-10-06T05:17Z
updated: 2026-10-06T05:17Z
---
# op-505 — Gatekeeper 1: proof of op-500 + op-502 (libxpc, two ZFS pairs)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 1 hour.**

Your op-498 proved launchd at `mach-fixes-5@0f1f76d5`. op-500 and
op-502 add libxpc fixes on top (`bd6bc1b8`, then `8cc4b37a`), with a
new test program in `tests/lib/libxpc`. Expected results:
`/Users/me/wip-mach/rmx-implementer/docs/op500-libxpc.md` and
`docs/op502-libxpc.md`.

Images (ZFS, work on copies; within each pair test files are
byte-identical and only libxpc's shared library, archive and debug
file differ; check from the BOMs):
- op500 base = `6a20061b` (`0f1f76d5` + op-500's tests):
  `/Users/me/wip-mach/stage/images/op500-base-tests-r2.raw`
  sha256 `d0dfd4f23046846a3b81e432a6e5bbfa7c531e1df2e45be13b5bf210bdb29ac0`
  BOM `/Users/me/wip-mach/stage/artifacts/op500-base-tests-r2/bom.json`
- op502 base = `0e946814` (`bd6bc1b8` + op-502's tests):
  `/Users/me/wip-mach/stage/images/op502-base-tests-r1.raw`
  sha256 `3627096b6a9a3338b7ec31b6e801842e08c4d9b425b92001e1b1da57b6e2ccad`
  BOM `/Users/me/wip-mach/stage/artifacts/op502-base-tests-r1/bom.json`
- op502 fixed = `8cc4b37a`:
  `/Users/me/wip-mach/stage/images/op502-fixed-tests-r1.raw`
  sha256 `1ef575172eec498bd6214cc95c40f0489cdb6238f4674557e264c4ce174fe987`
  BOM `/Users/me/wip-mach/stage/artifacts/op502-fixed-tests-r1/bom.json`

Use your op-498 harness, extended to the libxpc test program; check
every command against the image first.
1. op500 base: one boot with `stale_readiness`, `failed_receive`,
   `local_port_gone` (expected FAIL, with their recorded reasons) and
   `cancel_inflight` (expected PASS). Skip op-500's `remote_pending`:
   op-502 replaced its expectation.
2. op502 base: one boot with `named_pending`, `reconnect`,
   `lookup_failure` (expected FAIL) and `peer_pending` (expected PASS).
3. op502 fixed: one boot with all 77 cases (the 69 from op-498, the 8
   libxpc cases), all expected to PASS; none should hang.
One spare boot, only for a boot that fails before the tests run.

Result: one table, expected against observed, with the serial line
for each case, each FAIL's printed reason, and every mismatch listed.
The Implementer's self-checks matched these expectations.

Evidence by path; hash only each boot's raw serial log. Commits on
origin.

## Limits

- No product edits. If one case cannot run, record it and finish the
  others.

Re-read OPS.md first: defaults and the reply block.
