---
id: op-438
state: closed
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-016
gate: self
authority: guest boots: up to 3 on copies of op388-alpha2-pid1-premise.raw, 5-minute cap each; doas: load vmm.ko if absent, and the runner's bhyve calls; push rmx-gatekeeper1 main
updated: 2026-10-03T00:23Z
---
# op-438 — Gatekeeper 1: launchd PID-1 boot acceptance checks, and a baseline run on op-388's image, ahead of op-436

## Outcome

Context: ordinary engineering on our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source Mach IPC and launchd). Everything runs in disposable bhyve guests with no network.

The Implementer is making launchd PID 1 the default boot (op-436). When it returns, you will
accept its two images (UFS and ZFS root). Build the acceptance checks now, and run them once on
today's PID-1 image to get a baseline.

Checks, each with a pass/fail result read from the guest, not inferred from configuration:
1. PID 1 is `/sbin/launchd`, started without `-u`.
2. `/etc/rc` ran exactly once: one `cron`, one system logger (whichever owns logging), one `devd`
   with no "Device busy", and no "route already in table".
3. Root is mounted read-write, and a file can be created and removed on `/`.
4. The serial console shows a `login:` prompt.
5. `launchctl list` shows `com.apple.notifyd` and the logger running.
6. Shutdown: `shutdown -p now` powers the guest off cleanly (runner status for power-off).
7. SIGUSR1: `kill -USR1 1` from root. Record what happens (halt, ignored or other). Run it last,
   in its own boot if it ends the guest.

Baseline: a copy of `/Users/me/wip-mach/stage/images/op388-alpha2-pid1-premise.raw`
(sha256 `031885595536603d0312bfd351d37847d6694ef592dc709a699fcfd112a8f1e5`). The expected failures come from
op-429's serial log: rc ran twice (two `cron`, two `syslogd` groups, `devd` "Device busy"), and
there was no login prompt. Root read-write and SIGUSR1 are unknown.

Keep the checks independent of op-388's details (job labels, exact rc messages), so they work
unchanged on op-436's images, including a ZFS root (`rmxroot/ROOT/default`).

Result: the check scripts committed; a one-page list of the checks and what each reads; the
baseline table (check, expected, observed, serial line).

Evidence by path; hash only each boot's raw serial log. Commits on origin.

## Limits

- No product or image edits. Overlays on copies only if a check needs a helper in the guest.

Re-read OPS.md first: defaults and the REPORT block.
