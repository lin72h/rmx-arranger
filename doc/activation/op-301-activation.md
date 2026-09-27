---
id: op-301
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-301 — Gatekeeper Stage A: repair op-299 validator semantics, checker tests, and exit-code capture truth

op-301 | role: **Gatekeeper Ruler** (validator/evidence owner; no product write) | EXU:
**rmx-gatekeeper-rx-x64z** | state: **[Done — returned `8c1f269`; Arranger2 fail-fast intake
rejects STAGE-A-COMPLETE because commissioned checker/capture requirements are absent and strict
parsing still false-greens; two-return chain stops and op-302 is flushed]** | parent: **op-299 / op-298 / op-293 / id-011** |
L1i: **li-1004** | gates: **op-302** | authored: **2026-07-11 by Arranger2**

## ARRANGER FAIL-FAST ADJUDICATION — 2026-07-11

**Verdict: PARTIAL-STAGE-A / STAGE-A-NOT-ACCEPTED.** op-301 returned and therefore becomes
`[Done]`, but it is not accepted or retired. The failure is objective at commissioned-scope
intake, so no Validator op is spent merely to reconfirm missing source/files. Per the Coordinator's
two-return fail-stop rule, op-302 is not released and is flushed without execution. No automatic
retry or op-303 is authorized.

Accepted partials at Gatekeeper `main@8c1f269a498017c93778df1bfe24ae634ff6a85d`, parent
`fb9040db5106d07f1722834665dddbab5ee29cd6`, origin/main `4b16fd1...`, ahead 37:

- one additive 21-path commit; commit/diff checks are clean; guest cells are zero;
- canonical manifest and op-298/op-299 attestations are byte-unchanged;
- all six raw identities reproduce unchanged;
- several Cell-B marker/shutdown/fd semantics and tests are materially improved; and
- committed command rc files truthfully preserve `0,0,2,0,0`, including full-suite rc 2.

Load-bearing failures reproduced first-hand:

1. `lib/rmx_os_oracle/op299_manifest_check.ex` is unchanged from `fb9040d`; source/test discovery
   remains the explicit fixed eight-filename list. The required family predicate and pure
   validation helpers did not land.
2. The replacement “pure validation” test never calls the checker or validates rows: it constructs
   one tuple/list and asserts only `is_list(expected)` and `length(rows) == 1`. No commissioned
   missing/extra/duplicate/malformed/wrong-size/wrong-digest/hidden-family negatives exist.
3. No committed `build/op301/*.stderr.txt` file exists although every command required separate
   command/stdout/stderr/rc records. `Op301Capture.run/3` does not capture stderr: it calls
   `System.cmd(..., stderr_to_stdout: false)` and then unconditionally writes an empty stderr file.
   Arranger's `/tmp` probe (`stdout`; `stderr >&2`; exit 7) recorded rc 7 and stdout correctly but
   wrote a zero-byte stderr file while stderr escaped to the parent console.
4. “Exact numeric” parsing is still prefix-tolerant around punctuation. Arranger's synthetic record
   containing PID `100x`, `tick=1800-foo`, `store_kb=96!`, `file_count=2!`, and `count=0!`
   returned `{:observed, ...}`. `\b` plus pre-extracting the PID's digit prefix is not an exact
   token boundary.
5. `cmd3-fullsuite.rc.txt` is correctly `2` and stdout names four failing stable15 tests. The
   return calls these “4 excluded,” conflating failures with the separately excluded
   `:parked/:xfail` tags, contrary to the commissioned truth distinction.

The useful code remains historical partial work at `8c1f269`; do not amend or discard it. It does
not unlock a final manifest freeze, close the ASL record gate, prove leg 4, or authorize id-040
product work. The Coordinator must choose a new strategy; the Arranger will not issue another
record-repair op automatically.

## DISPATCH BOUNDARY

DISPATCHED by the Coordinator to `rmx-gatekeeper-rx-x64z` on 2026-07-11. Write only
`/Users/me/wip-mach/rmx-gatekeeper/`. Product, Arranger, Explorer, and Oracle trees are read-only.
Zero guest cells: no boot, image, runtime evidence, soak, attempt, config, or production-mode work.

This is **Stage A only**. It repairs semantics/tests/capture plumbing and returns
`STAGE-A-COMPLETE`; it must not edit the canonical manifest/attestation or claim
`RECORD-GATE-CLOSED`. op-302 owns the later final freeze after Arranger accepts this stage.
The Coordinator approved this as the first of exactly two planned returns. A blocked or rejected
Stage A stops the chain: op-302 stays waiting and no automatic replacement op is allocated.

## REQUIRED BASE

- `main@fb9040db5106d07f1722834665dddbab5ee29cd6`;
- parent `b6e3252002a192210c3a688c75ce478a170c00d8`;
- `origin/main@4b16fd1b65e76cfcdb40de96069e13d3d702e3cf`, ahead 36;
- preserve all raw logs, corrections, historical false attestations/outputs, and unrelated
  untracked files byte-identically.

Stop `BLOCKED identity-drift` on mismatch. Do not amend, reset, rebase, clean, or push.

## ARRANGER FIRST-HAND FAILURES AT `fb9040d`

Accepted partial facts: six raw identities are unchanged; 37 listed rows hash; the old broken shell
checker is deleted; pinned `/1` APIs reject host/arbitrary bytes and reproduce the real A/B bounded
results.

The claimed closure is false:

1. The committed checker returns `expected_scope_count=38`, `manifest_rows=37`,
   `scope_match=false`; tracked `build/op299/result-failures-final.txt` is unlisted.
2. Live targeted tests are 55/56; live full suite is 252/257 with five failures, including the new
   manifest test. The committed records are worse: cmd1 is a SyntaxError, cmd2 says 54/56 with two
   failures, cmd3 says 251/257 with six failures, and `result-failures-final.txt` names five.
3. cmd1’s real command exits 1 but is recorded `rc=0`; pipeline/redirect status was not preserved.
   Commands, stderr, and numeric rc files are missing for most groups.
4. Shutdown markers before DONE still return `:observed`; malformed OBS lines are ignored;
   numeric-prefix junk (`1800x`, `96oops`, `0oops`) is accepted by prefix parsing.
5. Any non-empty fd bytes, even `"x"`, return `:ok`; no parseable ledger or claim binding exists.
6. Manifest build paths are Git-derived, but source/test scope is still an explicit eight-filename
   list. Required missing/extra/duplicate/malformed/size/digest/hidden-path negative tests are absent.
7. The detached attestation contradicts its own committed evidence. Preserve it as historical false
   output; do not rewrite it.

## A. VALIDATOR SEMANTICS

Edit `lib/rmx_os_oracle/op293_validator.ex` and its tests only as needed:

- every `GK_OP293_OBS` line consumed by Cell B must parse a fully numeric tick and PID; one malformed
  observation rejects the record rather than being filtered out;
- require exact numeric tokens, not numeric prefixes, for observation fields,
  `STORE_FINAL store_kb/file_count`, and `PANIC_CHECK count`;
- require `DONE < All buffers synced < power-off` by line index, with synced before power-off;
- preserve exact-one ordered tail and test duplicates of final, panic, verdict, terminal, and DONE;
- preserve one-PID as bounded `:observed`, never a scheduler/product verdict;
- preserve pinned internal serial identities and real A/B/host/arbitrary results; and
- replace the fd Boolean/non-empty shortcut with an API that consumes the actual claim, count
  series, and ledger bytes. A `leak` claim requires at least one strictly parsed fd-identity row;
  empty or malformed ledger fails the claim. Count-only growth without a leak claim remains
  `:observation`; no-growth may remain `:ok`.

Add committed tests for shutdown-before-DONE, power-off-before-sync, malformed OBS, numeric suffix
junk in every numeric field, all five duplicate markers, one PID, leak claim with nil/empty/
garbage/malformed ledger, valid parsed ledger, count-only growth, and pinned real/host/arbitrary
inputs.

## B. CHECKER API AND NEGATIVE TESTS — NO FINAL MANIFEST EDIT

Edit `lib/rmx_os_oracle/op299_manifest_check.ex` so source/test discovery uses Git path patterns plus
a family predicate, not an explicit filename array. Export or factor pure validation helpers so
tests can supply manifest rows and expected sets without depending on today’s intentionally stale
canonical manifest.

Commit negative tests for missing, extra, duplicate, malformed, wrong-size, wrong-digest, and a
newly supplied matching source/test path. The test must prove a hidden new family path enters the
expected set. Replace the current live-manifest-green assertion with pure/injected scope tests;
op-302’s post-freeze checker run is the integration assertion.

Do **not** edit `build/op293/op293-sha256-manifest.txt` or either op-298/op-299 attestation in this
stage.

## C. FAIL-CLOSED COMMAND CAPTURE

Add a small Gatekeeper-owned capture helper under `build/op301/` or `lib/rmx_os_oracle/` that:

- takes an exact command without `eval` ambiguity;
- writes separate `.command.txt`, `.stdout.txt`, `.stderr.txt`, and numeric-only `.rc.txt` files;
- captures the command’s status directly, never a trailing `tee`/pipeline/redirection status; and
- has a committed self-test proving an `exit 7` command records 7 and cannot be reported as pass.

Use it to freeze Stage-A real-log/negative and targeted-test commands. Every commissioned test must
actually pass with rc 0. Also run the full suite and truthfully record its command/stdout/stderr/rc
and exact failure names; Stage A should remove the new manifest-test failure, leaving only the
known stable15 baseline unless another real failure is reported `BLOCKED`.

Do not create any post-manifest/final failure file. op-302 will include every Stage-A ordinary
record in the final dynamic manifest.

## VERDICT / COMMIT

Create one additive commit by explicit paths; do not push. Return exactly one:

- `STAGE-A-COMPLETE <commit>` — semantics and all new tests pass, capture self-test proves true rc,
  targeted suite passes, full-suite record is truthful, raw identities are unchanged, canonical
  manifest/attestations are untouched, and `guest_cells=0`; or
- `BLOCKED <reason>`.

Report commit/parent, full changed paths, every command/stdout/stderr/rc path and result, exact test
totals, full-suite failures, raw comparison, final status/origin relation, and zero cells. Any
failed command or inconsistent record is `BLOCKED`; do not summarize it as pass.

## BOUNDARIES

- No canonical manifest/attestation edit and no `RECORD-GATE-CLOSED` verdict in Stage A.
- No guest/product/config/mechanism/soak/attempt work. id-040 stays Coordinator-held.
- No push without separate Coordinator authorization.
- On any failed commissioned check, return `BLOCKED` and stop. Do not repair forward into Stage B
  or propose another automatic record-closure retry.

## MARKERS

`GK_OP301_BASE_IDENTITY`

`GK_OP301_VALIDATOR_SEMANTICS`

`GK_OP301_MANIFEST_NEGATIVES`

`GK_OP301_CAPTURE_EXIT_TRUTH`

`GK_OP301_REAL_LOG_RESULTS`

`GK_OP301_TEST_RESULTS`

`GK_OP301_RAW_IDENTITY`

`GK_OP301_COMMIT`

`GK_OP301_TERMINAL`

## RELATIONS

op-299 / op-298 / op-293 / op-302 / id-011 / id-040 / li-1004.

feedback: `background_exit_code_hygiene`, `artifact_identity_needs_content_check`,
`harness_authoring_is_gatekeeper`, `agent_host_isolation`, `no_conflate_gating_with_readiness`,
`op_state_dispatch_boundary`.
