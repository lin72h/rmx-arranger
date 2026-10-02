---
id: op-426
state: draft
agent: implementer
repo: rmx-implementer
idq: id-046
gate: validator
authority: build: kernel RMXOS-RELEASE, mach.ko, libmach and the Mach tests from the branch; stage base and fixed test images with rmx-stage-image; no guest runs; no push
updated: 2026-10-02T09:40Z
---
# op-426 — Implementer: Mach fix batch 3 — op-394 step 3: task and thread lifetimes, exec and exit

## Outcome

Context: ordinary bug fixing in our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source Mach IPC).

Implement step 3 of the decided Mach design: one Mach task and thread object per process or thread
lifetime, with full teardown, and defined behaviour at fork, exec and exit, while port names stay
file descriptors. The design is advisor2's op-394 proposal (`rmx-advisor2@519ec47`, § B, option B2,
its hook plan and its ownership and locking rules, and step 3). Decisions you have not seen, stated
here:

- **Exec.** An ordinary exec keeps the task identity and its bootstrap and registered ports; the
  Mach name space and thread ports are rebuilt. An exec that changes credentials (setuid or setgid)
  gives the task fresh control ports, so the old ones die, as XNU's `ipc_task_reset` does. XNU's
  exception-port reset rules and task identity tokens are not matched in 1.0; do not implement them.
- **Mach names and fd flags.** Mach names are governed by Mach's own fork, exec and exit hooks,
  never by `FD_CLOEXEC` or `FD_CLOFORK`. They stay non-inheritable on fork.
- **FreeBSD-side changes allowed in this op:** an "exec committed" event (after the final
  credentials, before the return to user space) and a non-blocking thread-exit gate in the common
  `thread_exit`. Both in FreeBSD's `EVENTHANDLER` style, each as its own `kern:` commit. Use the
  existing `process_init`, `process_ctor`, `process_dtor`, `process_fork`, `process_exec`,
  `process_exit` and `thread_*` handlers for everything else. Any other change to FreeBSD's own
  code: stop and report.
- **One Mach space per fd table.** Teardown never runs while the table is still shared.

Target findings (id-046 ledger):
- op-389 #4: fork copies task send rights that exit never releases;
- op-389 #11: shared-fd `rfork` exit;
- op-392 F2: task-port teardown;
- op-393 N5's prerequisite: stale identity on reused slots. The task-call conversion itself is D2,
  later;
- op-392 F1: the caller identity a receiver sees is a fork-time snapshot. Use credentials taken
  when the message is sent, per the proposal.

Work on a new branch `mach-fixes-3` from `mach-fixes-2` (`ee883a74`). Commit in steps that each
build. Each target gets a regression test, written first, in the existing `tests/sys/mach` style,
with its expected result on `mach-fixes-2` and after. Tests check Mach behaviour, not fd numbers.
Build and stage two images as before: `mach-fixes-2` + the new tests, and `mach-fixes-3` + the new
tests.

Evidence: the commits; a note mapping each target to its commit and test with expected results;
the native files changed; both image hashes and BOMs (by path).

## Limits

- Step 3 only: no receive-model change (step 4), and no cross-task MIG calls beyond what F1 needs.
- No push of `wip-rmxos`.

Re-read OPS.md first: defaults and the REPORT block.
