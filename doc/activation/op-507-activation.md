---
id: op-507
state: closed
agent: implementer
repo: rmx-implementer
idq: id-046
authority: libxpc builds (no world); 2 ZFS images; 3 self-check boots; no push
expected: 3h
issued-at: 2026-10-06T05:40Z
updated: 2026-10-07T00:09Z
---
# op-507 — Implementer: op-504 remediation (libxpc reconnect without a receive-queue wait; process watcher follows the server)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 3 hours** (tests 1 h, changes 45 min, two
images and self-checks 45 min, record 30 min).

validator3 reviewed op-500 and op-502 together (op-504, REMEDIATE
9/10):
`/Users/me/wip-mach/rmx-validator3/reviews/op-504/op500-op502-review.md`
(§ F1, § F2, and the queue-case table). Everything else in the
review was confirmed. Fix both findings on `mach-fixes-5` (now
`8cc4b37a`, not on origin) in `build/op468/source`.

Rules (confirm or correct each from the source):
1. **F1: sends never wait on the delivery queue.** `xpc_send` calls
   `xpc_connection_reconnect` (`lib/libxpc/xpc_connection.c:527-533`),
   which does `dispatch_sync` onto `xc_recv_queue` (`:877-935`). That
   queue delivers events, targets `xc_target_queue` and is suspended
   by `xpc_connection_suspend`. An event handler (or code on a serial
   target queue) that sends and then calls
   `xpc_connection_send_barrier` (`:391-396`) waits for the send
   queue, while the send queue waits for it. After an interruption, a
   suspended connection also holds every later send. Remove the
   dependency: the send path must not wait on `xc_recv_queue` or the
   target queue. For example, look up and publish on the send queue
   (sends are already serial there) under `xc_remote_lock`, with the
   send-death handler's identity check made safe against that
   publication. Keep message and barrier order, the old right's
   release after its source detaches, and the cancellation checks.
2. **F2: the process-exit watcher follows the current server.**
   `xpc_connection_reconnect` replaces only the send source.
   `xpc_connection_arm_proc_source` (`:946-963`) returns while
   `xc_proc_source` is set, so a reply from the new server never
   watches its PID, and `xpc_connection_remote_proc_dead` (`:939-943`)
   interrupts the current connection when the old server exits. On
   replacement (and when the credentials name a PID other than
   `xc_proc_pid`), retire the old watcher with the same ownership rule
   as the old send source (cancellation count or its own reference),
   arm the watcher for the new PID, and make a retired watcher's
   callback do nothing. A launchd restart that keeps the same port
   reaches the client only through this watcher, so the new server's
   exit must interrupt again.

Tests first (on op-502's fixture; leave the existing cases as they
are, including the order `a5aa3b09` set):
1. Suspended connection: after an interruption, an asynchronous send
   and then `xpc_connection_send_barrier` from another thread both
   complete within a bound while the connection stays suspended;
   resume only after the check.
2. From the event handler, on `XPC_ERROR_CONNECTION_INTERRUPTED`: an
   asynchronous send then `xpc_connection_send_barrier` completes
   within a bound, and the message arrives over the replacement right.
3. The same from a serial target queue.
4. Two server processes A and B (child processes, so the `getpid`
   exclusion at `:951` does not apply): after reconnecting to B, A's
   exit causes no interruption and no pending call of B's completes;
   B's later exit causes exactly one
   `XPC_ERROR_CONNECTION_INTERRUPTED`.
Bound every wait, so a hang shows as a FAIL with a reason rather
than a stuck boot.

Then two ZFS images (from `op417-alpha2-zfs-gpt.raw`, reusing the
existing world): base = `8cc4b37a` + the tests (name its branch, as
before), fixed = the changes + the same tests (test files identical).
Self-check: the new cases fail on base as expected (say which cannot
be shown on base and why), all pass on fixed, and the 77 earlier
cases pass on fixed.

Evidence: the commits; your op record (`docs/op507-libxpc.md`) with
each rule's change, test and base and fixed results; both image
hashes and BOMs (by path); the `selfcheck:` line.

## Limits

- libxpc and its tests only: no kernel, libdispatch, libmach or
  launchd change. op-500's receive changes and op-502's
  interruption/cancellation classification stay as they are. The
  inherited synchronous-reply waits on the event or target queue
  (the review's table, "already on base") are out of scope. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
