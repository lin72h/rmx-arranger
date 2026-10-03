---
id: op-437
state: issued
agent: implementer
repo: rmx-implementer
idq: id-046
gate: self
authority: build: kernel RMXOS-RELEASE, mach.ko, libmach and the Mach tests from mach-fixes-3; stage base and fixed test images with rmx-stage-image; no guest runs; no push
updated: 2026-10-03T01:40Z
---
# op-437 — Implementer: Mach batch 3 remediation — two teardown defects (op-433) and four lifetime cases that fail before their checks (op-434)

## Outcome

Context: ordinary bug fixing in our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source Mach IPC). Everything runs in disposable bhyve guests with no network.

Batch 3 (`mach-fixes-3` at `db592723`, your op-430) is not accepted yet. Continue on that branch
and fix what review and the guest run found.

**From validator3's review** (`/Users/me/wip-mach/rmx-validator3/reviews/op-433/op430-review.md`, `63fb8916`):
1. **Failed process creation.** If the first `thread_alloc` fails (`sys/kern/kern_fork.c:1099-1102`),
   the process has no thread. `mach_task_dtor` then calls `mach_task_exit`, which reads
   `FIRST_THREAD_IN_PROC(p)->td_machdata` without a check (`sys/compat/mach/kern/task.c:1127-1150`).
   Make the unwind handle a process with no thread.
2. **Parked RPC reply at thread exit or exec.** A reply parked in `ith_kmsg`
   (`sys/compat/mach/ipc/ipc_mqueue.c:247-273`) is never released when the thread retires, so the
   message and the rights it carries leak, possibly including a task control-port reference.
   Release it during retirement. (Step 4 will remove parked replies altogether; this fix only
   needs to make batch 3 correct on its own.)
Each gets a regression test written first. If a case cannot be reached from user space, say how it is covered
instead (for example a fixture call, as fixes 6 and 9 did).

**From gatekeeper1's guest run** (`/Users/me/wip-mach/rmx-gatekeeper1/build/op434/findings.md`, `45befb8`):
fixed image 35/39. All 31 batch-1 and batch-2 cases pass, as do `inherited_rights`,
`shared_fd_exit`, `incarnation` and `live_credentials`. No panic. Four cases fail on the fixed image
**before** their named check:
- `task_control_death`: "child observation failed" (also on base);
- `thread_control_death`: "thread observation failed" (also on base);
- `rfork_unshare` and `rfork_clean_table`: "child observation failed" on fixed; on base they hang
  until the 20-second timeout.
Raw serial: `build/op434/runtime/*/serial.raw`; ATF results: `build/op434/atf-results/`.
Find whether each is a test fixture fault or a product defect, fix it, and make sure each case
reaches its named check on both images. On base, the rfork cases must fail rather than hang.

Then build and stage two images as before: `mach-fixes-2` + the updated tests, and the fixed
`mach-fixes-3` + the same tests (test files byte-identical in both).

Evidence: the commits; a note giving each item's cause, fix and test, with its expected result on
base and fixed; both image hashes and BOMs (by path).

## Limits

- Batch 3 scope only: no step-4 receive-model work, no D2.
- FreeBSD-side changes: only the three batch-3 hooks as they are; any other change, stop and report.
- No push of `wip-rmxos`.
- Clean-up from op-436: the `op436-selftest-*` images in `/Users/me/wip-mach/stage/images` are yours; delete them
  (their fixture records stay in `stage/artifacts/op436-selftest-final5/`).

Re-read OPS.md first: defaults and the REPORT block.
