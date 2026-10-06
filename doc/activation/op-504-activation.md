---
id: op-504
state: returned
agent: validator3
repo: rmx-validator3
idq: id-046
authority: none beyond the defaults: read-only; no guests
expected: 2h30m
issued-at: 2026-10-06T05:17Z
updated: 2026-10-06T05:22Z
---
# op-504 — Validator 3: review of op-500 + op-502 (libxpc, step 4 part 2c)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Review the source.

**Expected time: about 2.5 hours.**

op-500 and op-502 adapt libxpc to the step 4 contract you reviewed for
libdispatch (op-474) and launchd (op-492): readiness can be stale, no
EOF is synthesized, an owner keeps its receive name until its own
cancellation completes. Review both together: 8 commits on
`mach-fixes-5`, from `0f1f76d5` (on origin) to `wip-rmxos@8cc4b37a`.
Source (clean at that commit):
`/Users/me/wip-mach/rmx-implementer/build/op468/source`. Records with
change-to-test tables:
`/Users/me/wip-mach/rmx-implementer/docs/op500-libxpc.md` and
`docs/op502-libxpc.md` (same repo). op-502 corrects op-500's
remote-death result: a named-service client is interrupted and stays
usable, as in Apple's libxpc; peers and endpoint connections are
cancelled. Self-checks: op-500 fixed 74/74; op-502 fixed 77/77
(8 libxpc + 69 earlier), base 3 FAIL and `peer_pending` PASS as
recorded.

Check:
1. **Asynchronous receive** (`lib/libxpc/xpc_misc.c`
   `xpc_pipe_receive`, around 455-495): `MACH_RCV_TIMEOUT` with
   timeout zero; `MACH_RCV_TIMED_OUT` returns quietly; every failure
   returns before the buffer is read. Its only caller is
   `xpc_connection_recv_message`; synchronous reply waits are
   unchanged.
2. **Local receive loss** (`xpc_connection.c`
   `xpc_connection_recv_message`): `MACH_RCV_PORT_DIED`,
   `MACH_RCV_INVALID_NAME`, `MACH_RCV_PORT_CHANGED` cancel once with
   `XPC_ERROR_CONNECTION_INVALID`.
3. **Which connections reconnect** (`xpc_connection_can_reconnect`):
   named, not a listener, no parent, owned remote right. Confirm the
   `"bootstrap"` client, peers and endpoint connections are excluded,
   and that `xpc_connection_remote_dead` and the `EPIPE` branch of
   `xpc_send` choose interruption or cancellation correctly.
4. **Reconnect** (`xpc_connection_reconnect`,
   `xpc_connection_send_source`, `xpc_connection_arm_send_source`, the
   new `xc_remote_lock`): the new right and source are published once;
   the old send right is released exactly once, after its source has
   detached; a handler from a retired source does nothing;
   `xc_interrupted` is cleared only on success; a failed lookup keeps
   the connection and reports `XPC_ERROR_CONNECTION_INTERRUPTED`.
   Check every interleaving with `xpc_connection_cancel`,
   `xpc_connection_cancel_sources` and `xpc_connection_destroy`.
5. **The receive queue as a fence.** `xpc_send` runs on
   `xc_send_queue`; the reconnect does `dispatch_sync` onto
   `xc_recv_queue`, which is also where events are delivered and which
   `xpc_connection_suspend` suspends. Commit `a5aa3b09` reorders a test
   to resume the connection before fencing sends. For each case, say
   what happens: a client that has suspended the connection and sends
   after an interruption; a send made from the event handler (async,
   and `xpc_connection_send_message_with_reply_sync`); a send from the
   target queue; `xpc_connection_send_barrier` meanwhile. Separate what
   op-502 introduces from what already behaves the same at `0f1f76d5`.
6. **Test hooks:** blocks under `XPC_CONSUMER_TESTING`, enabled only
   with `XPC_CONSUMER_FIXTURE`. Confirm a normal build compiles none of
   it (`build/op502/production-isolation.log`) and that the hooks only
   observe or, for `op502_lookup`, substitute the lookup.
7. **Tests and scope:** would each new case detect its defect at
   `0f1f76d5` (op-500's cases) or `bd6bc1b8` (op-502's)? Is
   `peer_pending` a useful control? Only `lib/libxpc` and
   `tests/lib/libxpc` changed (plus test registration).

Distinguishing question: is there a path where a libxpc client stops
making progress (a blocked send queue or a lost event) or uses a send
right after it has been released?

Re-read OPS.md first: defaults and the reply block.
