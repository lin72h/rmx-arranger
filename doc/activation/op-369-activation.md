---
id: op-369
state: draft
agent: validator2
repo: rmx-validator2
idq: id-042
gate: self
authority: none
updated: 2026-09-28T01:36Z
---
# op-369 — Validator 2: review op-364 (alpha2 profile commit, mach.ko rebuild, new image)

## Outcome

Review op-364, the Implementer's return on the alpha2 release critical path. You and
validator1 review it independently; it closes only if both of you reach 8 or more and agree.
Suggested distinguishing question: does anything besides `mach.ko` differ between the op-358 and
op-364 images, and was that `mach.ko` built from commit `2884304b` with the op-343 toolchain?
Name a better question if you find one. op-364 claims:

1. wip-rmxos commit `2884304b67fc454ee60187ce4731fca01cbefe6a` (branch `alpha2`, parent
   `15c185c038b9f5227c53e9019be8d35df328c314`) adds exactly five profile paths whose contents
   equal what the op-343 kernel was built from (op-340's three profile files, op-342's
   `sys/modules/dtrace/Makefile`) plus op-358's `release/rmxos/README.md`. The worktree
   `/Users/me/wip-mach/build/alpha2-stable15-sync-20260921` is clean.
2. `mach.ko` (sha256 `53e5a8cfc1b5e18801d62501312b3cc031e682cf7480b4aac16d0eb55ae2fcdb`) was
   built from that commit with op-343's clang/LLD 21.1.8 toolchain, and every undefined symbol
   in it (104 required, 8 weak) is defined in the op-343 kernel (sha256
   `b4608699ae1f93f1568053174b9c2197d497781f2653abba86eec34396a2ece8`).
3. The staged tree differs from op-358's final staging only in `boot/RMXOS-RELEASE/mach.ko`.
4. The image composed from it (UFS
   `ea7157ab25410510a9ee3f7d23e43d87423224bed9b3f847e3dcf3f600b5c384`, GPT
   `8f546a930859ce537d1cb8f462dbf391171fd02c2bd004d2d10b1c8b498c7140`) was built with makefs
   and mkimg returning 0, and the partition extracted from the GPT image is byte-for-byte the
   UFS.

Evidence: `/Users/me/wip-mach/rmx-implementer/build/op364-20260928T001637Z/` (`evidence/`,
`obj/`, `images/`, `inspect/`, `logs/`); op-358 is
`/Users/me/wip-mach/rmx-implementer/build/op358-alpha2-20260925T000042Z/`; the build-chain index
is `/Users/me/wip-mach/rmx-implementer/docs/alpha2-build-chain.md` (commit `39b2f89`). Whether the
module loads at boot is out of scope: that is the Gatekeeper's boot test.

## Limits

- Do not mount or boot the images; work from hashes, mtree files, manifests, and objects.
  Hashing each 8 GiB image takes about a minute.

Defaults and the REPORT block: OPS.md in your repo.
