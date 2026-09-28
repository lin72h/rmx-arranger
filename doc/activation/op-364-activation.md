---
id: op-364
state: closed
agent: implementer
repo: rmx-implementer (and nested wip-rmxos, branch alpha2)
idq: id-042
gate: both
authority: build mach.ko only; stage and compose a new image (makefs, mkimg)
updated: 2026-09-28T03:18Z
---
# op-364 — Implementer: rebuild mach.ko with the kernel toolchain and compose a new boot image

## Outcome

A boot candidate for alpha2 whose source is one commit and whose `mach.ko` is built with the
kernel's own toolchain:

1. **Profile commit.** In the alpha2 worktree `/Users/me/wip-mach/build/alpha2-stable15-sync-20260921`,
   the five uncommitted paths (`sys/modules/dtrace/Makefile`, `release/rmxos/README.md`,
   `release/rmxos/rmxos-make.conf`, `release/rmxos/rmxos-src.conf`,
   `sys/amd64/conf/RMXOS-RELEASE`) are one commit on `alpha2` on top of `15c185c`, with no other
   change, and the worktree is clean afterwards. Report the commit, its tree, and each path's
   SHA-256, showing they equal what op-343 built from (op-340's three profile files, op-342's
   Makefile) plus op-358's README.
2. **Module rebuild.** `mach.ko` is rebuilt from that commit in a new directory
   `build/op364-<UTC>/` with the op-343 kernel's toolchain, clang/LLD 21.1.8, and its `.comment`
   shows that version. For reference: op-343's module log compiled with the host `cc` (clang
   19.1.7), and the op-343 objdir's `tmp/usr/bin/cc` is clang 21.1.8.
3. **Static check.** Every undefined symbol in the new `mach.ko` resolves in the op-343 kernel's
   symbol table, by the same check op-358 recorded.
4. **New image.** Make a fresh copy of op-358's final staging tree and replace only
   `boot/RMXOS-RELEASE/mach.ko`, so the staging delta against op-358 is exactly that file.
   Compose an 8 GiB UFS and raw GPT image as op-358 did: makefs and mkimg return 0, and the
   partition extracted from the image is byte-for-byte equal to the UFS. Record every hash.
5. **Index.** `docs/alpha2-build-chain.md` gains an op-364 row and names the op-364 image as the
   current deliverable. Its op-358 row also notes that op-358 rewrote `release/rmxos/README.md` in
   the candidate. Committed in this repo.

## Limits

- Do not rebuild world or kernel; the op-343 kernel stays as built.
- Do not modify the op-343 or op-358 directories or any existing image.
- No mount, no guest run, no push.

Defaults and the REPORT block: OPS.md in your repo.
