# op-009m — META CATCHUP: Arranger1 learns the corrected unified continuity method

op-009m | lane: **META / INACTIVE-SEAT CATCHUP — does not consume a project ROB number** |
role: **Arranger1 (Fable), inactive seat; read-only acknowledgement only** | EXU: **the other
Arranger session, reading `/Users/me/wip-mach/rmx-arranger/` read-only** | state: **[Retired —
CATCHUP-COMPLETE through j-20260722-004; identity matched; zero writes; ownership unchanged]** |
parent: **op-007m / op-008m / `j-20260722-004`** | authored: **2026-07-22 by Arranger2 at
Coordinator request**

DISPATCH: **CONSUMED — Coordinator relayed; chat-only acknowledgement accepted 2026-07-22.**

## RETURN / ARRANGER INTAKE — 2026-07-22

Arranger1 returned all four required markers and `CATCHUP-COMPLETE`. It reproduced the immutable
target through `j-20260722-004`, reported `j-20260722-005` as the expected visible tail, restated
the authority split, owner/epoch fence, Rule-9 sequencing, immutable-entry/duplicate-ID rules,
SWAP ordering, dual-ACTIVE gate, bounded recovery, and frozen-companion boundary in its own words.

The return records `read_only=1`, `writes=0`, `journal_appends=0`, `commits=0`, and `pushes=0`;
ownership remained Arranger2 / `swap-20260710T234047Z-arranger2` / ACTIVE. The later
`j-20260722-006` full-terminal-op presentation rule and its governing-file hashes postdate the
reported read snapshot. That is a bounded later-tail catchup item, not identity drift and not a
reason to withhold retirement of this through-j-004 contract.

## DIRECTIVE

```text
CATCHUP Arranger1 THROUGH j-20260722-004
```

Read and acknowledge the corrected one-active-journal method adopted after Oracle op-007m,
Validator op-008m, and the required narrow Arranger Arbiter check. Return the acknowledgement in
chat only. Do not create a deliverable file or persistent acknowledgement.

This op does not grant ownership, revoke Arranger2, change the mutex, or authorize ordinary
Arranger work. Arranger1 remains inactive and read-only throughout.

## INPUT IDENTITY — STOP READ-ONLY ON MISMATCH

Workspace: `/Users/me/wip-mach/rmx-arranger/`.

- Git HEAD `f56170cf4ff88340ad5d960337e1714d9bc8b413`, tree
  `415019160e7a65c6fb95a48b744e7ab01f2ea5b2`, origin/main
  `2ab525f04f0983755604f3d9117fa4093100521e`, ahead/behind `50/0` at authoring. Existing dirty
  state is expected and must not be modified, cleaned, staged, committed, or normalized.
- `AGENTS.md`: 3,938 bytes / 62 lines / SHA-256
  `8e963b35e3563c6ad3e36ad93647fa19f18b2e3256d0cb7ca0f43f29c237655d`.
- `arranger-rulebook.md`: 13,482 bytes / 192 lines / SHA-256
  `b6685dc3f383c09051cb27598daa742f1e0fa94eccc727932263ceae0dcf9a77`.
- `arranger-swap.md` immutable prefix through the terminal line of `j-20260722-004`: first 189
  lines, 11,741 bytes, SHA-256
  `379aee8b5f270881f59c74404a42eae3d46f497f9cdf807e7bcb182235915365`.
- Current protocol prefix through `## Unified continuity journal`: first 126 lines, 7,546 bytes,
  SHA-256 `be501ff1fd1c6f6a91f8c31960436a06049dc092a10b49a80be49a15c39cb07e`.
- `j-20260722-004` block: 1,270 bytes / 14 lines / SHA-256
  `bc0bd33f51e96591a2a1cdb44c3738e9914f2dc5b5d3183e22d29d5b3382b126`.
- `arranger-swap-legacy-frozen-cp103.md`: stat/hash only — 310,808 bytes / 4,177 lines /
  SHA-256 `c4e2068900bd74c602865c7e11ff48627d7f164b0c347d8c9407692e237b009d`.
- `doc/activation/op-007m-activation.md`: retired, 17,141 bytes / 359 lines / SHA-256
  `db78548fb6415112b627fa89bb22c2038722da8ee395e716581e3798c4b594ad`.
- `doc/activation/op-008m-activation.md`: retired, 15,680 bytes / 335 lines / SHA-256
  `c114c47aa17641dcf568c8feea1a3d34c9953c4a14ff70546a2997c2229ee02d`.

Later complete journal entries after `j-20260722-004` are the visible tail and are not identity
drift. Census them read-only, but the catchup target remains `j-20260722-004`.

If a pinned governing input differs, return `CATCHUP-BLOCKED IDENTITY-DRIFT <fact>`. If mutex
ownership, epoch, or readiness differs from the expected state below, return
`CATCHUP-BLOCKED SEAT-STATE-DRIFT <fact>`. Make no repair.

## REQUIRED READS

Read first-hand:

1. `AGENTS.md` completely.
2. `arranger-rulebook.md` completely, especially Rules 9, 13, and 15.
3. The complete active `arranger-swap.md` protocol and journal through `j-20260722-004`; census
   any later real `j-*` headings as visible tail.
4. The RETURN / RETIREMENT sections of `op-007m-activation.md`.
5. The RETURN / NARROW ARBITER ADJUDICATION section of `op-008m-activation.md`.

Do not read the 4,177-line frozen companion beyond the stat/hash check. It is historical evidence,
not current procedure.

## REQUIRED METHOD ACKNOWLEDGEMENT

State in your own words, without proposing edits:

1. `arranger-swap.md` is the sole active chronological Arranger log. Activation headers own op
   state, IDQ owns problem state, and Git/hashes own artifact state.
2. Rule-13 chat ROBs and SWAPOUT compact ROBs are derived views, not parallel authorities or logs.
3. Before any shared control-state write, the active owner re-reads mutex owner/epoch; mismatch
   means stop. This catchup grants no write authority.
4. Read-only inspection owes no entry. A coherent state-changing action owes one complete EOF
   entry. Rule-9 authorization is a prior `DECISION` action; its later outcome is a separate entry.
5. Entries are immutable and complete only with a terminal physical `- next:` field. Corrections
   are additive. Duplicate complete IDs stop ordinary work and require content-identified,
   fail-closed resolution.
6. Standalone SWAPOUT is entry-then-`FREE`; SWAPIN begins only under an explicit Coordinator grant,
   fences with `VERIFYING`, verifies first-hand, and permits work only when both the SWAPIN entry
   and mutex header say `ACTIVE`. Dead-seat transfer never waits for an outgoing final turn.
7. Restart recovery reads the latest complete SWAP entry plus its tail and authoritative state;
   journal claims are hypotheses until reconciled.
8. `arranger-swap-legacy-frozen-cp103.md` is immutable provenance, never appended and never a
   second active log. Pickup/task/checkpoint bookkeeping must not be revived under new names.

Expected ownership after this op remains exactly:

```text
mutex: HELD
owner: Arranger2
epoch: swap-20260710T234047Z-arranger2
readiness: ACTIVE
```

## ZERO-WRITE BOUNDARY

Do not write or edit any file, including this activation, `arranger-swap.md`, activation/IDQ state,
an ACK file, pickup snapshot, task list, checkpoint, local notes, or another repository. Do not
append a journal acknowledgement. No allocation, issue, adjudication, retirement, commit, push,
build, test, product action, runtime, target, guest, image, privilege, or network action.

Return in chat only. The active Arranger may later consume that return as one ordinary journal
entry; Arranger1 does not record its own catchup.

## REQUIRED RETURN

Emit these markers:

```text
A1_OP009M_INPUT_IDENTITY
A1_OP009M_METHOD_ACK
A1_OP009M_BOUNDARY
A1_OP009M_TERMINAL
```

Then return:

```text
REPORT
op:                 op-009m
agent:              Arranger1 (Fable, inactive seat)
catchup_through:    j-20260722-004
input_identity:     MATCH | CATCHUP-BLOCKED <exact fact>
method_ack:         ACKNOWLEDGED | NOT-ACKNOWLEDGED <exact ambiguity>
ownership:          UNCHANGED <Arranger2 / swap-20260710T234047Z-arranger2 / ACTIVE>
visible_tail:       <later complete j-IDs or none>
parallel_log:       NOT-CREATED
discrepancies:      none | <exact discrepancy>
boundary:           read_only=1 writes=0 journal_appends=0 commits=0 pushes=0
terminal:           CATCHUP-COMPLETE | CATCHUP-BLOCKED
```

`CATCHUP-COMPLETE` means the method and boundary are understood; it is not ownership, SWAPIN,
method re-adjudication, or permission to resume work.
