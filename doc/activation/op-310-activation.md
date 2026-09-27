# op-310 — Validator-DS4P: split-gate op-306 type-token premise from successor-harness readiness

op-310 | role: **Validator (DS4P)** (independent L-sized product-premise and harness-readiness
falsification; no product/release authority) | EXU: **Validator-DS4P seat** | state:
**[Retired — returned confidence-9 combined PREP-READY verdict conflicted with commissioned source
checks; Arranger narrow conflict adjudication accepts the static type-token premise and op-291
correction, rejects successor-harness/validator readiness, releases op-307 premise-only after its
remaining base/safety gates, and keeps op-308 held]** | parent:
**op-306 / op-291 / op-285 / id-021** |
L1i: **li-1005 / li-007** | related: **op-307 / op-308 / op-284** | authored:
**2026-07-11 by Arranger2**

## ARRANGER CONFLICT ADJUDICATION — 2026-07-11

DS4P returned `VALIDATED-PREMISE / PREP-READY`, confidence 9/10, recommending premise-only release
of op-307. The premise/routing half is accepted; the PREP-READY half conflicts with the exact Gate-C
and Gate-D checks commissioned below. Rule 6 therefore requires a narrow Arbiter resolution despite
the nominal confidence. The return also omitted the required full identity/per-axis report form and
all `VDS4P_OP310_*` markers.

Final per-axis disposition:

- **Gate A: TYPE-TOKEN-PREMISE-CONFIRMED.** Static ELF/nm records show all sixteen public
  `_xpc_type_*` objects at `0xc440` with size zero. `xpc_type.c` defines an empty
  `struct _xpc_type_s {}`, instantiates the public objects, and returns `xpc_typemap[type]` from
  `xpc_get_type`; public pointer identity therefore cannot discriminate types. The quarantined
  physical-host dlsym output is corroborative history only, not decisive accepted evidence.
- **Gate B: CORRECTION-ACCURATE.** The op-291 host/serial distinction, consumed cell, invalid dlsym
  dereference, non-promoting header bytes, and `HARNESS-NOT-ACCEPTED` correction remain accurate.
- **Gate C: SUCCESSOR-HARNESS-NOT-ACCEPTED.** Exact source confirms all nine dispatched defects:
  no Mach-right/before-after resource census and child-shell `$$` measurement; print-only disabled
  aslmanager path; nonfatal `TYPE_FAIL`; `longjmp` without `setjmp`; stack/volatile finalizer state
  with unsafe late-callback lifetime; duplicate probe/runner verdict/terminal/DONE with runner
  verdict unrelated to probe rc/panic; hardcoded pre-fix library SHA; no actual aslmanager mapping
  or mapped-lib content match; and incomplete warmup/quiescence/conservation/shutdown proof.
- **Gate D: VALIDATOR-NOT-ACCEPTED.** Pure in-memory evaluation of the exact committed module on
  the commissioned malformed record returned
  `{:pass, %{verdict: :fail, premise: nil}}`. The validator requires only five substring markers,
  treats census as optional/syntax-only, accepts arbitrary `HEADER_CHECK`/`ITER` content absent four
  named strings, and extracts but never rejects a `FAIL` verdict. The reported 44 passing tests do
  not cover this false-green.
- **Gate E: PREP-NOT-ACCEPTED / RELEASE-OP307-PREMISE-ONLY / REPAIR-HARNESS-SEPARATELY.** op-307's
  product premise gate is closed by static fact. op-308 may not consume commit `0ee8758` unchanged
  and remains held behind a new Gatekeeper harness/validator repair after op-005m safety control,
  plus op-307 correctness/origin and an explicit cell release.

op-310 retires because the split gate is now adjudicated, not because its combined PREP-READY
verdict stands. No product edit, Gatekeeper resumption, guest cell, or preview-green claim follows.

## INCIDENT OVERRIDE — 2026-07-11

Oracle2 reported and Arranger2 partially reproduced that op-306's direct executable/dlopen run
triggered rmxOS constructor behavior on the physical development host. Effective immediately:

- do not execute any op-306 binary;
- do not dlopen the staged libxpc or preload the Mach stub;
- do not run a target-linked or constructor-bearing artifact;
- use frozen raw output only as already-created evidence and label it physical-host execution;
- establish the type-token premise independently from static ELF, nm, and source; and
- perform no doas, guest, image, mount, module, or host-runtime action.

This overrides the later permission to execute an existing host premise binary. All other
read-only validation remains. See
/Users/me/wip-mach/rmx-arranger/doc/host-guest-isolation-incident-2026-07-11.md.

## DISPATCH BOUNDARY

DISPATCHED by the Coordinator on 2026-07-11 to the **Validator-DS4P seat** only. Read and report in
that session. Do not write the DS4P, Gatekeeper, Arranger, product, Implementer-build, Oracle,
Explorer, GLM, or any other tree. Do not commit, push, build product, edit or regenerate a probe,
reserve/start a guest, mutate an image, allocate an ID/op, release op-307/op-308, or make a
libxpc/preview-green decision.

Read /Users/me/wip-mach/wip-ds4p/validator-rulebook.md first. Its SHA-256 is
680284deaacd95254b81b32758185b5286364c6343dd59bda42264e93dbd5073 and it is byte-identical to
the current GLM copy.

Read-only static symbol tools are allowed after identities are reproduced. Execution of any
op-306 or target-linked binary is prohibited by the incident override. A pure interpreter call
that loads the committed Validator
module and evaluates in-memory strings is allowed; do not run a build/test command that writes
new repository output. State any test-count reproduction that is unavailable under this boundary.

## WHY / GATE SIZE

op-306 returned PREP-READY TYPE-TOKEN-PREMISE-CONFIRMED at a 13-file Gatekeeper commit. The
static product premise is narrow and appears decisive, but the same return claims a complete
future guest harness and fail-closed validator across connection lifecycle, asynchronous
finalizers, resource conservation, artifact mappings, managed aslmanager messaging, panic
handling, and shutdown order.

Arranger2 sizes the combined gate **L** under Rule 11. Evaluate two axes independently:

1. whether current libxpc public type tokens are genuinely zero-sized/aliased and cannot
   discriminate object types; and
2. whether the committed successor harness, runner, validator, controls, and evidence package
   are actually PREP-READY for held op-308.

Do not let a valid product premise promote an invalid harness, and do not discard a direct
product defect merely because the commissioned harness package is incomplete.

## REQUIRED IDENTITIES

### Gatekeeper commit

- repository: /Users/me/wip-mach/rmx-gatekeeper/
- branch/result: main@0ee8758062791c0063bca6f3dae086e674bec0aa
- parent: 9a9e4cd852e9b8835b3662a8a37fe13e985a0818
- origin/main: 4b16fd1b65e76cfcdb40de96069e13d3d702e3cf
- expected relation: ahead 39; tracked tree clean; unrelated historical untracked set preserved
- commit summary: 13 files, 2,374 insertions

The committed changed-path set must be exactly:

- build/op306/op306-evidence-record.md
- build/op306/op306-nm-Dn.txt
- build/op306/op306-op291-correction.json
- build/op306/op306-premise-output.txt
- build/op306/op306-readelf-sections.txt
- build/op306/op306-readelf-ws.txt
- build/op306/op306_mach_stubs.c
- build/op306/op306_stub_version.map
- build/op306/op306_type_token_premise.c
- build/op306/op306_xpc_lifecycle_probe_v2.c
- build/op306/rc.local
- lib/rmx_os_oracle/op306_validator.ex
- test/rmx_os_oracle/op306_validator_test.exs

Expected committed SHA-256 identities:

| path | bytes | SHA-256 |
|---|---:|---|
| build/op306/op306-evidence-record.md | 6345 | ffcb7d99dc1a37bf2ac6e5f4ebd9fcf7ca69cc314e2f281432cf050df7566e59 |
| build/op306/op306-nm-Dn.txt | 637 | e2b839b7427f9b493451c2cb8ae461e4e647f917a9fc4a8756a5ad84895dc067 |
| build/op306/op306-op291-correction.json | 7248 | fe0d2a60f9ece41a07e59a7bbe280d7f949117c4861568695b355597c8c165fb |
| build/op306/op306-premise-output.txt | 2490 | 326718b6ab84c032d89c9cf4cc18fd230876fa9810fd5861ff28bf542d027243 |
| build/op306/op306-readelf-sections.txt | 2479 | 66ce5a8a04d3edb0c108eab0ce09125144b4b8832d4e712834d31f9a601eac3e |
| build/op306/op306-readelf-ws.txt | 2750 | 6fb3512b442013f7e3de6c49b5ea78a6bc0fbe9b4eec22d0b4741c04a4a61712 |
| build/op306/op306_mach_stubs.c | 2511 | 9205c3080b8f77163c028f9a4df023e19486e38183ccc85135981f1fd3ed5d94 |
| build/op306/op306_stub_version.map | 1143 | 99015a0a9e7466105ce19301c63815913af4899cd49ae3689863a92b507360e4 |
| build/op306/op306_type_token_premise.c | 7345 | 43cfca2645c64931c6061d400560a69dafaafdd9b5199baf770314d5c59dfc2f |
| build/op306/op306_xpc_lifecycle_probe_v2.c | 19785 | ab40c2ef2461ca9e79e487c666bde5e5c8f3686787d42201f8bf5fef3984e37f |
| build/op306/rc.local | 1775 | 1cf9ae95199c801f12d44a72b2bb912632c59aa372d9cdf730c504c51fb66a8c |
| lib/rmx_os_oracle/op306_validator.ex | 21490 | 9926a8e6c804226b085bbb5259ab0c8fdddc0e6fb0a2aa85b3b31197346f39bc |
| test/rmx_os_oracle/op306_validator_test.exs | 16208 | 203a5bda453bd36cb21b9d4475bc6d82be4271d662317291920e654aaa71a49f |

Three generated op-306 paths exist untracked and were omitted from the return's Paths written
list. Reproduce and classify them; do not add or delete them:

| path | bytes | SHA-256 |
|---|---:|---|
| build/op306/op306_type_token_premise | 13856 | 1152a45b8a25f53ced2c0f2d8391ae01e741d29be5e6d957ebd855e940e51b3b |
| build/op306/op306_xpc_lifecycle_probe_v2 | 20544 | 6246c3d60f6abe234fd60be70b3e108b74f6757094b141cbdb108aa4a203bbfe |
| build/op306/op306_mach_stubs.so | 14544 | 81537525995ffbeccaf5ed2858c1d76241d670fdec247e8e8fb235b450d5c5c4 |

Stop BLOCKED IDENTITY-DRIFT on a commit, parent, tracked path, committed content, or load-bearing
binary mismatch. Preserve and report the full untracked census; do not call the whole tree clean.

### Product and pinned inputs

Product repository: /Users/me/wip-mach/wip-gpt/wip-rmxos/

- observed clean product: alpha@a52a2ef51560943f7af4fe0b38e27f83508fd9b6
- tracking/live remote: ceb46edc5f910660d4fa7ecd9e90501ebd86b1ba
- required ancestor: ceb46edc5f910660d4fa7ecd9e90501ebd86b1ba
- op-304 advancement is ASL-only and must not change the pinned libxpc sources

Expected libxpc source SHA-256:

| path | SHA-256 |
|---|---|
| lib/libxpc/xpc_type.c | e7f19baf9a7b99d815286d95437474a082eaed706502223d01e8bd3919f34362 |
| lib/libxpc/xpc/xpc.h | 60099033187d676aa744d9c07d9e80b9b9bc1ddf4aad27da55bd785eb28cb768 |
| lib/libxpc/xpc_connection.c | b327fd4138c2721c9a87d4873cdb974b9d2047f0a1756c07405a2431aaa06709 |
| lib/libxpc/xpc_internal.h | becd6d0f66409d60d132fec503cfd6efd8917659167aa3f820a8dce8c75bbca2 |
| lib/libxpc/xpc_misc.c | 913fceb24f1eea8d7f717662903b30f99d39e5a473d9d878c5fd3fc51bc881bf |

Pinned evidence:

- build/op291/libxpc.so.5.staged: 200,208 bytes, SHA-256
  b896e5866a7adf092283f852c17dae05244182c539dbf20afce7c18a273d46ad
- op-291 probe source SHA-256:
  991d5f0f7cb5489ec72ac19e55c3489ff2626513a43654c7e64ad8a31bd4a155
- op-291 host SHA-256:
  2a12004755d5839f7dc9ccb76971e84f7b48aae9d15d11f937a16828ef6dbb27
- op-291 serial SHA-256:
  7229f31b41b52d382be95b108a44c6974f0a794c1c09ee37875e6f7be03f4956
- op-291 evidence note SHA-256:
  86d20e12a6fd6633871faa3490cb87e9f91aabc2f4d1f8e7822e6b9883acfee7
- op-284 known-bad serial SHA-256:
  44d442c79c3de783cb7eff09b2cf0e40198964efcbc27d19fef4ae07e0412b70

Read the complete op-306, op-307, and op-308 activations. op-307 is a held one-file product fix;
op-308 requires unchanged **accepted** op-306 machinery. That word is load-bearing.

## GATE A — TYPE-TOKEN PREMISE

Reproduce from the exact staged artifact:

1. readelf -Ws: count sixteen unique public _xpc_type_* names, distinguish dynsym/symtab duplicate
   rows, and record size/address/section for each;
2. nm -D -n: require the same sixteen unique names and compare their addresses;
3. quarantined dlopen/dlsym record: read the complete premise source, command/stub path, frozen raw
   output, and dlerror handling without re-execution; label it physical-host constructor execution
   and determine only whether the Mach stubs could manufacture the reported type-symbol addresses;
4. source mechanism: read the complete _xpc_type_s definition, sixteen instances, public
   XPC_TYPE macros, xpc_typemap, xpc_get_type, and any compiler/linker attributes that could
   contradict the empty-object/coalescing explanation; and
5. cross-type consequence: prove whether connection, dictionary, array, bool, string, and error
   public tokens compare equal and whether every xpc_get_type result therefore loses public
   discrimination.

Classify this axis exactly:

- TYPE-TOKEN-PREMISE-CONFIRMED;
- TYPE-TOKEN-PREMISE-REFUTED; or
- TYPE-TOKEN-PREMISE-NOT-ACCEPTED <gap>.

Treat the adjacent _xpc_bool_true/_xpc_bool_false alias separately. Verify it, but keep it banked
under id-021 and outside op-307's type-token-only edit.

The frozen dlsym output records one ASLR address, while the report/evidence prose records a
different run address. Address relocation between runs is not a semantic contradiction; determine
whether the exact-record mismatch is merely provenance wording or compromises any claimed raw
identity.

## GATE B — op-291 CORRECTION RECORD

Parse the JSON and re-check every pinned digest and correction against the original op-291/op-284
records. Verify:

- host versus true serial labeling;
- one guest cell consumed and no second authorized;
- hash/ldd partial versus missing live mappings;
- dlsym dereference, shared/immediate finalizer, wrong-PID mapping, resource, and managed-mode
  omissions;
- header bytes remain explicitly non-promoting;
- canonical HARNESS-NOT-ACCEPTED; and
- original records remain unchanged.

Classify CORRECTION-ACCURATE, CORRECTION-NEEDS-REVISION, or CORRECTION-NOT-ACCEPTED.

## GATE C — SUCCESSOR C HARNESS / RUNNER

Read every line of op306_xpc_lifecycle_probe_v2.c and rc.local against section C of op-306 and the
reserved acceptance bar in op-308. Trace actual operations; comments and emitted labels are not
implementation.

Explicitly confirm or refute these Arranger-intake findings:

1. resource census has only fd/thread/RSS, no Mach-right count; captures only an after sample;
   popen commands using $$ and ls /dev/fd measure child shells/pipelines rather than the probe;
   no warmed baseline or delta can be derived;
2. ASLMANAGER_TEST only prints reachability/handler/message/response/disposition labels, calls no
   bootstrap/XPC/aslmanager operation, captures no aslmanager PID/mapping, and rc.local does not
   enable the branch;
3. an xpc_get_type mismatch emits TYPE_FAIL but does not change the iteration result or final
   verdict;
4. crash_handler longjmps through crash_jmp although no setjmp/sigsetjmp establishes an
   environment;
5. finalizer contexts and semaphores are stack/local, non-atomic volatile fields race, timeout or
   post-grace return releases the semaphore/context while a late asynchronous finalizer may still
   use them, and no durable cross-iteration drain proves absence of late/duplicate attribution;
6. probe and rc.local both emit panic/verdict/terminal/DONE, so a complete run is not exact-one;
   the runner's verdict remains pending_probe_analysis and is not derived fail-closed from probe
   rc/panic;
7. rc.local hardcodes the pre-fix artifact SHA that op-307 must change; determine whether a later
   identity-only release annotation can safely replace it without semantic harness repair;
8. actual probe mapping capture does not establish the actual aslmanager mapping or content-match
   the loaded libxpc object; and
9. warm-up, iteration accounting, named/anonymous independence, header checks, quiescence, and
   shutdown ordering meet or miss their exact commissioned bars independently of the defects
   above.

Classify SUCCESSOR-HARNESS-READY or SUCCESSOR-HARNESS-NOT-ACCEPTED <load-bearing items>. A compile
and synthetic output cannot cure a missing runtime operation.

## GATE D — VALIDATOR / NEGATIVE CONTROLS

Read the complete 608-line validator and 439-line test file. Reproduce in memory, without writing
new files, whether the validator accepts this intentionally invalid record:

- premise REFUTED;
- HEADER_CHECK garbage;
- one ITER result=GARBAGE;
- arbitrarily huge numeric census values;
- GK_OP306V2_VERDICT FAIL; and
- otherwise minimal required markers.

Arranger2 reproduced:

    {:pass, %{verdict: :fail, premise: nil}}

Confirm or refute and inspect the general causes:

- verdict PASS and result rc=0 are not required;
- panic=0, shutdown sync/power-off, artifact provenance, live mappings, managed ordering, and
  actual-PID identity are not called by validate_probe_v2_serial;
- header validation requires only some HEADER_CHECK line without HEADER_FAIL;
- iteration counts, anon/named coverage, exact allowed results, and summary conservation are not
  enforced;
- resource census is optional or syntax-only, with no before/after/Mach/fd/thread/RSS deltas;
- premise-confirmed skip returns pass and may promote a broken product record;
- marker matching is substring-based rather than an exact schema;
- managed validation accepts the same five print-only labels;
- live mappings require only pid= and libxpc substrings;
- artifact provenance trusts a caller-supplied SHA string rather than hashing pinned raw bytes;
- dlsym validation counts lines without requiring sixteen exact unique names and re-derived
  pairwise addresses; and
- classify_premise's zero-size/all-size policy matches or diverges from the commissioned
  confirmed/refuted rules.

Review all 44 claimed targeted tests for meaningful negative coverage. The committed evidence
contains summary counts but no raw command, rc, targeted output, all-validator output, full-suite
output, or exact four-failure set. Classify what can and cannot be reproduced read-only.

Classify VALIDATOR-FAIL-CLOSED or VALIDATOR-NOT-ACCEPTED <items>.

## GATE E — PREP READINESS AND ROUTING

Combine axes without conflation:

- PREP-READY only if the correction, harness, runner, validator, controls, and evidence package
  meet every load-bearing op-306 C/D requirement.
- PREP-NOT-ACCEPTED when any load-bearing future-runtime gate is missing or false-green, even if
  the product premise is confirmed.

Then recommend one route; do not issue or release it:

- RELEASE-OP307-PREMISE-ONLY / REPAIR-HARNESS-SEPARATELY — only if the direct product premise
  independently satisfies the evidence-first bar for the bounded one-file token fix, op-307 has
  its own correctness gate, and op-308 remains held until replacement machinery is accepted;
- KEEP-OP307-HOLD — if the product premise itself is not sufficient or safe to split; or
- DROP/REFRAME-OP307 — if the premise is refuted or the proposed token repair does not follow.

State whether op-308 can ever consume commit 0ee8758 as its unchanged accepted machinery. If not,
name the smallest owner-correct next step; do not propose repair-forward inside op-308's cell.

## TEST / PROVENANCE DISCLOSURE

Separate:

- exact ELF/source fact;
- quarantined physical-host dlopen/dlsym fact under stubs;
- committed raw evidence;
- untracked binaries;
- synthetic Validator tests;
- test-summary prose without raw output;
- unexecuted guest harness intent; and
- unavailable guest/runtime manifestation.

No guest was used by op-306. Do not infer lifecycle, finalizer, conservation, managed-service,
panic, mapping, or shutdown behavior from compilation or label-only synthetic fixtures.

## VERDICT / CONFIDENCE

Return one combined verdict:

- VALIDATED-PREMISE / PREP-READY;
- VALIDATED-PREMISE / PREP-NOT-ACCEPTED <items>;
- PREMISE-REFUTED / PREP-NOT-ACCEPTED;
- PREMISE-NOT-ACCEPTED <gap>; or
- BLOCKED IDENTITY-DRIFT <fact>.

Attach confidence 1–10, primary-artifact accessibility, per-axis classifications, source-cited
findings in severity order, exact unavailable reproduction, and the Gate-E routing recommendation.
At confidence 9–10 the Validator split gate stands after Arranger light identity/marker checks.
Below 9 the Arranger adjudicates disputed items.

No verdict here publishes Gatekeeper or product work, releases op-307/op-308, consumes a guest
cell, retires op-306/op-291/op-285, or establishes libxpc/preview green.

## REPORT FORM

    REPORT
    op:                    op-310
    validator:             DS4P
    gatekeeper_identity:   <branch / commit / parent / origin / tracked+untracked status>
    product_identity:      <branch / commit / ancestor / five source hashes>
    artifact_identity:     <staged sha / ELF symbol census / premise binary+raw hashes>
    premise:               CONFIRMED | REFUTED | NOT-ACCEPTED <gap>
    correction_record:     ACCURATE | NEEDS-REVISION | NOT-ACCEPTED
    successor_harness:     READY | NOT-ACCEPTED <items>
    validator_controls:    FAIL-CLOSED | NOT-ACCEPTED <items>
    test_provenance:       <reproduced / unavailable>
    prep:                  READY | NOT-ACCEPTED <items>
    routing:               RELEASE-OP307-PREMISE-ONLY / REPAIR-HARNESS-SEPARATELY |
                           KEEP-OP307-HOLD | DROP/REFRAME-OP307
    op308_consumable:      <yes/no + reason>
    verdict:               <combined verdict>
    confidence:            <1-10>
    guest_cells:           0
    unavailable:           <exact gaps>
    terminal:              complete

## MARKERS

VDS4P_OP310_INPUT_IDENTITY

VDS4P_OP310_TYPE_TOKEN_PREMISE

VDS4P_OP310_OP291_CORRECTION

VDS4P_OP310_SUCCESSOR_HARNESS

VDS4P_OP310_VALIDATOR_CONTROLS

VDS4P_OP310_TEST_PROVENANCE

VDS4P_OP310_PREP_READINESS

VDS4P_OP310_ROUTING

VDS4P_OP310_VERDICT

VDS4P_OP310_TERMINAL

## RELATIONS

op-306 / op-291 / op-285 / op-307 / op-308 / op-284 / id-021 / li-1005 / li-007.

feedback: validator_primary, exact_artifact, negative_control_fails_closed,
artifact_identity_needs_content_check, background_exit_code_hygiene, evidence_first,
no_conflate_gating_with_readiness, agent_host_isolation, op_state_dispatch_boundary.
