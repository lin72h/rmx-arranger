# op-308 — Gatekeeper: corrected exact-artifact libxpc connection-lifecycle acceptance

op-308 | role: **Gatekeeper Ruler** (runtime/evidence owner; no product write) | EXU:
**rmx-gatekeeper-rx-x64z** | state: **[Hold — op-311 and op-312 both failed Arranger intake before
Validator; op-307 is retired and origin-reachable, but no successor machinery is accepted;
automatic repair-forward is stopped pending Coordinator disposition or the later li-1005 quality
review, plus exact artifact/image pins and cell release]** | parent: **op-307 / op-312 / op-311 / op-306 / op-291 / op-285 / id-021** | L1i:
**li-1005 / li-007** | authored: **2026-07-11 by Arranger2**

## DEPENDENCY UPDATE — 2026-07-11

op-307 returned commit `40c8a93d4b3fec707b2e6ecd7762a1b20948e6e3`. Its M-sized
first-hand source/static-ABI gate is accepted locally: sixteen one-byte distinct type tokens,
correct typemap relocations, and distinct PIE/non-PIE bindings reproduce. Its S-sized publication
gate also passed: the commit is clean, origin-reachable, and retired. op-311 then returned actual
Gatekeeper commit `75072c87`, but Arranger fail-fast intake rejected it before Validator: wrong
commissioned architecture, label-only managed path, unsafe finalizer lifetime, absent conservation
and containment, duplicate terminal ownership, and fail-open validation. Fresh op-312 then returned
`5fa26ee`, but direct intake again found destructive fd census, no Mach/fd-identity conservation,
nonfatal type mismatches, an inoperative managed-service path, disconnected isolation, synthetic
shutdown, and a Validator that accepts malformed FAIL records. op-312 is
`[Done / PREP-NOT-ACCEPTED]`; no independent Validator or successor is authorized. This closes no
runtime dependency and releases no guest cell.

## DISPATCH BOUNDARY

WAITING. Do not dispatch, write, build, stage, reserve, or boot. This finalized held brief
authorizes no cell now.

Before release, the Arranger must append the exact accepted op-312 successor-harness/validator
commit and hashes plus its independent Validator disposition;
origin-reachable op-307 product commit; freshly built libxpc hash/source blobs; disposable image
path/size/SHA/BOM/kernel config; and staging/install commands. Failure to reconcile any pin keeps
this op `[Hold]`.

When released, write only `/Users/me/wip-mach/rmx-gatekeeper/`, using the independently accepted
successor machinery and
`build/op308/` raw evidence. Product/control/other EXU repositories remain read-only.

## RESERVED ACCEPTANCE BAR

One new guest cell may be authorized only by the later release annotation. It is consumed at
`GK_OP308_RUNTIME_START`; no retry or repair-forward occurs inside this op.

Before runtime start, run the accepted successor's static host preflight against the exact op-307
artifact without loading or executing target code on the physical host.
Recompile and relink the **accepted successor probe source** against that library in both the
supported PIE and known `-fno-PIE`/non-PIE copy-relocation regimes; record source/compiler/linker,
ELF/relocation, binary, and library hashes, then stage both documented guest-regime controls for
runtime inside the disposable cell. Do not reuse a binary linked against the aliased
pre-fix artifact. Artifact/source identities, sixteen nonzero pairwise-distinct tokens,
direct-symbol controls, validator known-bad controls, image/BOM identity, and staging plan must all
pass. Any failure returns `PREFLIGHT-NOT-ACCEPTED` with `guest_cells=0`; do not boot.

Against the exact op-307 artifact, require:

1. complete host/guest artifact identity, symlink/size/hash/`ldd`, and actual live mappings for both
   probe and aslmanager;
2. sixteen nonzero, pairwise-distinct public type tokens; exact connection equality plus cross-type
   negatives and header type=4/refcount=1 for anonymous and named connections;
3. independent exactly-once finalizers after bounded asynchronous cancellation/source drain;
4. warm-up plus repeated lifecycle with zero owned Mach/fd delta, thread return to warmed baseline,
   and no monotonic memory growth after quiescence;
5. real donor-faithful managed aslmanager reachability with handler installation strictly before
   first message and a bounded response/protocol disposition; and
6. fail-closed validator acceptance, explicit zero panic result, exact-one terminal sequence,
   `DONE < buffers synced < power-off`, and clean shutdown.

Commit `0ee8758062791c0063bca6f3dae086e674bec0aa` is not accepted machinery: its census,
aslmanager drive, type-failure handling, crash recovery, finalizer lifetime, terminal ownership,
artifact pin, mapping proof, and validator fail-closed behavior all require a new Gatekeeper op
under a new Gatekeeper op. Do not patch these during an op-308 cell.

Wrong identity is `PROVENANCE-NOT-ACCEPTED`; missing observer/record/validator evidence is
`HARNESS-NOT-ACCEPTED`; only a fully valid record may produce `ACCEPTANCE-PASS` or `PRODUCT-FAIL`.

## BOUNDARIES

- No product edit/build, harness redesign, image publication, ASL reclaim verdict, id-040 decision,
  second cell, amendment, push, or broader libxpc parity work.
- If the accepted successor machinery needs a semantic change, stop `HARNESS-NOT-ACCEPTED`; do not
  patch it during the cell.
- Commit only explicit `build/op308/` evidence/attestation paths; never commit the image or unrelated
  files.

## RETURN / VERDICT

Return exactly `PREFLIGHT-NOT-ACCEPTED <reason> <commit>`, `ACCEPTANCE-PASS <commit>`, `PRODUCT-FAIL <assertion> <commit>`,
`PROVENANCE-NOT-ACCEPTED <reason> <commit>`, or `HARNESS-NOT-ACCEPTED <reason> <commit>`, including
all pins, hashes, marker counts, deltas, order indices, validator result, cell count, full status,
and push=0. `[Done]` is only the return boundary.

## MARKERS

`GK_OP308_BASE_IDENTITY`

`GK_OP308_PREFLIGHT`

`GK_OP308_RUNTIME_START`

`GK_OP308_ARTIFACT_PROVENANCE`

`GK_OP308_TYPE_IDENTITY`

`GK_OP308_LIFECYCLE`

`GK_OP308_RESOURCE_CENSUS`

`GK_OP308_MANAGED_REACHABILITY`

`GK_OP308_FIRST_MESSAGE_ORDER`

`GK_OP308_PANIC_CHECK`

`GK_OP308_VERDICT`

`GK_OP308_TERMINAL`

## RELATIONS

op-307 / op-312 / op-311 / op-306 / op-291 / op-285 / id-021 / li-1005 / li-007 / id-040.

feedback: `artifact_identity_needs_content_check`, `evidence_first`,
`background_exit_code_hygiene`, `agent_host_isolation`, `no_conflate_gating_with_readiness`,
`op_state_dispatch_boundary`.
