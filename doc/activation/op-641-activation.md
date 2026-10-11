---
id: op-641
state: hold
agent: explorer1
repo: rmx-explorer1
idq: id-064
authority: read-only source and image inspection; doas mdconfig -o readonly and mount -o ro of the two images below, detached afterwards; no guests; no push
expected: 2h
updated: 2026-10-11T09:46Z
---
# op-641 — Explorer 1: what the proven rmxOS VM image lacks to boot on a real UEFI machine (x86-64 Rocket Lake)

## Outcome

Context: ordinary engineering on our own open-source OS (rmxOS: FreeBSD
15 with Apple's open-source Mach, launchd and libdispatch). Today it
boots only in bhyve guests; the next goal is booting it on a real PC.

**Expected time: about 2 hours.**

The Coordinator wants the first rmxOS image that boots on their own
machine: x86-64 Intel Rocket Lake (11th generation desktop), UEFI,
booted from a USB stick. Our proven VM image is a FreeBSD 15 base image
plus an overlay disk that an install boot copies onto it: the kernel
`RMXOS-RELEASE` with its modules, `mach.ko`, the Mach libraries,
libdispatch, launchd, `asld`, `notifyd` and the tests. It has only run
under bhyve, with a serial console. The next op builds one
USB-bootable RELEASE image from it; this op says exactly what that
build must change.

Find, with file and line or image path for each item:
1. **Boot:** whether the base image has an EFI system partition and
   `loader.efi` (`gpart show`, the partition contents); how the
   overlay is applied today and how to apply it once on the host so
   the USB image boots directly into the result; the root pool or
   filesystem name and anything in `loader.conf`, `/etc/fstab` or the
   ZFS pool that assumes a bhyve disk (`vtbd`, device names).
2. **Console:** what `loader.conf` and `/boot.config` set for the
   console; what makes the EFI framebuffer (`vt`, `efifb`) the console
   with serial as a second, and whether `RMXOS-RELEASE` has `vt` and
   `vt_efifb`.
3. **Kernel and drivers:** whether `RMXOS-RELEASE`
   (`sys/amd64/conf/RMXOS-RELEASE` and what it includes, at
   `93b3735d` in `/Users/me/wip-mach/rmx-implementer/wip-rmxos`) has
   or ships as modules what a Rocket Lake desktop needs: `nvme`,
   `ahci`, `xhci` and USB mass storage, `igc` (Intel I225 2.5 GbE),
   `em`, `re` (Realtek), `acpi`, `hwpstate_intel`, `coretemp`; and
   anything only a guest needs that would get in the way.
4. **Start-up:** anything in `rc.conf`, launchd jobs or the rmxOS
   start scripts that waits on or expects a VM (serial-only `getty`,
   the test runner, auto power-off after tests, `virtio` devices).
5. **Mach and launchd on hardware:** any boot-time setting the VM
   runs pass from outside (for example `kern.racct.enable=1` through
   bhyveload) that the USB image must set itself.

Write `findings/op-641-real-machine.md`: a table per area (item, what
the VM image has, what a real UEFI machine needs, the exact change,
confidence), then a short ordered list of changes for the build op,
and what you could not determine without the hardware. Commit; no push.

## Inputs

- Base image, read-only:
  `/Users/me/wip-mach/rmx-implementer/build/op552/images/op552-overlay-base-r3.raw`
  sha256 `6f3b6e54606cecfbe3572cf5e2dee156c42499d113909351b811c41abe974059`.
- RELEASE overlay, read-only:
  `/Users/me/wip-mach/rmx-implementer/build/ci/93b3735d1d8bef1f15e013599d0a56bab3968b61/overlays/rmxos-release-op633-r2/`
  (`overlay.ufs` sha256 `81b08b76f594431e7d83db97f9c353cfe3d603efcbb0e51599368c4e03f9b183`,
  with `manifest.tsv` and `overlay.json` beside it).
- How the overlay route works: `/Users/me/wip-mach/rmx-implementer/docs/overlay-disks.md`.
- rmxOS source: `/Users/me/wip-mach/rmx-implementer/wip-rmxos` at
  `93b3735d1d8bef1f15e013599d0a56bab3968b61` (read with `git show`,
  `git grep`, `git log` only; another branch is checked out).

## Limits

- Attach images only read-only and detach them when done; never write
  to them. No guests.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
