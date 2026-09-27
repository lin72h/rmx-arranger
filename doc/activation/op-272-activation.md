# op-272 — Oracle2: verify ASL stored-record → rendered-line correctness

op-272 | role: **Oracle** (consult-only; no product or control write) | EXU:
**Oracle2 / rmx-oracle2** | state: **[Retired — exact consult passed op-303
VALIDATED-SOURCE-FINDINGS at confidence 9/10; H1/H2/H3/H5/H6 route to op-304→op-305,
H4/H7 bank post-preview; consult loop closed 2026-07-11]** | parent: **id-011** | L1i: **li-1004** | related:
**op-260 / op-269 / op-276** | authored: **2026-07-04; reissued 2026-07-10; normalized
2026-07-11 by Arranger2**

## RETURN INTAKE — 2026-07-11

- deliverable: `/Users/me/wip-mach/rmx-oracle2/op-272-asl-message-rendering-findings.md`;
- identity: 27,694 bytes / 419 lines / SHA-256
  `02a431709085027ed989a0f8e98b271f20d8eab8ad2e0df15dd0fda5568a96ca`;
- product/source pin reproduced clean and live-origin-aligned at
  `alpha@ceb46edc5f910660d4fa7ecd9e90501ebd86b1ba`; `asl_msg.c` identity reproduced exactly;
- all eight commissioned markers and `CONSULT-COMPLETE` are present; and
- boundary intake is coherent: read-only note, no build, guest cell, product write, or control write.

The return advances `[Exe]→[Done]` only. Its seven actionable claims are Oracle hypotheses, not
verified facts. The cross-file/contract/caller review is sized **L** and delegated to
Validator-DS4P under op-303 before any ID seed, Implementer fix, Gatekeeper vector, or retirement.

## RETIREMENT — 2026-07-11

Validator-DS4P op-303 returned `VALIDATED-SOURCE-FINDINGS`, confidence 9/10, confirming all seven
hypotheses, the normal-path model, and the exact 4-live/1-tool/3-dormant caller census. Arranger2
reproduced the unchanged note/source/product identities and consumed the confidence-9 gate without
re-review. Preview-relevant H1/H2/H3/H5/H6 are fetched as Implementer op-304 with held Gatekeeper
vectors op-305. H4 fractional textual timezone and H7 empty/sparse XML are confirmed but banked as
post-preview residuals under id-011. The consult therefore ends in product action plus explicit
banked closure and retires.

## DISPATCH BOUNDARY

DISPATCHED by the Coordinator to **Oracle2 / rmx-oracle2** on 2026-07-11. Oracle2 may write exactly one
commissioned deliverable:

`/Users/me/wip-mach/rmx-oracle2/op-272-asl-message-rendering-findings.md`

The product, Arranger, Explorer, Gatekeeper, and Oracle1 repositories are read-only. Do not build,
boot a guest, execute a runtime probe, modify evidence, allocate an ID/op, choose milestone scope,
or make a release decision.

## REQUIRED SOURCE IDENTITY

Review the clean, origin-aligned product tree:

- repository: `/Users/me/wip-mach/wip-gpt/wip-rmxos/`;
- branch/commit: `alpha@ceb46edc5f910660d4fa7ecd9e90501ebd86b1ba`;
- source: `lib/libasl/asl_msg.c`;
- source identity: 68,621 bytes / 3,045 lines / SHA-256
  `6f80ea731ca3d696b29e9bf335ff5c08411a31368b1bfe5ed865a4b0c4f91651` / Git blob
  `99b0e830c78f01e2bed71c2aecc7fa96957f4799`;
- primary function: `asl_format_message` at `asl_msg.c:2544`; and
- relevant formatting/encoding helpers begin around the comment at `asl_msg.c:1916`.

Verify identity before reasoning. On mismatch, stop with `BLOCKED SOURCE-DRIFT` and report the
observed branch/commit/file identity; do not silently repin, clone, fetch, or use a deprecated
Arranger tree.

## OBJECTIVE — ONE FEATURE ONLY

Determine whether the ASL message-rendering path correctly converts one stored `asl_msg_t` into
the complete human-readable line returned to a log sink. Scope is `asl_format_message` plus only
the format, template, time, string-encoding, and length helpers it directly uses.

This is the RENDER sibling of the already-banked query/predicate read op-269 and the earlier store
framing read op-260: store a record, find it, then render it. It is not permission to reopen either
of those paths.

## QUESTIONS

### Q1 — Built-in format selection and layout

Read every selected branch for `raw`, `std`, `bsd`, `xml`, and `msg`, including suffixed format
names. Establish whether each branch emits the intended fields, separators, newline, and fallback
values without selecting the wrong format or returning an empty line for a present record.

Identify the in-tree source of the expected layout (header, man page, comments, or established
caller contract). Do not infer correctness solely because the code compiles.

### Q2 — Custom-template substitution

Read the complete custom `$Key`, `$(Key)`, and `$((Key)(Format))` parser and the helper bodies it
calls. Check present versus absent keys, repeated/positional references, escaped dollar signs,
malformed or unterminated templates, key-buffer bounds, and deterministic placeholder behavior.

Do not claim a parser or bounds defect from a signature or isolated line; trace the complete
branch and surrounding state first.

### Q3 — Time formatting

Trace the raw-seconds, UTC, and local-time selections, including format suffixes, nanoseconds,
timezone handling, missing/invalid time fields, allocation ownership, and fallback output.
Determine whether every accepted selection yields a well-formed, deterministic timestamp field.

### Q4 — Text encoding, termination, and returned length

Trace ordinary text, control/non-printable bytes, XML string-versus-base64 handling, and each
accepted `text_encoding` mode. Establish whether ordinary text is preserved, unusual bytes are
rendered deterministically, the returned buffer is complete and NUL-terminated, and `*len`
matches the documented convention—including the trailing NUL where promised.

## BOUNDED CALL-SITE CENSUS

List every in-tree direct caller of `asl_format_message` and classify whether it is a live
preview consumer, a tool/test, or dormant. This census is for routing only: do not expand into
the caller's wider submit, query, storage, or service behavior.

For any actionable finding, state whether a live preview consumer reaches it and name the
smallest owner-correct next step. If source reasoning cannot settle behavior, specify one minimal
runtime microcheck and its exact expected observation; do not execute it.

## DELIVERABLE

Write the exact commissioned note and return a concise report. For Q1–Q4 provide:

- `SOLID`, `UNCERTAIN`, or `NEEDS-RUNTIME-CHECK`;
- exact source/body citations and the expected contract used;
- the reasoning chain, not only a conclusion;
- any bounded defect or ambiguity, its consumer exposure, and effort/risk; and
- one smallest verification or product-action recommendation, or an explicit banked-closure
  recommendation supported by the call-site census.

Include exact file size/SHA-256 for the deliverable and the observed source identity. All Oracle
findings remain hypotheses until Arranger verification; do not label them accepted facts.

Return exactly one terminal outcome:

- `CONSULT-COMPLETE`; or
- `BLOCKED <reason>`.

## BOUNDARIES / EXCLUSIONS

- Read and advise only; write only the one Oracle2 deliverable.
- Do not edit or build product source and do not run a guest or host probe.
- Do not expand into `asl_msg_cmp`, store write/read-back framing, submit transport, aslmanager
  scheduling/reclaim, the broad client API matrix, interface-shape work, or cross-platform/macOS
  runtime comparison.
- Do not turn op-276's charset-model/simplification question into part of this renderer review.
- Do not decide preview scope, release readiness, ID state, or follow-on dispatch.
- Preserve source fact, code inference, documented contract, and runtime unknown as distinct.

## REPORT FORM

```text
REPORT
op:                 op-272
oracle:             Oracle2
source_identity:    <branch / commit / size / lines / sha256 / blob>
deliverable:        <path / size / sha256>
q1_format:          SOLID | UNCERTAIN | NEEDS-RUNTIME-CHECK — <one line>
q2_template:        SOLID | UNCERTAIN | NEEDS-RUNTIME-CHECK — <one line>
q3_time:            SOLID | UNCERTAIN | NEEDS-RUNTIME-CHECK — <one line>
q4_encoding_length: SOLID | UNCERTAIN | NEEDS-RUNTIME-CHECK — <one line>
callers:            <live preview / tool-test / dormant census>
actionable:         <findings + smallest next steps, or explicit closure recommendation>
boundary:           read_only=1 builds=0 guest_cells=0 product_writes=0 control_writes=0
terminal:           CONSULT-COMPLETE | BLOCKED <reason>
```

## MARKERS

`O2_OP272_SOURCE_IDENTITY`

`O2_OP272_Q1_FORMAT_SELECTION`

`O2_OP272_Q2_TEMPLATE_SUBSTITUTION`

`O2_OP272_Q3_TIME_FORMATTING`

`O2_OP272_Q4_ENCODING_LENGTH`

`O2_OP272_CALLSITE_CENSUS`

`O2_OP272_ACTIONABLE_ROUTING`

`O2_OP272_TERMINAL`

## RELATIONS

op-260 (store framing) / op-269 (query match, banked closure) / op-276 (encoding-model design,
separately Ready) / id-011 / li-1004.

feedback: `oss_engineering_framing`, `code_reasoned_verdict_is_hypothesis`,
`verify_signature_divergence_claims`, `agent_host_isolation`,
`no_conflate_gating_with_readiness`, `op_state_dispatch_boundary`.
