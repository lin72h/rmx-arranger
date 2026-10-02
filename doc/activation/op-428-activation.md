---
id: op-428
state: draft
agent: implementer
repo: rmx-implementer
idq: id-046
gate: validator
authority: build: kernel RMXOS-RELEASE, mach.ko, libmach and the Mach tests from the branch; stage base and fixed test images with rmx-stage-image; no guest runs; no push
updated: 2026-10-02T11:40Z
---
# op-428 — Implementer: Mach fix batch 3, finish — thread-exit gate as a function-pointer hook, remaining lifetime fixes, images (continues op-427)

## Outcome

Context: ordinary bug fixing in our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source Mach IPC).

Finish batch 3 (op-394 step 3) on `mach-fixes-3`, after your op-427 commits, which stand:
`842c3a59` (exec committed event), `3956111e` (lifetime regression tests) and `119b7a51` (thread
published event), on `b9ad6f42` (F1). Everything in the op-427 brief still applies: exec policy,
fd-flag rule, shared fd table sharing its Mach space and names, and the targets op-389 #4 and #11,
op-392 F2, op-393 N5's prerequisite, and F1.

**Answer to your lock question: do not release `PROC_SLOCK`, and do not use an EVENTHANDLER at the
thread-exit point.** FreeBSD's own hwpmc already hooks `thread_exit` under the spin lock with a
plain function pointer (`PMC_CALL_HOOK_UNLOCKED(td, PMC_FN_THR_EXIT, …)` in
`sys/kern/kern_thread.c`'s `thread_exit`). Do the same:
- a global hook pointer, loaded atomically and called under the existing locks, as its own `kern:`
  commit;
- the handler only marks the thread's Mach binding as dying, atomically: no locks, no sleeping, no
  allocation;
- drain, disable and free the thread's Mach state later in `thread_dtor`, as planned;
- `mach.ko` sets the pointer at load. Mach stays preloaded and non-unloadable, so there is no
  unload race.

This replaces the EVENTHANDLER thread-exit gate in the allowed list. No other FreeBSD-side change.

Then complete the remaining lifetime fixes, build the kernel, `mach.ko`, libmach and the tests, and
stage two images as before: `mach-fixes-2` + the new tests, and `mach-fixes-3` + the new tests.

Evidence: the commits; a note mapping each target to its commit and test with expected results;
every native file changed and why; both image hashes and BOMs (by path).

## Limits

- Step 3 only. No push of `wip-rmxos`.

Re-read OPS.md first: defaults and the REPORT block.
