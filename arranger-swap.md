# Arranger swap protocol

Status: Coordinator-governed seat-control protocol and live continuity record for the two
interchangeable Arranger seats. It governs ownership of the shared control tree; it does not
change the Arranger's product-write, dispatch, adjudication, or retirement authority.

Canonical workspace: `/Users/me/wip-mach/rmx-arranger/`

## Live mutex record

- mutex: **HELD**
- owner: **Arranger1** (Fable)
- epoch: **swap-20260710T091248Z-arranger1**
- readiness: **ACTIVE** — SWAPIN preflight complete. The Arranger2 RECOVERY inventory was reconciled
  first-hand this session (tree parity, live ROB, stale in-flights, ID high-water, bonus seeds);
  residual first-hand checks carried as non-blocking open items (op-171 markers, rmx-arranger2 parity).
- SWAPIN authority: Coordinator directive, 2026-07-10: "you as arranger1 now swapin" — auto-SWAPOUTs
  Arranger2 at the same boundary.
- implied SWAPOUT: **Arranger2**
- last updated: 2026-07-10T09:12:48Z

### Pickup snapshot

- last completed action: executed SWAPIN Arranger1 (recorded mutex handoff, archived the Arranger2
  epoch, set ACTIVE); authored the SWAPOUT meta-op `op-001m` for Arranger2.
- shared tree: `main` at `ddf5663` (`ddf56639efc231908b1df9993400b1e49a412dc6`); `origin/main` an
  ancestor, local `main` 46 ahead, unpushed. Working tree = 143 mixed tracked/untracked entries, live
  state, preserved (no clean/stage/commit/push).
- divergence: **CLEARED first-hand** — `diff -qr --exclude=.git` wip-claude↔rmx-arranger shows only
  canonical-forward drift (AGENTS.md protocol repoint; arranger-swap.md itself; op-258-activation.md =
  my ratified adjudication). No un-migrated wip-claude tail. rmx-arranger is head-of-line. **Frozen-tree
  status (first-hand 2026-07-10):** rmx-arranger2 is ALREADY REMOVED (no such dir). `wip-claude` is the
  SOLE remaining frozen twin — still present + writable, HEAD ddf5663 byte-parallel to canonical, and
  the default cwd of an agent session. **Coordinator decision 2026-07-10: RETAIN `wip-claude` in place
  and writable as a fallback consult channel to the prior session — do NOT chmod/rename/delete it.** The
  one-writer rule is held by DISCIPLINE, not enforcement: canonical `rmx-arranger` is the only writer;
  if `wip-claude` drifts from canonical, flag it (do not silently reconcile).
- live ROB: **authoritative per-op state lives in each `doc/activation/op-NNN-activation.md` header —
  source of truth; do NOT restate per-op status here. On any conflict the activation header wins.**
  In-flight op set: op-270, 272, 276, 278, 279, 280, 281, 282, 283, 284, 286 (+ oracle2 consults
  op-287, 288). Swap-relevant deltas only (ops with an OPEN Coordinator action or just-returned):
  op-285 DONE 2026-07-10 — EDIT LANDED at alpha `778cb07`, Arranger1-verified FIRST-HAND (all 4
  release-scope items confirmed at source: object header @ `xpc_internal.h:110`, connection destructor
  @ `xpc_misc.c:140`/`xpc_connection.c:563`, first-message ordering serialized on the listener recv
  queue, NULL-handler guards). ACCEPTANCE NOT done/claimed (no runtime evidence performed) → authored
  **op-291** [Ready] = the follow-on Gatekeeper 4-part bar (provenance sha-match against fix artifact
  `9854f45…` FIRST, then lifecycle+leak census, named byte-0 re-check, managed-mode drive); Coordinator
  dispatch owed. op-286 authored [Ready], Coordinator dispatch owed; op-284 Returned/premise-confirmed
  (gate closed). op-273 ADJUDICATED 2026-07-10 (Finding A confirmed first-hand → routed to op-289→op-290);
  op-289 authored [Ready], Coordinator dispatch owed (launchd Finding A premise-check).
  Evidence-first gating chains (NOT recorded in the activation headers — keep here): op-281→op-282,
  op-284→op-285→op-291 (libxpc lifecycle: premise-check → edit LANDED → acceptance pass),
  op-279→op-280, op-289→op-290 (launchd Finding A: heal→halt collision),
  op-287→op-288 (oracle2 preview-closure consults, issued 2026-07-10).
- stale [In-flight] reconciled: op-258 = RETURNED / HARNESS-INVALID FAIL (first-hand verified against
  `rmx-gatekeeper/build/op258/`; header edit ratified this epoch; asl leg-4 REMAINS OPEN — do not treat
  green; re-soak owed as op-286); op-171 = stale-SUPERSEDED (orphaned by op-149's base switch to
  wip-rmxos alpha, its NextBSD mach_debug premise dead). Neither is awaited.
- **>>> TOMORROW'S QUEUE (2026-07-11) — 3 UNHANDLED `rmx-oracle/` return docs (found 2026-07-10 by a
  full-dir cross-check; CORRECTS an earlier "burn-down complete" overclaim — the op-NNN-named sweep
  missed non-op-named deliverables). All post-preview, none preview-gating. Do NOT lose these:**
  1. **op-274** (zfs-installer-updater-design.md) — RETURNED-but-UNADJUDICATED: deliverable staged +
     complete (op-277 cited it first-hand), but ROB header STILL reads `[Awaiting]` = same stale-header
     drift as op-273/275/265/277 (missed because filename isn't `op-274-*`). ACTION: verify first-hand,
     adjudicate → almost certainly BANK to a distribution/updater li (op-274 is the ZFS-BE + sealed-base
     OS-distribution design op-277's app-updater roadmap §5-D/A2 leans on), flip the stale header.
  2. **swift-network-rmxos-integration-design.md** — ORPHAN: no owning op, no id, not seeded anywhere.
     ACTION: allocate **id-038**, record the returned design, parent to the swift lane, adjudicate/bank.
  3. **zig-cort-dispatch-integration-design.md** — ORPHAN: no owning op, no id, not seeded. ACTION:
     allocate **id-039**, parent to the cort subsystem, adjudicate/bank.
  (scratch-op273 = op-273 working scratch, NOT a deliverable — leave. oracle-rulebook.md/AGENTS.md =
  infra. Everything else in `rmx-oracle/` IS handled — op-223/225/228/231/244/260/262/263/264/269/271/
  273/275/277/265 all on ROB, terminal, findings routed/banked; verified 2026-07-10.)
- returned consults awaiting adjudication: the 3 above (op-274 + 2 orphans) are the ONLY unhandled
  Oracle returns; queued to 2026-07-11. NOTE: staged
  deliverables in `rmx-oracle/` may still read `[Awaiting]` in their activation headers (drift
  op-273/op-275/op-265/op-277 all had, AND op-274 has it — verify the staged findings file, not the
  header, before treating as pending). (op-269 CLOSED 2026-07-10 → BANKED-CLOSURE; op-273 CLOSED 2026-07-10 →
  BANKED-with-ONE-ROUTED (Finding A → op-289→op-290); op-275 CLOSED 2026-07-10 → BANKED (li-008 seeds,
  no routed fix); op-265 CLOSED 2026-07-10 → BANKED (post-preview li-1000/id-000 design seeds, no
  routed fix; Fact 0(a)/0(b) kernel backbone spot-verified first-hand); op-277 CLOSED 2026-07-10 →
  BANKED (li-2000 flagship-app roadmap seeds, post-preview; A1 launchctl-verb trap spot-verified
  first-hand @ `launchctl.c:89-104`; forward pointers = li-008 modern-verb parity + op-268 reframe);
  all recorded in their activation headers.)
- reserved IDs / high-water: on-disk op-288 / id-037. Meta-op lane: op-001m allocated this epoch
  (meta-ops use a separate `m` lane so they never consume project ROB numbers). op-286 AUTHORED
  2026-07-10 (asl leg-4 re-soak #2, [Ready], dispatch-recommended — was proposed-reserved);
  op-287/op-288 allocated 2026-07-10 (oracle2 preview-closure consults); op-289/op-290 allocated
  2026-07-10 (launchd Finding A evidence-first chain from op-273); op-291 allocated 2026-07-10
  (libxpc lifecycle acceptance Gatekeeper pass, follow-on to op-285's landed edit). **id-038/id-039
  EARMARKED (not yet written) 2026-07-11 for the two orphan Oracle design docs (swift-network →
  id-038, zig-cort-dispatch → id-039) — see TOMORROW'S QUEUE above.** Next free: project op-292,
  id-040 (id-038/039 earmarked).
- pending Coordinator decisions: op-286 DISPATCH (authored/Ready 2026-07-10 — asl leg-4 re-soak #2,
  Gatekeeper session-time); halt/re-scope the CURRENTLY-RUNNING unsanctioned background asl soak
  (survival-only, does not count toward leg-4); op/id number-lane split between the two Arrangers;
  Validator 8-vs-9 threshold ruling; push/checkpoint of the 46-ahead+dirty tree.
  (RESOLVED 2026-07-10: frozen-tree disposition — retain `wip-claude` writable as a consult channel,
  one-writer rule by discipline; rmx-arranger2 already removed.)
- origin/validation blockers: tree unpushed (46 ahead); retirement binds to origin-reachable (Rule 7).
- known evidence gaps: op-258 leg-4 bar UNMET; Validator threshold contradiction; op-171 markers not
  yet re-read first-hand. (rmx-arranger2 parity gap resolved — tree removed.)
- safest next action: hand `op-001m` to the Coordinator to paste to Arranger2 (SWAPOUT). Then resume
  the returned-consult burn-down at op-269 (verify first-hand at wip-gpt/wip-rmxos → route to
  fix/verify or banked-closure).

### Tasks since this SWAPIN

- task-01 **[Done]** — execute SWAPIN Arranger1: record mutex handoff, preflight, reconcile the
  Arranger2 RECOVERY inventory first-hand, set ACTIVE, archive the Arranger2 epoch under Closed epochs.
- task-02 **[Done]** — delivered SWAPOUT meta-op `op-001m` to Arranger2 (normal-form, via Coordinator
  paste). **Verdict returned: SWAPOUT-ACK inactive** (markers `A2_SWAPOUT_ACK`, `A2_INFLIGHT_QUARANTINE
  none`, `A2_TERMINAL`). Arranger2 confirms inactive/read-only; no tool call in flight at the boundary;
  no cross-boundary mutation landed; quarantine: none. Arranger1 retains sole mutex ownership. Swap
  round-trip (SWAPIN Arranger1 + auto-SWAPOUT Arranger2 + confirmation) validated end-to-end.
- task-03 **[Done]** — 1.0-preview burn-down resumed. (a) **op-269 adjudicated → BANKED-CLOSURE**
  (headline verified first-hand at `asl_object.c:272/275` — 0xFFFF truncation → presence-test;
  consumer census clean incl. `aslmanager.c:1400` explicit `ASL_QUERY_OP_EQUAL`; all findings
  donor+ravynos byte-identical; asl post-preview-floor). Carried discrepancy: li-1004 has NO
  standalone file, `li-1000.md:85` status row stale. (b) **Preview-critical pivot (Coordinator
  "your call")**: op-284/op-285 briefs re-verified first-hand against product source — ALL cited
  claims match (`xpc_internal.h:85-93/109-136`, `xpc_connection.c:57-62/84/572-586`,
  `xpc_type.c:133-152/467-474`, `xpc_misc.c:139-177`, `aslmanager.c:1555-1603/1590-1592`); plus a
  sharpened prediction: `xpc_connection.c:585` invokes `peer->xc_handler` UNCONDITIONALLY → NULL-call
  crash if the type check keeps `accept_connection` from installing it. Adjacent note (not scoped
  in): create error paths `:92-95/:99-102` leak conn+queues — fold into op-285 finalization only.
  op-284 handed to Coordinator in normal-form for dispatch; op-285 stays RESERVED.
- task-04 **[Done]** — reviewed oracle2's independent preview-closure plan (proof-closure matrix +
  known-bad/mutation atlas); answered its 8 governance/evidence questions, ALL verified first-hand
  same-day (alpha HEAD dd6e7a8 clean = scan pin NOT candidate pin; canonical = rmx-arranger;
  rmx-gatekeeper exactly 27 unpushed + 33 dirty; core = li-1001…1008 per li-1000:63; op-253 =
  PASS-narrow probe-A with trailer sub-claim unvalidated; threshold ≥9-canonical/≥8-stale
  contradiction Coordinator-pending; today's op-258/269/171/284 state changes enumerated; atlas
  foundation-only). NEW FIND: **li-1012 exists on disk but is MISSING from li-1000's constituent
  table** (dangling index; its build-provenance finding feeds the matrix's freshness columns) —
  flagged to Coordinator. Minted **op-287** (matrix, issued) + **op-288** (atlas, HOLD gated on
  op-287 second-Arranger-review); feedback block handed to Coordinator for paste to oracle2.
- task-05 **[Done]** — gated op-284 return first-hand (commit 4143321; raw serial read, probe source
  read, 8 host libxpc builds hashed): **PREMISE-CONFIRMED partial-bar** — `xpc_get_type` → NULL for
  BOTH connection kinds on the guest; corrected the Gatekeeper's "compiled layout differs"
  hypothesis (single struct def in tree; real finding = guest libxpc sha `6393a714…` matches NO
  host build → deployed-lib provenance UNKNOWN, li-1012 live). Gaps (item-2 lifecycle depth, item-3
  managed-mode drive, uncommitted raw logs, provenance) folded into op-285's acceptance bar — no
  op-284 re-run. op-285 → RELEASE-RECOMMENDED (Coordinator warrant pending). Out-of-scope serial
  observation recorded: kernel `ipc_entry_lookup failed on 0` x9 around launchd -u (op-287
  cross-ref). OPEN QUESTION flagged to Coordinator: an "op-258 ASL soak" is running in the
  Gatekeeper session (~2h15m left, store monotonic, ZERO reclaims past the 500K forced trigger, fd
  flat 37) — under WHICH op and was the harness corrected per the op-258 adjudication's 5 mandatory
  fixes? If uncorrected, the run is pre-invalidated for leg-4 (survival evidence only). Zero
  reclaims past trigger = the op-257 wiring/trigger itself may not fire — a distinct product/config
  question from harness validity.
- task-06 **[Done]** — exercised the Coordinator "your call" warrant on two gated items. (a)
  **op-285 RELEASED** — flipped RESERVED/RELEASE-RECOMMENDED → RELEASED; fix scope FINAL (INTENT
  items 1+2 confirmed + item-3 source-reasoned + NULL-handler guard @ `xpc_connection.c:585`);
  acceptance = the 4-part augmented bar, adjudicated by a FOLLOW-ON Gatekeeper pass (NOT op-285);
  dispatched to wip-gpt in normal-form (below, for Coordinator relay). (b) **op-286 AUTHORED**
  ([Ready], dispatch-recommended) — the asl leg-4 re-soak owed by op-258's HARNESS-INVALID FAIL;
  inherits op-258 SCOPE 1–7, fixes the four verified harness defects, and FRONT-LOADS a
  reclaim-trigger PREMISE-CHECK (known-good control) gating the long soak — driven by the live
  background-run signal (zero reclaims past the 500K threshold ⇒ op-257's reclaim may not fire at
  all, a product/config question distinct from harness validity). RULING on the running background
  soak: unsanctioned + survival-only, does NOT count toward leg-4; op-286 is the authoritative
  re-soak (Coordinator dispatches — soaks consume Gatekeeper session time).
- task-07 **[Done]** — DRY fix on Coordinator direction ("your call"): removed the
  activation-header/swap-file per-op status duplication. Established the source-of-truth split
  explicitly (op state → `doc/activation/op-NNN` headers; id state → `idq/id-000.md`; on conflict
  the activation header wins) and relaxed the §4/§5 pickup-snapshot & CHECKPOINT discipline from
  "carry the full live ROB" (full per-op status restatement) to "reference the activation dir +
  restate ONLY the ops with an open Coordinator action or just-returned, plus the gating chains /
  IDs / decisions / blockers that the activation headers do NOT record." The live-ROB pickup line
  is now a lean pointer. No op state was changed — only where it is (not) mirrored.
- task-08 **[Done]** — resumed the burn-down: **op-273 (launchd scheduled-launch) ADJUDICATED**.
  Discovered its header was stale `[Awaiting]` while the deliverable was staged since 2026-07-06
  (`rmx-oracle/op-273-launchd-scheduled-launch-findings.md`) — corrected the header. Verified
  **Finding A first-hand** at wip-gpt/wip-rmxos @ alpha `dd6e7a8`: calendar self-heal
  `raise(SIGUSR1)` (`core.c:5882`) collides with the donor's init-compat SIGUSR1→RB_HALT handler
  (`runtime.c sighandler_init_compat`→`job_mig_reboot2(root_jobmgr,…)`), reachable on EVERY MIG
  completion (`sanity_check` @ `core.c:3521` = last line of `job_mig_destructor`), type confusion
  silenced by `Makefile:37` — a LIVE system-DOWN failure mode on pid-1. Q1–Q4 SOLID; trivia banked
  as li-008 seeds. ROUTED as an evidence-first chain (mirrors op-284→op-285): **op-289** (Gatekeeper
  runtime premise-check, [Ready], GATES) → **op-290** (RESERVED Implementer decouple-fix). Both
  authored. Coordinator gates op-289 dispatch + the SIGUSR1 init-compat signal-ownership decision.
  id-000.md id-016 row updated with the seed pointer.
- task-09 **[Done]** — burn-down continued: **op-275 (launchd pre-exec child setup) ADJUDICATED →
  BANKED** (stale `[Awaiting]` header corrected). Consult sound + careful (self-corrected a −4/−5
  line drift). NO preview-blocking defect. Spot-verified first-hand at alpha `dd6e7a8`: H2 (io-policy
  silently ENOSYS — syscall 259 `__iopolicysys`=`lkmressys`+`SY_THR_ABSENT` @ `init_sysent.c:331`)
  and H7 (non-root identity-fail = warn-and-run, fatal branch `#if 0`) both CONFIRMED. Findings
  banked as li-008 hygiene seeds + a NON-blocking parity/runtime-check bundle (H2/H3/H7 + Q4
  setpgid-vs-setsid session topology, which feeds the id-016 launchd-as-pid1 question). Flagged: the
  runtime-check items could opportunistically ride op-289's pid-1 boot, but op-289 stays scoped to
  Finding A. Coordinator decides whether to commission the bundle + the H7 non-root fatal-vs-warn
  policy. Next in burn-down: op-265 (workqueue-governor design), then op-277 (openclaw, defer).
- task-10 **[Done]** — burn-down continued: **op-265 (pthread_workqueue governor API design)
  ADJUDICATED → BANKED** (post-preview li-1000/id-000 seeds, NO routed fix, NO preview scope; stale
  `[Awaiting]` header corrected — third of the drift series). Strong API-design consult that correctly
  stays out of preview. Spot-verified the design's pivotal kernel backbone FIRST-HAND at alpha
  `dd6e7a8`: **Fact 0(a)** occupancy counts only ENROLLED threads (`td_twq` via
  `twq_lane_active_adjust` `kern_thrworkq.c:653-700`) + **Fact 0(b)** per-process width budget capped
  by `mp_ncpus`, NO cross-process/loadavg input (`twq_parallelism_limit` `MAX(1,mp_ncpus)` `:279-288`;
  `twq_lane_target_locked` `MIN(requested, limit-higher_pressure)` `:353-368`; loadavg/cross-process
  grep EMPTY). Backbone HOLDS — it makes the design's two headline calls *necessary*: (i) workgroup
  join/leave + recommended-width-query is the right iteration-1 seam (foreign runtime must enroll to
  be counted); (ii) a machine-wide cross-process budget is an iteration-2 KERNEL job, not API-surface.
  Concurred bank-worthy calls: governor-vs-executor = two faces on one pool; ERTS seam = external agent
  (no patch) driving `schedulers_online`; TCM = client (share one budget, cheap cross-runtime
  composability); iteration-1 surface internal/unstable {narrow-hint + width-query + grow-request}. NO
  op routed (post-preview by construction); id-000 initiative may commission the governor surface +
  ERTS-agent shim post-preview at Coordinator's call. Next in burn-down: op-277 (openclaw, defer
  post-preview) + the 3 bonus design seeds needing ids.
- task-11 **[Done]** — **op-285 (libxpc managed-lifecycle fix) RETURNED → EDIT VERIFIED FIRST-HAND →
  [Done]; acceptance authored as op-291.** Coordinator reported the edit committed on alpha as
  `778cb07`. Per Rule 1, verified at product source (wip-gpt/wip-rmxos @ alpha `778cb07`, clean, 1
  ahead of origin/alpha, child of `dd6e7a8`): ALL FOUR release-scope items confirmed AT SOURCE — (1)
  object header `struct xpc_object xc_object` embedded front of `struct xpc_connection`
  (`xpc_internal.h:110`); (2) `xpc_object_destroy`→`xpc_connection_destroy` teardown routing
  (`xpc_misc.c:140`, `xpc_connection.c:563`+, ports/queues/sources drained + finalizer + pending/peer/
  ctor-failure cleanup); (3) first-message ordering — old racy two-`dispatch_async` new-peer path
  REPLACED, accept handler runs inline on listener serial recv queue, first msg via
  `xpc_connection_dispatch_event` only after peer setup returns; (4) NULL-handler guards at every
  delivery site. Build/link (rc 0, `libxpc.so.5` sha `9854f45…`, 200080 B) is the Implementer's own
  claim, NOT re-run by Arranger. Coordinator explicitly did NO runtime/guest evidence → per
  `no_conflate_gating_with_readiness` the landed edit is NOT accepted/green. Authored **op-291**
  [Ready] = follow-on Gatekeeper 4-part acceptance bar (provenance sha-match vs `9854f45…` FIRST, then
  lifecycle+leak census, named byte-0 re-check, managed-mode drive). op-285 header flipped
  RELEASED→[DONE/EDIT LANDED]; chain now op-284→op-285→op-291.
- task-12 **[Done]** — burn-down COMPLETE: **op-277 (openclaw integration strategy, li-2000 flagship
  track) ADJUDICATED → BANKED** (post-preview roadmap seeds, NO routed fix; stale `[Awaiting]` header
  corrected — fourth/last of the drift series). Strong, overclaim-disciplined design consult that
  correctly never gates 1.0: verifies substrate first-hand, marks agent-sourced app-tree claims as
  hypotheses, self-caught the openclaw version skew (2026.4.6/4.29/6.11), holds the op-265 iter-2
  honesty line on cross-process budget. Spot-verified the ONE pivotal product-source finding
  first-hand — the **A1 launchctl-verb trap**: openclaw drives modern launchd2 verbs
  (bootstrap/bootout/kickstart/print/enable/disable) but our `launchctl.c:89-104` only has the legacy
  set {start/stop/load/unload/remove/bootstrap/list/dump/log/help} and our `bootstrap` is the
  `/etc/launchd.d` boot-scan (`:106-108`), not the domain-target verb — CONFIRMED, driver fails
  verb-by-verb; note's P2 rmxos-launchd app-side backend is the right shape. Banked to li-2000; two
  forward pointers for when li-2000 activates post-preview: (i) li-008 launchctl modern-verb parity
  seed (roadmap S6), (ii) op-268 reframe/re-issue prerequisite (held/REJECTED-on-dispatch) before any
  demand-launch reliance. Returned-consult queue now EMPTY except 3 bonus design seeds needing ids
  (zig-cort-dispatch, swift-network, zfs-installer).

### Coordination points

- latest checkpoint: **cp-001** (epoch `swap-20260710T091248Z-arranger1`), 2026-07-10T09:12:48Z,
  through task-01
- latest acknowledged catchup: **none**
- next catchup target: **Arranger2**, through `swap-20260710T091248Z-arranger1/cp-001`

## 1. Vocabulary

- **SWAP** — one serialized transfer of the Arranger seat.
- **SWAPIN** — the Coordinator grants the target seat the mutex. This is the normal command.
- **SWAPOUT** — revocation of a seat's mutex. A SWAPIN automatically SWAPOUTs the previous owner.
- **CHECKPOINT** — a frozen process snapshot published by the active seat while it retains the
  mutex. It is a Markdown coordination point, not a Git commit, tag, stash, or push.
- **CATCHUP** — a read-only synchronization pass by the SWAPOUT seat through one named CHECKPOINT.
  It does not transfer the mutex.
- **epoch** — one seat's uninterrupted ownership interval, identified by
  `swap-YYYYMMDDTHHMMSSZ-arrangerN`.
- **pickup snapshot** — the maintained summary of unresolved work the next seat must verify and
  continue.
- **task journal** — the list of tasks opened since the current epoch's SWAPIN, including completed
  work and exact next actions for unfinished work.

Use `SWAPIN Arranger1` or `SWAPIN Arranger2` as the canonical Coordinator directive. An equally
explicit plain-language directive is valid, but the canonical form avoids ambiguity.

## 2. Mutex invariants

1. At most one Arranger seat is authorized to mutate shared control state.
2. Only the Coordinator can SWAPIN a seat. A seat cannot infer, inherit, or self-grant ownership.
3. SWAPIN and the prior owner's SWAPOUT are one logical event. No outgoing acknowledgement is
   needed and there is no overlap in authority.
4. The Coordinator directive is the authority boundary. The live mutex record is its durable
   reflection, not a second grant.
5. A standalone `SWAPOUT ArrangerN` is used only to leave **no active owner**. It sets the mutex to
   `FREE`; work resumes only after a later SWAPIN.
6. Deprecated workspaces never participate in the mutex. The shared workspace above is the only
   live control tree.
7. CHECKPOINT and CATCHUP do not change the mutex owner or epoch. The SWAPOUT seat remains
   read-only throughout CATCHUP.

This is a cooperative logical mutex. A tool call already executing at the SWAP boundary may finish,
but the swapped-out seat must start no further call and must not use the result to mutate or retire
state. The incoming owner treats any write that lands across the boundary as unverified and
reconciles it first-hand.

## 3. SWAPIN procedure

The incoming seat performs these steps in order:

1. Receive an explicit Coordinator SWAPIN directive.
2. Record the new owner and epoch with readiness `VERIFYING`; record the prior owner as implicitly
   SWAPOUT. This mutex-record update is the sole write allowed before activation preflight because it
   prevents the stale seat from making later writes. It does not authorize issue, adjudication,
   retirement, or ID allocation.
3. Confirm `pwd`, writable workspace root, branch/HEAD/origin relation, and full working-tree status.
4. Read the outgoing epoch's pickup snapshot, task journal, latest CHECKPOINT, acknowledged CATCHUP,
   and the tail after that CHECKPOINT; then read the required governing documents and any changed
   governing lines.
5. Verify the outgoing claims first-hand against the shared tree and exact cited artifacts. A
   journal is a starting hypothesis, never evidence.
6. Carry every unresolved item into the new pickup snapshot. Record discrepancies explicitly; do
   not silently repair or discard them.
7. Set readiness to `ACTIVE` only when ownership, task inventory, live ROB, reserved/high-water IDs,
   blockers, and safest next action are reconciled.
8. Begin task action.

If the prior journal is absent, incomplete, or inconsistent, set readiness to `RECOVERY`. The seat
still owns the mutex, but it may only inspect and repair continuity state until the missing inventory
is reconstructed or the Coordinator explicitly dispositions it.

## 4. Active-seat journal discipline

The active seat maintains this file continuously; SWAPOUT must never depend on a final turn from the
outgoing session.

- Before starting a non-trivial Coordinator task or control-state operation, add it under **Tasks
  since this SWAPIN** as `[Open]` with its objective and intended artifacts.
- Update the entry after every durable decision or mutation. Track task-level facts, not individual
  shell commands.
- Use `[Open]`, `[Waiting]`, `[Done]`, or `[Dropped]` for swap-journal tasks. These local labels do
  not replace ROB status vocabulary.
- For unfinished work, state the exact next action, blockers, relevant paths/commits/evidence, and
  related `li-NNN` / `id-NNN` / `op-NNN` identifiers.
- Keep completed tasks in the current epoch journal so the next seat can see what changed since
  SWAPIN.
- Keep the pickup snapshot current. **Per-op state is NOT restated here — each
  `doc/activation/op-NNN-activation.md` header is the authoritative source of truth for its op's
  status (and `idq/id-000.md` for id state); on any conflict the activation header wins.** At minimum
  the snapshot references the activation dir and carries: the in-flight op set, and — restated ONLY
  for ops with an open Coordinator action or just-returned-awaiting-adjudication — the swap-relevant
  delta; the evidence-first gating chains (which the activation headers do not record); reserved IDs
  and next candidates; pending Coordinator decisions; origin/validation blockers; evidence gaps;
  working-tree state; and safest next action. (Full-status-restatement was dropped 2026-07-10 on
  Coordinator direction — "your call" — to remove activation-header/swap-file drift.)
- Record facts conservatively. Executor reports remain reports until the responsible gate verifies
  them first-hand under the governing rules.
- Publish a CHECKPOINT at each coherent Coordinator-task or op-batch boundary, before a requested
  CATCHUP, before a planned pause/SWAP, and whenever the unshared tail is becoming large enough that
  the other seat would face a difficult catchup.

Immediately before any shared control-state edit, ID allocation, op issue, adjudication, retirement,
commit, or push, re-read the live `owner` and `epoch`. If either differs from the seat's own epoch,
stop: it has been SWAPOUT. Re-check again after long-running commands and before consuming their
results.

## 5. CHECKPOINT and CATCHUP

These are coordination points, not ownership transitions and not Git operations.

### CHECKPOINT — active seat publishes

The active seat appends an immutable, epoch-local `cp-NNN` block under **Checkpoints**. A checkpoint
contains:

- epoch, owner, UTC timestamp, and the last task included;
- concise delta since the preceding checkpoint;
- current pickup snapshot: the in-flight op set + only the ops with an open Coordinator action or
  just-returned (activation headers are authoritative — NOT a full per-op status restatement),
  returned gates, and op/ID high-water or reservations;
- working-tree/branch/origin facts needed to understand the delta;
- unresolved questions, blockers, and safest next action; and
- the exact CATCHUP directive, when one is wanted.

Checkpoint numbers reset to `cp-001` at each SWAPIN; the epoch/checkpoint pair is the unique name.
Once published, a checkpoint is not rewritten except for an explicitly dated factual correction.
New facts go in the live record and the next checkpoint.

### CATCHUP — SWAPOUT seat reads

The Coordinator routes `CATCHUP ArrangerN THROUGH <epoch>/cp-NNN`. The target seat may inspect the
shared tree and run non-mutating checks, but it must not edit files, allocate IDs, issue or
adjudicate ops, retire work, commit, push, or change the mutex record.

The target returns a read-only report to the Coordinator:

```text
CATCHUP REPORT
seat:
active owner observed:
epoch / checkpoint:
tree HEAD and working-state observed:
deltas understood:
pre-SWAPOUT inventory:        # bootstrap only, when requested
questions or discrepancies:
status: CAUGHT-UP | PARTIAL
```

The active seat verifies the report as needed and records the acknowledgement in the live record;
the SWAPOUT seat never writes its own acknowledgement. A discrepancy is advice to the active owner,
not an adjudication or authority transfer. Work after the named checkpoint remains a visible tail
for the next CATCHUP.

Regular CHECKPOINT/CATCHUP pairs reduce the eventual SWAP to the last unshared tail. They do not
relax the incoming seat's activation preflight or first-hand verification duty.

## 6. Automatic SWAPOUT behavior

When the Coordinator SWAPINs the other seat, the old seat is SWAPOUT immediately:

- It performs no final cleanup write, ID allocation, issue, adjudication, retirement, commit, or
  push.
- It does not modify its closed epoch after transfer.
- It may acknowledge that it is inactive, but its continuously maintained journal is the handoff.
- Any unfinished task remains `[Open]` or `[Waiting]`; the incoming seat decides how to carry it
  after first-hand verification.

The incoming seat, not the outgoing seat, closes and archives the prior epoch after verification.
This makes transfer safe even when the outgoing session is crashed, compacted, busy in a tool call,
or no longer reachable.

## 7. Closing and archiving an epoch

After verifying the prior record, the incoming seat:

1. Copies the prior live mutex record, pickup snapshot, and complete task journal verbatim under
   **Closed epochs**.
2. Adds `SWAPOUT at`, `successor`, and any first-hand discrepancy notes.
3. Creates the new live record and carries unresolved tasks into its pickup snapshot. It may use new
   local task numbers; project IDs remain unchanged. Prior CHECKPOINT blocks and CATCHUP
   acknowledgements close with the epoch.
4. Never rewrites a closed epoch except for an explicitly dated factual correction.

Neither SWAP nor CHECKPOINT requires a Git checkpoint. The live shared-tree record is authoritative
even when uncommitted and ahead of Git. Any later commit or push follows the ordinary explicit-path
and Coordinator-authorization rules; it is not part of this protocol.

## 8. Recovery and conflict rules

- **Missing record:** no seat may assume ownership. The Coordinator issues a fresh SWAPIN, and the
  target creates a `RECOVERY` epoch.
- **Ambiguous owner or conflicting directives:** freeze mutations and ask the Coordinator. Do not
  resolve ownership by timestamp inference across separate chats.
- **Stale-seat write:** preserve it, identify the exact diff and tool boundary, verify it first-hand,
  and ask the Coordinator if intent is unclear. Never silently discard shared-tree work.
- **Dirty tree:** treat it as live state. Do not clean, reset, or broadly stage it during transfer.
- **Missing task details:** reconstruct from the full tree, activation artifacts, Git history,
  reports supplied by the Coordinator, and exact external artifacts. Mark what remains unknown.
- **Missed CATCHUP:** continue from the last acknowledged checkpoint plus the visible tail; never
  pretend the inactive seat saw a checkpoint it did not acknowledge.
- **Doctrine conflict:** record the conflict and follow the latest explicit Coordinator ruling. If
  none resolves a consequential decision, hold that decision rather than silently choosing.

## 9. Checkpoints

### cp-001 — initial protocol-aware catchup point

- epoch / owner: `swap-20260710T080933Z-arranger2` / Arranger2
- timestamp: 2026-07-10T08:49:29Z
- through: task-03
- prior checkpoint: none
- delta: Arranger2 SWAPIN automatically SWAPOUTed Arranger1; `arranger-swap.md` now holds the live
  mutex, pickup snapshot, task journal, automatic-SWAPOUT rules, plus non-Git CHECKPOINT and
  read-only CATCHUP rules. `AGENTS.md` points to this file. No project op was issued, adjudicated,
  retired, or allocated during the epoch.
- pickup/ROB/IDs: still `RECOVERY`; Arranger1's pre-protocol inventory, full live ROB, returned
  gates, reservations, and next ID candidates remain unreconciled. Allocate nothing.
- tree: `main` was 46 commits ahead of `origin/main` at swap-in inspection, with a large preserved
  mixed tracked/untracked working set. No cleanup, commit, or push was performed.
- requested catchup:
  `CATCHUP Arranger1 THROUGH swap-20260710T080933Z-arranger2/cp-001`; include the task inventory held immediately before
  SWAPOUT, last completed action, live ROB, returned gates, drafts/readies/queues/holds, reserved and
  next IDs, pending decisions, blockers, evidence gaps, and safest next action.
- after report: Arranger2 verifies it first-hand against the live tree, records discrepancies, and
  changes readiness to `ACTIVE` only after reconciliation.

### cp-002 — Arranger2 orientation prompt

- epoch / owner: `swap-20260710T080933Z-arranger2` / Arranger2
- timestamp: 2026-07-10T08:53:32Z
- through: task-04
- prior checkpoint: cp-001
- delta: prepared a copy-paste orientation prompt covering the canonical shared tree, explicit
  SWAPIN authority, automatic SWAPOUT, owner/epoch guards, write-ahead journal, pickup snapshot,
  non-Git CHECKPOINT, read-only CATCHUP, recovery, and stale-write handling. The prompt is expressly
  non-activating: only a separate Coordinator SWAPIN changes ownership.
- project state: no op was issued, adjudicated, retired, or allocated; the live project inventory
  remains in `RECOVERY` pending task-02.
- requested catchup:
  `CATCHUP Arranger1 THROUGH swap-20260710T080933Z-arranger2/cp-002`, including the pre-SWAPOUT
  inventory requested by cp-001.

### cp-001 — Arranger1 SWAPIN + Arranger2-epoch reconciliation *(epoch `swap-20260710T091248Z-arranger1`)*

- epoch / owner: `swap-20260710T091248Z-arranger1` / Arranger1 (Fable)
- timestamp: 2026-07-10T09:12:48Z
- through: task-01
- prior checkpoint: none (checkpoint numbering reset at this SWAPIN; the cp-001/cp-002 above belong to
  the now-closed Arranger2 epoch)
- delta: `SWAPIN Arranger1` auto-SWAPOUTed Arranger2. The Arranger2 epoch — which never left RECOVERY —
  is archived under Closed epochs. Its previously-unreconciled inventory is now reconciled first-hand:
  tree parity CLEARED (`diff -qr` wip-claude↔rmx-arranger = canonical-forward only), full live ROB
  restored (op-270..op-285, none dispatched), both stale [In-flight] ops dispositioned (op-258 =
  FAIL-ratified, op-171 = superseded), ID high-water op-285/id-037, bonus seeds located in
  `rmx-oracle/`. Readiness set ACTIVE. Authored SWAPOUT meta-op `op-001m` for Arranger2.
- pickup / ROB / IDs: see the live record above. Next free: project op-286 / id-038; meta-op lane at
  op-001m. Nothing dispatched; allocate project numbers only after the Coordinator's number-lane call.
- tree: `main` at `ddf5663`, 46 ahead of `origin/main`, dirty (143 entries), unpushed. No
  clean/stage/commit/push performed.
- unresolved / safest next action: deliver `op-001m` to Arranger2, then burn down returned consults
  from op-269. Carried Coordinator decisions: number-lane split, Validator 8-vs-9 threshold,
  push/checkpoint, frozen-tree disposition.

## 10. Closed epochs

### swap-20260710T080933Z-arranger2 — CLOSED

- SWAPOUT at: 2026-07-10T09:12:48Z, superseded by `SWAPIN Arranger1` (Coordinator directive: "you as
  arranger1 now swapin").
- successor: Arranger1, epoch `swap-20260710T091248Z-arranger1`.
- first-hand discrepancy notes (recorded by the incoming seat, per §7.2):
  1. The Arranger2 epoch closed in **RECOVERY**, never reaching ACTIVE; its pickup snapshot carried
     "NOT YET RECONCILED". The incoming Arranger1 reconciled that inventory first-hand this session —
     no silent repair.
  2. `doc/activation/op-258-activation.md` was edited during the RECOVERY window (an Arranger1
     adjudication that landed across the seat boundary). It is first-hand-correct and is **RATIFIED**
     by the incoming Arranger1, not discarded (per §8 stale-write rule: preserve + verify).
- archived record (verbatim):

#### Live mutex record

- mutex: **HELD**
- owner: **Arranger2**
- epoch: **swap-20260710T080933Z-arranger2**
- readiness: **RECOVERY** — swapped in, but the pre-protocol Arranger1 epoch has no durable
  outgoing handoff/task journal in the shared tree
- SWAPIN authority: Coordinator directive, 2026-07-10: "you are now in charge"
- implied SWAPOUT: **Arranger1**, at the same directive boundary
- last updated: 2026-07-10T08:53:32Z

#### Pickup snapshot

- last completed action: prepared the copy-paste Arranger2 swap-method orientation prompt and
  published `cp-002`.
- shared tree: `main` at `ddf56639efc231908b1df9993400b1e49a412dc6`, with `origin/main` an
  ancestor and local `main` 46 commits ahead at swap-in inspection time.
- working tree: large pre-existing mixed tracked/untracked control-state set; preserve it. No
  cleanup, staging, commit, or push was performed during this task.
- live ROB: **NOT YET RECONCILED** against an outgoing task list.
- returned awaiting adjudication: **NOT YET RECONCILED**.
- draft / ready / queued / hold: **NOT YET RECONCILED**.
- reserved IDs / next free candidates: **NOT YET RECONCILED; allocate nothing yet**.
- pending Coordinator decisions: none for swap doctrine; Coordinator routing is needed only to send
  the one-time Arranger1 bootstrap CATCHUP request between sessions.
- origin or validation blockers: not adjudicated during this process-only task.
- known evidence gaps: the pre-protocol handoff is absent; the Validator 8-vs-9 threshold
  contradiction remains governed by the onboarding warning and any later Coordinator ruling.
- safest next action: route
  `CATCHUP Arranger1 THROUGH swap-20260710T080933Z-arranger2/cp-002`, receive its pre-SWAPOUT task
  inventory, and reconcile that report against the live tree before issuing, adjudicating, retiring,
  or allocating project IDs.

#### Tasks since this SWAPIN

- task-01 **[Done]** — design and record the SWAP/SWAPIN/SWAPOUT process. Deliverable:
  `arranger-swap.md`.
- task-02 **[Waiting]** — obtain Arranger1's one-time read-only bootstrap CATCHUP inventory through
  `cp-002`, or reconstruct it if Arranger1 is unavailable; verify it first-hand against the shared
  tree, then change readiness from `RECOVERY` to `ACTIVE`.
- task-03 **[Done]** — add non-Git CHECKPOINT and read-only CATCHUP coordination points so the
  SWAPOUT seat can stay current without acquiring the mutex.
- task-04 **[Done]** — prepare a copy-paste orientation prompt that teaches Arranger2 the complete
  swap method without implicitly changing mutex ownership.

#### Coordination points

- latest checkpoint: **cp-002**, 2026-07-10T08:53:32Z, through task-04
- latest acknowledged catchup: **none**
- next catchup target: **Arranger1**, through
  `swap-20260710T080933Z-arranger2/cp-002`, including its pre-protocol task inventory
