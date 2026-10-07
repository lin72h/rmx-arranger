---
id: op-539
state: issued
agent: validator3
repo: rmx-validator3
idq: id-046
authority: none beyond the defaults: read-only; no guests
expected: 2h30m
issued-at: 2026-10-07T09:41Z
updated: 2026-10-07T09:41Z
---
# op-539 — Validator 3: review of op-516 (id-046 launchd's child-task setters)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Review the source.

**Expected time: about 2.5 hours.**

The last kernel part of id-046's step 4 (op-393 N5; op-392 S5's
caller substitution for two calls). When launchd starts a job, the
child sends launchd its own task port and launchd calls
`task_set_special_port` and `task_set_exception_ports` on it
(`sbin/launchd/core.c:8642`, `:6556`). Before this op,
`convert_port_to_task` returned the caller, so both calls changed
launchd's own task. op-516 is 6 commits on `mach-fixes-6`, from
`ea254222` (on origin) to `wip-rmxos@4de4d9ae`: tests `d5154950`,
`881d435c`, `931b7ec1`, `1f21eb8c`; changes `40e3f0d9`, `4de4d9ae`.
Source: `/Users/me/wip-mach/rmx-implementer/build/op468/source`
(read-only; use `git show` or your own worktree). Record:
`/Users/me/wip-mach/rmx-implementer/docs/op516-child-task-setters.md`.
Plan: advisor2's
`/Users/me/wip-mach/rmx-advisor2/op-435-mach-step4-c1-d2-plan.md`
§ 3. Decided scope (2026-10-03): only these two setters work on
another task; every other call on another task is refused.

Check (`sys/compat/mach/` unless named):
1. **Typed routing** (`ipc/ipc_kobject.c`): the routine family is
   matched to the destination's kobject type before any converter
   runs; wrong family gives `MIG_BAD_ID`. The MIG bucket layout seen
   by existing fixtures is unchanged (`4de4d9ae`).
2. **Truthful conversion** (`kern/ipc_tt.c`): `convert_port_to_task`
   returns the task the port names, pinned under the port lock, never
   the caller; calls on the caller's own task keep working.
3. **Allowlist:** only `task_set_special_port` (seatbelt, access,
   debug-control; seatbelt and access set-once) and
   `task_set_exception_ports` act on another task. Every other routine
   and direct trap on another task returns `KERN_NOT_SUPPORTED` (or
   `KERN_INVALID_TASK` / `KERN_INVALID_ARGUMENT` as briefed) and is
   never applied to the caller. `convert_port_to_map` hands out no
   unheld map for another task.
4. **Locked update:** the original request destination reaches the two
   setters; the space is checked under its own lock first, then alive,
   space identity and current control port are rechecked under the
   binding and task IPC locks; no space lock inside the task IPC lock;
   old and input rights released and notifications sent only after
   unlocking; an old control port fails after the task exits or after
   a credential-changing exec.
5. **Exception configuration:** launchd's exact mask, behavior and
   flavor are accepted and stored on the child; unknown bits and
   flavors refused; `EXC_MASK_ALL` unchanged; nothing delivered.
6. **Rights on refusal:** input rights released once, error reply
   still sent.
7. **Tests and scope:** would `mach_child_setters_test` (`special`,
   `exception`, `refused`, `stale_exit`, `stale_exec`) detect the
   defects at `ea254222`; are the corrected `kernel_reply_audit`,
   `revoked_port`, `revoked_set` still meaningful; is every wait
   bounded? Only `sys/compat/mach`, its MIG definitions and
   `tests/sys/mach` changed.

Distinguishing question: is there a path where a call aimed at
another task changes the caller, or where a setter updates a task that
has exited or whose control port is no longer current?

Re-read OPS.md first: defaults and the reply block.
