# op-294 — Validator-GLM: verify op-287’s 1.0-preview proof-closure matrix and gate op-288 release

op-294 | role: **Validator (GLM)** (independent falsification; no execution or acceptance authority) |
EXU: **Validator-GLM seat** | state: **[Retired — returned VALIDATED-SNAPSHOT at confidence 9/10;
Arranger2 light-provenance check accepted the gate and released op-288 on 2026-07-11]** | parent:
**op-287** | L1i: **li-1000 / li-1013** | authored:
**2026-07-11 by Arranger2**

## DISPATCH BOUNDARY

DISPATCHED by the Coordinator to Validator-GLM only on 2026-07-11. This is a read-only review. Return the
verdict in the Validator session; do not write the Arranger, Oracle2, product, Explorer, or
Gatekeeper repositories and do not run a guest. op-288 remains `[Hold]` until Arranger2 consumes
this gate.

## WHY / GATE SIZE

op-287 returned a release-wide, 365-line evidence census spanning li-1001…li-1008 plus li-1012/
li-1013, primary artifacts, publication state, doctrine, and proposed critical path. Arranger2
sizes its adjudication **XL** and delegates the full first-hand validation under Rule 11. This
review validates the matrix as a dated scan artifact; it does not make a release decision or
silently rewrite it into current state.

## PRIMARY INPUT IDENTITY

Read completely:

- matrix:
  `/Users/me/wip-mach/rmx-oracle2/rmxos-1.0-preview-proof-closure-matrix.md`
- expected size: `47630` bytes / `365` lines;
- expected SHA-256:
  `ec119b1f3f24ff5f46757f05e289d0d94ecc4f52ee6077e4f1cb1998a4e6e5eb`;
- observed mtime: `2026-07-10T22:18:02+1200`;
- activation:
  `/Users/me/wip-mach/rmx-arranger/doc/activation/op-287-activation.md`.

Provenance caveat: `/Users/me/wip-mach/rmx-oracle2/` currently has no `.git` directory. The hash
identifies a local file only; there is no commit/origin reachability to infer. Stop on any content
identity mismatch.

## AUTHORITATIVE TREES

- live control/doctrine: `/Users/me/wip-mach/rmx-arranger/`;
- product source, read-only: `/Users/me/wip-mach/wip-gpt/wip-rmxos/`;
- primary evidence, read-only: `/Users/me/wip-mach/rmx-gatekeeper/` and
  `/Users/me/wip-mach/rmx-explorer/`.

Activation headers are authoritative for op state; `idq/id-000.md` is authoritative for indexed
ID state. Do not use either deprecated Arranger tree as live truth.

## REVIEW SCOPE

### 1. Deliverable and stop-condition integrity

- Verify the matrix matches the commissioned structure and contains the required executive
  finding, atomic matrix, evidence register, gap/dependency register, exclusions, and explicit
  stop before op-288.
- Confirm it performs no disposition, milestone, product, evidence, or control-state mutation.

### 2. Binding amendments Q1–Q8

For every amendment in op-287, mark `SATISFIED`, `PARTIAL`, or `VIOLATED` with matrix section and
primary-source citation. Load-bearing checks include scan-pin-vs-candidate distinction,
rmx-arranger authority, local-only publication axis, li-1001…1008 scope plus li-1012, op-253
PASS-narrow/trailer separation, threshold contradiction, July-10 state refresh, and
foundation-only op-288 scope.

### 3. Constituent coverage and claim decomposition

Read every row for li-1001…li-1008 and the li-1012/li-1013 cross-cut. Verify that:

- each selected preview bar is decomposed into falsifiable claims;
- implementation/consumer, test/control, truth source, evidence/publication, and solidity are not
  conflated;
- missing evidence is labeled missing rather than promoted from a summary;
- excluded modern/long-arc scope is not smuggled into the preview bar.

List missing, duplicate, wrongly-parented, or materially misclassified claims.

### 4. Primary-evidence and publication audit

- Recompute every evidence-register hash that is locally accessible; report inaccessible paths.
- Verify each artifact's type (raw, structured truth, marker extract, or summary) and ensure the
  matrix does not treat a findings summary as raw primary evidence.
- Reproduce origin-reachability/local-only classifications at the scan boundary where possible.
- Treat the Oracle2 matrix itself as unversioned/local-only until an owning repository and origin
  record exist.

### 5. High-risk source/evidence claims

Verify first-hand—not by trusting the matrix summary—the decisive claims for:

- MACH_RCV_TOO_LARGE probe-A versus missing trailer boundary and separate MACH_RCV_LARGE gap;
- ASL leg-4/op-258 harness invalidity and reclaim premise;
- libxpc connection identity/lifetime and its acceptance dependency;
- launchd detached reaper and literal xpc_domain criterion mismatch;
- exact li-1007 chain and full-window invariant absence;
- li-1008 registry completeness/staleness.

For lower-risk rows, use a declared sampling method and list the sampled rows. Any sampled failure
expands verification to that constituent.

### 6. Post-scan delta audit

The matrix is dated; do not call a correct July-10 snapshot false merely because the project moved.
Return a separate delta table showing whether each change only updates freshness or invalidates the
matrix's reasoning. At minimum reconcile:

- product `origin/alpha` now `0ccd56212c172c27877eb613a7dc9f75ebcc0630`;
- op-285 edit is landed/origin-reachable but op-291 runtime acceptance remains open;
- op-286 returned `HARNESS-NOT-ACCEPTED`; op-293 has Cell A accepted and Cell B in progress;
- op-278 and op-292 are retired;
- IDQ index is reconciled through id-039;
- Gatekeeper is currently ahead of origin with newer op-286/op-293 records;
- any still-live li-1012 index or Validator-threshold contradiction.

### 7. Critical-path and successor decision support

Assess whether the proposed evidence order follows from verified dependencies. Return exactly one
op-288 recommendation:

- `RELEASE-AFTER-VALIDATION` — matrix is sufficient foundation for the mutation atlas;
- `REVISE-MATRIX-FIRST <load-bearing deltas>` — op-288 remains Hold pending a bounded addendum;
- `HOLD-OP288 <reason>` — foundation is materially unsound or unverifiable.

This is advisory; Arranger2 records the release/hold decision and Coordinator dispatches.

## VERDICT AND CONFIDENCE

Return exactly one matrix verdict:

- `VALIDATED-SNAPSHOT` — commissioned July-10 scan is materially correct; list minor corrections;
- `NEEDS-REVISION` — name every load-bearing correction/addendum required;
- `REJECTED` — evidence/citation/coverage failures make the matrix unsafe as a foundation.

Attach one confidence integer `1–10`, state whether every primary artifact was accessible, and
separate observed fact, inference, and unavailable reproduction. At confidence **9–10**, the
Validator gate stands after Arranger light provenance checks. Below 9, Arranger2 steps in on the
disputed points. The unresolved 8-vs-9 doctrine contradiction is not silently resolved here.

## DELIVERABLE FORM

Return:

```text
REPORT
op:             op-294
validator:      GLM
matrix_identity:<size / lines / sha256>
verdict:        VALIDATED-SNAPSHOT | NEEDS-REVISION | REJECTED
confidence:     <1-10>
q1_q8:          <8-item result>
coverage:       <constituent result + missing/misclassified claims>
evidence:       <hash/access/publication result>
post_scan:      <delta table>
op288:          RELEASE-AFTER-VALIDATION | REVISE-MATRIX-FIRST | HOLD-OP288
terminal:       complete
```

Then provide source-cited findings in severity order.

## BOUNDARIES

- Read/falsify only. No source, control, evidence, activation, ID, milestone, or repository writes.
- No guest run, build, attempt accounting, evidence disposition, release decision, or follow-on
  allocation.
- Do not repair the matrix. Name the smallest correction and let the Arranger route it.
- Do not expand op-288 beyond foundation scope or include Swift/Milestone 9.

## MARKERS

`VGLM_OP294_MATRIX_IDENTITY`

`VGLM_OP294_Q1_Q8`

`VGLM_OP294_COVERAGE`

`VGLM_OP294_EVIDENCE_REGISTER`

`VGLM_OP294_POST_SCAN_DELTA`

`VGLM_OP294_OP288_RECOMMENDATION`

`VGLM_OP294_TERMINAL`

## RELATIONS

op-287 (returned matrix) / op-288 (held mutation-atlas successor) / li-1000 / li-1012 / li-1013 /
arranger-rulebook Rule 11.

feedback: `arranger_gate_sizing_delegation`, `artifact_identity_needs_content_check`,
`code_reasoned_verdict_is_hypothesis`, `no_conflate_gating_with_readiness`,
`verify_signature_divergence_claims`, `agent_host_isolation`.

## ARRANGER CONSUMPTION — 2026-07-11

Validator verdict: **VALIDATED-SNAPSHOT**, confidence **9/10**; op-288 recommendation:
`RELEASE-AFTER-VALIDATION`. Under Rule 11 the confidence-9 gate stands after light provenance;
Arranger2 did not repeat the XL review.

Light checks reproduced the exact local matrix identity: 47,630 bytes / 365 lines / SHA-256
`ec119b1f3f24ff5f46757f05e289d0d94ecc4f52ee6077e4f1cb1998a4e6e5eb`, mtime
2026-07-10T22:18:02+1200. The tail still contains the explicit stop condition: op-287 complete,
no product/control mutation, and op-288 not started. Oracle2 remains non-Git, so the matrix's
publication classification stays local-only; the content identity is nevertheless sufficient for
the foundation-only successor.

The accepted gate reports Q1-Q8 all satisfied, 58 atomic claims across li-1001…li-1008 plus seven
li-1012/li-1013 cross-cut rows, 16/16 accessible evidence hashes matching, all named high-risk
claims checked, and zero reasoning-invalidating post-scan deltas. Its disclosed sampling and
unread portions do not affect the decisive release recommendation. The unresolved 8-vs-9 doctrine
conflict is not triggered by this confidence-9 result and remains Coordinator-pending.

Administrative deltas are routed separately: id-029/op-187 closure is reconciled first-hand;
li-1012 is restored to li-1000's constituent table; current IDQ/Gatekeeper/ASL changes are bound as
freshness inputs to op-288. op-294 and parent op-287 retire and leave the live ROB; op-288 advances
Hold→Ready, still requiring Coordinator dispatch and Oracle2 serialization.
