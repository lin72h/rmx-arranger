# op-305 — Gatekeeper: ASL renderer negative-vector acceptance for op-304

op-305 | role: **Gatekeeper** (post-retirement behavior/vector guard; no product write) | EXU:
**rmx-gatekeeper-rx-x64z** | state: **[Hold — op-304 is retired and origin-reachable; exact
source/artifact identities reproduced; WAITING on exact staging commands and a containment-safe
execution release]** | parent:
**op-304 / op-303 / id-011** | L1i:
**li-1004** | related: **op-272** | authored: **2026-07-11 by Arranger2**

## DISPATCH BOUNDARY

WAITING. Do not dispatch, build, stage, reserve a guest, load/execute target artifacts, or write
evidence yet.

op-304's correctness, publication, and origin gates are closed. Before release, the Arranger must
still bind exact artifact-install/staging commands and a containment mode that never loads or runs
rmxOS target artifacts or their constructors on the physical development host. Only then may the
Coordinator release this op to `rmx-gatekeeper-rx-x64z`, writing only
`/Users/me/wip-mach/rmx-gatekeeper/`.

The commissioned Gatekeeper paths are:

- `lib/rmx_os_oracle/op305_renderer_validator.ex`;
- `test/rmx_os_oracle/op305_renderer_validator_test.exs`; and
- `build/op305-asl-render/` for raw records, artifact copies/identities, and the attestation.

Any required path outside that set is `BLOCKED SCOPE-EXPANSION`; do not park/register the vectors
in an Explorer or product repository.

## REQUIRED RELEASE ANNOTATION

This brief is finalized and deliberately held. Before dispatch, the Arranger appends only the
resolved release identities—accepted op-304 commit/parent, source blobs, origin branch tip, built
libasl/aslutil/asld hashes, and the exact artifact-install/staging commands. That annotation binds
the already-defined scope below; it may not add vectors, guest cells, product work, or another EXU.
If those identities cannot be reconciled, keep this op `[Hold]` and do not dispatch it.

## PARTIAL RELEASE IDENTITY / SAFETY HOLD — 2026-07-11

Arranger2 reproduced the accepted source and extant Implementer build identities:

- product commit / live `alpha` / `origin/alpha`:
  `a52a2ef51560943f7af4fe0b38e27f83508fd9b6`, parent
  `ceb46edc5f910660d4fa7ecd9e90501ebd86b1ba`, clean and `0/0`;
- source blobs: `asl_msg.c` `dd08564a52d09b2ea0fc280a2b15f027976e5900`, `asl_util.c`
  `50d603ae154d9093b04ec977c93b0bfd58bb8a78`, `syslog.c`
  `4a5c0d9081c19f1abe1cc5e34bdbf5092b6c79d5`, `asl_action.c`
  `b28af99801ff7ef58ffa810c8a026117a7ef9625`;
- extant op-304 artifacts: `libasl.so.1` 220,248 bytes / SHA-256
  `4e64bec974d74614d3dcf56c32af70b42e14221b7641af3a8f8a4ded01fe3b90`, `libasl.a` 891,466 /
  `48671e0f30c4652013107dc9c670c60c46a146083488a92ab506092218bc0a80`, `aslutil` 54,800 /
  `718bbf3bd8e3c49ac4cef5a1d758dc2fc94f396e5aed7db5c06d1230e5e24b43`, and `asld` 164,336 /
  `12ef2d4dd33143d3930fbb831394b9eb016272003f1b8d8190d5174cb98b9c28`.

The publication return does not supply the exact Gatekeeper staging/install commands. In addition,
post-incident doctrine treats `dlopen`, target-linked executables, preload-driven target libraries,
and constructors as runtime execution—not host-safe inspection. Those two gates keep op-305 held.
Static hashing/ELF inspection on the host is permitted; behavioral vectors require a separately
authorized disposable guest or another explicitly approved containment mechanism.

## ACCEPTANCE SCOPE

Against the exact accepted op-304 artifact, run a fail-closed contained negative/positive vector
matrix for:

- NULL format defaults STD while explicit RAW remains RAW;
- `xml.4` selects XML and emits four fractional digits;
- terminal-backslash custom templates remain bounded and deterministic;
- truncated UTF-8 and surrogate encodings used as **values** select XML data/base64; the same
  invalid sequences used as **keys** omit their complete pair; valid boundaries stay keys/strings;
- configured XML metacharacters are escaped while non-XML SAFE output is unchanged; and
- wrong artifact identity, missing/duplicate terminal, and one known-bad control built only from a
  Gatekeeper-owned fixture or the pinned pre-fix artifact are rejected by the validator. Never
  manufacture that control by editing or rebuilding product source.

No guest cell is reserved by this held op. If an asld configured-sink observation genuinely requires
a guest after the accepted artifact is pinned, return to the Arranger for an explicit cell decision;
do not self-authorize one.

## BOUNDARIES

- Gatekeeper-owned harness/evidence only; no product, control, Explorer, Oracle, or Validator writes.
- No product build, source edit, image mutation, ASL reclaim/soak, id-040, or broader renderer audit.
- No inference from op-304's self-checks; consume the exact accepted artifact independently.
- This held brief allocates the dependent op ID but authorizes no execution.

## REQUIRED EVIDENCE / VALIDATOR

- Preserve raw command/output records and hashes for every vector and artifact-identity check.
- Use a fail-closed validator in the Gatekeeper repository; prove it rejects a wrong artifact,
  missing/duplicate terminal, and the Gatekeeper-owned or pinned-pre-fix known-bad control before
  accepting the fixed artifact.
- Record full-repository status and commit only op-305-owned harness/evidence paths explicitly.
- Static host-only inspection consumes zero guest cells. Target-artifact execution on the physical
  host is forbidden. If a disposable guest is authorized, the release annotation must name its
  image/BOM and the cell is consumed at runtime start.

## RETURN / VERDICT

Return exactly one of `ACCEPTANCE-PASS`, `PRODUCT-FAIL`, `HARNESS-NOT-ACCEPTED`, or
`PROVENANCE-NOT-ACCEPTED`, with complete raw records, fail-closed controls, the exact artifact
identity, full status, one explicit Gatekeeper commit, and push=0. `[Done]` records the return only;
it does not alter op-304's prior correctness retirement, retire op-305, or make ASL leg 4 green.

## MARKERS

`GK_OP305_ARTIFACT_IDENTITY`

`GK_OP305_NULL_DEFAULT`

`GK_OP305_XML_SUFFIX`

`GK_OP305_TERMINAL_SLASH`

`GK_OP305_UTF8_KEY_VALUE`

`GK_OP305_XML_ENCODING`

`GK_OP305_FAIL_CLOSED_CONTROLS`

`GK_OP305_COMMIT`

`GK_OP305_TERMINAL`

## RELATIONS

op-304 / op-303 / op-272 / id-011 / li-1004.

feedback: `evidence_first`, `artifact_identity_needs_content_check`, `agent_host_isolation`,
`no_conflate_gating_with_readiness`, `op_state_dispatch_boundary`.
