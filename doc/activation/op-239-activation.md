---
id: op-239
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-239 — Gatekeeper: correct the op-235 churn harness measurement bug (group the global half), then re-run churn across all 3 engine cells + macOS-27 self-check — the corrected layer-1 acceptance re-run for sub-fix #1

op-239 | role: **Gatekeeper** (harness-fix + re-run) | EXU: **rmx-gatekeeper-rx-x64z** | state: **[Done — CHURN LEG CLOSED, committed f7f50a8, Arranger-verified first-hand 2026-07-02]** — harness fix confirmed at source (:103 now grouped) + result logs confirmed: twq 1000/1000 ×2, pool 1000/1000 ×2, banner-labeled. Layer-1 substrate gate for sub-fix #1 CLOSED (fan_out+chain+churn all PASS on twq). See OUTCOME. | parent: op-240 (premise refuted — churn low-count is a harness artifact) → op-238 (verdict (b) refuted) → op-235 churn INCONCLUSIVE → op-231 D3 layer 1 | L1i: li-1002 (libdispatch hardening) / li-1013 Item 2 (RESOLVED) / li-1013 Item 1 / op-225 C2 (pool-arm evidence — churn arm supplied via cell 3) | cost: gatekeeper-tier (free role; harness edit + guest runs) | authored 2026-07-02 (Arranger seat, model Opus 4)

## OUTCOME (Arranger-verified first-hand at f7f50a8, 2026-07-02)
The 1-line harness fix (op-240's diagnosis) is correct at source: `op235-substrate.c:103` `dispatch_async_f(gq,…)` → `dispatch_group_async_f(g, gq, NULL, churn_work)` — the global half is now grouped, so `dispatch_group_wait` covers all `expected=iters*2` dispatched work. No count-masking, no product change. Result log (`findings/op239-churn-fix-result.txt`) confirmed first-hand:
- **Cell 2 (twq kernel, banner-confirmed):** churn 1000/1000, counts_balanced, 2/2 runs, zero crashes. **PASS.**
- **Cell 3 (pthread pool, DISABLE_KWQ, banner-confirmed):** churn 1000/1000, counts_balanced, 2/2 runs, zero crashes. **PASS.** — this is the **op-225 C2 pool-arm evidence for the churn shape**, previously unfed.
- **Cell 1 (MACHDEBUG native):** INCONCLUSIVE — dispatch binary couldn't init on the MACHDEBUG kernel (same mach.ko/MACHDEBUG KBI issue as op-234 cell 1). Not blocking: cells 2+3 cover both engine paths; MACHDEBUG is NOT the ship conf.
- **macOS-27 self-check:** carried honestly (no macOS toolchain on the FreeBSD-15 host).

**Verdict: churn leg CLOSED.** With op-235's fan_out + chain PASS (both on twq), **the layer-1 substrate gate for sub-fix #1 (`5675145` grant-clamp/handoff fix) is closed on the twq ship engine.** `5675145` holds under fan-out, deep continuation, AND queue-churn load.

**Two honesty notes (not gate-blocking):**
1. fan_out/chain were accepted on **twq only** (op-235); they were never run on the pool engine — the combined gate table's "accepted from op-235" for the pool column overstates. Immaterial to the gate: twq is the MACHDEBUGDEBUG ship engine and carries all 3 shapes; churn additionally confirmed on pool.
2. **Cell 1 (MACHDEBUG) is dark twice now** (op-234, op-239) on a mach.ko/MACHDEBUG KBI mismatch — the "weaker regime" pool arm can't run the dispatch binary. Low-impact (cell 3 supplies pool evidence; MACHDEBUG isn't shipped), but it means the 3-cell regime design effectively has only 2 live cells. Candidate for a lightweight id if the Coordinator wants MACHDEBUG-cell evidence to exist.

## CONTEXT (read first)
Open-source OS engineering — our own libdispatch stress harness. op-235 authored three dispatch-API stress shapes (fan_out/chain/churn) to prove `5675145`'s grant-clamp/handoff fix under load. fan_out + chain PASS on the twq cell (Arranger-accepted). churn returned a low, variable count (517/576/1000) that walked through two wrong root-causes before op-240's DTrace settled it: **the churn harness under-groups its own work** — it is a measurement artifact, not dropped work and not a product defect. This op fixes that harness bug and completes the churn leg + the cells/self-check op-235 left unrun. Not security work; no product edits.

## WHY (one line)
op-240 (Implementer, DTrace-confirm gate) refuted op-238's `dq_running>dq_width` product-divergence verdict first-hand: `OP240_SERIAL_OVERRUN=0` (drain guard never fired) and `group_leave=500` on every run (serial half never strands). The real cause is in `op235-substrate.c` `run_churn`: only the serial half is grouped — `dispatch_group_async_f(g, sq, …)` (:102) — while the global half `dispatch_async_f(gq, …)` (:103) is **ungrouped**, so `dispatch_group_wait(g)` (:109) returns after only 500 of the `expected = iters*2 = 1000` (:114) callbacks while `completed` counts BOTH halves → the [500,1000] timing variance. The harness must wait for ALL the work it counts.

## SCOPE (harness-fix + re-run; do NOT edit product)
1. **Fix the churn harness measurement bug** in `build/op235/op235-substrate.c` `run_churn`. Make the count and the wait cover the same set: either (a) group the global half too — `dispatch_group_async_f(g, gq, NULL, churn_work)` at :103 so `dispatch_group_wait` covers all `iters*2` — or (b) keep the global half on `dispatch_async_f` but add an explicit completion wait for it before reading `completed`. Prefer (a) (minimal, symmetric, matches the fan_out shape's own idiom). Keep `expected = iters*2` honest to whatever you group. Do NOT change the product; do NOT mask by moving the count.
2. **Re-run churn on all 3 engine cells**, every record regime-labeled (op-230 block): Cell 2 MACHDEBUGDEBUG twq (banner-confirmed), Cell 1 MACHDEBUG pool, Cell 3 MACHDEBUGDEBUG+LIBDISPATCH_DISABLE_KWQ=1 pool. Acceptance: churn completes `iters*2`/`iters*2` across ≥2 runs per cell, counts balanced, no crash, bounded wall time, serial-queue FIFO per queue. Cells 1&3 also finally supply the **pool-arm evidence op-225 C2 has been waiting on** (op-235 left them unrun on a heredoc-quoting staging issue — fix the staging).
3. **macOS-27 invariant self-check** — compile + run the same corrected C once on macOS-27 (the op-235 carried item): if a substrate invariant fails on macOS, the invariant is wrong, not the platform. (If no macOS toolchain is reachable from the Gatekeeper host, say so plainly and carry it — do not fabricate.)

## NON-SCOPE
- Does NOT re-open the product investigation — op-240 refuted the defect at trace; the harness fix is the whole residual UNLESS the corrected harness STILL drops work (then that record is a fresh, cleaner falsifiable signal → new Validator/Implementer op, not this one).
- Does NOT re-decide fan_out/chain (Arranger-accepted PASS on twq) or re-run them unless a cell needs them for the regime block.
- Does NOT edit product source (`build_is_implementer`) or author conformance content (Explorer).
- Does NOT decide C2 pool-acceptability (Coordinator, li-1013 Item 1) — but the pool cells here generate exactly the evidence C2 needs.

## DELIVERABLE
The corrected churn shape re-run across the 3 cells as regime-labeled green/red records (each naming: kernel ident, mach.ko flags, libdispatch flags, per-run engine evidence per li-1013 Item 1 M1), plus the macOS-27 self-check (or an honest carry). If churn now completes `iters*2`/`iters*2` on the twq cell, the churn leg is closed and — with fan_out/chain already PASS — the layer-1 substrate gate for sub-fix #1 is substantively closed. Commit the harness fix. If the corrected harness still drops work on ANY cell, that record is the smallest falsifiable requirement for a re-opened product investigation (report it, do not fix product yourself).

## BOUNDARIES
- Gatekeeper authors/fixes harness + runs; does not build product (`build_is_implementer`) or author conformance content (Explorer).
- Elixir+Zig+DTrace pillar (op-147m); no big shell harness; no committed printf/dprintf; load DTrace providers individually.
- `workload_class_needs_source_read` — confirm the corrected shape actually churns per iter and that the group now covers everything counted (the exact defect this op fixes).
- `no_conflate_gating_with_readiness` — a green churn leg advances the gate; it does not by itself declare behavior-ready.
- Stage only in the Gatekeeper's own dir (`agent_host_isolation`).

## RELATIONS
op-240 (refuted the product hypothesis — the reason this is a harness fix not a product re-run) → op-238 (verdict (b) refuted) → op-235 churn (the measurement bug this fixes) → op-231 D3 layer 1. op-233 [Done 9/10] (`5675145` mechanics — not in question). li-1002 (libdispatch hardening); li-1013 Item 2 (RESOLVED — this op closes its residual); li-1013 Item 1 / op-225 C2 (pool-arm evidence this finally supplies); op-230 @ `991dae2` (regime block). feedback: harness_authoring_is_gatekeeper, soak_is_gatekeeper, workload_class_needs_source_read, dtrace_first_debugging, build_is_implementer, artifact_identity_needs_content_check (regime label), no_conflate_gating_with_readiness, verify-premise-before-mechanism (the DTrace gate on op-240 is why this op is scoped correctly), op_state_dispatch_boundary (authored [Awaiting]).
