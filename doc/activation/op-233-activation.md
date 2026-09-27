---
id: op-233
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-233 — Validator: full first-hand verification of the op-231 consult's technical spine + triage the untriaged op193-dispatch-chur.core — attach a confidence 1-10

op-233 | role: **Validator (DS4P)** (falsification-primary) | EXU: **DS4P validator seat — reads rmx-oracle/op-231-swift-dispatch-join-review.md (consult) + wip-gpt/wip-rmxos (source, read-only)** | state: **[Done — confidence 9/10, status=0, 2026-07-02]** — spine CONFIRMED; per Rule 11 (≥9) op-231's technical spine retires on this word (light provenance check only). | parent: op-231 (the L-gate delegation) | L1i: li-9001 / li-1002 | cost: 4 (DS4P) | authored 2026-07-02 (Arranger seat, model Opus 4)

## VERDICT (DS4P, 9/10, primary-access y, 2026-07-02)
All four SCOPE items confirmed first-hand:
1. **`5675145df333` diff mechanics CONFIRMED** — grant clamp `grant = MIN(admitted, pending)` at `thr_workq.c:+285`; `spawn_needed = grant - transfer_wake` at `+304`; `twq_pick_bucket_locked` handoff at `+923`; `twq_make_priority` token fix at `+441-443`. **Ancestor of `c14e0904` YES** (the op-182 cert source). Maps to sub-fix #1 / completion-debt #19 (KWQ abort class).
2. **Sub-fix #2 correctly separated** — `5675145` does NOT address #21 MACH_RECV; it touches `thr_workq.c` (+37/-14) + `notifyd.c` (-16, deletes the raw-pthread fallback). The plan's "pending-count underflow in src/queue.c" naming is **documentation drift, not a fix error** — the real accounting is `tbr_pending` at `thr_workq.c:1090-1155`. Sub-fix #2 remains open.
3. **`op193-dispatch-chur.core` UNRELATED to twq servicing** — host-side, PID 88037, Jun-29 01:07, 12MB, likely **pool engine** (not twq). Disposition: unrelated to the twq servicing gate. Definitive engine classification wants a live MACHDEBUGDEBUG cell-2 re-run (a later op, not gating).
4. **Servicing path CONFIRMED** — `queue.c:3339-3424`; sentinel `:3353`; twq arm `:3372/:3379`; pool arm `:3385-3423`; DISABLE_KWQ `:755`; banner `:899-900`; setdispatch `:782-785`.

## CONTEXT (read first)
Open-source OS engineering — verify the first-hand technical claims of the op-231 Oracle consult (the libdispatch↔Swift-concurrency behavior-ready gate). Not security work; source-read + core-triage verification of our own libdispatch/kernel tree. This op writes NO product and NO tests — it is a read/falsify gate that returns a confidence.

## WHY (one line)
Per Rule 11 the Arranger sized op-231's adjudication **L** (large cross-plane surface) and delegated the deep verification here. The Arranger already spot-checked the load-bearing spine (HEAD `106f9d7fd160`; `5675145`→`c14e0904` ancestry; `queue.c:755`/`:899-900`; THRWORKQ conf matrix; op-229/op-230) — all PASS. This op verifies the claims the Arranger did NOT check, so downstream ops (op-235 layer-1 stress, the Swift join) build on a confirmed premise, not on an Oracle assertion.

## SCOPE (verify first-hand; do NOT write product/tests)
1. **The `5675145df333` diff mechanics** — confirm the consult's read: grant clamp `grant = MIN((uint32_t)admitted, pending)`; `spawn_needed = grant - transfer_wake` (was `admitted - transfer_wake`, overcounting when `admitted > pending`); worker-return handoff switched to `twq_pick_bucket_locked`; `twq_make_priority` token fix. Read the diff + `thr_workq.c:1090-1155` (twq_addthreads_common accounting). Confirm the fix maps to sub-fix #1 / completion-debt #19 (the KWQ abort class).
2. **Sub-fix #2 separation** — confirm #21 (MACH_RECV source servicing) is NOT addressed by `5675145` (whose title "service Mach receive…" invites conflation). Confirm the plan-blocker→fix location mismatch (plan names "pending-count underflow in src/queue.c"; fix landed in `thr_workq.c`) — is the mapping plausible or wrong?
3. **Triage `op193-dispatch-chur.core`** (Jun-29, post-fix, in the gatekeeper/relevant dir) — first-hand: which binary, which kernel, which engine, which workload? Post-mortem analysis (readelf/lldb + source; dtrace_first_debugging where a live re-run is warranted). Adjudicate whether it counts for/against twq servicing or is unrelated. This is the standing contrary-evidence flag; verify_signature_divergence_claims applies — do not let it drift as an untriaged unknown.
4. **Spot-confirm the mechanical servicing path** the consult cites (dispatch_async_f → _dispatch_queue_wakeup_global_slow :3339-3424; twq arm :3372/:3379 vs pool arm :3385-3423; sentinel :3352-3354) matches source — a sampling check, not a full re-read (the Arranger confirmed the entry points).

## NON-SCOPE
- Does NOT re-decide E1-E5 (Coordinator-held doctrine/milestone calls).
- Does NOT run the op-227 banner validation (that is op-234, a guest run) or the layer-1 stress (op-235).
- Does NOT author conformance content or servicing fixes.

## DELIVERABLE
A verification verdict per SCOPE item 1-4 (confirmed / corrected / falsified, each source-cited) **and a single confidence 1-10** on the consult's technical spine as a foundation for downstream ops. Per Rule 11: at **≥9** the Arranger retires op-231's technical spine on this word (light provenance check only); at **<9** the Arranger steps in on the disputed point. The core-triage (item 3) returns a disposition: contrary-evidence / consistent / unrelated.

## BOUNDARIES
- Read-only toward source and toward the Oracle consult; Validator falsification craft (validator-rulebook).
- First-hand or say-so-plainly (Rule 1): if the core is macOS-/guest-bound to re-run, analyze the static artifact and defer the live piece with a named requirement.
- Stage any triage notes only in the DS4P seat's own scratch, not host-global (agent_host_isolation).

## RELATIONS
op-231 (the consult being verified — the L-gate delegation); op-227 (`106f9d7fd160` banner, its validation is op-234); op-226 [Queued] (first attributed twq evidence); `5675145df333` / `c14e0904` (the fix + cert source); li-9001 (Swift join gate). feedback: verify_signature_divergence_claims (the core-triage is the structural instance — explorers overclaimed 3×), dtrace_first_debugging, artifact_identity_needs_content_check (identify the core's binary/kernel by content, not filename), no_conflate_gating_with_readiness. Rule 11 (this op IS the delegation); Rule 6 (Arranger steps in <9).
