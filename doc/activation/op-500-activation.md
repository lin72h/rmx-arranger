---
id: op-500
state: returned
agent: implementer
repo: rmx-implementer
idq: id-046
gate: self
authority: libxpc builds (no world); 2 ZFS images; 4 self-check boots; no push
expected: 3h
issued-at: 2026-10-05T04:52Z
updated: 2026-10-05T04:52Z
---
# op-500 — Implementer: step 4 part 2c, libxpc (op-435 § 4 item 4)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 3 hours** (tests 1 h, changes 45 min, two
images and self-checks 45 min, record 30 min).

The libxpc part of advisor2's plan item 4
(`/Users/me/wip-mach/rmx-advisor2/op-435-mach-step4-c1-d2-plan.md`
§ 1 "libxpc" and § 4 item 4), on the step 4 contract you applied to
libdispatch and launchd: readiness can be stale, no EOF is
synthesized, an owner keeps its receive name until its own
cancellation completes. Continue on `mach-fixes-5` (now `0f1f76d5`,
on origin) in `build/op468/source`.

Rules and starting points (confirm or correct each from the source):
1. **Asynchronous receive does not block.** The receive source's
   handler `xpc_connection_recv_message`
   (`lib/libxpc/xpc_connection.c:846-870`) calls `xpc_pipe_receive`
   (`xpc_misc.c:450-490`, private, this is its only caller), which
   uses `mach_msg` with `MACH_MSG_TIMEOUT_NONE`. If another receiver
   took the message first, the handler blocks a dispatch thread.
   Receive with `MACH_RCV_TIMEOUT` and timeout zero there;
   `MACH_RCV_TIMED_OUT` means stale readiness: return and let the
   source fire again. Any blocking receive used for synchronous
   replies stays blocking.
2. **No parsing after a failed receive.** `xpc_pipe_receive` logs a
   non-zero `mach_msg` result and then unpacks the buffer anyway
   (`xpc_misc.c:471-480`). Return the error before touching the
   buffer, on every failure.
3. **Terminal receive errors cancel.** A receive that reports the
   local port is gone or invalid (`MACH_RCV_PORT_DIED`,
   `MACH_RCV_INVALID_NAME`, `MACH_RCV_PORT_CHANGED`) cancels the
   connection with `XPC_ERROR_CONNECTION_INVALID`, once. Remote death
   keeps using its send notification or send error path.
4. **Cancellation stays as it is:** `xpc_connection_destroy`
   (`xpc_connection.c:715-770`) waits on `xc_source_cancel_count`
   before releasing pending calls, the remote send right
   (`mach_port_deallocate`) and the owned local receive right; keep
   that gating and do not turn it into EOF handling.

Tests first (Zig, a new `tests/lib/libxpc`, registered like
`tests/lib/launchd`):
1. Another receiver drains the connection's message before its
   handler runs: the handler returns without blocking, and the
   connection still receives the next message.
2. A failed receive: the handler gets an error, and no event with a
   parsed object reaches the connection's handler.
3. The local receive right goes away while the connection is live:
   exactly one `XPC_ERROR_CONNECTION_INVALID`, ports released once.
4. Remote death with two replies pending: each pending reply handler
   runs exactly once, with `XPC_ERROR_CONNECTION_INVALID`.
5. Cancel while the receive source is cancelling: one cancellation,
   pending calls and ports released once.

Then two ZFS images (from `op417-alpha2-zfs-gpt.raw`, reusing the
existing world): base = `0f1f76d5` + the tests (name its branch, as
before), fixed = the changes + the same tests (test files
identical). Self-check: new cases fail on base as recorded (say which
cannot be shown on base and why), all pass on fixed, and the 69
earlier cases pass on fixed.

Evidence: the commits; your op record with each rule's change, test
and base and fixed results; both image hashes and BOMs (by path); the
`selfcheck:` line.

## Limits

- libxpc and its tests only: no kernel, libdispatch, libmach or
  launchd change. No pure C1, public KNOTE or D2 work. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
