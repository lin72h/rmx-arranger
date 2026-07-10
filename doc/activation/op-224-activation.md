# op-224 — Implementer: fix the unbalanced task_deallocate in sys__kernelrpc_mach_port_insert_right_trap (per-call task ref-count under-count on a live libmach path)

op-224 | role: **Implementer** (product-write) | EXU: **wip-gpt (Implementer seat)** | state: **[RETIRED — 2026-07-03, op-254 dual-Validator gate PASSED (GLM 9/10 + DS4P 9/10, both RETIRE, concurrence per Rule 11). Fix confirmed correct + regression-safe. Removed the unbalanced `task_deallocate(task)` and dead `task != current_task()` guard from `sys__kernelrpc_mach_port_insert_right_trap` (mach_traps.c:250-266); task=current_task() is a BORROWED pointer (thread.h: returns `curthread->td_proc->p_machdata`, no ref taken — Arranger re-verified first-hand), used inline via task->itk_space. task_deallocate (task.c: `--ref_count; if 0 task_free`) was a pure per-call underflow. Regression: 20,000 allocate→insert_right→destroy iters `OP224_REGRESSION status=0` no panic (op224-regression-serial.log:143-146). mach.ko 6beda96a…, commit dd6e7a80 == origin/alpha (pushed, ff).]** | parent id: id-000 (op-223 LEG A review, finding N1) | L1i: li-1000 | cost: 30 | authored 2026-07-02 (Arranger seat, model Opus 4)

## OUTCOME (Arranger adjudication, 2026-07-03, verified first-hand)
Fix verified at source (mach_traps.c:250-266 — the deallocate + dead guard are gone, borrowed `current_task()` used inline), regression artifact verified (20k iters, status=0, no panic), and origin-reachability confirmed (`alpha == origin/alpha == dd6e7a80`, 0/0 ahead-behind). op-224's own D3 regression is a deliverable artifact, NOT self-gating — retirement binds to the **dual-Validator gate op-254** (GLM ≥8 + DS4P ≥8 AND agree). Retires on Validator concurrence.

## CONTEXT (read first)

Open-source OS engineering — a correctness fix to OUR OWN in-tree Mach IPC code (a NextBSD/Darwin userland ported onto stock FreeBSD 15/stable). Ordinary maintainer bug-fix work on a reference-counting imbalance we author and ship; NOT security/vulnerability research, not adversarial, no external target.

## WHY (one line)

op-223's LEG A review surfaced (finding N1) and the Arranger verified first-hand: `sys__kernelrpc_mach_port_insert_right_trap` releases a task reference it never took, so `task->ref_count` under-counts by one on every call — and this trap is on a live path (`libmach mach_port_insert_right()` routes straight through it). Left as-is, enough calls in one process drive `ref_count` to zero and `task_free` runs on a live task.

## VERIFIED FINDING (Arranger first-hand, tree @ 32f21706606f)

- `sys/compat/mach/mach_traps.c:253` — `task_t task = current_task();` then `:266-267` — `if (task) task_deallocate(task);`.
- `sys/sys/mach/thread.h:632-637` — `current_task()` returns `curthread->td_proc->p_machdata` and takes **NO** reference.
- `sys/compat/mach/kern/task.c:268-279` — `task_deallocate` does `--task->ref_count; if (x==0) task_free(task);`.
- Net: unbalanced decrement per call. The guard at `:258` `if (task != current_task())` is also **dead** (task IS current_task()).
- Scope: anti-pattern is **isolated** — mach_traps.c has exactly one `task_deallocate` (line 267); all sibling traps use `current_task()->itk_space` inline with no deallocate. Do NOT go hunting beyond this trap.

## SCOPE / SUBJECT

- Single function: `sys__kernelrpc_mach_port_insert_right_trap` in `sys/compat/mach/mach_traps.c` (canonical tree `wip-gpt/wip-rmxos`).
- Balance the reference. Preferred minimal fix: since `current_task()` takes no ref, **remove** the `task_deallocate(task)` (`:266-267`) and the dead `:258` guard; keep the copyin/insert logic. Acceptable alternative: take a real reference at entry (`task_reference`, kern/task.c:281) and keep the paired deallocate — but only if there's a reason to hold it, and there isn't. Prefer removal.
- Do NOT re-architect the task refcount machinery here (that is op-223 L3, a separate design call). This op is the tourniquet only.

## DELIVERABLES

**D1 — the fix.** Edit the one function so no unpaired `task_deallocate` remains; behavior of copyin/insert unchanged. Diff must be minimal and scoped to this function. → `OP224_FIX`

**D2 — build.** Build the standalone `mach.ko` module (`make -C sys/modules/mach`, per the standalone-module convention) clean; report the module SHA. → `OP224_BUILD`

**D3 — regression evidence.** A test that calls `mach_port_insert_right()` repeatedly in one process (many iterations) and confirms the owning task is NOT freed and `ref_count` stays stable (e.g. survives well past the pre-fix underflow count, no panic, insert still succeeds). Report before/after reasoning tied to the ref-count. → `OP224_REGRESSION`

**D4 — disposition.** `fixed` (diff minimal + builds + regression holds) | `walled` (report the exact obstacle). Commit + push to origin; report the commit hash and confirm origin-reachability. → `OP224_VERDICT` / `OP224_TERMINAL`

## BOUNDARIES
- **Product-write is the Implementer's** — this op edits source; that's correct for this role.
- Minimal diff, one function. No refactor of the refcount machinery (op-223 L3), no touching sibling traps, no build-infra changes.
- Build the module the standalone way (MAKEOBJDIRPREFIX only, no KERNBUILDDIR); don't fold into buildkernel.
- Push after commit; retirement binds to origin-reachable, not local-committed.

## MARKERS
```
OP224_FIX         # unpaired task_deallocate removed (or a real reference taken); one-function diff
OP224_BUILD       # mach.ko builds clean; module SHA reported
OP224_REGRESSION  # repeated insert_right holds task ref_count stable, no task_free-on-live, no panic
OP224_VERDICT     # fixed | walled
OP224_TERMINAL
```

## RELATIONS
- UPSTREAM: op-223 (LEG A review, finding N1) — the Arranger-verified source of this fix.
- DOWNSTREAM: Validators (GLM + DS4P) gate correctness (both >=8/10 AND agree) → retire. Feeds the op-223 near-term list (N1) and the 1.0-preview foundation grade.
- feedback: build_is_implementer (Implementer writes; others don't), verify-premise-before-mechanism (finding verified end-to-end before authoring), oss-engineering framing. project: mach_rebase, mach_ko_standalone_module, 10preview_gate, canonical_source_tree (wip-gpt/wip-rmxos).
