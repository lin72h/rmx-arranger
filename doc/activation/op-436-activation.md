---
id: op-436
state: returned
agent: implementer
repo: rmx-implementer
idq: id-016
gate: self
authority: build: userland and kernel from the new branch; stage two images with rmx-stage-image (UFS and ZFS-root); no guest runs; no push
updated: 2026-10-03T01:33Z
---
# op-436 — Implementer: launchd as PID 1 by default — rc once, root read-write, console login, SIGUSR1 safety; two staged images (supersedes op-202)

## Outcome

Context: ordinary engineering on our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source Mach IPC and launchd).

Make launchd PID 1 the system's **default** boot, from the source tree: a normal build and install
gives a system where the loader starts `/sbin/launchd` (not `-u`), `/etc/rc` runs exactly once,
root is read-write, base services run once each, and the console offers a login. Today this exists
only as op-388's staged overlay (`loader.conf` `init_path` plus `/etc/launchd.d/com.rmxos.rc-chainload.plist`).
This op replaces the June op-202 brief and keeps its scope.

Work on a new branch `pid1-boot-1` in `wip-rmxos` from `launchd-fixes-1` (`42bf6205`, which has
Mach batch 1 and the GetJob fix). Changes to launchd, launchctl, rc scripts, `/etc` defaults and
loader defaults are in scope; kernel changes are not.

What we already know, from op-429's PID-1 cell on op-388's image
(`/Users/me/wip-mach/rmx-gatekeeper1/build/op429/runtime/rmx-op429-cell-20261002T120329Z-76994/serial.raw`):
1. **`/etc/rc` runs twice.** `launchctl bootstrap -S System` already runs it, through `runcom()`
   (`bin/launchctl/launchctl.c:699-753`), and the rc-chainload plist runs it again. One `ps`
   listing (serial lines about 890-904) shows two `cron` (974, 1816) and two FreeBSD `syslogd`
   groups; the second run's `devd` fails with "Device busy", and its routes report "already in table". Pick
   one path. Prefer the `launchctl bootstrap` path, which is how launchd ran rc on macOS, and
   drop the extra plist unless you show it is needed.
2. `sh: /etc/bootstrap: not found` (`launchctl.c:759-765` calls it unconditionally): ship the file
   or stop calling it.
3. FreeBSD's `syslogd` (from rc) and `asld` (launchd's `com.apple.syslogd`) both run. Decide
   which owns logging under PID-1 launchd and disable the other by default, with the reason.
4. No `getty` or console login runs.
5. **Root read-write** was not shown in op-429; in op-201 root stayed read-only
   (`launchctl: unlink(): Read-only file system`). Find from source whether rc's root remount
   runs under launchd's environment (runcom sets `FsckSlash` and others), and fix it.
6. **SIGUSR1 to PID 1 halts the system** (op-322 §4): `sighandler_init_compat`
   (`sbin/launchd/runtime.c:277-280`) maps it to `RB_HALT`, while launchd's calendar check
   raises SIGUSR1 at itself (`core.c:4348-4349`, `5883-5884`). Keep FreeBSD's shutdown tools
   working (check what `shutdown`, `halt`, `reboot` and `poweroff` send to PID 1), and make sure launchd never raises a halt at
   itself. Record what an external SIGUSR1 does afterwards.

Also: keep FreeBSD init reachable for recovery (for example as a later entry in `init_path`), and
make the configuration work for both a UFS and a ZFS root.

Images: stage two with `rmx-stage-image`, each with the branch's userland, configuration, kernel and
`mach.ko`:
- UFS, on the op-364 image (`/Users/me/wip-mach/rmx-implementer/build/op364-20260928T001637Z/images/op364-alpha2-gpt.raw`,
  sha256 `8f546a930859ce537d1cb8f462dbf391171fd02c2bd004d2d10b1c8b498c7140`), as op-388 did;
- ZFS root, on op-417's image (`/Users/me/wip-mach/stage/images/op417-alpha2-zfs-gpt.raw`,
  sha256 `1f4cf9497295c50c512755ce71db0b075a82c329c7f88d31553f86851295f5a7`).

Evidence: the commits; a short note giving, for each of points 1-6, the cause, the change and what
a guest boot must show (the Gatekeeper's acceptance list); both image hashes and BOMs (by path).

## Limits

- No kernel changes and no guest runs; runtime acceptance is a separate Gatekeeper op.
- No push of `wip-rmxos`.

Re-read OPS.md first: defaults and the REPORT block.
