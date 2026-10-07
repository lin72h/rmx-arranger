---
id: op-510
state: closed
agent: validator3
repo: rmx-validator3
idq: id-046
authority: none beyond the defaults: read-only; no guests
expected: 1h30m
issued-at: 2026-10-07T00:00Z
updated: 2026-10-07T00:02Z
---
# op-510 — Validator 3: re-review of op-507 (libxpc reconnect remediation)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Review the source.

**Expected time: about 1.5 hours.**

Your op-504 review (REMEDIATE 9/10, F1 and F2) went to the
Implementer as op-507. It returned 2 commits on `mach-fixes-5`, from
`8cc4b37a` to `wip-rmxos@2de5f1d4`: tests `004eb90b` (new
`tests/lib/libxpc/reconnect.zig`), fix `2de5f1d4`
(`lib/libxpc/xpc_connection.c` only). Source (clean at that commit):
`/Users/me/wip-mach/rmx-implementer/build/op468/source`. Record:
`/Users/me/wip-mach/rmx-implementer/docs/op507-libxpc.md`.
Self-check: fixed 81/81 (4 new + 77 earlier); base 4/4 FAIL as
expected.

Check:
1. **F1:** `xpc_connection_reconnect` now runs on the send queue
   under `xc_remote_lock`, with no `dispatch_sync`. Confirm no send
   path waits on `xc_recv_queue` or the target queue, for each row of
   your op-504 queue-case table that op-502 introduced. Message and
   barrier order, the old right's release after its source detaches,
   and the cancellation checks are kept.
2. **F2:** `xpc_connection_retire_proc_source` and the new
   `xpc_connection_arm_proc_source`: the old process watcher is
   retired on replacement and when credentials name a new PID; a
   retired watcher's callback does nothing; the new server's PID is
   watched; the cancellation count and the retirement reference
   account for every source exactly once.
3. **The lock:** `xc_remote_lock` is now held around
   `xpc_connection_interrupt` (send-death and process-exit handlers),
   `xpc_connection_set_credentials` and source retirement. Check the
   lock order against `xpc_connection_cancel` /
   `xpc_connection_cancel_sources`, and that nothing reached while it
   is held takes it again or runs client code inline.
4. **Tests:** would `suspended_barrier`, `handler_barrier`,
   `target_barrier` and `process_watcher` detect F1 and F2 at
   `8cc4b37a`, and does every wait have a bound? The
   credentials-only PID change (no reconnect) has no runtime test;
   the source review covers it.
5. **Scope:** only `lib/libxpc/xpc_connection.c` and
   `tests/lib/libxpc` changed.

Distinguishing question: after op-507, is there still a path where a
named-service client stops making progress, or where an event from a
retired server (send death or process exit) affects the current one?

Re-read OPS.md first: defaults and the reply block.
