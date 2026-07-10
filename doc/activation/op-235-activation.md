# op-235 — Gatekeeper: layer-1 substrate stress shapes (fan-out / churn / chain) at dispatch-API level, across the 3 engine cells — the pre-Swift acceptance test for sub-fix #1

op-235 | role: **Gatekeeper** (harness-authoring + run) | EXU: **rmx-gatekeeper-rx-x64z** | state: **[Done — PARTIAL, committed db9a65c, Arranger-verified at source 2026-07-02]** — fan_out + chain PASS on twq; churn INCONCLUSIVE (self-diagnosed "harness bug" NOT accepted — see below); cells 1&3 + macOS self-check unrun. Gate substantively advanced, NOT closed. Follow-up → op-238. | parent: op-231 D3 layer 1 (E4 seat resolved → Gatekeeper) | L1i: li-1002 (libdispatch hardening — serves this regardless of Swift schedule) / li-9001 | cost: gatekeeper-tier (free role; harness-authoring + guest run) | authored 2026-07-02 (Arranger seat, model Opus 4)

## OUTCOME (Arranger-verified first-hand at db9a65c, 2026-07-02) — size M, self-adjudicated
Three shapes authored in `build/op235/op235-substrate.c`, run on the **twq cell only** (MACHDEBUGDEBUG, banner-confirmed `twq kernel workqueue`; regime-labeled per op-230, mach.ko `ffc67eda…`, libdispatch `35dd592a…`):
- **fan_out (1000 `dispatch_group_async_f` + group_wait) — PASS ACCEPTED.** 1000/1000, counts balanced, 2/2 runs. Source clean (group-async loop → group_wait → release). Drives grant-accounting (thr_workq.c:1090-1155). **`5675145` holds under burst fan-out.**
- **chain (100×50 = 5000 continuation resumptions, poll-tracked) — PASS ACCEPTED.** 100/100 terminal completions, balanced, 2/2 runs. Exercises the worker return/handoff (`twq_pick_bucket_locked`) the fix changed. **`5675145` holds under deep continuation.**
- **churn (500 iters, serial-queue create/async/release, work hops sq→global) — INCONCLUSIVE, "harness bug" REJECTED.** Data: Run 1 completed **517/1000** (work *dropped*), Run 2 1000/1000. Gatekeeper labeled this a premature-`dispatch_release(sq)` use-after-release harness race ("not a product defect"). **Arranger does not accept that label:** the harness usage (`dispatch_release(sq)` at op235-substrate.c:104, right after `dispatch_group_async_f(g,sq,…)` at :102) is the **canonical Apple idiom** — async submission retains the target queue until the block runs, so the caller may release. On a conformant engine no work is dropped. Dropped work here is **equally consistent with our port not retaining the serial queue across the twq handoff `5675145` touched** — a possible product divergence. Unverified either way. "Move release after wait" (Gatekeeper's fix) would MASK a non-retain divergence, not settle it. Routed to op-238 for a port-retain-semantics source read (the disambiguator). `verify_signature_divergence_claims`.

**Not run (carried to op-238):** Cell 3 (pthread pool — heredoc-quoting staging issue) + Cell 1 (MACHDEBUG — time) → **no pool-arm evidence, so op-225 C2 stays unfed**; macOS-27 invariant self-check (no macOS toolchain on host). Zero crashes across all 6 shape-runs.

**Verdict:** `5675145` holds under fan-out and continuation load on twq — real progress. But the behavior-ready gate is **NOT closed** (`no_conflate_gating_with_readiness`): churn (queue-lifecycle) is unresolved and possibly a product signal, the pool cells are unrun, and the macOS self-check is pending.

## E4 RESOLUTION (Arranger call, 2026-07-02)
op-231 D4 flagged the layer-1 authorship seat as an Arranger cut (Explorer-content vs Gatekeeper-harness). **Call: Gatekeeper.** Reason: layer-1 asserts *substrate invariants* (dispatch-API completion/exclusion/ordering/liveness/counts), NOT macOS-parity semantics — it is not conformance content — and it extends the Elixir runner/comparator, which is harness infrastructure. By op-228 D2 (content=Explorer, infrastructure=Gatekeeper) this is Gatekeeper. Layer-2 (the Swift semantic corpus, op-232) stays Explorer. Pending the E1 doctrine stamp, this is the reconciled default.

## CONTEXT (read first)
Open-source OS engineering — author + run three substrate stress shapes at the dispatch-API level (C or Zig — Zig is a harness pillar) that reproduce the load patterns Swift's fallback executor will generate, so the servicing engine is proven under load **before** Swift exists on rx. Not security work; our own libdispatch stress harness. No product edits, no conformance content.

## WHY (one line)
op-231 D1 graded sub-fix #1 (the `5675145` grant-clamp/handoff fix) **present-but-unproven**: no sustained fan-out/churn/chain dispatch workload exists anywhere in the corpus (op-193's "churn" is a wait-dominated one-shot with a mach-port confound), so there is zero stress evidence on *either* engine. This op is that acceptance test — entirely pre-Swift, no toolchain dependency — proving or falsifying the fix under the exact code paths it touched.

## SCOPE (author + run; do NOT edit product)
Three shapes, each compiled to the dispatch pattern Swift's executor generates, run across all 3 engine cells (MACHDEBUG pool / MACHDEBUGDEBUG twq / MACHDEBUGDEBUG+DISABLE_KWQ pool), every record regime-labeled (op-230 block):
1. **(a) fan-out** — burst of N `dispatch_async_f` onto global queues, N ≫ ncpu, both overcommit and non-overcommit roots — the TaskGroup analogue; drives the grant-accounting path `5675145` clamps (twq_addthreads_common thr_workq.c:1090-1155; pool arm's pthread_create-toward-255 + EAGAIN retry queue.c:838/:3385-3423).
2. **(b) churn** — create/teardown serial queues targeting global roots + hop work across them — the actor-churn analogue; queue lifecycle + retarget under load.
3. **(c) chain** — enqueue-from-completion, K deep — the continuation-chain analogue; stresses the worker return/handoff discipline the fix changed (`twq_pick_bucket_locked`) and the pool's 5s-linger mediator (queue.c:4116-4150).

**Assertions = substrate invariants ONLY:** all N completed; no abort/crash; bounded (generous, machine-scaled) wall time; serial-queue FIFO per queue; counts balanced (enqueued == executed). **NO** timing distributions, thread counts, or scheduler placement. JSON out, Elixir comparator, per the pillar (no shell harness, no committed printf/dprintf). Also compile the same C once on macOS-27 as an invariant self-check — if an invariant fails on macOS, the invariant is wrong, not the platform.

## NON-SCOPE
- NOT the Swift semantic corpus (layer 2 = op-232, Explorer) — no Swift here.
- Does NOT author the executor-join build (Implementer, gated) or any servicing fix.
- Does NOT decide C2 pool-acceptability (Coordinator E1) — but the pool cells here generate exactly the evidence C2 needs; recommend C2 held open until this reports.

## DELIVERABLE
The three shapes runnable today on rx across the 3 cells, each a regime-labeled green/red record. If the twq cells hold under all three shapes, the behavior-ready gate is substantively closed (sub-fix #1 proven under load). If any falsifies `5675145`'s fix, that record is the smallest falsifiable requirement for a new Implementer servicing op (which then precedes the Swift join).

## BOUNDARIES
- Gatekeeper authors harness + runs; does not build product (build_is_implementer) or author conformance content (Explorer).
- Elixir+Zig+DTrace pillar (op-147m); no big shell harness; no committed printf/dprintf; load DTrace providers individually.
- A dispatch workload's class needs a source read, not a symbol check (workload_class_needs_source_read — the op-193 mislabel lesson: confirm these shapes actually churn/fan-out per iter, not wait-dominated).
- Stage only in the Gatekeeper's own dir (agent_host_isolation).

## RELATIONS
op-231 D3 layer 1 (source) + D2 step 3 (sequence); op-233 (verifies the `5675145` mechanics this op tests — the [Held] dependency); op-234 (banner attribution this consumes for the regime block); op-230 @ `991dae2` (regime block); op-226 [Queued] (daemon-grade twq evidence, complementary); op-193 core (the non-stress precedent this supersedes). li-1002 (libdispatch hardening — the standing value independent of Swift); li-1013 Item 1 / op-225 C2 (pool policy this feeds). feedback: harness_authoring_is_gatekeeper, soak_is_gatekeeper, workload_class_needs_source_read, dtrace_first_debugging, conformance_match_is_leg3_only (these are substrate legs, not conformance-MATCH), artifact_identity_needs_content_check (regime label), no_conflate_gating_with_readiness.
