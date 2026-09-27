# op-298 — Gatekeeper: close op-297 scope/digest/shutdown/counter/fd record gaps host-only

op-298 | role: **Gatekeeper Ruler** (evidence/validator owner; no product write) | EXU:
**rmx-gatekeeper-rx-x64z** | state: **[Done — returned Gatekeeper commit `b6e3252`; Arranger2
M-gate rejects RECORD-GATE-CLOSED because scope is hard-coded/incomplete, the broken checker and
missing command records remain, and malformed/no-shutdown/fd records still false-green; zero-cell
op-299/op-301 also returned partial and op-302 was flushed, stopping the repair chain]** | parent:
**op-297 / op-296 / op-293 / id-011** | L1i: **li-1004** | authored:
**2026-07-11 by Arranger2**

## ARRANGER ADJUDICATION — 2026-07-11

**Verdict: PARTIAL-COMPLETION / RECORD-GATE-NOT-ACCEPTED.** op-298 remains `[Done]`; op-299 and
op-301 also returned partial, and op-302 was flushed under the fail-stop rule.

Accepted first-hand:

- Gatekeeper `main@b6e3252002a192210c3a688c75ce478a170c00d8`, parent `be5dbdc`, is 35
  ahead of `origin/main@4b16fd1`; raw/correction identity diff is empty and guest cells are zero.
- All 25 listed manifest rows reproduce. The manifest is 2,918 bytes / SHA
  `645ee049bb0c9b540513007431d30fbeedad11add58c7097e119ea6b52b0a947` / Git blob
  `25b296c0c0e01c3ec57ddf7e0c6c06153d11b3c3`.
- Exact real serial calls return Cell A `PARTIAL-CONTROL` and Cell B
  `HARNESS-NOT-ACCEPTED`; exact Cell-A host bytes are rejected by the new wrapper.
- Arranger independently reran the targeted command outside the repository build tree: 39/39 pass.
  The four stored base/result failure names match, but their executions are not frozen.

Rejected first-hand:

1. `expected_in_scope/0` is a hard-coded 25-path array. `git ls-tree` shows three tracked
   `build/op298/` files, while the manifest has zero `build/op298/` rows. The checker therefore
   returns `scope_match=true` over a false expected set.
2. The unchanged shell checker still exits 1 after overwriting `PATH` (`wc/tr/awk: not found`).
3. The commit adds no exact command/stdout/stderr/rc records. Its attestation contains summaries,
   lacks numeric checker rc and manifest Git blob, and the two failure files contain names only.
4. No test path changed. The same 39 tests do not cover the new digest/fd functions or the
   commissioned malformed-counter, shutdown, digest-identity, and ledger negatives.
5. The pinned serial SHA attributes are unused; the wrapper trusts a caller-provided digest.
   Arranger passed arbitrary bytes with their own SHA and reached the structural validator.
6. A two-window record with malformed final/panic counters, `fd_leak_proven`, no fd identities,
   and no shutdown returns `{:observed, ...}`. The parser checks presence, not numeric values or
   shutdown after DONE.
7. `validate_fd_claim([37, 91], true)` returns `:ok` without consuming ledger bytes. The existing
   structurally-complete positive fixture contains no shutdown proof and still returns observed.

Routing: op-299 replaces the fixed scope with a staged/tracked Git-derived census, deletes the
broken checker, pins trusted stream identities, enforces numeric/shutdown/fd-ledger gates, commits
the missing tests and exact command records, and uses only manifest-self plus a new detached
op-299 attestation as exclusions.

## DISPATCH BOUNDARY

DISPATCHED by the Coordinator to `rmx-gatekeeper-rx-x64z` on 2026-07-11. Write only
`/Users/me/wip-mach/rmx-gatekeeper/`. Product, Arranger, Explorer, and Oracle trees are read-only.
**Zero guest cells**: no boot, image, new runtime evidence, attempt, soak, or product/config edit.

## REQUIRED BASE

- `main@be5dbdc319fd7d904958164464e8578994321872`;
- parent `a66e3b7068e86eae71d7f6be46267be1246ec281`;
- `origin/main@4b16fd1b65e76cfcdb40de96069e13d3d702e3cf`, ahead 34;
- preserve all prior commits, unrelated untracked files, six raw logs, corrections, ledgers, and
  historical verdicts byte-identically.

Stop `BLOCKED identity-drift` if any identity differs. Do not amend, reset, rebase, clean, or push.

## FIRST-HAND FAILURES TO CLOSE

Arranger2 reproduced at `be5dbdc`:

1. Elixir checker says 16 listed rows pass, but nine required artifacts besides the manifest are
   unlisted: five op-286 record files, op-286 validator/test, and both new op-297 script/report.
2. `manifest_check.sh` fails all rows because `read ... PATH` overwrites shell `PATH`.
3. Cell-A host bytes are accepted as serial; no digest-aware entry point exists.
4. A Cell-B record with malformed final/panic counters, `fd_leak_proven`, no fd identities, and no
   shutdown returns `{:observed, ...}`.
5. The positive fixture contains no shutdown proof; digest, malformed-counter, fd-claim,
   clean-shutdown, duplicate-verdict/DONE, and related tests are missing.
6. Test file has 15 tests, not 13. Full `mix test` has four actual failures (apparently
   pre-existing), not merely four excluded tests; exact stdout/stderr/rc is not frozen.

## A. ONE CANONICAL COMPLETE MANIFEST

Use one canonical checker (prefer the Elixir module). Delete the broken shell checker or fix and
test it; no committed checker may be knowingly broken.

The checker must derive the expected in-scope set from staged/tracked Git paths and require exact
set equality, not merely validate listed rows. Scope includes all non-image op-286/op-293/op-297/
op-298 record files plus their validator/test sources. It must reject missing, extra/unlisted,
duplicate, malformed, size-mismatched, or digest-mismatched rows.

To avoid recursion, exactly two committed paths may be outside the artifact manifest:

1. `build/op293/op293-sha256-manifest.txt` itself; and
2. `build/op298/op298-manifest-attestation.txt`, generated after the final manifest check.

No other in-scope omission is allowed. The attestation must contain the exact checker command,
complete stdout/stderr, rc, final manifest size/SHA/Git blob, row count, expected-set count, and
the two explicit exclusions. Git commit identity authenticates both excluded files.

## B. DIGEST-AWARE FAIL-CLOSED VALIDATOR

Add/use real-log entry points that consume raw bytes plus expected stream identity/SHA-256.
Required behavior and committed tests:

- passing host bytes or a host digest as either serial returns digest/identity failure;
- Cell A below 500 KiB remains `PARTIAL-CONTROL` only after identity and structural checks;
- Cell B requires numeric observation ticks/PIDs, numeric `STORE_FINAL store_kb/file_count`, and
  numeric `PANIC_CHECK count`;
- exactly one ordered `STORE_FINAL → PANIC_CHECK → VERDICT → TERMINAL → DONE` tail;
- duplicates of verdict, terminal, or DONE fail;
- after DONE, require captured clean shutdown (`All buffers synced` followed by system power-off);
- a verdict/report containing an fd `leak` claim fails without an explicit fd-identity ledger;
  count-only growth remains an observation; and
- one PID never becomes a scheduler/product verdict; return bounded observations only after the
  complete window/structure bar.

Add negative tests for every item, including malformed numeric fields, wrong digest/host stream,
missing shutdown, duplicate verdict, duplicate DONE, and fd-leak-without-identities. The exact raw
serials must still return Cell A `PARTIAL-CONTROL` and Cell B `HARNESS-NOT-ACCEPTED`.

## C. EXACT FROZEN COMMAND RECORD

Under `build/op298/`, preserve exact command, stdout, stderr, and numeric rc files for:

1. digest-aware real-log validation;
2. all new negative/positive tests;
3. the combined op-286/op-293/op-297/op-298 targeted suite;
4. full `mix test` at base and result; and
5. authored-path `git diff --check` plus raw identity comparison.

Full-suite pre-existing failures do not automatically block this bounded op, but the base and
result failure sets/counts must match and be reported as **failures**, distinct from excluded tags.
Any new failure blocks.

Finalize all ordinary record/output files before generating the manifest. Generate the two-path
detached manifest attestation last, then commit by explicit paths. Raw CRLF/trailing whitespace is
verified by hashes and never normalized.

## VERDICT / COMMIT

Create one additive commit; do not push. Return exactly one:

- `RECORD-GATE-CLOSED <commit>` — exact manifest set equality passes, digest/structure/shutdown/
  counter/fd gates and tests pass, frozen commands are truthful, base/result full-suite failure
  sets match, and guest_cells=0; or
- `BLOCKED <reason>`.

Report commit/parent, exact paths, manifest/attestation identity, checker output/rc, raw identity
comparison, every test command/result/rc, full final status/origin relationship, and zero cells.

## BOUNDARIES

- Record mechanics only. No guest/product/config/mechanism/soak/attempt work or new factual
  interpretation.
- id-040 remains Coordinator-held; do not choose or implement a production mode.
- No push without separate Coordinator authorization.

## MARKERS

`GK_OP298_BASE_IDENTITY`

`GK_OP298_MANIFEST_SET_EQUALITY`

`GK_OP298_DIGEST_IDENTITY`

`GK_OP298_VALIDATOR_NEGATIVES`

`GK_OP298_REAL_LOG_RESULTS`

`GK_OP298_FULL_SUITE_BASELINE`

`GK_OP298_COMMIT`

`GK_OP298_TERMINAL`

## RELATIONS

op-293 / op-296 / op-297 / id-011 / id-040 / li-1004.

feedback: `artifact_identity_needs_content_check`, `code_reasoned_verdict_is_hypothesis`,
`harness_authoring_is_gatekeeper`, `agent_host_isolation`, `background_exit_code_hygiene`,
`no_conflate_gating_with_readiness`, `op_state_dispatch_boundary`.
