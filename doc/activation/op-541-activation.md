---
id: op-541
state: closed
agent: implementer
repo: rmx-implementer
idq: id-061
authority: test builds only (no kernel or launchd change); up to 2 ZFS images made from existing ones plus the new test; 5 self-check boots; no push
expected: 4h
issued-at: 2026-10-07T09:53Z
updated: 2026-10-07T10:34Z
---
# op-541 — Implementer: id-061 reproduce launchd's request chain without launchd (bounded stress test)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 4 hours** (test 1.5 h, images 45 min, runs
1 h, record 45 min).

id-061 (`/Users/me/wip-mach/rmx-arranger/idq/id-061-launchd-control-reply-lost.md`):
under repeated `launchd_consumer_test` runs, a request to launchd
sometimes gets no reply, and the guest then does not power off. It
happens on `mach-fixes-6` and on the older `2de5f1d4` kernel
(`docs/op529-launchd-reply.md`). The request travels this chain in
launchd: the test's socket is registered in launchd's main kqueue
(`tests/lib/launchd/fixture.zig:376`); a second launchd thread
`select()`s on that kqueue (`sbin/launchd/runtime.c:622-639`) and
then sends a `handle_kqueue` Mach request to launchd's own internal
port (`:639`); the main thread receives it from its port set and
calls `kevent` (`:662`), which runs the test's handler
(`fixture.zig:330`). Find which step stops, without launchd.

1. **A stress test of the same chain** (`tests/sys/mach`, Zig, new
   program): one process, two threads. Thread A: `select()` on a
   kqueue that watches one end of a `SOCK_SEQPACKET` pair; when it is
   readable, send a Mach request to a port that is a member of a port
   set and wait for the reply on its own reply port. Thread B: loop on
   `mach_msg` receive from that port set; for each request, call
   `kevent` on the kqueue to read the socket event, reply, and go
   back to receiving. A driver writes to the socket, waits for the
   round trip, and repeats (10,000 iterations or 60 s). Every wait is
   bounded; on a stall, print which step did not complete (socket
   written, `select` woke, request queued, request received, `kevent`
   returned the event, reply received) and the iteration number.
2. **Run it on the current kernel:** add the test to a copy of
   `op516-fixed-tests-r2.raw` (`mach-fixes-6@4de4d9ae`), METALOG/BOM
   diff showing only the new test differs. Run it in up to three
   boots.
3. **If it stalls, run it on the older kernel:** the same addition to
   a copy of `op529-old-tests-r1.raw` (`2de5f1d4`). Report on which
   kernels it stalls and at which step.
4. If it never stalls, say so, and say which part of launchd's chain
   the test does not cover.

Do not fix anything in this op. Name a cause only with file:line.

Evidence: commits; your op record (`docs/op541-request-chain.md`)
with the test, each run (kernel, iterations, any stall and its step),
image hashes and BOMs by path; the `selfcheck:` line.

## Limits

- A new test program only: no kernel, launchd, libdispatch or libxpc
  change. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
