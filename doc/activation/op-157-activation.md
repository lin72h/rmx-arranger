# op-157 — Validator-GLM: exhaustive inspection gate on the op-156 fix (port-to-pset lost-wakeup)

op-157 | role: **Validator-GLM** (FREE — GLM model) | state: READY dispatch (authorized) | parent id: id-025 | authored 2026-06-26 (Fable)
gates: op-156 fix (branch op-156-id025-waitpath @ 180d30b, file sys/compat/mach/ipc/ipc_pset.c). Inspection-only — NO build, NO soak. Runs IN PARALLEL with op-158 (DS4P) and op-155 (capture).

CONTEXT (Fable already verified the mechanism first-hand — do NOT re-derive, EXTEND it to exhaustive coverage):
- Named root cause A.4: a thread parks in a bare PORT's own thread pool via `ipc_mqueue_receive`/`thread_pool_put_act` (ipc_mqueue.c:811-816); `ipc_mqueue_deliver` routes deliveries solely on `port->ip_pset` (ipc_mqueue.c:443-454); `ipc_pset_move` `oset==IPS_NULL→nset` branch (ipc_pset.c:333-343) set `ip_pset` but never woke the port-pool waiters. Fix wakes them with MACH_RCV_PORT_CHANGED via `ipc_pset_port_changed`.

OBJECTIVE — prove the fix is COMPLETE, not just locally correct. Confirm-or-refute EACH by enumeration with file:line:
1. **Every direct-receiver→port-pool enqueue site.** Enumerate ALL call paths that land a thread in a *port's own* thread pool (`thread_pool_put_act` with `ith_object`=port). Confirm the only blocking path is `ipc_mqueue_receive` direct-port branch, OR list any others — each is a potential lost-wakeup victim the fix must also cover.
2. **Every `ipc_pset_move` branch that sets/changes `port->ip_pset`.** There are two that route a port into a set: `oset==IPS_NULL→nset` (fixed) and both-non-null `oset→nset` (ipc_pset.c:356-379). Prove the both-non-null branch CANNOT have direct port-pool waiters (port was already pset-routed via oset) — or flag it as a second missing wake.
3. **Every other producer of `port->ip_pset` transitions** outside `ipc_pset_move` (grep all writers of `ip_pset`). Confirm none introduces a no-set→set transition that bypasses the new wake.
4. **Lock/order audit of the new call site.** Confirm `ipc_pset_port_changed` is always entered with the port io_lock held (required by `thread_pool_get_act(port,0)`), and the nset lock held; confirm `thread_go` introduces no lock-order edge. Confirm MACH_RCV_PORT_CHANGED is drained cleanly by `ipc_mqueue_receive_error` (ipc_mqueue.c:556-559) with no `thread_pool_remove` double-pop.

DELIVERABLE / GATE: a written enumeration (file:line per claim) with a PASS/FAIL per item 1-4. PASS = fix covers every enqueue site + every set-entry transition + lock order clean. Any uncovered site → FAIL with the exact path. Inspection only; cite source, do not run anything.

MARKERS:
```
OP157_ENQUEUE_SITES_ENUMERATED status=0    # all port-pool enqueue paths listed (file:line); fix-coverage verdict
OP157_PSET_MOVE_BRANCHES status=0          # both set-entry branches dispositioned (covered | proven-safe | FAIL)
OP157_IP_PSET_WRITERS status=0             # all ip_pset writers enumerated; no bypass of the wake
OP157_LOCK_ORDER_CLEAN status=0            # call-site lock/order + clean PORT_CHANGED drain verified
OP157_VERDICT status=0                     # overall PASS|FAIL with evidence
OP157_TERMINAL status=0
```

PUSH: report the enumeration + per-item verdicts → Fable first-hand check → if PASS joins DS4P (op-158) pass → fix eligible for merge AFTER op-155 corroborates reachability. Do NOT merge. Inspection product only.

CHAIN (id-025): op-156 (fix, Fable-verified sound) → **op-157 (GLM exhaustive)** ∥ op-158 (DS4P falsify) ∥ op-155 (capture, reachability) → all green → merge → notify leg-4 / id-010.
