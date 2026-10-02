# id-057 — rmxOS images use UFS; ZFS root is an important rmxOS feature

- id: **id-057**
- state: **READY — op-414 drafted (held while the Implementer runs op-413)**
- raised: **2026-10-02 by the Coordinator**
- parent: id-042 (1.0-preview); related: id-016 (PID-1 image), id-047 (instrumented profiles)

## Problem

Every rmxOS test image is built as UFS (op-364: `makefs` + `mkimg`; the staging helper mounts UFS).
ZFS is an important rmxOS feature, so the images we test and ship should use a ZFS root.

## Facts (2026-10-02)

- The host's `makefs` supports `-t zfs` (`poolname`, `rootpath`, datasets), so a ZFS-root image can
  be built from a staging tree without root and without mounting anything.
- The host's own pool is `zroot`; guest pools must use another name (for example `rmxroot`) so a
  guest pool never collides with the host's.
- The op-364 image already carries `zfs.ko` and `opensolaris.ko` under `/boot/RMXOS-RELEASE/`; the
  ZFS boot code (`gptzfsboot` or the EFI loader) has to come from the build.

## Scope and rules

- New images use ZFS root from now on. Images pinned by finished or in-flight evidence (op-364,
  op-388, op-396, op-409, op-412, op-413) stay as they are; nothing is converted in place.
- Build from a staging tree with `makefs -t zfs`; never import a guest pool on the host.
- `loader.conf` names the kernel by directory (`kernel="RMXOS-RELEASE"`, as op-410 taught), loads
  `zfs`, and sets `vfs.root.mountfrom="zfs:<pool>/ROOT/default"`.
- The PID-1 contract's staging and BOM rules (op-318/op-322/op-380) still apply; where they name
  UFS paths or devices, the first ZFS image records the equivalent.

## Done when

A ZFS-root image built this way boots contained, `mach.ko` loads, and the op-372 slice passes;
later candidate and CI images use it.
