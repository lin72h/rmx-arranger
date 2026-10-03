---
id: op-445
state: draft
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-016
gate: self
authority: guest boots: up to 3 on copies of op436-boot-zfs.raw, a 75-minute cap each; doas: load vmm.ko if absent, and the runner's bhyve calls; push rmx-gatekeeper1 main
updated: 2026-10-03T04:53Z
---
# op-445 — Gatekeeper 1: launchd PID-1 robustness soak on op-436's ZFS image — orphan reaping, job churn, PID-1 health, calendar without wake-ups (supersedes op-203)

## Outcome

Context: ordinary engineering on our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source Mach IPC and launchd). Everything runs in disposable bhyve guests with no network.

launchd is now PID 1 by default, accepted on ZFS by your op-439. Find out whether it stays
healthy as init over a sustained run. This replaces the June op-203 brief and keeps its scope;
shutdown and the init signals were already accepted in op-439, so here they only need to work at the
end of a long run.

Image (work on copies): `/Users/me/wip-mach/stage/images/op436-boot-zfs.raw`
sha256 `caddd3b35664ed553ee60de0865975953141213cc041d6897e3d2f711eaceb81` (it includes `dtraceall.ko`).
Reuse your op-439 overlay method and checks, and your op-429 kernel-side observation (PID 1
cannot be traced from user space; observe it through `proc`, `syscall::wait4` and `fbt` probes).

One soak boot of about 60 minutes, with these loads running together:
1. **Orphan reaping:** a steady churn of short-lived processes that become children of PID 1
   (double fork, parent exits); about 10 per second. Expect: every orphan reaped. Sample the
   zombie count every 30 seconds; it stays bounded and returns to its baseline when the churn stops.
2. **Job churn:** repeatedly load, start, stop and unload a few launchd jobs, including one with
   `KeepAlive` that exits and is restarted. Expect: no errors, no leftover jobs, restarts honour the
   throttle.
3. **PID-1 health:** PID 1 receives no fatal signal and its process does not change. Sample its
   RSS and thread count every 30 seconds; growth stays bounded. notifyd, syslogd and the console
   getty stay up (same PIDs, or respawned once with a reason).
4. **Calendar without wake-ups** (id-060): a `StartCalendarInterval` job due every minute, with no
   `launchctl` calls near its times. Record whether each run happens on time, late (by how much) or
   not at all. Then step the clock forward past one due time and record the same. Report what
   happens; this item has no pass bar.
At the end: `shutdown -p now` powers off cleanly.

Result: per-load tables over time (zombies, PID-1 RSS and threads, job errors, calendar runs), a
verdict for each of 1-3 (healthy, or what failed and when), and the calendar observations. Use a
second boot only to repeat a failure or to finish after a harness fault. A third is spare.

Evidence by path; hash only each boot's raw serial log. Commits on origin.

## Limits

- No product or image edits; overlays on copies only for load and check helpers.
- If one load cannot run, record it and run the others.

Re-read OPS.md first: defaults and the REPORT block.
