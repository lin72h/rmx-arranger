# Arranger journal

Status: Coordinator-governed **sole continuity log** for the Arranger. Since 2026-09-27 the
workspace runs a **single Arranger seat**, so the two-seat mutex, epoch fence, and SWAP/CATCHUP
handoff are retired. The file keeps the name `arranger-swap.md` because many records link to it.
Pre-unified history is frozen in `doc/archive/arranger-swap-legacy-frozen-cp103.md`.

Canonical workspace: `/Users/me/wip-mach/rmx-arranger/`

## Seat record

- mode: **SINGLE-SEAT** — one Arranger (Claude Opus 5.5); no mutex, epoch, or handoff entries.
- since: 2026-09-27T21:20Z, Coordinator directive (j-20260927-001).
- back to two seats: only by explicit Coordinator directive. Restore the two-seat protocol from
  commit `f1c38f6` (`git show f1c38f6:arranger-swap.md`) and start with a SWAPIN entry.

## Current protocol — single seat

### 1. Authorities

- `arranger-swap.md` is the **only chronological Arranger log**.
- Op files (`doc/activation/op-NNN-activation.md`, read and changed with `tools/rob`) are
  authoritative op state.
- `idq/id-000.md` and individual IDQ files are authoritative problem state.
- Git and content hashes are authoritative artifact state.
- The journal links those records; it does not duplicate them. The Rule-13 board is a rendering
  of op state (`tools/rob board`), not a log. On conflict, the authoritative record wins; append a
  `CORRECTION`.

### 2. When to log

Append one entry at EOF when an op is sent, returns, closes, or is dropped; when a
Coordinator decision is consumed; or when a Rule-9 spend is authorized (log the authorization
before the spend and the result separately after). Related edits for one outcome share one entry.
Reads, drafts, and documentation edits that change no op/IDQ state need no entry; the commit
message is their record. Do not keep a pickup snapshot, task list, or checkpoint alongside it.

```text
### j-<UTC-YYYYMMDD>-<NNN> — <short outcome>
- time / kind: <UTC> / ISSUE | RETURN | DECISION | ACTION | CORRECTION
- outcome: <what became true>
- state delta: <changed op/IDQ states; link authoritative files>
- evidence: <decisive paths/hashes, or none>
- next: <single next action>
```

IDs take the next free sequence number for that UTC date. Entries are immutable; fix a mistake
with a `CORRECTION` entry naming the target j-ID. Older entries keep their historical
owner/epoch fields.

### 3. New session or compaction recovery

Read the journal tail back to the most recent `DECISION` (at least the last five entries), then
confirm it against `now.md`, `tools/rob board`, the IDQ index, and `git status`. Journal text is a
hypothesis until checked; record any divergence as a `CORRECTION`.

### 4. Frozen legacy archive

Pre-unified pickup/task/coordination/checkpoint history through `cp-103` lives byte-verbatim in
`doc/archive/arranger-swap-legacy-frozen-cp103.md`: 310,808 bytes / 4,177 lines / SHA-256
`c4e2068900bd74c602865c7e11ff48627d7f164b0c347d8c9407692e237b009d`. It is historical
provenance, not current procedure. Never edit or append it.

## Unified continuity journal

### j-20260722-001 — unified work/swap journal adopted

- time: 2026-07-22T01:25:56Z
- kind: DECISION
- owner / epoch: Arranger2 / `swap-20260710T234047Z-arranger2`
- outcome: Coordinator replaced parallel pickup/task/checkpoint bookkeeping with this one journal.
  The mutex plus journal now serve both ordinary progress and seat handoff.
- state delta: none. Authoritative live state remains in activation headers and IDQ files. Current
  dispatchable work is op-322 [Ready]; op-319/op-320 remain [Done] on the separate confidence-8
  threshold hold; op-202/op-203/op-279/op-280/op-305/op-308 remain [Hold].
- evidence: method-only control change; no product/EXU/build/runtime/guest/image/privilege action.
- blockers / decisions: op-322 correction must be accepted before PID-1 helper/image work; the
  Validator 8-vs-9 ruling for op-320 remains Coordinator-owned.
- next: dispatch op-322 to `rmx-explorer-rx-x64z`.

### j-20260722-002 — op-007m unified-journal Oracle review authored

- time: 2026-07-22T01:35:42Z
- kind: ISSUE
- owner / epoch: Arranger2 / `swap-20260710T234047Z-arranger2`
- outcome: allocated the next meta-control ID and authored op-007m [Ready] for Oracle3 to review
  the one-journal work/swap method, failure modes, and minimum corrected contract. The meta op does
  not consume project op-323.
- state delta: new meta activation `doc/activation/op-007m-activation.md` [Ready]; project ROB and
  IDQ state unchanged.
- evidence: method-only Oracle consult; one Oracle3-owned deliverable; Arranger/product/Ruler inputs
  read-only; no build/runtime/guest/image/privilege/commit/push authorized.
- blockers / decisions: Oracle findings remain advisory and require Arranger intake; L/XL findings
  route to an independent Validator before protocol changes.
- next: Coordinator dispatches op-007m to Oracle3.

### j-20260722-003 — op-007m returned; op-008m Validator gate authored

- time: 2026-07-22T02:05:49Z
- kind: RETURN
- owner / epoch: Arranger2 / `swap-20260710T234047Z-arranger2`
- outcome: consumed the explicitly reassigned Oracle op-007m return, reproduced its artifact and
  markers, sized the method gate XL, moved op-007m to [Done] returned-only, and authored independent
  Validator3 meta-op op-008m [Ready].
- state delta: `doc/activation/op-007m-activation.md` [Ready] -> [Done]; new
  `doc/activation/op-008m-activation.md` [Ready]. Project ROB and IDQ state unchanged.
- evidence: Oracle return 31,537 bytes / 451 lines / SHA-256
  `6defec43c73d67e7c737822f78efc52391930f6ba01a1c52ea7c1884d817dc76`; all nine markers present;
  Oracle3 op-319 file remains SHA-256 `0f2ed556adfcbee6c542cb6d38810bda3ec1c68ecad2c6434b5ed3dc12b62d53`.
- blockers / decisions: M1-M5/S1-S5/C1-C3 remain advisory and unapplied; op-008m must resolve
  archive immutability, duplicate IDs, Rule-9 sequencing, and SWAP header/readiness ordering.
- next: Coordinator dispatches op-008m to validator3.

### j-20260722-004 — corrected one-active-journal method adopted

- time: 2026-07-22T02:30:16Z
- kind: DECISION
- owner / epoch: Arranger2 / `swap-20260710T234047Z-arranger2`
- outcome: consumed Validator3 op-008m at confidence 8 through the required narrow Arbiter check,
  applied M1-M5 plus S1/S2*/S3-S5/C1/C3, dropped C2 for the frozen companion, and made the corrected
  mutex plus one EOF-append journal the active Arranger method.
- state delta: op-007m and op-008m retired; pre-unified history moved byte-verbatim to immutable
  `arranger-swap-legacy-frozen-cp103.md`; project ROB and IDQ state unchanged; mutex owner/epoch and
  readiness remain Arranger2 / `swap-20260710T234047Z-arranger2` / ACTIVE.
- evidence: archive 310,808 bytes / 4,177 lines / SHA-256 `c4e2068900bd74c602865c7e11ff48627d7f164b0c347d8c9407692e237b009d`; protocol prefix 7,546 bytes / 126 lines / SHA-256 `be501ff1fd1c6f6a91f8c31960436a06049dc092a10b49a80be49a15c39cb07e`; `git diff --check` passed.
- blockers / decisions: no remaining method blocker; duplicate IDs require content-identified fail-closed correction; SWAPIN work requires both entry and header ACTIVE; immutable archive never receives later epochs.
- next: resume the project queue with Coordinator dispatch of op-322.

### j-20260722-005 — op-009m inactive-Arranger catchup brief authored

- time: 2026-07-22T02:42:13Z
- kind: ACTION
- owner / epoch: Arranger2 / `swap-20260710T234047Z-arranger2`
- outcome: authored a zero-write `CATCHUP Arranger1 THROUGH j-20260722-004` meta brief so the
  inactive Arranger can learn the corrected unified continuity method without SWAPIN or a second
  log.
- state delta: op-009m is Ready for Coordinator copy/paste; project ROB, IDQ state, mutex owner,
  epoch, and readiness are unchanged.
- evidence: `doc/activation/op-009m-activation.md` 6,799 bytes / 141 lines / SHA-256
  `439bf1f8aa00924f77680f78cc8b47cbdd0171897d1d61f6bb04249259afdf24`.
- blockers / decisions: Arranger1 must return in chat only; no ACK file, journal append, ownership
  transition, or persistent write is authorized.
- next: Coordinator copy/pastes op-009m to Arranger1; after its read-only acknowledgement, resume project dispatch op-322.

### j-20260722-006 — full terminal op content made the default

- time: 2026-07-22T02:57:55Z
- kind: DECISION
- owner / epoch: Arranger2 / `swap-20260710T234047Z-arranger2`
- outcome: adopted the Coordinator's presentation rule that every generated, shown, prepared, or
  next-dispatch op is returned as its complete normal-form content in one terminal/copy-paste block;
  only an explicit Markdown-file request permits file-only delivery.
- state delta: Arranger `AGENTS.md`, Rule 4, and `op-brief-forms.md` now state the full-content
  default; terminal-only generation neither issues an op nor authorizes activation-file persistence;
  compact ROB status inventories remain compact.
- evidence: `AGENTS.md` 4,849 bytes / 73 lines / SHA-256
  `6cc65bcfcdd8efe68363ce54b0c5fa8dc96b21b9070240213770ee9a4f07a84c`;
  `arranger-rulebook.md` 14,275 bytes / 200 lines / SHA-256
  `91db47ce7060efd0523adaa34d2117a6afa0b8dc3f668cfd7811935fe4585218`;
  `op-brief-forms.md` 4,627 bytes / 71 lines / SHA-256
  `1b679c7461fd55aeba67a39daa4a6be4944c19aa85bde8baf275afb9f4afe907`;
  `git diff --check` passed.
- blockers / decisions: none; an activation path, link, short normal form, or REPORT-only block may
  accompany but never replace the full op content unless the Coordinator explicitly requests
  Markdown-file delivery instead.
- next: when returning to project work, show op-322's complete normal-form content in the terminal for Coordinator copy/paste.

### j-20260722-007 — op-009m catchup accepted and retired

- time: 2026-07-22T03:02:41Z
- kind: RETURN
- owner / epoch: Arranger2 / `swap-20260710T234047Z-arranger2`
- outcome: accepted Arranger1's chat-only `CATCHUP-COMPLETE` through `j-20260722-004`; the inactive
  seat accurately acknowledged the corrected one-journal method and preserved the zero-write/no-
  SWAPIN boundary.
- state delta: op-009m retired; mutex owner, epoch, and readiness remain Arranger2 /
  `swap-20260710T234047Z-arranger2` / ACTIVE; no project ROB or IDQ state changed.
- evidence: all four `A1_OP009M_*` markers and the required REPORT were present; target identities
  matched; visible tail was `j-20260722-005`; boundary reported read_only=1, writes=0,
  journal_appends=0, commits=0, pushes=0.
- blockers / decisions: the return snapshot predates `j-20260722-006`; a bounded read-only catchup
  through j-006 is owed for the later full-terminal-op output rule, without reopening op-009m.
- next: record the Coordinator's op-322 dispatch as its own op-state transition.

### j-20260722-008 — op-322 dispatched to Explorer

- time: 2026-07-22T03:03:10Z
- kind: ISSUE
- owner / epoch: Arranger2 / `swap-20260710T234047Z-arranger2`
- outcome: consumed the Coordinator's dispatch of the full op-322 normal-form brief to
  `rmx-explorer-rx-x64z` for the bounded op-318 PID-1 contract correction.
- state delta: op-322 advanced Ready → Exe; op-009m remains retired; project dependencies and IDQ
  states are unchanged.
- evidence: Coordinator in-session directive `dispatched`; authoritative op-322 activation now
  records the consumed dispatch and bound Explorer EXU.
- blockers / decisions: no Implementer helper/image stage or Gatekeeper reaper cell may issue until
  the Explorer correction returns and receives the required independent validation.
- next: await op-322's Explorer return; meanwhile relay only the bounded j-006 delta catchup and project-seam answers to inactive Arranger1.

### j-20260722-009 — Arranger1 acknowledged the j-006 method delta

- time: 2026-07-22T03:07:53Z
- kind: RETURN
- owner / epoch: Arranger2 / `swap-20260710T234047Z-arranger2`
- outcome: accepted Arranger1's chat-only read-back through `j-20260722-006`; the inactive seat now
  understands the full-terminal-op default, explicit Markdown-persistence exception, separation of
  generation from issuance, and compact-ROB exception.
- state delta: continuity knowledge is aligned through j-006; no op, IDQ, ROB, activation, mutex,
  ownership, epoch, or readiness state changed.
- evidence: Arranger1 reproduced `AGENTS.md` 4,849 bytes / 73 lines / SHA-256 `6cc65bcf…a84c`,
  `arranger-rulebook.md` 14,275 bytes / 200 lines / `91db47ce…218`, `op-brief-forms.md` 4,627
  bytes / 71 lines / `1b679c74…e907`, and reported j-007/j-008 as visible tail; boundary was
  read_only=1, writes=0, journal_appends=0, mutex/activation unchanged, commits=0, pushes=0.
- blockers / decisions: none; Arranger1 remains inactive/read-only and has no further questions.
- next: await op-322's Explorer correction return.

### j-20260722-010 — op-322 returned and split for parallel validation

- time: 2026-07-22T03:27:06Z
- kind: RETURN
- owner / epoch: Arranger2 / `swap-20260710T234047Z-arranger2`
- outcome: reproduced op-322's one-note local commit and complete C1-C8 marker set, sized the return
  XL, and split downstream validation into independent staging and reaper packages so one gate no
  longer blocks both branches.
- state delta: op-322 advanced Exe → Done; proposed op-323 (GLM staging gate) and op-324 (DS4P
  reaper gate) remain terminal-only draft dispatch payloads, not issued/live ops; ROB/IDQ/mutex state
  otherwise unchanged.
- evidence: Explorer note 41,160 bytes / 376 lines / SHA-256 `b6a08dc3…c8158`; local commit
  `3620e5b` parent `9355ad42`, exactly one added path, tracked clean, ahead/behind `3/1`, three
  expected untracked paths, push=0; verdict CORRECTED-CONTRACT-READY-FOR-VALIDATION confidence 9.
- blockers / decisions: neither package is validated yet; no Implementer helper/image brief or
  Gatekeeper reaper cell releases; Explorer findings commit is local-only, not origin/main-reachable.
- next: Coordinator dispatches the complete op-323 and op-324 Validator briefs in parallel.

### j-20260922-001 — Coordinator redirects alpha2 regression critical path

- time: 2026-09-22T00:26:59Z
- kind: DECISION
- owner / epoch: Arranger2 / `swap-20260710T234047Z-arranger2`
- outcome: Coordinator approved exact-candidate cold build, bounded manual evidence review, accepted containment/staging, then a small boot/base + Mach IPC + dispatch/workqueue regression slice. Generic preflight-checker acceptance is no longer a prerequisite for that chain; its rejection remains in force.
- state delta: no activation files changed. op-334 terminal draft is held from dispatch; if already dispatched, request a stop at the next safe boundary and preserve partial work. op-335 is a terminal-only Implementer build brief, not a persisted activation or dispatched job.
- evidence: Coordinator chat "go with this plan"; candidate worktree independently observed clean at `15c185c038b9f5227c53e9019be8d35df328c314`; `docs/freebsd-stable15-sync-plan.md` Phase 4 and `docs/rmxos-full-rebuild-agent-handoff.md` read first-hand in wip-gpt.
- blockers / decisions: accepted containment remains required before staging/guest execution; build evidence is manually reviewed without using the rejected checker as an acceptance authority. No real build/image/runtime acceptance is granted by this decision.
- next: Coordinator dispatches the full op-335 build-only brief to the wip-gpt / wip-rmxos Implementer after ensuring no same-candidate cold build is already running.

### j-20260722-012 — correct j-20260722-011 timestamp

- time: 2026-07-22T03:35:01Z
- kind: CORRECTION
- owner / epoch: Arranger2 / `swap-20260710T234047Z-arranger2`
- outcome: corrects only the `time` field of `j-20260722-011`; its now-true append time is
  `2026-07-22T03:34:12Z`, as captured by the immediately preceding owner/epoch pre-write check.
- state delta: no op, IDQ, activation, mutex, artifact, or dispatch state changed; the original
  complete entry remains immutable.
- evidence: pre-write command output recorded UTC `2026-07-22T03:34:12Z`; j-011 outcome and hashes
  remain unchanged.
- blockers / decisions: none beyond the still-unissued op-323/op-324 Validator gates.
- next: Coordinator dispatches the complete op-323 and op-324 Validator briefs in parallel.

### j-20260722-011 — op-322 IDQ pointers reconciled

- time: 2026-07-22T03:33:47Z
- kind: ACTION
- owner / epoch: Arranger2 / `swap-20260710T234047Z-arranger2`
- outcome: reconciled id-016/id-042 and the IDQ index with op-322's authoritative [Done]
  activation, recording that its staging and reaper packages await independent parallel Validator
  gates and that neither package has been issued or accepted.
- state delta: id-016/id-042 now point at op-322 [Done], validation pending; no activation, op
  issuance, mutex, readiness, product, helper, image, runtime, or legacy-op state changed.
- evidence: `idq/id-000.md` 17,712 bytes / 88 lines / SHA-256 `26700337…3610`;
  `idq/id-016-ambient-mach-bootstrap-port.md` 15,366 bytes / 167 lines / SHA-256
  `17c0e59b…9eb4`; `idq/id-042-1.0-preview-todo.md` 14,194 bytes / 211 lines / SHA-256
  `d87f8936…993e`; `git diff --check` passed.
- blockers / decisions: op-323 and op-324 remain terminal-only draft dispatch payloads; no
  Implementer helper/image authorship or Gatekeeper reaper cell is released before its relevant
  Validator verdict.
- next: Coordinator dispatches the complete op-323 and op-324 Validator briefs in parallel.

### j-20260722-013 — correct j-011/j-012 chronology metadata

- time: 2026-07-22T03:34:55Z
- kind: CORRECTION
- owner / epoch: Arranger2 / `swap-20260710T234047Z-arranger2`
- outcome: names and preserves both complete prior bodies while correcting their chronology:
  `j-20260722-011` was appended at `2026-07-22T03:34:12Z`; `j-20260722-012` was appended at
  `2026-07-22T03:34:25Z`. The latter was accidentally inserted physically before j-011 by a
  non-unique patch anchor; canonical logical order is j-011 then j-012. Neither body is rewritten.
- state delta: no op, IDQ, activation, mutex, artifact, or dispatch state changed; future appends
  must anchor uniquely at the physical EOF.
- evidence: the two immediately preceding pre-write command outputs supplied the corrected UTC
  values; both complete entries and their terminal `next:` fields remain present.
- blockers / decisions: the one physical-order defect is disclosed and additively corrected; the
  still-unissued op-323/op-324 gates are otherwise unchanged.
- next: Coordinator dispatches the complete op-323 and op-324 Validator briefs in parallel.

### j-20260922-002 — locate current decision after insertion error

- time: 2026-09-22T00:26:59Z
- kind: CORRECTION
- owner / epoch: Arranger2 / `swap-20260710T234047Z-arranger2`
- outcome: `j-20260922-001` was inadvertently inserted before historical entries by a non-unique patch anchor. It remains immutable; its logical chronology is after `j-20260722-013` and before this correction. Its decision is current: exact-candidate cold build, manual review, accepted containment/staging, then bounded guest regression; generic checker acceptance is off the critical path.
- state delta: none beyond the decision recorded in j-20260922-001; no op activation or dispatch.
- evidence: physical heading census of arranger-swap.md; j-20260922-001 at line 297 before historical j-20260722-012/011/013. Time records the decision timestamp, not a separately sampled correction time.
- blockers / decisions: op-334 remains held from new dispatch; accepted containment and later explicit runtime activation remain required.
- next: Coordinator sends op-335 to the wip-gpt / wip-rmxos Implementer; preserve any already-running work and avoid duplicate cold builds.

### j-20260922-003 — Coordinator excludes NFS and Kerberos from base release

- time: 2026-09-22T03:26:12Z
- kind: DECISION
- owner / epoch: Arranger2 / `swap-20260710T234047Z-arranger2`
- outcome: Coordinator confirms disabling NFS and Kerberos in rmxOS base for now. Optional Samba packages may retain bundled Heimdal; preserve OpenSSH/OpenSSL and local filesystem ACL support. This is a release-profile change, not permission to delete files from preserved builds or staging evidence.
- state delta: no activation or IDQ state changed; op-338 is a terminal-only Implementer configuration draft, not dispatched or persisted. Existing op-335/op-336 artifacts retain their original identities and coverage.
- evidence: Coordinator chat confirmation following Samba bundled-Heimdal clarification; candidate src.opts.mk exposes KERBEROS/KERBEROS_SUPPORT, GENERIC enables NFSCL/NFSD/NFSLOCKD/NFS_ROOT, and NFS userland entries inspected in build Makefiles.
- blockers / decisions: source/profile implementation and later fresh-build/image verification remain owed; no runtime or release acceptance, commit, push, or guest authorization follows.
- next: Coordinator relays the full op-338 configuration-only request to the owning wip-gpt / wip-rmxos Implementer; serialize against any concurrent source writer.

### j-20260925-001 — simplify Arranger instructions and bound preparation churn

- time: 2026-09-25T03:23:00Z
- kind: ACTION
- owner / epoch: Arranger2 / `swap-20260710T234047Z-arranger2`
- outcome: Coordinator-requested AGENTS.md cleanup introduces contextual reading, outcome completion, scoped autonomy, runner reuse, and proportional review. The Arranger rulebook aligns completion, review sizing, and maintenance guidance; no other role's instructions changed.
- state delta: documentation only; no activation, dispatch, retirement, guest budget, mutex, or publication state changed.
- evidence: AGENTS.md and arranger-rulebook.md edits based on the supplied prompting article and repeated harness failures in Coordinator reports.
- blockers / decisions: intervening chat operations are not reconstructed by this entry; historical journal policy is not a substitute for current Coordinator scope. No new execution authority follows from this cleanup.
- next: Apply the revised discipline to current authorized work without opening another preparation-only op.

### j-20260925-002 — apply approved Gatekeeper instruction cleanup

- time: 2026-09-25T03:29:41Z
- kind: ACTION
- owner / epoch: Arranger2 / `swap-20260710T234047Z-arranger2`
- outcome: Coordinator explicitly approved applying the read-only proposal to Gatekeeper AGENTS.md and aligning ONBOARDING.md. This scoped documentation edit replaces broad change ceremony and arbitrary correction counts with outcome completion, actual-path host checks, and explicit execution boundaries.
- state delta: two Gatekeeper instruction files changed under this specific Coordinator approval; ordinary repo ownership remains unchanged. No op activation, runtime budget, acceptance, or publication state changed.
- evidence: targeted git diff --check passed for rmx-gatekeeper/AGENTS.md and ONBOARDING.md; both files were clean before editing.
- blockers / decisions: no guest execution or retry is authorized by these edits; unrelated files and historical runtime evidence were not modified.
- next: Gatekeeper should read the updated instructions before continuing its currently authorized work.

### j-20260927-001 — single Arranger seat; two-seat swap protocol retired

- time / kind: 2026-09-27T21:20:19Z / DECISION
- outcome: Coordinator directs a single Arranger seat (Claude Opus 5.5). The mutex, epoch fence, SWAP/SWAPIN/SWAPOUT, and CATCHUP procedures are retired; the journal remains the sole chronological log with a lighter entry rule (op state changes, Coordinator decisions, Rule-9 spend only). Arranger1/Arranger2 ownership is superseded.
- state delta: arranger-swap.md header and protocol, arranger-rulebook.md Rule 15, and AGENTS.md reading guidance updated; no activation, IDQ, dispatch, guest budget, or publication state changed.
- evidence: Coordinator chat directive 2026-09-28 local; prior protocol recoverable from Git history of arranger-swap.md.
- next: Continue current authorized work under the single-seat protocol.

### j-20260927-002 — workflow redesign direction adopted; hand relay retained

- time / kind: 2026-09-27T22:45:51Z / DECISION
- outcome: Coordinator accepts the proposed workflow redesign (op file per op with machine-readable header, `rob` script for board/state/checks, five-state vocabulary, risk-sized review, three state stores, critical-path `now.md`) with one change: all dispatch and report relay stays by hand through the Coordinator. Agents never read or write this repo; a brief is `draft` until the Coordinator confirms it was sent.
- state delta: none yet; no activation, IDQ, or op state changed.
- evidence: Coordinator chat, 2026-09-28 local.
- next: Coordinator settles the review rule (self / one Validator / both) and the single confidence threshold (8 or 9); then step 1 aligns roles.md, the pipeline doc, and the rulebook.

### j-20260927-003 — review rule settled: risk-sized routing, single ≥8 threshold

- time / kind: 2026-09-27T22:47:49Z / DECISION
- outcome: Coordinator delegated the choice ("you decide"; Rule 9, recorded here). Returned gates are reviewed by size: S/M by the Arranger first-hand, L by one Validator, XL or release-critical-path by both. One threshold: close at ≥8/10, with agreement when two review; below 8 or conflict goes to the Arbiter. Supersedes the "both Validators on every op" rule and the rulebook's ≥9 bar.
- state delta: rule text aligned in discovery-implementation-pipeline.md (single home), roles.md, role-model-onboarding.md, arranger-rulebook.md Rules 6/11, AGENTS.md; no op, IDQ, or activation state changed.
- evidence: this commit's diff.
- next: Redesign step 2 — rob script, five-state op headers, and legacy [Done] triage proposal.

### j-20260927-004 — clean-start reset; workflow docs rewritten; agent alignment briefs drafted

- time / kind: 2026-09-27T22:56:39Z / ACTION
- outcome: Under the Coordinator's delegation ("you decide … new starting point"), all 102 returned ops were closed and 18 stale draft/issued ops dropped as a reset, not an adjudication; each keeps its legacy tag and `reset: j-20260927-004`. The 9 hold ops stay. Open problems remain in their IDQ files, and now.md holds the critical path. rob-mini-format.md, op-brief-forms.md, terminology.md §6, roles.md, and rulebook Rules 3/4/5/11/13 now describe the six-state, rob-driven, hand-relayed workflow. Six alignment briefs were drafted, one per agent/repo: op-339 Implementer, op-340 Explorer, op-341 Gatekeeper, op-342 Oracle, op-343 GLM, op-344 DS4P.
- state delta: 102 → closed, 18 → dropped, op-339…op-344 created as draft; no product, guest, or other-repo change.
- evidence: `tools/rob board`, `tools/rob check` (181 ops, 0 problems); this commit.
- next: Coordinator relays op-339…op-344 and answers whether op-335/op-338/op-323/op-324 were ever sent (now.md).

### j-20260927-005 — correct j-20260927-002 on repo access

- time / kind: 2026-09-27T23:09:15Z / CORRECTION
- outcome: j-20260927-002 said "Agents never read or write this repo", which overstates the Coordinator's decision. The decision was hand relay: agents never pick up or return ops through this repo. Reading its documents is allowed when a brief names the path; writing never is. roles.md § Edges states this.
- state delta: none.
- evidence: Coordinator chat ("I do want relay by hand"); roles.md § Edges.
- next: none beyond j-20260927-006.

### j-20260927-006 — roles.md made the canonical workflow doctrine; historical docs archived

- time / kind: 2026-09-27T23:09:15Z / DECISION
- outcome: Under the Coordinator's delegation ("you decide … restructure other agents accordingly"; Rule 9, recorded here), rmx-arranger/roles.md is canonical for roles, repos, edges, and the review and closure rule, and supersedes wip-gpt/docs/role-governance.md where they differ (op-339 aligns that file). The review rule moved there from discovery-implementation-pipeline.md, which was archived with 25 other point-in-time documents under doc/archive/ (index: doc/archive/README.md; frozen cp-103 archive SHA-256 re-verified after the move). tools/rob now enforces state transitions and flags stale issued/returned ops.
- state delta: no op or IDQ state changed; op-339/op-343/op-344 drafts revised (op-344 now needs op-343 and copies GLM's Validator rulebook itself instead of an Arranger cross-repo sync).
- evidence: this commit; `python3 -B tools/test_rob.py` (11 tests pass); `tools/rob check` (0 problems).
- next: Coordinator takes the agent repos one by one, starting with any of op-339…op-343.

### j-20260927-007 — direct repo onboarding; wip-gpt renamed to rmx-implementer

- time / kind: 2026-09-27T23:21:26Z / DECISION
- outcome: Coordinator directs the Arranger to onboard each role repo directly, one at a time: rename it to `rmx-<role>` and update its instructions to the current workflow. Agents' prior session state is not carried over; they are onboarded fresh. This is an explicit exception to "write only in this workspace" for onboarding. First repo: `/Users/me/wip-mach/wip-gpt` renamed to `rmx-implementer`; `wip-gpt` is a transitional symlink until other repos stop referencing it; `wip-rmxos` linked worktrees under `../build/` repaired to the new path (alpha2 candidate keeps its 3 op-338/op-340 profile files); three op108 objdir-backup symlinks retargeted. Implementer repo commits (local, not pushed): `92a8d92` snapshot of 29 uncommitted paths as found, `52b1789` onboarding (AGENTS.md rewritten, CLAUDE.md imports AGENTS.md, docs/role-governance.md points to roles.md).
- state delta: no op state changed by this entry; see j-20260927-008 for op ids.
- evidence: `git -C /Users/me/wip-mach/rmx-implementer/wip-rmxos worktree list`; Implementer repo log.
- next: Coordinator relays the Implementer onboarding op; then the next role repo.

### j-20260927-008 — correct op ledger: op-335 through op-360 ran chat-only

- time / kind: 2026-09-27T23:21:26Z / CORRECTION
- outcome: Corrects j-20260927-004/006 and now.md. Between 2026-09-22 and 2026-09-25, ops through at least op-360 were briefed and run from chat without op files here. Evidence includes rmx-implementer/build/op335-*, op336-*, op338, op340, op342, op343-*, op344-*, op348-*, op358-alpha2-20260925T000042Z; rmx-implementer/docs/op338-base-release-profile.md (CONFIGURATION-READY-FOR-VALIDATION) and op340-minimal-nfs-profile.md; and rmx-validator3/op339-review.*, op341-review.* (so validator3 is active). The drafts op-339…op-344 created in j-20260927-004 reused those ids; they were never sent and are deleted (their text remains in Git at 620815a and f7e4d19). Ids through op-360 are taken; `tools/rob next-id` allocates above them. Per the Coordinator, the chat-only ops are not reconstructed; the Implementer onboarding op re-establishes the product baseline from disk.
- state delta: op-339…op-344 draft files removed.
- evidence: directory listings above; `tools/rob next-id`.
- next: none beyond j-20260927-007.

### j-20260927-009 — standing op contract moves into each role repo's OPS.md

- time / kind: 2026-09-27T23:28:34Z / DECISION
- outcome: Coordinator directs that briefs stop repeating standing sections. Each role repo gets an `OPS.md` linked from its AGENTS.md, holding the brief format, the role's defaults (allowed, needs explicit authority, stop conditions), and the REPORT block. A brief now carries only the header line, the Outcome, and op-specific Inputs or Limits, plus one line pointing to OPS.md. First: rmx-implementer/OPS.md (`025d54e`, local). `authority` now means grants beyond the defaults; tighter restrictions go under Limits.
- state delta: op-361 rewritten in the short form (still draft, authority none, Limits read-only); `tools/rob new` emits the short template.
- evidence: op-brief-forms.md; rmx-implementer/OPS.md; `python3 -B tools/test_rob.py` passes.
- next: Coordinator relays op-361; then the Gatekeeper repo.

### j-20260927-010 — op-361 closed: Implementer onboarded; alpha2 baseline established

- time / kind: 2026-09-27T23:37:28Z / RETURN
- outcome: The Implementer read AGENTS.md and OPS.md and reported the baseline; every fact was re-verified first-hand (S gate). rmx-implementer main `025d54e` clean, 5 commits not on origin; wip-rmxos alpha `26655e67` clean, on origin; three linked worktrees; alpha2 candidate `15c185c0` with 1 modified and 4 untracked profile paths; 7 tracked scripts still hard-code the wip-gpt path. Newest build `op358-alpha2-20260925T000042Z`: 8 GiB UFS and raw GPT image from the candidate with mach.ko staged via loader.conf (kernel from op-343); makefs and mkimg rc 0; extracted partition byte-for-byte equal; not mounted or booted. Caveats from its summary: mach.ko compatibility is static only, and module (clang 19.1.7) and kernel (clang/LLD 21.1.8) toolchains differ. Also found: op-340 revised j-20260922-003 in chat. Kernel NFS options and NFS modules are off, NFS userland stays dormant, Kerberos is back to upstream defaults, OpenSSH/OpenSSL/ACLs kept (rmx-implementer/docs/op340-minimal-nfs-profile.md). Coordinator to confirm that this is the policy in force.
- state delta: op-361 issued → returned → closed.
- evidence: rmx-implementer/AGENTS.md sha256:e07913e1…; OPS.md sha256:f415b73b…; build/op358-alpha2-20260925T000042Z/evidence/final-makefs-return.txt sha256:1a21f3bc…, final-mkimg-return.txt sha256:1a6260f8…, final-partition-compare-return.txt sha256:e0752bc4…, op358-summary.txt.
- next: Relay op-362 (alpha2 build-chain index) to the Implementer.

### j-20260927-011 — op-362 closed: alpha2 build chain indexed for Coordinator review

- time / kind: 2026-09-27T23:54:26Z / RETURN
- outcome: The Implementer committed rmx-implementer/docs/alpha2-build-chain.md (`cb92a3c`, not on origin; only that file). Verified first-hand (M gate): file SHA-256 06185ec5…; rows spot-checked against recorded evidence for op-335 (BUILD-DONE, rc 0, kernel b4792259…), op-336 (STAGING-BLOCKED, makefs rc 1 on the krb5 debug directory), op-343 (848 modules; kernel b4608699…; mach.ko 1acea1e0…), op-344 (IMAGE-READY-FOR-REVIEW, image 24c2d4eb…), op-348 (IMAGE-READY, BOM pin mismatch recorded, 20/20 rows matched); the candidate's current profile files match op-340's three configs and op-342's Makefile. The deliverable images were hashed directly: UFS 0b877039…a4 and GPT 96644d80…d6, matching the index. Non-blocking gap: the op-358 row omits that op-358 also rewrote the candidate's release/rmxos/README.md (now 701d401a…) and the owner handoff doc.
- state delta: op-362 issued → returned → closed.
- evidence: rmx-implementer/docs/alpha2-build-chain.md; build/op358-alpha2-20260925T000042Z/images/final-rootfs-8g.ufs and final-op358-alpha2-gpt.raw (sha256 above).
- next: Coordinator reviews the index (critical path step 3); op-363 is ready to relay.

### j-20260927-012 — op-363 closed: tracked scripts no longer hard-code the old repo path

- time / kind: 2026-09-28T00:01:15Z / RETURN
- outcome: The Implementer committed `d58169e` in rmx-implementer (not on origin; exactly the seven scripts). Verified first-hand (S gate): all seven hashes match; `git grep /Users/me/wip-mach/wip-gpt -- scripts` is empty; `sh -n` passes (all are /bin/sh); the six preflights derive `expected_freebsd_src` from `${repo_root}/wip-rmxos` and verify-phase1 already defaulted to `${repo_root}/wip-rmxos` (only its help text changed). Note for any future reuse, not a defect: `repo_root` uses logical `pwd`, so running a script through the `wip-gpt` symlink resolves to the old tree while the real path resolves to `rmx-implementer`. Existing objdirs under build/wip-rmxos-alpha-obj exist only for the old path, so these preflights need a rebuild or NXPLATFORM_* overrides before reuse. `pwd -P` would match make's physical objdir layout.
- state delta: op-363 issued → returned → closed.
- evidence: rmx-implementer `d58169e`; derivation evaluated with `sh -c` for real, symlink, and relative invocations.
- next: Coordinator decides the alpha2 review items in now.md; then the Gatekeeper repo.

### j-20260927-013 — Arranger one-way access to all role repos made standing

- time / kind: 2026-09-28T00:08:17Z / DECISION
- outcome: Coordinator rules that the Arranger has standing one-way access. It can read and change every role repo directly, and no other agent reads or writes the Arranger's repo, so agents see its work only through briefs, notices, and their own files. When an Arranger change could affect what an agent knows or is working on, a NOTICE goes to that agent through the Coordinator; other changes need none. This supersedes the onboarding-only exception in j-20260927-007 and the old per-change one-way window/door records. Kept limits (Arranger reading, not a new Coordinator ruling): raw evidence, evidence dispositions, and guest-attempt accounting are never changed in place; product source stays the Implementer's. Applied to rmx-implementer (`dfe9a60`, local): its instructions no longer point at rmx-arranger.
- state delta: none; governing docs (AGENTS.md, roles.md, rulebook Rule 8, op-brief-forms.md with the NOTICE format, terminology.md) updated.
- evidence: this commit; rmx-implementer log.
- next: Relay the NOTICE to the Implementer (its AGENTS.md, OPS.md, and role docs changed).

### j-20260927-014 — alpha2 review decisions: rebuild mach.ko, commit profile, op-340 policy, push repos

- time / kind: 2026-09-28T00:13:45Z / DECISION
- outcome: Coordinator decisions after reviewing the op-362 index. (1) Before the first boot, the Implementer rebuilds mach.ko with the kernel's toolchain and composes a new image. op-343's module log shows host cc (clang 19.1.7), and the op-343 objdir holds clang 21.1.8. (2) The five release-profile paths are committed on wip-rmxos alpha2 as part of that op. (3) op-340's NFS/Kerberos policy is in force: kernel NFS options and NFS modules off, NFS userland dormant, Kerberos at upstream defaults, OpenSSH/OpenSSL/ACLs kept. This supersedes the j-20260922-003 text. (4) Push rmx-arranger and rmx-implementer (project-rmx) now. Also found: branch alpha2, including candidate 15c185c, exists only locally; neither rmxOS origin nor the backup remote has it. Pushing it is a separate, open publication decision, and op-364 cannot close while its alpha2 commit is local-only.
- state delta: op-364 created (draft, gate both).
- evidence: rmx-implementer/build/op343-alpha2-20260922T065914Z/logs/build-mach-module.log (bare `cc`); `cc --version` for host and op-343 objdir; `git branch -r --contains 15c185c` in wip-rmxos (none).
- next: Relay op-364; Coordinator decides whether alpha2 is pushed to rmxOS origin.
