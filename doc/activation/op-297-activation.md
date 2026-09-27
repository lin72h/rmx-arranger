---
id: op-297
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-297 — Gatekeeper: finish op-296 manifest and real-log validator fail-closed coverage host-only

op-297 | role: **Gatekeeper Ruler** (evidence/validator owner; no product write) | EXU:
**rmx-gatekeeper-rx-x64z** | state: **[Done — returned Gatekeeper commit `be5dbdc`; Arranger2
M-gate rejects RECORD-GATE-CLOSED: listed-row hashes and targeted tests pass, but scope-completeness,
digest/shutdown/counter/fd gates, shell checker, and frozen full-suite record remain defective;
op-298/op-299/op-301 returned further partials; op-301 failed Stage A and op-302 was flushed,
stopping the chain]** | parent: **op-296 / op-293 / id-011** | L1i:
**li-1004** | authored: **2026-07-11 by Arranger2**

## ARRANGER ADJUDICATION — 2026-07-11

**Verdict: PARTIAL-COMPLETION / RECORD-GATE-NOT-ACCEPTED.** op-297 remains `[Done]`; op-298,
op-299, and op-301 also returned partial, and op-302 was flushed under the fail-stop rule.

Accepted first-hand:

- Gatekeeper `main@be5dbdc319fd7d904958164464e8578994321872`, parent `a66e3b7`, is 34
  ahead of `origin/main@4b16fd1`; six raw logs/correction are byte-identical and no guest/image
  work occurred.
- The manifest self-row is removed. Its 16 listed rows reproduce with the Elixir checker; current
  identity is 2,027 bytes / SHA
  `dc2f333bb3c905ee835633467c577f7445f6496f9c88ff8643a22743ed74cf9c`, Git blob
  `ac4045901ae5951c5a6c5f10ac085aeedf8a4fbf`.
- Ordered tail, duplicate-marker, required-marker, and truncated-window checks fix the specific
  op-296 terminal+DONE false positive. Real logs return Cell A `PARTIAL-CONTROL` and Cell B
  `HARNESS-NOT-ACCEPTED`. Arranger reproduces 39/39 targeted tests.

Rejected first-hand:

1. Neither checker detects unlisted in-scope paths. The manifest omits nine required artifacts
   besides its deliberate self exclusion: five op-286 record files, both op-286 validator/test
   files, and the new op-297 shell checker/validation record.
2. `build/op297/manifest_check.sh` is broken: `read ... PATH` overwrites the executable search
   path, so the committed checker reports `wc/tr/awk: not found` and fails all 16 rows.
3. The validator still accepts the Cell-A **host** log as serial because no entry point consumes/
   checks the pinned digest. It accepts a structurally present tail with malformed final/panic
   counters, an `fd_leak_proven` verdict, no fd identities, and no shutdown as `{:observed, ...}`.
   The committed positive fixture likewise has no shutdown evidence.
4. Required digest, clean-shutdown, malformed-counter, fd-identity-claim, duplicate-verdict/DONE,
   and related negative cases are absent. The new file contains 15 tests, not the reported 13.
5. The frozen record summarizes rather than preserving exact stdout/stderr/rc. It also reports
   full `mix test` as “236/240 passed, 4 excluded”; Arranger reproduces four actual failing tests
   in addition to excluded tags. Those failures may be pre-existing, but must be baseline-compared
   and labeled honestly.

No ASL/product inference changes. id-040 remains WAITING and no guest cell is released.

## DISPATCH BOUNDARY

DISPATCHED by the Coordinator to `rmx-gatekeeper-rx-x64z` on 2026-07-11. All writes land in
`/Users/me/wip-mach/rmx-gatekeeper/`. Product, Arranger, Explorer, and Oracle trees are read-only.
This op authorizes **zero guest cells**: no boot, clone, image mutation, rerun, or new runtime
claim. It preserves op-296's accepted raw evidence/correction and fixes only the rejected
manifest/validator/test/run-record mechanics.

## REQUIRED BASE

- branch/HEAD: `main@a66e3b7068e86eae71d7f6be46267be1246ec281`;
- parent: `dd8600170f5a9118ce6a50958a20afe36adbbdc5`;
- `origin/main@4b16fd1b65e76cfcdb40de96069e13d3d702e3cf`, local ahead 33;
- preserve all unrelated untracked artifacts and every prior commit;
- full `git status --short --branch` before and after.

Stop `BLOCKED identity-drift` if HEAD or any of the six pinned raw identities differs. Do not
amend/rebase/reset/clean, and do not modify the six raw logs, either `.img`, the accepted
`op293-arranger-correction.md`, or historical `op293-verdict.md`.

## FIRST-HAND REJECTION TO CLOSE

Arranger2 reproduced:

1. all six raw identities and the correction/ledgers are sound;
2. the manifest's other 14 rows match, but its self-row claims 1,136 bytes / `433d5847...` while
   the committed manifest is 1,671 bytes / SHA
   `d88efeb86bd7e53489bce999a350ac48a3e9bf49b33f4b2831928d422d15adc1`, Git blob
   `342c38f52415e37b20503cb31d73437e208edf69`;
3. the 24 passing tests are 10 op-286 + 14 unchanged legacy op-293 tests; neither new real-log
   function has a committed test;
4. `validate_cell_b_serial/1` leaves verdict/final values unused and omits clean-shutdown,
   duplicate/order, digest, and fd-claim gates; and
5. a synthetic record with ticks 0/1800, one PID, terminal and DONE but no final inventory,
   verdict, or clean shutdown incorrectly returns `{:observed, ...}`.

## A. MANIFEST REPAIR

1. Remove the impossible self-hash row from `build/op293/op293-sha256-manifest.txt`. Add a comment
   that the manifest deliberately excludes itself; its integrity comes from the result commit/Git
   blob and the returned external SHA/size.
2. Cover every other committed op-286/op-293 raw/derived artifact, frozen rc script,
   correction/current-disposition pointer, validator source, tests, and any op-297 verification
   script/report. Every listed size/hash must reproduce.
3. Add a deterministic manifest-check command/script that rejects missing files, size mismatch,
   digest mismatch, duplicate paths, and unlisted in-scope committed artifacts. It must not attempt
   recursive self-authentication.
4. Return the final manifest size, SHA-256, Git blob, row count, and checker output/rc.

Raw `.log` bytes contain captured CRLF/trailing whitespace and must remain byte-identical. Run
`git diff --check` on authored source/Markdown/ledger/script paths while verifying raw logs by
size/hash. Do not normalize evidence to satisfy a whitespace tool.

## B. VALIDATOR COMPLETION

Extend the Gatekeeper-owned validator and tests so a real-log validation entry point consumes the
raw bytes plus the pinned expected serial digest/identity and fails closed on every commissioned
case:

- host bytes/digest presented as serial;
- Cell A store below the 500-KiB threshold;
- fewer than two complete 900-second Cell-B windows;
- missing final inventory, panic check, verdict, terminal, DONE, or clean-shutdown evidence;
- duplicate or out-of-order verdict/terminal/DONE markers;
- no invocation identity or a single-PID conclusion before the complete window;
- malformed/nonnumeric required counters; and
- any fd `leak` conclusion without an fd-identity ledger. Count growth alone remains observation.

For a structurally complete Cell-B fixture require exactly one ordered
`STORE_FINAL → PANIC_CHECK → VERDICT → TERMINAL → DONE` tail and explicit clean shutdown after
DONE. Do not infer a scheduler/product verdict merely from one PID; return bounded observations.

Add committed negative tests for every bullet plus positive fixtures. Tests must call the new
real-log functions, not only the legacy synthetic API. The exact current raw logs must still return:

- Cell A: `PARTIAL-CONTROL` with before 56 / after 48 / below-threshold reason;
- Cell B: `HARNESS-NOT-ACCEPTED` with the earliest applicable missing/truncated reason.

## C. FROZEN HOST-ONLY VALIDATION RECORD

Under `build/op297/`, preserve the exact commands, stdout/stderr, and exit statuses for:

1. manifest verification;
2. real Cell-A and Cell-B validation with pinned digests;
3. every required negative fixture class;
4. targeted op-286/op-293 tests; and
5. the complete Gatekeeper `mix test` suite.

The record must state `guest_cells=0`, identify `a66e3b7` as its base, and distinguish accepted
op-296 content from the op-297 mechanical completion.

## COMMIT / VERDICT

Create one additive commit by explicit paths only; do not push. Return exactly one:

- `RECORD-GATE-CLOSED <commit>` — manifest is internally reproducible without a self-row, every
  required validator negative is implemented/tested, real logs return the bounded dispositions,
  and the frozen host-only run record is committed; or
- `BLOCKED <reason>`.

Report result commit/parent, exact paths, manifest identity/check result, test commands/results,
real-log results, complete final status/origin relationship, and `guest_cells=0`.

## BOUNDARIES

- No guest, image, product/config, scheduling mechanism, new soak, attempt relabel, or evidence
  reinterpretation.
- Do not rewrite accepted raw logs/correction or claim size-threshold, scheduler, fd-leak, ASL
  leg-4, or production-mechanism closure.
- id-040 remains Coordinator-held. This op closes record mechanics only.
- No push without separate Coordinator authorization.

## MARKERS

`GK_OP297_BASE_IDENTITY`

`GK_OP297_MANIFEST_CHECK`

`GK_OP297_VALIDATOR_NEGATIVES`

`GK_OP297_REAL_LOG_RESULTS`

`GK_OP297_TESTS`

`GK_OP297_COMMIT`

`GK_OP297_TERMINAL`

## RELATIONS

op-293 / op-296 / id-011 / id-040 / li-1004.

feedback: `artifact_identity_needs_content_check`, `code_reasoned_verdict_is_hypothesis`,
`harness_authoring_is_gatekeeper`, `agent_host_isolation`, `background_exit_code_hygiene`,
`no_conflate_gating_with_readiness`, `op_state_dispatch_boundary`.
