# id-060 — launchd PID 1: overdue calendar jobs wait for the next launchd event; reroot re-adds routes

- id: **id-060**
- state: **OPEN — not scheduled; not a preview blocker on current evidence**
- raised: **2026-10-03 by the Arranger, from op-439 (rmx-gatekeeper1 `5998d41`)**
- parent: id-016; related: id-042, li-008

## Problems

1. **Calendar jobs after a clock step.** In op-439 B01, a `StartCalendarInterval` job whose time
   had passed after the clock was stepped forward did not run within 20 seconds. In B07 it ran right
   after a read-only `launchctl list` (GetJobs) woke launchd. At `pid1-boot-1@969f2151`,
   `calendarinterval_sanity_check()` runs only from launchd's event path (`sbin/launchd/core.c:3541`),
   and calendar alarms are relative timers set before the step. An overdue job therefore runs at
   the next launchd event, not when its time passes. A real system steps its clock at boot (ntpd),
   so calendar jobs can run late. macOS launchd also reacts to calendar-change notifications from
   the kernel; rmxOS has no such notification in launchd.
2. **Reroot re-adds loopback routes.** In op-439 B06, after `reboot -r`, the second rc run printed
   four `route already in table` messages (B06:366-372). A normal boot (B01) prints none. The kernel
   keeps its network state across a reroot, so this is probably what FreeBSD's own init does too.
   Compare with a native-init reroot before treating it as a defect.

## Next

- (1): a small launchd fix, either re-checking calendar alarms on a clock-change notification or a
  periodic sanity timer, with a guest check that steps the clock and waits with no other activity.
  Candidate for the op-203 soak's list.
- (2): one native-init reroot on the same image for comparison.

## op-445 observations (2026-10-03, gatekeeper1 `c1a55c5`)

In a busy guest (orphan and job churn producing constant child exits), with no `launchctl` calls
within 20 s of any due time, 60 of 61 per-minute calendar runs fired within 3-18 ms of their
deadlines. The one after the clock was stepped forward 59 s fired 42.8 s late. Delivery in an
otherwise idle guest is op-448's phase 4.
