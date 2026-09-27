---
id: op-299
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-299 — Gatekeeper: replace op-298’s hard-coded scope and false-green validator with a complete dynamic record gate

op-299 | role: **Gatekeeper Ruler** (evidence/validator owner; no product write) | EXU:
**rmx-gatekeeper-rx-x64z** | state: **[Done — returned Gatekeeper commit `fb9040d`; Arranger2
M-gate rejects RECORD-GATE-CLOSED because the final dynamic scope fails, committed commands/tests
self-report failures while the attestation claims green, and shutdown/OBS/fd parsing still
false-greens; op-301 later failed Stage A and op-302 was flushed, stopping the repair chain]** | parent:
**op-298 / op-297 / op-296 / op-293 / id-011** | L1i: **li-1004** | authored:
**2026-07-11 by Arranger2**

## ARRANGER ADJUDICATION — 2026-07-11

**Verdict: PARTIAL-COMPLETION / RECORD-GATE-NOT-ACCEPTED.** op-299 remains `[Done]`. The prior
monolithic reissue pattern ended with op-301's rejected Stage A; op-302 was flushed without
dispatch, and no automatic repair follows.

Accepted first-hand:

- Gatekeeper `main@fb9040db5106d07f1722834665dddbab5ee29cd6`, parent `b6e3252`, is 36
  ahead of `origin/main@4b16fd1`; six pinned raws/corrections are unchanged; guest cells are zero.
- The broken shell checker is deleted. All 37 listed rows reproduce; manifest identity is 4,170
  bytes / SHA `9f93030effb52f8e6b565786f07506ca27b34846a213a157ba795f001790fbd2` /
  Git blob `05a39a2f27586480ab0535e0b181ca7ee13dfd20`.
- Pinned `/1` APIs remove caller-digest bypass and reproduce real A/B plus host/arbitrary rejection.
- Numeric final/panic presence and duplicate final/panic checks were added as useful partial code.

Rejected first-hand:

1. At committed HEAD, the canonical checker returns `expected_scope_count=38`, rows 37,
   `scope_match=false`: tracked ordinary file `build/op299/result-failures-final.txt` is unlisted.
   The attestation’s `37/37/errors=0` claim is false.
2. Source/test discovery remains an explicit eight-filename array. No missing/extra/duplicate/
   malformed/size/digest/hidden-family negative tests exist; the lone live integration test fails.
3. Arranger’s live targeted rerun is 55/56. Live full suite is 252/257 with five failures: the four
   stable15 failures plus the new manifest test. This is not the reported 56/56 or four-only set.
4. The frozen evidence self-falsifies: cmd1 stdout is a SyntaxError and its real command exits 1
   while its rc file says 0; cmd2 says 54/56 with two failures; cmd3 says 251/257 with six failures;
   `result-failures-final.txt` itself lists five. Separate command/stderr/rc files are absent for
   most groups.
5. Shutdown presence is not ordered: sync/power-off before DONE returns `:observed`. A malformed OBS
   line is filtered out, and numeric-prefix junk (`1800x`, `96oops`, `0oops`) parses as valid.
6. Any non-empty fd bytes pass: `validate_fd_claim([37,91], "x")` returns
   `{:ok, :ledger_validated}` without parsing identities or binding an actual leak claim.

The detached attestation is 1,322 bytes / SHA
`36a6c737b80e1be737ee5c771c23c43ab614053377d2f36dcec30a40c2cd370b` / Git blob
`0ae6ffbe2edb05e110dba5402dd75ba42a48f99e`; preserve it and all false command records as
historical evidence. Do not rewrite them. id-040 remains WAITING.

## DISPATCH BOUNDARY

DISPATCHED by the Coordinator to `rmx-gatekeeper-rx-x64z` on 2026-07-11. Write only
`/Users/me/wip-mach/rmx-gatekeeper/`. Product, Arranger, Explorer, and Oracle trees are read-only.
**Zero guest cells**: no boot, image, runtime evidence, attempt, soak, product/config edit, or
production-mode decision.

## REQUIRED BASE

- `main@b6e3252002a192210c3a688c75ce478a170c00d8`;
- parent `be5dbdc319fd7d904958164464e8578994321872`;
- `origin/main@4b16fd1b65e76cfcdb40de96069e13d3d702e3cf`, ahead 35;
- preserve unrelated untracked files and every committed raw log/correction/ledger byte-identically.

Stop `BLOCKED identity-drift` on any mismatch. Do not amend, reset, rebase, clean, or push.

## ARRANGER FIRST-HAND FAILURES AT `b6e3252`

Accepted partial facts: parent/status are exact; raw/correction identity diff is empty; all 25
**listed** manifest rows hash correctly; exact real serials return Cell A `PARTIAL-CONTROL` and
Cell B `HARNESS-NOT-ACCEPTED`; the four named full-suite failures appear unchanged; guest cells
remain zero.

`RECORD-GATE-CLOSED` is rejected because:

1. `expected_in_scope/0` is a fixed 25-string array, not a Git-derived set. It omits every tracked
   `build/op298/` ordinary record: `baseline-failures.txt`, `result-failures.txt`, and the old
   attestation. The manifest contains zero `build/op298/` rows yet reports `scope_match=true`.
2. The known-broken `build/op297/manifest_check.sh` remains committed and still exits 1 with
   `wc/tr/awk: not found`; op-298 required one working canonical checker.
3. Only three op-298 record files exist. No exact command/stdout/stderr/rc record was committed for
   real-log validation, negatives, targeted tests, full-suite base/result, diff check, or raw
   identity. The attestation contains summaries, no numeric checker rc or manifest Git blob.
4. No test path changed from `be5dbdc` to `b6e3252`; “39/39” is the old suite. The new digest/fd
   functions and required negative cases are untested.
5. The pinned serial SHA attributes are unused. `/2` trusts a caller-supplied expected digest, so
   arbitrary bytes plus their own digest reach the structural validator.
6. Arranger reproduced an arbitrary Cell-B record with malformed final/panic counters,
   `fd_leak_proven`, no fd identities, no shutdown, and its own digest returning
   `{:observed, ...}`. `validate_cell_b_serial/1` checks marker presence only, never numeric final/
   panic fields or shutdown after DONE.
7. `validate_fd_claim([37, 91], true)` returns `:ok` without consuming ledger bytes. The existing
   “structurally complete” positive fixture has no shutdown proof and still returns `:observed`.
8. The two full-suite files contain only failure names, not the exact base/result commands,
   stdout, stderr, or rc required to establish the comparison.

## A. ONE DYNAMIC GIT-DERIVED MANIFEST CHECKER

Delete `build/op297/manifest_check.sh`. Keep one canonical Elixir checker and test it.

The expected set MUST be derived at execution time from staged/tracked Git paths (`git ls-files`
or an equivalent index/tree query), never a fixed path array. Filter the live Git set to:

- every non-image tracked file below `build/op286/`, `build/op293/`, `build/op297/`,
  `build/op298/`, and `build/op299/`; and
- all matching op-286/op-293/op-297/op-298/op-299 manifest/validator sources and tests below
  `lib/rmx_os_oracle/` and `test/rmx_os_oracle/`.

The final manifest remains `build/op293/op293-sha256-manifest.txt`. Exactly two tracked in-scope
paths may be absent from it:

1. the manifest itself; and
2. `build/op299/op299-manifest-attestation.txt`, generated last.

The old op-298 attestation and both baseline/result files are ordinary in-scope rows. Every op-299
command record is also an ordinary row. Require exact set equality plus unique, well-formed,
size- and SHA-correct rows.

Add committed tests that reject missing, extra, duplicate, malformed, wrong-size, and wrong-digest
rows and prove that a newly supplied Git-derived in-scope path cannot be hidden by a fixed list.
Include one integration assertion against the final staged/tracked set.

Avoid recursive output: finalize and stage all ordinary records first, generate the final manifest,
then run the final checker. Put that final checker’s exact command, complete stdout/stderr, numeric
rc, manifest size/SHA/Git blob, row and expected-set counts, explicit exclusions, and requirement
crosswalk in the detached op-299 attestation. The commit authenticates the two excluded paths.

## B. PINNED-IDENTITY FAIL-CLOSED VALIDATOR

The trusted expected stream identity must be selected internally. A caller may not bless arbitrary
bytes by passing their digest. Either replace the current `/2` APIs with a pinned stream selector,
or reject any `expected_sha` that is not the corresponding committed serial SHA before comparing
the bytes.

For Cell B, enforce and test all of:

- every observation used by the verdict has numeric tick and PID;
- exactly one numeric `STORE_FINAL store_kb=<n> file_count=<n>`;
- exactly one numeric `PANIC_CHECK count=<n>`;
- exactly one ordered `STORE_FINAL → PANIC_CHECK → VERDICT → TERMINAL → DONE` tail;
- duplicate final, panic, verdict, terminal, or DONE markers fail;
- after DONE, `All buffers synced` precedes a captured system-power-off marker;
- a complete one-PID record remains a bounded observation, never a scheduler/product verdict; and
- malformed counters or missing shutdown fail before any `:observed` return.

Replace the Boolean fd-ledger attestation with actual claim + ledger-byte validation. Count-only
growth is `:observation`; any `leak` claim without a non-empty parseable fd-identity ledger fails.
Do not accept `has_identity_ledger=true` without consuming and validating the ledger.

Commit tests for actual Cell A/B serials, host bytes with pinned serial identity, host digest as
expected identity, arbitrary bytes with their own digest, malformed observation/final/panic fields,
missing and misordered shutdown, every duplicate tail marker, one PID, fd-leak without/empty/
malformed ledger, count-only observation, and a fully valid synthetic record including shutdown.
The new targeted total must exceed the old 39 tests.

## C. COMPLETE FROZEN COMMAND RECORD

Under `build/op299/`, preserve separate exact command, complete stdout, complete stderr, and numeric
rc files for:

1. pinned-identity real-log validation plus host/arbitrary negative controls;
2. manifest-checker and validator negative/positive tests;
3. the combined op-286/op-293/op-297/op-299 targeted suite;
4. full `mix test` at base `b6e3252` and at the result; and
5. authored-path `git diff --check`, raw/correction byte-identity comparison, and final Git scope
   census.

Record exact base/result full-suite failure sets as failures, distinct from excluded tags. The four
pre-existing stable15 failures may remain only if exact names/counts match and no new failure
appears. Every ordinary record must be finalized before the manifest; only the final attestation is
generated afterward.

## VERDICT / COMMIT

Create one additive commit by explicit paths; do not push. Return exactly one:

- `RECORD-GATE-CLOSED <commit>` only if every requirement above is represented by committed code,
  a committed test, and exact frozen output, the dynamic final set-equality checker returns rc 0,
  raw bytes are unchanged, full-suite failure sets match, and `guest_cells=0`; or
- `BLOCKED <reason>`.

Report commit/parent, full changed-path list, final manifest/attestation identities and Git blobs,
derived scope and exclusions, each command/result/rc path, all test counts/results, base/result
failure sets, raw identity, full status/origin relationship, and zero cells. A summary without the
commissioned committed records is `BLOCKED`, not closure.

## BOUNDARIES

- Record mechanics only. No guest/product/config/mechanism/soak/attempt work or new factual
  interpretation.
- id-040 stays Coordinator-held; do not select or implement a production mode.
- No push without separate Coordinator authorization.

## MARKERS

`GK_OP299_BASE_IDENTITY`

`GK_OP299_DYNAMIC_SCOPE`

`GK_OP299_MANIFEST_SET_EQUALITY`

`GK_OP299_PINNED_DIGEST`

`GK_OP299_NUMERIC_SHUTDOWN_FD_GATES`

`GK_OP299_NEGATIVE_TESTS`

`GK_OP299_REAL_LOG_RESULTS`

`GK_OP299_FROZEN_COMMANDS`

`GK_OP299_FULL_SUITE_BASELINE`

`GK_OP299_COMMIT`

`GK_OP299_TERMINAL`

## RELATIONS

op-293 / op-296 / op-297 / op-298 / id-011 / id-040 / li-1004.

feedback: `artifact_identity_needs_content_check`, `harness_authoring_is_gatekeeper`,
`agent_host_isolation`, `background_exit_code_hygiene`, `no_conflate_gating_with_readiness`,
`op_state_dispatch_boundary`.
