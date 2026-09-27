# op-316 — Validator-DS4P: gate the op-313 Mach invariant / MACH_RCV_LARGE consult

op-316 | role: **Validator — independent L-sized source/evidence adjudication** | EXU:
**DS4P Validator session** | state: **[Retired — returned confidence-9
VALIDATED-WITH-CORRECTIONS but omitted the public-scope condition and load-bearing trailer portions
of G3–G5; Arranger2 narrow conflict adjudication accepts the invariant/syscall-`LARGE`/control spine
and rejects the unconditional bank/current-workload-adequacy conclusions]** |
parent: **op-313 / id-042** | relations:
**op-281 [Flushed] / op-282 [Flushed] / li-9007 / id-043 / closed id-036 / retired id-009** | authored:
**2026-07-11 by Arranger2**

## ARRANGER CONSUMPTION — 2026-07-11

Validator-DS4P returned `VALIDATED-WITH-CORRECTIONS`, confidence 9/10. Arranger2 reproduced the
pinned note/product identities and returned markers. The report nevertheless omits the explicit
G5 public-scope condition and the load-bearing trailer-mode/capacity/arithmetic work commissioned
across G3–G5, so Rule 11's conflict path requires narrow Arranger adjudication rather than automatic
confidence-9 consumption.

**Accepted:** the li-1001 control gap, three receive mechanisms, non-trailer syscall-`LARGE`
consumer census, op-247/op-253 control limits, op-282 brief incompleteness, and the bounded op-108
correction. The retained raw serial does identify `MACHDEBUGDEBUG` and WITNESS.

**Rejected/withheld:** the report says the census justifies banking without preserving the required
explicit Coordinator public/external-caller scope condition. Its table records `LARGE` flags but
does not provide the commissioned active-caller trailer modes/capacities, omits the
8,192/8/52/44-byte arithmetic, and calls current workloads adequately provisioned without runtime
evidence. Those trailer portions of G3–G5 and the bank conclusion do not pass.

Routing after the split adjudication:

- At split adjudication, banking syscall-`LARGE` remained conditional on an explicit Coordinator
  ruling that external/public callers were outside the 1.0-preview contract. Source census could
  not make that scope decision, so op-281/op-282 stayed [Hold] until the final route below.
- The Validator was commissioned to settle the trailer arithmetic but did not. Arranger first-hand
  source adjudication rejects its unsupported “adequately provisioned” sentence: an 8,192-byte
  receive structure reserves an 8-byte minimum trailer while requesting a 52-byte audit trailer.
  Masked admission can accept message sizes through 8,184 although the full audit-trailer exact fit
  is 8,140; sizes 8,141–8,184 imply a 1–44-byte conceptual boundary overrun. Runtime behavior is
  carried by existing preview IDQ id-021 rather than a new Mach IDQ or the syscall-`LARGE` bank
  decision.

The current-tip invariant replay folds into id-042's exact-final-candidate certification, avoiding
a stale standalone run before op-314 and remaining product work land. This explicit split
adjudication closed op-316's gate work and retired it; op-313 remained [Done] until the Coordinator
issued the final scope disposition below.

## FINAL COORDINATOR ROUTE — 2026-07-11

The Coordinator excludes external/public syscall-`LARGE` callers from 1.0-preview. op-281/op-282
are flushed without dispatch and the future contract is preserved under li-9007/id-043. The active
libxpc trailer boundary remains under id-021. op-313 retires, completing this lineage.

## OBJECTIVE

Independently determine whether Oracle2's reassigned op-313 consult is accurate enough to support
control-state routing. This is validation of a dated read-only analysis—not a product test, release
verdict, or permission to bank/fix anything.

Exact deliverable:

`/Users/me/wip-mach/rmx-oracle2/op-313-li-1001-preview-quality-control.md`

- 42,409 bytes / 329 lines;
- SHA-256 `fd46d7a3a2242533956cbf331fbc64946a2a72352a39100dcc5f5c0653f08dec`;
- terminal `CONSULT-COMPLETE`;
- executing EXU Oracle2 by direct Coordinator reassignment after Oracle1 produced no deliverable.

## DISPATCH / REPOSITORY BOUNDARY

DISPATCHED by the Coordinator to the one named DS4P Validator on 2026-07-11. The relayed Ready
brief was 9,342 bytes / 181 lines / SHA-256
`d620812d83eae26d52dd5782bf0824653d4dfcbe94a81a40a2ace9ae30e3ef81`.

Read every load-bearing source/evidence body first-hand. Return the validation report in the
Validator session only. Do not edit or create files in the product, Arranger, Oracle, Explorer,
Gatekeeper, host configuration, image, or any other repository. No build, runtime probe, target
execution, `dlopen`, guest, privilege, image staging, commit, push, ID/op allocation, retirement,
milestone ruling, or release decision.

## PINNED INPUTS

Product repository `/Users/me/wip-mach/wip-gpt/wip-rmxos/`:

- clean `alpha@40c8a93d4b3fec707b2e6ecd7762a1b20948e6e3`;
- `origin/alpha` and live remote equal that commit;
- tree `1b34024c749b5b6f4befe1fb8838a1e197e400d7`.

Load-bearing product sources and exact identities are tabulated in §1 of the note. Reproduce at
least `mach_msg.c`, `ipc_mqueue.c`, `ipc_pset.c`, libmach `mach_msg.c`, libdispatch `source.c` and
`init.c`, and `lib/libdispatch/Makefile` before reasoning.

Primary evidence roots:

- `/Users/me/wip-mach/rmx-gatekeeper/` — op-108 disposition, op-123 traces, op-247/op-253 raw and
  launchers/findings;
- `/Users/me/wip-mach/rmx-explorer/findings/nx-r64z/dtrace/` — soak detector/driver/harness and Mach
  detector contract;
- `/Users/me/wip-mach/build/block-078-runtime-smoke/runs/` — external op-105/op-108 raw records;
- `/Users/me/wip-mach/nx/ravynos/` — bounded donor source comparator only.

The control tree advanced after the note's observation: id-042 now carries the concrete preview
TODO, op-314's final refinement is bound, and op-313's EXU/state record is corrected. These are
freshness deltas. Product source remains at the pinned commit. Determine whether any control delta
changes the consult's reasoning; do not reject a dated identity merely because the live record was
properly advanced afterward.

## REQUIRED GATES

### G1 — input, reassignment, and publication identity

Reproduce the note identity and a risk-based sample of all commissioned/supplemental artifacts,
including every load-bearing raw used in the verdict. Confirm the publication classes and the
op-253 host-as-serial hash swap. Confirm the direct Oracle2 reassignment is disclosed and does not
masquerade as an Oracle1 return.

### G2 — literal li-1001 bar versus historical evidence

Verify each current li-1001 predicate separately:

- send/receive conservation under the actual workload;
- port allocation/destruction balance;
- no stuck enqueue;
- dead-name delivery;
- sustained-load survival of the retired pset-UAF regression.

Read the detector and workload bodies—not only their summaries. Test the note's claims that the
DTrace oracle prints counters but has no rejection predicate, `-Z`/wait handling can fail open, the
driver prints unconditional success, and the workload deliberately leaves a Mach message unread
while returning zero despite `g_fails`. Distinguish historical UAF survival from present-tip
fail-closed proof. Address the roadmap no-senders versus current li-1001-row mismatch explicitly;
do not silently select a threshold.

Correct one known intake discrepancy explicitly: the retained op-108 raw serial is not silent about
the kernel regime. Its boot banner says `MACHDEBUGDEBUG` and it reports WITNESS enabled. Reproduce
those raw lines and assess whether that narrows only the note's regime/publication classification or
changes any central quality-control conclusion. Do not accept the note's statement that the exact
regime is absent merely because the disposition summary omits it.

### G3 — three receive mechanisms and contract obligations

Source-trace and keep separate:

1. synchronous syscall queue-first receive;
2. synchronous syscall receive-first/blocked delivery;
3. readiness-only and direct-kevent dispatch Mach mechanisms.

Verify option masking, trailer-size admission, kmsg retention/consumption, `ith_msize`/identity,
user-visible copyout, blocked wake state, and same-message retry. Decide whether the note correctly
shows that merely forwarding one option word is insufficient and whether op-282's current brief is
materially incomplete at the result-copyout/wake-state sites.

Do **not** conflate the syscall-`LARGE` consumer census with trailer exposure. Separately identify
active non-`LARGE` callers that request non-minimum trailers, the actual receive-buffer capacity
they provide, and whether masking trailer bits at `mach_msg.c:372` can admit a message that later
copies beyond the declared capacity. In particular, inspect libxpc's requested trailer mode and
fixed receive structures. State whether this is merely cataloged/adequately provisioned or a
distinct live preview premise.

### G4 — preview consumer census

Re-run a build-aware source census, not a symbol grep. Confirm or correct:

- ordinary notifyd, ASL, launchd, libnotify, and libxpc receive flags;
- their requested trailer modes and actual buffer capacities, including active callers that do
  not set `LARGE`;
- readiness-only versus direct-kevent libdispatch paths;
- `dispatch_mig_server` implementation/build state;
- all in-tree callers, especially Heimdal's `__APPLE__ && HAVE_GCD` guards and the live generated
  configuration;
- the exact limit of the conclusion: the built libdispatch contains a syscall-`LARGE` retry
  implementation, but no **in-tree preview consumer found by the census activates that family**;
  installed external/third-party/public-API reachability remains unknown.

### G5 — existing controls and routing proposal

Verify that op-247/op-253 proves the no-`LARGE` op-249 panic regression only: Probe A omits
`LARGE`; Probe B exits 139 before exercising its target; the launcher does not fail closed; only
notify is exercised; probe binary/source identity and raw publication are incomplete. Then assess
the three routing proposals without actioning them:

- current-tip, workload-aware fail-closed invariant replay;
- bank/flush op-281/op-282 for no proven live preview consumer;
- conditional re-authoring if a future concrete IDQ promotes the public contract.

State whether each follows from verified facts, whether a new concrete IDQ is warranted, and
whether any recommended evidence can be folded into id-042's final current-tip certification
instead of creating duplicate work.
If `LARGE` is bankable but an active trailer-admission premise is not, split those dispositions;
do not accept a whole-chain bank merely from the narrower no-syscall-`LARGE` census.
Treat any `LARGE` bank recommendation as conditional on an explicit Coordinator scope ruling that
external/public callers are outside the 1.0-preview contract; the census alone cannot make that
policy decision. For the trailer premise, reproduce libxpc's fixed 8,192-byte receive structure,
its 8-byte reserved minimum trailer, and its requested 52-byte audit trailer. Decide whether the
44-byte difference can cross the admitted receive limit when trailer option bits are masked. If
supported, recommend a separate id-021/new-IDQ runtime premise with exact-fit and one-byte-short
negative cells; do not hide it behind op-281/op-282's `LARGE` disposition.

## REQUIRED VERDICT

Return exactly one:

- `VALIDATED-CONSULT` — central findings and routing recommendations materially hold;
- `VALIDATED-WITH-CORRECTIONS <bounded corrections>` — usable after named non-central fixes;
- `NOT-VALIDATED <load-bearing failure>`.

Attach confidence 1–10. If confidence is below 9, or if the threshold/role doctrines conflict,
stop for Arranger/Coordinator adjudication. A confidence-9/10 verdict still validates only the
consult; the Arranger/Coordinator separately decide IDQ/op disposition.

Report exact identities, source-cited G1–G5 findings, sampling/unavailable reproduction, current
freshness deltas, and one proposal-safe next-route recommendation.

Markers:

```text
VDS4P_OP316_INPUT_IDENTITY
VDS4P_OP316_LI1001_BAR
VDS4P_OP316_RECEIVE_PATHS
VDS4P_OP316_CONSUMER_CENSUS
VDS4P_OP316_CONTROL_ADEQUACY
VDS4P_OP316_ROUTING
VDS4P_OP316_TERMINAL
```

feedback: `oracle_consult_is_hypothesis`, `artifact_identity_needs_content_check`,
`verify_premise_before_mechanism`, `no_conflate_gating_with_readiness`,
`op_state_dispatch_boundary`, `agent_host_isolation`
