---
id: op-470
state: issued
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-016
authority: guest boots: up to 2 on copies of op449-boot-zfs-r4.raw, a 75-minute cap each; doas: load vmm.ko if absent, and the runner's bhyve calls; push rmx-gatekeeper1 main
expected: 2h
issued-at: 2026-10-04T05:51Z
updated: 2026-10-04T05:51Z
---
# op-470 — Gatekeeper 1: op-445 soak re-run on op-449's bounded-logger ZFS image

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 2 hours** (setup 20 min; one soak boot of
about 60 min; tables and record 30 min).

Your op-445 soak (`rmx-gatekeeper1@c1a55c5`,
`build/op445/tables/health.md`) found launchd as PID 1 growing from
4,436 to 6,580 KiB RSS in an hour of job churn. The cause was
launchd's in-memory log queue, which nothing drained while asld is
disabled (`sbin/launchd/log.c`). The Implementer's op-449 bounded
that queue and sends launchd's messages to FreeBSD's `syslogd` via
`syslog(3)` when asld is not running (`pid1-boot-1@21c11e10`, 7
commits on `969f2151`, `sbin/launchd` only). Its 15-minute self-check
showed PID-1 RSS flat at 4,480 KiB. This op is the independent proof.

Image (work on copies):
`/Users/me/wip-mach/stage/images/op449-boot-zfs-r4.raw`
sha256 `a97eab483cb362939c0a1796bd170cfd9055cabd96ca44ca1941e55e647bc451`
BOM `/Users/me/wip-mach/stage/artifacts/op449-boot-zfs-r4/bom.json`.
Against op-436's ZFS image only `/sbin/launchd` and its debug file
differ (check this from the two BOMs).

One soak boot of about 60 minutes with op-445's loads 1-3, unchanged
(orphan reaping, job churn including the `KeepAlive` job, PID-1
health), reusing your `build/op445/` scripts and overlay method.
Skip load 4 (calendar); it is unaffected.
Expected:
- PID-1 RSS stays bounded through the load and does not keep its
  growth after the load stops (compare with op-445's table).
- Loads 1-3 healthy as in op-445; notifyd, syslogd and the console
  getty stay up.
- launchd's job messages (the churn and `KeepAlive` labels) appear in
  `/var/log/messages`.
Also record, with no pass bar: whether launchd's messages from early
boot, before `syslogd` starts, reach `/var/log/messages` or the
console, or neither.
At the end: `shutdown -p now` powers off cleanly.

Result: the PID-1 RSS and thread table over time beside op-445's, a
verdict for each of loads 1-3, the `/var/log/messages` lines that
show launchd's messages (a few, by path and line), and the early-boot
observation. Use the second boot only to repeat a failure or to
finish after a harness fault.

Evidence by path; hash only each boot's raw serial log. Commits on
origin.

## Limits

- No product or image edits; overlays on copies only for load and
  check helpers.
- If one load cannot run, record it and run the others.

Re-read OPS.md first: defaults and the reply block.
