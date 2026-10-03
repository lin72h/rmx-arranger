---
id: op-444
state: returned
agent: implementer
repo: rmx-implementer
idq: id-046
gate: self
authority: build: the Mach tests from mach-fixes-3 (kernel and mach.ko only if a product change is needed); stage base and fixed test images with rmx-stage-image; self-check guests per OPS.md; no push
updated: 2026-10-03T05:28Z
---
# op-444 — Implementer: batch 3 — make thread_control_death a simple user-visible check, and self-check it in your own guests

## Outcome

Context: ordinary bug fixing in our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source Mach IPC). Everything runs in disposable bhyve guests with no network.

New this op: **run your test images yourself before returning.** See OPS.md § Self-check (re-read
it; it is new). Your first time: write a small contained runner in `tools/selfcheck/`.

op-443 (gatekeeper1 `b255431`, `build/op443/panic-backtraces.md`): `thread_control_death`
panicked on both images in the fixture, before its check:
`rmx_lifetime_observe` → `linker_file_lookup_symbol` → page fault. That is the `thread_deallocate`
lookup that `885be9ea` changed to `(linker_file_t)&__this_linker_file`. The other 40 fixed cases
pass. This one case has now failed three proofs for test reasons, so simplify it rather than patch
the fixture again:

1. **Check what a program sees.** Right after `pthread_join`, a user-space Mach call on the exited
   thread's control port (the name the worker got from `mach_thread_self()`) must fail. For example,
   `thread_info` or `thread_get_state` should return an error rather than `KERN_SUCCESS`. Record the
   code. Then, as now, the port goes inactive within 15 seconds, with the elapsed time printed.
2. If no such user call is supported on rmxOS for the caller's own threads, drop the immediate
   check and keep only the bounded inactive check. Say which and why. validator3 has already
   reviewed from source that dying bindings refuse conversion.
3. Remove the run-time `linker_file_lookup_symbol` from the fixture if nothing else needs it.

The `thr_exit` wake-before-gate window (`sys/kern/kern_thr.c:337-342`) still applies to the
immediate check. If your repeats show it, retry the call briefly (for example up to 100 ms) and
record how many retries each run took.

**Self-check before returning:**
- base: the 10 batch-3 cases, as expected;
- fixed: all 41 cases PASS, plus `thread_control_death` 20 times in a row, all PASS.
Fix and re-run within the op until that holds.

Update `EXPECTATIONS.md`. Rebuild only what changed. Stage two images as before, with test files
byte-identical in both.

Evidence: the commits; a short note giving the check you chose and its result codes; the selfcheck
counts and the 20-run table; both image hashes and BOMs (by path).

## Limits

- Batch 3 scope only. No FreeBSD-side changes.
- No push of `wip-rmxos`.

Re-read OPS.md first: defaults and the REPORT block.
