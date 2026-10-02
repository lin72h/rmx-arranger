---
id: op-414
state: draft
agent: implementer
repo: rmx-implementer
idq: id-057
needs: []
gate: self
authority: build a ZFS-root image from the op-364 staging tree with makefs -t zfs and mkimg, as a new file under /Users/me/wip-mach/stage/images/; no guest runs; no zpool import on the host; no push
updated: 2026-10-02T03:40Z
---
# op-414 — Implementer: build a ZFS-root rmxOS image with makefs -t zfs (pool rmxroot), alongside the UFS images

## Outcome

Context: ordinary OS engineering in our own open-source OS (rmxOS: FreeBSD 15 base with Apple's
open-source Mach and launchd).

ZFS root is an important rmxOS feature, so new rmxOS images move from UFS to ZFS (id-057). Build the
first one: the same contents as the op-364 image, with a ZFS root.

- Build from op-364's staging tree (`/Users/me/wip-mach/rmx-implementer/build/op364-20260928T001637Z/staging/`)
  with `makefs -t zfs`: pool `rmxroot` (never `zroot`, which is the host's pool), boot environment
  dataset `rmxroot/ROOT/default`, and `bootfs` set to it. Then `mkimg` with the ZFS boot code from the
  alpha2 build (`gptzfsboot`, and the EFI loader if the runner boots by UEFI). Never import the
  pool on the host.
- `loader.conf`: `kernel="RMXOS-RELEASE"` (a directory name; op-410 showed the `.../kernel` form
  falls back silently), `zfs_load="YES"`, `vfs.root.mountfrom="zfs:rmxroot/ROOT/default"`, and the
  same console and `mach_load` lines as op-364.
- Record a BOM like op-364's, plus `zdb -l` (or makefs output) showing the pool name, datasets and
  bootfs, read from the image file without importing it.
- Note which of the PID-1 contract's staging rules (op-380) name UFS devices or paths, and what the
  ZFS equivalent is; change nothing in those documents.

Evidence: the build commands and logs, the image hash, the BOM, and the pool listing (by path).
A boot check is the Gatekeeper's, in a later op.

## Limits

- Do not change or replace any existing image. Product source unchanged.

Re-read OPS.md first: defaults and the REPORT block.
