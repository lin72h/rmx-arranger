---
id: op-419
state: draft
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-057
gate: self
authority: guest boots: up to 2 on a copy of op417-alpha2-zfs-gpt.raw, 15-minute cap each; doas: load vmm.ko if absent, and the runner's bhyve calls; push rmx-gatekeeper1 main
updated: 2026-10-02T06:43Z
---
# op-419 — Gatekeeper 1: boot the first ZFS-root rmxOS image (op-417) and run the op-372 slice

## Outcome

Context: ordinary OS engineering in our own open-source OS (rmxOS: FreeBSD 15 base with Apple's
open-source Mach and launchd). Everything runs in a disposable bhyve guest with no network.

Boot the first ZFS-root rmxOS image and show it works as well as the UFS image did.

Image (work on a copy; never import its pool on the host, whose own pool is `zroot`):
`/Users/me/wip-mach/stage/images/op417-alpha2-zfs-gpt.raw` sha256
`1f4cf9497295c50c512755ce71db0b075a82c329c7f88d31553f86851295f5a7`. It has the op-364 contents on
pool `rmxroot`, root dataset `rmxroot/ROOT/default`, no boot code; your runner's `bhyveload` reads
ZFS through the host's `userboot.so`. Record the Implementer's build:
`/Users/me/wip-mach/rmx-implementer/build/op417/evidence/record.md`.

In the guest, record:
1. the root mount (`mount`, `zpool status`, `zfs list`) and the kernel identity (`kern.bootfile`,
   `kern.ident`);
2. **ownership and modes**, because the build evidence lists the staging copies as user-owned and
   only the manifest carries root ownership: `stat -f '%Su:%Sg %Sp %Sf'` on `/`, `/usr/bin/su`,
   `/etc/master.passwd`, `/sbin/launchd` and every file under `/etc/launchd.d` (expected
   `root:wheel`, `su` setuid with `schg`);
3. that `mach.ko` loads and launchd runs its jobs as on the UFS image;
4. your op-372 Mach and dispatch slice.

Evidence by path; hash only each boot's raw serial log. Commits on origin.

## Limits

- No product or image changes beyond the run copy. If the boot fails, record the loader and kernel
  output and stop.

Re-read OPS.md first: defaults and the REPORT block.
