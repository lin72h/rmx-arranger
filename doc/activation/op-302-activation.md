# op-302 — Gatekeeper Stage B: final dynamic manifest and truthful record freeze after op-301

op-302 | role: **Gatekeeper Ruler** (final evidence-package owner; no product write) | EXU:
**rmx-gatekeeper-rx-x64z** | state: **[Flushed — never dispatched; op-301 Stage A was rejected at
fail-fast intake, so the Coordinator's two-return stop rule cancels this final-freeze draft;
no automatic retry]** | parent: **op-301 / op-299 / op-293 / id-011** | L1i: **li-1004** | authored:
**2026-07-11 by Arranger2; exact base/release block to be finalized after op-301 gate**

## ARRANGER STOP — 2026-07-11

op-302 was never dispatched and consumed no execution, guest cell, attempt, or repository write.
Its prerequisite op-301 returned useful partial work at `8c1f269`, but failed the commissioned
Stage-A checker/capture/parser bar. The two-return strategy therefore stops before Stage B.

This op is `[Flushed]`; its number remains consumed and is never reused. No op-303 replacement is
automatically authorized. The canonical manifest and final attestation remain intentionally
unfrozen, the ASL record gate remains open, and id-040 remains Coordinator-held pending a new
strategy decision.

## DISPATCH BOUNDARY

WAITING on op-301. The Coordinator must not dispatch this draft. Arranger2 will bind the exact
accepted op-301 base and release it separately. When released, only `rmx-gatekeeper-rx-x64z` may
write `/Users/me/wip-mach/rmx-gatekeeper/`; all other trees remain read-only; guest cells stay zero.
The Coordinator approved op-301→op-302 as exactly two planned returns. A failed Stage A stops here;
a failed Stage B returns to the Coordinator for a new strategy, never an automatic op-303 retry.

## OBJECTIVE

Perform only the final record freeze after Stage A semantics/tests/capture plumbing are accepted.
No validator redesign belongs here.

Required final shape:

1. Run all real-log, negative, targeted, full-suite, diff/raw, and Git-scope commands through the
   accepted fail-closed capture helper. Preserve separate exact command/stdout/stderr/numeric-rc
   files. Targeted commands must rc 0; full-suite baseline/result failure names must match exactly
   and be called failures, not exclusions.
2. Finalize and stage **every ordinary file first**, including the single final failure-set file.
   After this point, create no ordinary path.
3. Generate `build/op293/op293-sha256-manifest.txt` from the dynamic staged/tracked Git scope over
   the complete op-286/op-293/op-297/op-298/op-299/op-301/op-302 family and matching source/tests.
4. Exactly two in-scope exclusions are allowed: the manifest itself and
   `build/op302/op302-manifest-attestation.txt`.
5. Run the canonical checker against the final staged set. Generate the detached attestation last;
   it contains exact checker command/stdout/stderr/rc, manifest size/SHA/Git blob, expected/actual
   sets/counts, exclusions, test/failure results, and requirement crosswalk. Stage it, create the
   additive commit, then rerun the checker at committed HEAD and return its complete output/rc.

Any file created or changed after manifest generation other than the one excluded attestation is a
hard failure requiring a fresh op; do not patch around it or claim closure.

## VERDICT

When released, return only `RECORD-GATE-CLOSED <commit>` or `BLOCKED <reason>`. Closure requires
post-commit dynamic set equality, truthful command records, unchanged raws, exact baseline/result
failure-set equality, zero new failures, and `guest_cells=0`. Do not push.

## BOUNDARIES

- WAITING draft: no execution until Arranger2 records accepted op-301 identity and Coordinator
  dispatch.
- Final record mechanics only; no guest/product/config/mechanism/soak/attempt work.
- id-040 remains Coordinator-held.
- No automatic follow-on is authorized if this final stage fails.

## MARKERS

`GK_OP302_BASE_IDENTITY`

`GK_OP302_FROZEN_COMMANDS`

`GK_OP302_DYNAMIC_SCOPE`

`GK_OP302_MANIFEST_SET_EQUALITY`

`GK_OP302_ATTESTATION`

`GK_OP302_POST_COMMIT_CHECK`

`GK_OP302_RAW_IDENTITY`

`GK_OP302_COMMIT`

`GK_OP302_TERMINAL`

## RELATIONS

op-301 / op-299 / op-298 / op-293 / id-011 / id-040 / li-1004.

feedback: `background_exit_code_hygiene`, `artifact_identity_needs_content_check`,
`harness_authoring_is_gatekeeper`, `agent_host_isolation`, `no_conflate_gating_with_readiness`,
`op_state_dispatch_boundary`.
