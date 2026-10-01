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

### j-20260927-015 — Validators onboarded: rmx-validator1/2/3 under Git with OPS.md

- time / kind: 2026-09-28T00:25:10Z / ACTION
- outcome: Under one-way access (j-20260927-013), the three Validator workspaces were modernized. `wip-glm` → `rmx-validator1` (GLM) and `wip-ds4p` → `rmx-validator2` (DS4P), each with a transitional symlink; `rmx-validator3` kept its name. Numbering follows validator3's own peer list. All three were put under Git (local, no remote), with snapshot commits as found (`ea467a6`, `7732511`, `6a6b890`) and onboarding commits (`fc093bd`, `df2257b`, `148306c`). Each has a self-contained AGENTS.md, a Validator OPS.md (review defaults, score and verdict rules, a REPORT with question/access/score/verdict lines), and an identical modernized validator-rulebook.md (SHA-256 78675303…; craft rules unchanged). About 2 GB of review scratch in rmx-validator3 (op339-review.*, op341-review.*, op331-isolated, op333-review.*) and a DS4P erl_crash.dump are ignored by Git, not deleted.
- state delta: none; no op state changed.
- evidence: the six commits above; rulebook hashes identical across the three repos.
- next: Relay the three onboarding NOTICEs; Validators then review op-364 when it returns.

### j-20260927-016 — roles become templates with numbered instances

- time / kind: 2026-09-28T00:42:21Z / DECISION
- outcome: Coordinator decision: every role is a class with a template repo `rmx-<role>0` and numbered instance repos `rmx-<role>N`, rooted at `rmx-role0`. Singletons are instance 1 (the Arranger is arranger1), so adding an instance is just another number. The Coordinator chose all four recommended options. (1) Instance files are generated: `tools/roles` renders the template chain plus the instance's `instance.toml` overrides into a self-contained repo and refuses to overwrite local edits. (2) A root template `rmx-role0` holds text every role shares. (3) Onboarded roles are renamed now; the others at their onboarding (oracle, oracle2, oracle3 become oracle1 to oracle3). (4) An agent's own notes and lessons go in `LOCAL.md`, and the Arranger promotes lessons into the template.
- state delta: none.
- evidence: Coordinator answers in chat.
- next: see j-20260927-017.

### j-20260927-017 — templates built; Validators and Arranger converted; two folders renamed

- time / kind: 2026-09-28T00:42:21Z / ACTION
- outcome: Built tools/roles (8 tests) and templates rmx-role0 (`ae975f3`), rmx-validator0 (`a51bc6f`), and rmx-arranger0 (`a009361`), all local Git. Validators 1 to 3 are now instances of validator0 (`4febc44`, `9c06c2c`, `5fd10a2`); new rulebook lessons go to LOCAL.md. rmx-arranger was renamed to rmx-arranger1 and rendered from arranger0. rmx-implementer was renamed to rmx-implementer1: symlinks kept for rmx-implementer and wip-gpt, wip-rmxos worktrees repaired, op108 objdir links retargeted. Incident: the Implementer rename happened at 13:38:49 local while a Codex Implementer session was working op-364. Its profile commit (`2884304b`, 13:15) and its module, staging, and image steps (13:17 to 13:31) were already done, and it wrote one evidence file at 13:39. No build process was running, and old paths resolve through the symlink. Rule 8 now requires checking for in-flight ops and processes before renaming or re-rendering a repo. The Implementer's conversion to rmx-implementer0 waits for op-364's REPORT.
- state delta: op-364 draft → issued (it is in flight).
- evidence: commits above; `tools/roles check` reports 4 instances, 0 needing attention; procstat showed codex with cwd in rmx-implementer at 13:38.
- next: Relay the Implementer NOTICE (folder renamed) and the Validator NOTICEs; convert the Implementer after op-364 returns.

### j-20260927-018 — singleton roles: one unnumbered repo with the template inside

- time / kind: 2026-09-28T00:55:19Z / DECISION
- outcome: Coordinator refines j-20260927-016 to cut noise for singleton roles. A role with one instance is one repo with no number (`rmx-arranger`, `rmx-implementer`). The repo is the instance (implicitly instance 1, id `arranger`), and its template lives in a subdirectory (`arranger0/`), kept for consistency and for growth to several instances. Roles with several instances keep `rmx-<role>0` plus `rmx-<role>N` (Validators). Growing a singleton means moving `<role>0/` out to `rmx-<role>0` and renaming the repo `rmx-<role>1`.
- state delta: none.
- evidence: Coordinator message in chat.
- next: see j-20260927-019.

### j-20260927-019 — Arranger converted to the singleton layout; Validators re-rendered

- time / kind: 2026-09-28T00:55:19Z / ACTION
- outcome: tools/roles now finds a template at `rmx-<cls>` or inside a singleton at `rmx-<role>/<cls>` (an error if both exist), gives an unnumbered instance n=1 and id `<role>`, adds a `template` built-in (the template's path from the instance), and locks template content digests instead of Git commits (10 tests). The standalone rmx-arranger0 (one commit, `a009361`) moved into `rmx-arranger/arranger0/` and was deleted after a byte-for-byte check. rmx-arranger1 was renamed back to rmx-arranger, with rmx-arranger1 kept as a transitional symlink, and rendered as `arranger`. The root partial instance-files now names the template location (rmx-role0 `d552b15`). Validators 1 to 3 were re-rendered (`a67c438`, `97bbca3`, `bcb7cb8`); only an idle zsh was open in rmx-validator1 and no agent was running. The Implementer's rename back to rmx-implementer and its `implementer0/` template wait for op-364's REPORT.
- state delta: op-364 names updated to implementer / rmx-implementer (still issued).
- evidence: `tools/roles check` reports 4 instances, 0 needing attention; commits above.
- next: Relay op-365, op-366, op-367; convert the Implementer after op-364 returns.

### j-20260927-020 — tools rewritten in Elixir; role config moved from TOML to JSON

- time / kind: 2026-09-28T01:08:21Z / DECISION
- outcome: Coordinator directs no Python and no TOML. tools/rob and tools/roles are now Elixir scripts (Elixir 1.20, OTP 29, built-in JSON; no dependencies) with the same commands and behavior. Their tests are ExUnit suites: `elixir tools/test/rob_test.exs` (14) and `elixir tools/test/roles_test.exs` (11); the Python tests were deleted. Role config is JSON: template.json and instance.json replace the .toml files in rmx-role0, rmx-validator0, rmx-arranger/arranger0, rmx-arranger, and rmx-validator1 to 3, and a "comment" key replaces TOML comments. Equivalence check: before any template text changed, the Elixir renderer reading JSON reported all 4 instances up to date against locks written by the Python renderer, so all 11 rendered files were byte-identical. Mutation checks confirmed that each suite catches a disabled guard (the transition check for rob, the local-edit check for roles). Afterwards `instance.toml` wording became `instance.json` and all instances were re-rendered (rmx-role0 `03fda3b`, rmx-validator0 `d0035d0`, Validators `84ba053`, `7c08718`, `33723b6`).
- state delta: none.
- evidence: the test runs and `tools/roles check` (4 instances, 0 need attention); commits above.
- next: Relay op-365, op-366, op-367; convert the Implementer after op-364 returns.

### j-20260927-021 — Validator costs recorded for routing, in the Arranger repo only

- time / kind: 2026-09-28T01:23:11Z / DECISION
- outcome: Coordinator gave relative Validator costs (0 free to 10): validator1 (GLM) 0, validator2 (DS4P) 1, and validator3 by the model seated for the session: luna-max 1, sol-medium 3, astra-medium 6, astra-max 8, astra-ultra 9. They are kept only in roles.md § Choosing a Validator, never in role templates or instance files, so Validators cannot be biased by them. Rule: risk decides how many reviewers and cost decides which. The default pair for XL or critical-path gates is validator1 + validator2. validator3 is the third opinion when the pair disagrees or scores below 8, or when a question needs a stronger model; its tier follows the stakes and is named in the op's agent field. Rule 11 (arranger0 template) updated accordingly. This also answers the open question: validator3's model is chosen per session.
- state delta: none.
- evidence: Coordinator messages in chat; roles.md, terminology.md, arranger0/files/arranger-rulebook.md.
- next: Relay op-365, op-366, op-367 (seat validator3 at the tier expected for real reviews); paste op-364's REPORT.

### j-20260927-022 — op-366 closed: validator2 onboarded; calibration exceeded the key

- time / kind: 2026-09-28T01:25:45Z / RETURN
- outcome: validator2 (DS4P) read its instructions and returned the op-363 calibration review: claims 1 and 2 hold, claim 3 fails for two of the three invocation names, verdict REMEDIATE, score 9. I verified it first-hand: kernel_path and mach_module_path are concatenated without canonicalization (lines 75-76) while the source-tree check canonicalizes (physical_dir, lines 102 and 130-134), and both objdir trees are keyed only by `wip-gpt`. The review exceeded my pre-registered key: `pwd -P` is not a fix, and verify-phase1 has the same issue. It also shows my S gate on op-363 was too lenient; the cause was my op-363 brief. validator2's instruction feedback and lessons are held in LOCAL.md until op-365 and op-367 return, to avoid editing under a live review or leaking the answer. A follow-up Implementer op is queued after op-364.
- state delta: op-366 issued → returned → closed.
- evidence: rmx-validator2 `5961a5e` (LOCAL.md and reviews/op-366/op-363-calibration-review.md only); `tools/roles check` clean; the script lines and objdir listings above.
- next: Paste the op-365 and op-367 REPORTs; then op-364's.

### j-20260927-023 — op-367 closed: validator3 onboarded; calibration met the key

- time / kind: 2026-09-28T01:27:45Z / RETURN
- outcome: validator3 read its instructions and returned the op-363 calibration review: claim 3 fails, with the source-tree check holding for every alias and the objdir paths matching only via `wip-gpt`; verdict DO-NOT-CLOSE, score 9. I verified every hash first-hand, including the objdir kernel (`b8f3f8a7…`) and mach.ko (`9c7706a3…`); its two commit-evidence hashes are sha256 of the raw commit objects. It met the key but went less deep than validator2 (no remediation, missed verify-phase1, no feedback on its instructions). The model tier seated for this session was not stated.
- state delta: op-367 issued → returned → closed.
- evidence: REPORT op-367; the re-computed hashes above.
- next: Paste the op-365 REPORT; then apply the held Validator template changes; then op-364's REPORT.

### j-20260927-024 — op-365 closed: validator1 onboarded; calibration feedback applied to validator0

- time / kind: 2026-09-28T01:30:13Z / RETURN
- outcome: validator1 (GLM) returned the op-363 calibration review: claims 1 and 2 hold, claim 3 fails, verdict REMEDIATE, score 9. I verified first-hand its two findings that no one else had: five more scripts still use `${workspace_root}/wip-gpt/…` (asl-a3 and four verify-phase07), and mach-send pins mach.ko `49ac3d89…` (line 61, guard at lines 231-232) while the objdir holds `9c7706a3…`. Its proposed fix is fragile; validator2's is the one to use. With all three calibrations back, the held feedback was applied to rmx-validator0 (`cc3ff9b`): idq and needs defined, the review op's own number used for REPORTs and notes, evidence forms for source reviews, a solo-review provision in Rule 3, and three falsification patterns promoted from the Validators' LOCAL.md. Validators re-rendered: `d2f2e4e`, `cc3a826`, `1beb054`. Their sessions are still open, so each gets a NOTICE to re-read OPS.md and the rulebook. Routing: validator1 + validator2 stays the default pair. The follow-up Implementer op now covers the five extra scripts and reports the pin mismatch (LOCAL.md).
- state delta: op-365 issued → returned → closed.
- evidence: rmx-validator1 `577411c` (LOCAL.md and reviews/op-365/notes.md only); the script lines above; `tools/roles check` reports 4 instances, 0 needing attention.
- next: Relay the Validator NOTICE; paste op-364's REPORT.

### j-20260927-025 — op-364 returned and verified first-hand; review ops drafted for both default Validators

- time / kind: 2026-09-28T01:36:55Z / RETURN
- outcome: The Implementer returned op-364 DONE. I verified it first-hand. wip-rmxos `2884304b` (parent `15c185c`, tree `801b8ae9…`) adds exactly the five profile paths, with hashes equal to op-340's three configs, op-342's Makefile, and op-358's README; the worktree is clean. mach.ko `53e5a8cf…` has a .comment of clang 21.1.8. My own nm comparison found 112 undefined symbols (104 required plus 8 weak) and none missing from the op-343 kernel. The staging mtrees differ only in mach.ko (`1acea1e0…` → `53e5a8cf…`), all seven stages returned 0, and the images I hashed match the REPORT (UFS `ea7157ab…`, GPT `8f546a93…`). The index commit `39b2f89` changes only docs/alpha2-build-chain.md. The gate is `both` (release critical path), so op-368 (validator1) and op-369 (validator2) are drafted. Closure also needs both commits on origin: rmx-implementer `39b2f89` (one commit ahead) and wip-rmxos `2884304b` (branch alpha2 is on no remote; rmxOS is public; decision open).
- state delta: op-364 issued → returned; op-368 and op-369 created (draft).
- evidence: rmx-implementer/build/op364-20260928T001637Z/{evidence,images,obj}; the hashes above.
- next: Relay op-368 and op-369; Coordinator decides the rmx-implementer and alpha2 pushes.

### j-20260927-026 — only ready, concurrency-safe ops are shown to the Coordinator

- time / kind: 2026-09-28T01:42:11Z / DECISION
- outcome: Coordinator rule. The Arranger tells the Coordinator only about ops that are ready to send now and safe to run alongside everything in flight: their needs have closed, their agent is idle, they share no writes, they read nothing another op or the Arranger may change meanwhile, and they need no guest or VM in use. Everything else stays in the IDQ, or in `hold` if a brief exists, and is not mentioned until ready. `draft` now means ready to send (rob-mini-format.md), and rulebook Rule 5 and AGENTS.md (arranger0 template) are updated. Applied now: the follow-up fix for the op-363 scripts became IDQ problem id-044 (fix or retire) instead of a planned op; the Implementer conversion waits until op-368 and op-369 return, so nothing moves under a review.
- state delta: id-044 raised (WAITING).
- evidence: Coordinator message in chat; rob-mini-format.md; arranger-rulebook.md Rule 5; idq/id-044.
- next: Relay op-368 and op-369.

### j-20260927-027 — op-368 and op-369 sent: both default Validators review op-364

- time / kind: 2026-09-28T01:44:27Z / ISSUE
- outcome: The Coordinator relayed op-368 (validator1) and op-369 (validator2), concurrent independent reviews of op-364 under no-lock-git, own-scratch, and independence limits. op-364 closes only if both reach 8 or more and agree, and its commits are on origin.
- state delta: op-368 and op-369 draft → issued.
- evidence: Coordinator message in chat.
- next: Wait for both REPORTs; meanwhile nothing touches rmx-implementer build/op364, the alpha2 worktree, or the Implementer folder.

### j-20260927-028 — Gatekeeper modernized as two instances; roles sync for remote instances

- time / kind: 2026-09-28T02:08:14Z / ACTION
- outcome: Coordinator direction: the Gatekeeper has an mx instance on the M4 Mac mini, and all legacy directories are to be modernized. Built rmx-gatekeeper0 (`d49f9cf`), with the host as an instance variable and REPORT lines for attempts and disposition. gatekeeper1: `rmx-gatekeeper` snapshot `e25df5a` (27 files as found; crash dumps and disk images now ignored, build/ run trees left untracked), renamed `rmx-gatekeeper1` with a symlink, and converted `1414af2` (ONBOARDING.md moved to docs/ as history; README repointed). gatekeeper2: mm4's legacy unified Oracle `~/Local/wip-mach/mach-oracle` got snapshot `ab5202b` (a macOS 26 artifacts run), was renamed `rmx-gatekeeper2` with a `mach-oracle` symlink, and converted `8877835` from the local mirror `rmx-gatekeeper2` (`ac7e002`). tools/roles gained remote instances ("remote" in instance.json) and `roles sync` (tar over SSH; refuses remote edits and unsynced files unless --force or --adopt; never overwrites the remote LOCAL.md); 14 roles tests pass. Root partial: template location is now a block (rmx-role0 `197ce7b`). mm4 access: the Coordinator authorized installing mDNSResponder (`doas pkg install`), and mdnsd was started for this boot only (onestart, not enabled at boot). mm4.local resolved to 192.168.4.47 and .22; the host key was recorded under alias mm4 (ED25519 SHA256:oGl+Y6+r2gIERKHWw6SlQX/4qhvCxxPZ6eeOiI/y618); the Coordinator supplied ~/.ssh/social3.pem. SSH still needs `-o HostName=<ip>` (ROLES_SSH_OPTS), because this host does not resolve .local names. Findings: rmx-gatekeeper1's 41 unpushed commits include a 6.5 GB disk image (build/op247/op247.img, `117e718`), so that history cannot be pushed to GitHub as it stands; its `.git/worktrees/wip-gpt-oracle-ui-core` is stale metadata from the oracle fork (never run `git worktree repair` there).
- state delta: op-370 (gatekeeper1) and op-371 (gatekeeper2) onboarding ops created (draft).
- evidence: the commits above; `tools/roles check` reports 6 instances, 0 needing attention.
- next: Relay op-370 and op-371; Coordinator decides the op247.img history fix and a stable mm4 address.

### j-20260927-029 — remote instances get their class template beside them

- time / kind: 2026-09-28T02:13:01Z / DECISION
- outcome: Coordinator direction. gatekeeper2 is on another host, so the gatekeeper0 template is copied to mm4 beside it, where the remote agent can read the shared role definition. `roles sync` now also copies an instance's class template, without .git, to the same parent folder on the remote host. The same guards apply (a template copy edited there blocks the next sync unless --force), the synced template digests are recorded, and `roles check` reports template changes not yet synced. The source of truth stays here; the remote copy is read-only. gatekeeper2's template_location override was removed because `../rmx-gatekeeper0/` is now true on mm4. Commits: rmx-gatekeeper0 README `f2359b5`; mm4 rmx-gatekeeper2 `06fb1a5`; mirror `17e25a7`. roles tests: 17 pass. op-371 (unsent) now points the Mac Gatekeeper at the template copy.
- state delta: none.
- evidence: mm4 ~/Local/wip-mach/rmx-gatekeeper0 (README, template.json, files/AGENTS.md, files/OPS.md); `tools/roles check` reports 6 instances, 0 needing attention.
- next: Relay op-370 and op-371.

### j-20260927-030 — op-370 and op-371 sent: both Gatekeepers onboarding

- time / kind: 2026-09-28T02:16:01Z / ISSUE
- outcome: The Coordinator relayed op-370 (gatekeeper1, FreeBSD host) and op-371 (gatekeeper2, mm4): read-only onboarding with a baseline from disk. They run alongside op-368 and op-369 without sharing writes or reading anything under review.
- state delta: op-370 and op-371 draft → issued.
- evidence: Coordinator message in chat.
- next: Wait for the op-368, op-369, op-370, and op-371 REPORTs.

### j-20260928-001 — gatekeeper2 lives only on mm4; roles sync and the local mirror removed

- time / kind: 2026-09-28T02:35:51Z / DECISION
- outcome: Coordinator direction: keep remote instances simple. gatekeeper2 exists only on mm4, beside a plain copy of rmx-gatekeeper0; the Arranger reaches it over SSH, and the Coordinator relays to its Codex CLI agent the same way. Removed `roles sync`, the "remote" handling, the sync record, and ROLES_SSH_OPTS from tools/roles (6 tests dropped; 1 added: an instance kept elsewhere renders in a temporary workspace that links the templates). The local mirror `rmx-gatekeeper2` (`ac7e002`, `17e25a7`) left the workspace (moved to the session scratchpad); its five instance files were byte-identical to mm4's. The re-render route was verified read-only against mm4: its instance.json, lock, LOCAL.md, and two rendered files, fetched into a temporary workspace, rendered "up to date" with an unchanged lock. rob check no longer looks for a repo written host:/path; op-371's repo is now `mm4:/Users/linz/Local/wip-mach/rmx-gatekeeper2`. Updated roles.md, terminology.md, op-brief-forms.md, now.md, and the rmx-gatekeeper0 README. Nothing on mm4 changed, because op-371 is in flight there (a Codex session was running).
- state delta: op-371 repo field only (still issued).
- evidence: roles tests 12 pass; rob tests 15 pass; `tools/roles check` 5 instances, 0 need attention; `tools/rob check` 0 with problems; sha256 local vs mm4 identical (5 instance files, 4 template files).
- next: After op-371 returns, replace the rmx-gatekeeper0 copy on mm4 (README changed) and drop "remote" and the mirror comment from gatekeeper2's instance.json there. No NOTICE: nothing the agent relies on changes.

### j-20260928-002 — ssh mm4 pinned to 192.168.4.47; mDNS deferred

- time / kind: 2026-09-28T02:40:23Z / ACTION
- outcome: Coordinator direction: set mm4's IP in the SSH config and solve mDNS completely later. In ~/.ssh/config, Host mm4 now has HostName 192.168.4.47 (was mm4.local) and HostKeyAlias mm4, so the host keys recorded under mm4 (ed25519, rsa, ecdsa) still match and an address change only touches HostName. Plain `ssh mm4` works from this host with BatchMode (answered hostname mm4.local, macOS 27.0). File mode stays 600. mDNS for mm4.local on this host is deferred; mdnsd from the earlier one-time start is still running (not enabled at boot, so it ends at reboot).
- state delta: none.
- evidence: `ssh -o BatchMode=yes mm4 'hostname; sw_vers -productVersion'` → `mm4.local`, `27.0`; the previous config is backed up in the session scratchpad.
- next: none; mDNS when the Coordinator takes it up.

### j-20260928-003 — op-371 returned and closed: gatekeeper2 onboarded

- time / kind: 2026-09-28T02:45:11Z / RETURN
- outcome: gatekeeper2's REPORT (DONE, read-only) was verified first-hand on mm4 and closed as S (gate self, confidence 9). All 15 evidence hashes match. The repo is clean on main at 06fb1a5, 3 commits ahead of origin (the Arranger's snapshot and conversion commits), and the op wrote nothing. Its evidence choice is right: the newest macOS runs are macos-validation/results/mx-a64z/20260619-27.0-27.0.0 (12 checks, all "pass", on macOS 27.0 beta 26A5353q) and artifacts/oracle/macos26/oracle.mach_ipc.cross_task_inline.v1/20260604T031557Z ("pass"); mx-a64z/ holds older write-ups from 2026-05-12/13. Filled in first-hand what the REPORT left out: the login shell provides Elixir 1.20.0 (compiled with OTP 28) on Erlang/OTP 29, and Zig 0.16.0; the host now runs macOS 27.0 build 26A428, which is newer than the evidence build. Gaps: the REPORT block gave no per-run reading, and its commits line listed existing commits instead of none. The toolchain was left untested because the brief said "no runs"; that ambiguity is the brief's, not the agent's (LOCAL.md lessons).
- state delta: op-371 issued → returned → closed.
- evidence: `shasum -a 256 -c` on mm4 (15 OK); `git status -sb` on mm4; statuses read from the 12 result JSONs; versions from `zsh -l` on mm4.
- next: none for gatekeeper2 until a macOS-truth op is needed; a re-run on 26A428 would need run authority.

### j-20260928-004 — mm4 cleanup after op-371: template copy replaced, instance.json tidied

- time / kind: 2026-09-28T02:45:11Z / ACTION
- outcome: With op-371 returned and gatekeeper2's Codex session idle, replaced the rmx-gatekeeper0 copy on mm4 (now identical to the local tree at faf7acd: 4 files, no .git) and removed the old "remote" key and mirror comment from gatekeeper2's instance.json. That change is rmx-gatekeeper2 39d92e7 on mm4, not pushed; main is 4 commits ahead of origin. The render is unchanged: a temporary-workspace render was up to date and the lock identical. No NOTICE, because nothing the agent relies on changed.
- state delta: none.
- evidence: local vs mm4 hash comparison (4 template files identical); rmx-gatekeeper2 39d92e7.
- next: Push rmx-gatekeeper2 (origin lin72h/mach-oracle) only when the Coordinator asks. Its 4 unpushed commits are small (largest blob 53 KB).

### j-20260928-005 — gatekeeper2 gets its own GitHub repo, lin72h/rmx-gatekeeper2

- time / kind: 2026-09-28T02:49:14Z / ACTION
- outcome: Coordinator direction: create a new repo for gatekeeper2 instead of pushing to mach-oracle. Created github.com/lin72h/rmx-gatekeeper2, private like mach-oracle; making it public is the Coordinator's call. First, the repo note that named mach-oracle as the remote was re-rendered (instance.json block, AGENTS.md, and lock: rmx-gatekeeper2 510d275 on mm4). Then origin on mm4 was pointed at the new repo, and main was pushed from a bare clone on this host, because mm4 cannot authenticate to GitHub from a non-interactive SSH session (Permission denied (publickey)). GitHub main equals mm4 HEAD 510d275. mm4's origin/main was set to it with update-ref, so `git status` there shows main in sync. lin72h/mach-oracle is untouched (private; main at 9ed6170).
- state delta: none.
- evidence: `git ls-remote git@github.com:lin72h/rmx-gatekeeper2.git refs/heads/main` → 510d275cf9ee2f757f952f29bc1afe294c2768fb; `gh repo view` → PRIVATE, default branch main.
- next: The Coordinator relays the NOTICE to gatekeeper2 (origin and the AGENTS.md repo note changed).

### j-20260928-006 — op-369 returned and consumed: validator2 says CLOSE op-364 at 9

- time / kind: 2026-09-28T02:54:02Z / RETURN
- outcome: validator2 reviewed op-364 with its own sharpened question: does the byte chain hold end to end, from 2884304b and op-343's compiler to the module in the delivered image, with everything else still matching op-358? It found that all four claims hold. Verdict CLOSE, score 9; it recorded two failed falsification threads and did not read validator1's review. Consumed after a light provenance check (confidence 9): all 14 file evidence hashes match first-hand, including both UFS copies (ea7157ab…) and the GPT image (8f546a93…); the review is rmx-validator2 d401250 (reviews/op-369/op-364-review.md plus LOCAL.md lessons; local Git, no origin); rmx-implementer 39b2f89 and alpha2 2884304b exist as cited. Carried into the boot test: mach.ko needs the kernel's LOCAL knote_enqueue, which resolves only through leak-locals (debug.link_elf_leak_locals=1, the default) and the loader's symbol table; op-343's module had the same dependency. This also corrects the Arranger's op-364 symbol check, which counted .symtab membership (LOCAL.md). Format slips: a duplicated REPORT line again, and a commit given without its repo.
- state delta: op-369 issued → returned → closed. op-364 stays returned until op-368 (validator1) returns and agrees.
- evidence: sha256 of the 14 cited files (all OK); `git log`/`show --stat` of rmx-validator2 d401250; now.md boot-test note.
- next: Wait for op-368. Closing op-364 then needs rmx-implementer 39b2f89 and alpha2 2884304b on origin, or the Coordinator's waiver.

### j-20260928-007 — op-370 returned and closed: gatekeeper1 onboarded; the op-358 image had been booted

- time / kind: 2026-09-28T02:58:39Z / RETURN
- outcome: gatekeeper1's REPORT and narrative were verified first-hand and closed as S (gate self, confidence 9). Both evidence hashes match. The repo is at 1414af27, 43 commits ahead of origin/main 4b16fd1b, with 62 untracked entries; 117e718 carries build/op247/op247.img at 6,476,638,720 bytes, over GitHub's limit. Key fact for the critical path, which corrects the op-361 baseline in now.md: the op-358 final image (96644d80…, final-op358-alpha2-gpt.raw per the Implementer's artifact-hashes.txt) was booted by op359 and op360 on 2026-09-25. op360's third attempt (VM …044634Z-24151; 2 vCPU, 4G, one disk, no network, shares, or passthrough) loaded mach.ko ("mach system calls available"), passed Mach 4/4 and dispatch 4/4 with twq_attribution UNTESTED, and powered down after 46 s. So the leak-locals path for knote_enqueue already worked at boot with the op-358 module. For steps 6–7: reuse the op360 runner, re-pinned from its wip-gpt op-358 paths to op-364's image. No formal containment disposition is recorded; vmm is not loaded now. The host is bdw-fx15-x64z (seat rx-x64z); the host_desc fix is queued for the next gatekeeper render.
- state delta: op-370 issued → returned → closed.
- evidence: sha256 of serial.raw and host-orchestration.log (OK); op360 run dir: module-inventory.raw, module-dmesg.raw, probe-mach-output.raw, probe-dispatch-output.raw, serial.raw; op358 evidence/artifact-hashes.txt; `git rev-list --count`; `git cat-file -s`; `kldstat -n vmm`.
- next: Wait for op-368. Coordinator decision before gatekeeper1's first op with commits can close: how its history (the 6.5 GB image in 117e718) reaches an origin.

### j-20260928-008 — gatekeeper1 history rewritten without the 6.5 GB image; new private repo lin72h/rmx-gatekeeper1

- time / kind: 2026-09-28T03:08:53Z / DECISION
- outcome: The Coordinator left the gatekeeper1 history decision to the Arranger. Chosen: the same pattern as gatekeeper2, with a history rewrite of the unpushed range only. With no op in flight and gatekeeper1's Codex session idle, the 43 commits after 4b16fd1b were rewritten with `git filter-branch --index-filter` in a shared bare clone, so the working tree and the image file were never touched. Only build/op247/op247.img was removed (blob 07bde8c1…, sha256 b98fbcb5…c4106, identical to the file on disk, which stays in place and is now ignored by *.img). 24 commits keep their IDs; the 19 from 117e718 on were rewritten, each differing from its original only by that path, with identical authors, dates, and messages. The new history has no blob over 50 MB and pushes 2.3 MB. In the live repo, old main 1414af27 is kept at refs/archive/pre-rewrite-2026-09-28 (never to be pushed), and main moved to 48b4597 by index-only reset. gatekeeper1 then got docs/history-rewrite-2026-09-28.md (the full old→new map, c444d74) and a re-render (589b945) that names the new remote and the host bdw-fx15-x64z (seat rx-x64z). Created github.com/lin72h/rmx-gatekeeper1 (private), pointed origin at it, and pushed main. The public lin72h/rmx-gatekeeper is untouched (main 4b16fd1b). Old IDs cited earlier in this journal (e25df5a, 1414af2) map to a39cdbe and 48b4597.
- state delta: none.
- evidence: image stat (inode 9225921, 6476638720 bytes, same mtime) before and after; `git hash-object` = committed blob; pair check over all 43 commits; `git ls-remote` main = HEAD 589b9450ca613cc2652503992572f4b3b920afc7; `gh repo view` → PRIVATE.
- next: The Coordinator relays the NOTICE to gatekeeper1 before any further op. gatekeeper1 ops that make commits can now meet the origin rule.

### j-20260928-009 — op-368 returned and consumed: both Validators say CLOSE op-364

- time / kind: 2026-09-28T03:15:42Z / RETURN
- outcome: validator1 reviewed op-364 layer by layer with its own question: commit inputs, module build, staged tree, makefs spec, UFS bytes, and GPT wrap each equal op-358's except mach.ko. Verdict CLOSE, score 9.5. It found 104 required and 8 weak undefined symbols, all satisfied by the retained op-343 kernel. It hashed all 30,641 staged files and 1,113 symlinks itself, and its own GPT parse and partition hash reproduced the UFS image. Consumed after a light provenance check (confidence 9.5). The review is rmx-validator1 da865b2 (reviews/op-368/op-364.md plus a LOCAL.md lesson; local Git). The five commit blobs of 2884304b hash as cited, and so do the obj-dir mach.ko, module-symbol-check.txt, staging-after.mtree, and METALOG.op364.reconciled (the pasted REPORT had fused, cut-off lines, so exact values came from the committed file). Its three non-claim observations, all inherited from op-344→op-358 (a stale /METALOG.reconciled inside the tree, 263 makefs duplicate-definition warnings, an inconsistent op-358 final-gpt-inspection.txt), went to id-012. With validator2's CLOSE at 9 (op-369), op-364 has both reviews at 8 or more, in agreement.
- state delta: op-368 issued → returned → closed. op-364 stays returned until its commits are on origin: rmx-implementer 39b2f89 (private lin72h/project-rmx, 1 ahead) and alpha2 2884304b (public lin72h/rmxOS, 1,930 commits on no origin branch, mostly the upstream stable/15 merge; no blob over 50 MB; not on the local backup remote either).
- evidence: `git log`/`show --stat` of rmx-validator1 da865b2; sha256 of the five commit blobs and four cited files (OK); `git rev-list` counts; `gh repo view` visibilities.
- next: The Coordinator decides the two pushes (publishing alpha2 needs an explicit yes); then close op-364 and present the Gatekeeper boot op.

### j-20260928-010 — op-364 closed after both pushes; op-372 drafted for the contained boot

- time / kind: 2026-09-28T03:21:43Z / DECISION
- outcome: The Coordinator chose to push both. rmx-implementer 39b2f89 went to the private lin72h/project-rmx (main dfe9a60..39b2f89), and alpha2 2884304b went to the public lin72h/rmxOS as a new branch. Both were verified with `git ls-remote`, and op-364 closed (gate both: validator1 9.5, validator2 9, in agreement; commits on origin). Drafted op-372 (gatekeeper1, steps 6–7 bundled): prepare, then a bounded, contained boot of the op-364 image with up to 2 guest attempts, loading vmm with doas if absent, and pushing to rmx-gatekeeper1. While preparing it, the passing op360 attempt turned out not to match the launcher on disk. Its host log records Expect driver boot-op360-r2.expect 7bcd0682…, plan guest-sequence-alignment-r1.tsv cc93815a…, and Mach probe alignment-r1/bin/mach_probe_diag 72be4d2c…, while run-op360-r2.sh (c642924f…) pins bin/mach_probe_diag 0830f1a0… and guest-sequence.tsv. op-372 therefore pins the passing basis and changes only the image-side pins. The Implementer rename now waits for op-372, which reads the image under rmx-implementer/build/.
- state delta: op-364 returned → closed; op-372 created as draft.
- evidence: `git ls-remote` for project-rmx main (39b2f89972d6…) and rmxOS alpha2 (2884304b67fc…); sha256 of op360's driver, plan, and probes and of op-364's image inputs; op360 host-orchestration.log lines 10–20.
- next: Present op-372; it is ready and nothing else is in flight. gatekeeper1's NOTICE (j-20260928-008) must be relayed first.

### j-20260928-011 — op-372 sent; gatekeeper1 NOTICE relayed

- time / kind: 2026-09-28T03:23:17Z / ISSUE
- outcome: The Coordinator relayed gatekeeper1's NOTICE (history rewrite and new origin, j-20260928-008) and then op-372: preparation, containment disposition, and a bounded, contained boot of the op-364 image, with up to 2 guest attempts, vmm load authority, and a push to rmx-gatekeeper1. It is the only op in flight.
- state delta: op-372 draft → issued.
- evidence: Coordinator message in chat.
- next: While op-372 runs, apply the queued validator0 template changes (no Validator has an op in flight). Do not touch rmx-gatekeeper1 or rmx-implementer until op-372 returns.

### j-20260928-012 — validator0 updated: concurrency defaults and four falsification patterns

- time / kind: 2026-09-28T03:24:18Z / ACTION
- outcome: With no Validator op in flight, all three repos clean, and their sessions idle, the per-brief limits from op-368/op-369 became standing OPS.md defaults ("Working alongside other ops": lock-free git in other roles' repos, scratch under reviews/op-NNN/scratch/, no reading the other reviewer before the REPORT). The rulebook gained four falsification patterns: .comment names the building compiler; symbol checks must name the resolution path; an image diff is layout until shown otherwise; verify image-delta claims layer by layer. Commits: validator0 edf1597, rmx-validator1 24f24ae, rmx-validator2 4c7ae12, rmx-validator3 258252b. `roles check`: 5 instances, 0 need attention.
- state delta: none.
- evidence: the commits above; the render output (OPS.md and validator-rulebook.md per instance).
- next: The Coordinator relays the Validator NOTICE (one text for all three). The rmx-role0 report-partial change waits for op-372 (it re-renders gatekeeper1).

### j-20260928-013 — Validator NOTICEs relayed

- time / kind: 2026-09-28T03:28:33Z / ACTION
- outcome: The Coordinator relayed the validator0 NOTICE (j-20260928-012) to validator1, validator2, and validator3.
- state delta: none.
- evidence: Coordinator message in chat ("3 sent").
- next: While op-372 runs, inspect the Explorer repos (here and on mm4) for modernization.

### j-20260928-014 — Explorer split into two instances: explorer1 done, explorer2 waits for mm4 Xcode

- time / kind: 2026-09-28T03:37:28Z / DECISION
- outcome: Coordinator decision: the Explorer's two seats become two instances with separate repos, like the Gatekeepers, not one shared repo. Created template rmx-explorer0 (local Git 81e62c3: AGENTS.md from the roles table and the still-valid legacy craft rules — Zig/Elixir test logic, shell discipline, guest-run preflight, attempt accounting; OPS.md allowing read-only commands; an attempts line in the REPORT). Its plain copy on mm4 is identical (4 files, no .git). explorer1 (rx-x64z, here): the clone was renamed rmx-explorer → rmx-explorer1 (symlink kept); loose work snapshotted 5336897 (a findings log and a soak conductor; *.core now ignored, the 24 MB core dump stays on disk); converted 3354264 (ONBOARDING.md → docs/ONBOARDING-2026-06-21.md, README repointed, rendered with --adopt); old origin renamed `shared`; pushed to new private github.com/lin72h/rmx-explorer1 (main = HEAD 33542646). explorer2 (mx-a64z, mm4): nothing changed yet. The first git call there found no developer directory (no Xcode, no Command Line Tools, only the /usr/bin/git shim), opened the "Install Command Line Developer Tools" dialog, and consumed the rest of the stdin-fed script, so no snapshot or rename happened. The Coordinator is reinstalling Xcode on mm4. Lesson: run mm4 scripts from a copied file with stdin from /dev/null (LOCAL.md).
- state delta: none.
- evidence: rmx-explorer0 81e62c3; rmx-explorer1 5336897, 3354264; `git ls-remote` of lin72h/rmx-explorer1; mm4 checks (`whence -a git`, `xcode-select -p` error, CommandLineTools absent).
- next: Once Xcode is back on mm4, finish explorer2: snapshot 3 findings dirs, rename, onboarding doc and README, instance.json, render, commit, new private repo lin72h/rmx-explorer2. Then update terminology, roles, and now.md, and prepare the two Explorer onboarding ops.

### j-20260928-015 — explorer2 converted on mm4; Explorer onboarding ops drafted

- time / kind: 2026-09-28T03:44:20Z / ACTION
- outcome: After the Coordinator's Xcode reinstall, git works on mm4 again (Apple Git 2.54.0 from /Applications/Xcode.app, login and non-interactive). explorer2 (mx-a64z) on mm4: loose findings snapshotted 0498dfd (op190 xpc cancel and echo truth, op232 concurrency truth); renamed rmx-explorer → rmx-explorer2 (symlink kept); converted 0327f73 (ONBOARDING.md → docs/ONBOARDING-2026-06-21.md, README repointed, instance.json installed, rendered through a temporary workspace with --adopt, byte-identical on mm4). The old origin was renamed `shared`, and main was pushed from a bare clone here to new private github.com/lin72h/rmx-explorer2; mm4 main tracks origin/main and is in sync. The rmx-explorer0 copy on mm4 is identical to the local template. Updated terminology.md (§4 rows, §9 map), roles.md (Explorer row, classes), and now.md. Drafted op-373 (explorer1) and op-374 (explorer2): read-only onboarding baselines, safe alongside op-372.
- state delta: op-373 and op-374 created as draft.
- evidence: mm4 rmx-explorer2 0498dfd, 0327f73; `git ls-remote` of lin72h/rmx-explorer2 = 0327f73547cf…; hash comparisons of the rendered files and the template copy.
- next: Present op-373 and op-374 (ready, read-only, no shared writes with op-372). Then the Oracle.

### j-20260928-016 — op-373 returned and closed: explorer1 onboarded

- time / kind: 2026-09-28T03:54:09Z / RETURN
- outcome: explorer1's REPORT and narrative were verified first-hand and closed as S (gate self, confidence 9). All 4 evidence hashes match (three op-097 rx dispatch-matrix results and op232 macOS truth). The repo is clean at 33542646 with 0 commits off origin. This host has Zig 0.15.2 and Elixir 1.20.0 on Erlang/OTP 29 (the macos-validation README names Zig 0.16 as default; mm4 has 0.16.0). The six findings it summarized exist, with the recorded verdicts. One label was paraphrased: op-318's verdict is NEEDS-IMPLEMENTER-CONTAINMENT-HELPER, not "PREP-NEEDS-CONTAINMENT-HELPER". Its flagged instruction issue was real (README lines still called ONBOARDING.md authoritative) and is fixed in explorer1 f6277a4 (local, not pushed); explorer2's copy waits for op-374. Useful state for later: the newest rx work is the PID-1/launchd contract line (op-315, op-318, op-322 → CORRECTED-CONTRACT-READY-FOR-VALIDATION, id-016), and the Mach receive records (op-097 green on 129ee3c; op-241 panic on another image) do not establish one current result.
- state delta: op-373 draft → issued → returned → closed (the Coordinator relayed it; the REPORT is the send confirmation).
- evidence: sha256 of the 4 cited files; `git rev-list`/status in rmx-explorer1; `zig version`, `elixir --version`; grep of the six findings' verdict lines.
- next: op-374 when the Coordinator sends it; op-372 still running.

### j-20260928-017 — op-374 returned and closed: explorer2 onboarded

- time / kind: 2026-09-28T03:56:15Z / RETURN
- outcome: explorer2's REPORT and narrative were verified first-hand on mm4 and closed as S (gate self, confidence 9). The repo is clean at 0327f73, 0 ahead, with origin rmx-explorer2 and shared rmx-explorer. Four evidence hashes match exactly. The fifth (environment.json) matches 7f8a81fd…8095 on disk; the pasted value lacks 4 middle characters, a copy slip. Toolchain as reported: Xcode 27.0 (27A266a), Swift 6.4, Zig 0.16.0, Elixir 1.20.0 on OTP 29, macOS 27.0 26A428. Spot checks hold: the 2026-06-21 Mach/dispatch run is 21/21 pass on beta 26A5353q; notify 10 passes; ASL one failure (asl_search_roundtrip, also seen on rx); ob2.4 on 26.5/25F71. So the macOS truth predates the current build, and several captures do not record a build. Fixed the README pointer it flagged (mm4 explorer2 90d5344, not pushed; explorer1's twin is f6277a4).
- state delta: op-374 draft → issued → returned → closed.
- evidence: `shasum -a 256` of the five cited files on mm4; `xcodebuild -version`, `swift --version`, `zig version`, `sw_vers`; counts in the 20260621 run dir.
- next: Both Explorers are onboarded. op-372 is still running. Next modernization: the Oracle.

### j-20260928-018 — the Oracle role renamed Advisor; three Advisor instances converted

- time / kind: 2026-09-28T04:01:00Z / DECISION
- outcome: Coordinator decision: the consult role "Oracle" becomes "Advisor". Lowercase "oracle" keeps only its test sense and legacy artifact names. Created template rmx-advisor0 (local Git 8dbf3c4). It keeps the still-valid Oracle-era rules: framing every consult as open-source OS engineering so a model's safety layer does not misread kernel design review, first-hand reading, overclaim-strict proposals, no product writes, and plain text. Its REPORT adds question, consult, and proposal lines. The three plain folders became Git instances with transitional symlinks: rmx-oracle → rmx-advisor1 (snapshot ca6f7e0; Oracle-era AGENTS.md and oracle-rulebook.md moved to docs/ as history; converted 2d4e274), rmx-oracle2 → rmx-advisor2 (snapshot e400a08 with two core dumps ignored; 67bfbf1), rmx-oracle3 → rmx-advisor3 (17aa85e; 015f225). No agent was working in them. Renamed the role in roles.md, terminology.md (definition, repo table, §9 map), now.md, the Arranger rulebook (Advisor briefs lead with the framing), and the Arranger's harness note; re-rendered rmx-arranger. `roles check`: 9 instances, 0 need attention. The Advisors have no remote yet.
- state delta: none.
- evidence: the commits above; the render output.
- next: The Coordinator decides whether the Advisors get private GitHub repos like the other instances, and names each seat's model (for routing). Then Advisor onboarding.

### j-20260928-019 — advisor4 added on mm4 (mx-a64z, macOS side)

- time / kind: 2026-09-28T04:03:21Z / DECISION
- outcome: Coordinator direction: add a macOS-side Advisor for difficult tasks. Created advisor4, which lives only on mm4 at /Users/linz/Local/wip-mach/rmx-advisor4 (local Git ed0a690). It is rendered from advisor0 through a temporary workspace; the rendered files on mm4 are byte-identical to the local render, and a plain copy of rmx-advisor0 sits beside it (identical, 4 files). Its seat note lets it read the macOS 27 SDK, system headers, and man pages and inspect system binaries with read-only tools; it runs no probes, since explorer2 records macOS truth. Updated roles.md (Advisor row, classes, the on-mm4 instance list), terminology.md (repo table), and now.md.
- state delta: none.
- evidence: mm4 rmx-advisor4 ed0a690; hash comparisons of the rendered files and the template copy.
- next: The Coordinator decides private GitHub repos for the four Advisors and names each seat's model; then Advisor onboarding.

### j-20260928-020 — Advisor template on GitHub; instances stay local; routing by question

- time / kind: 2026-09-28T04:05:53Z / DECISION
- outcome: Coordinator decisions. Only the template goes to GitHub: created private github.com/lin72h/rmx-advisor0 and pushed main aa8168d (its README now names advisor4); the mm4 copy was refreshed and is identical. The four Advisor instances stay local Git with no origin. Seat models were left to the Arranger: they are not recorded, and routing is by question (roles.md § Choosing an Advisor: macOS-side questions to advisor4, the rest to advisor1–3, every consult treated as expensive). The closure rule now states the exemption that Validator review closures (op-365–op-369) already relied on: repos without an origin by Coordinator decision (Validators, Advisors) are verified locally. Advisor onboarding folds into each seat's first consult brief instead of four separate ops.
- state delta: none.
- evidence: `git ls-remote` of lin72h/rmx-advisor0 = aa8168d7812666e198d98194a8f1b93664e8e6f7; hash comparison of the mm4 template copy.
- next: op-372's REPORT. The first consult brief to each Advisor carries a one-line introduction to the new workflow.

### j-20260928-021 — op-372 returned: the op-364 image boots contained; Mach and dispatch slice passes

- time / kind: 2026-09-28T04:09:51Z / RETURN
- outcome: gatekeeper1's REPORT was verified first-hand before routing to review. All 4 evidence hashes match. The host log shows image_original = the op-364 image, image_sha256 = 8f546a93…, probes Mach 72be4d2c… and dispatch f6c52015… (op360's passing basis), and Expect driver 7bcd0682…. The run used the launcher that actually produced op360's passing attempt, run-op360-alignment-r1.sh (a10382f6…, now committed), parameterized by build/op372/config.sh; the plan (a8dff3e1…, regenerated by make_plan.exs) differs from the alignment-r1 basis only in the module hash pin (1acea1e0… → 53e5a8cf…) and the added leak-locals step. Raw serial: mach.ko in kldstat, "mach services loaded", debug.link_elf_leak_locals: 1, no undefined symbol, root login, power-down after 46 s. This settles op-369's knote_enqueue carry-forward by observation. Probes: Mach 4/4 and dispatch 4/4 PASS; twq_attribution UNTESTED. Attempts 1/2; containment disposition recorded before launch and the run disposition accepted; commits e5d46af and a4a9836 on private origin; /dev/vmm empty, vmm.ko left loaded as authorized. Gate is both (critical path; a gate can be raised, never lowered): drafted op-375 (validator1) and op-376 (validator2) with the same claims and full pins.
- state delta: op-372 issued → returned; op-375 and op-376 created as draft.
- evidence: sha256 of the cited files; host-orchestration.log header; serial.raw lines 15, 203, 219, 300, 4256, 4271; `git merge-base --is-ancestor` against `git ls-remote origin`; `diff` of the plan against the basis.
- next: Present op-375 and op-376. After both return: close op-372, then the Implementer rename and the Gatekeeper report-partial render (both wait so nothing moves under a review).

### j-20260928-022 — op-375 and op-376 sent: both Validators review op-372

- time / kind: 2026-09-28T04:11:31Z / ISSUE
- outcome: The Coordinator relayed op-375 (validator1) and op-376 (validator2), identical reviews of op-372 with full pins. They run concurrently under validator0's standing concurrency defaults.
- state delta: op-375 and op-376 draft → issued.
- evidence: Coordinator message in chat.
- next: Wait for both REPORTs. Until they return, leave rmx-gatekeeper1, rmx-implementer, and both Validator repos untouched.

### j-20260928-023 — op-376 returned and consumed: validator2 says CLOSE op-372 at 9; id-045 raised

- time / kind: 2026-09-28T04:59:12Z / RETURN
- outcome: validator2 reviewed op-372 with its own sharpened question: the identity chain from the verified copy through the loader to the guest's own hash and kldstat, with leak-locals read as the shipped default and not set by the run. All four claims hold. Verdict CLOSE, score 9. It confirmed containment from inside the guest (one virtio block device of the image's sector count, no NIC, only lo0), confirmed ordering by commit timestamps, scanned the whole 324,692-byte serial for "undefined" and "symbol" (0 hits), confirmed the plan has no setter for the tunable, and re-derived both image hashes. It dismissed one anomaly (5120 MB real memory under -m 4G, the same in op-347 and op-349). Consumed after a light provenance check: rmx-validator2 fe2b3c5 (reviews/op-376/op-372-review.md; scratch in-repo per the new default); rmx-gatekeeper1 untouched at a4a9836; the disposable copy hash 48d385a4… matches host-orchestration.log line 3912. Its proposed negative-control run became IDQ id-045, with options to accept, harden, or test, and the Arranger's proposal to accept and document now and harden after the preview. Format: a third duplicated REPORT line; a template fix is queued.
- state delta: op-376 issued → returned → closed. op-372 stays returned until op-375 (validator1).
- evidence: `git log`/`show --stat` of rmx-validator2 fe2b3c5; `git status` of rmx-gatekeeper1; host-orchestration.log line 3912.
- next: Wait for op-375.

### j-20260928-024 — op-372 closed: the alpha2 regression critical path is complete

- time / kind: 2026-09-28T05:08:09Z / RETURN
- outcome: validator1's op-375 (CLOSE 9.5, with its own sharpened question: the in-guest module hash, leak-locals 1, 8 case PASS lines in raw console bytes, a pre-run-verified fresh copy, one attempt, clean power-off, no VM left) was consumed after a light provenance check: rmx-validator1 7c61ba0 (reviews/op-375/op-372.md; scratch in-repo); loader.raw 53873ae9…, attempt-marker b9b7ec1e…, run-command 4846796d…, and the host-test result-summary de1f3c21… match (the pasted REPORT had fused lines and a mangled path; exact values came from disk); rmx-gatekeeper1 untouched. With validator2's CLOSE at 9 (op-376) the two agree at 8 or more, and the commits e5d46af and a4a9836 are on origin, so op-372 closed (gate both). Critical path steps 1–7 of the alpha2 regression milestone are done. Limits stay recorded: TWQ attribution untested, a bounded slice, no release-wide regression claim. Correction to j-20260928-016: explorer1's "PREP-NEEDS-CONTAINMENT-HELPER" for op-318 is the label this repo's id-042 uses; the finding file itself says NEEDS-IMPLEMENTER-CONTAINMENT-HELPER, so it was not a slip.
- state delta: op-375 issued → returned → closed; op-372 returned → closed.
- evidence: `git log`/`show --stat` of rmx-validator1 7c61ba0; sha256 of the four additional files; rmx-gatekeeper1 status.
- next: The Coordinator chooses the next milestone focus from id-042's open boxes (proposal: PID-1 launchd via op-322's XL gates, after re-basing its contract from alpha 26655e67 to alpha2). Two pure decisions are pending: the launchd service-plane bar and the libxpc quality disposition (id-021). Housekeeping is now unblocked: Implementer rename and template, and the template fixes.

### j-20260928-025 — housekeeping after op-372: template fixes, brief re-read line, Implementer converted

- time / kind: 2026-09-28T05:13:19Z / ACTION
- outcome: With nothing in flight, three queued items were applied. (1) Every new brief now ends "Before you start, re-read OPS.md in your repo: it holds the defaults and the REPORT block" (tools/rob; rob tests 15 pass), and op-brief-forms.md says a change to OPS.md alone needs no NOTICE. This cuts relaying. (2) Templates: rmx-role0 c170d88 (the commits line covers each commit this op made), gatekeeper0 35bcb0c (read-only commands allowed), validator0 8495aa1 (the REPORT block printed once). Re-rendered OPS.md: explorer1 7affb09, gatekeeper1 c17f2bd, validator1 571a901, validator2 a09c785, validator3 200c964; on mm4 gatekeeper2 0cb46e6 and explorer2 241284e through temporary workspaces; the rmx-gatekeeper0 copy on mm4 was refreshed. Advisors are unaffected (they override the commits line). No NOTICEs are needed for these. (3) Implementer: with no op in flight and its Codex session idle, the folder rmx-implementer1 became rmx-implementer again (rmx-implementer1 and wip-gpt are now symlinks to it; the wip-rmxos worktrees resolve through the kept path, and worktree repair was not run). It gained the embedded template implementer0/ (the same rules; the project context and self-containment now come from the shared partials; the legacy oracle mention was dropped), and was rendered with --adopt and committed as f57003b (1 ahead of the private origin). `roles check`: 10 instances, 0 need attention.
- state delta: none.
- evidence: the commits above; `git worktree list` of wip-rmxos after the rename; `git status -sb` of the alpha2 worktree.
- next: The Coordinator relays the Implementer NOTICE. The PID-1 launchd critical path (Coordinator choice) comes next: re-base op-322 onto alpha2, then its XL gates.

### j-20260928-026 — new milestone: PID-1 launchd; op-377 drafted to re-base the contract onto alpha2

- time / kind: 2026-09-28T05:16:06Z / DECISION
- outcome: Coordinator choice: the next critical path is PID-1 launchd (id-016, id-042). now.md was rewritten with six steps: re-base, two-Validator review, the Coordinator's service-plane bar, the Implementer's helper and disposable stage, the Gatekeeper's containment and corrected reaper premise, then op-280/op-202/op-203. The contract to validate is op-318 as corrected by op-322 (explorer1's notes; CORRECTED-CONTRACT-READY-FOR-VALIDATION, confidence 9), written at alpha@26655e67. Arranger checks: alpha is wholly contained in alpha2 (merge-base 26655e67; 0 alpha-only commits; 1,930 alpha2-only); op-322's pinned launchd sources (runtime.c, core.c, launchd.c) are byte-identical at 2884304b; its three pinned staging scripts are unchanged in rmx-implementer/scripts/bhyve; in the contract's areas only sys/kern/kern_exit.c (stable/15, including 9d6498310f5c "processes: add zombie references, each of them prevents reap", ecdc9cfea64c pdwait, 83fa3c3ad844) and 26 libexec/rc files changed; the alpha2 dtrace Makefile change only filters dtnfscl. Drafted op-377 (explorer1, read-only apart from one addendum note): decide HOLDS-ON-ALPHA2 or NEEDS-AMENDMENT for exactly those deltas.
- state delta: op-377 created as draft.
- evidence: `git merge-base`, `git rev-list --count`, `git show <commit>:<path> | sha256`, `git diff --stat` in wip-rmxos; sha256 of the staging scripts.
- next: Present op-377 (ready; nothing in flight). The Coordinator relays the Implementer NOTICE (j-20260928-025) and decides the service-plane bar before any soak.

### j-20260928-027 — op-377 sent; Implementer NOTICE relayed

- time / kind: 2026-09-28T05:19:35Z / ISSUE
- outcome: The Coordinator relayed op-377 (explorer1: re-base the PID-1 contract onto alpha2) and the Implementer NOTICE (j-20260928-025). The Coordinator asked the Arranger to check with a web search, not an agent, whether xpc_domain still matters on current macOS: if so, it is worth doing but may be deferred.
- state delta: op-377 draft → issued.
- evidence: Coordinator message in chat.
- next: Web research on launchd/XPC domains on current macOS; record the answer against id-042's service-plane box.

### j-20260928-028 — service-plane bar decided: MachServices+nvlist for the preview; xpc_domain deferred

- time / kind: 2026-09-28T05:21:16Z / DECISION
- outcome: The Coordinator asked whether xpc_domain still matters on the latest macOS: if it does, it is worth doing but may be deferred. Web search (no agent): since OS X 10.10, launchd is organized around domains (system, user/<uid>, gui/<uid>, and a per-process pid/<pid> domain holding the XPC services that process can reach), and 2025–26 reports show the domain model in daily use on macOS 26. The last open-source launchd is 842.92.1 (OS X 10.9.5), the base rmxOS descends from. First-hand on mm4, macOS 27.0 (26A428): launchctl's domain subcommands (bootstrap, bootout, print, enable, disable, kickstart, blame); the system domain holds 431 services (228 active); a pid domain exists on demand for an ssh shell (pid/40403); 121 .xpc service bundles in /System/Library frameworks and private frameworks; 8 apps with XPCServices; 324 of 425 system LaunchDaemons publish MachServices. Result: xpc_domain still matters on macOS 27, so per the Coordinator it is worth doing and deferred. The preview bar is MachServices+nvlist, which carries system daemons (the preview's services) and is what rmxOS hosts today. Recorded in id-042 (box checked as a Coordinator disposition), li-008, id-021, and now.md step 3.
- state delta: none.
- evidence: web sources (ss64.com launchctl; thrysoee.dk launchctl; Tencent Xuanwu Lab on XPC service domains; Wikipedia launchd; GitHub issues on macOS 26 launchctl bootstrap); mm4 commands `launchctl help`, `launchctl print system`, `launchctl print pid/$$`, and counts of .xpc bundles and MachServices plists.
- next: Wait for op-377 (explorer1).

### j-20260928-029 — op-377 returned: NEEDS-AMENDMENT on alpha2; contract reviews drafted

- time / kind: 2026-09-28T05:25:16Z / RETURN
- outcome: explorer1's addendum (rmx-explorer1 5c51fc0, findings/nx-r64z/20260928-op377-alpha2-rebase.md, sha256 39a4d301…, 52 lines) re-confirms every unchanged pin and finds two material alpha2 deltas. (1) kern_exit.c zombie references: a consuming parent wait clears PZOMBIEREF_PARENT but other references can keep the zombie; proc_to_reap skips children without that bit; reparenting to the reaper re-enables it. So a surviving Z or an ECHILD is diagnostic, not proof of hazard (b), unless correlated by pid. (2) /etc/rc now exits 1 with "/dev is not populated" unless /dev/null is a character device (rc:49-52), before either rcorder pass. Three amendments: prove the /dev/null gate and capture the rc chain's raw exit status; correlate ECHILD and zombies by pid, else INCONCLUSIVE; pin fresh alpha2 build inputs and measure host-built = BOM = in-image. Arranger spot checks hold: rc:45-53; kern_exit.c 1013-1021, 1257-1264, 1681-1691; file hashes e20a0255… and bc2f5382…; rc.conf:115. One minor citation slip: svcj_all_enable="NO" is at rc.conf:764, not 762-763. Confidence 9; the gate is self. op-377 closes once 5c51fc0 is on origin (rmx-explorer1 is 3 ahead). Drafted op-378 (validator1) and op-379 (validator2), identical reviews of the layered contract (op-318 180361ec… as corrected by op-322 b6a08dc3… and amended by op-377 39a4d301…) with four claims: staging and containment, reaper observation, consistency, sufficiency. The briefs carry op-321's gist so the Validators need not read this repo.
- state delta: op-377 issued → returned; op-378 and op-379 created as draft.
- evidence: `git show 2884304b:<path>` line reads and sha256; rmx-explorer1 `git log`/`show --stat` 5c51fc0; sha256 of the three notes and wait.h.
- next: Present op-378 and op-379. Ask the Coordinator for push permission for rmx-explorer1 so op-377 can close; a standing permission for private role repos would remove this round trip.

### j-20260928-030 — op-378 and op-379 sent: both Validators review the PID-1 contract

- time / kind: 2026-09-28T05:28:04Z / ISSUE
- outcome: The Coordinator relayed op-378 (validator1) and op-379 (validator2), identical reviews of the layered PID-1 contract on alpha2. The push permission for rmx-explorer1, needed to close op-377, is still open.
- state delta: op-378 and op-379 draft → issued.
- evidence: Coordinator message in chat.
- next: Wait for both REPORTs; op-377 closes when 5c51fc0 is on origin.

### j-20260928-031 — op-379 consumed: validator2 REMEDIATE 9 on the PID-1 contract BOM; shorter brief ending

- time / kind: 2026-09-28T05:36:42Z / RETURN
- outcome: validator2 (rmx-validator2 4e1ecc4, 189-line review) found claims 1 and 2 hold. C1 is host-safe and the replaced defect is real at stage-guest.sh:253-277 and run-guest.sh:75-87; C3's commands exist on FreeBSD 15; the tiers are realizable on the real alpha2 image (KDTRACE_HOOKS, and the dtrace, fasttrap, fbt, and systrace modules present, launchd unstripped); the wait-status table is exact. Claims 3 and 4 fail on op-318's Q2 BOM: the launchctl row says source sbin/launchctl, destination /sbin/launchctl, but the source is bin/launchctl/ and launchd hard-codes /bin/launchctl for session bootstrap (core.c:7145). C2's triple equality would still pass, because it checks the destination it is handed, so an image built to the BOM would silently lose its bootstrap jobs, including the rc-chain job. The same class applies to lib/libBlocksRuntime (really lib/libblocksruntime) and the kernel destinations (pre-alpha2 convention against /boot/RMXOS-RELEASE/{kernel,mach.ko}). Fix: correct those rows and add a rule that every BOM destination is checked against its consumer. Arranger first-hand: core.c:7143-7147 shows the /bin/launchctl literal; at 2884304b bin/launchctl and lib/libblocksruntime exist while sbin/launchctl and lib/libBlocksRuntime do not; op-318 lines 127 and 130 carry the wrong rows; the op-364 image ships /bin/launchctl (b622a5b9…) and no /sbin/launchctl. Consumed at confidence 9. The remediation goes to explorer1 as one op once op-378 returns, so both reviewers' fixes land together. Separately, per the Coordinator, briefs now end "Re-read OPS.md first: defaults and the REPORT block." (tools/rob; test updated; 15 pass).
- state delta: op-379 issued → returned → closed.
- evidence: rmx-validator2 4e1ecc4; `git show 2884304b:sbin/launchd/core.c` lines 7143-7147; `git ls-tree` for the four directories; the op-318 note lines 127 and 130; the op-364 staging tree listing and sha256.
- next: Wait for op-378, then a single explorer1 remediation op amending the BOM and C2. The push permission for rmx-explorer1 is still open.

### j-20260928-032 — Arbiter: REMEDIATE the PID-1 contract BOM; private role repos pushed; op-377 closed

- time / kind: 2026-09-28T05:40:09Z / DECISION
- outcome: The Coordinator granted push permission, recorded as standing for private role repos only; public repos still need a yes each time. Pushed and verified on GitHub: rmx-explorer1 5c51fc0 (op-377 plus README and OPS.md commits), rmx-gatekeeper1 c17f2bd, rmx-implementer f57003b (project-rmx), and, through bare clones from mm4, rmx-explorer2 241284e and rmx-gatekeeper2 0cb46e6 (mm4 origin/main refs updated). No blob over 50 MB. op-377 closed (its commit is on origin). validator1's op-378 (rmx-validator1 7629105, CLOSE 9.5; 30+ citations verified, but sufficiency judged on the documents alone) was consumed. The reviewers split, and as Arbiter the Arranger rules REMEDIATE: validator2's BOM defect is verified first-hand and decisive (op-318 lines 123 and 126 give sbin/launchctl → /sbin/launchctl and lib/libBlocksRuntime; alpha2 has bin/launchctl and lib/libblocksruntime; launchd hard-codes /bin/launchctl at core.c:7145; line 131 uses pre-alpha2 kernel paths where alpha2 boots /boot/RMXOS-RELEASE/{kernel,mach.ko} with kernel="RMXOS-RELEASE/kernel"). No third opinion is needed for an objective path fact. Drafted op-380 (explorer1): a new amendment note correcting those rows, adding the consumer-path rule to C2, and applying it to every BOM row. On return, the Arranger verifies the fix against source and the alpha2 layout and closes the contract review, since each correction is an objective path check.
- state delta: op-377 returned → closed; op-378 issued → returned → closed; op-380 created as draft.
- evidence: `git ls-remote` for all five repos; rmx-validator1 7629105; the op-318 note lines 119–133; the op-364 staging loader.conf and boot/RMXOS-RELEASE listing.
- next: Present op-380. After it returns and is verified, step 4 (the Implementer's helper and disposable alpha2 image) becomes ready.

### j-20260928-033 — op-380 verified: the PID-1 contract is accepted on alpha2; op-381 drafted for the Implementer

- time / kind: 2026-09-28T05:54:08Z / RETURN
- outcome: explorer1's op-380 note (rmx-explorer1 be1a3fb, pushed; 46 lines) is BOM-CORRECTED. It fixes launchctl (bin/launchctl → /bin/launchctl), BlocksRuntime (lib/libblocksruntime), kernel and module (/boot/RMXOS-RELEASE/{kernel,mach.ko}), and loader.conf (kernel="RMXOS-RELEASE/kernel", mach_load, mach_name, plus init_path planned). It also found launch.h at /usr/include/launch.h, not /usr/local/include. It adds the consumer-check rule to C2 and lists every BOM row with its consumer. Arranger first-hand: launchctl.c:106-109 bootstrap_paths = {/etc/launchd.d, /usr/local/etc/launchd.d}, loaded by the bootstrap loop at 899-925, so the load chain is launchd → /bin/launchctl bootstrap → /etc/launchd.d; the notifyd plist runs /usr/sbin/notifyd; liblaunch INCS installs launch.h to /usr/include; the witness loader.conf mach_name and the library symlinks match. Confidence 9. op-380 closed. As Arbiter, the contract review is satisfied: the accepted contract is op-318 as corrected by op-322 and amended by op-377 and op-380. Drafted op-381 (Implementer, chain step 1): the rmx-stage-image helper with op-322 C1's self-test tiers, and a disposable PID-1 premise image staged onto a copy of the op-364 image (init_path, the four /etc/launchd.d plists including a new rc-chainload running /bin/sh /etc/rc). Under C2 rule 5 the Arranger accepts, in the brief, the alpha2 /sbin/launchd 3ac3d0ec… already in that image: built in op-343's release-profile buildworld from sources byte-identical at 2884304b, verified by op-368 and op-369, booted in op-372. That avoids a mid-op stop. Its gate is one Validator (op-318 chain step 2); authority is doas for image operations inside the workspace only, no guest runs, and a push of rmx-implementer.
- state delta: op-380 draft → issued → returned → closed; op-381 created as draft.
- evidence: `git show 2884304b:bin/launchctl/launchctl.c` lines 104-110 and 899-925; the notifyd plist lines 17-22; lib/liblaunch/Makefile; the op-364 staging loader.conf and the sha256 of /sbin/launchd and /bin/launchctl; alpha2-build-chain.md rows for op-343, op-344, op-358, op-364.
- next: Present op-381 (ready; nothing in flight).

### j-20260928-034 — op-381 BLOCKED: no staging filesystem distinct from /

- time / kind: 2026-09-28T05:59:55Z / RETURN
- outcome: The Coordinator relayed op-381; the Implementer returned BLOCKED before staging. op-318 Q4's pre-privilege check 5 (kept by op-322) requires `df "$workspace"` and `df /` to resolve to distinct devices, and both are zroot/ROOT/default. The op-364 base image hash matched; no image change, commit, or push. Verified first-hand: both evidence files (workspace-root-df.txt 826fcbc2…, host-mounts.txt a887d16a…) match; stat shows the same device id (5882038518042460496) for /Users/me/wip-mach/rmx-implementer and /, while /tmp is zroot/tmp; rmx-implementer is clean at f57003b. This is the contract's fail-closed containment working as reviewed, so the fix is a place to stage, not a weaker rule. `zfs list` shows the Coordinator already separates projects by dataset (zroot/RNX, zroot/wip-rnx-normd). Proposal: a dedicated dataset for rmxOS image staging with a quota, then re-issue op-381 as a new op with that workspace.
- state delta: op-381 draft → issued → returned (BLOCKED).
- evidence: sha256 of the two blocker files; `df` and `stat -f %d` for the workspace, /, and /tmp; `zfs list`.
- next: The Coordinator decides the staging dataset (host change, needs root).

### j-20260928-035 — staging dataset created; op-381 re-issued as op-382

- time / kind: 2026-09-28T06:02:13Z / ACTION
- outcome: The Coordinator chose to have the Arranger create the staging dataset. Created with `doas -n zfs create -o mountpoint=/Users/me/wip-mach/stage -o quota=64G zroot/wip-mach-stage` and `doas -n chown me:staff`, after checking that neither the path nor the dataset existed. It is a distinct device from / (dev 14112530667120819705 vs 5882038518042460496), 64 GB quota, writable by me, and persistent through the ZFS mountpoint property. op-381 was dropped as superseded, and op-382 drafted: the same brief with the workspace /Users/me/wip-mach/stage and privilege confined to image files there. Its gate is still one Validator.
- state delta: op-381 returned → dropped; op-382 created as draft.
- evidence: `zfs list zroot/wip-mach-stage`; `df` and `stat -f %d` of the dataset and /; a write test.
- next: Present op-382 (ready; nothing in flight).

### j-20260928-036 — op-382 sent; Advisor review round drafted (op-383 to op-386)

- time / kind: 2026-09-28T06:08:32Z / ISSUE
- outcome: The Coordinator relayed op-382 and proposed a new rmxOS review round on the core components (Mach IPC, libxpc, libdispatch, launchd, libnotify), using it to onboard and exercise the Advisors. Design: one consult per seat; each seat gets a component it did not write the July checklist for (advisor2 wrote the July foundation, libxpc, launchd, and ASL checklists; advisor3 wrote op-319, foundation round 2). All four ask the same question: do July's items hold at alpha2 2884304b, which moved with the stable/15 merge, what are the ranked preview risks, and what are the proposals tied to IDQ entries? Architecture and risk only. Each brief opens with the framing line and a one-line onboarding, and carries the problem-entry facts itself, since Advisors never read this repo. op-383 advisor1: Mach IPC and libdispatch, baseline July foundation checklist cbbcdd28… and op-319 0f2ed556…. op-384 advisor2: libnotify and notifyd, baseline op-262 1aefd784… and op-270 7b4c6c6d…. op-385 advisor3: launchd, liblaunch, and launchctl hosting (the PID-1 contract out of scope), baseline July launchd checklist 94a34e9c…. op-386 advisor4 on mm4: libxpc against the macOS 27 SDK headers, with id-021's acceptance box spelled out, baseline July libxpc checklist f25d9d6c…. For advisor4, a read-only pinned copy of the relevant source at 2884304b (225 files, 3.1 MB, git archive) and the checklist were placed on mm4 under /Users/linz/Local/wip-mach/rmx-reference/. All four are read-only and safe alongside op-382 (no shared writes; lock-free reads).
- state delta: op-382 draft → issued (recorded earlier); op-383 to op-386 created as draft.
- evidence: sha256 of the four baseline consults; the mm4 copy count (225, matching `git ls-tree`) and the checklist hash.
- next: Present op-383 to op-386.

### j-20260928-037 — Advisor round: one seat in sequence

- time / kind: 2026-09-28T06:14:21Z / DECISION
- outcome: Coordinator: Advisors are expensive, so no fan-out; advisor4 is fine for the macOS-only task. advisor2 (ChatGPT astra max) runs op-383, op-384, and op-385 in three sequential batches; op-383 and op-385 were reassigned to advisor2, op-384 and op-385 are held with needs, and op-386 (advisor4) stays a draft. roles.md § Choosing an Advisor records the no-fan-out rule and advisor2's model.
- state delta: op-383 reassigned (draft); op-384 draft → hold (needs op-383); op-385 reassigned, draft → hold (needs op-384).
- evidence: Coordinator message.
- next: Present op-383 and op-386.

### j-20260928-038 — op-383 narrowed to the Mach kernel; libdispatch split out as op-387

- time / kind: 2026-09-28T06:18:20Z / DECISION
- outcome: Coordinator: narrow op-383 to the Mach kernel side (Mach IPC and every FreeBSD integration point), with libdispatch next. op-383 was rewritten to name the integration surface (syscalls.master and the generated sysent/syscalls/systrace files, kern_event.c EVFILT_MACHPORT and knote_enqueue, sys/event.h, sys/file.h, sys/sys/mach headers and MIG defs, sys/modules/mach, and the module's own hooks), found with git grep at 2884304b. Created op-387 (advisor2, libdispatch and kern_thrworkq.c). Sequence: op-383 → op-387 → op-384 → op-385.
- state delta: op-383 rewritten (draft); op-387 created, hold (needs op-383); op-384 needs op-387.
- evidence: `git grep` of the integration files.
- next: op-383 is ready to send.

### j-20260928-039 — op-382 BLOCKED on a false host delta; op-388 drafted

- time / kind: 2026-09-28T06:46:09Z / RETURN
- outcome: op-383 was relayed. op-382 (Implementer) returned BLOCKED at the host-inventory hard stop. Evidence hashes match; the two inventories agree on rc.conf, rc.local, and loader.conf and differ only in the mtree digests for /etc/rc.d and /boot/modules. Arranger first-hand: rmx-stage-image.exs:123 hashes the whole `mtree -c` output, including its # header (user, machine, tree, date), which differs on every run; back-to-back runs differ while content-only lines are stable; no protected file changed in the last 12 hours. So the host was unchanged and the stop was a harness defect, handled correctly (stop, not repair). The self-test lacked a no-change stability control. op-382 dropped as superseded; op-388 drafted: fix the inventory to hash content lines only, add the stability check, then stage a fresh copy (the op-382 image bdce6128… is not accepted).
- state delta: op-383 draft → issued; op-382 issued → returned → dropped; op-388 created as draft.
- evidence: sha256 of host-before.json and host-after.json; the diff; back-to-back `mtree -c` on this host; `find -newermt`.
- next: Present op-388.

### j-20260928-040 — op-388 sent; op-383 consumed (Mach kernel consult); op-387 released

- time / kind: 2026-09-28T07:07:37Z / RETURN
- outcome: op-388 relayed. advisor2 returned op-383: an 821-line consult (rmx-advisor2 433838e) with July checklist dispositions, integration traces from both sides, seven ranked risks, and six proposals. Arranger checks: its cited hashes for mach_module.c and kern_event.c at 2884304b match; syscalls.master shows native pdopenpid at 603, below Mach's 610 block (R5); mach_module.c:266-273 returns EINVAL after syscall registration with no unwind (R7). The findings bind to existing entries, so no new ones are needed: P1 (option B, a narrow kernel activation interface) to id-045; P3 (bootstrap lineage) to id-016; P2, P4, P5, and P6 (Mach replay, integration manifest, usable-Mach ledger, init and failure ownership) to id-042. Closed (gate self; local repo, no origin). Released op-387 (libdispatch) as advisor2's next batch.
- state delta: op-388 draft → issued; op-383 issued → returned → closed; op-387 hold → draft.
- evidence: rmx-advisor2 433838e; `git show 2884304b` of syscalls.master and mach_module.c; sha256 of the two cited files.
- next: Present op-387.

### j-20260928-041 — Mach deep dive (op-389) ahead of libdispatch

- time / kind: 2026-09-28T07:21:07Z / DECISION
- outcome: The Coordinator questioned op-383's value and wants to go deep on the Mach kernel integration: XNU Mach ported by NextBSD onto FreeBSD 12.0, revived on stable/15. The Arranger's assessment of op-383: a few concrete verified finds (syscall-number headroom, the load-failure unwind, overstated public calls, the lifetime risk surface, a reusable replay list), with much of the rest restatement and process; the audit-shaped brief invited that. For the deep dive: the pristine NextBSD 12.0 tree is at /Users/me/wip-mach/nx/NextBSD-NextBSD-CURRENT; releng/12.0 is in wip-rmxos; the rmxOS import snapshot is 8c6a1c15 (Upstream-Base e4f02a72); fetched a public shallow XNU xnu-12377.121.6 (ac9718f, read-only, 24 MB) to /Users/me/wip-mach/reference/. Drafted op-389 (advisor2): findings only, ranked, each with the assumption, rmxOS and NextBSD lines, the stable/15 or XNU truth, the failure, confidence, and the smallest confirming check; under about 300 lines. op-387 now needs op-389.
- state delta: op-389 created as draft; op-387 needs op-389.
- evidence: `git log` of sys/compat/mach; the NextBSD newvers REVISION 12.0; the xnu clone.
- next: Present op-389.

### j-20260928-042 — op-388 returned DONE; one-Validator review op-390 drafted

- time / kind: 2026-09-28T07:26:16Z / RETURN
- outcome: The Implementer fixed the inventory (mtree content only), added the no-change stability test (fixture_no_change_stable), and staged a fresh copy: /Users/me/wip-mach/stage/images/op388-alpha2-pid1-premise.raw 031885…, 28 BOM rows, host inventories equal (9bb2e817…), rmx-implementer dd78a31 on origin. Arranger first-hand: all seven evidence files and the image hash match; the BOM has /sbin/launchd 3ac3d0ec, /bin/launchctl b622a5b9, the four /etc/launchd.d plists, and loader.conf; the commit is an ancestor of origin main. Per op-318 chain step 2, drafted op-390: validator2 as the sole L reviewer of the helper, BOM, and image.
- state delta: op-388 issued → returned; op-390 created as draft.
- evidence: sha256 of the seven artifacts and the image; `git merge-base --is-ancestor`; the BOM rows.
- next: Present op-390; op-388 closes on its review.

### j-20260928-043 — op-390 CLOSE 9/10; op-388 and op-390 closed; reaper cell op-391 drafted

- time / kind: 2026-09-28T07:54:00Z / RETURN
- outcome: validator2 returned op-390: all four op-388 claims hold, CLOSE at 9/10. It re-derived the 28 BOM rows, the plist pins, the loader.conf delta, launchd's NEEDED entries and the kernel ident, and reproduced the host inventory live with the helper's method. Arranger first-hand: rmx-validator2 3a5df4c exists; every cited artifact hash and the image hash `031885…` match on disk; rmx-implementer dd78a31 is on origin/main. Two small notes, neither blocking. consumer-checks.json was written five minutes after the run and no script produces it; validator2 re-derived its content. validator2 cited rmx-explorer1 5c51fc0 for the op-380 note, but that note landed in be1a3fb. Closed op-388 and op-390 (gate validator; rmx-validator2 has no origin by decision). For the next step, the Arranger checked the image: launchd is unstripped (jobmgr_reap_pid, job_reap and waitpid_loop are present), and dtrace with dtraceall, fasttrap and systrace are staged, so the Tier U and Tier K probes are possible. The premise image carries no workload, and a guest has no network or shares, so the W1–W5 workload has to be staged. rmx-stage-image already accepts any base whose hash matches the BOM and requires the 28 premise rows. Drafted op-391 (gatekeeper1, gate both): harness and Tier-2 classifier controls, then a workload overlay on a copy of the premise image, then one cell. op-279 dropped, as op-318 recommended (mis-scoped method; superseded by op-391). op-280 now needs op-391.
- state delta: op-390 issued → returned → closed; op-388 returned → closed; op-279 hold → dropped; op-280 needs op-391; op-391 created as draft.
- evidence: sha256 of the op-388 artifacts and image; `git branch -r --contains dd78a31`; `nm` and `file` of the op-364 staged launchd; the /boot/RMXOS-RELEASE module listing; `git ls-tree be1a3fb`.
- next: Present op-391 with its authority for the Coordinator's decision.

### j-20260928-044 — op-391 sent; op-389 consumed (Mach deep dive): id-046; op-387 rewritten and released

- time / kind: 2026-09-28T08:20:00Z / RETURN
- outcome: op-391 relayed. advisor2 returned op-389: 14 confirmed Mach defects and 1 suspect, 294 lines, rmx-advisor2 2f6c337, nearly all inherited from NextBSD. The Arranger traced 3, 2, 4, 5, 9, 12 and 13 at 2884304b; each holds as stated. Finding 3 is a user-triggerable panic: `mach_fileops` has no fo_poll or fo_ioctl, and poll(2) calls through NULL. Answering advisor2's "next": the op-364 mach.ko is a standalone module build with an empty opt_global.h (build-mach-module.log) and carries no assertion strings, while the kernel does. So finding 1 and the assertion in 11 are latent in the shipped build, and the module does not share the kernel's options. No HZ override exists, so a bhyve guest runs hz=100 (finding 10). Recorded as id-046, with a proposed fix batch that can run alongside op-391. Closed op-389 (gate self; local repo). Much more useful than op-383: every finding is a concrete failure with a check. Fetched Apple libdispatch-442.1.4 read-only to /Users/me/wip-mach/reference/ (the rmxOS tree is 442.1.4 plus three FreeBSD shim files). Rewrote op-387 in op-389's findings-only form and moved it from hold to draft.
- state delta: op-391 draft → issued; op-389 issued → returned → closed; op-387 hold → draft (rewritten); id-046 created.
- evidence: `git show 2884304b` of ipc_entry.c, sys_generic.c, file.h, mach_msg.c, ipc_tt.c, ipc_pset.c, mach_thread.c and the conf files; `strings` of the op-364 kernel and mach.ko; logs/build-mach-module.log; `git ls-remote` of the libdispatch tag.
- next: Present op-387; the Coordinator decides the id-046 fix batch and its preview gating.

### j-20260928-045 — op-387 and op-391 paused (shared token account)

- time / kind: 2026-09-28T08:45:00Z / STATUS
- outcome: gatekeeper1 and advisor2 share one token account, and both paused mid-op. The Arranger checked the host: no bhyve process, nothing mounted from the stage dataset, no overlay image, and no new rmx-gatekeeper1 commits. op-391 had consumed no attempt, and the op-388 image is untouched. Both ops stay issued; re-relaying op-391 is safe if its session restarts. The Coordinator declined the id-046 fix batch for now. Also recorded: the IDQ index gained a priority column (6de3008).
- state delta: none.
- evidence: `pgrep bhyve`; `mount`; the stage images listing; `git log` of rmx-gatekeeper1.
- next: Wait for op-387 and op-391 to resume.

### j-20260928-046 — workflow review: Coordinator positions; sanitizers and fuzzers raised (id-047, id-048)

- time / kind: 2026-09-28T09:30:00Z / DECISION
- outcome: The Arranger reviewed the workflow's fit for kernel and OS work. The principles fit: independent verification, pinned evidence, containment, fail-closed gates, and single ownership. The observed costs are heavy mechanics, paper contracts where a boot would answer, no rmxOS in-tree tests for Mach or its userland, and no automated bug-finding. The Coordinator's positions:
  - The hand relay and the Coordinator bottleneck are intentional. Understanding intent matters more than speed, and slow or no feature progress is fine.
  - The multi-agent efficiency plan comes later, not for this project.
  - Architecture correctness is the goal of the Advisor review round.
  - Sanitizers and fuzzers go into the IDQ at priority medium.
  - The macOS side was designed in from the start and needs polish.
  Raised id-047 (sanitizer builds: KASAN, KMSAN and KCSAN kernels, ASan, UBSan and TSan userland; starts with `mach.ko` built under its kernel's options) and id-048 (fuzzing: syzkaller with kcov on Mach traps, libFuzzer on userland decoders). id-048 needs id-047 and a containment decision, because syzkaller needs host-guest networking and current containment allows none. Recorded the positions in LOCAL.md. now.md states the round's architecture goal. id-046 part 2 now starts with an Advisor architecture proposal before code.
- state delta: id-047 and id-048 created (medium).
- evidence: `git show 2884304b:sys/conf/options` (KASAN, KMSAN, KCSAN, KCOV); the sys/amd64/conf listing; std.debug; the rmxOS tree listing (no Mach or userland tests); rmx-gatekeeper1's per-op build directories.
- next: When writing op-384 and op-385, lead with the architecture question.

### j-20260928-047 — IDQ: id-049 (nx-v64z names) and id-050 (mm4 mDNS) raised at low; id-033 low

- time / kind: 2026-09-28T09:45:00Z / DECISION
- outcome: The Coordinator added two macOS-side polish items to the IDQ at priority low. id-049: the `nx-v64z` → `nx-r64z` name migration that terminology.md calls pending never happened. The old names remain in rmx-explorer1, rmx-gatekeeper1 (`findings/nx-v64z/`, `macos-validation/findings/nx-v64z/`, the archived plan) and the old mach-oracle clones, with about 119 mentions in each role repo. The Arranger proposes freezing the existing paths as history, because migrating moves cited evidence paths. id-050: `mm4.local` does not resolve here, since nsswitch has no mDNS source. The ssh config pins 192.168.4.47. mDNSResponder is installed and mdnsd runs from a manual start, not at boot. The fix is to enable mdnsd, install `mDNSResponder_nss`, and add `mdns` to the hosts line; no avahi. id-033 stays low (already set). Not added, per the Coordinator: the macOS results living in rmx-gatekeeper1, and the unexercised mm4 seats.
- state delta: id-049 and id-050 created (low).
- evidence: `find`/`grep` for nx-v64z across the workspace; `pkg info` and `pkg search` for mDNSResponder; /etc/nsswitch.conf; `getent hosts mm4.local`; `pgrep mdnsd`.
- next: none today.

### j-20260928-048 — op-392 drafted: advisor1 repeats the Mach deep dive independently

- time / kind: 2026-09-28T09:55:00Z / DECISION
- outcome: The Coordinator gives advisor1 (the Arranger's model at max effort) the same Mach kernel work as advisor2's op-389, while the other agents are at their limits. op-392 reuses op-389's brief with three changes. It is independent: advisor1 may not read other Advisors' repos, and the two results will be compared. It asks for design-level causes where a class of failures shares one. It asks advisor1 to read the build rather than the config name. No op-383 or op-389 results are given. Comparing overlap and differences with id-046 will show how complete a single review is.
- state delta: op-392 created as draft.
- evidence: none (drafting).
- next: Present op-392.

### j-20260928-049 — op-392 consumed: advisor1's independent Mach review adds F1 (caller identity) and more

- time / kind: 2026-09-28T10:40:00Z / RETURN
- outcome: op-392 was relayed. advisor1's session was interrupted by a safety flag after its document was committed (rmx-advisor1 d320d93, 289 lines, complete). It reports 8 confirmed defects, 6 suspected, and 5 design classes. Arranger first-hand at 2884304b:
  - F1: the audit token is set only at fork (task.c:211), copied into every trailer (ipc_kmsg.c:850-851), and trusted by launchd (runtime.c:1089-1094).
  - F5: NextBSD's compiled-out `assert(found)` is a `panic` in rmxOS (thread_pool.c:92-93).
  - F6: `thread_unlock` after `mi_switch`, which on stable/15 already releases the lock (kern_synch.c:462-468). NextBSD's FreeBSD 12 `mi_switch(SW_VOL, NULL)` returned holding it.
  - The truncated REPORT hashes are paste truncation; the recomputed full hashes match their prefixes.
  Overlap with op-389 covers about five items (F2, F3, F4, S2, the rfork item, and the build fact). Each review found roughly half the union. Recorded in id-046 with the design classes; F1 is also noted in id-016 as a PID-1 trust dependency. Closed op-392 (gate self; local repo). Not reached: clock, semaphores, kobject/MIG dispatch, ipc_space, ipc_notify, and the trap argument path.
- state delta: op-392 draft → issued → returned → closed.
- evidence: `git show 2884304b` of proc_info.c, task grep, ipc_kmsg.c, runtime.c, mach_traps.c, kern_synch.c and thread_pool.c; the NextBSD thread_pool.c and mach_traps.c; sha256 of four cited files.
- next: The Coordinator decides id-046 scope; a possible advisor1 follow-up covers the unreached areas.

### j-20260928-050 — Kernel review plan recorded: kernel-reviews.md and id-051 (medium)

- time / kind: 2026-09-28T10:55:00Z / DECISION
- outcome: The Coordinator decided that the Mach integration gets a second review round after the fixes, shaped as follows. Decide design classes A and B first, then fix; Validators review each fix; then a blind round with two reviewers on different models covering the new design and the areas neither review reached, each returning a checked-and-cleared list. Stop when overlap is high, then hand over to sanitizers and fuzzing. Round 1 (op-389, op-392) is recorded with its overlap (about 6 of 23), the capture-recapture estimate (about 12 unfound), the scores (advisor2 8, advisor1 8.5) and the brief form that worked. Written to kernel-reviews.md, linked from now.md; id-051 raised at medium.
- state delta: id-051 created (medium).
- evidence: none new (from j-20260928-044 and -049).
- next: none.

### j-20260928-051 — op-393 drafted: advisor1 finishes the Mach review

- time / kind: 2026-09-28T11:05:00Z / DECISION
- outcome: The Coordinator wants advisor1 to finish its Mach review before any libdispatch work. op-393 covers the areas op-392 never reached: clocks and callouts, semaphores, the kernel-object and MIG dispatch, ipc_space, ipc_notify, and the trap argument path. It also firms up three shallow op-392 claims. To lower the chance of another safety interruption, the brief frames the work as a correctness and robustness review for fixing: each finding carries a regression test and a fix direction, with no exploit framing. The output is a new document of about 200 lines. advisor1 remains blind to other Advisors.
- state delta: op-393 created as draft.
- evidence: `git ls-tree 2884304b sys/compat/mach` for the listed paths.
- next: Present op-393.

### j-20260928-052 — op-393 amended: S1 log observation, best effort, LOCAL.md note

- time / kind: 2026-09-28T11:20:00Z / ACTION
- outcome: advisor1's full answer matched op-393's scope. The Arranger grepped guest serial logs for S1 (read-only). 3 of about 4,400 serial logs show a WITNESS lock-order reversal: 1st ETAP_IPC_RPC (sleep mutex), 2nd ETAP_IPC_IS (rw). That is not the pair S1 predicts. The Coordinator stopped further digging: leave it to advisor1, best effort, then move on. op-393 now asks advisor1 to explain that reversal from source, marks the op as best effort, and asks for its LOCAL.md note on the standalone module build. The background search was stopped.
- state delta: none (op-393 draft amended).
- evidence: `grep -i "lock order reversal"` over the serial-log list in the session scratchpad.
- next: Present op-393; after it returns, advisor2 continues with libdispatch (op-387).

### j-20260929-001 — op-393 consumed: advisor1 finishes the Mach review (N1–N5)

- time / kind: 2026-09-29T00:30:00Z / RETURN
- outcome: advisor1 returned op-393 (rmx-advisor1 cd7b08c, 212 lines, plus its LOCAL.md build note). It reports 5 main findings, lower items, 3 firm-ups and 1 retraction (op-392's workqueue item). Arranger first-hand at 2884304b:
  - N1: the timebase trap returns 4000000000/75189611 while libmach's `mach_absolute_time` returns CLOCK_REALTIME_FAST nanoseconds. launchd scales by the ratio before its respawn throttle, so crashing jobs respawn after about 0.19 s instead of 10 s.
  - N5: `convert_port_to_task` returns `current_task()` before its real body, so every task_* kernel call acts on the caller.
  Recorded in id-046 (with the proposal: N3, N4 and the clock_sleep divisor now; N1 with the libmach clock; N2 as design; F2 teardown before N5). N1 and N5 also noted in id-016, since both matter for PID-1 and for reading op-391. kernel-reviews.md updated. S1's open check is the file:line of the logged reversal's first lock, left open per the Coordinator. Closed op-393 (gate self; local repo).
- state delta: op-393 draft → issued → returned → closed.
- evidence: `git show 2884304b` of mach_clock.c:112-121, mach_misc.c:186-197, runtime.c:1508-1515, core.c:4474-4479 and ipc_tt.c:870-882.
- next: advisor2 resumes op-387 (libdispatch) when its account is back.

### j-20260929-002 — id-052 raised (high): the Mach review remainder

- time / kind: 2026-09-29T00:40:00Z / DECISION
- outcome: The Coordinator put what remains of the Mach review into the IDQ at priority high. id-052 covers the host_priv and mach_host routine bodies, task_info and task_threads, and the other vm_map server routines, which no review has read. It also carries S1's open check: the file:line of the first lock in the logged ETAP_IPC_RPC → ETAP_IPC_IS reversal. It is high because N5 showed that the task-level routines were never really exercised. Linked from kernel-reviews.md.
- state delta: id-052 created (high).
- evidence: none new.
- next: none.

### j-20260929-003 — id-046 findings ledger: every finding from the three reviews

- time / kind: 2026-09-29T00:50:00Z / ACTION
- outcome: The Coordinator asked whether every finding was in the IDQ. Before this, not by name: op-392's S3 (urefs in f_count; exit frees files still referenced) and its §3 low-ranked items, and op-393's N6–N10 (N9 was summarized without its number), were reachable only through the consult documents. id-046 now has a ledger of all 38 rows. Each row gives the source, the number, one line, how far it was checked (first-hand, reported, open check, or retracted), and any other entry that tracks it (id-016, id-045, id-047, id-052).
- state delta: none.
- evidence: the section headings of the three consult documents.
- next: none.

### j-20260929-004 — Coordinator: Mach foundation first; upper components wait

- time / kind: 2026-09-29T01:00:00Z / DECISION
- outcome: The Coordinator's plan: do not continue to libdispatch or other upper components. Every component depends on Mach, so the order is: fix all the reported Mach bugs (id-046), set up CI-like consistent checking on the verification side, run another Mach review round like 2026-09-28's (id-051, id-052), then move up the stack. op-387 (issued to advisor2 and paused) was dropped, because `rob` refuses issued → hold and its alpha2 pin will be stale after the fixes; it will be re-drafted against the fixed candidate. op-386 moved from draft to hold; op-384 and op-385 stay on hold. now.md gained the four-step plan. Open questions for the Coordinator: whether op-391 continues as a pre-fix baseline, and which role owns the CI.
- state delta: op-387 issued → dropped; op-386 draft → hold.
- evidence: none.
- next: Draft the first fix ops when the Coordinator answers.

### j-20260929-005 — op-391 continues as the pre-fix baseline; the Gatekeeper owns CI

- time / kind: 2026-09-29T01:05:00Z / DECISION
- outcome: The Coordinator's answers: op-391 continues as a baseline of launchd's reaper on today's alpha2, with its results read in light of N1's fast respawn. CI is built and run by the Gatekeeper and read by the Validators, keeping who runs apart from who judges. Fix ops are test-first: each starts with an in-tree regression test that fails on today's code, which also confirms the 20 reported-only findings. Batches: local fixes; lifetime fixes after the class A and B design; design fixes.
- state delta: none.
- evidence: none.
- next: Draft the first ops: the class A and B design consult (Advisor), fix batch 1 (Implementer), and the CI (Gatekeeper).

### j-20260928-051 — correction: j-20260929-001 to -005 carry wrong dates and times

- time / kind: 2026-09-28T11:33:00Z / CORRECTION
- outcome: Entries j-20260929-001 to j-20260929-005 were written on 2026-09-28 UTC (commits between 11:06Z and 11:22Z, local 2026-09-29 00:06–00:22 NZDT). The Arranger took the local date for the UTC date and estimated the times instead of reading the clock. Read them as 2026-09-28, in commit order. Their IDs stay as written (the journal is append-only), and this entry continues the true UTC sequence after j-20260928-050. The times on j-20260928-046 to -050 were also estimates; their commits are authoritative (22:11–23:27 NZDT). From now on, times come from `date -u`. Also created worklog.md: major milestones only, with local-time headers taken from commit times.
- state delta: none.
- evidence: `git log --date=format-local` for the affected commits; `date -u` → 2026-09-28 11:31 UTC.
- next: none.

### j-20260929-006 — disk cleanup: old guest images and build objects deleted

- time / kind: 2026-09-29T03:43:02Z / ACTION
- outcome: The Coordinator asked to clean up wip-mach, because the zpool was at 79% (734G allocated, 194G free), and approved deleting the candidate lists. Deleted: 271 disk images of 256 MB or more, last modified before 2026-09-14 (285G by du was in build/block-078-runtime-smoke/runs), and 62 obj directories older than 2026-09-14, all from closed ops. There were no errors and none are left. Logs, serial captures, cores and evidence files were kept; small .raw serial captures and METALOG.raw were excluded by the size filter. Kept: every image and obj directory since 2026-09-14, including the op-364 base image, the op-388 premise image (op-391 in flight), the op-372 run image, and the op343/op335 objects (op-364's toolchain). Result: 581G allocated, 347G free, 62%. The pool freed 153G, while ROOT/default's used fell from 867G to 300G: most deleted images were block clones sharing blocks (bclonesaved is now 52.2G). The recorded hashes of the deleted images can no longer be re-checked against files; the hashes remain in their records. Not touched: /tmp (57.6G, including op195-calib.img and simd7-ci-minimal*.raw), the op-382 and op-358 images, and nx/.
- state delta: none.
- evidence: the candidate lists and the (empty) delete-failed.txt in the session scratchpad; `zpool list` before and after; `zpool get bcloneused,bclonesaved`.
- next: none.

### j-20260929-007 — Mach foundation round begins: op-394 (design) and op-395 (fix batch 1) drafted

- time / kind: 2026-09-29T04:04:03Z / DECISION
- outcome: First ops of the Mach foundation round. op-394 (advisor1): a design proposal for classes A (port names as fds), B (task and thread state on reused slots), C (the receive and wakeup model) and D (self-only vs cross-task MIG). Each option comes with userland impact, lifetime and locking rules, bootable steps, and the ledger findings each step retires. advisor1 was chosen because advisor2 shares an account with gatekeeper1; the blind rule is lifted, since round 1 is over. op-395 (Implementer, gate both): 13 local fixes on a new branch mach-fixes-1 off origin/alpha2, one commit each, each with an ATF test under tests/sys/mach/ written before its fix, with expected results FAIL or PANIC on alpha2 and PASS after. The Implementer builds and stages two images from the op-364 base (base + tests; fixed + tests) and runs no guests. Test-first is proven by gatekeeper1's CI running both images; that CI op waits for op-391 and op-395's images. The module build configuration is unchanged here (id-047 comes later). No push, since rmxOS is public.
- state delta: op-394 and op-395 created as draft.
- evidence: rmx-implementer/OPS.md defaults; `git ls-tree 2884304b tests/sys` (no mach directory); wip-rmxos is clean on branch alpha.
- next: Present op-394 and op-395.

### j-20261001-001 — Testing 1.0/2.0/3.0 adopted; op-396 drafted; seqc gap confirmed first-hand

- time / kind: 2026-10-01T02:14:48Z / DECISION
- outcome: The Coordinator set a testing strategy built on what FreeBSD already ships, kept in FreeBSD's own form so stable/15 merges and upstreaming stay simple. Testing 1.0 is sanitizers and post-mortem debugging, LLDB included; 2.0 is DTrace; 3.0 is hwpmc. The plan is in testing-strategy.md. Facts at alpha2 `2884304b`: options KASAN, KMSAN, KCSAN, KUBSAN, COVERAGE and KCOV, with GENERIC-KASAN/KMSAN/KCSAN as include-plus-one-option configurations; base compiler-rt (ASan, UBSan, MSan, TSan, libFuzzer); `WITH_ASAN`/`WITH_UBSAN`; LLVM 21.1.8; base LLDB with the FreeBSD kernel-core plugin and Lua scripting. On this host, ports LLDB llvm21 has Python. GCOV does nothing under clang. bhyve guests have no PMU (vmm x86.c:484-490), so 3.0 needs bare metal. LLDB work upstream is tracked in llvm-project#180061. Also confirmed first-hand op-392 §3's "seqc compiled out of `mach.ko`": the standalone build's empty `opt_capsicum.h` drops `kern_fdfree`'s `fde_seqc` writes (ipc_entry.c:933-942), while the kernel's lockless lookups rely on them (kern_descrip.c:323-328, 3244-3268). New ledger row id-046 A1: `ipc_kmsg_alloc` zeroes messages only under INVARIANTS. op-396 (Implementer) builds `mach.ko` with its kernel, adds RMXOS-KASAN/-KMSAN/-KCSAN (and KUBSAN as a trial), and stages one image per profile from alpha2, with no guests. The kernel build needs one fix: `mach_port.c:101` includes `opt_compat_mach.h`, which no options file defines. Survey mode (report-only plus `debug.kassert.warn_only=1`) replaces id-047's precondition of fixing op-389 #1 and #11 first. The op-395 draft gained a limit: the standalone build compiles out `#ifdef CAPABILITIES` and `#ifdef INVARIANTS` code, so fix 10 must not rely on it.
- state delta: op-396 created as draft; id-047 WAITING → READY; id-053 (medium), id-054 (low) and id-055 (low) raised; id-048 amended (libFuzzer design from apple/swift-network-evolution#147; an in-guest fuzzer with no network); id-046 ledger: §3 seqc row checked first-hand, row A1 added.
- evidence: `git show 2884304b:` sys/conf/{options,kern.mk,kmod.mk,kern.pre.mk,config.mk}, sys/amd64/conf/GENERIC-K*SAN, sys/compat/mach/ipc/{ipc_entry.c,ipc_kmsg.c,mach_port.c}, sys/kern/kern_descrip.c, sys/amd64/vmm/x86.c, lib/clang/liblldb/Makefile, lib/libclang_rt/Makefile; the op-364 build log, line 14 (`touch opt_global.h`); `lldb -b -o 'script print(_VERSION)'` → Lua 5.4; `/usr/local/llvm21/bin/lldb` → Python 3.11.15.
- next: The Coordinator chooses the order of op-396 and op-395 (one Implementer).

### j-20261001-002 — op-396 sent and returned; checked first-hand; op-397 review drafted

- time / kind: 2026-10-01T07:40:36Z / ACTION
- outcome: The Coordinator sent op-396, and the Coordinator relayed its REPORT (DONE). The Implementer's record says the Coordinator authorized, during the op, adapting the dd78a31 staging helper for kernel-profile BOMs; recorded here as a Coordinator authorization. Checked first-hand:
  - `testing-1` = `42d1fdbf` + `7ccf16fa` on `2884304b`. The changes are the module list, the mach `SRCS`, the `opt_compat_mach.h` include in `mach_port.c`, and four configurations in GENERIC-KASAN form. The `7ccf16fa` subject omits KUBSAN (cosmetic).
  - Each profile's `opt_global.h` defines INVARIANTS, WITNESS, COMPAT_MACH and its sanitizer option. `-asan-use-stack-safety=0` comes from `kern.mk`'s amd64 branch.
  - Each staged `mach.ko` carries exactly its own sanitizer's runtime references: `__asan_` 14, `__msan_` 13, kcsan 29, `__ubsan_` 7, none in RELEASE.
  - All five image hashes match. The op-388 premise image still hashes `031885…`, and the op-364 image's mtime is unchanged.
  - KASAN spot check: BOM = source = in-image for the kernel, `mach.ko`, `mach.ko.debug` and launchd. `loader.conf` differs from op-364's only in `kernel=` and `mach_name=`.
  - Helper `9d718966` only adds an `rmx-stage-kernel/v1` branch; the v1 path reads the same.
  - **Correction:** the symbol evidence misreads `nm` type `i` (ifunc) as local. Only `knote_enqueue` is LOCAL in every profile; `copyin`, `copyout`, `mem*` and `sched_relinquish` are IFUNC GLOBAL (recorded in id-045).

  Two follow-ons:
  - op-391's brief runs the helper by path "at dd78a31", which now runs `9d718966`. A NOTICE to gatekeeper1 has it extract and run dd78a31 exactly.
  - op-395's draft pinned dd78a31, whose v1 schema accepts only alpha2's PID-1 premise, so its staging would have blocked as op-396's did. Its authority and staging text now let it add a test-image schema on top of `9d718966`.

  Gate: L, as briefed, so op-397 goes to validator2 (falsification).
- state delta: op-396 draft → issued → returned; op-397 created as draft; op-395 brief amended (still draft); id-047 READY → IN WORK; id-045 gained the profile check.
- evidence: `git show 42d1fdbf 7ccf16fa` in `build/op396/source`; `readelf -sW` on each profile's `kernel.full`; `nm -u` on each BOM's `mach.ko` source; `sha256` of the six images (background run); `git show 9d718966 -- scripts/bhyve/rmx-stage-image.exs`; `diff` of the two `loader.conf` files.
- next: Coordinator: send op-397, relay the gatekeeper1 NOTICE, decide on pushing `testing-1` to the public rmxOS origin (needed for closure), and send op-395 when ready.

### j-20261001-003 — op-397 sent; gatekeeper1 NOTICE relayed; testing-1 published

- time / kind: 2026-10-01T07:46:34Z / ACTION
- outcome: The Coordinator sent op-397 to validator2 and relayed the helper NOTICE to gatekeeper1 for op-391. With the Coordinator's yes, the Arranger pushed `testing-1` to the public rmxOS origin, pushing by hash so that exactly the reviewed commits were published: `refs/heads/testing-1` = `7ccf16fa` (parent `42d1fdbf`, on `2884304b`). The branch did not exist on origin before. op-396's commits on rmxOS are now on origin. `rmx-implementer@9d718966` will be pushed at closure. The Coordinator asked for op-395, so the brief is shown again; it stays draft until it is sent.
- state delta: op-397 draft → issued.
- evidence: `git ls-remote --heads origin testing-1` → 7ccf16fa410c8764c91b1cdaf3f3be683e4ad549; `git log origin/alpha2..testing-1` lists two commits.
- next: op-397's REPORT, then the closure decision on op-396. op-395 is sent when the Coordinator says so.

### j-20261001-004 — op-395 sent; op-391 BLOCKED before staging, dropped; redo op-398 drafted

- time / kind: 2026-10-01T07:53:40Z / ACTION
- outcome: The Coordinator sent op-395 to the Implementer and relayed op-391's REPORT: BLOCKED, HARNESS-NOT-ACCEPTED, axes a/b/c INCONCLUSIVE, attempt 0/1. Checked first-hand:
  - `build/op391/classify.exs` does not compile. `return_product_failure` is bound inside `if` branches (lines 66-68) and read at line 70, and the Tier-2 `results.json` stderr shows the CompileError in every case. The six "rejections" therefore prove nothing, and both required acceptances fail.
  - The classifier was edited on 2026-09-28 21:12, after its controls passed at 21:10, and never re-run.
  - Commit `5ba8835` is on origin, and the evidence hashes match. The extracted helper files are byte-identical to the dd78a31 blobs (`baaff6f5…`, `e1021f61…`) and were never executed.
  - Arranger error: the 2026-10-01 NOTICE told gatekeeper1 to copy the helper, while op-391's Inputs said "do not edit or copy it". The copy is verbatim and unused, and op-398 now names it explicitly. Lesson added to LOCAL.md.

  Size S: the BLOCKED return is verified, and no runtime evidence exists. op-391 is dropped and redone as op-398, which is op-391's brief plus:
  - the classifier repair, done inside the op;
  - the op-322 controls kept honest, each with exactly its one named difference, and W4/W5 records added to every control if the classifier needs them;
  - the cell classified with the classifier hash that passed Tier 2;
  - a 30-minute no-progress stop;
  - the verbatim helper copy named;
  - panic and backtrace quoting, so that a Mach panic (id-046) is not misread as reaper evidence. op-322 counts any panic during a wave as (a) OBSERVED.
- state delta: op-395 draft → issued; op-391 issued → returned → dropped (superseded by op-398); op-398 created as draft; id-016, id-023 and id-042 rows, now.md and testing-strategy.md point to op-398.
- evidence: `build/op391/tier2-notice-20261001/results.json` sha256:d2ec28c4…; `classify.exs` lines 55-75 and 100-135; `git show dd78a31:scripts/bhyve/rmx-stage-image{,.exs} | sha256`; `git merge-base --is-ancestor 5ba8835 origin/main` in rmx-gatekeeper1; op-322 at be1a3fb, lines 264-283 and 287.
- next: Present op-398 (gatekeeper1 is idle; nothing it touches is in use).

### j-20261001-005 — op-398 sent; op-397 CLOSE 9/10; op-396 and op-397 closed

- time / kind: 2026-10-01T07:56:13Z / ACTION
- outcome:
  - The Coordinator sent op-398 and relayed op-397: validator2 CLOSE 9/10, all six claims hold, and the `/.rmx-staged` marker is a fourth, disclosed difference that op-397's brief left out of its "only in" list.
  - Light provenance check: `d939da7` exists in rmx-validator2 (Validators have no origin). `testing-1` = `7ccf16fa` and `rmx-implementer@9d718966` are on origin; the Arranger pushed 9d718966 under standing permission.
  - One review error, overruled as Arbiter: validator2 says `copyin`/`memcpy`/… resolve only through leak-locals ("i = local"). `readelf --dyn-syms` shows them `IFUNC GLOBAL` in the kernel's `.dynsym`, and `link_elf.c:1576-1583` refuses only `STB_LOCAL` symbols without `see_local`. The only real leak-locals dependency is `knote_enqueue`. The error overstates the dependency and does not affect what was built or staged, so the close stands. A NOTICE corrects validator2's new LOCAL.md lesson.
- state delta: op-398 draft → issued; op-397 issued → returned → closed; op-396 returned → closed; id-047 → op-396 closed.
- evidence: `readelf --dyn-syms -W` on the RELEASE `kernel.full`; `link_elf.c:1570-1595` at testing-1; `git merge-base --is-ancestor 9d718966 origin/main`; `git ls-remote --heads origin testing-1`.
- next: op-395 and op-398 in flight. Once op-398 closes, draft the Gatekeeper's P0/P1 survey of the op-396 images (id-047, id-053).
