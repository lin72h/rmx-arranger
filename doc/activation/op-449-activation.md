---
id: op-449
state: hold
agent: implementer
repo: rmx-implementer
idq: id-016
gate: self
authority: build: launchd and the PID-1 ZFS image (reuse op-436's world; rebuild only sbin/launchd); stage one ZFS image with rmx-stage-image; self-check guests per OPS.md; no push
updated: 2026-10-03T07:12Z
---
# op-449 — Implementer: launchd PID 1 keeps every log message in memory when asld is not running — cap the queue and log to syslog

## Outcome

Context: ordinary debugging of our own open-source OS (rmxOS: FreeBSD 15 with Apple's open-source
Mach IPC and launchd). Everything runs on the host or in a disposable bhyve VM with no network.

**Expected time: about 1.5-2 hours** (fix and rebuild of `sbin/launchd` about 30 min; staging one
ZFS image about 20 min; self-check boots about 40 min; write-up about 15 min).

gatekeeper1's op-445 soak (`rmx-gatekeeper1@c1a55c5`, `build/op445/tables/health.md`) on your
op-436 ZFS image: launchd as PID 1 grew steadily, from 4,436 to 6,580 KiB RSS in an hour of job
churn, and kept the growth after the load stopped.

Cause, from source at `pid1-boot-1@969f2151` (Arranger; confirm or correct):
- `_launchd_syslog` appends every message at `LOG_NOTICE` or above to `_launchd_logq`
  (`sbin/launchd/log.c:237-238`, `_logmsg_add` at `:73-105`). The queue has no limit.
- As PID 1, `launchd_log_push` does not forward the queue; it waits for a drain request
  (`log.c:306-329`). The only drainer is Apple's syslogd, `usr.sbin/asl/syslogd.c`, through
  `_vprocmgr_log_drain`.
- op-436 made FreeBSD's `syslogd` the default logger and installed `com.apple.syslogd` (asld) as
  `Disabled`, so nothing drains the queue.

Fix on `pid1-boot-1`, test first:
1. Bound the queue (for example, keep the newest 1,000 messages or 256 KiB, whichever is smaller, and
   count what was dropped), so memory stays bounded in every configuration.
2. When no drainer is present (asld not running), send launchd's messages to the system log with
   `syslog(3)` instead of queueing them, so they reach `/var/log/messages`. Keep the drain path
   unchanged when asld does run.
A host-side test of the queue bound if practical; otherwise say how it is covered.

**Self-check before returning:** on the old image (`op436-boot-zfs.raw`) and the new one, run
15 minutes of op-445's job churn (gatekeeper1's `build/op445/` scripts show it) and sample PID 1's
RSS every 30 seconds. Expected: steady growth on the old image; flat (bounded) on the new one;
launchd messages in `/var/log/messages` on the new one. Then a normal `shutdown -p now`.

Evidence: the commits; a short note with cause, fix and both RSS tables; the image hash and BOM.

## Limits

- launchd only; no kernel or rc changes. No push.

Re-read OPS.md first: defaults and the REPORT block.
