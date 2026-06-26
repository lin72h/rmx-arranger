# op-165 — Gatekeeper: notify LEG-4 hours-scale soak (the last notify truly-green leg) on the op-156-patched kernel — id-025 regression confirmation + cond-3 `thr_acts@0x20` rider (non-blocking)

op-165 | role: **Gatekeeper** | EXU: **rmx-gatekeeper-rx-x64z** | state: **[Queued]** (behind op-163 asl leg-4 — single soak host; sequencing = Coordinator's call) | parent id: id-010 (notify leg-4) + id-025 (regression confirmation) | authored 2026-06-27 (Arranger seat, model Opus 4)

NOTE on numbering: this is the **id-010 leg-4 regression soak** (which must run anyway to close notify truly-green) — NOT the "dedicated cond-3 re-soak" the op-156 merge decision declined. The cond-3 `thr_acts@0x20` watchpoint is folded in as a NON-BLOCKING rider, consistent with that decision (cond-3 observation is a bonus, never a gate).

purpose: notify's legs 1-3 are GREEN (op-123); leg-4 (hours-scale soak) is the ONLY remaining leg and it FAILED the no-hang bar at op-123 (the id-025 deadlock, ~t=64m, 0% CPU / IC). id-025's fix (op-156, `ipc_pset_port_changed` waking direct receivers on the no-set→set transition) is now MERGED to alpha (`3c2dd7f`) + Arranger-verified. THIS soak is the regression confirmation: a clean hours-scale run = the fix holds + notify leg-4 truly-green; a freeze recurrence RE-OPENS id-025.

STATE OF THE WORLD (verified first-hand, do NOT re-derive):
- op-156 fix MERGED on `origin/alpha` (`3c2dd7f`); fix is in `mach.ko` (`sys/compat/mach/ipc/ipc_pset.c`). The soak image MUST boot a kernel/module carrying this fix — a stale pre-fix `mach.ko` invalidates the regression read. (op-156 note: `sys/modules/mach` builds clean against the alpha object prefix → the patched `mach.ko` ships as a module WITHOUT a full buildkernel; the pre-existing dtrace `systrace_freebsd32` wall does NOT block this.)
- Canonical hardened harnesses exist + are Arranger-verified (id-010): `notifyd-soak-driver.sh` (register/post/check/cancel churn, `SOAK_DURATION` env), `notifyd-soak-oracle.d` (fbt invariant oracle), hardened by op-131 (`56664fe`) on all 3 holes (launchd-job round-trips → port=19; harness runs from shell; `pgrep -x notifyd`). bs_probe is a HARD precondition.
- The op-159/op-164 work identified the id-025 mechanism: no-set→set `ipc_pset_move` strands a direct receiver parked on the port's OWN thread pool. cond-3 (the parked receiver) lives at `thr_acts@0x20` (op-164, source-validated). The op-156 fix drains exactly that head.

DELIVER:
1. **Boot + soak on the op-156-patched kernel** — confirm first-hand the running `mach.ko` carries `ipc_pset_port_changed` (e.g. the merged SHA / a symbol presence check), THEN run the **real notifyd leg-4 workload** (register/post/check/cancel via `notifyd-soak-driver.sh`) hours-scale. Use the REAL notifyd churn, NOT the synthetic op-150 C probe (id-025/op-155 caveat: the synthetic churn may never exercise the direct-receive→move-into-set precondition; workload fidelity matters).
2. **Enforce the FIXED BAR (Gatekeeper-owned, not the Explorer's trace-only oracle):** sync oracle `tick-Ns` to `SOAK_DURATION` (NOT the 120s proof version — else the oracle exits at 120s and the soak runs unwatched). Bars: **no-hang** (the bar id-025 violated — bhyve must not go 0% CPU / IC blocked-idle) + port-slope FLATNESS (bounded delta, no monotonic growth) + kmsg/mqueue balance at quiescence + dead-name balance. NOT send/recv equality (notifyd has legit asymmetry). The terminal marker is a CLAIM — check oracle deltas + `notifyd_soak_fails` first-hand, do not trust an unconditional `status=0`.
3. **cond-3 `thr_acts@0x20` rider `.d` (NON-BLOCKING):** add a watchpoint on `ipc_pset_move`'s no-set→set branch capturing `thr_acts@port+0x20` (the op-164 offset; cross-check `waiting@port+0x28`). Three-condition predicate: `nset!=NULL` (cond-1) + `ip_pset==NULL` (cond-2, `port+0x80`) + `thr_acts!=NULL` (cond-3, `port+0x20`). A fire = cond-3 OBSERVED on the live workload = the full A.4 precondition (op-159 closed cond-1/2; this would close cond-3). This rider NEVER gates the soak pass/fail — a no-fire is fine (the fix may simply prevent the strand). It is opportunistic capture only.

GATES (id-011 / overclaim discipline — Arranger will check first-hand):
- Image provenance: the booted kernel/module MUST be the op-156-patched `mach.ko` (cite the SHA / symbol). A soak on a stale pre-fix kernel proves nothing about the fix.
- Workload fidelity: REAL notifyd register/post/check/cancel churn (op-129/131 driver), NOT synthetic C churn.
- Oracle ASSERTS, not just traces; `tick-Ns` synced to the full duration; bs_probe present (absent = setup FAIL, not paper-green).
- A clean soak is the REGRESSION confirmation of op-156 (validates, does not independently re-prove id-025 — the bug was always a rare race). A freeze recurrence RE-OPENS id-025 (and the captured stacks/oracle become the long-sought freeze-window evidence).
- This is an hours-scale soak → **overnight batch**, not interactive (long-ops-batch directive).

MARKERS:
```
OP165_IMAGE_PROVENANCE status=0   # booted mach.ko carries ipc_pset_port_changed (op-156 fix); SHA/symbol cited
OP165_SOAK_RAN status=0           # real notifyd churn, hours-scale, SOAK_DURATION-synced oracle
OP165_NOHANG status=0             # no 0%CPU/IC freeze across the full soak (the id-025 bar)
OP165_INVARIANTS status=0         # port-slope flat + kmsg/mqueue balance + dead-name balance (asserted, not traced)
OP165_COND3_RIDER recorded        # thr_acts@0x20 3-condition watchpoint: fire(cond-3 OBSERVED)=N | no-fire (NON-BLOCKING)
OP165_VERDICT status=0            # LEG4-GREEN (fix holds, notify truly-green) | FREEZE-RECURRED (re-open id-025, stacks captured)
OP165_TERMINAL status=0
```

PUSH: gatekeeper branch (soak log + oracle slope + cond-3 rider capture + verdict). Report → **Arranger-seat first-hand verify** the image provenance (patched mach.ko booted) + the no-hang/invariant bars from the RAW slope (not the summary) + any cond-3 fire before it counts toward notify truly-green or id-025 confirmation.
- If **LEG4-GREEN**: notify's 4th leg closes → **notify truly-green** (id-010 retires) → li-002 notify rung solid; id-025's fix is regression-confirmed (cond-3 either observed via the rider = full A.4 precondition closed, or simply prevented = fix holds).
- If **FREEZE-RECURRED**: id-025 re-opens with — finally — freeze-window stacks; op-156 fix is insufficient → new Implementer op.

CHAIN: id-025 closed (op-156 merged) + id-010 legs 1-3 green (op-123) + harness hardened (op-131) → **op-165 (notify leg-4 soak, this)** → notify truly-green (id-010 retires) + id-025 regression-confirmed. Sequencing vs op-163 (asl leg-4) on the shared soak host = Coordinator's call (both overnight-batch; op-165 confirms the just-merged id-025 fix, a possible priority).
