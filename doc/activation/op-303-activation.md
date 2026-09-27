# op-303 — Validator-DS4P: falsify op-272 ASL renderer source findings and routing

op-303 | role: **Validator (DS4P)** (independent source-finding falsification; no acceptance or
write authority) | EXU: **Validator-DS4P seat** | state: **[Retired — returned
VALIDATED-SOURCE-FINDINGS at confidence 9/10; light identity/marker consumption accepted routing
and retired op-272/op-303 on 2026-07-11]** | parent: **op-272 / id-011** | L1i:
**li-1004** | related: **op-260 / op-269 / op-276** | authored: **2026-07-11 by Arranger2**

## ARRANGER CONSUMPTION — 2026-07-11

Validator-DS4P confirmed H1–H7 at source, the four sampled normal paths, and the exact caller census;
verdict `VALIDATED-SOURCE-FINDINGS`, confidence 9/10. All twelve commissioned markers were returned,
with no conflicting Validator result or inaccessible primary artifact.

Arranger2's light confidence-9 consumption reproduced:

- note: 27,694 bytes / 419 lines / SHA-256
  `02a431709085027ed989a0f8e98b271f20d8eab8ad2e0df15dd0fda5568a96ca`;
- `asl_msg.c`: 68,621 bytes / 3,045 lines / SHA-256
  `6f80ea731ca3d696b29e9bf335ff5c08411a31368b1bfe5ed865a4b0c4f91651`;
- clean local/tracking/live-remote product
  `alpha@ceb46edc5f910660d4fa7ecd9e90501ebd86b1ba`; and
- the report's exact verdict, confidence, per-hypothesis classifications, normal-path result,
  caller census, and terminal marker.

Disposition: H1/H2/H3/H5/H6 are bounded preview-relevant fixes routed to op-304 then op-305.
H4/H7 are confirmed but banked post-preview under id-011. This gate makes no runtime manifestation
claim and does not close ASL leg 4. op-303 and parent op-272 retire.

## DISPATCH BOUNDARY

DISPATCHED by the Coordinator on 2026-07-11 to the **Validator-DS4P seat** only. Read and report in the
Validator session. Do not write the DS4P, Oracle2, Arranger, product, Explorer, Gatekeeper, or any
other repository. No build, guest, probe execution, product mutation, ID/op allocation, evidence
disposition, scope decision, or release decision.

Read `/Users/me/wip-mach/wip-ds4p/validator-rulebook.md` first. The matching GLM copy is
byte-identical at dispatch preparation. This op uses DS4P for falsification and leaves GLM
available for the broader op-291 runtime-return gate.

## WHY / GATE SIZE

op-272 is a consult, not validation. It returned seven claimed source defects spanning renderer
selection, public/tool contracts, custom-template scanning, time parsing, UTF-8 validation, asld
encoding selection, sparse-message iteration, and eight direct callers. Arranger2 sizes the gate
**L** and delegates it under Rule 11. Determine which claims survive direct source falsification;
do not implement or execute the proposed vectors.

## PRIMARY INPUT IDENTITIES

Read completely:

- note: `/Users/me/wip-mach/rmx-oracle2/op-272-asl-message-rendering-findings.md`;
- note identity: `27694` bytes / `419` lines / SHA-256
  `02a431709085027ed989a0f8e98b271f20d8eab8ad2e0df15dd0fda5568a96ca`;
- activation: `/Users/me/wip-mach/rmx-arranger/doc/activation/op-272-activation.md`; and
- current activation: this op-303 file.

Oracle2 is a local deliverable tree without required Git provenance. The note hash identifies
content only; do not infer commit or origin publication.

Validate against the clean product tree:

- repository: `/Users/me/wip-mach/wip-gpt/wip-rmxos/`;
- required branch/local tracking/live remote:
  `alpha@ceb46edc5f910660d4fa7ecd9e90501ebd86b1ba`;
- primary source: `lib/libasl/asl_msg.c`, 68,621 bytes / 3,045 lines / SHA-256
  `6f80ea731ca3d696b29e9bf335ff5c08411a31368b1bfe5ed865a4b0c4f91651` / Git blob
  `99b0e830c78f01e2bed71c2aecc7fa96957f4799`; and
- governing contracts/helpers/callers are the exact files cited by the note under this same commit.

Stop with `BLOCKED IDENTITY-DRIFT` if the note or product/source identity differs. Do not repin,
fetch, repair, or substitute a sibling source snapshot.

## REVIEW METHOD

For every finding below:

1. Read the complete cited function/helper and enough caller/contract context to establish the
   full control and data path.
2. State the distinguishing fact that would confirm or refute it.
3. Classify `CONFIRMED-SOURCE`, `REFUTED`, or `RUNTIME-UNRESOLVED`.
4. Separate documented contract, direct source fact, code inference, consumer reachability, and
   unexecuted manifestation.
5. If confirmed, classify exposure as `DEFAULT-PREVIEW`, `LIVE-OPTIONAL`, `TOOL/API`, or
   `POST-PREVIEW/BANK`, and state the smallest owner-correct next step.

Do not convert source reachability into an observed crash/output claim. A source-confirmed defect
may be routed without runtime reproduction only when the full contract and control path are
decisive; otherwise name the exact missing microcheck.

## SEVEN ACTIONABLE HYPOTHESES

### H1 — NULL format default

Verify whether the public contract says `msg_fmt == NULL` selects STD while
`asl_format_message` initializes/retains RAW, and whether `asl_object.c` passes NULL through.
Check for any wrapper normalization or later override that would refute the claimed divergence.

### H2 — `xml.N` suffix selection

Verify the exact `aslutil.1` suffix grammar, renderer selector, and `aslutil/syslog.c` option path.
Decide whether the documentation truly applies `.N` to XML and whether `xml.4` falls into literal
custom formatting rather than XML output. Do not infer the contract from one sentence alone.

### H3 — terminal-backslash template scan

Trace the entire custom-template loop and escape branch. Prove or refute whether a final `\`
advances to NUL, the loop increment advances beyond it, and the next condition reads outside the
template. Check every break/continue/index update and any allocation padding assumption. Keep
source undefined behavior separate from an unobserved crash.

### H4 — positive fractional ISO offset

Trace `_asl_time_string` into the actual parser in `asl_core.c`. Recompute `+05:30`, `-05:30`, and
whole-hour cases from source. Confirm or refute that the sign applies only to hours and that the
claimed positive case is one hour late. Verify this parser is reached for stored textual Time and
that ordinary rmxOS epoch records avoid the path.

### H5 — incomplete/surrogate UTF-8 accepted for XML

Read the complete `asl_is_utf8` state machine. Confirm or refute both terminal-incomplete acceptance
and `ED A0 80` surrogate acceptance, then trace the result into XML `<string>` versus base64
`<data>` selection. Check key and value handling separately.

### H6 — configured XML sink uses SAFE encoding

Trace configured `format=xml` from `asl_common.c`/asld activation through `asl_action.c`,
`asl_format_message`, and `asl_string` XML-tag emission. Confirm whether SAFE is always passed and
whether it fails to escape XML metacharacters in tag content. Verify the current shipped rules do
not enable XML before classifying default-preview exposure.

### H7 — empty or slot-zero-sparse XML NULL-key path

Trace message initialization, unset semantics, `asl_msg_fetch(msg, 0, ...)`, iterator tokens,
`asl_is_utf8(NULL)`, and the XML branch. Confirm or refute that an empty or first-slot-free message
can reach `strcmp(NULL, ASL_KEY_TIME)` without an intervening guard. Check whether RAW's guard and
normal stored-record population change only exposure rather than source correctness.

## NORMAL-PATH AND QUALIFICATION CHECK

Risk-sample at least one claimed coherent normal path from each Q1–Q4 so the review does not accept
defects built on a misread surrounding model. Specifically verify:

- exact-name RAW/STD/BSD/MSG/XML selection and trailing newline;
- one well-formed custom substitution plus escaped dollar;
- normal current-epoch time formatting and fractional precision clamp; and
- returned NUL/length convention through `asl_string_length` and ownership transfer.

Review the note's uncertain/banked qualifications only far enough to ensure none contradicts,
subsumes, or invalidates H1–H7. Do not expand into a general ASL audit, op-260 store framing,
op-269 query matching, or op-276 encoding simplification.

## DIRECT-CALLER CENSUS

Re-run the full-product exact call search for `asl_format_message` at the pinned commit. Confirm or
correct the claimed eight expressions:

- four live preview consumers;
- one installed tool and zero direct tests; and
- three dormant calls.

For each, verify build/config reachability from primary Makefiles/guards. Distinguish compiled,
enabled-by-default, live-optional, and dormant. A grep hit alone is not consumer proof.

## ROUTING RECOMMENDATION

Return a per-finding recommendation only. Do not issue it:

- `FIX+NEGATIVE-VECTOR` — decisive, preview-relevant bounded correction for Implementer followed
  by Gatekeeper vector;
- `VECTOR-FIRST` — manifestation/contract ambiguity must be settled before a product edit;
- `BANK` — real but outside current preview use cases; or
- `DROP` — refuted.

Check repository ownership: Implementer alone changes product; Gatekeeper owns runtime/vector
evidence; Explorer owns macOS/conformance truth. Do not brief or perform cross-repository writes.

## VERDICT / CONFIDENCE

Return exactly one overall verdict:

- `VALIDATED-SOURCE-FINDINGS` — routing is materially sound after any named non-load-bearing
  corrections;
- `NEEDS-REVISION <items>` — one or more load-bearing claims/census entries fail while a bounded
  corrected note remains usable; or
- `REJECTED <reason>` — the source/contract/caller foundation is unsafe to route.

Attach confidence `1–10`, primary-artifact accessibility, source-cited findings in severity order,
and any unavailable reproduction. At confidence 9–10 the Validator gate stands after Arranger
light provenance checks; below 9 Arranger adjudicates only the disputed points under the current
Rule-11 ruling.

## REPORT FORM

```text
REPORT
op:                 op-303
validator:          DS4P
note_identity:      <size / lines / sha256>
source_identity:    <branch / commit / size / lines / sha256 / blob>
verdict:            VALIDATED-SOURCE-FINDINGS | NEEDS-REVISION <items> | REJECTED <reason>
confidence:         <1-10>
h1_null_default:    CONFIRMED-SOURCE | REFUTED | RUNTIME-UNRESOLVED — <routing>
h2_xml_suffix:      CONFIRMED-SOURCE | REFUTED | RUNTIME-UNRESOLVED — <routing>
h3_terminal_slash:  CONFIRMED-SOURCE | REFUTED | RUNTIME-UNRESOLVED — <routing>
h4_timezone:        CONFIRMED-SOURCE | REFUTED | RUNTIME-UNRESOLVED — <routing>
h5_utf8:            CONFIRMED-SOURCE | REFUTED | RUNTIME-UNRESOLVED — <routing>
h6_xml_safe:        CONFIRMED-SOURCE | REFUTED | RUNTIME-UNRESOLVED — <routing>
h7_sparse_xml:      CONFIRMED-SOURCE | REFUTED | RUNTIME-UNRESOLVED — <routing>
normal_paths:       <Q1-Q4 sample result>
callers:            <live/tool-test/dormant recount + corrections>
unavailable:        <none or exact gap>
terminal:           complete
```

## MARKERS

`VDS4P_OP303_INPUT_IDENTITY`

`VDS4P_OP303_H1_NULL_DEFAULT`

`VDS4P_OP303_H2_XML_SUFFIX`

`VDS4P_OP303_H3_TERMINAL_SLASH`

`VDS4P_OP303_H4_TIMEZONE`

`VDS4P_OP303_H5_UTF8`

`VDS4P_OP303_H6_XML_SAFE`

`VDS4P_OP303_H7_SPARSE_XML`

`VDS4P_OP303_NORMAL_PATHS`

`VDS4P_OP303_CALLER_CENSUS`

`VDS4P_OP303_VERDICT`

`VDS4P_OP303_TERMINAL`

## BOUNDARIES

- Read/falsify/report only; no repository write anywhere.
- No build, host/guest probe, cell, mutation, evidence spend, commit, push, or publication.
- No implementation, runtime acceptance, ID/L1i allocation, milestone decision, or retirement.
- Do not repair the Oracle note; name corrections for Arranger routing.
- Do not expand into op-260, op-269, op-276, aslmanager scheduling/reclaim, or broader ASL parity.

## RELATIONS

op-272 / id-011 / li-1004 / op-260 / op-269 / op-276 / arranger-rulebook Rule 11.

feedback: `arranger_gate_sizing_delegation`, `code_reasoned_verdict_is_hypothesis`,
`verify_signature_divergence_claims`, `primary_artifact_first`, `agent_host_isolation`,
`op_state_dispatch_boundary`.
