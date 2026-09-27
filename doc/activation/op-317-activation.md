# op-317 — Validator-DS4P: gate op-315 launchd reaper preflight, preview relevance, and staging/containment completeness

op-317 | role: **Validator — independent L-sized source/scope/safety gate** | EXU:
**Validator-DS4P session** | state: **[Retired — confidence-9
VALIDATED-PARTIAL-BANK-PID1 consumed with a narrow identity correction on 2026-07-12; no image,
runtime, or fix released. Coordinator later required PID-1 for preview; op-318 owns the missing
exact contract.]** | parent:
**op-315 / op-279 / id-016 / id-042** | L1i: **li-1006 launchd core service** | relations:
**op-200/op-201 PID-1 calibration; held op-280 fix; host-isolation incident** | authored:
**2026-07-12 by Arranger2**

## ARRANGER CONSUMPTION — 2026-07-12

Validator-DS4P returned `VALIDATED-PARTIAL-BANK-PID1`, confidence 9/10. Arranger2 accepts:

- the source-premise classification and runtime-only boundary;
- correction of “only valid non-`-u` topology” to “only proven named topology”;
- image stage `PARTIAL`, fail-closed plan `PARTIAL`, and containment `PARTIAL`;
- no op-279/op-280 release; and
- the routing fork between post-preview PID-1 banking and a new current-preview `-u` premise.

Narrow identity correction: the report's “all identities verified byte-for-byte” is not literally
true against the live control tree. It reproduced the pinned pre-dispatch op-279 identity
`dc6808c1...` and pre-routing id-016 identity `e0df0c9d...`; during normal control progression those
files changed only to record op-317 `[Ready]→[Exe]` and the op-315→op-317 routing note. Current
product/Explorer/note/source identities remain exact, and first-hand inspection confirms those
control deltas change neither the preview doctrine nor the source premise. The substantive
confidence-9 verdict is accepted with that correction rather than promoted to a false exact-match
claim.

Further correction: op-315 is consumed and retires; it must not receive a rewritten addendum.
Any later Explorer correction receives the then-next free project op. An Implementer stage cannot
be next because the exact base/BOM/helper/containment contract is absent.

**Disposition: RETIRED.** op-317 leaves the ROB. op-315 also retires as a useful partial source
record. op-279/op-280 remain held pending the Coordinator choice: keep PID-1 evidence entirely
post-preview and bank/flush the current briefs, or require a fresh Explorer-owned current-preview
`-u` premise. No product, image, runtime, cell, or fix is released by this consumption.

## CONTEXT / DECISION

Explorer op-315 returned a useful source premise but called op-279 blocked only on an Implementer
image stage. The return selects PID-1 `init_path`, while op-200/op-201 explicitly routed PID-1
productionization/robustness to post-preview op-202/op-203, and it omits several exact staging,
fail-closed, and containment fields commissioned by op-315. Independently decide whether any
1.0-preview runtime work is warranted and whether the returned preflight is complete enough to
release it.

## DISPATCH / EXU BOUNDARY

**DISPATCHED by the Coordinator on 2026-07-12.** The read-only/no-runtime boundary remains binding.

Read-only Validator work. Do not write product, Arranger, Explorer, Gatekeeper, Oracle, image,
host configuration, or another repository. No build, mount, staging, privilege, target execution,
`dlopen`, preload, guest boot, runtime probe, cell, commit, push, ID allocation, op issue, release,
or retirement. Return the verdict to the Coordinator/Arranger only.

## PINNED INPUTS — STOP `BLOCKED IDENTITY-DRIFT <fact>` ON MISMATCH

Explorer repository `/Users/me/wip-mach/rmx-explorer/`:

- branch `main`;
- op-315 commit `332e159bd719f7f4841c7a0f8ebe2d43461f470d`;
- parent `206b5a36e78de29ae6e519a836406972aa9b7ac5`;
- `origin/main=f8006a3dbf6edb970e1ab0f5b19c2fb386731666`;
- exactly one added committed path:
  `findings/nx-r64z/20260711-op315-launchd-reaper-premise-preflight.md`;
- note 12,871 bytes / 241 lines / SHA-256
  `5d221ef98b4a76d4bec970d6e46b596d6c693d1e6d0114ecf1637ebae0d20401` / blob
  `478d4cb6cb0d0b934f419834635dda942a9acc83`;
- tracked tree clean, with the three pre-existing untracked paths reported in op-315 preserved.

Product repository `/Users/me/wip-mach/wip-gpt/wip-rmxos/`:

- clean, origin-aligned `alpha@26655e67872cd55cff0a272b32b7895f55368033`;
- tree `aa9d4f44716b0793ca4de6ae67c7d819cf7ab15d`;
- no `sbin/launchd` delta from the op-315 pin `40c8a93d` to current origin;
- `runtime.c`: 39,762 bytes / 1,584 lines / SHA-256
  `b7823622f793aa0d0827e3adde28c45d2ef30f9f5c083e6344ca6e771c859ec8` / blob
  `d87e749eb96e940cadabea33609c018687f5c2b1`;
- `core.c`: 333,020 bytes / 12,133 lines / SHA-256
  `ff2dbec2a30db9905235db628c0088334de09a72381be86a880f2304bc19dd07` / blob
  `e9ac1dca60aabe416a7bada98320384da622cc80`;
- `launchd.c`: 17,328 bytes / 705 lines / SHA-256
  `a9c96d6b84241134c9a5bd694fa66b5532dbc9363b25da3f26645205b7ea650e` / blob
  `be81cddead0a6a7fd0576e829af393d2e7c80602`.

Control inputs:

- `doc/activation/op-315-activation.md`: 12,620 bytes / 252 lines / SHA-256
  `fd8dbc14315b4b8d0863e81be5c1b14166cbc47897fabcce2b8d3449750304f0`;
- `doc/activation/op-279-activation.md`: 5,779 bytes / 46 lines / SHA-256
  `dc6808c119ae2613d2a45fe40eb022eab560d0215e8d2f5b1de833c0ca566b5c`;
- `doc/activation/op-280-activation.md`: 3,522 bytes / 28 lines / SHA-256
  `01fdd2d6f4c625a459fc424416f7fd345949cbef3e593cecd00546b31d9b0e79`;
- `doc/activation/op-200-activation.md`: 9,271 bytes / 47 lines / SHA-256
  `ea54bcbc6d25afa25e58b5e163687731f8035a1ae8f7398f015fe42116902bd9`;
- `doc/activation/op-201-activation.md`: 9,719 bytes / 46 lines / SHA-256
  `f32bf1a5f86908be44a71a8aadd7f03072cf33cab00c7893ec3aba909b1a173f`;
- `idq/id-016-ambient-mach-bootstrap-port.md`: 13,830 bytes / 151 lines / SHA-256
  `e0df0c9d1200c438cf6755f75362212d0667b809d4635ce9b61f888d2e61e70c`;
- `idq/id-042-1.0-preview-todo.md`: consume the live file and report its observed identity;
- `doc/host-guest-isolation-incident-2026-07-11.md`: 9,214 bytes / 161 lines / SHA-256
  `a93981176b34caab2743380506f3563fb429b9ce47caff1093f652bc11169c66`.

## REQUIRED READS

Read the full op-315 note and op-315 activation. Read the complete short op-279/op-280/op-200/
op-201 activations, the live id-016/id-042 state, and the host-isolation incident. Read source
bodies first-hand at minimum:

- `runtime.c:238-266,646-657`;
- `core.c:3390-3420,4040-4070,7225-7240`;
- `launchd.c:180-220`;
- any additional bounded main-thread exit-status/reap body required to evaluate the claimed
  zombie-theft consequence.

Use existing text manifests/logs only for the bounded image census. Do not read or execute an image
as a target and do not acquire privilege.

## G1 — INPUT / RETURN CONTRACT

Reproduce note/commit/source identities and compare the return against every Q1-Q5 and RETURN
requirement in op-315. Record missing, ambiguous, or overclaimed fields rather than filling them in.
The Explorer's self-reported confidence 9 is not a Validator verdict.

## G2 — SOURCE PREMISE

Independently classify each claim:

1. detached `waitpid_loop` creation/lifetime and `WNOWAIT` behavior;
2. unsynchronized active-job/submanager traversal and whether abort/UAF is merely a structural
   hazard or source-certain execution outcome;
3. the exact preconditions for a managed child to be repeatedly returned by `WNOWAIT` and the
   duration/termination of that spin;
4. the exact race needed for a managed child to be misclassified absent and reaped by the helper;
5. what remains runtime-only: incidence, CPU magnitude, status theft, crash/misclassification, or
   panic.

Do not promote “source-reachable” to “runtime-confirmed.” Identify any claim that needs a wider
main-thread exit-path read before acceptance.

## G3 — TOPOLOGY AND PREVIEW RELEVANCE

Separate three facts:

- source-permitted non-`-u` forms (`getpid()==1` **or** `getppid()==1`);
- the topology actually proven by op-200/op-201 (`init_path=/sbin/launchd`, PID 1, hybrid rc-chain);
- the current preview topology recorded by id-016/id-042 and whether it runs launchd with `-u`.

Test the note's absolute “only valid” wording. Then decide whether op-279's non-`-u`/PID-1 plan is:

- a genuine 1.0-preview prerequisite;
- a post-preview PID-1 robustness item already belonging with op-202/op-203; or
- mis-scoped but replaceable by a different bounded premise on the actual preview topology.

Explain whether `uflag` force-start behavior makes a `-u` premise invalid, merely noisy, or still
capable of measuring one of the named hazards. Do not change preview doctrine; report the source-
and-control-backed routing implication for the Coordinator.

## G4 — IMAGE / IMPLEMENTER-STAGE EXACTNESS

Verify whether the bounded existing records prove any candidate contains launchd artifact SHA-256
`bcdc0e5e54015dffd7ef32430665d169bd388478ff10405ef9d3ed33fd4ca897` and the required topology.
Then compare the note's “golden base + launchd + init_path” sentence with op-315's commissioned
exact prerequisite:

- one image base path and content hash;
- source artifact and in-image destination;
- dependent libraries/configuration and loader setting;
- owning EXU and approved staging mechanism;
- before/after BOM and in-image content proof; and
- whether a new disposable image is required.

Classify `EXACT`, `PARTIAL`, or `MISSING`. Do not choose a base or author staging commands yourself.

## G5 — FAIL-CLOSED RUNTIME PLAN

Compare Q4 in the note against op-315's full commission. Determine whether its three observations
can distinguish the named hazards and the required verdict classes. Check explicitly for:

- exact managed/unmanaged workload and intended exit status;
- launchd executable/mapping/PID identity;
- ECHILD, `LASTEXITSTATUS`, zombie population, CPU, survival/restart, and panic observations;
- raw command/stdout/stderr/serial/rc capture and terminal grammar;
- known-good self-control and known-bad detector control;
- attempt/cell consumption boundary, final inventory, sync, and clean shutdown.

Classify `FAIL-CLOSED-COMPLETE`, `PARTIAL`, or `NOT-SUFFICIENT`. A counted DTrace self-exit is not
by itself a product-hazard verdict.

## G6 — HOST/GUEST CONTAINMENT

Compare the note with the incident's permanent controls. Verify whether it binds:

- approved image/staging owner and helper;
- nonempty/nonroot mounted guest-root/device/sentinel checks before privilege;
- atomic explicit-path installation;
- host `/etc`, `/boot`, modules, and rc integrity inventory before/after;
- exact disposable image/BOM/hash;
- target execution only after the guest runtime marker; and
- host limited to supervisor plus passive serial/kgdb observation.

Classify `CONTAINMENT-COMPLETE`, `PARTIAL`, or `NEEDS-PREREQUISITE`. Do not infer that historical
bhyve use automatically satisfies the post-incident guards.

## G7 — DISPOSITION / NEXT OWNER

Return exactly one primary verdict:

- `VALIDATED-PREP-READY` — source, preview relevance, exact image stage, fail-closed plan, and
  containment are all sufficient to release a bounded next stage;
- `VALIDATED-PARTIAL-BANK-PID1` — useful source premise, but the warranted non-`-u`/PID-1 route is
  post-preview; recommend whether op-279/op-280 flush/bank under the existing PID-1 arc;
- `VALIDATED-PARTIAL-NEEDS-EXPLORER-CORRECTION` — preview runtime evidence remains warranted, but
  exact staging/evidence/containment prerequisites require a new Explorer-owned op;
- `VALIDATED-PARTIAL-NEEDS-CONTAINMENT-PREREQUISITE` — technical plan is otherwise sufficient but
  no approved safe staging mechanism exists; or
- `REJECTED-PREP <reason>`.

Attach confidence 1-10 and explicit recommendations for op-315, op-279, op-280, id-016, and id-042.
Name the next **role/repository** if work remains, but allocate no ID/op number and make no release,
scope, retirement, or product decision.

## RETURN

Report input identities; G1-G7 results with source/control citations; unavailable reproduction;
primary verdict; confidence; and these markers:

```text
VDS4P_OP317_INPUT_IDENTITY
VDS4P_OP317_SOURCE_PREMISE
VDS4P_OP317_TOPOLOGY_SCOPE
VDS4P_OP317_IMAGE_STAGE
VDS4P_OP317_FAIL_CLOSED_PLAN
VDS4P_OP317_CONTAINMENT
VDS4P_OP317_DISPOSITION
VDS4P_OP317_TERMINAL
```

## RELATIONS / FEEDBACK

op-315 → op-317; held op-279 → held op-280; op-200/op-201 → held post-preview op-202/op-203;
id-016 / id-042 / li-1006.

feedback: `verify_premise_before_mechanism`, `code_reasoned_verdict_is_hypothesis`,
`no_conflate_gating_with_readiness`, `agent_host_isolation`,
`artifact_identity_needs_content_check`, `op_state_dispatch_boundary`, `soak_is_gatekeeper`.
