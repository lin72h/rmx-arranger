---
id: op-485u
state: draft
cast: unicast
agent: implementer
repo: rmx-implementer
idq: id-046
updated: 2026-10-05T00:00Z
---
# op-485u — Implementer: op-484 restated

## Message

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

op-484 in full, as four small launchd fixes with tests first, on
`mach-fixes-5` (now `b2d5f5b7`) in `build/op468/source`. Nothing is
started yet. Change launchd and its tests only.

1. `sbin/launchd/runtime.c:580-617`, `mportset_callback`: when a
   member of `demand_port_set` has messages, the code looks up the
   job with `job_find_by_service_port()` and invokes its callback
   without checking the lookup result (the check is under `#if 0`).
   Add the check: a member with no current job or machservice is
   skipped, and no other service is started for it.
2. `sbin/launchd/core.c:7326-7369`, `machservice_drain_port`: the
   two buffers come from `calloc`, but the code passes `&req_buff`
   and `sizeof(req_buff)` (the pointer variable, 8 bytes) and never
   frees them. With `drain_all` the loop stops only at
   `MACH_RCV_TIMED_OUT`. Use the allocated buffers and their sizes,
   free them, and stop the loop on any receive error other than
   success.
3. Before launchd destroys a service port or a set it owns
   (`machservice_delete`, `core.c:7372-7396`, and the other
   `launchd_mport_close_recv` call sites), remove the port from
   `demand_port_set` / `ipc_port_set` first, so a later scan cannot
   find it. Leave set registration otherwise as it is.
4. `runtime.c:1014-1031`, `do_mach_notify_dead_name`: keep it; check
   that it drops the job's records for the name and then releases
   the extra dead-name uref with `mach_port_deallocate`, also when
   the job record is already gone.

Tests first (Zig, against launchd in the guest, registered like
`tests/lib/libdispatch`; describe how each case drives launchd):
1. A message waits on a MachService that is unloaded before launchd
   looks at it: launchd keeps running as the same PID 1, and neither
   that service nor any other service is started for the message.
2. A job with `DrainMessagesOnCrash` set to all exits with status 1
   while messages are queued: each message is drained once, the
   drain then stops, and launchd answers `launchctl list` after it.
3. The same drain when the service port is already gone, and when a
   queued message is larger than the buffer: the drain stops after
   one pass.
4. A dead-name notification for a service whose job was already
   unloaded: other jobs are unchanged and urefs balance.

Then two images reusing the existing world: base = `b2d5f5b7` + the
tests, fixed = the changes + the same tests (test files identical).
Self-check: the new cases fail on base as recorded (say which cannot
be shown on base and why), all pass on fixed, and the 65 earlier
cases pass on fixed. Up to 4 self-check boots; no push.

Then your op record (each change, its test, base and fixed results,
both image hashes and BOMs by path, the `selfcheck:` line) and the
reply to op-484.
