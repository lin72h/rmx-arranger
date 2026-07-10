# op-288 — Oracle2: known-bad / oracle-mutation atlas (QA fail-closed census) — GATED on op-287 review

op-288 | role: **Oracle** (consult-only; design-not-execute) | EXU: **rmx-oracle2** | state: **[Hold — GATED on the second-Arranger-review of op-287 (the proof-closure matrix). Do NOT begin until that review verdict releases this op. Plan authored by oracle2 2026-07-10, Arranger-accepted with amendments (scope = foundation-only, Swift excluded). Deliverable `rmxos-qa-known-bad-oracle-mutation-atlas.md`, staged markdown-only in rmx-oracle2.]** | parent: li-1013 / id-033 (conformance→regression pipeline) | L1i: li-1000 | cost: oracle-tier | authored 2026-07-10 (Arranger1 seat, model Fable/Opus)

## CONTEXT (engineering framing)
Ordinary open-source OS QA engineering on our own test harnesses: for each claim class, would our detectors catch the smallest realistic defect, and do they fail closed? rmxOS = Darwin/Mach userland on FreeBSD 15. No target, no adversary.

## SCOPE (oracle2's plan, incorporated by reference)
Per major claim class: historical defects + harness failures → smallest mutation that should be detected → responsible test/comparator/hard-stop/invariant → does it currently fail closed → missing negative controls → DESIGN (do not execute) a runtime campaign covering: stale binaries/wrong modules, missing/duplicated/reordered markers, unexpected skip + partial expected sets, invalid JSON + misleading aggregates, crashed mandatory probes, missing evidence, VM/image collisions, timeout/runner-death/failed finalization, known-bad product candidates, comparator field mutations. Distinguish product bugs / harness bugs / infrastructure failures / inconclusive.

## SEED MATERIAL (Arranger-verified defect history — calibrate the atlas against these real cases)
- op-258: four harness defects in one run — observer compile-fail unpreflighted; a diagnostic line counted as the event; verdict parsing a never-written file; verdict shell bad-number fall-through. (Banked lesson: compile/preflight every observer + demonstrate a known-bad control before the long run.)
- op-198 v5: root-FS fill → OOM cascade killed asld+launchd+devd — infrastructure failure misattributable to product.
- op-253 probe B: unexercised sub-case (harness struct SIGSEGV) inside a PASS verdict.
- op-232: cross-repo write stall → agent duplicated the target locally, reported green against its own copy.
- op-206: probe blind spot — released a stubbed object, never asked its type (became op-284).
- op-163: instrumented the WRONG quantity (RSS instead of fd/store-size) — signal-selection defect class.
- op-249: product-bug class — dequeue-stale/uninitialized caller-local.
- mach_msg.c:372: latent dead-code class — masked option bits make a whole decision branch unreachable (op-281/op-282).
- op-225/li-1013 Item 1: regime mismatch — greens on MACHDEBUG vs ship MACHDEBUGDEBUG; -O0/-O2 axis uncovered by any config.
- op-257→op-258 lineage: component VARIANT changed between soaks — durability evidence non-transferable.

## BOUNDARIES
- Foundation-only: Swift-rx excluded (li-9001/M9); a Swift atlas would be a separate post-preview commission.
- Design-not-execute: no guest attempts, no runs, no product edits, no dispositions.
- Stage markdown only in rmx-oracle2 (`agent_host_isolation`).

## RELATIONS
op-287 (the proof-closure matrix whose review GATES this) / 1.0-preview solidity consult finding #4 (registered regression lane — this atlas is its negative-control complement) / id-033 / li-1013 / li-1000. feedback: oss_engineering_framing, code_reasoned_verdict_is_hypothesis, agent_host_isolation, op_state_dispatch_boundary.
