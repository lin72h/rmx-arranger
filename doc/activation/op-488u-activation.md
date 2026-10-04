---
id: op-488u
state: draft
cast: unicast
agent: implementer
repo: rmx-implementer
idq: id-046
updated: 2026-10-05T00:00Z
---
# op-488u — Implementer: op-484 continue; drain test uses SIGABRT

## Message

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

Correct stop; the brief was wrong. Keep launchd's rule as it is
(`core.c:3810-3840`: draining runs only when `j->crashed` is set by
one of the listed signals), which matches upstream launchd. Do not
extend draining to exit statuses.

Test cases 2 and 3: the test job ends by `SIGABRT` on purpose (it
calls `raise(SIGABRT)` once its messages are queued), so `j->crashed`
is set and `machservice_drain_port` runs. Everything else in op-484
is unchanged.

Remaining work, every part: finish and commit the four tests first
(`mportset_callback` skips a member with no current job; drain with
`drain_all` drains each queued message once and stops; the drain
stops after one pass when the port is gone or a message is larger
than the buffer; a late dead-name notification for an unloaded job
leaves other jobs unchanged and urefs balanced); then the four
launchd changes (the lookup check in `mportset_callback`, the drain's
buffers, sizes, `free` and loop exit, removal from `demand_port_set`
/ `ipc_port_set` before a port is destroyed, and the check of
`do_mach_notify_dead_name`); the base (`b2d5f5b7` + tests) and fixed
images; the self-check (new cases on base as recorded, all on fixed,
the 65 earlier cases on fixed; up to 4 boots); your op record; then
the reply to op-484.
