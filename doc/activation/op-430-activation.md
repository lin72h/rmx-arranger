---
id: op-430
state: draft
agent: implementer
repo: rmx-implementer
idq: id-046
gate: validator
authority: build: kernel RMXOS-RELEASE, mach.ko, libmach and the Mach tests from the branch; stage base and fixed test images with rmx-stage-image; no guest runs; no push
updated: 2026-10-02T11:55Z
---
# op-430 — Implementer: Mach fix batch 3, finish — lazy Mach-space rebinding after in-place rfork, remaining lifetime fixes, images (continues op-428)

## Outcome

Context: ordinary bug fixing in our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source Mach IPC).

Finish batch 3 (op-394 step 3) on `mach-fixes-3`, after your op-428 commits, which stand:
`3cb2092a` (atomic thread-exit gate) and `415112e0` (special send rights released on exit), on
op-427's `842c3a59`, `3956111e` and `119b7a51` and op-426's `b9ad6f42`. Everything in the op-427 and
op-428 briefs still applies.

**Answer to your question about in-place fd-table changes (rfork without RFPROC): no new FreeBSD
hook. Mach handles it lazily.**
- `kern_fork.c:384-420` gives the current process a clean table (`RFCFDG`) or a copy (`RFFDG`,
  `fdunshare`). The copy skips files without `DFLAG_FORK` (`kern_descrip.c:2563`), so the new table
  has no Mach names: in effect an empty Mach name space.
- Keep each Mach space bound to the fd table it was created for. On the Mach entry path, compare the
  current process's `p_fd` with the bound space's table. If they differ, bind the task to a fresh,
  empty space for the new table and drop the task's reference on the old space, which lives on
  until its last owner leaves (the shared-table rule). Do the check and rebinding under the task's
  binding lock, so threads of the same process cannot race it.
- Task-level state (task port, bootstrap and special ports) belongs to the task, not the name space,
  and is kept, as for exec.
- Add a regression test: Mach names are gone after `rfork(RFFDG)` and `rfork(RFCFDG)` without
  `RFPROC`, the task's special ports still work, and new Mach names work in the new space.

Then install the thread-exit handler in `mach.ko`, complete the remaining lifetime fixes, build the
kernel, `mach.ko`, libmach and the tests, and stage two images as before: `mach-fixes-2` + the new
tests, and `mach-fixes-3` + the new tests.

Evidence: the commits; a note mapping each target to its commit and test with expected results;
every native file changed and why; both image hashes and BOMs (by path).

## Limits

- Step 3 only. No FreeBSD-side change beyond the three hooks already committed. No push of
  `wip-rmxos`.

Re-read OPS.md first: defaults and the REPORT block.
