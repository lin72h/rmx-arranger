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

---

## ARRANGER-SEAT VERDICT (2026-06-26, model Opus 4) — NECESSARY-condition reachability PROVEN; full A.4 precondition NOT yet, but closable from data ALREADY IN HAND

Verified first-hand against `rmx-gatekeeper @ dfb3b04` — `findings/op159-reachability-proven.txt` + `op159-precondition-watchpoint.d`, read directly (not the relayed report). id-011/overclaim history + my own pre-set bar required it.

**CREDITED (genuinely shown):**
- 2 fires on `ipc_pset_move`'s no-set→set branch, port `0xfffff80003447340`, `curproc=notifyd pid=968`, real syscall stack `mach_port_move_member+0x13b ← sys__kernelrpc_mach_port_move_member_trap ← amd64_syscall`. The bug's **necessary condition is reachable on the live notifyd register/post/check/cancel workload**.
- `ip_pset@0x80` provenance credible — mach.ko disassembly (`movq 0x80(%rax)` compared against `nset` in `ipc_pset_move`), not a guess. Predicate `arg2!=0 && *(uint64_t*)(arg1+0x80)==0` = conditions 1+2.
- Methodological win: ~5900 churn iters vs op-150's ~400 → **op-150's ~6-8min fast-onset was a C-probe confound, NOT real id-025 acceleration** → confirms the ~60-100min stochastic window + corroborates the op-155 wall-clock-under-run caveat. precondition-detection-during-healthy-churn works (fires BEFORE freeze), unlike op-148's freeze-catcher that starves at the wedge.

**LABEL HELD (the overclaim):** "REACHABILITY PROVEN" unqualified overclaims. The `.d`'s OWN comment is honest — "reachability of the bug's **NECESSARY** condition is PROVEN (weaker than the full three-condition precondition)"; the report title dropped the qualifier. Per the pre-set bar: this is necessary-condition reachable, NOT the full A.4 precondition. `OP159_PRECONDITION_FIRED` = PASS **for the necessary condition ONLY**; `cause_evidenced=0`; `HANG_CORRELATED n/a`. The A.4-SPECIFIC part (a direct receiver parked AT the transition = condition 3) is what makes the freeze A.4 vs some other deadlock — and that is not yet confirmed.

**CLOSABLE NOW, NO RE-SOAK — the captured port-struct dumps already hold the answer:**
- fire=1: `off98 = fffff80003c9f200` (**non-NULL**)
- fire=2: `off98 = 0` (NULL)
- `off98` is the gatekeeper's `thr_acts` (parked-receiver, `rcd_thread_pool.thr_acts`) CANDIDATE. **If `off98` is confirmed = `thr_acts`, then fire=1 captured a parked receiver at a no-set→set transition = the FULL 3-condition A.4 precondition, from data ALREADY IN HAND.** This needs only an OFFSET-IDENTIFICATION (same disassembly method that nailed `ip_pset@0x80`, applied to the receive / `thread_pool_put_act` enqueue path, ipc_mqueue.c:813) + a semantics check (non-NULL `thr_acts` head = a parked act). NO new soak.

**RESIDUAL (minor):** the base/pre-fix-kernel claim rests on the `OP159_BASE_KERNEL_SOAK` marker + serial sha `5aa7b2d8…`, NOT on the fire data — branch-ENTRY is pre/post-fix agnostic (op-156 changes post-branch routing, not whether the branch is entered). Cross-check the serial/boot record if the merge leans on it.

**MERGE DISPOSITION — Coordinator's call, two framings:**
- (A) **merge-now**: necessary-condition reachable (this) + the leg-4 freeze independently observed historically (the deadlock is why id-025 exists) + fix sound/covered/falsified (op-156/157/158) + op-156 is a low-risk defensive fix → sufficient; accept fire=1's non-NULL `off98` as strong-but-uncertified corroboration.
- (B) **close cond-3 first (CHEAP, recommended)**: confirm `off98 = thr_acts` from disassembly → fire=1 retroactively becomes the FULL A.4 precondition from existing data → airtight, overclaim risk eliminated → then merge. Falls back to (A) if the offset can't be landed quickly.

Recommend **(B)** — it converts a strong suggestion to proof at the cost of an offset-ID on data already captured, not a new run.

**MARKER DISPOSITION (mine):** WATCHPOINT_AUTHORED PASS · BASE_KERNEL_SOAK PASS(marker/serial-attested) · PRECONDITION_FIRED **PASS-NECESSARY-ONLY** (not full A.4) · HANG_CORRELATED n/a · VERDICT **NECESSARY-CONDITION REACHABILITY PROVEN; full precondition pending `thr_acts` offset (off98 candidate, fire=1 data in hand)** · TERMINAL PASS.

**op-159 → stays [In-flight]** for the cheap cond-3 close (identify `thr_acts` offset, re-interpret fire=1) — NOT [Done]. id-025 stays OPEN; op-156 merge pends the Coordinator's (A)-vs-(B) decision. Do NOT merge off the unqualified "PROVEN" label.
