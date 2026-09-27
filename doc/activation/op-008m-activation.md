# op-008m — META Validator3: gate op-007m unified-journal method review and corrected contract

op-008m | lane: **META / INDEPENDENT XL METHOD GATE — does not consume a project ROB number** |
role: **Validator — first-hand governance/protocol validation** | EXU: **validator3, workspace
`/Users/me/wip-mach/rmx-validator3/`** | state: **[Retired — VALIDATED-METHOD-WITH-CORRECTIONS at
confidence 8/10; narrow Arranger Arbiter check consumed and applied the corrected contract]** |
parent: **op-007m / Coordinator
2026-07-22 one-journal directive** | authored: **2026-07-22 by Arranger2**

Assignment rationale: validator3 is the available concrete independent Validator EXU, previously
used for op-320/op-321, and authored neither the Arranger method nor the op-007m Oracle note.

DISPATCH: **CONSUMED** — Validator return adjudicated; no further Validator required.

## RETURN / NARROW ARBITER ADJUDICATION — 2026-07-22

Validator3 returned `VALIDATED-METHOD-WITH-CORRECTIONS`, confidence 8/10, with all load-bearing
identities matched. It accepted M1-M5, S1, corrected S2, S3-S5, C1, and C3; rejected appending to
the immutable archive (C2) and corrected the failure matrix from `4/11/0/0` to
`SAFE 2 / CORRECTABLE 13 / BLOCKING 0 / INCONCLUSIVE 0`.

Because confidence is below 9, the Arranger rechecked the decisive current/frozen clauses,
authority split, archive segment identity, Rule-9 contradiction, and SWAP state ordering
first-hand. Final call:

- adopt M1-M5, S1/S2*/S3-S5, C1, and C3;
- move the exact 310,808-byte / 4,177-line frozen segment to immutable
  `arranger-swap-legacy-frozen-cp103.md`, preserving SHA-256
  `c4e2068900bd74c602865c7e11ff48627d7f164b0c347d8c9407692e237b009d`;
- drop C2 for that companion permanently;
- require content identities when resolving duplicate journal IDs; and
- require both SWAPIN entry and mutex-header readiness to say `ACTIVE` before work, removing the
  proposed long-lived `VERIFYING` cache mismatch.

The corrected contract is applied in `AGENTS.md`, Arranger Rule 15, and `arranger-swap.md`. No
product/Ruler/Oracle/Validator workspace, runtime, guest, image, privilege, commit, or push is part
of this adjudication. op-007m and op-008m retire; Coordinator's one-journal intent is now the active
method.

## DISTINGUISHING QUESTION

After first-hand checking Oracle's premises and exact M1-M5/S1-S5/C1-C3 proposals, is one active
Arranger journal safe and simpler enough to adopt, and what is the smallest exact correction set
that preserves one-writer, crash/restart, and SWAPOUT/SWAPIN invariants without recreating parallel
bookkeeping?

This gate validates method facts and proposed contract text. It does not authorize product work,
change seat ownership, edit control files, adopt the method, or decide project readiness.

## EXECUTION / WRITE BOUNDARY

Run read-only from `/Users/me/wip-mach/rmx-validator3/`. Return the report in chat only; create no
deliverable or activation file. Write no Validator, Arranger, Oracle, product, Ruler, host, image,
or other file. No build, test execution, target execution, guest, mount, privilege, network,
commit, push, op/ID allocation, dispatch, adjudication, retirement, or SWAP action.

At authoring the validator3 workspace is a plain non-Git directory containing exactly:

- `AGENTS.md` — 2,009 bytes / 49 lines / SHA-256
  `8e0aee797c72aba148055addfd89b0db34bf23e28ed074361403178e956093bd`;
- `validator-rulebook.md` — 8,067 bytes / 137 lines / SHA-256
  `680284deaacd95254b81b32758185b5286364c6343dd59bda42264e93dbd5073`.

Read both first and preserve them. Stop `BLOCKED WRONG-WORKSPACE` if the execution root or census
differs.

## PINNED INPUTS

Oracle return:

- `/Users/me/wip-mach/rmx-oracle/op-007m-arranger-unified-continuity-review.md`;
- 31,537 bytes / 451 lines / SHA-256
  `6defec43c73d67e7c737822f78efc52391930f6ba01a1c52ea7c1884d817dc76`;
- recommendation `METHOD-RECOMMEND-ADOPT-WITH-CORRECTIONS`, confidence 8/10;
- required marker count: nine `O3_OP007M_*` markers.

Original Oracle3 workspace control:

- `/Users/me/wip-mach/rmx-oracle3/op-319-mach-ipc-libdispatch-foundation-review-round2.md`;
- 41,135 bytes / 575 lines / SHA-256
  `0f2ed556adfcbee6c542cb6d38810bda3ec1c68ecad2c6434b5ed3dc12b62d53`;
- no op-007m file may exist in `/Users/me/wip-mach/rmx-oracle3/`.

Canonical Arranger workspace `/Users/me/wip-mach/rmx-arranger/`:

- `main@f56170cf4ff88340ad5d960337e1714d9bc8b413`, tree
  `415019160e7a65c6fb95a48b744e7ab01f2ea5b2`;
- `origin/main@2ab525f04f0983755604f3d9117fa4093100521e`, ahead/behind `50/0`;
- intentionally dirty/live; do not clean, stash, reset, or attribute the cumulative diff solely to
  this method change;
- `doc/activation/op-007m-activation.md` — 16,871 bytes / 353 lines /
  SHA-256 `3ce41eaa1e0705529fbc63f16bda5375b5043463ae28fac4d8f4d827b113f5c9`, state `[Done]` means returned, not accepted;
- `AGENTS.md` — 3,802 bytes / 60 lines / SHA-256
  `ed267c3043a296187297fa8f836927b6d76fc419a8927c3a4875f72ae825687e`;
- `arranger-rulebook.md` — 13,154 bytes / 189 lines / SHA-256
  `018a9187aa90a68d499e6a929c27d4c4515d22e20d68360abeebe8b2b87ec94c`;
- current `arranger-swap.md` authoring census — 317,348 bytes / 4,302 lines /
  SHA-256 `3a0f13fb4ae002e3d9b4325af50511a4581effed9e9b4d59cceb9c1b28c0aa36`.

The Oracle-reviewed immutable segments remain load-bearing:

| Segment | Bytes | Lines | SHA-256 |
|---|---:|---:|---|
| protocol prefix through `## Unified continuity journal` | 3,615 | 76 | `3bdfd53603552a75622e7f0e3c8e5d6f5005360b073d612c1cd2fe3e054b580e` |
| journal seed `j-20260722-001` through `j-20260722-002` | 1,836 | 30 | `b02c2640d42fb490238f709de33fbac9de629d5364462cb61546da6acf25b8dd` |
| frozen archive marker through EOF | 310,808 | 4,177 | `c4e2068900bd74c602865c7e11ff48627d7f164b0c347d8c9407692e237b009d` |

Later well-formed `j-*` entries between the seed and frozen marker are expected. Inventory them;
they are not drift. Stop `BLOCKED IDENTITY-DRIFT <fact>` on any other load-bearing mismatch.

## REQUIRED READS

Read completely:

1. op-007m activation and Oracle return;
2. `AGENTS.md`, `arranger-rulebook.md`, and the active prefix/current journal of
   `arranger-swap.md`;
3. `roles.md`, `discovery-implementation-pipeline.md`, `terminology.md` section 6,
   `op-brief-forms.md`, and `rob-mini-format.md` where authority or state semantics are relevant;
4. frozen swap-protocol sections containing the old one-writer epoch re-read, conflict precedence,
   VERIFYING/RECOVERY, standalone/automatic SWAPOUT, dead-seat waiver, stale-seat handling, and the
   closed-epoch drift cited by Oracle.

Use primary files, exact hashes, heading/entry counts, and direct text comparisons. This is a
static method gate; do not demand a destructive seat-crash experiment. Clearly label analytic
failure-mode conclusions.

## G1 — IDENTITY, REASSIGNMENT, AND COMPLETENESS

Verify all pins, Oracle return size/hash/markers/report, and the unchanged Oracle3 workspace.
Determine whether the first wrong-workspace stop followed by explicit Coordinator reassignment and
path transposition is procedurally acceptable or leaves a provenance defect. Confirm the Oracle
did not write Arranger/Oracle3/product state.

Return `MATCH`, `MATCH-WITH-PROVENANCE-NOTE`, or `BLOCKED IDENTITY-DRIFT <fact>`.

Marker: `V3_OP008M_INPUT_IDENTITY`

## G2 — ONE-LOG AUTHORITY GRAPH

Reconstruct the live authority graph from current governing text. Validate or correct:

- journal = chronology only;
- activation headers = op state;
- IDQ = problem state;
- Git/hashes = artifact state;
- mutex = current writer authority;
- Rule-13 chat ROB and SWAPOUT compact ROB = derived renderings/snapshots, not maintained state.

Decide whether Oracle's `FIRST-HAND-CONSISTENT` result is sound and whether M3 explicit conflict
precedence is MUST, SHOULD, redundant, or wrong. Identify any remaining field duplication that
would recreate the old pickup/task/checkpoint problem.

Marker: `V3_OP008M_AUTHORITY`

## G3 — ARCHIVE / PHYSICAL APPEND REVIEW

Verify the exact 4,177-line / 310,808-byte frozen segment, the 97.5% line ratio, physical insertion
point, and claimed write-amplification direction. Gate M1 independently:

- Does moving the exact segment byte-for-byte to one hash-pinned immutable companion preserve the
  Coordinator's “one log serving both purposes” intent by leaving exactly one **active** log?
- Is the proposed segment/hash/pointer exact, and what safe control-file operation verifies no byte
  loss or overlap?
- Must the companion be permanently immutable, or may C2 append closed epochs? Oracle describes it
  both as “must never be edited” and as optionally appendable-at-close; resolve that contradiction.
- Could a smaller treatment safely leave the archive in-file?

Return `M1-ACCEPT`, `M1-CORRECT <exact text/operation>`, or `M1-REJECT <reason>`.

Marker: `V3_OP008M_ARCHIVE`

## G4 — ONE-ENTRY / RECOVERY CONTRACT

Gate M2, M3, M5 and S1, S2, S4, S5 one by one. At minimum decide:

1. whether Rule 9's pre-spend authorization is correctly modeled as a separate coherent DECISION
   action followed later by an outcome action, preserving one entry per action;
2. the exact boundary that makes read-only work entry-free and prevents unsafe over-batching;
3. whether every shared control write needs an immediate owner/epoch re-read;
4. exact precedence and recovery when authority changes before the journal entry lands;
5. how a torn entry is recognized without confusing wrapped `next:` content;
6. whether a duplicated j-ID can be repaired by `CORRECTION` when the target ID is ambiguous, or
   must instead hard-stop/use content identity/a new unambiguous ID;
7. UTC rollover and latest-entry discovery without matching the template inside a code fence; and
8. whether bounded restart reads are latest SWAP entry + tail + authorities, without reviving a
   pickup snapshot.

Return a compact per-item table: `ACCEPT`, `CORRECT <exact change>`, `REJECT`, or `OPTIONAL`.

Marker: `V3_OP008M_ONE_ENTRY`

## G5 — SWAP STATE MACHINE

Independently derive exact state/write ordering for ordinary work, standalone SWAPOUT,
SWAPIN-driven automatic SWAPOUT, unreachable outgoing seat, successful SWAPIN, failed SWAPIN,
catchup, and stale-seat discovery.

Gate M4 and S3. Resolve these load-bearing ambiguities rather than inheriting Oracle wording:

- Coordinator alone grants/revokes ownership, while a seat may only record that directive;
- whether outgoing `entry → FREE header` is safe and authorized on standalone SWAPOUT;
- incoming first header write (`VERIFYING`) versus the claim that Coordinator changes ownership;
- whether success must update header readiness to `ACTIVE`, or an ACTIVE SWAPIN entry may safely
  coexist with a `VERIFYING` header described as an informational cache;
- which writes, if any, a failed/BLOCKED incoming seat may perform for continuity repair;
- dead-seat waiver and fail-closed detection of an absent SWAPOUT entry; and
- cooperative-mutex limits versus any overclaim of mechanical exclusion.

Return a minimal transition table naming actor, precondition, first write, verification, final
header/entry state, and crash recovery.

Marker: `V3_OP008M_SWAP_STATE`

## G6 — FAILURE MATRIX AND QUANTIFICATION

Re-evaluate all 15 Oracle scenarios and its `SAFE 4 / CORRECTABLE 11 / BLOCKING 0 /
INCONCLUSIVE 0` totals. Correct inconsistent classifications, especially:

- ordinary state-changing work called `SAFE-AS-WRITTEN` while M2 is simultaneously mandatory;
- journal/authority conflict called safe while M3 is proposed mandatory;
- crash timing around entry/state/header writes;
- duplicate-ID correction ambiguity; and
- archive corruption/write-amplification claims.

Reproduce or correct the before/after record-touch counts, 97.5% archive ratio, ~60x write-size
claim, old pickup-vs-tail Git-state drift, and fresh-seat minimum-read claim. Approximation must be
labeled; do not convert an analytic model into runtime proof.

Marker: `V3_OP008M_FAILURE_MATRIX`

## G7 — MINIMUM FINAL CONTRACT / DISPOSITION

Return:

1. exact `MUST`, `SHOULD`, and `DROP/DEFER` lists using Oracle labels where possible;
2. corrected replacement wording for every MUST item;
3. a no-more-than-five-step ordinary-work procedure;
4. a no-more-than-seven-step SWAPOUT/SWAPIN procedure;
5. exact archive disposition and verification; and
6. whether the current method may remain in provisional use for ordinary non-swap work while the
   corrections wait, or must stop immediately.

Do not edit the protocol. Do not restore pickup snapshots, task-NNN, cp-NNN, or coordination
summaries under new names. Do not turn the correction into a tool/database/service project.

Marker: `V3_OP008M_CORRECTED_CONTRACT`

## G8 — VERDICT / CONFIDENCE

Return exactly one:

- `VALIDATED-METHOD-AS-WRITTEN`;
- `VALIDATED-METHOD-WITH-CORRECTIONS <exact accepted correction IDs>`;
- `VALIDATED-PARTIAL <accepted / rejected portions>`;
- `REJECTED-METHOD-REVIEW <reason>`; or
- `BLOCKED IDENTITY-DRIFT <fact>`.

State separately:

- `disposition: ADOPT-NOW <exact edits>` or `DO-NOT-ADOPT-YET <reason>`;
- whether op-007m may retire after the corrections are recorded;
- whether any second Validator is required for a still-unresolved fact; and
- that the verdict itself changes no control file or mutex state.

Attach confidence 1-10 under the validator rulebook. Confidence 9+ permits the Arranger to consume
this gate after a light provenance check; below 9 requires narrow Arbiter adjudication.

Markers: `V3_OP008M_VERDICT`, `V3_OP008M_TERMINAL`

## REQUIRED RETURN

Start with the Validator3 header:

```text
op:           op-008m
validator:    validator3
score:        <n>/10
verdict:      <one G8 verdict>
primary-access: <y/n — exact files read>
Distinguishing question: After first-hand checking M1-M5/S1-S5/C1-C3, what exact minimum contract safely preserves one active journal and swap recovery?
```

Then include:

```text
REPORT
op:                    op-008m
validator:             validator3
input_identity:        <MATCH|MATCH-WITH-PROVENANCE-NOTE|BLOCKED>
authority:             <validated/corrected/rejected>
archive:               <M1 result + immutable/append disposition>
one_entry:             <per-item M2/M3/M5/S1/S2/S4/S5 result>
swap_state:            <M4/S3 result>
failure_matrix:        <exact counts + material corrections>
corrected_contract:    <MUST/SHOULD/DROP-DEFER summary>
verdict:               <one G8 verdict>
confidence:            <1-10>
disposition:           <ADOPT-NOW exact edits|DO-NOT-ADOPT-YET reason>
second_validator:      <required/not-required + reason>
boundary:              read_only=1 builds=0 tests=0 target_exec=0 guest_cells=0 privileges=0 writes=0
terminal:              complete
```

Required markers:

```text
V3_OP008M_INPUT_IDENTITY
V3_OP008M_AUTHORITY
V3_OP008M_ARCHIVE
V3_OP008M_ONE_ENTRY
V3_OP008M_SWAP_STATE
V3_OP008M_FAILURE_MATRIX
V3_OP008M_CORRECTED_CONTRACT
V3_OP008M_VERDICT
V3_OP008M_TERMINAL
```

REPORT

```text
op: op-008m
agent: validator3
dispatch: independent XL unified Arranger journal/mutex method gate complete
next-hop: Arranger consumes confidence verdict; Coordinator decides adoption; no protocol or mutex change occurs automatically
```

## RELATIONS / FEEDBACK

op-007m → op-008m; Coordinator 2026-07-22 one-journal directive; Arranger Rules 9, 13, 15;
legacy meta precedents op-001m/op-002m/op-005m/op-006m/op-147m.

feedback: `primary_artifact_first`, `convergence_before_verdict`, `one_writer`,
`append_only_recovery`, `op_state_dispatch_boundary`, `no_conflate_gating_with_readiness`,
`agent_host_isolation`, `oracle_is_consult_not_validator`.
