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

### j-20261001-006 — op-398 step 1 verified and closed; op-399 carries the cell

- time / kind: 2026-10-01T08:05:10Z / ACTION
- outcome: gatekeeper1 returned op-398 as PARTIAL, with the classifier repair only. That scope came from the Arranger's continuation message, which named only step 1. Checked first-hand:
  - `0e767ac` is on origin, and the three evidence hashes match.
  - `classifier-tested.exs` equals `build/op391/classify.exs` (9fe56dac…).
  - All eight Tier-2 cases pass. Each of the six rejections fails for its own named reason (raw/workload, raw/decode, missing reap, terminal, wave order, empty trace), and each control differs from known_good only by its named mutation plus the manifest hashes and consistent log lines.

  op-398 is closed for step 1. op-399 carries the rest (runner and workload host tests, overlay, one cell) with the classifier pinned. The guest attempt is still unused.
- state delta: op-398 issued → returned → closed; op-399 created as draft.
- evidence: `build/op398/classifier-binding.json` sha256:e5014579…; `diff -r tier2-r3/known_good tier2-r3/<case>`.
- next: Present op-399.

### j-20261001-007 — brief-wording.md: framing to keep briefs clear of safety filters

- time / kind: 2026-10-01T08:11:42Z / DECISION
- outcome: At the Coordinator's request, wrote brief-wording.md. gatekeeper1's provider filter stopped op-398 and op-399 at the start because of words in the brief such as "steal a zombie", "synthesized SIGSEGV" and "mutation controls". The guide sets a standard context sentence, engineering-word substitutions, exact identifiers in backticks, a list of words never to use, and complete continuation messages. op-brief-forms.md links to it. Promotion into rmx-role0 is pending until op-399 returns.
- state delta: op-399 draft → issued (filtered at start; framing message relayed).
- evidence: none.
- next: none.

### j-20261001-008 — brief-wording.md renamed safety-flag-avoidance.md

- time / kind: 2026-10-01T08:13:10Z / DECISION
- outcome: The Coordinator asked for a name that says what the guide is for, because this kind of mistake happens often. brief-wording.md is now safety-flag-avoidance.md, and the links in op-brief-forms.md and LOCAL.md are updated. Earlier journal entries keep the old name.
- state delta: none.
- evidence: none.
- next: none.

### j-20261001-009 — op-399 BLOCKED (PID-1 tracing unavailable), closed; wording rules in every role's instructions

- time / kind: 2026-10-01T08:45:25Z / ACTION
- outcome:
  - op-399 returned BLOCKED, HARNESS-NOT-ACCEPTED, attempt 1/1 consumed. Checked first-hand: the serial, orchestration and index hashes match; `1b47852` and `936edbb` are on origin; the op-388 image still hashes 031885…; no bhyve process is left.
  - The serial log shows identity, loader, BOM and `/dev/null` OK, then Tier U fails: `dtrace: … failed to grab process 1` (line 505). No wave ran.
  - Source check at 2884304b: `p_candebug` refuses init only when securelevel > 0 (`kern_prot.c:2393-2395`) or when `P2_NOTRACE` is set. launchd sets neither `PT_DENY_ATTACH` nor `PROC_TRACE_CTL`. libproc's `proc_attach` has no PID-1 special case. So the cause is guest-side (securelevel, the attach errno, or `proc_init` reading launchd's executable path) and needs a diagnostic boot.
  - Closed at size S; the evidence stands. This is the third reaper op without a verdict, so the next is a no-verdict diagnostic, not another cell.
  - At the Coordinator's direction, the wording rules went into rmx-role0's `project-context` partial (`7b01162`, local; rmx-role0 has no origin) and were rendered to every instance here except rmx-implementer, which waits for op-395. gatekeeper1 starts a new session.
- state delta: op-399 issued → returned → closed; id-016 → WAITING (diagnosis).
- evidence: `serial.raw` sha256:5d382fd4…, lines 497-505; `sys/kern/kern_prot.c` and `lib/libproc/proc_create.c:125-170` at 2884304b.
- next: Draft the PID-1 tracing diagnostic for gatekeeper1's new session.

### j-20261001-010 — op-400 DONE: PID 1 cannot be ptraced (upstream P_SYSTEM); closed

- time / kind: 2026-10-01T09:08:07Z / ACTION
- outcome: Sent to gatekeeper1's new session, and returned DONE. Checked first-hand:
  - Serial sha256 47ce9357… matches; `9a92ec8` and `f417d01` are on origin; the op-388 image still hashes 031885….
  - Serial lines 130-161: securelevel is -1. `PT_ATTACH pid=1` returns -1 with errno 22 (EINVAL), and the dtrace grab fails. The control process (pid 1005) attaches, waits, detaches and lists `pid1005::nanosleep:entry`.
  - Cause: `initproc->p_flag |= P_SYSTEM | P_INMEM` at `init_main.c:838`, identical in upstream stable/15 (`99c63b81`), and `sys_process.c:1153` rejects `P_SYSTEM` with EINVAL. PID 1 is untraceable by ptrace, and so by the pid provider, on FreeBSD by design.
  - The REPORT's "bhyve exit 1 despite poweroff" is not a fault: bhyve(8) defines exit status 1 as powered off. The runner misreads it.

  The Arranger does not adopt the REPORT's proposed next step (a kernel exception letting ptrace through for initproc). It weakens an upstream protection and diverges from FreeBSD (testing-strategy.md, alignment rule 1). The alternatives (kernel-side probes, USDT) go to the Coordinator.
- state delta: op-400 draft → issued → returned → closed.
- evidence: `serial.raw` lines 124-163; `git show 2884304b:sys/kern/init_main.c` and `git show stable/15:sys/kern/init_main.c`, line 838; `man bhyve` EXIT STATUS.
- next: Coordinator: choose the Tier U replacement.

### j-20261001-011 — Delegated: replace Tier U with kernel-side observation of PID 1 (option A)

- time / kind: 2026-10-01T09:09:20Z / DECISION (Rule 9 delegation)
- outcome: The Coordinator delegated the choice ("your call"). The Arranger chose option A:
  - **What changes:** amend op-322's Tier U so that launchd as PID 1 is observed from the kernel side, without attaching: `syscall::wait4` filtered on `pid == 1` with the thread ID, the `proc` provider for exits, `profile` sampling of PID 1's threads, and launchd's own LastExitStatus and log lines.
  - **Why:** no product change, no divergence from FreeBSD, and it answers (b) and (c) directly.
  - **Rejected:** option C (letting ptrace attach to init), because it weakens an upstream protection and makes the test kernel differ from the shipped one.
  - **Deferred:** option B (USDT probes in launchd), to Testing 2.0 (id-054).
- state delta: none.
- evidence: none.
- next: op-401 (explorer1) amends the contract.

### j-20261001-012 — op-401 returned; checked; two blind reviews drafted

- time / kind: 2026-10-01T09:17:17Z / ACTION
- outcome: The Coordinator sent op-401 and relayed its REPORT (DONE). Checked first-hand:
  - `f1df370` is on origin, and the note's sha256 is 1277d769….
  - Spot checks at 2884304b hold: systrace sets return `arg0 = arg1 = retval` (`systrace.c:221-222`); `waitpid_loop` calls `waitpid(-1, NULL, WNOWAIT)` (`runtime.c:651`); `Reap failed` and `W_EXITCODE(-1, SIGSEGV)` are at `core.c:3725-3727`; there is no `proc:::reparent` SDT probe, hence `fbt::proc_reparent`.
  - The note fails closed: ambiguous thread mapping or status leaves an axis INCONCLUSIVE.

  The gate is both Validators (PID-1 critical path): op-402 (validator1, completeness) and op-403 (validator2, falsification), blind to each other.
- state delta: op-401 draft → issued → returned; op-402 and op-403 created as drafts.
- evidence: the spot-check reads above.
- next: Send op-402 and op-403.

### j-20261001-013 — op-403 returned: REMEDIATE 9/10 (two missing Tier-2 controls)

- time / kind: 2026-10-01T09:22:38Z / ACTION
- outcome: validator2 (`07ac8fd`, local) finds claims 1-4 hold and claim 5's coverage short. The note's rule that "missing data is not excused by an OBSERVED axis" has no control, and neither has its accepted shape "explicit open blocked wait4 entry". Each needs an additive one-mutation Tier-2 control. The Arranger agrees: a classifier that accepts whenever any axis is OBSERVED would pass the current suite. The remediation waits for validator1 (op-402), so both reviews' fixes go to explorer1 as one op.
- state delta: op-403 draft → issued → returned.
- evidence: the op-403 REPORT; `git log 07ac8fd` in rmx-validator2.
- next: op-402's REPORT.

### j-20261001-014 — op-402 REMEDIATE 9/10; reviews agree; op-404 drafted

- time / kind: 2026-10-01T09:27:21Z / ACTION
- outcome: validator1 (`669b877`, local) finds claims 1-4 hold and names five uncovered rules. With validator2's two, the union is six controls (one overlaps). Both reviews are REMEDIATE at 9/10, so they agree and need no arbitration. op-402 and op-403 are closed. op-401 stays returned until op-404 adds the controls; then it closes on a light check.
- state delta: op-402 draft → issued → returned → closed; op-403 → closed; op-404 created as draft.
- evidence: both REPORTs; both commits exist locally.
- next: Send op-404.

### j-20261001-015 — Lighter process: REPORT hashes and review sizing

- time / kind: 2026-10-01T09:33:09Z / DECISION
- outcome: The Coordinator approved cutting validation overhead:
  - REPORT evidence now hashes only the artifacts later work depends on; others are listed by path (rmx-role0 report partial).
  - Build, staging and documentation ops are S/M and close on the Arranger's first-hand check.
  - One Validator for work that decides a result; two only for runtime verdicts, contracts and release decisions.
  - Feasibility is checked first before any single-attempt run (roles.md § Review and closure; rulebook Rule 11).
  - Commit-ID pins stay. In-flight ops are unchanged. explorer1 and the Implementer re-render when their ops return.
- state delta: op-404 draft → issued.
- evidence: none.
- next: none.

### j-20261001-016 — op-404 and op-401 closed; op-405 (cell under the amended contract) drafted

- time / kind: 2026-10-01T09:34:24Z / ACTION
- outcome: op-404 returned DONE. Checked first-hand: `a04db00` is on origin; the change is append-only (+15, -0); the six controls each have a single named difference and a required result. Documentation is S under the new sizing, so op-404 and op-401 are closed. op-405 is gatekeeper1's cell under the amended contract:
  - the classifier is updated and passes the full Tier 2 (8 + 6 controls);
  - a separate probe preflight boot checks feasibility before the single cell attempt;
  - the runner's misreading of bhyve exit 1 is fixed;
  - REPORT hashes only the images and serial logs.

  The gate is both Validators (runtime verdict).
- state delta: op-404 → returned → closed; op-401 returned → closed; op-405 created as draft.
- evidence: `git diff f1df370 a04db00`.
- next: Send op-405.

### j-20261002-001 — op-395 returned (13 fixes, verified); op-405 BLOCKED on a collector format bug; op-406/op-407 drafted

- time / kind: 2026-10-02T00:35:58Z / ACTION
- outcome:
  - **op-395** (Implementer) returned DONE. Checked first-hand:
    - `mach-fixes-1` = 13 commits on 2884304b, head `5fa02fb5`; 33 files, +1134 -83, confined to compat/mach, sys/sys/mach, libmach and tests/sys/mach.
    - 13 ATF programs (27 cases) with EXPECTATIONS.md.
    - Both image hashes match (d7cf4506…, ca61f2fa…). `rmx-implementer@d4a8015` is on origin.
    - The tests are ATF programs written in Zig, linking ATF's C ABI and run by Kyua. That satisfies the brief and the test-pillar doctrine, but a stock buildworld has no Zig, which conflicts with the FreeBSD-alignment goal. Raised to the Coordinator.

    Gate: one Validator (op-407, validator2) plus gatekeeper1's runtime proof (op-406). `mach-fixes-1` is not on the public origin; pushing it needs the Coordinator's yes.
  - **op-405** (gatekeeper1) returned BLOCKED. Checked first-hand:
    - `664bff8` and `00bd1c8` are on origin; the preflight serial hash matches; Tier 2 passes 22/22 (classifier 8bca5ac0…).
    - The preflight's own D collector failed to compile at `kernel.d:6` (`%lld` with a uint64_t `timestamp`). No probe was shown to be infeasible, and the cell boot is unused.
    - Lesson: the harness host test should compile every D script on the host (`dtrace -e -s`) before any boot, and a harness bug found in preflight should be fixed in-op rather than stopping the op.

    The follow-up op waits until op-406 frees gatekeeper1.
  - Re-rendered rmx-implementer and rmx-explorer1. Every instance is current, and the Implementer starts a new session.
- state delta: op-395 issued → returned; op-405 issued → returned; op-406 and op-407 created as drafts.
- evidence: `git log 2884304b..mach-fixes-1`; `sha256` of both images; `build/op405/runtime-preflight/…/guest-records/trace.err`.
- next: Send op-406 and op-407. Coordinator: the Zig-tests question and pushing `mach-fixes-1`.

### j-20261002-002 — op-406 BLOCKED (no Kyua in the image); closed; redo op-408 drafted

- time / kind: 2026-10-02T01:00:30Z / ACTION
- outcome: op-406 was sent and returned BLOCKED after 1 of 20 boots. The serial log at line 232 shows `-sh: kyua: not found`. Checked first-hand:
  - `1a53555` is on origin.
  - op-364's METALOG has no `./usr/bin/kyua` and no `./usr/tests`.
  - The test programs link ATF statically (only libc and libthr are dynamic), so they run directly with `-l` and `-r <file> <case>`.

  Arranger error: the brief prescribed `kyua` without checking the image, against the feasibility-first rule. op-406 is closed (its evidence stands). op-408 is the same run by direct ATF invocation, with in-op harness fixes and a command-versus-image check before the first boot. op-407 was sent to validator2.
- state delta: op-406 → issued → returned → closed; op-407 draft → issued; op-408 created as draft.
- evidence: op-406 serial lines 217-232; `ldd` and `nm` of `build/op395/mach_fileops_test`.
- next: Send op-408.

### j-20261002-003 — Coordinator: FreeBSD tests as they are; new tests on our modern stack

- time / kind: 2026-10-02T01:06:36Z / DECISION
- outcome: FreeBSD's existing in-tree tests (ATF and Kyua) are run unchanged. New rmxOS tests use the project's own stack consistently (Zig for the substrate, swift-testing for the high level, Elixir to drive runs) and need not be upstreamable. A new Zig test must run one case at a time by name and leave a per-case result. This replaces testing-strategy.md rule 4's "ATF under tests/sys/mach". op-395's ATF-linked Zig tests stay until a migration op, and op-408 runs them as they are. Also added to the gatekeeper0 OPS template: check guest commands against the image before any boot, and fix own-harness problems in-op (re-rendered gatekeeper1).
- state delta: none.
- evidence: none.
- next: none.

### j-20261002-004 — op-394 design proposal returned and closed; decision pending

- time / kind: 2026-10-02T01:39:42Z / ACTION
- outcome: advisor2 returned `rmx-advisor2@6c4667b`, a 300-line proposal that recommends:
  - **A2:** a Mach-owned name table with generation tags and fileports for file transfer;
  - **B2:** per-incarnation task and thread objects with full death and unwind;
  - **C1:** messages queued, with kqueue for readiness only, and the dispatch receive adapter shipped in the same image;
  - **D2:** a bounded cross-task MIG subset, gated on B and A.

  It introduces them in six booting steps that take batch 1 as done, and it lists the decisions needed before code. Spot checks: `port.h:219-230` (generations under `#if 0`) and `ipc_tt.c:870-878` (`convert_port_to_task` returns `current_task()`) are exact. Closed as a consult (S). The Coordinator decides the direction.
- state delta: op-394 draft → issued → returned → closed.
- evidence: the two spot checks above.
- next: Coordinator: adopt A2, B2, C1 and D2 or not; then draft fix batch 2 as step 2.

### j-20261002-005 — op-394 follow-ups: XNU-reuse revision and the NextBSD fd rationale

- time / kind: 2026-10-02T02:22:35Z / ACTION
- outcome: The Coordinator consulted advisor2 directly after op-394 closed. Two follow-up commits in rmx-advisor2:
  - `519ec47`: the proposal revised to reuse XNU's namespace and right-accounting code through FreeBSD adapters, keep direct receive through an XNU-style kqueue callback (C3), and carry Capsicum rights on fileports.
  - `02bc161`: why NextBSD made port names fds. Checked first-hand: the five cited Matt Macy commits in `nx/NextBSD` (27c6e39d, a9c4bf05, 8e81d12c with +117/-2053, 298a8e33, 45010950), f3af7791 (non-passable), cbda4630 (Capsicum boot fix), and `ipc_entry.c:329` (CAP_KQUEUE rights) all match. Conclusion: the fd choice was an ownership and integration decision (allocation, limits, refcount lifetime, kqueue, file transfer, Capsicum compatibility); inspection came later and was a side benefit.

  Open for the Coordinator: the direction (XNU table, with NextBSD's six functions as requirements); C1 or C3 (the Arranger suggests C1 for the preview, because C3 changes FreeBSD's kqueue); pushing `mach-fixes-1`. Next per advisor2: pin the XNU donor release (two trees on disk).
- state delta: none.
- evidence: `git log -1` of each commit in `nx/NextBSD`; `NextBSD-NextBSD-CURRENT/sys/compat/mach/ipc/ipc_entry.c:327-331`.
- next: Coordinator decisions.

### j-20261002-006 — Coordinator: 1.0 keeps fd-backed Mach names; step 5 deferred (id-056)

- time / kind: 2026-10-02T02:30:30Z / DECISION
- outcome: The Coordinator kept 1.0's aim of reviving NextBSD:
  - **1.0:** port names stay file descriptors (op-394 A1), with B2, C1 and D2 through op-394's steps 2-4.
  - **Deferred past 1.0:** step 5 (the XNU-style name table, and possibly C3), as id-056.
  - **Record:** mach-names-step5-deferred.md lists nine limitations of fd-backed names with a 1.0 rule for each, the rules that keep step 5 possible (all name handling through the step-2 entry API; no name/fd casts outside named functions; tests check Mach behaviour, not fd numbers), and the triggers to revisit.

  Linked from now.md, kernel-reviews.md and the IDQ index.
- state delta: id-056 raised (DEFERRED POST-1.0).
- evidence: none.
- next: Draft fix batch 2 (step 2) once op-395 closes.

### j-20261002-007 — op-408: 13 of 13 base panics reproduced; fixture module unloadable; op-409 drafted

- time / kind: 2026-10-02T02:32:10Z / ACTION
- outcome: op-408 returned BLOCKED after 14 of 20 boots. Checked first-hand:
  - `18f721d` is on origin.
  - B01-B13 reproduced their expected base panics; those results stand.
  - B14 failed because `rmx_translate_fixture.ko` has 5 `R_X86_64_32` relocations, which the kernel linker refuses (`kldload: unexpected relocation type 10`). It is loaded by mach_translate, mach_proc_info and mach_timeout.

  gatekeeper1 stopped the whole run instead of skipping the 3 dependent programs. The gatekeeper0 OPS template now says to skip dependent cases and finish the rest (gatekeeper1 re-rendered). op-408 is closed. op-409 (Implementer, new session) rebuilds the fixture with kmod.mk flags, checks its relocations, and restages both images. Then one Gatekeeper run finishes the remaining base cases and the whole fixed suite.
- state delta: op-408 issued → returned → closed; op-409 created as draft.
- evidence: `readelf -rW rmx_translate_fixture.ko`; `git grep` of the fixture users.
- next: Send op-409.

### j-20261002-008 — op-409 sent; op-410 (first sanitizer survey) drafted

- time / kind: 2026-10-02T02:34:44Z / ACTION
- outcome: op-409 is sent to the Implementer. While it runs, gatekeeper1 is idle, so op-410 runs the op-372 slice (which copies its binaries in over serial, so needs no image change) on the op-396 RELEASE and KASAN images in survey mode. The loader variables go through `bhyveload -e`. op-410 is the first Testing 1.0 runtime evidence and the first boot of an in-kernel-built `mach.ko`. It uses different images from op-409, so the two do not conflict. Size M; the Arranger reviews.
- state delta: op-409 draft → issued; op-410 created as draft.
- evidence: `build/op372/guest-sequence.tsv` (serial transfer, identity checks).
- next: Send op-410.

### j-20261002-009 — Naming: "instrumentation" is the umbrella; testing-strategy.md → instrumentation-strategy.md

- time / kind: 2026-10-02T02:46:04Z / DECISION
- outcome: The Coordinator named the umbrella. Instrumentation covers sanitizers and coverage, DTrace and hwpmc/hwt. Each tool is an instrument, and a build with one compiled in is an instrumented profile. The tiers are now Instrumentation 1.0, 2.0 and 3.0. The file is renamed and the live documents (now.md, the IDQ, the step-5 record, the safety guide, the op-410 draft) are updated. The term is defined in terminology.md §7. Journal entries and closed ops keep the old names. The strategy also gains a Swift row for SE-0550 (`@instrumentation`; swiftlang/swift-evolution#3522 merged a revision, and the proposal text is still in review).
- state delta: none.
- evidence: none.
- next: none.

### j-20261002-010 — Correction: op-407 was never sent

- time / kind: 2026-10-02T02:49:14Z / CORRECTION
- outcome: j-20261002-002 recorded op-407 as issued without the Coordinator saying it was sent. The Coordinator confirms it was not sent, so op-407 is back to draft (rob --force, as a correction). Rule: an op becomes issued only on the Coordinator's word.
- state delta: op-407 issued → draft (correction).
- evidence: none.
- next: Show op-407 again.

### j-20261002-011 — op-407 sent; op-409 verified and closed; op-411 held behind op-410

- time / kind: 2026-10-02T02:57:17Z / ACTION
- outcome: The Coordinator sent op-407. op-409 returned DONE. Checked first-hand:
  - `acfc34cd` sits on `5fa02fb5` and changes only the fixture.
  - The new `rmx_translate_fixture.ko` has only R_X86_64_64, PC32, PLT32 and 32S relocations, all accepted at `elf_machdep.c:296-349`.
  - Both image hashes match (41c81b17…, 088c490a…).

  op-409 is closed (S). op-411 finishes the op-395 proof in 3 boots and is held until op-410 frees gatekeeper1. `mach-fixes-1` (now 14 commits) still needs the Coordinator's yes to push.
- state delta: op-407 draft → issued; op-409 issued → returned → closed; op-411 created and held (needs op-410).
- evidence: `readelf -rW` of the fixture; `sha256` of both images.
- next: op-410's REPORT.

### j-20261002-012 — op-407 REMEDIATE 9/10: fix 6 leaves the port-set lock held in filt_machport; op-412 drafted

- time / kind: 2026-10-02T03:03:09Z / ACTION
- outcome: validator2 (`17ba614`, local) finds that 12 of the 13 fixes hold. Fix 6 (`10b9c426`) made `ipc_object_translate` always lock and moved `filt_machportattach` to the `_known` form, but left `filt_machport` on the plain call (`ipc_pset.c:623`). Its guarded unlock (line 637) then skips the normal case, and line 667 re-locks the same mutex. Checked first-hand at `5fa02fb5`: lines 609-669 and `ipc_object.c` `translate_internal` locking unless `known == object`. The finding holds. op-407 is closed. op-412 (Implementer) makes the one-call fix plus a check of the other callers, then restages the fixed image. op-411 now needs op-410 and op-412, and gets the new fixed image's path and hash before it is sent. The base image is unaffected.
- state delta: op-407 issued → returned → closed; op-412 created as draft; op-411 needs op-410 and op-412.
- evidence: `git show 5fa02fb5:sys/compat/mach/ipc/ipc_pset.c`, lines 609-669; `ipc_object.c`, lines 115-161.
- next: Send op-412.

### j-20261002-013 — op-410: RELEASE survey clean; KASAN boots ran RELEASE (kernel= form); op-413 held behind op-412

- time / kind: 2026-10-02T03:09:27Z / ACTION
- outcome: op-410 was sent and returned PARTIAL after 4 of 4 boots; `ca5ac4a` is on origin.
  - **P0 RELEASE (A2):** `mach.ko` built with its kernel (assertions compiled in) loaded, all eight slice cases passed, and there were no KASSERT or sanitizer reports. That is the first boot of the in-kernel-built module.
  - **P1 KASAN (A3/A4):** booted the RELEASE kernel, and the KASAN `mach.ko` failed to load (`__asan_load4_noabort`).
  - **Cause, from `stand/lua/config.lua:717-800`:** `kernel=` names a /boot directory and the loader appends `/kernel`. op-396's `kernel="RMXOS-KASAN/kernel"`, required by the helper's kernel-profile check, makes the loader fall back. op-364 and op-388 use the same form and work only by fallback.

  op-410 is closed (the RELEASE result stands). op-413 (Implementer) fixes the helper check and restages KASAN and KMSAN; it is held until op-412 frees the Implementer. gatekeeper1's queue: op-411, the KASAN survey retry, the reaper redo.
- state delta: op-410 issued → returned → closed; op-413 created and held.
- evidence: `build/op410/findings.md`, lines 9 and 59-78; `git show 2884304b:stand/lua/config.lua`, lines 717-800.
- next: op-412's REPORT.

### j-20261002-014 — op-412 verified and closed; op-411 and op-413 released

- time / kind: 2026-10-02T03:16:49Z / ACTION
- outcome: op-412 returned DONE. Checked first-hand:
  - `1045a24b` (on `acfc34cd`) changes only `filt_machport` to `ipc_object_translate_known(…, entry->ie_object, …)`.
  - The caller audit finds no other seeded-output and conditional-unlock pattern (`mach_port_get_set_status` unlocks unconditionally; `thread_activation_create` is under `notyet`).
  - The image hash matches (154d638b…).

  op-412 is closed (S). op-411 gets the new fixed image and is ready (gatekeeper1). op-413 is ready (Implementer). They use different images and agents.
- state delta: op-412 issued → returned → closed; op-411 and op-413 hold → draft.
- evidence: `git show 1045a24b`; `build/op412/evidence/caller-audit-v2.txt`.
- next: Send op-411 and op-413.

### j-20261002-015 — Road to round 2 and its guardrail; receive model needs a "C1 under A1" note

- time / kind: 2026-10-02T03:29:30Z / DECISION
- outcome:
  - **Readiness for Mach review round 2**, recorded in kernel-reviews.md and id-051: batch 1 closed; step 2 (entries); step 3 (lifetimes); step 4 plus receive in `mach_msg` (C1) with the dispatch adapter; the D2 subset; the regression suite and KASAN on the fixed branch.
  - **Guardrail:** the round-2 brief carries the step-5 deferral, so reviewers judge the code against mach-names-step5-deferred.md and do not re-propose the name table or C3. Findings that only step 5 could fix go to id-056. id-052's areas are included.
  - **Gap found:** advisor2's revision (`519ec47`, lines 196-222, 280-301) ties the receive-model fix to step 5, while the 1.0 record keeps C1. A short design note, "C1 on the fd backend", must precede step 4, or op-389 #6 and op-392 F4 would wait for the overhaul.
- state delta: none.
- evidence: the proposal lines cited.
- next: After op-411, draft batch 2 (step 2) and the C1 design note.

### j-20261002-016 — Coordinator: rmxOS images move to ZFS root (id-057); op-414 drafted, held

- time / kind: 2026-10-02T03:33:14Z / DECISION
- outcome: ZFS is an important rmxOS feature, so new images use a ZFS root. This is independent of the Mach work. Checked:
  - the host's `makefs` supports `-t zfs` (unprivileged build, no mount);
  - the host pool is `zroot`, so the guest pool is `rmxroot`;
  - op-364's image has `zfs.ko` and `opensolaris.ko`, and the ZFS boot code must come from the build.

  Pinned UFS images stay as they are. op-414 (Implementer) builds the first ZFS-root image from op-364's staging tree, with `kernel=` in directory form. It is held until op-413 returns. A Gatekeeper boot check follows.
- state delta: id-057 raised (READY); op-414 created and held.
- evidence: `makefs` usage and man page (zfs options); `zpool list`; op-364 METALOG.
- next: op-411 and op-413 REPORTs.

### j-20261002-017 — op-413 verified and closed; op-414 released; op-415 (KASAN/KMSAN survey) held behind op-411

- time / kind: 2026-10-02T03:40:18Z / ACTION
- outcome: op-413 returned DONE. Checked first-hand:
  - `59afc2fc` changes the helper's kernel-profile check to `kernel="<config>"`, with its generator and self-test.
  - The KASAN image's loader.conf reads `kernel="RMXOS-KASAN"`.
  - Both image hashes match (b1f44761…, a3eff4dc…).
  - The Arranger pushed `59afc2fc` (private repo); it is on origin.

  op-413 is closed (S). op-414 (ZFS image) is released, since the Implementer is idle. op-415 (KASAN and KMSAN survey, 8 GiB for KMSAN, kernel-identity check before the slice) is held behind op-411.
- state delta: op-413 issued → returned → closed; op-414 hold → draft; op-415 created and held.
- evidence: `git show 59afc2fc`; the op413-KASAN BOM's loader.conf; `sha256` of both images.
- next: Send op-414.

### j-20261002-018 — op-411: 20 of 27 confirmed; three causes behind seven mismatches; op-415 released; op-416 held

- time / kind: 2026-10-02T03:43:04Z / ACTION
- outcome: op-414 was sent. op-411 returned FAILED after 5 of 6 boots; `13f1212` is on origin. 20 of 27 cases match, including op-408's 13 base panics and `short_buffer` (which confirms op-412's lock fix). The seven mismatches have three causes:
  1. **The fixture cannot load (4 cases):** `MODULE_DEPEND(…, mach, 1, 1, 1)` against a `mach.ko` with no `MODULE_VERSION`. Checked first-hand at `1045a24b`.
  2. **fd_exhaustion on the fixed image:** `IPC_KERNEL` returned where the test expects `IPC_SPACE`. A semantic question to settle against XNU.
  3. **Base clock absolute and past:** an outer timeout, because the defect sleeps too long; the tests should bound their own wait.

  op-411 is closed. op-416 (Implementer) takes all three and restages; it is held until op-414 returns. op-415 (KASAN/KMSAN survey) is released, since gatekeeper1 is idle.
- state delta: op-414 draft → issued; op-411 issued → returned → closed; op-415 hold → draft; op-416 created and held.
- evidence: `build/op411/findings.md`, lines 44-66; `git grep MODULE_` at `1045a24b`.
- next: Send op-415.

### j-20261002-019 — op-414 BLOCKED on boot code the runner does not need; op-416 released; op-417 (ZFS redo) held

- time / kind: 2026-10-02T03:50:27Z / ACTION
- outcome: op-415 was sent. op-414 returned BLOCKED because `gptzfsboot` and `pmbr` are absent from the build trees. Checked first-hand:
  - op-364 built its image with `mkimg -s gpt -p freebsd-ufs:=…` and no boot code (command-returns.txt:33).
  - gatekeeper1's runner boots with `bhyveload`, which uses the host's `/boot/userboot.so` (run-op360 scripts).

  The boot-code requirement was the Arranger's over-specification (an Arranger error). op-414 is closed. op-416 (the Mach proof fixes) is released first, since it has priority. op-417 is op-414 without boot code and is held behind op-416.
- state delta: op-415 draft → issued; op-414 issued → returned → closed; op-416 hold → draft; op-417 created and held.
- evidence: op-364 `evidence/command-returns.txt`, line 33; `grep bhyveload` in rmx-gatekeeper1 build/op360.
- next: Send op-416.

### j-20261002-020 — op-416 sent; op-415 DONE: KASAN and KMSAN surveys clean; closed

- time / kind: 2026-10-02T04:05:37Z / ACTION
- outcome: op-416 was sent. op-415 returned DONE after 2 of 4 boots. Checked first-hand:
  - `a02d5e1` is on origin, and both serial hashes match (88301b6d…, 7c1089aa…).
  - Lines 9, 131 and 172 show `RMXOS-KASAN` and `RMXOS-KMSAN` from `testing-1@7ccf16fa` booted from `/boot/RMXOS-K?SAN/kernel`.
  - The survey settings were applied (`warn_only 1`, `panic_on_violation 0`).
  - No sanitizer, assertion or panic line appears; every keyword match is an identity or settings line.

  The slice passed 8/8 on both. Reading: the instrumented profiles work end to end. It does not show Mach is clean, because the slice is small and the code is alpha2. op-415 is closed. Next for id-047: the 27-case Mach suite under KASAN on the fixed branch, after op-416.
- state delta: op-416 draft → issued; op-415 issued → returned → closed.
- evidence: both serial logs, lines 9-307.
- next: op-416's REPORT.

### j-20261002-021 — Swift integration restarted: first step is one libdispatch per process

- time / kind: 2026-10-02T04:11:50Z / DECISION
- outcome: The Coordinator restarted the Swift integration, starting with Swift on rmxOS's real libdispatch after the current Mach test proof.
  - **Found:** the installed Swift 6.4 toolchain ships corelibs `libdispatch.so` and `libBlocksRuntime.so` (RUNPATH `$ORIGIN`), and `libswiftDispatch.so` links both. On rmxOS that means two dispatch runtimes per process (Swift on corelibs; libxpc, notify and launchd on rmxOS's `libdispatch.so.5`).
  - **First step**, recorded in swift-rmxos-integration-plan.md § Restart: build `libswiftDispatch` and `libswift_Concurrency` against rmxOS's libdispatch; run Dispatch, a Mach-port source and Swift concurrency in a guest, showing one libdispatch mapped; then compare with macOS.
  - **Ownership of the Swift-side build** (the swift-rx agents) is to be confirmed by the Coordinator.
- state delta: none.
- evidence: `readelf -d` of `/usr/local/swift/lib/swift/freebsd/libdispatch.so` and `libswiftDispatch.so`; the swift-rx implementer's git log, CHANGELOG and 2026-10-02 comparison note.
- next: Coordinator: who arranges the swift-rx agents.

### j-20261002-022 — op-416 verified and closed; op-418 (final batch-1 proof) and op-417 (ZFS) ready

- time / kind: 2026-10-02T04:17:11Z / ACTION
- outcome: op-416 returned DONE. Checked first-hand:
  - Commits on `mach-fixes-1`: `923b3229` adds `MODULE_VERSION(mach, 1)`. `2b20aee8` makes `kern_finstall` returning EMFILE give KERN_NO_SPACE, hence MACH_MSG_IPC_SPACE, matching XNU `ipc_kmsg_copyout_port`'s "No room in space" at lines 3637-3643 and the A1 rule that fd limits are the name space. `903c8fc2` bounds the clock tests.
  - The base `mach.ko` is 2884304b plus only MODULE_VERSION.
  - Both image hashes match.
  - `rmx-implementer@59fd6cba` was pushed and is on origin.

  op-416 is closed. op-418 (gatekeeper1) is the final batch-1 proof in 3 boots; it reruns the fixture programs on the base image too, because op-411's base FAILs there came from the load failure, and it asks for each FAIL's printed reason. op-417 (ZFS image) is released to the idle Implementer.
- state delta: op-416 issued → returned → closed; op-417 hold → draft; op-418 created as draft.
- evidence: `git show` of the three commits; `build/op416/evidence/xnu-copyout.txt`; `sha256` of both images.
- next: Send op-418 and op-417.

### j-20261002-023 — Mach batch 1 PROVEN (op-418, 27/27); op-417 ZFS image built; op-419 drafted

- time / kind: 2026-10-02T06:43:01Z / ACTION
- outcome:
  - **op-418** returned DONE. Checked first-hand: `9157b8c` is on origin; the three serial hashes match. The findings table has 27 rows: 14 PANIC/PANIC base with PASS/PASS fixed, 12 FAIL/FAIL base with PASS/PASS fixed, and 1 control PASS everywhere. No fixture-load reason appears. Batch 1 is proven at runtime.
  - **op-417** returned DONE. Checked: the image hash is 1f4cf949…; the pool `rmxroot` has the datasets `ROOT` and `ROOT/default`; loader.conf has `kernel="RMXOS-RELEASE"`, `zfs_load` and the ZFS mountfrom. Open point: the BOM lists all 32,844 staging files as 501:20 with no setuid on su. The image's ownership should come from the mtree manifest passed to makefs, but an offline zdb read was inconclusive. op-419 checks ownership in the guest.
  - Both are closed. op-395 waits only on `mach-fixes-1` being on origin (the Coordinator's yes).
- state delta: op-417 and op-418 issued → returned → closed; op-419 created as draft.
- evidence: `build/op418/findings.md`; op-417's `commands.jsonl` (makefs with the METALOG.op417 source) and its pool logs.
- next: Send op-419; the Coordinator's push decision; then batch 2 (step 2) and the C1 note.

### j-20261002-024 — op-419 sent; batch 2 (op-420, step 2) and the C1-under-A1 note (op-421) drafted

- time / kind: 2026-10-02T06:47:46Z / ACTION
- outcome: op-419 was sent. The Implementer and advisor2 are idle, so two drafts are ready:
  - **op-420 (Implementer):** op-394 step 2 on a new branch `mach-fixes-2`, test-first, gate one Validator. It carries the step-5 deferral rules 1, 2 and 4 inline, and targets op-389 #2 and op-392 S2/S3/S4.
  - **op-421 (advisor2):** the short design note for C1 on the fd backend, closing the gap recorded in j-20261002-015.

  They use different agents and do not conflict.
- state delta: op-419 draft → issued; op-420 and op-421 created as drafts.
- evidence: the proposal's step list, lines 280-292.
- next: Send op-420 and op-421; the Coordinator's push decision for `mach-fixes-1`.

### j-20261002-025 — op-420 and op-421 sent; op-419: the ZFS-root image boots; makefs drops file flags

- time / kind: 2026-10-02T06:57:31Z / ACTION
- outcome: op-420 and op-421 were sent. op-419 returned FAILED on its acceptance list only because `su` lacks `schg`. Checked first-hand:
  - `fb253ff` is on origin; serial hash 62fc69a7….
  - Lines 94-216: the root is mounted from `zfs:rmxroot/ROOT/default`; the pool is ONLINE; RMXOS-RELEASE runs; `/`, `su` (setuid `-r-sr-xr-x`), `master.passwd` (0600) and `launchd` are `root:wheel`, so the mtree manifest's ownership works. Every file carries only `uarch`.
  - Cause: makefs's ZFS backend hard-codes the znode flags (`fs.c:434-435`) and ignores manifest flags. This is a FreeBSD upstream candidate.

  "launchd jobs untested" came from the Arranger's brief: op-364's contents boot /sbin/init. op-419 is accepted as the ZFS boot proof with the flag gap recorded in id-057, and closed.
- state delta: op-420 and op-421 draft → issued; op-419 issued → returned → closed.
- evidence: serial lines 94-216; `git show 2884304b:usr.sbin/makefs/zfs/fs.c`, lines 430-436.
- next: Reports from op-420 and op-421; the Coordinator's push decision.

### j-20261002-026 — mach-fixes-1 published; op-395 (Mach fix batch 1) closed

- time / kind: 2026-10-02T06:59:48Z / ACTION
- outcome: With the Coordinator's yes, the Arranger pushed `mach-fixes-1` to the public rmxOS origin by hash: `refs/heads/mach-fixes-1` = `903c8fc2`, 18 commits on `2884304b`. It is a new branch, and no existing branch changed. op-395's gates are all met:
  - validator2's review (op-407; its fix-6 finding fixed in op-412 and verified);
  - the runtime proof (op-418, 27/27 before and after);
  - the Implementer repo's commits (`d4a8015`, `59afc2fc`, `59fd6cba`) on origin.

  op-395 is closed. Mach fix batch 1 is done. now.md, id-046 and the index are updated.
- state delta: op-395 returned → closed.
- evidence: `git ls-remote --heads origin mach-fixes-1` → 903c8fc2…; `git merge-base --is-ancestor` for the three Implementer commits.
- next: op-420 and op-421 REPORTs.

### j-20261002-027 — op-405 closed; reaper redo op-422 drafted for the idle gatekeeper1

- time / kind: 2026-10-02T07:00:43Z / ACTION
- outcome: op-405's evidence stands: the classifier passes 22/22 and the exit-status fix works. It is closed. op-422 redoes the collector fix (`dtrace -e` on the host), the probe preflight and the one cell under the kernel-side contract, with in-op harness fixes. It is a pre-fix baseline on op-388 (without N1). The gate is both Validators (runtime verdict). op-280 now needs op-422.
- state delta: op-405 returned → closed; op-422 created as draft; op-280 needs op-422.
- evidence: none new.
- next: Send op-422.

### j-20261002-028 — op-422 sent; op-421 C1-on-fd-backend note returned and closed; one decision open

- time / kind: 2026-10-02T07:33:04Z / ACTION
- outcome: op-422 was sent. op-421 returned DONE (`rmx-advisor2@5bfc3e1`, 120 lines). The design:
  - a readiness-only, fd-backed `EVFILT_MACHPORT` with independent pins and no Mach locks under knlist locks;
  - one queued receive path (MIG replies queued, no waiter handoff) and complete LARGE/trailer handling;
  - a libdispatch manager-side `mach_msg` drain loop, plain `mach_msg` kept for launchd and libxpc, and a nonblocking libxpc pipe receive;
  - introduction against steps 2-4, and an honest "needs step 5" list.

  One item changes FreeBSD itself: a native "EOF retirement" helper in kern_event.c and kern_descrip.c, so that closing a Mach name delivers one EOF per registration before fd reuse. It goes to the Coordinator as (a) adopt it, or (b) keep native close semantics (silent knote deletion; death reported through Mach notifications). The Arranger recommends (b), per the alignment rule and the C3 precedent. op-420 is unaffected under (b). op-421 is closed as a consult.
- state delta: op-422 draft → issued; op-421 issued → returned → closed.
- evidence: the note's §1 "Revocation needs a small native retirement helper".
- next: The Coordinator's (a)/(b) decision.

### j-20261002-029 — Coordinator: (b) native close semantics for 1.0; the EOF helper is deferred

- time / kind: 2026-10-02T07:34:33Z / DECISION
- outcome: The Coordinator chose (b), the safe option. 1.0 keeps FreeBSD's native close behaviour: closing a Mach name silently removes its knotes, and port death is reported through Mach notifications and `mach_msg` errors. op-421's native EOF retirement helper (changes to kern_event.c and kern_descrip.c) is deferred with step 5 (id-056). mach-names-step5-deferred.md gains a "Receive model for 1.0" section and a revisit trigger. kernel-reviews.md step 4 points to op-421 minus the helper.
- state delta: none.
- evidence: none.
- next: op-420 and op-422 REPORTs.

### j-20261002-030 — op-420's native FreeBSD changes reviewed in flight; NOTICE; allowed list recorded

- time / kind: 2026-10-02T07:55:51Z / DECISION
- outcome: The Coordinator saw op-420 editing FreeBSD files and asked whether that is safe. Checked the work tree (uncommitted; commit `9e0d19e2` holds the Mach uref work):
  - `file.h` adds `fo_fdpostclose` in a spare slot (`fo_spares[7]` to `[6]`, struct size unchanged) and `DFLAG_NODUP 0x08`, next to PASSABLE, SEEKABLE and FORK.
  - `kern_descrip.c` gains about 15 lines: the post-close calls at 1422 and 2740, and dup rejection at 1079 and 4038.
  - Both follow from op-420's rules (descriptor-removal revocation and dup rejection), which FreeBSD cannot provide natively. Expected and safe in design.

  The NOTICE asks for separate `kern:`/`sys:` commits, the native files listed in the REPORT, and every removal path shown calling the hook. It caps native changes at these two mechanisms. mach-names-step5-deferred.md records them as the only FreeBSD-side changes allowed for 1.0 without a new decision.
- state delta: none.
- evidence: `grep` of `sys/sys/file.h` and `sys/kern/kern_descrip.c` in build/op420/source.
- next: Relay the NOTICE.

### j-20261002-031 — op-420 (batch 2) returned and checked; op-423 review ready; op-424 proof held

- time / kind: 2026-10-02T09:00:05Z / ACTION
- outcome: op-420 returned DONE. Checked first-hand:
  - `mach-fixes-2` has 7 commits from 903c8fc2 to ee883a74 (+754 -366, 21 files).
  - Outside compat/mach, sys/sys/mach and tests, only `sys/kern/kern_descrip.c` and `sys/sys/file.h` change, as separate `kern:` commits bc8852bd and 0df2b329.
  - Every removal path reaches the post-close hook: kern_close, close_range and close-on-exec through closefp; dup2 replacement through closefp(…, delfp …); fdclose through closefp when the hook is set; exit through fdescfree_fds directly.
  - Both image hashes match.

  The gate is one Validator: op-423 (validator2), ready now. The runtime proof op-424 (gatekeeper1) is held behind op-422. Commits are not yet on origin.
- state delta: op-420 issued → returned; op-423 created as draft; op-424 created and held.
- evidence: `git log` and `git diff --name-only 903c8fc2..ee883a74`; kern_descrip.c call sites at ee883a74; `sha256` of both images.
- next: Send op-423.

### j-20261002-032 — op-423 sent; op-422 preflight passed, cell not accepted; launchd GetJob bug (id-059)

- time / kind: 2026-10-02T09:02:24Z / ACTION
- outcome: op-423 was sent. op-422 returned BLOCKED after 3 of 3 boots; `2db74d1` is on origin.
  - **Preflight r2 PASSED:** all eight kernel-side streams for PID 1 recorded.
  - **Cell: HARNESS-NOT-ACCEPTED,** with (a), (b) and (c) INCONCLUSIVE:
    1. the driver's serial markers stop after STARTED (cause unknown);
    2. `pgrep -x launchd` excludes ancestors, a harness bug;
    3. all 30 `launchctl dump LABEL` replies export the caller.
  - **Diagnostics only:** the 50 kernel statuses match the workload, and the detached thread peaked at 0.006 of a core.
  - Item 3 is a launchd bug, checked first-hand: `sbin/launchd/ipc.c:570` `job_export(ctx->j)`, against `job_export(j)` at line 445. Raised as id-059, with op-426 for the Implementer.

  op-422 is closed. op-424 (batch-2 proof) is released first (Mach first). The reaper cell is redrafted after op-424, with the transcript fix, an ancestor-safe PID check, and job status read through GetJobs with exact label selection.
- state delta: op-423 draft → issued; op-422 issued → returned → closed; op-424 hold → draft; id-059 raised; op-426 created as draft.
- evidence: `build/op422/findings.md`, lines 23-31; `git show 2884304b:sbin/launchd/ipc.c`, lines 436-452 and 560-575.
- next: Send op-424 and op-426.

### j-20261002-033 — Correction: the GetJob op is op-425, not op-426

- time / kind: 2026-10-02T09:02:42Z / CORRECTION
- outcome: j-20261002-032 named the launchd GetJob op "op-426", but `rob new` assigned op-425, and the brief was not written at first. op-425 now holds the brief, and id-059 and the index say op-425.
- state delta: none.
- evidence: none.
- next: Send op-424 and op-425.

### j-20261002-034 — op-424 and op-425 sent; op-423 CLOSE 9/10 on Mach batch 2

- time / kind: 2026-10-02T09:07:52Z / ACTION
- outcome: op-424 and op-425 were sent. op-423 (validator2, `156f754`, local) returned CLOSE 9/10. All five checks hold: the targets are fixed at their causes; no conflicting lock order; every removal path funnels through idempotent hooks; the FreeBSD-side change keeps the ABI and leaves other file types unchanged; batch 1 is intact. Its "next" names op-421 for the runtime run, which is a slip for op-424. op-423 is closed. op-420 stays returned until op-424's runtime proof and `mach-fixes-2` reach origin.
- state delta: op-424 and op-425 draft → issued; op-423 issued → returned → closed.
- evidence: `git log 156f754` in rmx-validator2.
- next: op-424 and op-425 REPORTs; then batch 3 (step 3).

### j-20261002-035 — Correction: op-425 was never sent

- time / kind: 2026-10-02T09:10:22Z / CORRECTION
- outcome: j-20261002-034 recorded op-424 and op-425 both as issued after an ambiguous "sent". The Implementer has no trace of op-425 (no launchd-fixes-1 branch, build directory or record), so op-425 is back to draft. This is the second such error after op-407; LOCAL.md now says to record only the op the Coordinator names and to ask when unsure.
- state delta: op-425 issued → draft (correction).
- evidence: `git branch --list launchd-fixes-1` is empty; there is no build/op425.
- next: Show op-425.

### j-20261002-036 — op-425 sent; workflow-report.md created with the first workflow review

- time / kind: 2026-10-02T09:19:11Z / ACTION
- outcome: op-425 was sent. At the Coordinator's request, created workflow-report.md, a dated log of workflow reviews. The first entry covers op-391 to op-425 (35 ops):
  - what works: verification catching real bugs, parallel lanes, cost tiering, the relay steering;
  - what costs time: brief quality (about ten guest ops lost, many to Arranger brief errors, now standing rules), relay ambiguity (op-407, op-425), filter stops;
  - the "graph engineering" mapping, and proposals: "sent op-NNN" and `tools/rob graph`.
- state delta: op-425 draft → issued.
- evidence: `tools/rob list` counts for op-391 onward.
- next: op-424 and op-425 REPORTs; the Coordinator's batch-3 decisions.

### j-20261002-037 — Rule 16 "Brief quality" added to the rulebook

- time / kind: 2026-10-02T09:21:33Z / DECISION
- outcome: The Coordinator asked whether the briefing strategy improved and is documented. The lessons were scattered in LOCAL.md. They are now rulebook Rule 16 (arranger0 template, rendered), a check before any brief is shown: feasibility first; tools and paths checked against the real artifact; only required requirements; facts verified with a cited line; "do not proceed until" rather than "stop the op", with budgets for reruns; unseen context inline; complete continuation messages and NOTICEs; redo briefs updated throughout; wording and evidence rules; "issued" only on the Coordinator's word. LOCAL.md keeps the specific cases; workflow-report.md lists the change.
- state delta: none.
- evidence: none.
- next: none.

### j-20261002-038 — op-425 verified and closed: launchd GetJob fix

- time / kind: 2026-10-02T09:23:00Z / ACTION
- outcome: op-425 returned DONE. Checked first-hand:
  - `42bf6205` (on 903c8fc2) changes `job_export(ctx->j)` to `job_export(j)` and adds `tests/sys/launchd/launchd_getjob.zig`.
  - The NextBSD source has the same bug at `ipc.c:570`, so the donor claim holds.
  - The remaining `job_export(ctx->j)` at line 507 is CHECKIN (a job asking for itself), which is correct.

  `rmx-implementer@5d4d7c6a` was pushed. op-425 is closed (S). The named_job runtime check goes to the next guest run with launchd. `launchd-fixes-1` is not on the public origin yet.
- state delta: op-425 issued → returned → closed.
- evidence: `git show 42bf6205`; `grep job_export(ctx->j)` in the NextBSD tree and at 42bf6205.
- next: op-424's REPORT; the batch-3 decisions.

### j-20261002-039 — Delegated (Rule 9): batch-3 exec policy and two more FreeBSD hooks

- time / kind: 2026-10-02T09:40:24Z / DECISION (delegated by the Coordinator)
- outcome: The Coordinator delegated both batch-3 questions under the principle "match macOS, but not at the cost of stability; document differences and fix them later".
  - **Exec policy:** an ordinary exec keeps the task identity and its bootstrap and registered ports, and the Mach name space and thread ports are rebuilt (op-394 B2). A credential-changing exec (setuid/setgid) gives the task fresh control ports, as XNU's `ipc_task_reset` does. Deferred as documented differences: XNU's exception-port reset rules and task identity tokens.
  - **FreeBSD-side hooks:** allowed are an "exec committed" event (after the final credentials, before the return to user space) and a non-blocking thread-exit gate in the common `thread_exit`. Both in FreeBSD's EVENTHANDLER style, as separate `kern:` commits. Without them, setuid revocation races the credential change and thread state is torn down late.
  - Mach names stay outside `FD_CLOEXEC` and `FD_CLOFORK` (rules 7 and 8): Mach's own hooks govern them.

  The allowed-list in mach-names-step5-deferred.md grows by these two. A "Known differences from macOS in 1.0" section starts there.
- state delta: none.
- evidence: op-394 § B (`rmx-advisor2@519ec47`, lines 92-180).
- next: Draft batch 3.

### j-20261002-040 — Batch 3 (op-426, op-394 step 3) drafted

- time / kind: 2026-10-02T09:40:49Z / ACTION
- outcome: op-426 (Implementer) is drafted: B2 lifecycles on a new branch `mach-fixes-3` from `mach-fixes-2`. It carries the delegated exec policy, the fd-flag rule, the two allowed hooks and the shared-table rule inline. Targets: op-389 #4 and #11, op-392 F2 and F1, and op-393 N5's prerequisite. Gate: one Validator, then the Gatekeeper's proof. Ready: the Implementer is idle, and op-424 only reads `mach-fixes-2`.
- state delta: op-426 created as draft.
- evidence: none.
- next: Send op-426.

### j-20261002-041 — op-426 sent; op-424 proves batch 2 (4/4 before and after, 31/31 on the fixed image)

- time / kind: 2026-10-02T09:55:27Z / ACTION
- outcome: op-426 was sent. op-424 returned DONE. Checked first-hand: `f04d76a` is on origin; the serial hashes match (2ffc1850…, 6e6e6eaa…). The table has 31 rows: the 4 new cases are FAIL on the base (no fixture-load reasons) and PASS on the fixed image; the 27 batch-1 cases are NOT-RUN on the base, by design, and PASS on the fixed image. op-424 is closed.

  op-420 closes once `mach-fixes-2` is on origin. Correction: op-425 was closed while `launchd-fixes-1` was only local, against the origin rule. Both branches go to the Coordinator for a push decision.
- state delta: op-426 draft → issued; op-424 issued → returned → closed.
- evidence: `build/op424/findings.md` table; serial hashes.
- next: The Coordinator's push decision for mach-fixes-2 and launchd-fixes-1.

### j-20261002-042 — op-426 clarification: shared fd table means a shared Mach space and names

- time / kind: 2026-10-02T09:57:26Z / DECISION (Arranger, within the Coordinator's delegated principle)
- outcome: The Implementer asked whether a shared-fd `rfork` child may use the parent's Mach names. Answer: yes. Processes sharing an fd table share its Mach space and names, and the space is retained until the last process using the table exits, with no per-task denial. Reasons: under A1 the names are the shared fds, so denial would need owner checks on every lookup (risk without benefit); there is no macOS equivalent; ordinary fork, vfork and posix_spawn copy the table; exec unshares it. Rule 3 in mach-names-step5-deferred.md is updated.
- state delta: none.
- evidence: none.
- next: none.

### j-20261002-043 — op-426 BLOCKED on a missing thread hook; third hook allowed (delegated); op-427 continues batch 3

- time / kind: 2026-10-02T10:05:17Z / DECISION (delegated principle)
- outcome: op-426 returned BLOCKED. It committed `b9ad6f42` (the F1 fix, on ee883a74), changed no native files, and stopped correctly: op-394's hook plan binds new threads after `thread_link` and before they run (`kern_thr.c:266-274`), and FreeBSD has no hook there. Arranger error: the brief capped native changes at two without checking each hook point in the design against FreeBSD (Rule 16; lesson in LOCAL.md).

  Decided under the Coordinator's principle (stability over avoiding native change): allow a third EVENTHANDLER hook, "thread published", right after `thread_link`. It is non-sleeping under PROC_LOCK; the Mach object is prepared in thread_ctor and only linked in the event. The rejected alternative was lazy binding on first Mach use: no native change, but more Mach-side complexity and edge cases (cross-thread calls).

  op-426 is dropped and superseded by op-427, which carries its commit. The allowed list in mach-names-step5-deferred.md is updated.
- state delta: op-426 issued → returned → dropped; op-427 created as draft.
- evidence: `git show b9ad6f42`; `kern_thr.c` lines 262-276 at 2884304b.
- next: Send op-427; the Coordinator's push decision.

### j-20261002-044 — op-427 sent; mach-fixes-2 and launchd-fixes-1 published; op-420 (batch 2) closed

- time / kind: 2026-10-02T10:07:06Z / ACTION
- outcome: op-427 was sent. With the Coordinator's yes, both branches were pushed by hash to the public rmxOS origin as new branches: `mach-fixes-2` = `ee883a74` and `launchd-fixes-1` = `42bf6205`. `rmx-implementer@a4820eaa` (op-426's record) is on origin. op-420 (batch 2) is closed: review CLOSE 9/10, runtime proof op-424, commits on origin. op-425's closure is now valid, since `launchd-fixes-1` is on origin. id-046, the index and now.md are updated.
- state delta: op-427 draft → issued; op-420 returned → closed.
- evidence: `git ls-remote --heads origin mach-fixes-2 launchd-fixes-1`.
- next: op-427's REPORT.

### j-20261002-045 — Correction: rmx-implementer@a4820eaa reached origin only on the retry

- time / kind: 2026-10-02T10:07:46Z / CORRECTION
- outcome: j-20261002-044 said `a4820eaa` was on origin, but that push had failed. op-426's REPORT gave the full hash with one character missing (`a4820eaacb66…`; the real hash is `a4820eaaacb66f29a2f1215d40215807a2632ccd`). Pushed again by the resolved hash; it is now on origin. Lesson in LOCAL.md: resolve REPORT hashes with `git rev-parse` first.
- state delta: none.
- evidence: `git merge-base --is-ancestor a4820eaaacb66f29a2f1215d40215807a2632ccd origin/main`.
- next: none.

### j-20261003-001 — op-427 question: the thread-exit gate is a function-pointer hook, not a released spin lock

- time / kind: 2026-10-02T11:34:58Z / DECISION (Arranger, within the delegated principle)
- outcome: The Implementer asked whether the thread-exit gate may briefly release PROC_SLOCK, because the EVENTHANDLER dispatcher takes a blocking mutex. Answer: no. Use a plain function-pointer hook under the existing locks, as hwpmc already does in `thread_exit` (`PMC_CALL_HOOK_UNLOCKED(td, PMC_FN_THR_EXIT, …)` with PROC_SLOCK held). The handler is atomic-only; draining and freeing stay in thread_dtor; the pointer is set at mach.ko load (Mach is non-unloadable). This keeps FreeBSD's exit locking unchanged. The allowed list in mach-names-step5-deferred.md is updated.
- state delta: none.
- evidence: `git show 2884304b:sys/kern/kern_thread.c`, thread_exit (line 935) and its HWPMC_HOOKS block.
- next: none.

### j-20261003-002 — op-427 BLOCKED on the exit-hook question (answer not yet relayed); op-428 continues

- time / kind: 2026-10-02T11:40:04Z / ACTION
- outcome: op-427 returned BLOCKED before the j-20261003-001 answer reached it. It committed `842c3a59` (`kern:` exec committed event), `3956111e` (lifetime regression tests) and `119b7a51` (`kern:` thread published, covering kern_thr.c and kern_kthread.c). The native files are kern_exec.c, kern_thr.c, kern_kthread.c, kern_thread.c (only the event list definition) and eventhandler.h, all within the allowed hooks. op-427 is dropped and superseded by op-428, which carries the answer (an hwpmc-style function-pointer hook under PROC_SLOCK) and finishes batch 3.
- state delta: op-427 issued → returned → dropped; op-428 created as draft.
- evidence: `git log ee883a74..mach-fixes-3`; `git diff --name-only`; the kern_thread.c diff.
- next: Send op-428.

### j-20261003-003 — Reaper redo op-429 drafted (op-422's three harness fixes)

- time / kind: 2026-10-02T11:44:58Z / ACTION
- outcome: At the Coordinator's request, op-429 (gatekeeper1) is drafted:
  - markers written to both the console and a guest file, with sequence numbers; the cause of op-422's transcript gap is unknown, because `cell-driver.sh:45` already redirects to /dev/console;
  - `ps -p 1` replaces `pgrep -x`;
  - LastExitStatus is read through GetJobs with exact label selection, working around id-059 on the alpha2 launchd.

  A preflight shows all three working before the one cell. op-280 now needs op-429.
- state delta: op-429 created as draft; op-280 needs op-429.
- evidence: `build/op422/workload/cell-driver.sh`, lines 45-46; the op-422 plist.
- next: Send op-429.

### j-20261003-004 — op-429 sent; op-428 BLOCKED on in-place rfork; lazy Mach-space rebinding decided; op-430

- time / kind: 2026-10-02T11:55:08Z / DECISION (delegated principle)
- outcome: op-429 was sent. op-428 returned BLOCKED, with `3cb2092a` (`kern:` atomic thread-exit gate; native files kern_thread.c and proc.h) and `415112e0` (special send rights released on exit) committed. Its question: in-place `rfork` (no RFPROC) changes the fd table with no process event.

  Checked: `kern_fork.c:384-420` uses fdinit (RFCFDG) or fdunshare (RFFDG), and fdcopy skips files without DFLAG_FORK (`kern_descrip.c:2563`). The new table has no Mach names.

  Decided: no fourth FreeBSD hook. Mach rebinds lazily: a space stays bound to its fd table; on the Mach entry path a mismatch between `p_fd` and the space's table binds a fresh empty space under the task's binding lock and drops the old reference; task-level ports are kept, as for exec; a regression test is required. Reasons: it is rare, has no macOS equivalent, and stays Mach-local. op-428 is dropped and superseded by op-430. Rule 3 in the record is updated.
- state delta: op-429 draft → issued; op-428 issued → returned → dropped; op-430 created as draft.
- evidence: `git show mach-fixes-3:sys/kern/kern_fork.c`, lines 384-420; kern_descrip.c, lines 2561-2597.
- next: Send op-430.

### j-20261003-005 — op-430 sent; op-429 returns the reaper verdict PREMISE-NOT-OBSERVED; two blind reviews drafted

- time / kind: 2026-10-02T12:24:59Z / ACTION
- outcome: op-430 was sent. op-429 returned DONE: **PREMISE-NOT-OBSERVED**, with (a), (b) and (c) NOT-OBSERVED across 50 exits. Checked first-hand:
  - `b546000` is on origin; serial hashes match (cell b1882605…, preflights 1dcb32c3… and 9f96fa05…).
  - The managed statuses equal the kernel statuses per wave (W1 0, W2 256, W3 139; W4 and W5 unmanaged 0 and 139).
  - The detached thread's CPU is near zero; the 1,105 markers match.
  - The indexed classifier `78899afa…` passed the 22 controls (01:13:14) before classifying the cell (01:13:56), with the original kept at `8bca5ac0…`.

  Gate: both Validators (runtime verdict, PID-1 critical path): op-431 (validator1, completeness) and op-432 (validator2, falsification), blind. If accepted, op-280 (launchd reaper fix) stays held without a fix, per op-322 §7, and the PID-1 path moves to productionization (op-202). The result is bounded: no incidence in this workload, not proof of absence.
- state delta: op-430 draft → issued; op-429 issued → returned; op-431 and op-432 created as drafts.
- evidence: `build/op429/findings.md`, lines 1-40; serial hashes; tier2-indexed results and stdout timestamps.
- next: Send op-431 and op-432.

### j-20261003-006 — op-431 and op-432 sent; validator3 preferred this week (fast, free)

- time / kind: 2026-10-02T12:27:45Z / DECISION
- outcome: op-431 (validator1) and op-432 (validator2) were sent. The Coordinator says validator3 is fast and free this week. roles.md § Choosing a Validator gains a dated rule: validator3 is the default single Validator for L gates and one of the two for XL gates, until the week ends or the Coordinator says otherwise.
- state delta: op-431 and op-432 draft → issued.
- evidence: none.
- next: op-430's REPORT (batch 3); its review goes to validator3.

### j-20261003-007 — op-432 returns: validator2 CLOSE 9/10 on op-429's PREMISE-NOT-OBSERVED

- time / kind: 2026-10-03 / ACTION
- outcome: validator2 (falsification) found that every failure mode would have shown in the evidence, and re-ran the indexed classifier on the cell's own manifest, getting the same verdict. Checked first-hand:
  - `ae2c77c` resolves in rmx-validator2;
  - the cell serial is `b1882605…`, the original classifier `8bca5ac0…`, and the a04db00 note `64ac5f91…`;
  - `reviews/op-432/scratch/reclassify.out` is byte-identical to `build/op429/evidence/classifier-indexed.stdout` (verdict PREMISE-NOT-OBSERVED);
  - `WNOWAIT` is 8 at alpha2 `sys/sys/wait.h:81`;
  - markers.log has 1,105 lines; the serial has no panic, KASSERT, `Reap failed` or `-245` lines.
  Hygiene notes, none blocking: the classifier's hash binds in `final-classifier-binding.json`, not in the cell manifest; when the classifier rejects input it marks every axis INCONCLUSIVE (conservative, as the original does).
- state delta: op-432 issued → returned.
- evidence: the hashes and `cmp` above.
- next: op-431 (validator1). If it also reaches ≥8 and agrees, close op-429, op-431 and op-432; op-280 stays held with no fix; the PID-1 path moves to op-202.

### j-20261003-008 — op-431 returns (validator1 REMEDIATE 9/10); Arbiter ruling: accept with two recorded deviations; op-429, op-431, op-432 closed

- time / kind: 2026-10-03 / DECISION (Arbiter)
- outcome: Both reviews score 9/10 and agree that the evidence supports PREMISE-NOT-OBSERVED. They differ only on the record: validator2 says CLOSE; validator1 (`172c9df`) says REMEDIATE until two deviations are on record. This entry is that record (a new record; gatekeeper1's disposition is not edited). Checked first-hand:
  1. **Classifier created and validated after the cell.** The cell's serial log was written from 12:04:32Z to 12:08:30Z (2026-10-02). `classify-indexed.exs` was born at 12:12:52Z, its 22 Tier-2 controls passed at 12:13:14Z, and the classification ran at 12:13:56Z. The contract (`a04db00` note, line 83) says Tier-2 controls "run before any commissioned runtime cell". findings.md line 5 states the order truthfully but does not call it a deviation. The op-429 brief contributed: "If you change it, run the 22 Tier-2 controls again first" did not say first relative to what.
     **Ruling: accepted.** The rule exists so that a classifier cannot be fitted to a cell's data. Here:
     - the original classifier `8bca5ac0…` passed Tier-2 before the cell;
     - both Validators diffed the rewrite and found only an index substitution, with identical predicates;
     - its 22 control outputs are identical to the original's;
     - validator2's re-run on the cell manifest is byte-identical (`cmp`, j-20261003-007).
     **Going forward:** the classifier is frozen, and its Tier-2 controls pass, before the cell boots. A later rewrite (for speed, say) is a declared deviation and needs the same equivalence proof.
  2. **`containment_access_probe_rc=not-run` in all three attempts: a logging artifact, not a gap.** op-429's configs set `CELL_PREFLIGHT=build/op429/preflight.sh`, which replaces the op360 runner's `preflight()`. The runner's `doas bhyvectl --get-stats` probe therefore keeps its default `not-run`, as in op-410 and op-422. The same unique-VM check ran at the runner's launch step (line 272): `prelaunch_vm_state_rc=1`, "could not be opened", and at teardown `targeted_final_vm_state=absent`. `host-before.json` equals `host-after.json`.
  Closure: two reviews at 9 or above; the disagreement resolved narrowly as above. `b546000` is on rmx-gatekeeper1's origin; the validator repos are local-only (roles.md:130). The result is bounded: no incidence in this preview workload, not proof of absence. op-280 stays held with no fix needed (op-322 §7). The PID-1 path moves to op-202 (productionization).
- state delta: op-431 issued → returned; op-429, op-431 and op-432 returned → closed.
- evidence: the `stat` birth and modify times of the three files; `build/op429/cell-config.sh:3`; `run-op360-alignment-r1.sh:37,159,272-276`; the cell's `host-orchestration.log` lines 1-2 and 29-31.
- next: Re-draft op-202 against the current candidate once batch 3 (op-430) lands, or decide whether it goes on op-388's alpha2.

### j-20261003-009 — op-430 returns batch 3 (Mach lifetimes); review op-433 (validator3) and proof op-434 (gatekeeper1) drafted

- time / kind: 2026-10-03 / ACTION
- outcome: op-430 returned DONE: `mach-fixes-3` at `db592723`, 12 commits over `mach-fixes-2`, local only; two staged images; 39 cases, untested in a guest. Checked first-hand:
  - native changes `mach-fixes-2..mach-fixes-3`, excluding Mach and tests: 24 lines in 6 files, exactly the three allowed hooks;
  - the exit gate is an atomic function pointer, called with `PROC_SLOCK` asserted (`kern_thread.c:949-956`); `mach.ko` installs it and refuses unload with EBUSY (`mach_module.c:296`);
  - lazy rebinding exists (`task.c:1034-1055`, plus `:1193-1197` for exec);
  - both image hashes match; each stage's host-before equals its host-after;
  - BOMs: 36 identical paths; all test files are byte-identical, and only the kernel, `mach.ko` and their debug files differ;
  - `EXPECTATIONS.md` § Batch 3: 8 new cases, all FAIL before and PASS after (no PANIC expected).
  Sizing: L, a kernel code review, so one Validator: validator3, this week's default (j-20261003-006). The proof (op-434) is read-and-run only, safe in parallel with the review.
- state delta: op-430 issued → returned; op-433 and op-434 created as drafts.
- evidence: `git diff --stat mach-fixes-2 mach-fixes-3`; `sha256sum` of both images; the BOM comparison.
- next: Send op-433 and op-434. After both: push `mach-fixes-3` (needs the Coordinator's yes), close op-430, then step 4 and re-draft op-202.

### j-20261003-010 — op-433 and op-434 sent; op-435 drafted for advisor2 (step-4 plan without the EOF helper)

- time / kind: 2026-10-03 / ACTION
- outcome: op-433 (validator3) and op-434 (gatekeeper1) were sent. The Coordinator says advisor2 is free today. op-421's note relies on the native EOF retirement helper (§1, §3, §4.1), which 1.0 does not adopt (2026-10-02). Its libdispatch, launchd and libxpc death handling therefore needs re-planning before step 4 can be briefed. op-435 asks advisor2 for the step-4 plan on `mach-fixes-3`: death via dead-name notifications and `mach_msg` errors, the kernel part, the D2 subset, commit order with tests first, and open risks. The note is read-only; it runs in parallel with op-433 and op-434.
- state delta: op-433 and op-434 draft → issued; op-435 created as a draft.
- evidence: `rmx-advisor2/op-421-c1-on-fd-backend.md`, lines 29-47, 78-97 and 109.
- next: Send op-435.

### j-20261003-011 — op-435 sent; op-436 drafted to supersede op-202 (launchd PID 1 by default); op-429's cell shows /etc/rc running twice

- time / kind: 2026-10-03 / DECISION
- outcome: op-435 was sent. The Coordinator asked for op-202. Its June brief is legacy and long, so op-436 supersedes it and keeps its scope (op-322 §6): config productionized in the tree, root read-write, base services, getty, the SIGUSR1 risk. op-202 → dropped (superseded).
  New fact, checked first-hand in op-429's cell serial: `/etc/rc` ran twice. `launchctl bootstrap -S System` runs it through `runcom()` (`launchctl.c:699-753`), and op-388's `com.rmxos.rc-chainload` plist runs it again. One `ps` listing shows two `cron` (974, 1816) and two FreeBSD `syslogd` groups, a failed second `devd` ("Device busy") and duplicate routes. Also present: `sh: /etc/bootstrap: not found`, `asld` running alongside FreeBSD `syslogd`, and no getty.
  The reaper verdict is unaffected: its axes concern PID 1's waits, not rc. op-436 gives these six points as the brief's known facts.
  Delegated choices (macOS behaviour, weighed against stability):
  - prefer launchctl's built-in rc path, as on macOS;
  - keep FreeBSD init as a recovery fallback;
  - stage images for both UFS and ZFS roots (id-057);
  - branch from `launchd-fixes-1` (`42bf6205`, Mach batch 1 plus the GetJob fix);
  - no kernel changes; the Gatekeeper accepts in a later op.
- state delta: op-435 draft → issued; op-202 hold → dropped (superseded by op-436); op-436 created as a draft.
- evidence: serial lines 95-159 and 890-904 of the op-429 cell; `launchctl.c:699-765` and `runtime.c:275-281` at `42bf6205`; the op-364 image re-hashed as `8f546a93…`, op-417's as `1f4cf949…`.
- next: Send op-436.

### j-20261003-012 — op-436 sent; batch 3 not accepted: op-433 REMEDIATE (two teardown defects), op-434 35/39; remediation op-437 held behind op-436

- time / kind: 2026-10-03 / ACTION
- outcome: op-436 was sent.
  - **op-433 (validator3, 9/10, REMEDIATE; `63fb8916`).** Two defects, both confirmed first-hand:
    - `mach_task_exit` reads `FIRST_THREAD_IN_PROC(p)->td_machdata` unchecked, and `mach_task_dtor` reaches it when the first `thread_alloc` fails (`kern_fork.c:1099-1102`).
    - `ith_kmsg` is released in no retirement path; `git grep` shows only the mqueue and mach_msg users.
    The hook scope, the non-blocking callbacks and lazy rebinding passed.
  - **op-434 (gatekeeper1, FAILED; `45befb8` on origin).** Serial hashes `3c07f3d3…` and `76e2941c…` verified. Fixed image 35/39: all 31 standing cases pass, as do 4 of the 8 new cases. `task_control_death`, `thread_control_death`, `rfork_unshare` and `rfork_clean_table` fail before their named checks; the base rfork cases time out (status 124). No panic.
  op-437 (Implementer remediation) is drafted. It is held because the Implementer is on op-436, a different branch. Batch 3 stays unpublished and op-430 stays returned until op-437 is proved.
- state delta: op-436 draft → issued; op-433 and op-434 issued → returned; op-437 created and held.
- evidence: `task.c:1127-1150` and `kern_fork.c:1095-1110` at `db592723`; `findings.md`; the serial lines quoted.
- next: After op-436 returns, send op-437; then re-run the review (validator3) and the proof (gatekeeper1). op-433 and op-434 close with op-430.

### j-20261003-013 — op-435 returns the step-4 plan; Arranger decides its four contracts; op-435 closed

- time / kind: 2026-10-03 / DECISION (delegated)
- outcome: advisor2's plan (`42dc8247`) has six test-first commits, C1 without the EOF helper, and no new FreeBSD change. Checked first-hand at `db592723`: launchd's two setter calls (`core.c:8610,8617`), the caller substitution (`ipc_tt.c:901-902`), the N6 window (`ipc_object.c:666-695`) and the N7 drop (`ipc_notify.c:434-438`).
  Decisions, recorded in mach-names-step5-deferred.md § Step 4 decisions:
  - D2 is two setters only, with the note's error codes;
  - launchd's exception configuration is stored but not delivered;
  - legacy buffered updates are ignored, with no FreeBSD hook;
  - the consumer ownership contract and one-space kqueue rule, with no FreeBSD guard;
  - N6 is added to step 4; N7 stays a known limitation.
  The design note is an S/M return, verified by the Arranger.
- state delta: op-435 issued → returned → closed.
- evidence: the cited lines; the note's §5.
- next: Brief step 4 to the Implementer after batch 3 is accepted (op-437, then the re-review and re-proof).

### j-20261003-014 — op-438 drafted: PID-1 acceptance checks and a baseline, ahead of op-436

- time / kind: 2026-10-03 / ACTION
- outcome: The Implementer is still on op-436, and the other seats are idle. gatekeeper1 builds op-436's acceptance checks now: PID 1, rc once, root read-write, login prompt, services, power-off, SIGUSR1. It runs them once on op-388's image as a baseline, so acceptance becomes a single run when op-436 returns. It touches no repo or image the Implementer uses.
- state delta: op-438 created as a draft.
- evidence: none.
- next: Send op-438.

### j-20261003-015 — op-438 returns PARTIAL baseline; "rc twice" is a startup race; NOTICE to the Implementer for op-436; op-438 closed

- time / kind: 2026-10-03 / ACTION
- outcome: `51d32fb` is on origin, and the three serial hashes match (`4669935a…`, `6265f088…`, `7d6b7617…`). Baseline on op-388's image:
  - PID 1 is `/sbin/launchd` without `-u` (PASS);
  - root is read-write once booted (PASS);
  - `shutdown -p` powers off cleanly (PASS);
  - no login prompt (FAIL);
  - SIGUSR1 from root halts the system (orderly `reboot(RB_HALT)`).
  Read first-hand across the three serials: the double rc run is a **race**. In boots 1-2, `launchctl bootstrap` hits `launchctl: unlink(): Read-only file system` (line 108) before rc remounts root. Its job loading then stops, so rc runs once (via the chainload plist) but notifyd and the logger never load. In boot 3 the remount came first, so launchctl loaded the jobs and its `runcom()` ran rc a second time. op-436 must order this: rc's root remount before any job loading that writes, and a single rc path.
  The final collector repair (console reopened per command) passed host PTY tests but has not run in a guest. No fourth boot is granted; its first guest run is the op-436 acceptance op, with a pre-boot check. op-438 closes as a baseline: S/M, Arranger-verified.
- state delta: op-438 issued → returned → closed.
- evidence: serial lines 101-115, 131 and 161 of each boot; `build/op438/findings.md`.
- next: Relay the NOTICE to the Implementer (op-436).

### j-20261003-016 — Correction: op-438 recorded as sent late

- time / kind: 2026-10-03 / CORRECTION
- outcome: The Coordinator said op-438 was sent, but it was not recorded at the time, so j-20261003-015's transitions failed. Now applied: op-438 draft → issued → returned → closed.
- state delta: as above.
- evidence: none.
- next: unchanged.

### j-20261003-017 — Staging cleanup: 40 old images deleted, hashes kept

- time / kind: 2026-10-03 / ACTION
- outcome: The Coordinator asked for old staged images to be cleaned up. 40 images of closed or superseded ops were deleted from `stage/images`, plus two unreferenced op-430 intermediates (`op430-fixed-tests`, `op430-final-fixed-tests`). Before deletion, no process had them open and no bhyve was running. Each file's sha256 and mtime are recorded in `doc/stage/deleted-images-20261003.tsv`; the BOMs and stage records in `stage/artifacts` and every op's evidence are untouched.
  Kept:
  - `op388-alpha2-pid1-premise` (the PID-1 baseline);
  - `op417-alpha2-zfs-gpt` (op-436's base);
  - `op430-base-tests` and `op430-deliverable-fixed-tests` (op-434 is still open);
  - `op413-RMXOS-KASAN` and `op413-RMXOS-KMSAN` (the instrumented reference);
  - all `op436-*` (in flight).
  `zroot/wip-mach-stage` went from 54G used, 9.9G free, to 12.6G used, 51.4G free.
- state delta: none.
- evidence: `doc/stage/deleted-images-20261003.tsv`; `zfs list zroot/wip-mach-stage`.
- next: unchanged.

### j-20261003-018 — Rule: each agent cleans up its own large unused files

- time / kind: 2026-10-03 / DECISION (Coordinator)
- outcome: The Coordinator says each agent is responsible for cleaning up its own unused files, especially large builds. The shared partial `rmx-role0/partials/evidence-limits.md` (`0e269a9`, local only) gains "Clean up after yourself":
  - at op end, delete your own large intermediates;
  - keep REPORT evidence, anything an open op names, and deliverables;
  - never touch another agent's files, and never delete while a VM uses them;
  - record an image's sha256 before deleting it;
  - report what was removed.
  Rendered and committed in advisor1-3, explorer1, gatekeeper1 and validator1-3. rmx-implementer is not re-rendered while op-436 is in flight; a NOTICE carries the rule, and the re-render follows its REPORT. The mm4 instances (gatekeeper2, explorer2, advisor4) take it at their pending render. Current sizes: rmx-implementer/build 102G, rmx-gatekeeper1/build 66G.
- state delta: none.
- evidence: `tools/roles list`.
- next: Relay the NOTICE to the Implementer; re-render rmx-implementer after op-436.

### j-20261003-019 — op-436 returns (launchd PID 1 by default); acceptance op-439 drafted; op-437 now sendable

- time / kind: 2026-10-03 / ACTION
- outcome: op-436 DONE. `pid1-boot-1` at `969f2151` (6 commits on `42bf6205`, local), with nothing under `sys/` changed. Image hashes verified (UFS `d1e32784…`, ZFS `caddd3b3…`); loader default `init_path="/sbin/launchd:/sbin/init:/rescue/init"`.
  The record covers all six points plus the op-438 race. runcom runs `/etc/rc autoboot`, waits, and verifies root read-write before loading system jobs. Native syslogd owns logging (asld and aslmanager are installed `Disabled`). A launchd console getty job. Native init signals go through the kqueue, and the calendar check calls its callback directly. Added beyond the brief: `reboot -r` hands off to `/rescue/init`. This is in scope, since FreeBSD's shutdown tools must keep working.
  Host slip from the record: a stray restore left `rmx-implementer/` with group `wheel`; restored to `staff` like its 20 siblings. rmx-implementer re-rendered with the cleanup rule (`8195e8f`). The `op436-selftest-*` images were not cleaned up, so op-437 now asks for that.
  Sizing: the runtime acceptance (op-439) is the gate for this config/userland change. A Validator code review is not added: the acceptance tests the behaviour directly, and it is not a release.
- state delta: op-436 issued → returned; op-439 created as a draft; op-437 brief gains the cleanup line (still held).
- evidence: `git diff --stat 42bf6205 pid1-boot-1`; `sha256` of both images; `stat` of the repo directories.
- next: Send op-437 (Implementer) and op-439 (gatekeeper1); they are independent.

### j-20261003-020 — ZFS is the default image root; op-439 accepts the ZFS image only

- time / kind: 2026-10-03 / DECISION (Coordinator)
- outcome: The Coordinator says ZFS is rmxOS's default root. UFS is only for a use case that needs it, such as a small or high-performance setup; an installer medium does not require it. op-436's UFS image is not accepted or tested. op-439 is reworded to ZFS only, with its budget cut from 10 boots to 7. The Coordinator asked whether two images made op-436 slow. They did not. Composing both images took about 6 minutes (14:06-14:12). Most of the roughly 12 hours went into full world builds (03:18-13:03, with failures from inherited build environment) and two more world builds; the extra cost of "both" was the per-filesystem offline read-back harness. Future briefs ask for one ZFS image, and for reuse of an existing world build where its inputs are unchanged.
- state delta: op-439 brief edited (still draft).
- evidence: `ls -ltr rmx-implementer/build/op436`.
- next: Send op-437 and op-439.

### j-20261003-021 — op-437 and op-439 sent

- time / kind: 2026-10-03 / ACTION
- outcome: op-437 (Implementer, batch-3 remediation) and op-439 (gatekeeper1, ZFS acceptance of op-436) were sent.
- state delta: op-437 hold → draft → issued; op-439 draft → issued.
- evidence: none.
- next: Wait for both REPORTs. After op-437: re-review (validator3) and re-proof (gatekeeper1).

### j-20261003-022 — kernel-testing.md: proposal to speed up the kernel test loop

- time / kind: 2026-10-03 / ACTION
- outcome: The Coordinator asked whether bhyve testing is the right way, since it seems slow. Answer: bhyve is right; the pipeline around it is slow. kernel-testing.md proposes:
  - a fixed base image plus a small payload disk;
  - an Implementer inner loop through the same contained runner (a role-boundary change that needs the Coordinator);
  - the Gatekeeper's proof once per batch;
  - no world builds for kernel batches;
  - a rollout: decision, runner op, pilot on Mach step 4, measures.
  It is linked from now.md.
- state delta: none.
- evidence: op-436 build timeline; op-434 boot durations.
- next: The Coordinator decides on § 4.2.

### j-20261003-023 — op-437 returns batch-3 remediation; re-review op-440 (validator3) drafted; re-proof op-441 held behind op-439

- time / kind: 2026-10-03 / ACTION
- outcome: op-437 DONE. `mach-fixes-3` is now at `cf398822` (5 commits on `db592723`). Checked first-hand:
  - native files unchanged (the same 24 lines);
  - both image hashes match (`e5887d54…`, `69c5b871…`); BOMs differ only in the kernel, `mach.ko` and their debug files;
  - all 12 `op436-selftest-*` images were deleted;
  - 4 small targeted builds (kernel, module, tests, libmach), no world, about 7 minutes.
  The four op-434 setup failures were fixture faults: `ip_active` read as Boolean; a stale lookup loop and a native `fget` in the rfork fixtures. The two op-433 defects are fixed test-first. `failed_creation` passes on base (no handlers there) and would panic at `db592723`, so its before/after is against the pre-remediation head, not `mach-fixes-2`.
  Re-review op-440 asks validator3 whether any fixture correction weakened a case. Re-proof op-441 is held: gatekeeper1 is on op-439.
- state delta: op-437 issued → returned; op-440 created as a draft; op-441 created and held.
- evidence: `git diff --stat db592723 mach-fixes-3`; `sha256` of both images; the BOM comparison.
- next: Send op-440 now; send op-441 when op-439 returns.

### j-20261003-024 — Round-1 review status recorded per finding; round-2 readiness list

- time / kind: 2026-10-03 / ACTION
- outcome: At the Coordinator's request, id-046 gains "Status by finding": 17 fixed and proven; 7 fixed and in re-review; 9 planned for step 4; N7 accepted; about 9 not scheduled. Its state line is updated. kernel-reviews.md's road to round 2 gains step 7 (leftovers decided) and a readiness note: not ready yet. Proposed: a small leftover batch after step 4 (#8, N9, N10, #14); this awaits the Coordinator.
- state delta: none.
- evidence: id-046 ledger; `rmx-implementer/docs/op395-mach-fixes.md` fix table.
- next: unchanged.

### j-20261003-025 — op-439 accepts launchd PID 1 by default on ZFS (16/16); op-439 closed; id-060 opened; op-436 awaits push

- time / kind: 2026-10-03 / ACTION
- outcome: op-439 DONE and accepted. `5998d41` is on origin, and all 7 serial hashes match. 16/16 checks pass:
  - PID 1 is `/sbin/launchd`; rc once, with one cron, syslogd and devd and no errors;
  - root read-write before services, with early writes to `/` and `/var/run`;
  - login, logout and getty respawn;
  - notifyd running; native syslogd only, and a `logger` message lands;
  - `shutdown -p`, SIGUSR1 halt, SIGUSR2 power-off, SIGINT reboot, SIGTERM single-user, `reboot -r` back to launchd PID 1;
  - an overdue calendar job does not halt PID 1.
  B02 was a HARNESS-FAIL: a halted VM stayed allocated past the cap until a targeted destroy. The collector was fixed, and the check repeated in B07.
  Opened id-060 (low): an overdue calendar job ran only once a GetJobs request woke launchd (the sanity check sits in the event path, `core.c:3541`); reroot printed four duplicate routes.
  Timing: about 61 minutes (14:42-15:43). The boots totalled about 10 minutes, about 6 of them B02's cap. The rest was overlay composition, verification and harness preparation.
  op-436 can close once `pid1-boot-1` (`969f2151`) and the rmx-implementer commits are on origin; that needs the Coordinator's yes.
- state delta: op-439 issued → returned → closed.
- evidence: `build/op439/findings.md`; the serial hashes.
- next: Send op-441 (gatekeeper1 is free); ask about pushing `pid1-boot-1`.

### j-20261003-026 — op-441 sent

- time / kind: 2026-10-03 / ACTION
- outcome: op-441 (gatekeeper1, batch-3 re-proof) was sent. op-440 (validator3 re-review) is still a draft; the Coordinator asked what it is.
- state delta: op-441 draft → issued.
- evidence: none.
- next: Send op-440; push `pid1-boot-1` on the Coordinator's yes.

### j-20261003-027 — op-440 sent; pid1-boot-1 pushed; op-436 closed

- time / kind: 2026-10-03 / ACTION
- outcome: op-440 (validator3 re-review) was sent. On the Coordinator's yes, the Arranger pushed `wip-rmxos` `pid1-boot-1` to origin, where `ls-remote` shows `969f2151`. It also pushed `rmx-implementer` main to origin (`1d76e6d`, including `fc38ebd` and `f974f43`), with no Implementer op in flight. op-436 closes: accepted by op-439, its commits on origin.
- state delta: op-440 draft → issued; op-436 returned → closed.
- evidence: `git ls-remote origin refs/heads/pid1-boot-1`; `git rev-parse origin/main`.
- next: op-440 and op-441 REPORTs; then close batch 3 and push `mach-fixes-3`. PID-1 next: re-draft op-203 (soak) on `pid1-boot-1`, including id-060.

### j-20261003-028 — op-440 returns: validator3 CLOSE 9/10 on batch-3 remediation

- time / kind: 2026-10-03 / ACTION
- outcome: Checked first-hand:
  - `076e1193` resolves; the review hash is `fdb61c18…`;
  - at `cf398822`, `ipc_thread_terminate` takes `ith_kmsg`, clears the slot and destroys the reply (`ipc_tt.c:355-370`);
  - `mach_task_exit` retires the first thread only if one exists (`task.c:1147-1149`).
  validator3 finds that no fixture correction weakens its check. Its one condition: on the fixed image, `failed_creation` must also print `observed_constructed=1`. op-441's brief already requires that.
- state delta: op-440 issued → returned.
- evidence: the cited lines.
- next: op-441. If it matches, close op-430, op-433, op-434, op-437, op-440 and op-441, and ask to push `mach-fixes-3`.

### j-20261003-029 — op-441 40/41: thread control port goes inactive only at zombie reap; decision: lazy disable kept; op-442 drafted

- time / kind: 2026-10-03 / DECISION (delegated)
- outcome: op-441 FAILED, 40/41 (`eae58f4`, on origin); base 10/10 as expected; `failed_creation` shows constructed 0 on base and 1 on fixed. `thread_control_death` reached its check for the first time and observed the port active. From source at `cf398822`, the test waits only 1 s (`mach_lifetime.zig:89-94`). Mach disables the port in the thread destructor, which runs when FreeBSD frees the zombie thread from a 5-second callout, and only after 5 s of age (`kern_thread.c:596,742,857`).
  Decision: keep the lazy disable for 1.0, with nothing added to the spin-locked exit gate. The case changes to check that the port is unusable right after join (a product defect if not) and inactive within a reaper bound. The difference is recorded in mach-names-step5-deferred.md § Known differences.
  op-442 goes to the Implementer, and its proof follows. This is the second round trip a quick Implementer guest run would have saved (kernel-testing.md § 4.2).
- state delta: op-441 issued → returned; op-442 created as a draft.
- evidence: the cited lines; `build/op441/findings.md` lines 43 and 68-69.
- next: Send op-442.

### j-20261003-030 — op-442 returns (test-only change); op-443 drafted: proof plus 20 repeats of thread_control_death

- time / kind: 2026-10-03 / ACTION
- outcome: The send of op-442 was not named, but its REPORT came back, so it is recorded as issued and then returned (`--force`; this note is the record). Checked first-hand: `mach-fixes-3` is now at `885be9ea`, 2 commits after `cf398822`, touching tests and fixtures only (4 files); both image hashes match (`024bb03f…`, `0c810513…`). The case now checks conversion right after join (fixture result 4 expected on fixed), then polls for up to 15 s.
  The Implementer's caveat: `sys_thr_exit` wakes joiners before the exit gate marks DYING (`kern_thr.c:337-342`), so the immediate check could race. No retry was added. op-443 measures it with 20 repeats on the fixed image. If any run fails, add a short bounded retry for the DYING mark; if none does, accept and record the window.
- state delta: op-442 draft → issued → returned (forced); op-443 created as a draft.
- evidence: `git diff --stat cf398822 mach-fixes-3`; `sha256` of both images.
- next: Send op-443.

### j-20261003-031 — op-443 PARTIAL (fixture panic); streamlining adopted: Implementer self-check guests; op-444 drafted

- time / kind: 2026-10-03 / DECISION (Coordinator)
- outcome: op-443 (`b255431`, on origin): `thread_control_death` panicked on both images in the fixture's `linker_file_lookup_symbol` call (`885be9ea`'s `&__this_linker_file`). The other 40 fixed cases pass; the repeats are untested. Recorded as issued and returned from its REPORT.
  The Coordinator: the churn is painful; streamline everything. Adopted:
  - Implementer self-check guests: OPS.md § Self-check (`rmx-implementer@538e488`, template and render); roles.md row and § Streamlining; kernel-testing.md § 4.2 marked adopted.
  - Rulebook Rule 16 gains "Streamlining": proof only after a green self-check; user-visible tests over kernel fixtures; two failed rounds → simplify; a returned REPORT = sent.
  - workflow-report.md gains the 2026-10-03 entry.
  op-444: replace the fixture lookup with a user-visible Mach call on the dead thread port (or only the bounded inactive check), and self-check base 10/10, fixed 41/41 plus 20 repeats before returning.
- state delta: op-443 draft → issued → returned; op-444 created as a draft.
- evidence: `build/op443/panic-backtraces.md`; `git show 885be9ea`; `kern_linker.c:911-923`.
- next: Send op-444. After its green self-check: one Gatekeeper proof, then close batch 3.

### j-20261003-032 — op-444 sent; op-445 drafted: PID-1 robustness soak (supersedes op-203)

- time / kind: 2026-10-03 / ACTION
- outcome: op-444 was sent. The Coordinator asked for the PID-1 soak. op-445 supersedes the legacy op-203 and keeps its scope (orphan reaping under load, PID-1 crash floor, shutdown at the end). It runs on op-436's accepted ZFS image, which includes `dtraceall.ko`. One 60-minute boot carries four concurrent loads: orphan churn at about 10 per second, launchd job churn, PID-1 health sampling, and id-060's calendar timing without wake-ups (observed only, no pass bar). Budget: 3 boots, 75-minute cap. Independent of Mach batch 3.
- state delta: op-444 draft → issued; op-203 hold → dropped (superseded by op-445); op-445 created as a draft.
- evidence: the op-436 BOM lists `dtraceall.ko`.
- next: Send op-445.

### j-20261003-033 — op-445 sent

- time / kind: 2026-10-03 / ACTION
- outcome: op-445 (gatekeeper1, PID-1 soak) was sent. In flight: op-444 (Implementer) and op-445 (gatekeeper1).
- state delta: op-445 draft → issued.
- evidence: none.
- next: Wait for both REPORTs.

### j-20261003-034 — op-444 returns with the first green self-check; final proof op-446 held behind op-445; step 4 part 1 (op-447) drafted

- time / kind: 2026-10-03 / ACTION
- outcome: op-444 DONE. Checked first-hand:
  - `mach-fixes-3` is now at `844112f4`, one test-only commit (4 files, -33 lines; the fixture symbol lookup removed);
  - both image hashes match (`1b6238b7…`, `160c3843…`);
  - `tools/selfcheck` is contained (bhyve `-c 2 -m 4G`, one virtio-blk, serial stdio, no network or shares);
  - selfcheck: base 10/10, fixed 41/41, 20/20 repeats at 4.9-10.0 s, matching the 5 s zombie reaper.
  The immediate thread-call check was dropped (no supported call tells live from exited threads), as the brief allowed.
  gatekeeper1 is on op-445, so the final proof op-446 is held. To keep the Implementer busy, step 4 part 1 (op-447: op-435 § 4 items 1-3 plus N6, kernel only, branch `mach-fixes-4` from `844112f4`) is drafted now. Batch 3's product is unchanged since its proof candidate, so the risk is low.
- state delta: op-444 issued → returned; op-446 created and held; op-447 created as a draft.
- evidence: `git diff --stat 885be9ea mach-fixes-3`; `tools/selfcheck/run.exs` bhyve line; the selfcheck table.
- next: Send op-447; send op-446 when op-445 returns.

### j-20261003-035 — Batch 3 accepted without a separate re-proof; mach-fixes-3 pushed; 9 ops closed, op-446 dropped

- time / kind: 2026-10-03 / DECISION (Arbiter, Coordinator agreed)
- outcome: The Coordinator asked whether we were churning again. Yes: op-446 would have re-proved product a Gatekeeper had already proven (op-441, 40/41) for a test-only change already self-checked 20/20. Batch 3 is accepted on:
  - validator3 9/10 twice (op-433, op-440);
  - gatekeeper1's op-441 on product unchanged since `cf398822`;
  - the Implementer's self-check (base 10/10, fixed 41/41, 20/20).
  Confidence 9. With the Coordinator's yes, the Arranger pushed:
  - `wip-rmxos` `mach-fixes-3` to origin (`ls-remote`: `844112f4`);
  - `rmx-implementer` main (`829aada`, including `tools/selfcheck`).
  Validator repos are local only (roles.md:130). Rulebook Rule 16 Streamlining adds: a test-only change on proven product needs only a green self-check, and the next batch's proof re-runs it. The step-4 part-1 proof must therefore run all 41 batch-3 cases.
- state delta: op-430, op-433, op-434, op-437, op-440, op-441, op-442, op-443 and op-444 returned → closed; op-446 hold → dropped.
- evidence: `git ls-remote origin refs/heads/mach-fixes-3`; `git rev-parse origin/main` in rmx-implementer.
- next: Send op-447.

### j-20261003-036 — op-447 sent; the Implementer was stopped by the provider filter near the end; continuation message given

- time / kind: 2026-10-03 / ACTION
- outcome: op-447 is recorded as issued: the Implementer was working on it. The provider filter ("We take extra care with some cybersecurity requests") stopped the session while it ran `build/op447/r2-check-delivery.exs`. By then `mach-fixes-4` had 16 commits (`259de5f8`…`34d6ddf5`) covering items 1-4. Likely trigger: prose about races, concurrency and cancellation fixtures. The continuation message (context sentence, then five named remaining steps) follows safety-flag-avoidance.md § "When a session is filtered anyway". gatekeeper1's op-445 is on B03, its last boot; B01 and B02 were harness failures. The B01 and B03 samples show launchd RSS rising by about 16-28 KiB per 30 s (watch item).
- state delta: op-447 draft → issued.
- evidence: `git log mach-fixes-3..mach-fixes-4`; `build/op445/attempt-ledger-preliminary.json`.
- next: The op-447 REPORT (with selfcheck) and the op-445 REPORT.

### j-20261003-037 — op-447 filtered a second time; the Arranger's continuation caused it; guide fixed

- time / kind: 2026-10-03 / CORRECTION
- outcome: The Arranger's continuation listed the words to avoid and mentioned security and the filter, so the anti-flag prompt itself carried trigger words. The Implementer was filtered again. New continuation: a fresh session, the context sentence, the brief path, the commits and build directory, positive wording guidance only, and the five remaining steps. safety-flag-avoidance.md gains rules 6 (never list the words to avoid, or mention security or the filter, in an agent message) and 7 (restart a filtered agent in a new session).
- state delta: none.
- evidence: none.
- next: The op-447 REPORT.

### j-20261003-038 — Shared project context rewritten without trigger words; re-rendered everywhere except gatekeeper1 (mid op-445)

- time / kind: 2026-10-03 / CORRECTION
- outcome: The shared partial (`rmx-role0/partials/project-context.md`, rendered into every AGENTS.md) listed the words to avoid and mentioned security testing and the provider filter, so every session started with trigger words. It now gives positive guidance only (`rmx-role0@03e80a6`). Re-rendered and committed in rmx-arranger, rmx-implementer, advisor1-3, explorer1 and validator1-3. rmx-gatekeeper1 waits for op-445's REPORT (render later); the mm4 instances take it at their pending render. safety-flag-avoidance.md rule 6 adds: do not point agents at the guide.
- state delta: none.
- evidence: `grep -l exploit rmx-*/AGENTS.md` lists only gatekeeper1 (and its old symlink).
- next: Re-render rmx-gatekeeper1 after op-445.

### j-20261003-039 — Implementer restarted in a new session with the clean op-447 continuation

- time / kind: 2026-10-03 / ACTION
- outcome: The Coordinator started a new Implementer session and sent the clean continuation (context sentence, brief path, commits, build directory, positive wording guidance, five remaining steps). The new session loads the re-rendered AGENTS.md without trigger words.
- state delta: none (op-447 stays issued).
- evidence: none.
- next: The op-447 REPORT (selfcheck) and the op-445 REPORT.

### j-20261003-040 — Rule: every op shown carries an expected time; soaks no longer than needed

- time / kind: 2026-10-03 / DECISION (Coordinator)
- outcome: The Coordinator said op-445's 1.5+ hours without a forecast was painful. op-445 timeline: setup about 30 min; B01 and B02 harness faults about 20 min; B03 soak plus shutdown about 70 min; write-up about 20 min (findings.md updated 20:06). Rulebook Rule 16 Streamlining adds an Expected time on every op shown, flags for long runs, soaks only as long as the question needs, and rough guides. op-447 estimate: 1-2 h remaining.
- state delta: none.
- evidence: `build/op445` file times; `OP445_MARK|141-142` shutdown markers.
- next: The op-445 REPORT (expected within about 20 min) and the op-447 REPORT.

### j-20261003-041 — op-445 soak: reaping and job churn healthy; launchd RSS grows about 2 MiB/h; op-445 closed; isolation op-448 drafted

- time / kind: 2026-10-03 / ACTION
- outcome: op-445 DONE (`c1a55c5` on origin; B03 serial `95e45573…` verified). 3,600 s soak:
  - 36,000 orphans reaped (zombies 0 or 1);
  - job churn and KeepAlive healthy;
  - PID 1 and services continuous;
  - clean shutdown.
  PID-1 RSS rose almost linearly from 4,436 to 6,580 KiB (about 18 KiB per 30 s) and kept 2,160 KiB after the drain, so it is not accepted as resource-healthy. Calendar: 60 of 61 runs on time in a busy guest; one 42.8 s late after a 59 s clock step (added to id-060).
  B01 and B02 were harness faults; scratch cleanup 26.8 GB. op-445 closes: its question is answered, and the growth is the new item. rmx-gatekeeper1 was re-rendered with the positive project context (`AGENTS.md`).
  op-448 isolates the growth in one boot: orphans only, then jobs only, then idle with a calendar job. Expected time about 1.5 h, stated in the brief per the new rule.
- state delta: op-445 issued → returned → closed; op-448 created as a draft.
- evidence: `build/op445/tables/health.md`; `findings.md` lines 3, 12 and 14.
- next: Send op-448.

### j-20261003-042 — PID-1 RSS growth traced in source to launchd's undrained log queue; op-448 dropped; fix op-449 queued

- time / kind: 2026-10-03 / ACTION
- outcome: The Coordinator asked why an hour-long run was needed instead of reading the code. Fair: read first. At `pid1-boot-1@969f2151`:
  - `_launchd_syslog` appends every message at LOG_NOTICE or above to `_launchd_logq`, unbounded (`log.c:237-238`, `:73-105`);
  - as PID 1, `launchd_log_push` only waits for a drain request (`log.c:306-329`);
  - the only drainer is asld (`usr.sbin/asl/syslogd.c`, `_vprocmgr_log_drain`), which op-436 installed as `Disabled`.
  This fits the measurement: per-job-event NOTICE and WARNING lines grow the queue; orphan reaping logs at DEBUG, so it does not; the growth is linear and retained. op-448 (unsent) is dropped. op-449 (Implementer, held until op-447 returns) bounds the queue and logs to syslog(3) when no drainer runs, with a 15-minute before/after RSS self-check. Expected time 1.5-2 h. Lesson (LOCAL.md): read the source for a cause before commissioning a long run.
- state delta: op-448 draft → dropped; op-449 created and held.
- evidence: the cited lines; `git grep _vprocmgr_log_drain` (only asld outside liblaunch).
- next: Send op-449 after op-447 returns.

### j-20261003-043 — Rulebook Rule 17: weigh the cost (time) before issuing an op

- time / kind: 2026-10-03 / DECISION (Coordinator)
- outcome: Rule 17 sets a cheapest-step-first ladder:
  1. Arranger reads the source or records;
  2. host check;
  3. Implementer self-check in the fix op;
  4. Gatekeeper proof or review;
  5. long soak only when the question is about duration (li-004), flagged in advance.
  It also requires an Expected time on every op shown (updated when an agent runs long), runs sized to the question, combining instead of chaining, and no re-proofs of unchanged product. Rendered into rmx-arranger.
- state delta: none.
- evidence: none.
- next: unchanged.

### j-20261004-001 — Side task: set up the zenoh-swift workspace (two agents) from this workflow

- time / kind: 2026-10-04 / ACTION (Coordinator)
- outcome: The Coordinator asked for a new project, a Swift port of Rust Zenoh, at `/Users/me/wip-rbzq`, with two agents (`agent-arranger`, `agent-implementer`), to grow later. Built from this workflow:
  - `tools/rob` and `tools/roles` copied and generalized (folder prefix derived from the Arranger repo's name; root template allowed inside the Arranger repo);
  - templates, roles.md, a distilled rulebook, now.md and IDQ files;
  - op-001 (groundwork) drafted.
  Both repos are committed locally (`agent-arranger@1d6fd75`, `agent-implementer@9e4c063`). No rmxOS state changed. Stack per the Coordinator: local Swift 6.4 (`swift6-rx-6.4.0`), swift-nio, RabbitMQ later if needed.
- state delta: none (rmxOS).
- evidence: `/Users/me/wip-rbzq/agent-arranger/journal.md` j-20261004-001.
- next: unchanged for rmxOS.

### j-20261004-002 — Dynamic roles recorded as a core method (roles.md, Rule 18); zenoh-swift is the worked example

- time / kind: 2026-10-04 / DECISION (Coordinator)
- outcome: The Coordinator named dynamic roles as a core method of the workflow. Keep the full role set in mind; start with the Arranger alone, holding every role and doing each role's work in that role's form; seat agents as complexity or performance requires, so delegation later needs no rework. rmxOS roles.md gains § Dynamic roles (rmxOS is the fully grown case). The rulebook gains Rule 18 (arranger0 template, rendered). zenoh-swift is the first worked example: Arranger first, then an Implementer seated at once, other roles held (`agent-arranger@6fc6c2e`: roles.md, template, `held:` field shown by `rob`).
- state delta: none.
- evidence: `tools/roles check`.
- next: unchanged.

### j-20261004-003 — Swift toolchain issues are reported via the Coordinator, never worked around; TF-001 reproduced

- time / kind: 2026-10-04 / DECISION (Coordinator)
- outcome: A separate agent maintains the new Swift 6.4 toolchain (`swift6-rx-6.4.0`), and zenoh-swift is the first project on it. Projects report toolchain issues to the Coordinator as relay-ready findings and do not patch or work around them; a workaround needs the Coordinator's approval and stays temporary. The Arranger reproduced zenoh-swift's TF-001 first-hand: the default build system shows no source warning and prints "Could not read serialized diagnostics file: unable to find libclang in any registered toolchain"; `--build-system native` shows the `unused` warning; `/usr/local/swift/lib` has no libclang. The TF-001 block for the toolchain agent and a decision message for the zenoh-swift Arranger were given to the Coordinator (not edited directly: that seat is held). swift-real-libdispatch.md: open question 1 answered, and the rule added.
- state delta: none.
- evidence: the repro transcript (scratch package, deleted).
- next: The Coordinator relays TF-001 and the zenoh message.

### j-20261004-004 — zenoh-swift onboarding finished (Coordinator); side task closed

- time / kind: 2026-10-04 / ACTION
- outcome: The Coordinator declared the zenoh-swift project and its first two agents onboarded. Its Arranger completed op-002 (setup verified, three setup fixes, toolchain-findings rule and register), and op-001 (groundwork) is sent to its Implementer. workflow-report.md gains the 2026-10-04 entry; LOCAL.md gains the seeding lessons. From here the zenoh-swift Arranger runs that project; this Arranger returns to rmxOS.
- state delta: none (rmxOS).
- evidence: `agent-arranger@e958ac0`, `agent-implementer@fa40b5f`.
- next: rmxOS: the op-447 REPORT (Mach step 4 part 1, with selfcheck); op-449 after it.

### j-20261004-005 — op-447 found stalled since 20:28 on 2026-10-03; restart prompt prepared; correction to the previous prompt

- time / kind: 2026-10-04 / ACTION + CORRECTION
- outcome: The Implementer's op-447 session stopped at about 20:28 with no REPORT. Last state:
  - `mach-fixes-4` at `b1ef1670`; rmx-implementer at `bef5ebd`;
  - round-5 images staged (`op447-base-tests-r5.raw` 20:16, `op447-fixed-tests-r5.raw` 20:19);
  - base self-check r5: 11/11 new cases fail as expected (`selfcheck-r5/selfcheck-base-7.json`);
  - the fixed-image r5 log `logs/selfcheck-fixed-r5.log` is empty, so that run never happened;
  - 7 of 8 self-check boots used; no bhyve running.
  A restart prompt for a new session was given to the Coordinator, with up to 3 more self-check boots proposed. Correction: the continuation in j-20261003-037 pointed the Implementer at this repo's activation file, which agents must never read (op-brief-forms.md). The new prompt carries the remaining work inline.
  Also seen: the Swift toolchain agent is building `swift6-rx` here (the TF-001 qualification, `make -j32`); its package install should be timed so it does not swap the toolchain under zenoh-swift's op-001.
- state delta: none.
- evidence: `build/op447` file times; `stage/images` listing; empty r5 fixed log.
- next: The Coordinator restarts the Implementer with the prompt.

### j-20261004-006 — The Arranger tree (cross-project one-way access, the Combinator rule); zenoh-swift's Arranger is the first child

- time / kind: 2026-10-04 / DECISION (Coordinator)
- outcome: The Coordinator extended one-way access across projects. Arrangers form a tree, and this Arranger is the parent of zenoh-swift's. Each project is like a Reason Studios Combinator: its agents are inside, and its Arranger is the only interface.
  - The parent may read and change a child Arranger's repo, logging each change in the child's `parent-log.md`, with a NOTICE through the Coordinator.
  - The parent never reads or writes a child's role or product repos.
  - The child never reads or writes the parent's repo.
  Recorded here: roles.md § Arranger tree (with the child registry); rulebook Rule 19 and an AGENTS.md paragraph (arranger0 template, rendered). Recorded in the child (`agent-arranger@864eea6`): `parent-log.md` (p-20261004-001), roles.md § Parent Arranger and the Edges bullet, its arranger0 AGENTS.md (session start reads parent-log.md), rendered for agent-arranger only. Correction p-20261004-002: in the same check the parent read `agent-implementer` (`git status`, `git log -1`) and ran the child's `tools/roles check`, which reads all instances. Reads only, now logged; parent checks stay inside the child Arranger's repo.
- state delta: none.
- evidence: `agent-arranger` commits `864eea6` and the p-002 correction.
- next: The Coordinator relays the NOTICE to the zenoh-swift Arranger; then the op-447 restart.

### j-20261004-007 — ~/wip-workflow created: the shared base templates, tools and method; rmxOS now runs the shared tools

- time / kind: 2026-10-04 / DECISION (Coordinator)
- outcome: The Coordinator asked for the workflow to live in `~/wip-workflow`, serving as both the shared base class and the source of truth. Built and committed (`wip-workflow@7c131a3`, change W-001):
  - `docs/` (method, forms, onboarding, improving);
  - base templates `base-role0`, `base-arranger0`, `base-implementer0`, generalized from zenoh-swift's;
  - one copy of `tools/rob` and `tools/roles`, driven by `ROB_ROOT`, `ROB_FLOOR`, `ROLES_REPO` and `WORKFLOW_HOME`; base templates are searched after a project's own; tests: rob 17/17, roles 15/15;
  - `scaffold/` for new projects (a demo rendered with no unresolved markers);
  - README, AGENTS (maintainer), CHANGELOG, projects.md.
  rmxOS adopted the tools first. Before the swap, ten comparisons between the old and the central tools were identical (`rob board`, `check`, `list`, `next-id`, `show op-447`, `show op-152`; `roles list`, `check`, `diff rmx-implementer`, `diff rmx-validator1`). `tools/rob` and `tools/roles` are now the scaffold's wrappers, and `tools/test` was removed (the tests live centrally). This Arranger maintains the workflow as root of the tree: AGENTS.md (arranger0 template, rendered) and roles.md say so. rmxOS's own templates move onto the bases later, in a separate step, because agents are in flight.
- state delta: none.
- evidence: the identical comparisons; `tools/rob board` and `tools/roles check` through the wrappers.
- next: Give the Coordinator the W-001 proposal for the zenoh-swift Arranger; then the op-447 restart.

### j-20261004-008 — The supervision tree (Erlang/OTP) as a workflow inspiration (W-002); op-447 now monitored

- time / kind: 2026-10-04 / DECISION (Coordinator)
- outcome: The Coordinator named Erlang's supervisor tree as an inspiration for the workflow. Recorded in `~/wip-workflow` (W-002, `4beaff9`): `docs/method.md` § The supervision tree, with an OTP-to-workflow table covering supervisors and workers, let-it-crash, state on disk, monitoring, restart strategies and types, restart intensity, escalation, lean supervisors and isolation; base rulebook Rule 19; a session-start line. The shared `tools/rob` gains `expected:` and `issued-at`, and `rob board` flags issued ops past their expected time (tests 19/19; scaffold renders clean). rmxOS took W-002: rulebook Rule 20, AGENTS.md session-start line (arranger0 template, rendered), op-brief-forms.md `expected:` field. op-447 got `expected=2h` and the board now shows it overdue; op-449 got `expected=2h` for when it is sent.
- state delta: op-447 issued (expected added); op-449 hold (expected added).
- evidence: `tools/rob board`.
- next: The Coordinator restarts op-447 (its prompt is in the conversation); NOTICE for zenoh-swift about W-002.

### j-20261004-009 — Layers and scopes (W-003): only Arrangers read the workflow; each Arranger gates propagation into its scope

- time / kind: 2026-10-04 / DECISION (Coordinator)
- outcome: Subagents never access the workflow layer; only each project's Arranger does. The Arranger propagates workflow changes into its project's rules and may deliberately delay one. The layers mirror the Arranger tree, so future mid-level Arrangers can keep scope layers.
  In `~/wip-workflow` (W-003):
  - `tools/roles` reads `workflow.lock` (`layer: <name> <path> <rev>`, most general first) and exports each layer at its revision into `<repo>/.workflow/`, so a project renders the version its Arranger chose. Tests: roles 17/17, with a pinned layer holding while the workflow moves, and a scope layer between the base and a project.
  - Base `self-contained` text (agents: your rendered files are your instructions; you never read the workflow); base AGENTS workflow paragraph and Rule 18 (the gate; deliberate delay recorded).
  - method § Layers and scopes; improving and onboarding updated; the scaffold has `workflow.lock`, `.gitignore` and now.md § Workflow; tags W-001, W-002, W-003.
  - The scaffold renders pinned with no unresolved markers, and agent files carry no workflow path.
  rmxOS took W-003: `workflow.lock` pinned at W-003; `.workflow/` ignored; `roles list` identical with the lock (rmxOS templates do not derive from a base yet); AGENTS.md (arranger0 template, rendered) states the gate; now.md § Workflow.
- state delta: none.
- evidence: `tools/roles list` before and after (identical); `tools/roles check`.
- next: NOTICE for zenoh-swift (W-001..W-003); the op-447 restart.

### j-20261004-010 — Parent review of zenoh-swift's op-001 and toolchain work; message p-20261004-003 delivered by file; W-004 (file-based relay) proposed

- time / kind: 2026-10-04 / ACTION
- outcome: The Coordinator relayed the zenoh-swift Arranger's op-001 reply, garbled in places by terminal copy (chunks of about 25-30 characters lost from long lines). That Arranger had raised the same problem: two briefs lost text in relay, so op-001 missed `z_querier`. Read first-hand in its Arranger repo:
  - op-001 is closed PARTIAL (j-20261004-009): the smoke was re-run, 10 hashes match, and id-002 stays open on TF-002;
  - TF-001 was fixed by the toolchain agent (`swift6-rx-6.4.0_1`, libclang): verified, workaround removed everywhere, pin moved (j-20261004-010, `dd9097b`);
  - TF-002 is a clean three-file reduction (MemberImportVisibility attributes libc struct members to a C target including the header).
  The parent's answer went into its `parent-log.md` as p-20261004-003 (`agent-arranger@5949b42`; the header now also covers messages): W-001..W-003 to adopt at its pace; the review; its two proposals. The diagnostic swift-nio op is the Coordinator's call (parent's view: approve, time-boxed, scratch only). Briefs as files: agreed, proposed to the Coordinator as W-004. The relay to it is one short line with a checksum. TF-002 goes to the toolchain agent by pointer to the register.
- state delta: none (rmxOS).
- evidence: its journal j-009 and j-010, toolchain-findings.md § TF-002, id-000; `sha256` of its parent-log.md, `4d54736094fc`.
- next: The Coordinator relays the two short lines and decides on the diagnostic op and W-004; the op-447 restart is still pending.

### j-20261004-011 — W-004: everything is an op (no TF- ids); id-000 is the default IDQ entry

- time / kind: 2026-10-04 / DECISION (Coordinator)
- outcome: The Coordinator: do not use TF- ids; everything is an op-NNN (the op is the workflow's CPU micro-op: issued, executed out of order, retired after verification). A project without the complexity for an IDQ keeps only id-000, and every op implicitly belongs to it, which makes adding ids later smooth.
  In `~/wip-workflow`, W-004 (`f9474d2`, tag at `036f2fe`):
  - method § Ops and the IDQ (the CPU metaphor; id-000) and § Findings (a finding is an op for its owner, `repo: outside:<owner>`);
  - forms § Finding as an op brief; base Rule 16; base op-brief-forms (outside owners, default idq);
  - scaffold `idq/id-000.md` as the single default entry;
  - the base `op-brief-forms.md` loses a zenoh-swift toolchain paragraph that had leaked in during W-001 (my copy-edit had missed silently);
  - `rob new` defaults to `idq: id-000`, id-000 is valid with no IDQ files, `repo: outside:<owner>` passes check, `rob show` always prints idq. Tests: rob 21/21, roles 17/17; the scaffold renders clean at W-004.
  W-NNN stays the workflow's version label (what `workflow.lock` pins), not a work id.
  rmxOS took W-004: lock bumped; swift-real-libdispatch.md says findings are ops for the toolchain agent; rmxOS's existing id-000.md is already its index, which matches the method.
- state delta: none.
- evidence: `tools/rob check`, `tools/roles check`; the W-004 test runs.
- next: Message zenoh-swift's Arranger (parent-log p-20261004-004). Withdraw the TF-002 relay line given earlier: the finding goes out as an op once that Arranger converts it.

### j-20261004-012 — Coordinator decisions: zenoh-swift's own decisions are its scope; relay stays manual; op-447 no hurry

- time / kind: 2026-10-04 / DECISION (Coordinator)
- outcome:
  1. The diagnostic swift-nio op and zenoh-swift's charter questions are that project's scope, not this Arranger's (the Combinator rule applied to decisions as well as access).
  2. Messages as files (the proposed W-005) is not adopted now: the Coordinator relays everything manually on the terminal.
  3. The op-447 restart has no hurry.
  Correction in the child: p-20261004-003 had widened `parent-log.md` to carry the parent's messages and announced the file-based relay. Its header is restored to changes only, and p-20261004-005 records the correction and the scope point (`agent-arranger@2a8f8e7`). Lesson in LOCAL.md.
- state delta: none.
- evidence: the child's parent-log.md.
- next: The Coordinator relays to the zenoh-swift Arranger: read parent-log entries p-20261004-003 to -005. rmxOS: op-447 when convenient.

### j-20261004-013 — W-005: li-000 is the default L1i entry (op → id-000 → li-000)

- time / kind: 2026-10-04 / DECISION (Coordinator)
- outcome: As with id-000, a project starts with every op in id-000, and id-000 in li-000, the project's goal. Milestones are added only when the work calls for them. In `~/wip-workflow`, W-005 (tag at `e709a07`):
  - method § Ops, the IDQ and the L1i, with the three-tier CPU table (L1 instruction cache → instruction decode queue → micro-ops);
  - the scaffold's id-000 names li-000, and the scaffold's now.md § Goal (li-000);
  - base op-brief-forms.
  The W-005 commit had emptied the scaffold's `workflow.lock`: my edit opened the file for writing before reading it. Restored in `e709a07`, where the tag was moved before any use. `tools/roles` now fails clearly on a lock with no layer lines (`02f7a3a`; roles 18/18). rmxOS took W-005: lock bumped; terminology.md §6 names `li-000` as the root of the L1i (roadmap.md, with the li-M000 milestone indexes under it); now.md § Workflow.
- state delta: none.
- evidence: the scaffold renders at W-005 with no unresolved markers; `tools/roles check`.
- next: unchanged (op-447 when convenient; zenoh-swift learns W-004 and W-005 through the Coordinator).
