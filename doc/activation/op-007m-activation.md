# op-007m — META Oracle3: review the unified Arranger continuity journal and swap protocol

op-007m | lane: **META / METHOD REVIEW — does not consume a project ROB number** | role:
**Oracle consult — architecture and failure-mode synthesis only** | EXU: **Oracle3, workspace
`/Users/me/wip-mach/rmx-oracle3/`** | state: **[Retired — Oracle consult consumed through op-008m;
validated correction set applied by narrow Arranger Arbiter review]** | parent: **Coordinator directive,
2026-07-22: replace parallel Arranger work/swap logs with one record serving both purposes** |
authored: **2026-07-22 by Arranger2**

Assignment rationale: Oracle3 owns the recent independent op-319 consult workspace, is available as
a concrete Oracle EXU, and did not author the Arranger method being reviewed.

DISPATCH: **CONSUMED** — return recorded; no protocol correction adopted by this op.

## RETURN / ARRANGER INTAKE — 2026-07-22

The first Oracle seat correctly stopped `CONSULT-INCONCLUSIVE WRONG-WORKSPACE`. The Coordinator then
explicitly reassigned op-007m to that Oracle seat and authorized the deliverable-path transposition.
The completed consult is:

- `/Users/me/wip-mach/rmx-oracle/op-007m-arranger-unified-continuity-review.md`;
- 31,537 bytes / 451 lines / SHA-256
  `6defec43c73d67e7c737822f78efc52391930f6ba01a1c52ea7c1884d817dc76`;
- all nine required `O3_OP007M_*` markers and the terminal REPORT are present;
- `/Users/me/wip-mach/rmx-oracle3/` still contains only its pinned op-319 file, byte-identical at
  SHA-256 `0f2ed556adfcbee6c542cb6d38810bda3ec1c68ecad2c6434b5ed3dc12b62d53`.

Oracle recommends `METHOD-RECOMMEND-ADOPT-WITH-CORRECTIONS`, confidence 8/10: MUST M1-M5,
SHOULD S1-S5, COULD C1-C3. The return is sized **XL** because it changes mutex recovery,
one-writer, crash, archive, and Rule-9 semantics. Per Arranger Rules 6/11, `[Done]` means returned
only; no recommendation is adopted until independent meta Validator op-008m gates it.

## RETIREMENT

op-008m independently validated the one-active-log design with corrections at confidence 8/10.
The Arranger performed the required narrow Arbiter check, applied the accepted correction set, and
retired this consult. The method—not the Oracle recommendation by itself—is authoritative in the
current `arranger-swap.md` and Rule 15.

## PURPOSE

Review the newly simplified Arranger continuity method first-hand. Determine whether one mutex plus
one append-only journal can safely serve ordinary work logging, catchup, restart, and
SWAPOUT/SWAPIN without recreating parallel state or weakening one-writer and recovery guarantees.

This is a process-design consult, not a validation or acceptance lane. The current text is a
Coordinator-directed provisional method. Oracle3 may recommend bounded corrections but may not
edit it, adjudicate adoption, change the mutex, allocate IDs/ops, or alter the ROB.

Project context: this is ordinary open-source operating-system workflow governance. No product or
security-sensitive execution is involved.

## REPOSITORY / WRITE BOUNDARY

Oracle3 may write exactly one deliverable in its own workspace:

`/Users/me/wip-mach/rmx-oracle3/op-007m-arranger-unified-continuity-review.md`

All inputs are read-only. Do not edit `/Users/me/wip-mach/rmx-arranger/`, any product/Ruler/
Validator/other Oracle workspace, host configuration, images, or external state. No build, test
execution, target execution, guest cell, mount, privilege, network action, commit, or push.

At authoring, `/Users/me/wip-mach/rmx-oracle3/` is a dedicated plain workspace, not a Git repo, and
contains one pre-existing file:

`op-319-mach-ipc-libdispatch-foundation-review-round2.md` — 41,135 bytes / 575 lines / SHA-256
`0f2ed556adfcbee6c542cb6d38810bda3ec1c68ecad2c6434b5ed3dc12b62d53`.

Verify that identity before and after the consult and preserve it byte-for-byte. The op-007m output
path must be absent before work. Stop `CONSULT-INCONCLUSIVE WRONG-WORKSPACE` without writing if the
writable root is not exactly the Oracle3 path above.

## PINNED INPUT IDENTITY

Canonical Arranger workspace:

- path: `/Users/me/wip-mach/rmx-arranger/`;
- branch/HEAD: `main@f56170cf4ff88340ad5d960337e1714d9bc8b413`;
- tree: `415019160e7a65c6fb95a48b744e7ab01f2ea5b2`;
- origin/main: `2ab525f04f0983755604f3d9117fa4093100521e`;
- ahead/behind origin/main: `50/0`;
- working tree: intentionally large and dirty; preserve it and do not clean/stash/reset.

Review these exact current files. The first two full-file identities are load-bearing. The
`arranger-swap.md` full-file identity is its authoring census; its three anchor-delimited identities
below are the load-bearing review inputs so a later valid journal-tail entry does not create false
drift.

| Path | Bytes | Lines | SHA-256 |
|---|---:|---:|---|
| `AGENTS.md` | 3,802 | 60 | `ed267c3043a296187297fa8f836927b6d76fc419a8927c3a4875f72ae825687e` |
| `arranger-rulebook.md` | 13,154 | 189 | `018a9187aa90a68d499e6a929c27d4c4515d22e20d68360abeebe8b2b87ec94c` |
| `arranger-swap.md` authoring census | 316,261 | 4,285 | `7c62a00ff8c568b585d92c426145f426364037793add11cb2218f0bd297fbe70` |
| protocol prefix: line 1 through `## Unified continuity journal` inclusive | 3,615 | 76 | `3bdfd53603552a75622e7f0e3c8e5d6f5005360b073d612c1cd2fe3e054b580e` |
| commissioned journal seed: `j-20260722-001` through the final `next` line of `j-20260722-002` | 1,836 | 30 | `b02c2640d42fb490238f709de33fbac9de629d5364462cb61546da6acf25b8dd` |
| frozen archive: `## Legacy continuity archive — frozen through cp-103` through EOF | 310,808 | 4,177 | `c4e2068900bd74c602865c7e11ff48627d7f164b0c347d8c9407692e237b009d` |

Stop and report `IDENTITY-DRIFT` if either complete governing file or any load-bearing
anchor-delimited `arranger-swap.md` identity differs. A changed full `arranger-swap.md` hash is
expected if and only if the difference is one or more well-formed later `j-*` entries between the
seed block and frozen-archive marker; inventory that tail and continue. Any other change is drift.
HEAD/origin or unrelated working-set drift is reportable context, but it is not by itself
permission to inspect or repair unrelated changes.

Early-stop routes:

- wrong writable workspace or a pre-existing op-007m output → return inline with
  `terminal: CONSULT-INCONCLUSIVE WRONG-WORKSPACE`; do not write;
- load-bearing input mismatch → write only the commissioned deliverable if the Oracle3 workspace
  is valid, record the exact mismatch, and return `terminal: BLOCKED IDENTITY-DRIFT`;
- recommendation and score fields below are required only after `input_identity: MATCH`.

Important provenance limit: the working-tree diff is cumulative across the active Arranger epoch
and is **not** a clean method-only patch. Do not attribute every `git diff HEAD` hunk to this
simplification. The commissioned method delta is the current content of:

1. the `Seat-control gate and sole continuity log` paragraph in `AGENTS.md`;
2. Rule 9's `pre-spend continuity-journal entry` phrase and all of Rule 15 in
   `arranger-rulebook.md`;
3. `arranger-swap.md` from its status/mutex through `Current protocol`, `Unified continuity
   journal`, and the `Legacy continuity archive — frozen through cp-103` boundary.

The old pickup/task/coordination/checkpoint material below that boundary is historical evidence,
not a second active method. If a causal before/after claim cannot be reproduced from the available
records, label it `UNVERIFIABLE`; do not infer drift.

## REQUIRED READS

Read first-hand:

- complete `AGENTS.md` and `arranger-rulebook.md`;
- the complete active protocol and unified-journal section of `arranger-swap.md`;
- a heading/identifier census across the full `arranger-swap.md`, plus enough beginning/end archive
  inspection to assess whether frozen material can be mistaken for live state;
- `roles.md`, `discovery-implementation-pipeline.md`, `terminology.md` section 6,
  `op-brief-forms.md`, and `rob-mini-format.md` where they define authority, op/meta-op state,
  handoff, or ROB rendering.

Do not re-adjudicate historical ops or product facts embedded in the frozen archive.

Use these evidence labels:

- `FIRST-HAND-CONSISTENT` — current texts jointly establish the claimed invariant;
- `FIRST-HAND-CONTRADICTION` — two current requirements cannot both be obeyed as written;
- `DESIGN-RISK` — internally possible but underspecified or failure-prone;
- `UNVERIFIABLE` — the available current records cannot establish the claim;
- `OUT-OF-SCOPE` — unrelated to this method.

## Q1 — AUTHORITY AND DUPLICATION

Reconstruct the exact authority graph among:

- live mutex owner/epoch/readiness;
- the unified chronological journal;
- activation headers for op state;
- IDQ index/files for problem state;
- Git/content hashes for artifact state; and
- Rule 13's complete compact ROB in adjudication/dispatch replies.

Decide whether the text leaves exactly one chronological log or silently recreates a second one.
In particular, determine whether ordinary journal entries, SWAPOUT's compact ROB, and Rule 13's chat
ROB can remain references/views rather than competing state authorities. Identify every field that
is unnecessarily copied and every field that is missing for recovery.

Marker: `O3_OP007M_AUTHORITY`

## Q2 — ONE-ENTRY AND APPEND-ONLY SEMANTICS

Test the one-entry rule as an executable protocol, not a slogan. Resolve or flag:

1. Rule 9 requires a **pre-spend** journal entry before irreversible delegated work, while the
   current one-entry rule says append one outcome/state-delta entry **after** each action. Can one
   immutable entry satisfy both? If not, give the smallest safe exception or replacement.
2. New journal entries are logically added above the frozen archive, not literally appended at
   end-of-file. Define whether this is append-only, whether insertion is safe, and whether the
   archive should move to an immutable companion file without becoming a second active log.
3. Define a falsifiable boundary for one `coherent action or batch`; prevent both entry spam and
   over-batching that loses intermediate authority/spend decisions.
4. Check `CORRECTION` semantics, day-local monotonic IDs, UTC/day rollover, duplicate IDs, partial
   writes, malformed entries, and references to missing/moved authoritative files.
5. Decide whether the latest delta-only entry is sufficient for a fresh seat, or whether it needs a
   bounded recovery summary without restoring the old pickup snapshot.

Return exact minimal wording for any correction; do not rewrite unrelated doctrine.

Marker: `O3_OP007M_ONE_ENTRY`

## Q3 — MUTEX / SWAP STATE MACHINE

Write the smallest state-transition model for `ACTIVE`, `SWAPOUT`, inactive/catchup, Coordinator
ownership transfer, and `SWAPIN`. For each transition identify:

- who alone may write;
- whether the mutex header changes, and in what order relative to the journal entry;
- how the old seat is prevented from writing;
- what a new seat verifies before becoming active;
- the recovery rule if a process dies before, during, or after either write; and
- how a failed/mismatched SWAPIN remains fail-closed.

The current text says the mutex changes only on SWAPIN/SWAPOUT/control correction, says SWAPOUT
appends then becomes read-only, and says the Coordinator changes ownership for SWAPIN. Determine
whether SWAPOUT mutex ownership/state is actually specified or ambiguous.

Marker: `O3_OP007M_SWAP_STATE`

## Q4 — FAILURE-MODE MATRIX

Evaluate at least these scenarios independently:

1. ordinary read-only action;
2. ordinary state-changing control action;
3. a deliberate multi-op batch;
4. delegated irreversible spend requiring Rule 9;
5. correction of a wrong prior entry;
6. crash before journal write;
7. crash during journal write;
8. crash after journal write but before external action or state-file update;
9. crash after state-file update but before journal write;
10. two seats attempt writes concurrently;
11. journal state conflicts with activation/IDQ/Git authority;
12. inactive-seat catchup while newer entries arrive;
13. UTC day rollover / duplicate sequence allocation;
14. restart or context compaction with only the latest entry read; and
15. growth of the 300-KiB frozen archive.

For each return `SAFE-AS-WRITTEN`, `CORRECTABLE <minimum change>`, `BLOCKING <failure>`, or
`INCONCLUSIVE <missing fact>`. A safe result must state the invariant that prevents false ownership,
lost work, duplicated spend, or stale handoff.

Marker: `O3_OP007M_FAILURE_MATRIX`

## Q5 — SIMPLICITY / OPERATING COST

Assess whether the new method actually lowers Arranger context and write amplification. Quantify,
where possible:

- records touched per ordinary action, dispatch/return, decision, and swap;
- duplicated live-state fields before versus after;
- minimum reads for a fresh seat and an inactive catchup;
- ambiguity caused by the frozen archive remaining in the active file; and
- a bounded retention/archive approach that preserves one **active** log.

Do not optimize away evidence needed for one-writer safety or crash recovery. Do not propose a
database, service, automation project, or broad governance rewrite unless the file method is shown
incapable of meeting its invariants.

Marker: `O3_OP007M_SIMPLICITY`

## Q6 — MINIMUM CORRECTED CONTRACT

Return:

1. an invariant list of no more than 12 items;
2. a ranked `MUST / SHOULD / COULD` correction list;
3. exact replacement text only for clauses that must change;
4. a five-step maximum operator procedure for ordinary work;
5. a seven-step maximum procedure for SWAPOUT→SWAPIN; and
6. a clear answer on whether the frozen archive stays in-file, moves to one immutable legacy file,
   or requires another bounded treatment.

Preserve the Coordinator's core intent: one active chronological journal serves both ordinary work
and handoff. Do not restore task-NNN, cp-NNN, pickup snapshots, or coordination summaries under new
names.

Marker: `O3_OP007M_CORRECTED_CONTRACT`

## Q7 — SYNTHESIS

Return one recommendation:

- `METHOD-RECOMMEND-ADOPT`;
- `METHOD-RECOMMEND-ADOPT-WITH-CORRECTIONS <items>`;
- `METHOD-RECOMMEND-REVISE <blocking flaws>`; or
- `CONSULT-INCONCLUSIVE <missing facts>`.

These recommendation forms apply only after the input identity matches. Use the early-stop routes
above otherwise.

Score 1–10 separately:

- simplicity;
- authority clarity;
- crash/restart safety;
- swap concurrency safety; and
- operational maintainability.

State confidence 1–10. Oracle's recommendation is a hypothesis for Arranger/Validator intake, not
an acceptance or governance decision.

Markers: `O3_OP007M_SYNTHESIS`, `O3_OP007M_TERMINAL`

## REQUIRED REPORT

Completed consult after identity match:

```text
REPORT
op:                    op-007m
oracle:                Oracle3
deliverable:           /Users/me/wip-mach/rmx-oracle3/op-007m-arranger-unified-continuity-review.md / <bytes> / <lines> / <sha256>
input_identity:        <MATCH|IDENTITY-DRIFT with exact details>
authority:             <FIRST-HAND-CONSISTENT|FIRST-HAND-CONTRADICTION|DESIGN-RISK summary>
one_entry:             <result; pre-spend and logical-append disposition>
swap_state:            <result; ownership/write-order disposition>
failure_matrix:        <safe/correctable/blocking/inconclusive counts>
simplicity_score:      <1-10>
authority_score:       <1-10>
crash_safety_score:    <1-10>
concurrency_score:     <1-10>
maintainability_score: <1-10>
recommendation:        <one allowed recommendation>
confidence:            <1-10>
boundary:              read_only_inputs=1 builds=0 tests=0 target_exec=0 guest_cells=0 privileges=0 product_writes=0 control_writes=0
terminal:              CONSULT-COMPLETE
```

Early stop:

```text
REPORT
op:                    op-007m
oracle:                Oracle3
deliverable:           <absolute path + identity, or none for WRONG-WORKSPACE>
input_identity:        <IDENTITY-DRIFT|not checked due WRONG-WORKSPACE, with exact fact>
boundary:              read_only_inputs=1 builds=0 tests=0 target_exec=0 guest_cells=0 privileges=0 product_writes=0 control_writes=0
terminal:              BLOCKED IDENTITY-DRIFT|CONSULT-INCONCLUSIVE WRONG-WORKSPACE
```

Required markers:

```text
O3_OP007M_INPUT_IDENTITY
O3_OP007M_AUTHORITY
O3_OP007M_ONE_ENTRY
O3_OP007M_SWAP_STATE
O3_OP007M_FAILURE_MATRIX
O3_OP007M_SIMPLICITY
O3_OP007M_CORRECTED_CONTRACT
O3_OP007M_SYNTHESIS
O3_OP007M_TERMINAL
```

REPORT

```text
op: op-007m
agent: Oracle3
dispatch: read-only unified Arranger work/swap journal review complete
next-hop: Arranger verifies identity and sizes the return; L/XL findings route to an independent Validator before changing the protocol
```

## RELATIONS / FEEDBACK

Relations: Coordinator 2026-07-22 simplification directive; `AGENTS.md`; Arranger Rules 9, 13, and
15; `arranger-swap.md`; meta-op namespace precedent op-147m/op-005m/op-006m.

feedback: `one_writer`, `verify_first_hand`, `op_state_dispatch_boundary`,
`no_conflate_gating_with_readiness`, `artifact_identity_needs_content_check`,
`append_only_recovery`, `agent_host_isolation`, `oracle_is_consult_not_validator`.
