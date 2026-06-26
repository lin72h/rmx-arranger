# op-158 — Validator-DS4P: falsify the op-156 fix (port-to-pset lost-wakeup)

op-158 | role: **Validator-DS4P** (cost-4 — falsification) | state: READY dispatch (authorized) | parent id: id-025 | authored 2026-06-26 (Fable)
gates: op-156 fix (branch op-156-id025-waitpath @ 180d30b, sys/compat/mach/ipc/ipc_pset.c). Inspection-only — try to BREAK the fix by reasoning. Runs IN PARALLEL with op-157 (GLM) and op-155 (capture).

CONTEXT: the fix wakes direct port-pool waiters with MACH_RCV_PORT_CHANGED when a no-set port joins a set (`ipc_pset_move` oset==IPS_NULL→nset). Fable verified the mechanism + lock order sound on inspection. Your job is the adversary: find the interleaving where it still hangs, regresses, or wakes wrongly.

FALSIFICATION TARGETS (for EACH: construct the breaking interleaving or declare it cannot occur, with file:line):
- **F1 — woken-then-re-block race.** The woken receiver returns MACH_RCV_PORT_CHANGED, re-issues the receive, now routes via the set. Can it re-block in a NEW lost state? e.g. it re-enters, reads `ip_pset`, but a concurrent `ipc_pset_move` removes the port from the set (nset==IPS_NULL) in the window → does it park in the port pool again with no waker? Trace the re-issue path.
- **F2 — bl-009 UAF regression.** op-107 fixed a UAF in `ipc_mqueue_pset_receive` (id-009). Does waking + draining the port pool during `ipc_pset_move` (port + nset locked) create a use-after-free or double-free of the thread/act, the port, or the pset ref? Check `thread_go` on a thread mid-`ipc_mqueue_receive` and the ref counts.
- **F3 — double-drain / lost act.** `thread_pool_get_act(port,0)` pops without clearing `ith_active`/`ith_pool_next` (thread_pool.c:122-127). Confirm the woken thread's PORT_CHANGED path (returns at ipc_mqueue.c:556-559, NO `thread_pool_remove`) cannot leave a stale pool linkage or double-remove. Falsify the "clean drain" claim.
- **F4 — missed sibling waiter.** If MULTIPLE threads are parked in the same port's pool, does the `while` loop drain ALL of them, or can one be left behind (e.g. a concurrent put_act racing the drain under the held port lock)?
- **F5 — build-wall provenance.** The 3 buildworld/buildkernel walls (libc_nonshared `__iconv_bool`; kpilite `thread_lite`; dtrace `systrace_freebsd32`) — are they PRE-EXISTING on the base (unrelated to the fix) or did the fix introduce/expose them? Check base-tree HEAD vs the branch. A wall the fix caused is a FAIL.

DELIVERABLE / GATE: per-target verdict — REFUTED (cannot break, with the invariant that blocks it) or BROKEN (the interleaving, file:line). Any BROKEN on F1-F4 → fix FAILs, back to Implementer. F5 BROKEN → build ownership issue, not correctness. Inspection only — no soak, no run.

MARKERS:
```
OP158_F1_REBLOCK status=0      # woken-then-re-block race: refuted | broken (interleaving)
OP158_F2_UAF status=0          # bl-009/id-009 UAF regression: refuted | broken
OP158_F3_DRAIN status=0        # double-drain / stale linkage: refuted | broken
OP158_F4_SIBLINGS status=0     # all port-pool siblings drained: refuted | broken
OP158_F5_BUILDWALLS status=0   # 3 walls pre-existing on base | introduced by fix
OP158_VERDICT status=0         # overall: fix survives falsification? PASS|FAIL
OP158_TERMINAL status=0
```

PUSH: report per-target verdicts → Fable first-hand check → if all F1-F4 REFUTED joins GLM (op-157) PASS → fix eligible for merge AFTER op-155 corroborates reachability. Do NOT merge.

CHAIN (id-025): op-156 (fix) → op-157 (GLM exhaustive) ∥ **op-158 (DS4P falsify)** ∥ op-155 (capture) → all green → merge → notify leg-4 / id-010.
