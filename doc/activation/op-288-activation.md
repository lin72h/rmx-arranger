# op-288 — Oracle2: known-bad / oracle-mutation atlas for foundation QA fail-closed coverage

op-288 | role: **Oracle** (consult-only; design-not-execute) | EXU: **Oracle2 / rmx-oracle2** |
state: **[Retired — DESIGN-COMPLETE atlas banked as foundation-campaign design after op-300
VALIDATED-DESIGN confidence 9/10; local-only/non-Git provenance and design-only boundary
preserved]** | parent:
**li-1013 / id-033** | L1i: **li-1000** | authored: **2026-07-10 by Arranger1; normalized and
released 2026-07-11 by Arranger2**

## ARRANGER INTAKE — 2026-07-11

**Intake state at return: RETURNED / L-GATE-DELEGATED / NOT YET BANKED.** Oracle2 deliverable:

`/Users/me/wip-mach/rmx-oracle2/rmxos-qa-known-bad-oracle-mutation-atlas.md`

Arranger2 reproduced:

- atlas: 62,319 bytes / 396 lines / SHA-256
  `f2536dcad3fda3298207ac7e33be4fc4b1658a8ff3a16c01b5a0ec7eeaa0aae2`;
- matrix input: 47,630 bytes / 365 lines / SHA-256
  `ec119b1f3f24ff5f46757f05e289d0d94ecc4f52ee6077e4f1cb1998a4e6e5eb`;
- all six commissioned markers and the design-only terminal;
- 35 joined Table-A/Table-B classes with arithmetic `YES=1`, `PARTIAL=16`, `NO=16`,
  `UNKNOWN=2`;
- ten campaign phases P0–P9 and the four-control KBC-0 pre-soak pack; and
- explicit zero guest/build/mutation/product/control work and exclusion of Swift/Milestone 9.

The atlas is local-only in Oracle2’s non-Git deliverable tree. It correctly treats product
`ceb46edc` as accepted source freshness rather than a release candidate and freezes concurrent
Gatekeeper work rather than consuming it. Its Gatekeeper/op-298 and id-032 language is now dated:
op-298 returned partial at `b6e3252`; op-299 returned partial at `fb9040d` and is now split into
op-301 [Ready]→op-302 [Draft/Waiting]; id-032 retired as an already-satisfied op-197 duplicate.
Those are post-atlas deltas pending Validator assessment, not silent rewrites.

This return was sized L at intake: 35 claim classes, primary evidence/source assertions, classification
rubric, ownership routing, and a ten-phase dependency graph. Per Rule 11, op-300 `[Exe]` binds
Validator-GLM for the substantive first-hand falsification. At that boundary op-288 remained
`[Done]` and was neither retired nor banked until the gate was consumed.

## FINAL ADJUDICATION — 2026-07-11

Validator-GLM op-300 returned `VALIDATED-DESIGN` at confidence 9/10 and recommended
`BANK-AS-FOUNDATION-CAMPAIGN-DESIGN`. Arranger2 reproduced both content identities and local-only
provenance, found no conflict, and consumed the gate under Rule 11. The banked design contains 35
unique twelve-field classes (`YES=1 / PARTIAL=16 / NO=16 / UNKNOWN=2`), P0–P9, monotonic cell
accounting, KBC-0, and the nine-item closure ladder.

The atlas is now a content-addressed, local-only design foundation under id-033/li-1013. It is not
executed evidence, a release verdict, a candidate BOM, origin-published state, or authorization to
fetch any campaign phase. Post-atlas op-298→op-299→op-301/op-302 progress is a non-invalidating
freshness delta. op-288 and op-300 retire and leave the live ROB; no new ID/L1i is allocated.

## DISPATCH BOUNDARY

DISPATCHED by the Coordinator to **Oracle2 / rmx-oracle2** on 2026-07-11. Write exactly one
deliverable:

`/Users/me/wip-mach/rmx-oracle2/rmxos-qa-known-bad-oracle-mutation-atlas.md`

All product, Arranger, Explorer, and Gatekeeper trees are read-only. Design only: no guest, build,
mutation execution, evidence disposition, ID/op allocation, milestone change, or release decision.

## OBJECTIVE

Design a foundation-only known-bad/mutation atlas that answers, for every major 1.0-preview claim
class: what is the smallest realistic defect, which current detector should reject it, whether that
detector fails closed today, which negative control proves that, and what bounded campaign closes
any gap. Distinguish product bugs, harness bugs, infrastructure failures, and inconclusive runs.

This is the negative-control complement to the registered conformance/regression lane. It does not
execute mutations and does not declare the release green or blocked.

## AUTHORITATIVE INPUTS

Read completely:

1. validated foundation matrix:
   `/Users/me/wip-mach/rmx-oracle2/rmxos-1.0-preview-proof-closure-matrix.md`
   — 47,630 bytes / 365 lines / SHA-256
   `ec119b1f3f24ff5f46757f05e289d0d94ecc4f52ee6077e4f1cb1998a4e6e5eb`;
2. `/Users/me/wip-mach/rmx-arranger/doc/activation/op-287-activation.md`;
3. `/Users/me/wip-mach/rmx-arranger/doc/activation/op-294-activation.md`, especially the accepted
   `VALIDATED-SNAPSHOT` report and disclosed sampling limits;
4. `/Users/me/wip-mach/rmx-arranger/l1i/li-1000.md`, `li-1012.md`, `li-1013.md`;
5. `/Users/me/wip-mach/rmx-arranger/idq/id-033-conformance-to-regression-test-pipeline.md`;
6. every activation/evidence/source artifact cited by a load-bearing atlas row.

Roots:

- control/doctrine: `/Users/me/wip-mach/rmx-arranger/`;
- product, read-only: `/Users/me/wip-mach/wip-gpt/wip-rmxos/`;
- evidence, read-only: `/Users/me/wip-mach/rmx-gatekeeper/` and
  `/Users/me/wip-mach/rmx-explorer/`.

The matrix scan pin is product `dd6e7a804ebfee330d40903dc4b9acb3e18863b9`; it is not a candidate
BOM. Accepted freshness now reaches product `origin/alpha`
`ceb46edc5f910660d4fa7ecd9e90501ebd86b1ba`. Activation headers are live op truth. op-295's
header-only cleanup is first-hand accepted, origin-reachable, and retired; record it as a
post-scan publication delta, not a runtime-green claim. Do not treat a dirty evidence tree as
accepted state. Record exact commit/status identities observed during this consult.

## RELEASE GATE ALREADY SATISFIED

op-294 validated the exact op-287 matrix as a materially correct July-10 snapshot: Q1–Q8
satisfied, 58 atomic claims plus seven cross-cut rows, 16/16 evidence hashes matching, all named
high-risk areas checked, and no reasoning-invalidating post-scan delta. Preserve that dated scan
boundary; add freshness deltas separately rather than rewriting history.

## REQUIRED FRESHNESS DELTAS

Reconcile at least:

- op-285 lifecycle fix `778cb074...` and op-292 correction `0ccd5621...` are on
  `origin/alpha`; op-291 runtime acceptance remains `[Ready]`;
- op-295 header-surface cleanup `ceb46edc...` passes its M gate, is now on `origin/alpha`, and is
  retired; it changes header truth only and does not close libxpc runtime acceptance;
- id-029/op-187 reply correlation is administratively retired and origin-reachable;
- op-293 is `[Done]`, with Cell B `HARNESS-NOT-ACCEPTED`. op-296 `[Done]` committed the six raw
  logs/correction at `a66e3b7`; op-297 `be5dbdc` removed the self-row and fixed several marker
  gates; op-298 `b6e3252` added partial digest/set work, but Arranger verification still rejects
  record closure because its expected set is hard-coded and omits its own records, the broken
  checker remains, command/test records are absent, and malformed/no-shutdown/fd inputs still
  false-green. op-299 `fb9040d` also returned partial: the committed checker/tests/outputs
  contradict its attestation and structural false accepts remain. Completion is split into
  op-301 `[Ready]` then op-302 `[Draft / WAITING]`. Do not promote op-293's scheduler verdict;
- op-270 is first-hand verified and retired: ordinary notifyd logical slot bounds and counter
  reset hold. Extreme `-shm_pages` physical-size truncation is id-041, explicitly banked
  post-preview after a no-live-preview-consumer census;
- IDQ is current through id-041; id-038/id-039 are post-preview language designs, id-040 is the
  ASL production-mode decision, and id-041 is non-preview notify sizing hardening;
- li-1012 is present in li-1000's constituent table;
- the Validator confidence ≥9 versus ≥8 contradiction remains unresolved;
- record the exact Gatekeeper commit/publication/dirty state observed after or during op-296.

These are atlas inputs, not authority to alter dispositions or preview scope.

## REQUIRED ATLAS

For every major claim class across li-1001…li-1008 and the li-1012/li-1013 cross-cuts, provide one
or more rows with these fields:

1. claim ID/class and bounded property;
2. representative historical defect or harness/infrastructure failure;
3. smallest realistic product or evidence mutation;
4. exact current detector/comparator/hard-stop/invariant and owning repository;
5. expected observable rejection signal;
6. existing negative control and its primary evidence identity, or `MISSING`;
7. current fail-closed verdict: `YES`, `PARTIAL`, `NO`, or `UNKNOWN`;
8. false-green mode if the detector is absent, bypassed, stale, or mislabelled;
9. artifact, build regime, provenance, and publication assumptions;
10. smallest design-only closure and correct owning EXU/repository;
11. source fact versus inference versus runtime-unknown; and
12. confidence 1–10.

Do not collapse implementation, test execution, truth source, evidence publication, and solidity
into one verdict. A findings summary is not raw evidence. A detector that never observes the
mutated field is `NO`, even when its surrounding suite exits zero.

## REQUIRED CAMPAIGN DESIGN

Design—do not run—a bounded campaign covering:

- stale binaries, wrong modules, wrong image, and component-variant drift;
- missing, duplicated, reordered, malformed, or misleading markers/JSON;
- unexpected skips, partial expected sets, and a mandatory probe that crashes before exercising
  the product path;
- missing/uncommitted evidence and summary-vs-raw hash or label swaps;
- VM/image collisions, root-filesystem exhaustion, timeout, runner death, and failed finalization;
- known-bad product candidates for each high-risk foundation class;
- comparator-field mutations and aggregates that hide a failed constituent;
- build-regime mismatch, including MACHDEBUG versus MACHDEBUGDEBUG and uncovered optimization
  axes; and
- recovery rules that classify a run as product-fail, harness-fail, infrastructure-fail, or
  inconclusive without consuming a green verdict.

For each campaign phase name prerequisites, mutation fixture, expected detector, hard stop,
attempt/cell accounting, retained raw artifacts, and pass/fail/inconclusive rule. Include the
minimum known-bad control that must pass before any hours-scale soak is released.

## VERIFIED SEED INCIDENTS

Calibrate the atlas against these accepted classes; verify the cited primary record before using
each one:

- op-258: observer compile failure, diagnostic text counted as reclaim, wrong-file verdict input,
  and shell bad-number fall-through;
- op-286/op-293: host hashes mislabeled as serial, truncated/missing terminal record, and a
  synthetic validator that did not consume or enforce the actual logs;
- op-198 v5: root-filesystem fill and OOM cascade misattributable to product;
- op-253 probe B: harness SIGSEGV left a mandatory subcase unexercised inside a PASS report;
- op-232: cross-repository ownership violation led to a local duplicate and false green;
- op-206/op-284: probe omitted the load-bearing object type;
- op-163: wrong measured quantity (RSS rather than fd/store size);
- op-249: real product defect, stale/uninitialized dequeue caller-local;
- `mach_msg.c:372`: masked option bits make a decision branch unreachable (op-281/op-282);
- op-225/li-1013: evidence-regime mismatch and uncovered optimization axis; and
- op-257→op-258: component variant changed between soaks, invalidating durability transfer.

## DELIVERABLE STRUCTURE

The markdown note must contain:

1. input identities and snapshot boundary;
2. executive fail-closed finding;
3. complete mutation-atlas table;
4. negative-control coverage/gap register;
5. designed campaign and attempt-accounting rules;
6. prioritized foundation-only closure ladder with repository-correct owners;
7. exclusions and runtime-unknowns; and
8. a concise return report with counts, top fail-open gaps, and the markers below.

Return exactly one completion verdict:

- `DESIGN-COMPLETE` — commissioned atlas and campaign are complete;
- `DESIGN-INCOMPLETE <missing load-bearing inputs/rows>` — name every required addition; or
- `BLOCKED-INPUT-MISMATCH <identity>` — an authoritative input does not match.

All conclusions remain Oracle hypotheses for Arranger verification.

## BOUNDARIES

- Foundation-only: Swift/Milestone 9 and language-specific atlases are excluded.
- Design-not-execute: no mutation, guest, build, probe, soak, disposition, or release decision.
- Do not edit the validated op-287 matrix; preserve its scan pin and add a separate delta view.
- Do not promote id-038/id-039/id-041 into preview work or choose id-040's production mode.
- Do not issue ops/IDs, assign attempts, reserve hosts, or write another repository.
- Stage only the named markdown in `rmx-oracle2`; no copied artifacts or cross-repo registration.

## MARKERS

`O2_OP288_INPUT_IDENTITY`

`O2_OP288_MUTATION_ATLAS`

`O2_OP288_NEGATIVE_CONTROLS`

`O2_OP288_CAMPAIGN_DESIGN`

`O2_OP288_FAIL_CLOSED_VERDICT`

`O2_OP288_TERMINAL`

## RELATIONS

op-287 (validated proof-closure matrix) / op-294 (confidence-9 gate) / id-033
(conformance→regression pipeline) / li-1000 / li-1012 / li-1013 / 1.0-preview solidity consult
finding 4.

feedback: `oss_engineering_framing`, `code_reasoned_verdict_is_hypothesis`,
`agent_host_isolation`, `op_state_dispatch_boundary`, `artifact_identity_needs_content_check`,
`no_conflate_gating_with_readiness`, `verdict_labeling_model_honest`.
