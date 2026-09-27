# op-320 — Validator3: gate Oracle3 op-319 foundation delta, evidence classifications, and id-042 minimum bar

op-320 | role: **Validator — independent XL source/evidence/scope gate** | EXU:
**Validator3 session (Coordinator substitution for the originally bound Validator-DS4P seat)** |
state: **[Done — VALIDATED-WITH-CORRECTIONS at confidence 8/10; threshold hold]** |
DISPATCH: **CONSUMED — Validator3 returned; not retired or banked pending the Coordinator's
8-vs-9 doctrine ruling** | parent: **op-319 / id-042** | L1i:
**li-1001 / li-1002 / li-1007 / li-1013** | relations: **op-223/op-225/op-231,
op-313/op-316, id-006/id-009/id-021/id-025/id-036/id-037/id-043** | authored:
**2026-07-17 by Arranger2**

## RETURN / THRESHOLD HOLD — 2026-07-17

Validator3 returned `VALIDATED-WITH-CORRECTIONS`, confidence **8/10**, and recommended
`BANK-AS-VALIDATED-FOUNDATION-INPUT`. The return confirms the four-commit `+64/-16` source delta
and the bounded id-042 foundation recommendation, while requiring these corrections before use:

- exact round-1 disposition totals are `1/3/4/1/1/11/2` across the seven named classes, total 23;
- N3 has live launchd/notifyd/ASL/libxpc audit-trailer consumers; a no-consumer/fictitious-token
  rationale is false even if the Coordinator retains the scope deferral;
- id-009/id-025 are closed defects whose fixes survive at tip, not live historical races;
- op-253 Probe A covers queued no-`LARGE` receive only, not blocked handoff;
- DEBUG libdispatch emits to its default file/syslog path without requiring
  `LIBDISPATCH_LOG=stderr`; the latter was a capture choice;
- raw op-235 evidence has one fan-out and one chain result; corrected churn has two TWQ plus two
  forced-pool results;
- six findings are committed only in local Gatekeeper HEAD and five raw serials remain untracked.

No id-042 box closes. No stage, cell, product change, candidate replay, ship action, or retirement
is released. The active Arranger rulebook requires a narrow Arbiter step-in below confidence 9,
while older governing text still accepts both Validators at 8; the live swap record identifies
that 8-vs-9 conflict as Coordinator-pending. Therefore this activation records the return as
`[Done]` and preserves the corrected report without silently banking or retiring it.

## OBJECTIVE

Independently gate Oracle3's round-2 Mach IPC + libdispatch review. Establish which source and
evidence improvements since op-223 are correct, repair its non-exclusive classifications and
provenance wording, and decide whether its bounded foundation prerequisites are a sound input to
id-042. Do not validate 1.0-preview itself and do not release product/runtime work.

Oracle3 recommends `FOUNDATION-RECOMMEND-PREVIEW-WITH-BOUNDED-PREREQUISITES`, scoring Mach
architecture/evidence 8/6 and dispatch architecture/evidence 7/6. Those are consult hypotheses,
not accepted facts.

Coordinator seat substitution: Validator3 replaces Validator-DS4P as the concrete EXU. The
existing `VDS4P_OP320_*` marker strings are retained as stable contract labels so the dispatched
brief and returned evidence remain mechanically comparable; they do not identify the executing
seat. The required report must name Validator3.

Arranger intake reproduced the deliverable, all central notes, the product baseline/current tip,
the exact four-commit low-level source delta, and all eleven pinned evidence hashes. Intake also
found classification/provenance defects that this gate must not silently normalize:

1. D1 promises one status per item but gives E1 both `PARTIAL` and `SUPERSEDED`, double-counts a
   partial N2 subclaim as `RESOLVED`, uses approximate totals, and introduces a
   `PREMISE-CORRECTED` row outside the enumerated N/L/E inventory.
2. D5 promises one of four classes per gap but gives the op-108 row two classes and gives the raw
   provenance row none.
3. The phrase “historical races still in tip” misdescribes id-009 and id-025: both defects are
   retired/closed; their fixes `e101f9c` and `180d30bd` survive in current source.
4. All six tracked Gatekeeper findings are committed **locally** but are not ancestors of
   `origin/main`; the report's “local-or-origin committed” phrase is too loose.
5. The report's formal deliverable field omits its own identity and refers to an enclosing return
   that did not supply one. The exact identity is pinned below.
6. D1 omits op-223's `-mno-avx`/kernel-vector quality row. Later op-168 evidence found five YMM
   instructions despite the flag-level premise, while its four-hour run remained free of FPU
   faults; the missing row likely carries a `PREMISE-CORRECTED` disposition.
7. The report does not explicitly carry op-316's correction that op-108 raw serial identifies
   MACHDEBUGDEBUG plus WITNESS; the blanket op-223 “all evidence kernels were assert-dead” premise
   cannot remain implicit.
8. N3 is materially misstated. `task.c:205-216` calls `set_security_token()` for ordinary tasks;
   only the kernel-task branch gets KERNEL constants. `proc_info.c:482-503` creates a real but
   fork-time audit token while zeroing the security token. launchd, notifyd, ASL, and libxpc
   actively request/use audit trailers, so “future consumers / trailer consumers still fiction”
   is not a sound no-consumer rationale.
9. The report conflates queued/immediate and genuinely blocked syscall receives. op-253 Probe A
   proves only the queued no-`LARGE` case; blocked handoff remains source-only.
10. Two dispatch evidence claims conflict with current source/raw evidence: the DEBUG build logs
    by default to `/var/tmp/libdispatch.<pid>.log` or syslog—`LIBDISPATCH_LOG=stderr` was a capture
    choice, not a prerequisite for emission—and op-235 raw contains one fan-out plus one chain
    run, not two of each.

## EXECUTION / WRITE BOUNDARY

Read-only Validator work. Write no product, Arranger, Oracle, Explorer, Gatekeeper, image, host,
or other repository file. No build, target execution, `dlopen`, preload, guest, image mount,
staging, privilege, host configuration, network, commit, push, ID/op allocation, dispatch,
release, adjudication, retirement, scope decision, or ship decision.

Use static source/Git inspection, hashing, and existing text evidence only. State what cannot be
reproduced. Return the verdict to the Coordinator/Arranger in chat. A confidence-9+ verdict moves
the verification labor; it does not itself close an id-042 box or authorize the proposed replay.

## PINNED INPUTS — STOP `BLOCKED IDENTITY-DRIFT <fact>` ON LOAD-BEARING MISMATCH

Oracle3 deliverable:

- `/Users/me/wip-mach/rmx-oracle3/op-319-mach-ipc-libdispatch-foundation-review-round2.md`;
- 41,135 bytes / 575 lines / SHA-256
  `0f2ed556adfcbee6c542cb6d38810bda3ec1c68ecad2c6434b5ed3dc12b62d53`;
- Oracle3 workspace is not a Git repository; the commissioned note is the only write in scope.

Canonical activation after Arranger intake:

- `/Users/me/wip-mach/rmx-arranger/doc/activation/op-319-activation.md`;
- 22,146 bytes / 417 lines / SHA-256
  `0a2212d17a57ba363950de720743b07435adcf51d8634f1616a140dfbdaa7227`;
- state `[Done]` means returned, not retired or accepted.

Product repository `/Users/me/wip-mach/wip-gpt/wip-rmxos/`:

- clean, origin-aligned `alpha@26655e67872cd55cff0a272b32b7895f55368033`;
- tree `aa9d4f44716b0793ca4de6ae67c7d819cf7ab15d`;
- round-1 baseline `32f21706606fa574956aa0faddfe16f078149b47`, tree
  `83d217d2429fafc1460bd27c871161b2bac74833`;
- bounded low-level diff: six paths, 64 insertions, 16 deletions;
- exact commits: `106f9d7fd160736639a49f389960c435b849a307`,
  `d7006259107395cde25d1e46d04c82a7886c7ebe`,
  `59fe7b300adbe769ff894a37e9bb06d6ff93d453`, and
  `dd6e7a804ebfee330d40903dc4b9acb3e18863b9`.

Prior notes:

- op-223: 25,370 bytes / 368 lines / SHA-256
  `66c50ee4b69bff613972fb8ed9b98e539787da9323e2f25503d496d3c25a72f8`;
- op-225: 12,815 / 189 /
  `a3e011d92b932dd4c89812eac13cd965fdb822df1563d9e816f75ecb156e9fb8`;
- op-231: 22,865 / 344 /
  `367f0c08843d3801af0d02c8648d68cca949e7b83ab0ec6b2a048b149e911998`;
- op-313: 42,409 / 329 /
  `fd46d7a3a2242533956cbf331fbc64946a2a72352a39100dcc5f5c0653f08dec`.

Gatekeeper `/Users/me/wip-mach/rmx-gatekeeper/`:

- `main@5fa26ee151e0a770f7c3ae0aa2a418ef37bd0b0f`,
  `origin/main=4b16fd1b65e76cfcdb40de96069e13d3d702e3cf`, 41 ahead;
- expected large preserved untracked evidence set;
- reproduce the eleven hashes listed in op-319. For each artifact state separately whether it is
  tracked, committed, reachable from local `HEAD`, reachable from `origin/main`, or untracked.

The Arranger control tree is intentionally dirty/live. State-only progression of op-319 and the
addition of this op-320 are expected; do not clean or treat those as product identity drift.

## REQUIRED READS

Read completely:

1. op-319 activation and Oracle3 deliverable;
2. op-223, op-225, op-231, and op-313 notes;
3. op-224/op-226/op-227/op-233/op-234/op-235/op-239/op-242/op-246/op-247/op-249/
   op-250/op-253/op-254/op-313/op-316 activations;
4. `idq/id-006*`, `idq/id-009*`, `idq/id-021*`, `idq/id-025*`, `idq/id-036*`,
   `idq/id-037*`, `idq/id-042*`, `idq/id-043*`, `l1i/li-1001.md`, `l1i/li-1002.md`,
   `l1i/li-1007.md`, `l1i/li-1013.md`, `l1i/li-9004.md`, and `l1i/li-9007.md` where present;
5. current complete source bodies needed for G2-G5, not only cited lines.

## G1 — IDENTITY / COMPLETENESS

Reproduce all load-bearing identities. Confirm all ten `O3_OP319_*` markers and all required
report fields are present. Record the missing embedded deliverable identity as a return-format
defect and use the independently reproduced identity above.

Report whether the note actually answers every D1-D8 requirement. Do not infer completeness from
marker presence.

Marker: `VDS4P_OP320_INPUT_IDENTITY`

## G2 — FOUR-COMMIT SOURCE DELTA

Independently inspect each exact diff and its current surrounding body:

1. `106f9d7`: kernel TWQ feature probe/cache, setdispatch failure log, selected-engine log;
2. `d700625`: readiness-only versus buffer-bearing direct Mach receive;
3. `59fe7b30`: initialized kmsg and dequeued/retained TOO_LARGE routing;
4. `dd6e7a80`: removal of the borrowed-current-task deallocation.

Confirm exact current survival and whether Oracle3 accurately distinguishes product behavior,
diagnostic-only change, and evidence-only improvement. Check for an interaction omitted from its
source ledger. Return `CONFIRMED`, `CONFIRMED-WITH-CORRECTION`, or `REJECTED` per commit.

Marker: `VDS4P_OP320_SOURCE_DELTA`

## G3 — ROUND-1 DISPOSITION EXACTNESS

Reconstruct the disposition from op-223 itself:

- N1-N7;
- L1-L6;
- E1-E3; and
- each distinct `OP223_QUALITY` rough edge/coverage gap.

For every unique row assign exactly one allowed status. Do not split one row across statuses,
count a subclaim separately, or double-count a quality row that merely aliases N/L/E unless the
report labels it explicitly as an alias excluded from totals. Return exact integer totals.

Resolve explicitly:

- E1 `PARTIAL` versus `SUPERSEDED`;
- N2 overall `PARTIAL` versus the locally source-resolved probe subclaim;
- whether `PREMISE-CORRECTED` for the op-235 churn diagnosis belongs to the op-223 inventory;
- whether any `STILL-OPEN-PREVIEW` row is actually outside the low-level foundation;
- the report's inconsistent rule “source fix without accepted runtime is not RESOLVED” versus its
  `RESOLVED (source)` libthr-probe quality row.
- the omitted op-223 `-mno-avx`/hardware-proof row using op-168's `kernel_ymm=5_flagged` evidence;
  and
- the op-223 blanket assert-dead premise using op-108 raw plus op-316's correction.

Return a corrected compact table or an exact correction list sufficient for Arranger
adjudication. Approximate counts (`≈`, `12+`) are not accepted.

Marker: `VDS4P_OP320_ROUND1_DISPOSITION`

## G4 — MACH IPC MAP / PREVIEW EFFECT

Verify the load-bearing current-source claims for:

- module/filter registration and unload behavior;
- port-right-as-fd lifecycle and fd shadow coupling;
- trap/tail bridging and current-task ownership;
- pset lock/ref/wakeup behavior and invariant coverage;
- syscall immediate/blocked receive, readiness-only kevent, and buffer-bearing direct kevent;
- no-`LARGE` TOO_LARGE behavior, deferred syscall-LARGE contract, and the separate live libxpc
  trailer-capacity boundary;
- notification arms; and
- task/IPC-space lifetime and dormant code.

Correct the phrase “historical races still in tip”: id-009 and id-025 are closed product defects;
their fixes survive at tip. Determine whether any **other** open source-certain low-level panic,
UAF, refcount, or conservation defect contradicts the conclusion that no op-223-class foundation
product blocker remains. Do not count id-021 closed/open without reading its current live state.

Separate `SOURCE-SOLID`, runtime on the exact current artifact, runtime on an older artifact,
control gap, and Coordinator-deferred scope.

Reconstruct N3 precisely. Verify ordinary-task token initialization, exec/credential-change
freshness, successful-receive trailer stamping/metadata, error-receive trailer contents, and the
direct-kevent disabled trailer-construction block. Census the active launchd/notifyd/ASL/libxpc
consumers. Decide whether the old Coordinator deferral remains supportable only as an explicit
scope/risk decision or whether its factual no-live-consumer premise must return to the Coordinator.
Do not independently promote it into preview or write a fix brief.

Separate the four receive modes: queued/immediate syscall, blocked/receive-first syscall,
readiness-only filter, and buffer-bearing direct-kevent receive. State exactly which one op-253
Probe A exercised.

Marker: `VDS4P_OP320_MACH_MAP`

## G5 — LIBDISPATCH / TWQ MAP

Verify first-hand:

- actual probe/cache and banner/log conditions;
- TWQ selection and forced/ENOSYS pool fallback behavior;
- lane/pending/grant/return/handoff mechanics;
- exact artifact identities and classifications for fan-out, chain, churn, timer, MACH_RECV, and
  notify evidence;
- native MACHDEBUG Cell-1 dark scope and ship effect;
- source-type breadth not exercised by the stress suite;
- QoS lane selection versus real CPU priority/donation; and
- risk-excluded surfaces.

Test the statements that the probe is “observability-only,” production fallback remains silent,
and the four-service preview workload needs no still-provisional path. Do not convert symbol or
source presence into runtime proof.

Read `internal.h:334-357`, `init.c:474-517,579-594`, and the product Makefile. Correct the claim
that engine/fallback logging requires `LIBDISPATCH_LOG`: under the current DEBUG build the default
is a per-process `/var/tmp` log, falling back to syslog; the environment was required to capture
stderr in op-234, not to make `_dispatch_log` emit. Reassess N2's overall disposition accordingly.

Read the pinned op-235 raw serial and runner. Count actual invocations: current first-hand intake
finds one fan-out result and one chain result, while corrected churn has two TWQ and two forced-pool
runs. Do not inherit `×2` from a summary when raw disagrees, and do not imply pool fan-out/chain
coverage.

Marker: `VDS4P_OP320_DISPATCH_MAP`

## G6 — EVIDENCE PROVENANCE / CONTROL GAPS

For every load-bearing improvement identify:

- product commit and origin reachability;
- exact runtime artifact identity where known;
- committed finding reachability from Gatekeeper local `HEAD` and `origin/main` separately;
- raw record hash and tracked/untracked status; and
- known summary/raw label defect.

Carry these known controls explicitly:

- all six findings are local-HEAD committed but not `origin/main`-reachable;
- all five pinned raw serials are untracked;
- op-253's `dd24beb1...` host-as-serial label swap;
- op-226's finding/raw serial hash mismatch; and
- op-235 Cell 3 physical-host contamination is unaccepted.

Reproduce op-316's correction that the op-108 raw serial does name MACHDEBUGDEBUG + WITNESS.
Distinguish that regime visibility from a fail-closed current-tip proof.

Reproduce op-168's durable `kernel_ymm=5_flagged` result and distinguish “four hours without an
FPU fault” from the falsified “AVX-free by construction” premise.

Then give exactly one D5 class per gap:
`PREVIEW-BLOCKING`, `FINAL-CANDIDATE-REPLAY`, `CATALOG-AND-DEFER`, or
`NO-LIVE-PREVIEW-CONSUMER`. If one subject has both a historical control-debt disposition and a
current replay obligation, split it into two clearly different rows rather than assigning two
classes to one row.

Marker: `VDS4P_OP320_EVIDENCE_CONTROL`

## G7 — id-042 MINIMUM BAR / ROUTING

Determine whether D6 is bounded, fail-closed, and role-correct. Check specifically:

- exact candidate/image/kernel/mach.ko/libthr/libdispatch identity requirements;
- engine attribution and forced-pool differential;
- what may be reused only as historical provenance versus what must run on the candidate;
- the apparent tension between D6's “reuse Probe A shape” table and P2's candidate replay;
- conservation predicates and known-bad detector controls;
- minimal dispatch breadth actually consumed by PID-1 launchd plus the four services;
- raw content-addressed evidence; and
- Explorer/Implementer/Gatekeeper/Validator ownership boundaries.

The accepted result may inform id-042, but it must not:

- close ASL leg 4, libxpc, PID-1, exact-image, or all-up soak boxes;
- revive op-281/op-282 or pull id-043 into preview;
- authorize a new mega-harness, guest cell, product fix, or runtime spend; or
- treat Oracle scores as readiness evidence.

Return at most three corrected preview actions and five post-preview actions, each tied to a live
IDQ/L1i and named owner/repository. Flag any recommendation that lacks a concrete live consumer.

Marker: `VDS4P_OP320_PREVIEW_BAR`

## G8 — VERDICT

Return exactly one:

- `VALIDATED-FOUNDATION-DELTA` — all load-bearing source/evidence/disposition/routing claims hold;
- `VALIDATED-WITH-CORRECTIONS <exact corrections>` — central delta/recommendation holds after
  bounded corrections supplied by this report;
- `VALIDATED-PARTIAL <accepted / rejected portions>` — only a subset is safe to bank;
- `REJECTED-FOUNDATION-REVIEW <reason>`; or
- `BLOCKED IDENTITY-DRIFT <fact>`.

Attach confidence 1-10. State separately whether the four architecture/evidence scores are
reasonable ranges or require replacement. Recommend `BANK-AS-VALIDATED-FOUNDATION-INPUT` only if
the corrected result is sufficient to shape a future id-042 runtime brief; never recommend ship
acceptance or retirement of unrelated ops.

Markers: `VDS4P_OP320_VERDICT`, `VDS4P_OP320_TERMINAL`

## REQUIRED RETURN

```text
REPORT
op:                    op-320
validator:             Validator3
input_identity:        <op-319 note identity match/drift>
source_delta:          <four per-commit verdicts>
round1_disposition:    <exact counts, no approximations>
mach_map:              <validated/corrected/rejected>
dispatch_map:          <validated/corrected/rejected>
evidence_provenance:   <local/origin/raw classification>
control_gaps:          <exact counts by the four allowed classes>
preview_bar:           <validated/corrected/rejected>
scores:                <Mach arch/evidence; dispatch arch/evidence>
verdict:               <one G8 verdict>
confidence:            <1-10>
disposition:           <BANK-AS-VALIDATED-FOUNDATION-INPUT or DO-NOT-BANK>
boundary:              read_only=1 builds=0 target_exec=0 guest_cells=0 writes=0
terminal:              complete
```

Required markers:

```text
VDS4P_OP320_INPUT_IDENTITY
VDS4P_OP320_SOURCE_DELTA
VDS4P_OP320_ROUND1_DISPOSITION
VDS4P_OP320_MACH_MAP
VDS4P_OP320_DISPATCH_MAP
VDS4P_OP320_EVIDENCE_CONTROL
VDS4P_OP320_PREVIEW_BAR
VDS4P_OP320_VERDICT
VDS4P_OP320_TERMINAL
```

## RELATIONS / FEEDBACK

op-223 → op-319 → op-320; id-042 final candidate; li-1001/li-1002 foundation;
li-1007 all-up; li-1013 regime/evidence; li-9007/id-043 deferred generic LARGE.

feedback: `verify_premise_before_mechanism`, `code_reasoned_verdict_is_hypothesis`,
`artifact_identity_needs_content_check`, `no_conflate_gating_with_readiness`,
`validator_not_oracle_for_correctness`, `agent_host_isolation`,
`op_state_dispatch_boundary`.
