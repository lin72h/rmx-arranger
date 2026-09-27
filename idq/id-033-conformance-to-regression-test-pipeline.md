# id-033 — conformance→regression test pipeline: the macOS-as-truth conveyor (park-ahead OOO ledger → Explorer-authored conformance → Gatekeeper-owned regression)

- id: id-033
- state: **OPEN — seeded from op-228 Oracle consult (delivered + Arranger-verified 2026-07-02).** Decodes the Oracle's E4 into four bounded work-streams below. Doctrine + scope calls (E1-E3) are Coordinator-held; no op cut until the matching ruling.
- raised: 2026-07-02 (Arranger seat, codifying op-228).
- roadmap parent: **id-000** (roadmap consult) / **li-1000** (M1); the regression-soak infra relates **li-1007** integration soak + **id-007** soak infra. Post-preview surface (swift-testing) touches **li-9001**.
- cost note: the four streams split by role per the reconciled doctrine (D2) — parked-ledger + regime-fields are harness-authoring (Gatekeeper); conformance content is Explorer; binaries are Implementer.

## WHY (the Coordinator's vision, pressure-tested by op-228)

A standing conformance→regression conveyor, not ad-hoc per-feature greens: explorer-nx (explorer-mx macOS-truth + explorer-rx rmxOS-match) authors test cases **ahead of** implementation; a not-yet-buildable test is **parked (skip/xfail)** so the pipeline never stalls (OOO-style); when the feature lands the parked test **activates** and must go green; once green it **migrates** from Explorer authoring to Gatekeeper regression/soak ownership; and the macOS-truth corpus doubles as the living spec the Coordinator reads to learn each feature.

op-228 graded the vision **sound** and the novel crux (the park-ahead ledger) **HIGH-feasibility**, but verified first-hand that the enabling mechanisms **do not yet exist**:
- **NO park/skip convention** — zero `@tag`/`@moduletag`/`ExUnit.configure`/`exclude` across all three harness Elixir trees (rmx-explorer, rmx-gatekeeper, wip-gpt/test). *(Arranger re-verified 2026-07-02.)*
- **Migration scaffold is design-only** — `rmx-explorer/docs/migration-m2-authority-design.md:50-52` marks `catalog/`+`mismatches/` "design only", `certification/claims/` "deferred"; :77-80 "does not create them"; :108 "certification/ remains absent until the R0 claims-ledger contract is accepted." *(Arranger re-verified 2026-07-02.)*
- **Conformance vs regression conflated** at corpus level; **regime labeling** (op-225 M1) not yet a required record field; leg state kept as prose, not queryable records.

## THE FOUR WORK-STREAMS (op-228 E4 decode — each a candidate op when its gate clears)

### Stream A — park-ahead mechanism + pending-gate ledger (the novel crux; Gatekeeper harness-authoring) — **DONE → op-229 [Done] @ 2771dbc (Arranger-verified)**
The OOO non-stall. Two parked flavors (op-228 D3): **parked** (`@tag`-excluded via `ExUnit.configure`, feature absent) and **xfail** (self-activating — runs, expected-fail, flips green when the feature lands). Plus the **pending-gate ledger** so a parked test is *never silently lost*:
- **Lock 1** — a committed parked-ledger + a `mix oracle.parked` diff task that fails CI if a parked test exists without a ledger entry (or vice-versa), so "N tests parked waiting on features X,Y,Z" is always visible.
- **Lock 2** — an IDQ reciprocal hook: the feature-op's retirement flips its parked test skip→active (the activation trigger is the feature-op reaching [Retired]/[Done], not a manual re-scan).
- Feasibility: **HIGH** (op-228). This is the first-to-build stream.

### Stream B — migration ceremony generalization (Explorer→Gatekeeper handoff; Gatekeeper harness-authoring) — **CEREMONY PROVEN → op-236 [Done] @ 8f783e9 (first authority-transfer landed + Arranger-verified, 2026-07-02)**
Migration is an **AUTHORITY transfer, not a raw file move** (op-228 D2): a per-test registry record (schema'd like `catalog_probe_v1`), a **hash-pinned vendored copy** of the conformance case, re-homed under Gatekeeper regression ownership. Generalizes the launchctl D19-D21 migration precedent (`transitional_reference`). Post-migration contract change **re-opens as an Explorer op** (conformance content is always Explorer's).

**First case (op-236):** op-232's Swift-concurrency corpus surfaced the concrete trigger — the park-ahead ledger (op-229) lives in **rmx-gatekeeper**, the corpus was authored in **rmx-explorer**, and an Explorer **cannot write cross-repo** (`agent_host_isolation`). rx1 worked around it by DUPLICATING op-229's ledger in the explorer repo (drift). op-236 is the authority-transfer that re-homes the corpus: vendor + hash-pin the 3 probes into the Gatekeeper repo and register them in the **canonical** op-229 ledger, superseding the rx1 duplicate. This is the first exercise of the Stream B ceremony and the reason it stops being design-only. **Root lesson:** cross-repo park-registration is a Gatekeeper handoff (Stream B), never Explorer self-service — the Explorer authors content, the Gatekeeper owns the ledger repo.

**Landed (op-236 @ 8f783e9, Arranger-verified first-hand):** 3 probes vendored hash-pinned into canonical rmx-gatekeeper `priv/probes/concurrency/` (fan_out=6983efc2, actor_churn=2c4396f6, deep_chain=994544d0, from rmx-explorer @ 8489fe7); canonical ledger now 4 entries (3 `:parked` blocked_by li-9001 + 1 xfail id-998); Lock-2 self-activates on P1 join-op retirement. The Stream B ceremony is now proven, not design-only. **Residual:** rx1's now-non-canonical duplicate (`oracle.parked.ex` + `concurrency/parked_ledger.ex`) still physically sits in rmx-explorer — a Gatekeeper op can't delete cross-repo; cleanup = a small Explorer op or leave inert (Coordinator call, non-gating).

### Stream C — regime fields in comparison records (op-225 M1 bake-in; Gatekeeper harness-authoring) — **DONE → op-230 [Done] @ 991dae2 (Arranger-verified)**
Make the op-225 M1 regime label a **required field** in the `mismatch_v1` comparison record (op-228 D4): kernel ident, mach.ko flags, libdispatch flags, per-run engine evidence (op-227 banner once landed, else dtrace of twq syscalls) — on the **rx side mandatorily**. A conformance/regression record that doesn't carry its regime repeats the op-225 caveat. E2 candidate for retirement-blocking.

### Stream D — R0-minimal claims-ledger contract (the migrated-gate registry; Coordinator-gated by E3)
The migrated regression gates need a registry. op-228 recommends the **minimal R0 claims-ledger contract** (`migration-m2-authority-design.md:52,:108`) as that registry — "accepted rx regression claims and hard-stop ledger." Whether to accept R0 vs a lighter registry is **E3 (Coordinator)**. Do not build until ruled.

## BANKED FOUNDATION NEGATIVE-CONTROL DESIGN — op-288→op-300 (2026-07-11)

Oracle2's foundation mutation atlas is banked as a validated design supplement:

- content identity: 62,319 bytes / 396 lines / SHA-256
  `f2536dcad3fda3298207ac7e33be4fc4b1658a8ff3a16c01b5a0ec7eeaa0aae2`;
- 35 unique twelve-field claim classes, independently recounted
  `YES=1 / PARTIAL=16 / NO=16 / UNKNOWN=2`;
- ten-phase P0–P9 campaign, monotonic cell accounting, non-promoting result classes, four-control
  KBC-0 pre-soak pack, and a nine-item closure ladder; and
- Validator-GLM op-300: `VALIDATED-DESIGN`, confidence 9/10,
  `BANK-AS-FOUNDATION-CAMPAIGN-DESIGN`.

Oracle2 is non-Git, so this is a content-addressed local-only design—not origin publication. The
atlas's central finding is that only one of 35 foundation claim classes currently has a complete
frozen-negative→detector-rejects→known-good-replay chain. Banking does not execute the campaign,
fetch an ID, resolve Stream D/E1–E3, change retirement doctrine, or make the preview green. Any
closure-ladder work requires Coordinator scope and fresh role-correct ops: Explorer owns
conformance truth/content, Implementer disposable product candidates, Gatekeeper harness/runtime/
evidence, and Arranger registry reconciliation.

## DOCTRINE + SCOPE — Coordinator-held (op-228 escalations; Arranger flags, does not decide)

- **E1 — role-boundary doctrine stamp.** op-228 D2 states: Explorer owns conformance *content*; Gatekeeper owns regression *infrastructure* + the migrated gates; Implementer owns binaries; a post-migration contract change re-opens as an Explorer op. This **reconciles** the apparent `harness_authoring_is_gatekeeper` vs "Explorer-authors-conformance" tension (content vs infrastructure, not the same axis). Needs Coordinator stamp before it governs op-splitting.
- **E2 — what's retirement-blocking vs advisory.** op-228 recommends making the **parked-ledger diff** (Stream A Lock 1) + **regime labeling** (Stream C) retirement-blocking, the rest advisory. Coordinator call.
- **E3 — R0 claims-ledger vs lighter registry** (Stream D). Coordinator call.
- **E4 — this id.** Seeded; the four streams above are the decode.

## BOUNDARIES
- **Consult-only output so far** — op-228 wrote no product; these streams are candidate ops, not dispatched work (op_state_dispatch_boundary).
- **Build on established constraints, don't re-litigate** — Elixir+Zig+DTrace pillar (op-147m); 4-leg truly-green bar (conformance-MATCH = leg 3 only); the C-probe DTrace exception (block-080a) stays in force; XPC probes pump a queue+semaphore.
- **First-hand truth capture** — divergences that drive a test change must be source-verified (verify_signature_divergence_claims); the mm4 human-checkpoint cycle stays.
- **Role split on the ops** — Stream A/B/C are Gatekeeper harness-authoring; conformance content is Explorer; binaries Implementer. Explorer seat is rx1 (rx2 parked).

## RELATIONS
- **op-228** (source consult, [Done] + Arranger-verified) — D1-D6 are the full backing; staged at rmx-oracle/op-228-testing-strategy-review.md.
- **op-225** (evidence-regime) — its M1 regime-labeling is Stream C; the two consults are complementary (op-225 = what our greens proved; op-228 = how to produce greens going forward).
- **op-223** (LEG A) — its Item-5 test-coverage gaps (li-9004 Item 5) are concrete D1 inputs.
- **op-147m** — the harness pillar this builds on.
- **op-227** (engine banner) — Stream C's per-run engine evidence leans on it.
- **li-1007 / id-007** — the integration-soak infra the migrated gates re-home onto (Gatekeeper).
- **li-9001** — Swift toolchain; swift-testing is the post-preview 3rd authoring surface (op-228 D5).
- **op-288 / op-300** — banked foundation known-bad/mutation campaign design and its confidence-9
  Validator gate; design support only, not a fetched stream or runtime/release verdict.
- feedback: `harness_authoring_is_gatekeeper` + `build_is_implementer` + `soak_is_gatekeeper` (the D2 reconciliation), `conformance_match_is_leg3_only`, `verify_signature_divergence_claims`, `dtrace_first_debugging`, `xpc_probe_pump_queue`, `no_conflate_gating_with_readiness`, `op_state_dispatch_boundary`, `artifact_identity_needs_content_check`.
- **Ops cut (2026-07-02):** **op-229** [Done] @ 2771dbc (Stream A — park-ahead ledger + `mix oracle.parked`, the HIGH-feasibility first build) and **op-230** [Done] @ 991dae2 (Stream C — regime fields into `mismatch_v1`), both Gatekeeper (rmx-gatekeeper-rx-x64z), Arranger-verified first-hand. E2 still decides their gating severity (advisory vs retirement-blocking). **First live consumer:** op-232 (Swift-concurrency conformance corpus) uses op-229's park-ahead + op-230's regime field. **Stream B UNHELD → op-236** [Awaiting] (Gatekeeper, rmx-gatekeeper-rx-x64z): the first authority-transfer — re-homes op-232's corpus into the canonical op-229 ledger (vendor+hash-pin, supersedes rx1's duplicate). Stream D still waits on E3.
