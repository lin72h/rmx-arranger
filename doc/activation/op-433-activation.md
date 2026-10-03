---
id: op-433
state: closed
agent: validator3
repo: rmx-validator3
idq: id-046
gate: self
authority: none beyond the defaults: read-only; no guests
updated: 2026-10-03T05:30Z
---
# op-433 — Validator 3: review op-430 — Mach batch 3 (task and thread lifetimes, three FreeBSD hooks, lazy space rebinding)

## Outcome

Context: ordinary bug fixing in our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source Mach IPC). Review the code, not attack scenarios.

Review Mach batch 3 (Implementer, op-426, op-427, op-430). You are the only reviewer. It implements step 3
of the decided Mach design: one Mach task and thread object per process or thread lifetime, with
full teardown, while port names stay file descriptors. Branch `mach-fixes-3`, 12 commits from
`mach-fixes-2` (`ee883a74`) to `wip-rmxos@db592723e9c6`. Design: advisor2's op-394 proposal
(`rmx-advisor2@519ec47`, § B option B2, step 3). The Implementer's mapping of findings to commits
and tests: `/Users/me/wip-mach/rmx-implementer/docs/op430-mach-lifetimes.md`.

Decisions the code must follow:
- **Exec:** an ordinary exec keeps the task and its bootstrap and registered ports; a setuid or
  setgid exec gives fresh control ports (as XNU's `ipc_task_reset`). XNU's exception-port reset
  and identity tokens are deliberately not matched.
- **fd flags:** Mach names follow Mach's fork, exec and exit hooks, never `FD_CLOEXEC` or
  `FD_CLOFORK`, and are not inherited on fork.
- **One Mach space per fd table:** processes sharing a table share its space and names until the
  last of them exits. After an in-place `rfork` that replaces the table, the task rebinds to a
  fresh space lazily at its next Mach operation, keeping task-level ports.
- **FreeBSD-side changes allowed, and only these:** an exec-committed event (`842c3a59`); a
  thread-published event after `thread_link` that does not sleep or allocate (`119b7a51`); and a
  thread-exit gate in `thread_exit`, a plain function pointer called under `PROC_SLOCK` that never
  blocks (`3cb2092a`). Together: 24 lines in 6 files under `sys/kern` and `sys/sys`.

Targets: op-389 #4 and #11, op-392 F1 and F2, and op-393 N5's prerequisite (no stale identity on
reused proc or thread slots). Cross-task task calls (D2) and the receive model (step 4) are out of
scope.

Check:
1. Each target is fixed at its cause, and each new test (`mach_lifetime_test`, 7 cases;
   `mach_identity_test:live_credentials`) would detect it on `mach-fixes-2`.
2. **Lifetime:** every task and thread object, binding and control port is released exactly once.
   Nothing is used after its last reference, and nothing reachable is freed, at fork, exec, setuid
   exec, exit, thread exit and in-place `rfork`.
3. **Locking:** the exit gate and the thread-published handler take no sleeping lock, allocate
   nothing and sleep nowhere. Lazy rebinding is safe against a second thread of the same task doing
   a Mach operation at the same time.
4. **The FreeBSD-side commits** change only what they say, and leave processes that are not Mach
   tasks unchanged. `mach.ko` refuses to unload while its hooks are installed.
5. Batch-1 and batch-2 fixes are not reverted.

Distinguishing question: is there any path where a task or thread object, or its control port, outlives its
process or thread, or is freed while still reachable?

Re-read OPS.md first: defaults and the REPORT block.
