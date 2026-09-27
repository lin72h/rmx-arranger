---
id: op-236
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-236 — Gatekeeper: register the op-232 concurrency corpus in the CANONICAL op-229 parked-ledger (the id-033 Stream B authority-transfer, first real case) — de-dup rx1's drift

op-236 | role: **Gatekeeper** (harness-authoring; Stream B migration) | EXU: **rmx-gatekeeper-rx-x64z** | state: **[Done — committed 8f783e9, Arranger-verified 2026-07-02]** — first id-033 Stream B authority-transfer landed correctly in the CANONICAL repo. | parent id: id-033 Stream B (Explorer→Gatekeeper migration) + op-232 (the corpus) | L1i: li-1000 (li-1007/id-007 soak infra) / li-9001 | cost: gatekeeper-tier (free role; harness-authoring) | authored 2026-07-02 (Arranger seat, model Opus 4)

## OUTCOME (Arranger-verified first-hand at 8f783e9, 2026-07-02) — size M, self-retired
The op-232 Swift corpus is vendored hash-pinned into the **canonical** rmx-gatekeeper parked-ledger (the Rule-12 topology concern that spawned this op is satisfied — landed in the right repo, right owner):
- 3 probes in `priv/probes/concurrency/`, hashes **match the report exactly**: `fan_out_taskgroup.swift`=6983efc2, `actor_churn.swift`=2c4396f6, `deep_async_chain.swift`=994544d0 (vendored from rmx-explorer @ 8489fe7).
- Ledger (`lib/rmx_os_oracle/parked_ledger.ex`) has **4 entries**: 3 `:parked` probes all `blocked_by: "li-9001"` with the claimed per-probe `match_invariants` (fan_out=[completion,counts]; actor_churn=[completion,exclusion,ordering,counts]; deep_chain=[completion,liveness,counts]) + 1 xfail demo (`id-998`, retained from op-229). All confirmed first-hand.
- Gatekeeper's own proof (accepted, not re-run — light provenance check): `mix oracle.parked --strict` 4/4 reconciled exit 0; `mix test` 3 excluded, suite green.
- Lock-2 activation wired to P1 join-op retirement (remove `@tag :parked` → self-activates when the executor join lands).

**Residual (flagged, not blocking):** the report says this "supersedes rmx-explorer's duplicate `oracle.parked.ex` + `concurrency/parked_ledger.ex`" — authority-wise correct (canonical is now the gatekeeper copy), but under agent_host_isolation this Gatekeeper op cannot delete the explorer's now-non-canonical files; the stale duplicate physically still sits in rmx-explorer. Cleanup = a small Explorer op (remove the drifted copy) OR leave it inert. Coordinator call — noted, not gating.
**Comparator note (carried):** use `xcrun --toolchain XcodeDefault swiftc`, NOT bare `swiftc` (mm4 dev-snapshot Foundation.swiftmodule parse fail); documented in test wrappers.

## CONTEXT (read first)
Open-source OS engineering — take the Explorer-authored Swift-concurrency conformance corpus (op-232) and register it in OUR OWN canonical park-ahead ledger (op-229, in this Gatekeeper repo). Not security work; harness-authoring (Gatekeeper). No product code, no conformance-content authoring (that is Explorer's, done).

## WHY (one line)
op-232 surfaced a repo-topology gap: the park-ahead mechanism (op-229) + regime schema (op-230) live in **rmx-gatekeeper**, but the corpus was authored in **rmx-explorer**, and the Explorer cannot write cross-repo (agent_host_isolation). rx1 worked around it by DUPLICATING op-229's `oracle.parked.ex` + a parallel `parked_ledger.ex` in the explorer repo — drift: two ledgers, two tasks, one canonical. This op is the id-033 **Stream B authority-transfer** (op-228 D2: migration = per-test registry record + hash-pinned vendored copy, re-homed under Gatekeeper ownership) — the first real case, releasing Stream B's "hold until a case is ready to migrate."

## SCOPE (register in the canonical ledger; do NOT author conformance content)
1. **Vendor + hash-pin the 3 op-232 probes** into the Gatekeeper repo: `fan_out_taskgroup.swift`, `actor_churn.swift` (incl. the `OrderedCounter` D3-ordering enhancement), `deep_async_chain.swift` — a content-hash-pinned copy of the Explorer's canonical sources (from rmx-explorer `8489fe7` / macos-validation/probes/concurrency), so the Gatekeeper regression copy is provenance-traceable to the Explorer original (transitional_reference precedent, launchctl D19-D21).
2. **Register 3 parked entries in the CANONICAL op-229 ledger** (`lib/rmx_os_oracle/parked_ledger.ex`), each `@tag :parked`, `blocked_by: "P1 executor-join op (li-9001) — sub-fix #1 servicing + swift-rx toolchain"`, with per-probe `match_invariants` (fan_out: completion,counts; actor_churn: completion,exclusion,ordering,counts; deep_chain: completion,liveness,counts) and D3 excludes. Prove `mix oracle.parked` (and `--strict`) shows "3 probes waiting on the P1 executor join" — the item-2 deliverable op-232 could not meet cross-repo.
3. **Use op-230's `mismatch_v1` regime block** for the comparison-record shape (kernel_ident, mach_ko, engine{dispatch_engine, evidence_source}); wire the macOS-truth (mx) side to a reference-platform regime convention (the op-230 E5 follow-up: a darwin-native engine value + evidence_source for the closed-source reference side).
4. **Lock-2 activation trigger:** wire the skip→active flip to the future Implementer P1 join-op retirement (op-229 lock-2 discipline), so the corpus self-activates when the join lands.

## NON-SCOPE
- Does NOT author conformance content or re-capture macOS truth (Explorer/op-232, done — human-checkpoint pending Coordinator).
- Does NOT build the executor join or any servicing fix (Implementer, gated).
- Does NOT run the probes green on rx (that is post-join drive-rx→match, a later op).

## DELIVERABLE
The 3 op-232 probes hash-pinned + registered as parked entries in the canonical op-229 ledger, visible in `mix oracle.parked` as waiting on the P1 executor join, regime-record shape per op-230. Proof: `mix oracle.parked --strict` exit 0 with the 3 corpus entries reconciled; the rx1 duplicate infra is superseded (explorer drops its local `oracle.parked.ex` + `concurrency/parked_ledger.ex`; canonical is here).

## BOUNDARIES
- Gatekeeper authors harness/registry; does not author conformance content (Explorer) or build product (Implementer).
- Elixir pillar (op-147m); no shell harness; no committed printf.
- **Comparator toolchain fix (carried from op-232, explorer-mx-caught):** the probe-capture path must use `xcrun --toolchain XcodeDefault swiftc`, NOT bare `swiftc` (the mm4 dev-snapshot Foundation.swiftmodule parse fail). Fix in whichever comparator the Gatekeeper regression copy uses; flag back to the explorer for its `comparator.ex:115` if the source copy is shared.
- Stage only in the Gatekeeper's own dir (agent_host_isolation).

## RELATIONS
id-033 Stream B (this IS the first authority-transfer case — releases its hold); op-232 (the Explorer corpus being migrated); op-229 @ `2771dbc` (the canonical ledger + `mix oracle.parked` this registers into) + op-230 @ `991dae2` (regime schema) + its E5 (reference-platform regime enum); op-228 D2 (migration = authority transfer, not a raw file move); the launchctl D19-D21 migration precedent (transitional_reference). feedback: harness_authoring_is_gatekeeper, soak_is_gatekeeper, agent_host_isolation (the cross-repo constraint that forced this split), artifact_identity_needs_content_check (hash-pin the vendored copy), no_conflate_gating_with_readiness. project: canonical source tree = wip-gpt/wip-rmxos; explorer roster rx1 IN.
