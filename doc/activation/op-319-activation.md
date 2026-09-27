---
id: op-319
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-319 — Oracle3: round-2 1.0-preview foundation review — low-level Mach IPC + libdispatch, with an explicit delta from op-223

op-319 | role: **Oracle consult — architecture/quality synthesis only** | EXU: **Oracle3 session,
workspace `/Users/me/wip-mach/rmx-oracle3/`** | state: **[Done — consult returned 2026-07-17;
41,135-byte / 575-line note at SHA-256
`0f2ed556adfcbee6c542cb6d38810bda3ec1c68ecad2c6434b5ed3dc12b62d53`; Arranger identity
intake reproduced, but no recommendation is accepted pending the L/XL op-320 Validator gate]** |
DISPATCH: **CONSUMED — read-only consult complete** | parent: **id-042** |
L1i: **li-1001 / li-1002 / li-1007 / li-1013** | relations: **retired op-223,
op-225, op-226, op-227, op-231, op-233, op-234, op-239, op-242, op-246, op-247,
op-249, op-250, op-253, op-254, op-313, op-316; id-006/id-009/id-036/id-037/
id-043** | authored: **2026-07-17 by Arranger2**

## CONTEXT / WHY

rmxOS is an open-source Darwin/Mach userland and IPC port onto stock FreeBSD 15. This is a
maintainer's second architecture and code-quality review of our own low-level foundation. It is
ordinary operating-system engineering: no external target, offensive-security purpose, exploit,
evasion, or data collection.

The first foundation review, op-223, examined Mach IPC and libdispatch at product
`32f21706606f`. Since then we landed four focused low-level commits and collected substantially
better runtime/evidence-regime data. We also found that some old greens were less fail-closed than
their summaries implied. Re-read the current source and evidence from first principles, measure
what genuinely improved, identify what remains provisional, and recommend only the smallest
preview-relevant next work.

This consult is tied to the concrete current-tip ship tracker **id-042**. It is not a subsystem
tour for its own sake and must not create work merely because a long-arc parity item exists.

## REPOSITORY / WRITE BOUNDARY

Write exactly one commissioned deliverable:

`/Users/me/wip-mach/rmx-oracle3/op-319-mach-ipc-libdispatch-foundation-review-round2.md`

Oracle3 owns that directory. Read the product, Arranger, Explorer, Gatekeeper, Oracle1, and
Oracle2 trees as needed; write none of them. The Oracle3 directory is presently empty and is not a
Git repository. Do not create a repository, commit, push, or copy control state into it.

No product/control/harness edit; no build; no target execution; no `dlopen`/preload; no guest,
image mount, staging, privilege, host configuration action, network action, ID/op allocation,
dispatch, adjudication, retirement, acceptance, or milestone decision. Static source reading,
`git show`/`git diff`, hashing, and passive ELF/text inspection are allowed. Do not use
`/Users/me/wip-mach/wip-claude/` or `/Users/me/wip-mach/rmx-arranger2/` as live truth.

All Oracle conclusions are hypotheses/recommendations pending Arranger first-hand intake and an
independent Validator gate where sized L/XL. Say plainly what cannot be reproduced locally.

## PINNED INPUT IDENTITIES — REPRODUCE OR STOP

Canonical control tree:

- `/Users/me/wip-mach/rmx-arranger/`;
- branch `main`, `HEAD=f56170cf4ff88340ad5d960337e1714d9bc8b413`;
- `origin/main=2ab525f04f0983755604f3d9117fa4093100521e` is an ancestor;
- expected live control tree: 50 commits ahead with a large intentional tracked/untracked working
  set. Read it as live state; do not clean, stage, commit, or repair it.

Product review baseline, round 1:

- repository `/Users/me/wip-mach/wip-gpt/wip-rmxos/`;
- op-223 reviewed commit `32f21706606f` / tree
  `83d217d2429fafc1460bd27c871161b2bac74833`;
- prior review `/Users/me/wip-mach/rmx-oracle/op-223-leg-a-review.md`:
  25,370 bytes / 368 lines / SHA-256
  `66c50ee4b69bff613972fb8ed9b98e539787da9323e2f25503d496d3c25a72f8`.

Current product ceiling:

- branch `alpha`, clean and origin-aligned at
  `26655e67872cd55cff0a272b32b7895f55368033`;
- tree `aa9d4f44716b0793ca4de6ae67c7d819cf7ab15d`;
- `git diff 32f21706606f..26655e67872c` over
  `{sys/compat/mach,sys/modules/mach,lib/libdispatch,lib/libthr/thread/thr_workq.c,
  sys/kern/kern_thrworkq.c}` must show exactly six modified paths, 64 insertions, 16 deletions,
  carried by the four commits in the next section.

Central later consults:

- `/Users/me/wip-mach/rmx-oracle/op-225-evidence-regime-review.md`:
  12,815 bytes / 189 lines / SHA-256
  `a3e011d92b932dd4c89812eac13cd965fdb822df1563d9e816f75ecb156e9fb8`;
- `/Users/me/wip-mach/rmx-oracle/op-231-swift-dispatch-join-review.md`:
  22,865 bytes / 344 lines / SHA-256
  `367f0c08843d3801af0d02c8648d68cca949e7b83ab0ec6b2a048b149e911998`;
- `/Users/me/wip-mach/rmx-oracle2/op-313-li-1001-preview-quality-control.md`:
  42,409 bytes / 329 lines / SHA-256
  `fd46d7a3a2242533956cbf331fbc64946a2a72352a39100dcc5f5c0653f08dec`.

Gatekeeper source/evidence repository is read-only input:

- `/Users/me/wip-mach/rmx-gatekeeper/`, `main@5fa26ee151e0a770f7c3ae0aa2a418ef37bd0b0f`,
  `origin/main=4b16fd1b65e76cfcdb40de96069e13d3d702e3cf`, 41 ahead, with a large preserved
  untracked evidence set;
- never infer publication from a working-tree file. State whether each fact comes from committed
  findings, untracked raw evidence, product source, or an activation summary.

If a pinned product commit/tree, prior-review note, or central later-consult identity differs,
return `BLOCKED IDENTITY-DRIFT <fact>`. Record non-load-bearing control/evidence drift without
repairing it.

## REQUIRED READS

Read completely before writing the synthesis:

1. This activation and `AGENTS.md`, `arranger-rulebook.md`, `roles.md`,
   `discovery-implementation-pipeline.md`, `terminology.md`, and `idq/id-042-1.0-preview-todo.md`
   from the canonical Arranger tree.
2. `doc/activation/op-223-activation.md` and the complete op-223 review note pinned above.
3. The complete op-225, op-231, and op-313 notes pinned above.
4. Activations op-224, op-226, op-227, op-233, op-234, op-235, op-238, op-239, op-240,
   op-242, op-246, op-247, op-249, op-250, op-253, op-254, op-261, op-313, and op-316.
5. `l1i/li-1000.md`, `l1i/li-1013.md`, `l1i/li-1011.md`, `l1i/li-9004.md`,
   `l1i/li-9007.md`, `idq/id-036-kernel-mach-recv-copyout-dest-null-lock-panic.md`,
   `idq/id-037-machdebug-cell-dispatch-init-dark.md`, and
   `idq/id-043-mach-oversized-receive-contract.md`.
6. The current function/structure bodies in the product paths named by D2/D3 below, plus the
   exact four low-level product diffs. Do not reason from summaries alone.

For the load-bearing runtime improvements, spot-check the committed finding and its exact raw
record where available:

- `findings/op226-invariants-soak.txt` SHA-256 `16262c0959964e45b676306ad48ce89cde520eee6af445cab087c020d4611bf6`;
- `findings/op234-banner-validation.txt` SHA-256 `cf3b057dc15bdcf0c72d1fff15c41af1eccd5dc22fa6e964fc52587e38205966`;
- `findings/op235-substrate-stress-result.txt` SHA-256 `d64ba82a99eb5c83ef0e1b1dd20087bff36700d342fec971b047d41a70f8eee6`;
- `findings/op239-churn-fix-result.txt` SHA-256 `925c8556ae1b17703e1afa5e31487cb3964676e552ecc8a7ce887c0ceb0c643c`;
- `findings/op250-captured-green.txt` SHA-256 `dd86270d5af45d1af12b5f336890026dcc9f48e2b667a6afae131a3676f32add`;
- `findings/op253-acceptance.txt` SHA-256 `a4ffcf155d9a441e696351abd2b41697a554fbc1b0b9af6726ee7bd1494c4e89`;
- raw `build/op226/op226-serial.log` SHA-256
  `142a2dde17f34fa9f8501da01e423a5a4c4a256c107e9e94c9672cd85e3d1c45`;
- raw `build/op235/op235-cell2-serial.log` SHA-256
  `8e405393be1722c5a0be46f28ff4956eba02814a7cb32027a7857747b01bb4c4`;
- raw `build/op235/op239-cells23-serial.log` SHA-256
  `8e5c2dde2cb91aaaf1d3a10508abb5470fe7be5b791cd79adeb3ddb540361660`;
- raw `build/op250/op250-serial.log` SHA-256
  `a792baf8c76575aa5ad1de6733375e3520a409256e2f12c242a28f7dd3d535c2`;
- raw `build/op253/op253-serial.log` SHA-256
  `34e708b3233b5d0df264179aeb4c2cc926f573ab6686b9675ab56d7518dcf70a`.

The raw files above are untracked in the current Gatekeeper worktree unless first-hand Git status
shows otherwise. Their existence/hash supports a read-only spot-check; it is not publication.
Treat op-235 Cell 3 as **physical-host contamination and unaccepted guest evidence**, per
`doc/host-guest-isolation-incident-2026-07-11.md`; do not rehabilitate it.

## DELTA LEDGER — VERIFY, CORRECT, THEN USE

The Arranger's routing hypothesis is that only these four low-level product commits landed after
the op-223 source ceiling. Verify their exact diffs, current survival, and origin reachability:

1. `106f9d7fd160736639a49f389960c435b849a307` — `dispatch: probe and report concurrency
   engine`: kernel feature probe/cache in `lib/libthr/thread/thr_workq.c`; explicit
   setdispatch-failure and selected-engine logging in `lib/libdispatch/src/queue.c`.
2. `d7006259107395cde25d1e46d04c82a7886c7ebe` — `mach: keep MACH_RECV source readiness
   from direct receive`: distinguish readiness-only knotes from buffer-bearing direct receives in
   `sys/compat/mach/ipc/ipc_pset.c`.
3. `59fe7b300adbe769ff894a37e9bb06d6ff93d453` — `mach: return dequeued TOO_LARGE kmsgs
   to receive error path`: initialize/guard the receive-local kmsg and distinguish dequeued from
   retained-on-queue TOO_LARGE in `ipc_mqueue.c`/`mach_msg.c`.
4. `dd6e7a804ebfee330d40903dc4b9acb3e18863b9` — `mach: stop dropping current task ref in
   insert-right trap`: remove the unbalanced `task_deallocate(current_task())` path in
   `mach_traps.c`.

The evidence delta is larger than the source delta. Verify these claimed improvements and limits:

- op-227/op-234: engine selection is probed and attributable; MACHDEBUGDEBUG→TWQ and forced
  fallback→pthread-pool were observed, while native MACHDEBUG Cell 1 stayed dark.
- op-226/op-250: the dispatch 9-case and notify churn were re-hosted on the
  MACHDEBUGDEBUG/WITNESS/INVARIANTS regime; this is real progress, not the final current-tip
  all-up invariant replay.
- op-233/op-235/op-239: the pre-existing `5675145` TWQ grant/handoff mechanics were source-gated;
  fan-out and deep-chain passed on TWQ; corrected churn passed on TWQ and forced-pool. The first
  churn diagnosis was a harness-measurement error, and native MACHDEBUG plus macOS self-check
  remained unavailable.
- op-242/op-246/op-247: the readiness/direct-receive flag collision fix was semantically sound but
  necessary-not-sufficient for the independent syscall TOO_LARGE panic.
- op-249/op-253: the dequeue-stale/uninitialized-kmsg fix made the original undersized probe return
  `MACH_RCV_TOO_LARGE` without panic. The trailer-sized probe was not exercised because its
  userland harness crashed.
- op-224/op-254: op-223 N1's borrowed-current-task refcount bug was fixed, dual-Validator-gated at
  confidence 9, runtime-regressed, and published.
- op-313/op-316: the old li-1001 soak is not a complete fail-closed proof of all literal
  invariants; current-tip replay remains owed. The external/public syscall-`MACH_RCV_LARGE`
  retain/report/retry contract is explicitly deferred post-preview as li-9007/id-043 after a
  no-build-enabled-preview-consumer census. The separate active libxpc trailer-capacity boundary
  remains preview work under id-021.

Do not accept any bullet because it appears here. Reproduce it from source/primary evidence,
correct it if needed, and distinguish **product improvement**, **evidence improvement**,
**harness correction**, **scope disposition**, and **still-open gap**.

## D1 — ROUND-1 DISPOSITION MATRIX

Re-evaluate every op-223 proposed item, not just its headline:

- near-term N1 through N7;
- long-term L1 through L6;
- Coordinator escalations E1 through E3;
- every rough edge and test-coverage gap in `OP223_QUALITY`.

For each return exactly one status: `RESOLVED`, `PARTIAL`, `DEFERRED-BY-COORDINATOR`,
`SUPERSEDED`, `STILL-OPEN-PREVIEW`, `STILL-OPEN-POST-PREVIEW`, or `PREMISE-CORRECTED`.
Give the current source coordinate, product commit if any, strongest evidence op/artifact, evidence
strength, and preview effect. A fix without accepted runtime proof is not `RESOLVED`; a scope cut is
not a working-feature claim.

Marker: `O3_OP319_ROUND1_DISPOSITION`

## D2 — CURRENT MACH IPC INTEGRATION / QUALITY MAP

Read the complete current bodies and grade the present design, not the 32f snapshot:

1. module attach/detach and dynamic syscall/filter registration;
2. port-right-as-fd lifecycle, fork/exec/exit/close semantics, and stable/15 fd-internal shadow
   coupling;
3. trap argument/tail bridging, return conventions, borrowed/current task lifetime, and remaining
   unsupported traps;
4. blocking/wakeup, pset move/wake, lock/reference discipline, and invariant coverage;
5. `EVFILT_MACHPORT` readiness, buffer-bearing direct receive, private/public knote signaling, and
   the three receive mechanisms separated by op-316 (syscall immediate/blocked, readiness, direct
   kevent);
6. send/receive ownership, TOO_LARGE error/copyout behavior, trailer sizing/formatting and peer
   identity, with the generic deferred syscall-LARGE contract kept separate from the live libxpc
   exact-fit/trailer boundary;
7. dead-name/no-senders/port-destroyed/send-possible notification surface;
8. task/IPC-space/refcount lifetime and dormant/dead code.

For every plane label `SOURCE-SOLID`, `RUNTIME-PROVEN-CURRENT-ARTIFACT`,
`RUNTIME-PROVEN-OLDER-ARTIFACT`, `SOURCE-ONLY`, `CONTROL-GAP`, or `DEFERRED`. Cite exact current
file/function/line coordinates and the primary evidence. Call out any op-223 claim now falsified
or materially sharpened.

Marker: `O3_OP319_MACH_MAP`

## D3 — CURRENT LIBDISPATCH / PTHREAD_WORKQUEUE INTEGRATION MAP

Read the current bodies across `lib/libdispatch`, `lib/libthr/thread/thr_workq.c`, and
`sys/kern/kern_thrworkq.c`. Grade:

1. classic-Apple lineage/build switches, debug/optimization shape, and kevent64 shim fidelity;
2. root-queue initialization, real kernel feature probe, banner/log observability, TWQ selection,
   forced and ENOSYS pool fallback, and failure behavior;
3. TWQ lane/pending/grant/worker-return/handoff/concurrency accounting, including what
   `5675145` plus the later fan-out/chain/churn evidence actually proves;
4. pool-engine fallback coverage, the native-MACHDEBUG Cell-1 dark gap, and whether that gap has any
   ship impact when MACHDEBUGDEBUG/TWQ is the preview regime;
5. Mach-backed source servicing: readiness-only vs direct receive, send/dead/send-possible state,
   syscall vs direct-kevent paths, and consumer agreement with the two receive fixes;
6. timers, semaphores/deadline polling, fd sources, DTrace/USDT observability, and source-type
   breadth actually exercised by preview services;
7. QoS/priority propagation across dispatch→pthread_priority_t→libthr TWQ lanes→kernel admission,
   while distinguishing lane selection from real CPU priority/donation;
8. known risk-excluded surfaces: firehose, vouchers/importance donation, cooperative SPI, modern
   upstream rebase, and anything else not required by the existing preview surface.

Use the same evidence labels as D2. Separate architectural faithfulness, source correctness,
runtime coverage, and production readiness. Do not use symbol presence as runtime proof.

Marker: `O3_OP319_DISPATCH_MAP`

## D4 — IMPROVEMENT ACCOUNTING SINCE op-223

Produce two independent ledgers:

- **source ledger:** exact low-level code behavior changed by each of the four commits, any
  unintended interaction, and whether the change remains current;
- **evidence ledger:** new facts learned without a low-level source change, including engine
  attribution, asserts-armed runs, TWQ stress, harness corrections, raw/publication limits, and
  later scope decisions.

For each improvement state the old op-223 concern, the new fact, what is now stronger, and what the
new evidence still does not prove. Explicitly identify improvements that are merely procedural or
diagnostic and should not be counted as product maturity.

Marker: `O3_OP319_IMPROVEMENT_DELTA`

## D5 — CURRENT 1.0-PREVIEW CONTROL-GAP / FAILURE-MODE REVIEW

Falsify the optimistic reading. At minimum assess:

- whether current-tip `26655e67` has ever run the li-1001 invariant bar or full libdispatch core on
  one content-addressed ship image;
- whether op-108's historical driver/oracle can reject queue/port/message conservation failures,
  DTrace absence, and workload self-failure;
- what probe A versus failed probe B actually establishes for TOO_LARGE/trailers;
- whether raw untracked records, summary/raw label swaps, or host/guest confusion affect any
  improvement claim;
- whether the TWQ stress suite covers both overcommit/non-overcommit roots, queue lifecycle,
  timer/fd/Mach sources, cancellation, and shutdown—or only fan-out/chain/churn;
- whether silent fallback is fixed for diagnosis but still possible in production;
- whether the active four-service workload reaches any still-provisional Mach/dispatch path;
- whether the certified image's low-level artifacts are behind current origin and therefore require
  final-candidate replay.

For each gap return `PREVIEW-BLOCKING`, `FINAL-CANDIDATE-REPLAY`,
`CATALOG-AND-DEFER`, or `NO-LIVE-PREVIEW-CONSUMER`, with a source/consumer/evidence reason. Do not
promote an uncertainty into a blocker without a live preview consumer or invariant obligation.

Marker: `O3_OP319_CONTROL_GAPS`

## D6 — MINIMUM FOUNDATION BAR FOR id-042

Define the smallest honest low-level foundation slice that must accompany id-042's final PID-1
four-service certification. It must be bounded and reuse accepted evidence where valid. Specify:

- exact candidate/image/kernel/mach.ko/libthr/libdispatch identity fields;
- engine attribution and fallback detection;
- current-tip functional cases to replay versus evidence safely reusable from older artifacts;
- fail-closed Mach conservation/invariant predicates and known-bad controls;
- the minimal dispatch breadth needed by the four actual services and PID-1 launchd;
- duration/attempt ownership only as a proposal, leaving the Coordinator to set the final spend;
- what must be captured raw and content-addressed for Validator consumption.

Do not design a new all-subsystem mega-harness. State which pieces belong inside the final all-up
Gatekeeper run and which need a prior bounded Explorer/Implementer/Validator op.

Marker: `O3_OP319_PREVIEW_BAR`

## D7 — ROLE-CORRECT IMPROVEMENT ROUTING

Return a ranked list of at most:

- **three preview-critical actions** tied to existing live IDQ problems, and
- **five post-preview items** tied to existing deferred IDs/L1i entries where possible.

For each give: concrete problem, falsifiable completion condition, live consumer, risk/blast
radius, and owning role/repository. Use `Explorer` for new conformance/content, `Implementer` for
product/build changes, `Gatekeeper` for contained runtime/soak/evidence, and `Validator` for
pre-retirement correctness. Do not assign Oracle as a validation lane. Do not allocate IDs or op
numbers. If a new concrete IDQ is genuinely required, propose its title/parent and explain why no
existing live IDQ fits.

Do not revive op-281/op-282, repair-forward rejected harness chains, or pull id-001/002/004/005/
008/043 back into preview without a newly proven preview consumer and Coordinator decision.

Marker: `O3_OP319_ROUTING`

## D8 — SYNTHESIS / REPORT

Give four separate scores, each 1–10 with a one-sentence calibration:

- Mach IPC architecture maturity;
- Mach IPC evidence maturity;
- libdispatch/TWQ architecture maturity;
- libdispatch/TWQ evidence maturity.

Then give a concise recommendation, not an acceptance ruling:

- `FOUNDATION-RECOMMEND-READY-FOR-FINAL-CANDIDATE-REPLAY`;
- `FOUNDATION-RECOMMEND-PREVIEW-WITH-BOUNDED-PREREQUISITES <items>`;
- `FOUNDATION-RECOMMEND-NOT-READY <blocking items>`; or
- `CONSULT-INCONCLUSIVE <missing facts>`.

Explain whether the project is materially stronger than at op-223 and name the two or three facts
that most changed the answer. State confidence 1–10. Coordinator owns scope/readiness; the
Arranger/Validators establish facts and retirement.

Markers: `O3_OP319_SYNTHESIS`, `O3_OP319_TERMINAL`

## REQUIRED RETURN BLOCK

```text
REPORT
op:                    op-319
oracle:                Oracle3
deliverable:           <absolute path> / <bytes> / <lines> / <sha256>
baseline_identity:     <op-223 note + 32f217 tree match/drift>
current_identity:      <alpha commit/tree/status/origin match/drift>
source_delta:          <four commits confirmed/corrected>
mach_arch_score:       <1-10>
mach_evidence_score:   <1-10>
dispatch_arch_score:   <1-10>
dispatch_evidence:     <1-10>
round1_disposition:    <counts by status>
preview_actions:       <0-3 concise items>
postpreview_actions:   <0-5 concise items>
recommendation:        <one allowed recommendation>
confidence:            <1-10>
boundary:              read_only=1 builds=0 target_exec=0 guest_cells=0 product_writes=0 control_writes=0
terminal:              CONSULT-COMPLETE
```

Required markers:

```text
O3_OP319_INPUT_IDENTITY
O3_OP319_ROUND1_DISPOSITION
O3_OP319_MACH_MAP
O3_OP319_DISPATCH_MAP
O3_OP319_IMPROVEMENT_DELTA
O3_OP319_CONTROL_GAPS
O3_OP319_PREVIEW_BAR
O3_OP319_ROUTING
O3_OP319_SYNTHESIS
O3_OP319_TERMINAL
```

REPORT

```text
op: op-319
agent: Oracle3
dispatch: detailed read-only Mach IPC + libdispatch round-2 consult complete
next-hop: Arranger reproduces identities, sizes the return L/XL, and routes an independent Validator before any finding drives product/runtime work
```

## RELATIONS / FEEDBACK

Primary carrier: id-042 current-tip ship tracker. Foundation bars: li-1001/li-1002; final all-up:
li-1007; evidence-regime carry: li-1013. Prior review: op-223. Later correction/synthesis:
op-225/op-231/op-313/op-316. Deferred generic oversized receive: li-9007/id-043.

feedback: `agent_host_isolation`, `verify_premise_before_mechanism`,
`code_reasoned_verdict_is_hypothesis`, `artifact_identity_needs_content_check`,
`workload_class_needs_source_read`, `dtrace_first_debugging`,
`no_conflate_gating_with_readiness`, `build_is_implementer`, `soak_is_gatekeeper`,
`validator_not_oracle_for_correctness`, `op_state_dispatch_boundary`.
