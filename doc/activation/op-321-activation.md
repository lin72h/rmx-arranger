# op-321 — Validator-GLM: gate op-318 PID-1 topology, image/BOM, containment-helper contract, reaper controls, and next-chain disposition

op-321 | role: **Validator — independent XL source/evidence/safety gate** | EXU:
**Validator3 session (Coordinator substitution for Validator-GLM)** | state: **[Retired —
VALIDATED-WITH-CORRECTIONS confidence 7/10; Arranger Arbiter final call PREP-NOT-ACCEPTED;
replacement op-322 Ready]** | DISPATCH: **CONSUMED — no Implementer stage or guest cell
released** | parent: **op-318 / id-016 / id-042** | L1i:
**li-1006 / li-008 / li-1013** | relations: **retired op-200/op-201/op-315/op-317;
held op-202/op-203/op-279/op-280** | authored: **2026-07-17 by Arranger2**

## RETURN / ARBITER FINAL CALL — 2026-07-17

The Coordinator explicitly substituted Validator3 for Validator-GLM. Validator3 returned
`VALIDATED-WITH-CORRECTIONS`, confidence **7/10**, and recommended
`RETURN-TO-EXPLORER-CORRECTION`.

Arranger Rules 6/11 require narrow Arbiter adjudication below 9; the older governing threshold
also requires step-in below 8. The Arranger reverified the decisive evidence first-hand:

- `run-guest.sh:75-87` executes interpolated command strings through `sh -c`;
- `stage-guest.sh:253-277` checks only nonempty/file inputs, selects the first UFS partition, and
  performs privileged `tee -a`; the guard is image-attachment-only;
- op-318's proposed self-test would write physical `/etc/rc.conf`, which is prohibited;
- `jobmgr_reap_pid` is userspace launchd code (`core.c:7232+`), so kernel FBT cannot probe it;
- `last_exit_status` stores the raw `wait4` status and exports it directly (`core.c:1107-1112,
  3725-3727`), so exit 1 is not the integer 1 and signal death must use wait macros;
- `PREMISE-CONFIRMED` cannot include an entirely falsified/non-observed premise;
- a product panic/death under a valid identity-correct workload is product evidence, not
  infrastructure failure;
- `jobmgr_init` contains no source-certain `/etc/launchd.d` scan, while SIGTERM only logs/breaks;
  those behaviors remain runtime owed;
- SIGUSR1→`RB_HALT`, the EVFILT_SIGNAL calendar callback, and the sanity-check `raise(SIGUSR1)`
  coexist in tip source; zero shipped calendar plists does not erase external SIGUSR1 risk.

Final call: **PREP-NOT-ACCEPTED AS IMPLEMENTER/RUNTIME CONTRACT**. Bank only the corrected partial
facts: PID-1/non-`-u` topology intent, no acceptable current image base, disposable/production
image separation, the 18-row census, existing-helper deficits, and the named SIGUSR1 risk. The
unsafe/invalid helper and reaper controls are superseded by bounded Explorer correction op-322.
No legacy op is flushed; op-202/op-203/op-279 contract content must be migrated or explicitly
superseded, and op-280 remains conditionally held.

## OBJECTIVE

Independently gate Explorer op-318 before any Implementer helper/image stage. Verify the frozen
PID-1 topology, no-acceptable-base census, source-artifact→in-image BOM, 18-row activation delta,
post-incident containment requirements, one-cell reaper plan, and seven-step role split. Correct
unsafe, false-green, technically invalid, or overclaimed controls. Decide whether op-318 is a sound
contract input for a new Implementer containment-helper/disposable-image op.

Do not validate PID-1 runtime, authorize a guest cell, write a helper, select a production image,
flush legacy ops, or make a ship/readiness decision.

Arranger intake reproduced the return identity and sized it XL. It also identified load-bearing
questions that must not be normalized silently:

1. Unchanged launchd source does not prove op-278's `bcdc0e5e...` binary reproduces without an
   exact build environment; the note partially acknowledges this only at its confidence line.
2. The proposed helper self-test says to simulate a host delta by writing physical
   `/etc/rc.conf`. No test may mutate real host configuration. Use a fixture/injected inventory
   root or other non-host state.
3. `ps -p 1 -o comm=` normally yields a command name, not necessarily `/sbin/launchd`;
   `procstat -binary 1` output cannot itself be hashed as the executable without extracting and
   hashing the actual mapped/path object. Verify the exact target commands and grammar.
4. Confirm proposed DTrace probes/providers/arguments exist on this FreeBSD target. In particular,
   distinguish kernel FBT syscall bodies from libc `waitpid` and bind ECHILD to an observable,
   valid probe rather than a label.
5. Confirm launchctl `LASTEXITSTATUS` representation for exit 0/1 and SIGSEGV. Do not equate a
   signal name, signal number, wait status, and shell `128+signal` without source/runtime evidence.
6. The proposed known-bad fixture uses `launchctl setenv` to publish a fake status, but it is not
   shown to influence the observed kernel/launchd exit record or to test the detector. Establish a
   true fail-closed mutation/control or reject the fixture.
7. `PREMISE-CONFIRMED` says each hazard may be observed **or falsified**. A falsified/non-observed
   hazard cannot make a positive premise-confirmed verdict. Require per-axis outcomes and an
   unambiguous aggregate classification.
8. A panic or launchd/guest crash during a valid, identity-correct workload may be product evidence,
   not automatically `INFRASTRUCTURE-NOT-ACCEPTED`. Separate product failure from bad cell/host
   infrastructure.
9. Verify whether zero shipped `StartCalendarInterval` plists is enough to bank the PID-1
   SIGUSR1→halt collision, given external SIGUSR1 remains source-reachable. Do not revive flushed
   op-289/op-290; return a scope recommendation only.
10. Recommendations to flush op-202/op-203/op-279 and normalize op-280 are not accepted until this
    gate establishes whether their useful contracts can be preserved without ID churn.

## EXECUTION / WRITE BOUNDARY

Read-only Validator work. Write no product, Arranger, Explorer, Gatekeeper, image, host, or other
repository file. No build, target execution, `dlopen`, preload, guest, image mount/stage/mutation,
privilege, host configuration, network, commit, push, op/ID allocation, dispatch, release,
retirement, or ship decision.

Use static source/Git inspection, hashing, and existing evidence only. State unavailable
reproduction. Return in chat. Attach confidence 1–10. Confidence 9+ transfers the verification
labor but closes no id-042 box and authorizes no implementation/runtime action by itself.

## PINNED INPUTS — STOP `BLOCKED IDENTITY-DRIFT <fact>` ON LOAD-BEARING MISMATCH

Explorer repository `/Users/me/wip-mach/rmx-explorer/`:

- branch `main`, `HEAD=9355ad42e2647846e601ae2200507daefd59ce74`;
- parent `332e159bd719f7f4841c7a0f8ebe2d43461f470d`;
- `origin/main=f8006a3dbf6edb970e1ab0f5b19c2fb386731666`, ahead/behind `2/1`;
- tracked tree clean; exactly these three untracked paths:
  `findings/nx-r64z/dtrace/op195-serial-v2.log`,
  `lib/rmx_os_oracle/id025/integration_soak_conductor.ex`, `python3.11.core`;
- commit changes exactly one new 436-line note; no push.

Explorer deliverable:

- `/Users/me/wip-mach/rmx-explorer/findings/nx-r64z/20260712-op318-pid1-preview-activation-contract.md`;
- 48,127 bytes / 436 lines / SHA-256
  `180361ecdc772e2a63ca6ba05c76797524729314feb9ad7cb26056e834b73dfe`.

Canonical op-318 activation after return intake:

- `/Users/me/wip-mach/rmx-arranger/doc/activation/op-318-activation.md`;
- 14,281 bytes / 280 lines / SHA-256
  `bc23b86d30bf502d0aed296da93226696077aa69bd2536277a4c39af7120e1c6`;
- state `[Done]` means returned, not accepted or retired.

Product `/Users/me/wip-mach/wip-gpt/wip-rmxos/`:

- clean, origin-aligned `alpha@26655e67872cd55cff0a272b32b7895f55368033`;
- tree `aa9d4f44716b0793ca4de6ae67c7d819cf7ab15d`;
- launchd pins from op-318: `runtime.c` SHA-256 `b7823622...59ec8`, `core.c`
  `ff2dbec2...dd07`, `launchd.c` `a9c96d6b...50e`;
- op-278 accepted launchd artifact claim: SHA-256
  `bcdc0e5e54015dffd7ef32430665d169bd388478ff10405ef9d3ed33fd4ca897`;
  treat it as a historical artifact pin unless the build environment and new artifact reproduce.

Existing staging inputs:

- `/Users/me/wip-mach/wip-gpt/scripts/bhyve/stage-guest.sh` SHA-256
  `6753c0b179c5a9ef6de02583feea7a8083673fb83ed0a02047c492597a5a3cf1`;
- `image-staging-guard.sh` SHA-256
  `b92e97f5df38b9ce9c22588cd2da81246130b20a7e18810d5ffd4676404a19a2`;
- `run-guest.sh` SHA-256
  `251ab6ddc5b09e333629cd7be5450c480b39be8acb2d70dfb5b1bbc88d2d8630`.

Control inputs:

- `doc/host-guest-isolation-incident-2026-07-11.md`: 9,214 bytes / 161 lines / SHA-256
  `a93981176b34caab2743380506f3563fb429b9ce47caff1093f652bc11169c66`;
- `idq/id-016-ambient-mach-bootstrap-port.md`: SHA-256
  `20c770954c64cbdc685f60acd2a437eddfd115ef87a1db0b671e85cc97c4ad3a`;
- op-202/op-203/op-279/op-280 activation SHA-256 respectively:
  `7c87c1ca3de1c49dfa18838912e86a7d6fa17db559aaec8941338c0183df8e62`,
  `c95068c59cd5ca24ed5d436c652a2d28bc30b1720ce2480f4e500c770ea624c8`,
  `c6c2ab907168e767fbd200079f00b66a42acb67ce649b91a43e3dea2232acba5`,
  `0d275d1069e26f1af1cf0836f0c4d18c2e5431c0c24fa6117837a5296d52f1cb`.

The active op-321 Ready header and id-042 routing entry are expected control deltas, not input
identity drift. Stop on product, Explorer note/commit, source, incident, or legacy-op drift.

## REQUIRED READS

Read completely:

- op-318 note and activation;
- op-200/op-201/op-315 notes and op-317 return/activation where a claim depends on them;
- op-202/op-203/op-279/op-280 activations;
- id-016 and id-042;
- the host-isolation incident;
- all three staging scripts and directly sourced/executed helpers;
- bounded product source for launchd admission/PID-1 init, launchd.d scanning, rc-chainload,
  root-rw/single-user/shutdown paths, StartInterval/StartCalendarInterval/SIGUSR1,
  waitpid/reaping/LASTEXITSTATUS, plus the cited plist/Makefile paths.

## G1 — IDENTITY / DELIVERABLE COMPLETENESS

Verify every pin first-hand, one-file commit scope, clean tracked tree, exact untracked census,
all eight `EXPLORER_OP318_*` markers, Q1–Q6 coverage, terminal verdict, and boundary. Correct the
note's pre-commit Explorer HEAD wording versus result commit without calling honest input identity
drift. Report publication: local commit, divergent `2/1`, not origin-reachable.

Marker: `VGLM_OP321_INPUT_IDENTITY`.

## G2 — PID-1 TOPOLOGY / CURRENT SOURCE

At exact source/evidence, validate or correct T1–T6:

- `init_path=/sbin/launchd`, PID 1, non-`-u`, `pid1_magic`;
- exact launchd.d scan mechanism/directory and rc-chainload ordering;
- ownership/order of `/etc/rc`, plists, base services, getty, shutdown/reboot/single-user;
- op-201 root-rw residual and ambient bootstrap evidence;
- removal/inerting of the old rc.local generic loader without creating duplicate starts.

Keep historical op-200/op-201 runtime separate from current-tip source support and candidate-runtime
debt. Classify each T-row `CONFIRMED`, `CORRECTED`, or `UNPROVEN`.

Marker: `VGLM_OP321_PID1_TOPOLOGY`.

## G3 — IMAGE CENSUS / BOM / ARTIFACT IDENTITY

Verify the bounded image census supports `NO-ACCEPTABLE-BASE`. For every accepted/rejected
candidate claim that drives the conclusion, check existence, lineage, and in-image proof limits.
Validate the disposable-versus-production image split and each required BOM class/path.

Explicitly rule on the op-278 binary statement:

- source unchanged = source equivalence only;
- binary equality requires exact build environment/artifact reproduction;
- a newly accepted hash may replace `bcdc0e5e...` if independently built/pinned and BOM-equal.

Return the minimum exact inputs an Implementer stage needs without choosing the image or building.

Marker: `VGLM_OP321_IMAGE_BOM`.

## G4 — ACTIVATION DELTA / PID-1 SIGNAL RISK

Reproduce all 18 rows and exact counts. Verify product-wide plist/source census for
`StartCalendarInterval` and `StartInterval`, the aslmanager.once semantics, and the source chain
from calendar sanity/SIGUSR1 to PID-1 halt.

Separate:

- no shipped calendar consumer;
- external/accidental SIGUSR1 reachability;
- source defect versus currently activated workload;
- preview scope recommendation versus product acceptance.

Do not revive op-289/op-290 or allocate an ID. State whether id-016/id-042 must retain a named
PID-1 signal-ownership risk before productionization.

Marker: `VGLM_OP321_ACTIVATION_DELTA`.

## G5 — CONTAINMENT HELPER CONTRACT

Verify each claimed deficit in the three current scripts at exact lines. Gate the proposed
`rmx-stage-image` and `rmx-run-cell` contract against the incident's permanent controls and Rule-12
repository ownership.

Required corrections/decisions:

- exact owning repository and Implementer-owned paths;
- all rejection checks occur before privilege where possible;
- explicit argv, atomic install, correct mount/device/image/sentinel checks, lock and cleanup;
- complete before/after host inventory and fail-closed BOM/in-image hashes;
- no test, including simulated-delta negative control, writes real host `/etc`, `/boot`, modules,
  loader configuration, or other protected paths;
- self-tests use fixtures/injected inventory roots or non-host mock state;
- no arbitrary privileged shell/heredoc/tee/redirection;
- target execution only after a guest-runtime marker and exact image identity;
- distinguish helper source/build tests, disposable image stage, and later guest cell.

Return `CONTAINMENT-CONTRACT-SOUND`, `CONTAINMENT-CONTRACT-CORRECTABLE <items>`, or
`CONTAINMENT-CONTRACT-NOT-READY <items>`.

Marker: `VGLM_OP321_CONTAINMENT`.

## G6 — REAPER PLAN / FAIL-CLOSED CONTROLS

Validate the proposed one-cell plan at source and command/probe semantics. For each observation,
state whether it is executable and distinguishing on the target:

- PID/executable/non-`-u`/BOM identity commands;
- managed and unmanaged W1–W5 construction without contaminating product config;
- DTrace provider/probe/argument availability for reaping and ECHILD;
- LASTEXITSTATUS/wait-status/signal representation;
- zombie and per-thread CPU measurement;
- panic/KASSERT/survival/service observations;
- ordered marker grammar, manifest, final inventory, shutdown, attempt ownership;
- known-good and true known-bad detector controls.

Require per-axis results for hazards (a), (b), and (c): `OBSERVED`, `NOT-OBSERVED`, or
`INCONCLUSIVE`. Define a non-contradictory aggregate verdict. A valid-workload product panic,
launchd death, or corrupt exit accounting must not be hidden as infrastructure failure; an image,
identity, host, capture, or harness failure must not be promoted to product evidence.

Return a corrected minimal plan or `REAPER-PLAN-NOT-READY`; do not execute it.

Marker: `VGLM_OP321_REAPER_PLAN`.

## G7 — ROLE SPLIT / LEGACY OP DISPOSITION

Validate the seven-step role/repository chain and one-op/one-pipeline boundaries. Decide whether
the **contract content** of op-202/op-203/op-279 can be preserved through normalization or whether
new op numbers are necessary; decide the same for conditional op-280. Do not edit/flush/release
them.

Return one exact recommended next hop:

- `RELEASE-NEW-IMPLEMENTER-HELPER-STAGE-BRIEF` only if G2–G6 are exact/corrected enough;
- `RETURN-TO-EXPLORER-CORRECTION <bounded items>` if specification work remains; or
- `BLOCKED <fact>`.

Marker: `VGLM_OP321_ROLE_SPLIT`.

## G8 — VERDICT / CONFIDENCE

Return exactly one:

- `VALIDATED-PID1-CONTRACT`;
- `VALIDATED-WITH-CORRECTIONS <corrections>`;
- `PREP-NOT-ACCEPTED <defects>`;
- `BLOCKED IDENTITY-DRIFT <fact>`.

Attach confidence 1–10. State separately:

- whether op-318 may retire/bank as corrected contract input;
- whether a new Implementer helper+disposable-image brief may be authored;
- whether any legacy-op disposition is recommended;
- that no stage/cell/product/ship action is performed or automatically authorized.

Markers: `VGLM_OP321_VERDICT`, `VGLM_OP321_TERMINAL`.

## REQUIRED REPORT

```text
REPORT
op:                    op-321
validator:             Validator-GLM
input_identity:        <MATCH/BLOCKED>
pid1_topology:         <CONFIRMED/CORRECTED/UNPROVEN summary>
image_bom:             <NO-ACCEPTABLE-BASE supported/corrected/rejected>
activation_delta:      <18-row result + SIGUSR1 scope>
containment:           <SOUND/CORRECTABLE/NOT-READY>
reaper_plan:           <SOUND/CORRECTED/NOT-READY>
role_split:            <exact next hop + legacy-op recommendation>
verdict:               <one G8 verdict>
confidence:            <1-10>
boundary:              read_only=1 builds=0 target_exec=0 guest_cells=0 writes=0
terminal:              complete
```

Required markers:

```text
VGLM_OP321_INPUT_IDENTITY
VGLM_OP321_PID1_TOPOLOGY
VGLM_OP321_IMAGE_BOM
VGLM_OP321_ACTIVATION_DELTA
VGLM_OP321_CONTAINMENT
VGLM_OP321_REAPER_PLAN
VGLM_OP321_ROLE_SPLIT
VGLM_OP321_VERDICT
VGLM_OP321_TERMINAL
```

REPORT

```text
op: op-321
agent: Validator-GLM
dispatch: independent XL op-318 PID-1 contract gate complete
next-hop: Arranger consumes the confidence verdict; no Implementer stage or guest cell releases automatically
```

## RELATIONS / FEEDBACK

op-200→op-201→op-318→op-321; retired op-315/op-317; held op-202/op-203/op-279/op-280;
id-016/id-042; li-1006/li-008/li-1013.

feedback: `agent_host_isolation`, `artifact_identity_needs_content_check`,
`verify_premise_before_mechanism`, `code_reasoned_verdict_is_hypothesis`,
`no_conflate_gating_with_readiness`, `launchd_no_autoscan`, `build_is_implementer`,
`soak_is_gatekeeper`, `op_state_dispatch_boundary`, `one_op_one_pipeline`.
