---
id: op-502
state: closed
agent: implementer
repo: rmx-implementer
idq: id-046
authority: libxpc builds (no world); 2 ZFS images; 3 self-check boots; no push
expected: 2h30m
issued-at: 2026-10-06T03:38Z
updated: 2026-10-07T00:09Z
---
# op-502 — Implementer: op-500 remediation (remote death on a named-service client interrupts, not cancels)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 2.5 hours** (tests 45 min, change 30 min, two
images and self-checks 45 min, record 30 min).

op-500 is verified except for one point, and the mistake was in my
brief: test 4 asked remote death to give `XPC_ERROR_CONNECTION_INVALID`.
Apple's libxpc does that only for connections that cannot reconnect. A
client of a named Mach service gets `XPC_ERROR_CONNECTION_INTERRUPTED`
and keeps a usable connection, so launchd can start the service again
and the client carries on. Correct the remote-death and send-error
paths on `mach-fixes-5` (now `bd6bc1b8`, not on origin) in
`build/op468/source`. Rules 1, 2, 4 of op-500 and its receive-side
cancellation (`xpc_connection.c:884-889`) stay as they are.

Rules (confirm or correct each from the source):
1. **Which connections reconnect.** A named-service client is a
   connection made by `xpc_connection_create_mach_service` without
   `XPC_CONNECTION_MACH_SERVICE_LISTENER` (`xc_parent == NULL`, a
   name, `xc_owns_remote_port`). Peers (`xc_parent != NULL`) and
   endpoint connections (`xpc_connection_create_from_endpoint`) do not
   reconnect.
2. **Remote death.** `xpc_connection_remote_dead`
   (`xpc_connection.c:808-812`) and the `EPIPE` branch in `xpc_send`
   (`:529-535`): on a named-service client, interrupt
   (`XPC_ERROR_CONNECTION_INTERRUPTED`; each pending reply handler runs
   once with it; the connection is not cancelled). On a peer or
   endpoint connection, cancel with `XPC_ERROR_CONNECTION_INVALID`, as
   op-500 does now. Keep the `MACH_SEND_INVALID_DEST` to `EPIPE`
   mapping (`xpc_misc.c:442`).
3. **Usable after interruption.** Today `xc_interrupted` is set once
   and never cleared (`xpc_connection_interrupt`, `:647-656`), and the
   dead send right stays in `xc_remote_port`. After an interruption,
   the next send on a named-service client looks the name up again
   with `bootstrap_look_up`, replaces the remote send right (releasing
   the old one once), re-arms the send-death source, and allows a later
   interruption to be reported again. If the lookup fails, report
   `XPC_ERROR_CONNECTION_INTERRUPTED` for that send and keep the
   connection; do not cancel it.

Tests (in `tests/lib/libxpc`, on op-500's fixture):
1. Replace op-500's `remote_pending` expectations: a named-service
   client with two replies pending, through both the send-death
   notification and the send-error phase: each pending handler runs
   once with `XPC_ERROR_CONNECTION_INTERRUPTED`, no
   `XPC_ERROR_CONNECTION_INVALID`, the connection is not cancelled.
2. A peer connection, same two phases: each pending handler runs once
   with `XPC_ERROR_CONNECTION_INVALID` (op-500's current result).
3. Reconnect: after test 1's interruption, the service name is checked
   in again with a new receive right; the client's next message and its
   reply arrive over the new right, and a second remote death is
   reported as a second `XPC_ERROR_CONNECTION_INTERRUPTED`. Port
   accounting: the old send right is released exactly once.

Then two ZFS images (from `op417-alpha2-zfs-gpt.raw`, reusing the
existing world): base = `bd6bc1b8` + the tests (name its branch, as
before), fixed = the change + the same tests (test files identical).
Self-check: the new cases fail on base as expected (test 2 passes on
base; say so), all pass on fixed, and op-500's other cases and the 69
earlier cases pass on fixed.

Evidence: the commits; an addendum to `docs/op500-libxpc.md` (or a new
op record) with each rule's change, test and base and fixed results;
both image hashes and BOMs (by path); the `selfcheck:` line.

## Limits

- libxpc and its tests only: no kernel, libdispatch, libmach or
  launchd change. Receive-side cancellation, the timeout-zero receive
  and the cancellation gating from op-500 stay unchanged. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
