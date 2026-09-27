---
id: op-254
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-254 — Validator gate (GLM + DS4P): correctness review of the op-224 insert-right task-refcount fix — confirm removing the unbalanced task_deallocate is correct and regression-safe → retire op-224

op-254 | role: **Validator** (correctness gate; NO product-write) | EXU: **GLM (primary, cost 0) + DS4P (concurrence, cost 5)** | state: **[Done — CONCURRING RETIRE, Arranger-adjudicated 2026-07-03. GLM 9/10 RETIRE + DS4P 9/10 RETIRE — both ≥8 AND agree ⇒ op-224 RETIRES on concurrence (Rule 11, no Arbiter needed). Both independently source-read the same anchors: current_task() no-ref (thread.h), task_deallocate unbalanced decrement (task.c), removed guard trivially dead (task=current_task() ⇒ task!=current_task() always false), zero remaining task_deallocate in mach_traps.c, fix isolated to one trap, XNU borrowed-pointer intent matched. Both reserved 1pt only on the regression serial — Arranger-verified first-hand (op224-regression-serial.log:143-146). Arranger re-confirmed thread.h/task.c anchors first-hand.]** | parent id: id-000 (op-223 N1) | L1i: li-1000 | cost: 5 (DS4P leg; GLM free) | authored 2026-07-03 (Arranger seat, model Opus 4)

## CONTEXT (read first)
Open-source OS engineering — a correctness gate on OUR OWN in-tree Mach IPC refcount fix. Not security work, no external target. op-224 (Implementer) removed an unbalanced `task_deallocate(task)` and a dead guard from `sys__kernelrpc_mach_port_insert_right_trap` (commit dd6e7a80, on origin/alpha). op-224's retirement is a **dual-Validator gate** (per its own spec): GLM + DS4P both ≥8/10 AND agree.

## WHY (one line)
op-223 finding N1 (Arranger-verified): the insert-right trap did `task_deallocate(current_task())` though `current_task()` takes NO reference — under-counting `task->ref_count` by one per call on a live libmach path, driving `task_free` on a live task eventually. The fix removes that decrement; confirm it is correct and introduces no regression.

## SCOPE — the correctness questions
1. **Is the removal correct?** `current_task()` (thread.h:632-637) returns `curthread->td_proc->p_machdata` and takes NO ref, so there is nothing to release; the removed `task_deallocate` (task.c:268-279, `--ref_count; if 0 task_free`) was a pure unbalanced decrement. Confirm `task->itk_space` is still used inline (mach_traps.c:258/262) and the trap's copyin/insert behavior is unchanged. Verify the removed `if (task != current_task())` guard was genuinely dead.
2. **Is it isolated / no sibling regression?** mach_traps.c had exactly one `task_deallocate` (the removed one); sibling traps use `current_task()->itk_space` inline with no deallocate. Confirm the fix touches only this function and does not alter the refcount contract elsewhere.
3. **macOS/XNU intent match** (`oss_engineering_framing`): the trap should NOT hold a task ref it never took — confirm the borrowed-pointer discipline matches Mach-native intent.
4. **Regression evidence integrity:** op-224's D3 ran 20,000 `mach_port_allocate → insert_right → mach_port_destroy` iterations through libmach → `OP224_REGRESSION status=0`, no panic/core (serial log verified by Arranger at op224-regression-serial.log:143-146). Confirm this exercises the fixed path enough to clear the pre-fix underflow, or note what more would.

## DELIVERABLE
Two independent verdicts (GLM primary, DS4P concurrence), each a confidence 1-10 with the correctness reasoning. **Both ≥8 AND agree ⇒ op-224 RETIRES** (Arranger retires on concurrence, Rule 11). Split or either <8 ⇒ Arbiter (Arranger) steps in on the decisive point (Rule 6). If a Validator finds the fix WRONG (e.g. some path DID rely on that deallocate), that is a real defect → back to the Implementer.

## BOUNDARIES
- **Consult/gate only, no product-write.** Review the committed diff (dd6e7a80) + the regression artifact; do not edit.
- Stage in each Validator's own dir (`agent_host_isolation`).
- This is a targeted Change→Retire correctness gate (Validator, not Gatekeeper — `gatekeeper_vs_validator`): a one-function refcount fix, not a long soak.

## RELATIONS
op-224 (the fix this gates; commit dd6e7a80 on origin/alpha; mach.ko 6beda96a) / op-223 (LEG A review, finding N1) / li-1000. feedback: gatekeeper_vs_validator, validator_routing_glm_default (GLM default; DS4P concurrence per op-224's dual-gate spec), arranger_gate_sizing_delegation, verify_signature_divergence_claims, build_is_implementer, agent_host_isolation, oss_engineering_framing.
