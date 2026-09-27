---
id: op-230
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-230 — Gatekeeper: make the op-225 M1 regime label a REQUIRED field in the comparison record (`mismatch_v1`) — no green/diff lands without naming its regime

op-230 | role: **Gatekeeper** (harness-authoring) | EXU: **rmx-gatekeeper-rx-x64z** | state: **[Done — COMPLETE 2026-07-02 @ 991dae2, Arranger-verified first-hand]** | parent id: id-033 (Stream C) | L1i: li-1000 (li-1013 Item 1 / op-225 M1) | cost: gatekeeper-tier (free role; harness-authoring) | authored 2026-07-02 (Arranger seat, model Opus 4)

## ADJUDICATION (Arranger, 2026-07-02) — deliverable MET
Verified first-hand at 991dae2 in priv/schemas/mismatch_v1.schema.json: `"regime"` is in the top-level `required` array (line 32); the regime object requires `kernel_ident` + `mach_ko` {sha256, flags} + `engine` (line 176); `engine` requires both `dispatch_engine` (twq_kernel|pthread_pool|unknown) AND `evidence_source` (init_banner|dtrace_syscall|not_applicable) — so per-run engine proof is mandated, not the library's self-description (correctly distrusts thr_workq.c:196-201 constant). Schema-comment records the op-225 rationale ("a green without regime is regime-limited or undetermined"). mismatch_regime_test.exs (5 tests) among the passing set. This is the required-field foundation op-232's concurrency corpus will populate.

## CONTEXT (read first)
Open-source OS engineering — OUR OWN test-harness comparison-record schema for the rmxOS/macOS parity loop. Not security work. Harness-authoring (Gatekeeper), no product code.

## WHY (one line)
op-225 established M1: regime identity is part of artifact identity — a green that doesn't name its kernel ident / mach.ko flags / libdispatch flags / per-run engine is regime-limited or undetermined, not proven. op-228 D4 folds this into the pipeline: every conformance/regression comparison record must carry its regime **as a required field**, or the whole conveyor repeats the op-225 caveat at scale.

## SCOPE (op-228 D4 + op-225 M1)
1. **Add mandatory regime fields to the rx-side comparison record** (`mismatch_v1` / the rx-vs-mx delta schema): kernel ident (uname / boot-log naming MACHDEBUG vs MACHDEBUGDEBUG + INVARIANTS state), mach.ko build flags, libdispatch flags, and — for any dispatch-engine claim — **per-run engine evidence**.
2. **Engine evidence source:** prefer the op-227 init banner ("twq kernel" vs "pthread pool") once it lands; until then, dtrace of the twq syscalls (the method op-225 named). Do NOT trust libthr's constant advertisement (thr_workq.c:196-201 returns FINEPRIO unconditionally) — engine proof is per-run.
3. **Enforce required-ness:** a comparison record missing the regime block is a schema failure, not a silent optional. macOS-truth (mx) side records its regime symmetrically where it applies.

## NON-SCOPE (explicit)
- Does **NOT** decide whether a missing-regime record is retirement/CI-blocking vs advisory-warn — that is **E2 (Coordinator)**. Make the field mandatory in the schema; the enforcement severity is a later flip.
- Does **NOT** re-run or re-label historical greens (that is op-225 M2 / op-226 territory).
- Does **NOT** author conformance content or touch product source.

## DELIVERABLE
An updated `mismatch_v1` (comparison-record) schema with a required regime block + validation that rejects a record lacking it, plus one worked example record carrying a full regime label (kernel ident + module/dispatch flags + per-run engine evidence). Proof: a record without the regime block fails validation; a complete one passes.

## BOUNDARIES
- Gatekeeper authors harness/schema; does not build product (build_is_implementer) or author conformance content (Explorer).
- Respect the op-228 established constraints (Elixir pillar; DTrace observation for engine evidence; no committed printf scaffold).
- Stage only in the Gatekeeper's own dir (agent_host_isolation).

## RELATIONS
id-033 Stream C (source); op-225 M1 (the mandate — regime labeling) + D2 per-green ledger (the gap this closes); op-228 D4 (comparison-record required field); op-227 (the engine banner this consumes as evidence); op-226 (its run is regime-labeled per this schema); li-1013 Item 1 (M1). feedback: harness_authoring_is_gatekeeper, artifact_identity_needs_content_check (regime = part of artifact identity), no_conflate_gating_with_readiness (mandatory field ≠ gating severity — E2), dtrace_first_debugging, op_state_dispatch_boundary, agent_host_isolation.
