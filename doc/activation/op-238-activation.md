# op-238 — Validator: settle op-235's churn result — does our libdispatch port RETAIN the target queue across `dispatch_group_async_f`/`dispatch_async_f` submission? (harness-bug vs product-divergence disambiguator)

op-238 | role: **Validator (DS4P)** (falsification-primary source read) | EXU: **DS4P validator seat — reads wip-gpt/wip-rmxos libdispatch source (read-only) + rmx-gatekeeper `build/op235/op235-substrate.c` @ db9a65c** | state: **[Done — verdict (b) SUBSEQUENTLY REFUTED by op-240's DTrace, 2026-07-02]** — this op's 9/10 "product divergence" mechanism did NOT survive empirical confirmation (see REFUTATION block below). The `dq_running>dq_width` serial strand it hypothesized never fired (`OP240_SERIAL_OVERRUN=0`); op-235's churn low-count is a **harness measurement artifact**. Cited lines were real; the causal mechanism was wrong. | parent: op-235 (churn INCONCLUSIVE) → op-231 D3 layer 1 | L1i: li-1002 (libdispatch hardening) / li-9001 | cost: 4 (DS4P) | authored 2026-07-02 (Arranger seat, model Opus 4)

## REFUTATION (op-240 DTrace confirm, Arranger-verified first-hand on 3 artifacts 2026-07-02)
This op's verdict (b) was **code-reasoned at 9/10, not trace-confirmed** — and op-240 (the Implementer servicing op) was gated to confirm the mechanism via DTrace BEFORE any product fix. That gate caught the error:
- **`OP240_SERIAL_OVERRUN` count = 0** across all runs (`build/op240-twq-serial/…dtrace.serial.log`) → the `dq_running > dq_width` guard this op hypothesized (item 2 below) **never fired**.
- **`group_leave=500` on EVERY run** (incl. `completed=576`) → the serial half always completes 500/500 and never strands work.
- **Root cause is the harness, not the port:** `op235-substrate.c` groups only the serial half (`dispatch_group_async_f(g,sq,…)` :102) while the global half (`dispatch_async_f(gq,…)` :103) is **ungrouped** — `dispatch_group_wait(g)` :109 returns after only 500 of the `expected=iters*2=1000` (:114) callbacks, and `completed` counts both. The 517/576/1000 variance is timing on the ungrouped half, NOT dropped work.

**Both this op's decisive line citations were correct** (`queue.c:3199` retain, `queue.c:3545` drain guard both exist at source) — but a verified-line ≠ a verified-mechanism. The retain-on-submission finding (item 1) stands as good source work; the strand-mechanism inference (items 2–3) is refuted. **Do not re-open the product investigation on this basis.** Corrected next-hop: op-239 (Gatekeeper) fixes the harness (group the global half) + re-runs churn.

## VERDICT (DS4P 9/10 — SUPERSEDED: item 1 stands, items 2–3 REFUTED by op-240; see REFUTATION block above)
**(b) product divergence — the churn harness is Apple-conformant; the twq engine drops the work.** ← *the "engine drops the work" half of this verdict is REFUTED; the harness-conformance half (item 1) stands but was not the whole story — the harness under-groups the work (op-240).*
1. **Submission retains the target queue: YES** — first item on an empty queue takes the slow path and retains: `queue.c:3199` `if (!retained) _dispatch_retain(dq);` (guarded by the `<rdar://6932776>` comment at :3193-3198; **Arranger-confirmed at source**). Released when `dq_running→0` at `queue.c:2358`. So `dispatch_release(sq)` right after `dispatch_group_async_f` is correct — the submission ref holds the serial queue alive through drain. **Harness-bug label rejected, confirmed.**
2. **Drain overcommit guard strands work** — `_dispatch_queue_drain` at `queue.c:3545` `if (dq->dq_running > dq->dq_width) goto out;` (**Arranger-confirmed at source**; serial-queue `dq_width == 1` special-case at :3552). If the twq handoff spawns a second worker while the first is still draining a serial queue, `dq_running` → 2 > `dq_width` 1 → the draining worker bails at the guard; if the handoff doesn't guarantee the other worker resumes the drain, items in `dq_items_tail` are stranded → the **517/1000** signature.
3. **Smallest falsifiable requirement (→ op-240 Implementer):** the twq handoff (`twq_pick_bucket_locked`, `thr_workq.c`, via `_dispatch_queue_wakeup_global_slow` → `_pthread_workqueue_addthreads`) must not permit `dq_running > dq_width` on a serial queue mid-drain — either keep the SAME worker draining (the removed `twq_pick_pending_bucket_locked` behavior) or ensure the spawn path does not create a new worker for a serial queue that already has an active drain. `twq_addthreads_common` (`thr_workq.c:1090-1155`) uses `grant = MIN(admitted,pending)` (the `5675145` fix) — if that grant still permits a spawn for a serial queue with `dq_running == 1`, the guard fires and work is lost.

## RECONCILIATION (measured — this does NOT invalidate prior greens)
- **op-233 (5675145 grant mechanics, 9/10) stands** — the grant clamp fixes the concurrent-fan-out overcount (#19 KWQ abort); that is orthogonal to and NOT contradicted by the serial-queue handoff side-effect found here.
- **op-235 fan_out + chain PASS stand** — both run on CONCURRENT global queues (`dq_width > 1`), which never hit the `dq_width == 1` serial guard. Consistent, not contradictory.
- **op-182 cert stands** — it asserts fix-present + build-clean + boot, not serial-queue drain liveness. This is a **newly-surfaced substrate defect on the certified build**, not a cert error. `5675145` correctly fixed #19 AND its handoff change introduced a distinct serial-queue-drain regression.
- **Note:** the mechanism is code-reasoned (well-cited, 9/10), not yet DTrace-traced live — op-240 confirms the `dq_running==2` strand with a targeted trace on the churn workload before/while fixing.

## CONTEXT (read first)
Open-source OS engineering — a focused read-only source-semantics question on our own libdispatch port. Not security work; no product write, no test authoring. Returns a finding + confidence 1-10.

## WHY (one line)
op-235 ran three dispatch stress shapes on the twq engine: fan_out + chain PASS (Arranger-accepted; `5675145` holds), but **churn dropped work** (Run 1 = 517/1000 completed, Run 2 = 1000/1000). The Gatekeeper labeled churn a **harness bug** (premature `dispatch_release(sq)` before `dispatch_group_wait`) and declared it "not a product defect." The Arranger does **not** accept that label: the harness usage is the **canonical Apple idiom** — `dispatch_async`/`dispatch_group_async` retain the target queue for the enqueued block's lifetime, so releasing the caller's ref immediately after submit is correct and drops NO work on a conformant engine. Dropped work is therefore equally consistent with **our port failing to retain the serial queue across the twq handoff `5675145` touched** — a candidate product divergence. This op settles which it is, at source.

## THE HARNESS PATTERN UNDER TEST (rmx-gatekeeper `build/op235/op235-substrate.c`, `run_churn`)
```
sq = dispatch_queue_create(label, NULL);        /* :100  sq refcount = 1 (caller) */
dispatch_group_async_f(g, sq, NULL, churn_work);/* :102  submit to serial queue    */
dispatch_async_f(gq, NULL, churn_work);         /* :103  hop work to global root    */
dispatch_release(sq);                           /* :104  drop caller ref            */
...
dispatch_group_wait(g, DISPATCH_TIME_FOREVER);  /* :109  wait for all sq work        */
```
On Apple semantics `sq` survives until its enqueued block runs (submission took +1). If our port drops the block when the caller releases at :104, work is lost — exactly the 517/1000 signature.

## SCOPE (read-only; do NOT write product/tests/harness)
1. **Read our port's `dispatch_group_async_f` and `dispatch_async_f`** (wip-gpt/wip-rmxos libdispatch `src/queue.c` + the group path): does the submission path **retain the target queue** (`_dispatch_retain`/`os_obj_retain` on `dq`) for the enqueued item's lifetime, released only after the item is invoked/completed? Cite the exact lines.
2. **Trace the serial-queue drain on the twq engine:** when a serial queue targeting the global root has pending work and its external refcount hits 0, does the twq servicing path (`twq_pick_bucket_locked` / `_dispatch_queue_wakeup_global_slow` :3339-3424) hold the queue alive through drain, or can it free mid-drain? This is where `5675145` changed handoff — check whether the retain/release balance is correct on THIS path specifically.
3. **Adjudicate:** (a) **harness bug** — only if our port does NOT retain on submission (i.e. our documented contract requires the caller to hold the ref until completion, a deliberate divergence) → then op-235's churn harness is genuinely mis-coded AND the divergence itself is a li-1008 catalog item; or (b) **product divergence/defect** — if our port DOES retain (Apple-conformant) yet work still drops, the twq handoff frees the queue mid-drain → smallest falsifiable requirement for an Implementer servicing op. State which, with line citations.

## NON-SCOPE
- Does NOT re-run churn or any cell (that is the reserved op-239 Gatekeeper re-run, gated on this finding).
- Does NOT edit the harness, product source, or author tests.
- Does NOT re-decide fan_out/chain (Arranger-accepted PASS on twq).

## DELIVERABLE
A source-cited finding: **retained-on-submission? yes/no**, the twq drain-liveness verdict, and the harness-bug-vs-product-divergence adjudication (a/b) with exact lines — plus a **confidence 1-10**. Per Rule 11: at ≥9 the Arranger acts on this word (light provenance check); at <9 the Arranger steps in on the disputed line. If (b) product-divergence, this finding IS the requirement text for the Implementer servicing op.

## BOUNDARIES
- Read-only toward product source and the Gatekeeper harness (Validator falsification craft).
- First-hand or say-so-plainly (Rule 1); cite lines, do not assert from function names.
- `verify_signature_divergence_claims` — this op EXISTS because a divergence root-cause claim ("harness bug, not product") was asserted without a source check; do not repeat the pattern in reverse (do not assert "product defect" without the retain-path lines).
- Stage any notes only in the DS4P seat's own scratch (agent_host_isolation).

## RELATIONS
op-235 (the churn result being disambiguated) → op-231 D3 layer 1; `5675145df333` (the handoff fix) / op-233 [Done 9/10] (verified its mechanics); op-239 **[Reserved — Gatekeeper churn re-run, Held on this finding]** (fixed + retain-probe harness variants, cells 1&3, macOS-27 self-check). li-1002 (libdispatch hardening); li-1008 (catalog, if a deliberate contract divergence); li-1013 Item 1 / op-225 C2 (pool-arm evidence still unfed — op-239 supplies it). feedback: verify_signature_divergence_claims, no_conflate_gating_with_readiness, workload_class_needs_source_read, build_is_implementer (this op does not fix — it scopes the fix), op_state_dispatch_boundary (authored [Awaiting]).
