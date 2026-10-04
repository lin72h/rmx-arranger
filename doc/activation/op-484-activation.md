---
id: op-484
state: draft
agent: implementer
repo: rmx-implementer
idq: id-046
gate: self
authority: launchd builds (no world); 2 images; 4 self-check boots; no push
expected: 4h
updated: 2026-10-05T00:00Z
---
# op-484 — Implementer: step 4 part 2b, launchd (op-435 § 4 item 4)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 4 hours** (tests 1.5 h, changes 1 h, two
images and self-checks 1 h, record 30 min).

The launchd half of advisor2's plan item 4
(`/Users/me/wip-mach/rmx-advisor2/op-435-mach-step4-c1-d2-plan.md`
§ 1 "launchd" and § 4 item 4), on the same contract as op-468: no EOF
is synthesized; a removed name silently drops its registrations; an
owner keeps a receive name and its set membership until its own
cancellation completes; watched send and dead names are released with
`mach_port_deallocate`, never closed or destroyed. launchd has no EOF
handling to remove (`EV_EOF` appears only in logging,
`runtime.c:440`). Continue on `mach-fixes-5` (now `b2d5f5b7`, being
proven by gatekeeper1; do not change libdispatch or libmach) in
`build/op468/source`.

Rules and starting points (confirm or correct each from the source):
1. **Demand callback revalidates** (`sbin/launchd/runtime.c:580-617`,
   `mportset_callback`). It lists `demand_port_set`'s members, and
   for the first one with messages calls `job_find_by_service_port()`'s
   result as a callback with no NULL check (the check is under
   `#if 0`). If the service was removed after the readiness event,
   that is a call through NULL in PID 1. Skip a member with no current
   job or machservice; never act for another service.
2. **Crash drain** (`core.c:7326-7369`, `machservice_drain_port`). The
   buffers are `calloc`'d but used as `&req_buff` / `sizeof(req_buff)`
   (the address and size of the pointer variable), and never freed.
   The loop with `drain_all` ends only on `MACH_RCV_TIMED_OUT`, so any
   other lasting error (invalid name, port died, too large) repeats
   forever. Receive into the real buffers with their real sizes, free
   them, and end the drain on every terminal receive error.
3. **Before replacing or destroying an owned set or service port**,
   remove it from `demand_port_set`/`ipc_port_set` and let callbacks
   already started finish first (`machservice_delete` at
   `core.c:7372-7396` and the other `launchd_mport_close_recv` sites).
   A destroyed set gives no final event; no rearm after a terminal
   error.
4. **Dead names** keep the existing handler
   (`runtime.c:1014-1031`, `do_mach_notify_dead_name`): drop the job's
   records for the name, then release the extra dead-name uref with
   `mach_port_deallocate`, even if the job record is already gone.

Tests first (Zig, against a launchd in the guest, registered like
`tests/lib/libdispatch`; say how the cases drive launchd):
1. A demand message queued for a MachService that is removed before
   launchd handles it: launchd stays up (same PID 1), the removed
   service is not launched, and an unrelated service is not launched.
2. Crash drain with `drain_all` (a job with `DrainMessagesOnCrash`
   that exits with messages queued): every queued message is drained
   once, then the drain ends; launchd stays responsive.
3. Crash drain when the port is gone or a message is too large: the
   drain ends without repeating.
4. A service's send-death notification arriving after its job was
   removed: no other job is affected and urefs balance.

Then two images, reusing the existing world: base = `b2d5f5b7` + the
tests, fixed = the changes + the same tests (test files
byte-identical). Self-check: new cases fail on base as recorded (say
which cannot be shown on base and why), all pass on fixed, and the 65
earlier cases still pass on fixed.

Evidence: the commits; your op record with each rule's change, test
and expected result on base and fixed; both image hashes and BOMs (by
path); the `selfcheck:` line.

## Limits

- launchd and its tests only: no kernel, libdispatch, libmach or
  libxpc change. No pure C1, public KNOTE or D2 work. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
