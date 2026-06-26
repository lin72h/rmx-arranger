# op-159 — Gatekeeper: deterministic reachability watchpoint for id-025 (precondition-fires detector on the real notifyd soak)

op-159 | role: **Gatekeeper** (FREE) | state: QUEUED (overnight batch — long soak; NOT interactive) | parent id: id-025 | authored 2026-06-26 (Arranger seat, model Opus 4)
purpose: close the SOLE remaining bar on the op-156 merge gate — reachability. The inspection legs (op-156 fix sound, op-157 coverage, op-158 falsification) are all verified. What inspection CANNOT prove: that notifyd's register/post/check/cancel churn actually hits the bug's precondition. This op proves it on the real workload, deterministically — complementary to op-155 (which catches the hung stack stochastically). EITHER closes reachability; together they are airtight.

THE PRECONDITION TO DETECT (the exact, verified bug setup):
`ipc_pset_move` takes the no-set→set branch (`oset==IPS_NULL && nset!=IPS_NULL`) on a port that ALREADY HAS a direct receiver parked in its own thread pool. That is the lost-wakeup trigger: a thread blocked in `ipc_mqueue_receive` on the bare port (enqueued via `thread_pool_put_act`, ipc_mqueue.c:813) at the instant the port is added to a set, after which `ipc_mqueue_deliver` routes only to the pset pool (ipc_mqueue.c:443-454) and the direct waiter is orphaned.

THE WATCHPOINT (fixed bar — fbt kernel-only, per harness pillar):
- `fbt::ipc_pset_move:entry` — args: port (arg1), nset (arg2). Predicate: `arg2 != NULL` (entering a set) AND `port->ip_pset == NULL` (oset is null = no-set→set) AND the port's own thread pool head is non-empty (`((struct rpc_common_data *)port)->rcd_thread_pool.thr_acts != NULL` = a direct receiver is parked RIGHT NOW).
- When all three hold → the precondition has FIRED on the live notifyd path → reachability PROVEN. Record: timestamp, port, curproc/curthread, churn-iteration, stack().
- Load the fbt provider individually (do NOT pull a blanket provider set). NO printf/dprintf added to source — this is a `.d` observation artifact only.

RUN PLAN:
- Run on the **BASE (pre-fix) kernel** — where the defect still exists — under the standard leg-4 notifyd register/post/check/cancel soak (the ~63min-onset workload from op-123 leg-4).
- TWO winning outcomes, either closes reachability:
  1. Watchpoint FIRES (precondition observed on real churn) → reachability PROVEN even before any hang.
  2. Watchpoint fires AND the soak then wedges (0%-CPU blocked-idle) with the same port → precondition + hang causally linked = the strongest possible corroboration of op-156.
- Negative result (full soak, no fire) is also signal: it would mean notifyd does NOT hit this precondition → op-156 is "a real bug but maybe not THE bug" → escalate to widen op-155's net and re-open the candidate field. Report it as a real negative, do not hand-wave.

DELIVERABLE / GATE: the `.d` watchpoint script (committed to the harness, fbt loaded individually) + the soak run log + the fire record (or a clean no-fire over the full leg-4 duration). Arranger-seat first-hand check of the fire record (port + parked-waiter + churn-iter) before it corroborates the merge.

MARKERS:
```
OP159_WATCHPOINT_AUTHORED status=0     # .d precondition detector committed (fbt::ipc_pset_move:entry, loaded individually)
OP159_BASE_KERNEL_SOAK status=0        # leg-4 notifyd churn run on pre-fix kernel; duration + iters logged
OP159_PRECONDITION_FIRED status=0      # fired (port/thread/iter/stack) | clean no-fire over full leg-4
OP159_HANG_CORRELATED status=0         # if wedged: same port as the fire? (strongest corroboration) | n/a
OP159_TERMINAL status=0
```

PUSH: harness branch (the `.d` + run log + fire record). Report → Arranger-seat first-hand verify the fire record → if PROVEN, joins the inspection legs → op-156 eligible to MERGE → id-025 closes → notify leg-4 / id-010 unblocks. Do NOT merge from this op.

CHAIN (id-025): op-156 (fix sound) + op-157 (coverage PASS) + op-158 (falsify PASS) [inspection CLOSED] → reachability: op-155 (stochastic capture) ∥ **op-159 (deterministic precondition watchpoint)** → either fires → merge → notify leg-4 / id-010 green.

---

## v2 NOTE + INTERPRETATION BAR (2026-06-26, Arranger seat, model Opus 4) — Gatekeeper ran a RAW-OFFSET .d with a 2-of-3 predicate; fixing the verdict bar before results land

Gatekeeper reports op-159 v2 running (bg `bydaqoa2d`): a raw-offset `.d` bypassing the struct-CTF limitation that killed v1. Predicate = `arg2 != 0 && *(uint64_t*)(arg1+0x80) == 0`. This is conditions **1 + 2 only**; condition **3 (parked direct receiver, `thr_acts != NULL`) is DROPPED** pending thr_acts offset identification (v2 dumps candidate offsets toward it).

**The bar this fixes IN ADVANCE (do not move post-hoc, either direction):**
- A v2 **fire = "notifyd reaches the no-set→set branch"** — NECESSARY, NOT SUFFICIENT. It does NOT prove the bug precondition, because condition 3 (a direct waiter parked AT THAT INSTANT) is exactly what turns a benign no-set→set move into the lost-wakeup. A bare 2-condition fire must be reported as *branch-reached, parked-waiter coincidence UNCONFIRMED* — NOT "reachability PROVEN." `OP159_PRECONDITION_FIRED` stays status=0 on a 2-condition fire alone.
- The **STRONG outcome is condition-3-independent**: a fire FOLLOWED by a wedge on the **SAME port** (`OP159_HANG_CORRELATED`) recovers sufficiency empirically — the causal link (no-set→set on port X → port X orphaned/0%-CPU) proves the parked-waiter coincidence happened without needing to read thr_acts. **Prioritize capturing the port identity on every fire** so the hang can be correlated to it.
- A full-soak **no-fire is still a real negative** (notifyd never hits no-set→set → op-156 not THE bug → escalate), unchanged.

**TWO things to verify first-hand before any fire record counts (Rule 1 / id-011 claim-history):**
1. **Offset 0x80 provenance** — is `ip_pset` actually at `+0x80` in this kernel's `struct ipc_port`? A wrong raw offset reads garbage and the predicate is meaningless. Gatekeeper must cite the derivation (CTF of a sibling type / pahole / source struct layout), not assert it.
2. **thr_acts from the candidate dump** — use v2's offset dump to land condition 3 in a **v3** = the real deterministic detector. v3 (3-condition) is what can set `OP159_PRECONDITION_FIRED`; v2 narrows + de-risks v3 but does not self-certify the gate.

Net: v2 is a legitimate CTF work-around and good signal (especially the fire+same-port-hang path), but it does NOT carry the deterministic-reachability claim on a bare fire. Let it run; verdict on the actual record, against this bar.
