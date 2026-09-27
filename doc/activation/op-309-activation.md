# op-309 — Validator-GLM: gate op-304 ASL rendering correction and evidence

op-309 | role: **Validator (GLM)** (independent L-sized product/evidence gate; no product or
release authority) | EXU: **Validator-GLM seat** | state: **[Retired — returned
VALIDATED-CORRECTION at confidence 9/10; Arranger2 light identity consumption accepted the local
correction on 2026-07-11]** | parent: **op-304 / op-303 / id-011** | L1i: **li-1004** | related:
**op-305 / op-272 / op-276** | authored: **2026-07-11 by Arranger2**

## ARRANGER CONSUMPTION — 2026-07-11

Validator-GLM returned `VALIDATED-CORRECTION`, confidence 9/10, for H1/H2/H3/H5/H6. Under Rule
11 the verdict stands after light provenance checks. Arranger2 reproduced clean local
`alpha@a52a2ef51560943f7af4fe0b38e27f83508fd9b6`, parent/tracking/live remote
`ceb46edc5f910660d4fa7ecd9e90501ebd86b1ba`, exact four-path commit, source hashes, zero build
and final-test rc files, and unchanged evidence identities. No conflicting Validator result exists.

The Validator explicitly carries forward: no frozen manifest, no base/known-bad replay, static
test binding for part of the suite, host Mach-trap preload, incomplete command/environment
capture, and local-only product provenance. These do not invalidate source correctness; op-305
already owns the independent exact-artifact negative-vector gate after publication/retirement.
No guest, ASL leg-4, H4, H7, or preview-green claim follows.

The return did not echo the requested VGLM_OP309_* label strings, but it supplied every
corresponding identity, H1/H2/H3/H5/H6, build/provenance, scope, verdict, confidence, origin
blocker, unavailable-reproduction, and terminal field. Arranger2 treats the label omission as
non-load-bearing reporting drift and records it without inventing Validator markers.

Disposition: op-309 retires. op-304 is locally validated but stays [Done] until exact non-force
publication and origin reachability are reproduced. op-305 remains [Hold].

## DISPATCH BOUNDARY

DISPATCHED by the Coordinator on 2026-07-11 to the **Validator-GLM seat** only. Read and report in
that session. Do not write the GLM, Arranger, product, Implementer-build, Gatekeeper, Explorer,
Oracle, or DS4P trees. Do not commit, push, edit an image, reserve or start a guest, allocate an
ID/op, release op-305, or make an ASL-leg-4/preview-green decision.

Read /Users/me/wip-mach/wip-glm/validator-rulebook.md first. Validate the exact returned commit and
Implementer evidence first-hand. Existing binaries may be executed read-only when their behavior
and output location are understood; do not rebuild or replace an artifact. If independent new
vectors or a fresh build are required to settle correctness, return EVIDENCE-NOT-ACCEPTED with
the missing test instead of writing into another role's repository. op-305 owns the later
independent Gatekeeper vector suite.

## WHY / GATE SIZE

op-304 changes four product files across the public renderer, UTF-8 state machine, installed
aslutil selection, and asld configured-file path. Its report also relies on a custom Zig
microcheck, guard-page detector, statically embedded product objects, a globalized asld object,
an LD_PRELOAD Mach-trap shim, XML parsing, and several failed build/binding attempts. Arranger2
sizes this gate **L** and delegates it under Rule 11.

Determine whether the focused commit correctly implements H1/H2/H3/H5/H6 without regressions and
whether the reported build/microcheck evidence actually exercises the committed paths. This is a
correctness/evidence gate, not the independent post-publication behavior acceptance owned by
op-305.

## REQUIRED IDENTITIES

### Product

- repository: /Users/me/wip-mach/wip-gpt/wip-rmxos/
- branch: alpha
- returned commit: a52a2ef51560943f7af4fe0b38e27f83508fd9b6
- required parent/base and current origin/alpha:
  ceb46edc5f910660d4fa7ecd9e90501ebd86b1ba
- subject: libasl: correct message rendering paths
- expected status: clean, alpha ahead of origin/alpha by exactly one commit
- expected commit summary: four files changed, 48 insertions, 6 deletions

The complete changed-path set must be exactly:

- lib/libasl/asl_msg.c
- lib/libasl/asl_util.c
- usr.bin/aslutil/syslog.c
- usr.sbin/asl/asl_action.c

Reproduce git show --check, git diff --check against the parent, commit parentage, full-repository
status, tracking relationship, and the absence of a push. Stop with BLOCKED IDENTITY-DRIFT if the
commit, parent, changed-path set, branch, or worktree differs. Do not repin, fetch, merge, clean,
or accept a later sibling commit.

Expected committed source identities:

| path | SHA-256 | Git blob |
|---|---|---|
| lib/libasl/asl_msg.c | 3cfb1473a0b1d2cdbe58d017c8b0673b5612989e508363bfbd167d30a178488f | dd08564a52d09b2ea0fc280a2b15f027976e5900 |
| lib/libasl/asl_util.c | 3e4458b46372fe8dd7960b85821948f6baac2fc62a5a9804dd72d7f232477739 | 50d603ae154d9093b04ec977c93b0bfd58bb8a78 |
| usr.bin/aslutil/syslog.c | d603deaa0329899d22d55141d321a69f71cd264f144010709a6f638125ebe745 | 4a5c0d9081c19f1abe1cc5e34bdbf5092b6c79d5 |
| usr.sbin/asl/asl_action.c | deef6cf9d0f946c0f9b5fb6aa6164cda9a66f24a79027ef809a3e2affadfa99f | b28af99801ff7ef58ffa810c8a026117a7ef9625 |

### Validated input

Read:

- /Users/me/wip-mach/rmx-oracle2/op-272-asl-message-rendering-findings.md
  - 27,694 bytes / 419 lines
  - SHA-256 02a431709085027ed989a0f8e98b271f20d8eab8ad2e0df15dd0fda5568a96ca
- /Users/me/wip-mach/rmx-arranger/doc/activation/op-303-activation.md
  - accepted verdict VALIDATED-SOURCE-FINDINGS, confidence 9/10
- /Users/me/wip-mach/rmx-arranger/doc/activation/op-304-activation.md
  - exact commissioned corrections, edit ceiling, vectors, and exclusions

The op-272 note is content-addressed local Oracle material, not origin-published product evidence.
Do not turn its source hypotheses into proof that the returned implementation is correct.

### Implementer build/evidence

Evidence root:

/Users/me/wip-mach/wip-gpt/build/op304-asl-render/

Object root:

/Users/me/wip-mach/wip-gpt/build/op304-asl-render/obj/Users/me/wip-mach/wip-gpt/wip-rmxos/amd64.amd64/

Expected built artifacts:

| artifact | bytes | SHA-256 |
|---|---:|---|
| lib/libasl/libasl.so.1 | 220248 | 4e64bec974d74614d3dcf56c32af70b42e14221b7641af3a8f8a4ded01fe3b90 |
| lib/libasl/libasl.a | 891466 | 48671e0f30c4652013107dc9c670c60c46a146083488a92ab506092218bc0a80 |
| usr.bin/aslutil/aslutil | 54800 | 718bbf3bd8e3c49ac4cef5a1d758dc2fc94f396e5aed7db5c06d1230e5e24b43 |
| usr.sbin/asl/asld | 164336 | 12ef2d4dd33143d3930fbb831394b9eb016272003f1b8d8190d5174cb98b9c28 |

Expected test/provenance artifacts:

| artifact | bytes | SHA-256 |
|---|---:|---|
| op304-asl-render-microcheck.zig | reproduce | 7eaf3b9f277eacda1a6b94119c38ec4787b37890fb43df12afba143a9e57e63a |
| op304-asl-render-microcheck | 4500256 | 48b382e8048618f772830f03158e73b2e20aa2d1dcbfa3e662378e7477af74a1 |
| op304-h1-public.zig | reproduce | d95077b2bcbb42906985e93bf8c6013e459dcc9fede3b6ac3f46f61f8268a5b1 |
| op304-h1-public | 4334416 | 8d22ebc035b2726d6cdbad53bfb17867e1b0f5bbb20ccdedcb1fdf1cac715ae8 |
| op304-mach-trap-stubs.zig | reproduce | d9b03e2f9d3bc61f1be6164a79d1f1e5b46172521d46d689fbd0868a03bbd647 |
| libop304-mach-trap-stubs.so | 4013320 | 0750ada79150740c8d5605213db227028173a3c810ddbcb3ccc7db90f11e0cb3 |
| asl_action-test.o | 104584 | 915b0df9de814b55170cef3d58c30deee37cd2a35de46df43d003a9d4f2a4728 |
| aslutil-fixture.asl | 230 | b3749b0041558e57eab17a81957251ae49841ac5f044d81f826ab9fe23257820 |

Read every build/run command and rc/log pair needed for the verdict. The directory deliberately
contains failed binding/static-build attempts with rc=1. Confirm the final successful path does
not hide, overwrite, or misclassify those failures; distinguish abandoned setup attempts from a
load-bearing failure in the final artifact or vector.

## REVIEW METHOD

1. Reproduce all identities before interpreting results.
2. Read each complete changed function/state-machine body, the unchanged helpers it depends on,
   and enough direct caller context to establish the real path.
3. Compare the final diff against every MUST/MUST-NOT in op-304, not merely the Oracle finding.
4. Read the full microcheck sources before consuming their outputs. Trace each assertion to the
   exact committed product object/symbol it exercises.
5. Inspect ldd/nm/object identities and build commands. Prove the final tests use the fresh op-304
   objects rather than host libasl, a stale sibling, a stubbed implementation, or only a fixture.
6. Re-derive output claims from raw XML/text/rc files. Confirm xmllint actually parsed the produced
   fragments and the terminal markers are unique and consistent.
7. Run a negative-control review of the microcheck logic: identify whether an unchanged/pre-fix
   implementation or wrong artifact would fail each commissioned assertion. Do not infer the
   later op-305 fail-closed suite exists.
8. Separate source correctness, host microcheck behavior, build success, guest/runtime behavior,
   origin publication, and ASL-leg-4 acceptance.

## REQUIRED CORRECTION GATES

### H1 — NULL documented default

Confirm the public asl_format path passes NULL to the corrected selector and now produces the STD
layout, while explicit RAW remains RAW and other exact names are unchanged. Consume both the
internal and public-wrapper tests only after proving their linkage/binding. Check output layout,
newline, NUL, returned length, and ownership rather than one substring.

### H2 — XML fractional suffix

Read the renderer, aslutil option parser, asld configured-file selection, time-format helper, and
documented grammar as one path. Confirm exact xml and documented xml.N select XML consistently,
use the intended local fractional time format, and preserve invalid/custom fallback.

This is the highest-risk branch. Explicitly test or source-prove:

- xml.0, xml.4, xml.9, leading-zero precision, empty suffix, non-digit suffix, and a very long
  all-digit suffix;
- precision clamping/truncation and the 16-byte tfmt_ext construction;
- identical recognition boundaries across renderer, aslutil, and asld; and
- whether the new duplicated checks materially violate op-304's requirement to mirror existing
  suffix semantics and avoid a divergent second parser.

Do not fail merely for style duplication. Fail or revise when differing grammar, truncation,
integer interpretation, or caller selection changes observable/documented behavior or leaves an
unsafe ambiguity. State the exact distinguishing vector/source fact.

### H3 — terminal backslash

Trace every index transition and loop exit. Confirm a terminal backslash is emitted literally,
the loop cannot read beyond NUL, normal newline/NUL/length behavior follows, and existing escaped
dollar, ordinary backslash, and numeric escape behavior is preserved. Verify the guard-page setup
places the NUL at the last readable byte and that the tested function is the committed one.

### H5 — UTF-8 completeness and surrogate rejection

Audit the complete state machine, including state and ctype transitions. Re-derive:

- truncated 2-, 3-, and 4-byte sequences reject at terminal state;
- overlong encodings and stray continuation bytes remain rejected;
- ED 80 80 through ED 9F BF remain valid non-surrogate sequences;
- ED A0 80 through ED BF BF are rejected as surrogate encodings;
- E0 lower bound, F0 lower bound, and F4 upper bound remain correct; and
- representative valid 1/2/3/4-byte boundaries remain accepted.

Then trace keys and values separately: invalid keys omit their entire pair; invalid values retain
the existing XML data/base64 behavior. Reject evidence that checks only the reported ED A0 80
sample while regressing adjacent valid boundaries.

### H6 — configured XML encoding

Confirm exact xml and accepted xml.N select ASL_ENCODE_XML in both aslutil and the actual rebuilt
asl_action path. Re-derive the entity escaping for ampersand, angle brackets, quotes, and
apostrophes, and verify the exact generated XML parses. Confirm a normal BSD configured line is
byte-compatible and invalid/custom formats do not silently receive XML selection.

Inspect how asl_action.pieo became the globalized asl_action-test.o and how the microcheck reached
the real _act_file_final body. Treat the Mach-trap preload as a host-kernel compatibility aid only;
prove it does not substitute for the rendering behavior under test.

## BUILD / EVIDENCE GATE

Confirm:

- libasl, aslutil, and asld final build rc files are exactly zero and logs show the intended
  FreeBSD target/object root;
- the four reported build hashes reproduce;
- git blobs in the commit equal the sources used by the successful build;
- the final microcheck and public-wrapper rc values are zero and raw markers match the report;
- the reported ldd/nm evidence establishes the claimed fresh static embedding or dynamic binding;
- the configured asld object test genuinely covers the changed asld function;
- allocator junk and the guard-page detector were active where claimed;
- no core was produced;
- no guest/image/runtime/ASL-leg-4 result is implied; and
- the product commit remains local-only, so origin reachability is a downstream retirement blocker,
  not a reason to reject a correct local commit.

If a self-check is strong but not independently fail-closed, classify that limitation precisely.
op-305 is the already-held independent negative-vector gate; do not demand it as if it were part
of the Implementer return.

## SCOPE / REGRESSION CENSUS

Verify the commit edits no H4 timezone parser, H7 sparse-XML iterator, store/query/socket/reclaim
code, configuration, build system, tests, or image. Search direct callers of the changed functions
and inspect enough ordinary RAW/STD/BSD/MSG/XML paths to exclude an obvious default-path
regression. Record any adjacent defect as a banked observation unless it invalidates this commit.

## VERDICT / CONFIDENCE

Return exactly one:

- VALIDATED-CORRECTION — all five corrections and their build/vector provenance are materially
  sound; name any non-blocking limits;
- PRODUCT-ISSUE <H/item> — the committed implementation is wrong, unsafe, or regressive;
- EVIDENCE-NOT-ACCEPTED <item> — source may be sound but a load-bearing build/vector/provenance
  claim cannot be established; or
- BLOCKED IDENTITY-DRIFT <fact> — an exact required input differs or is inaccessible.

Attach confidence 1–10 and explain which direct primary artifacts answer the distinguishing
questions. At confidence 9–10, the Validator gate stands after Arranger light provenance checks.
Below 9, Arranger adjudicates the disputed points. A VALIDATED-CORRECTION return does not publish
or retire op-304, release/retire op-305, make op-276 Ready, or close ASL leg 4.

## REPORT FORM

    REPORT
    op:                    op-309
    validator:             GLM
    product_identity:      <branch / commit / parent / origin / status>
    changed_paths:         <4 paths / source hashes+blobs / diff-check>
    input_note:            <size / lines / sha256>
    artifact_identity:     <four build hashes + test binary/source hashes>
    verdict:               VALIDATED-CORRECTION | PRODUCT-ISSUE <item> |
                           EVIDENCE-NOT-ACCEPTED <item> | BLOCKED IDENTITY-DRIFT <fact>
    confidence:            <1-10>
    h1_null_default:       <result + distinguishing evidence>
    h2_xml_suffix:         <result + grammar/boundary evidence>
    h3_terminal_slash:     <result + bounds evidence>
    h5_utf8:               <result + boundary/key-value evidence>
    h6_xml_encoding:       <result + aslutil/asld/binding evidence>
    build_provenance:      <result + failed-attempt disposition>
    scope_regression:      <result>
    origin_blocker:        <local-only / exact origin tip>
    unavailable:           <none or exact gap>
    terminal:              complete

## MARKERS

VGLM_OP309_INPUT_IDENTITY

VGLM_OP309_CHANGED_PATHS

VGLM_OP309_H1_NULL_DEFAULT

VGLM_OP309_H2_XML_SUFFIX

VGLM_OP309_H3_TERMINAL_SLASH

VGLM_OP309_H5_UTF8

VGLM_OP309_H6_XML_ENCODING

VGLM_OP309_BUILD_PROVENANCE

VGLM_OP309_SCOPE_REGRESSION

VGLM_OP309_VERDICT

VGLM_OP309_TERMINAL

## RELATIONS

op-304 / op-303 / op-305 / op-272 / op-276 / id-011 / li-1004.

feedback: validator_primary, exact_artifact, artifact_identity_needs_content_check,
negative_control_fails_closed, no_conflate_gating_with_readiness, agent_host_isolation,
op_state_dispatch_boundary.
