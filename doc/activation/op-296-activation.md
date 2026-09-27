---
id: op-296
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-296 — Gatekeeper: repair and freeze the op-293 evidence record host-only

op-296 | role: **Gatekeeper Ruler** (evidence owner; no product write) | EXU:
**rmx-gatekeeper-rx-x64z** | state: **[Done — returned Gatekeeper commit `a66e3b7`;
Arranger2 M-gate accepts the six raw identities/correction but rejects RECORD-REMEDIATED as
incomplete: manifest self-entry was removed by op-297, but its scope/digest/shutdown/counter/fd
gate remained false-green through op-301; op-301 failed Stage A and op-302 was flushed, so the
bounded repair chain is stopped]** | parent: **op-293 / id-011** | L1i: **li-1004** | authored:
**2026-07-11 by Arranger2**

## ARRANGER ADJUDICATION — 2026-07-11

**Verdict: PARTIAL-REMEDIATION / RECORD-GATE-NOT-ACCEPTED.** op-296 remains `[Done]`; it is not
retired. Fresh completion is op-297.

First-hand accepted:

- Gatekeeper `main@a66e3b7068e86eae71d7f6be46267be1246ec281`, parent
  `dd8600170f5a9118ce6a50958a20afe36adbbdc5`, is 33 ahead of
  `origin/main@4b16fd1b65e76cfcdb40de96069e13d3d702e3cf`; unrelated untracked artifacts remain.
- The commit changes only 11 explicit op-286/op-293/validator paths and adds no image.
- All six pinned raw sizes/hashes match exactly and are committed. The correction and ledgers
  accurately record Cell A `PARTIAL-CONTROL`, Cell B `HARNESS-NOT-ACCEPTED`, the host/serial
  reversal, and withdrawal of scheduler/fd-leak claims.
- Product source at accepted `0ccd5621` confirms `aslmanager.c:1590-1605` enters the managed XPC
  listener/`dispatch_main` branch and `launchd/core.c:8401-8403` reports named jobs managed.
- Arranger reproduced the targeted op-286+op-293 command: 24 tests pass. Direct real-log calls
  return Cell A `{:partial_control, ...}` and Cell B
  `{:harness_not_accepted, :missing_terminal_marker}`. Guest cells remain 0.

Gate failures:

1. `op293-sha256-manifest.txt` lists itself as 1,136 bytes / SHA `433d5847...`, but the committed
   file is 1,671 bytes / SHA
   `d88efeb86bd7e53489bce999a350ac48a3e9bf49b33f4b2831928d422d15adc1`. The other 14 entries
   reproduce. A manifest cannot recursively authenticate its own final bytes; the self-row must
   be removed and the manifest identity reported from its Git blob/commit.
2. The committed op-293 test file is unchanged and has 14 tests; the reported 24 is the combined
   10 op-286 + 14 legacy op-293 suite. No committed test exercises either new real-log function.
3. `validate_cell_b_serial/1` computes `has_verdict` and `has_final` but never enforces them. It
   does not check clean shutdown, duplicate/order constraints, digest identity, or fd-leak claim
   provenance. Arranger supplied a synthetic log with tick 0/1800, one PID, terminal and DONE but
   no final inventory/verdict/clean shutdown; the validator returned `{:observed, ...}` rather than
   failing closed.
4. No exact real-log validation command/output/exit record is frozen under `build/op293/`.
5. A literal whole-commit `git diff --check` flags preserved raw console whitespace/CRLF. That is
   not a reason to alter byte-exact logs; op-297 separates raw hash verification from
   `diff --check` on authored text/source paths.

The additive correction remains useful and must not be rewritten. op-297 completes only the
manifest/validator/test/run-record gap. id-040 stays WAITING; this evidence repair does not choose
the production mechanism or release another guest run.

## DISPATCH BOUNDARY

DISPATCHED by the Coordinator to `rmx-gatekeeper-rx-x64z` only on 2026-07-11. All writes land in
`/Users/me/wip-mach/rmx-gatekeeper/`. Product, Arranger, Explorer, and Oracle repositories are
read-only. This op authorizes **zero guest cells**: do not boot, clone, mutate, resume, or rerun an
image. It corrects and freezes the already-consumed op-286/op-293 evidence record.

## REQUIRED REPOSITORY IDENTITY

Before writing, verify:

- branch/HEAD: `main@dd8600170f5a9118ce6a50958a20afe36adbbdc5`;
- `origin/main`: `4b16fd1b65e76cfcdb40de96069e13d3d702e3cf`;
- local branch is 32 commits ahead;
- commits `b3aeb7c`, `1b1c3e6`, and `dd86001` exist in that order;
- full `git status --short --branch` is captured, including all unrelated untracked artifacts.

Preserve every existing commit verbatim. Do not amend, rebase, reset, discard, or clean. If HEAD,
any named raw artifact, or its hash differs, stop with `BLOCKED identity-drift`.

## PINNED RAW IDENTITIES

Reproduce before staging:

### op-293

- Cell A serial: `build/op293/op293-cellA-serial.log`, 11,798 bytes,
  SHA-256 `8aaa5f197a1c8a0aba87d949a1e69f36f81aa7a4e92955b1477bafead175d9f8`;
- Cell A host: `build/op293/op293-cellA-host.log`, 14,761 bytes,
  SHA-256 `4c026249caffe67fa4e06aafbcdbb94b7d53e68c10685b1e91c835b1f0d117da`;
- Cell B serial: `build/op293/op293-cellB-serial.log`, 35,315 bytes,
  SHA-256 `6584f2d11a8761c47d7d8d0efe531a7006c77504ae051cc61ef16699846d382c`;
- Cell B host: `build/op293/op293-cellB-host.log`, 38,278 bytes,
  SHA-256 `53af92aef67b7926cd76a8263842639afcf45ad750d732ca0f03f0dba18ff321`.

### op-286 record referenced by the existing manifest

- host: `build/op286/op286-a1-host.log`, 855,731 bytes,
  SHA-256 `b97f157c62231fb5cb76b8f8c77bbe0f80711810eb6429cf509563e4af47281a`;
- serial: `build/op286/op286-a1-serial.log`, 852,768 bytes,
  SHA-256 `2aa919a10bbae79091f2f5ad2c7147c0465ff0fcfeebc8a6eeb310e4c5aa10f9`.

The op-293 report reversed host and serial identities for both cells. Never relabel or regenerate
these files.

## REQUIRED ADDITIVE CORRECTION

Create `build/op293/op293-arranger-correction.md` that clearly separates:

### Observed facts retained

- Cell A: direct PID 993/PPID 15 exited 0; two TTL-eligible July-3 files were deleted; store
  56→48 KiB.
- Cell B: exactly one observed launchd child PID 916/PPID 867 remained state `S` through tick
  1710; no second PID appeared through the first interval boundary.
- asld fd count changed 37→91 over the observed 1710 seconds, with no fd-identity census.

### Corrected disposition

- Cell A is `PARTIAL-CONTROL`: it proves TTL deletion but the store never exceeded the commissioned
  500-KiB size threshold.
- Cell B is `HARNESS-NOT-ACCEPTED truncated-before-two-windows/terminal`: it stops at tick 1710,
  before the second complete 900-second window, and has no final inventory, panic check, verdict,
  terminal marker, or clean shutdown.
- Both cells remain consumed (2/2); this op runs no retry.
- The “+40 fd/hour leak” claim is withdrawn. The endpoint count slope is approximately +114/hour,
  but without fd identities it remains an observation, not a proven leak.

### Corrected source interpretation

Verify and cite the current product source read-only:

- `usr.sbin/aslmanager/aslmanager.c:1590-1605`: managed jobs intentionally create the XPC listener
  and enter `dispatch_main`; only unmanaged jobs run `cli_main`;
- `sbin/launchd/core.c:8401-8403`: non-anonymous launchd jobs report managed=1;
- op-257's plist combines a named managed job with CLI arguments and interval keys;
- donor/Ravyn `com.apple.aslmanager.plist` uses MachServices and no interval.

State that the persistent process is the expected managed-XPC-server branch. It is not a library
constructor mystery and does not establish a StartInterval implementation defect. Explicitly
reject `exit()` after `main`, which would break the intended server mode. The production mechanism
decision is id-040 and is outside this evidence-repair op.

## VALIDATOR REMEDIATION

Extend the Gatekeeper-owned op-293 validator/tests so they consume the actual raw log schema and
fail closed on at least:

- host digest presented as serial;
- store below the commissioned Cell-A threshold;
- fewer than two complete 900-second windows;
- missing final inventory, verdict, terminal marker, or clean shutdown;
- duplicate/out-of-order verdict or terminal markers;
- a single PID classified without a complete observation window;
- fd-count growth presented as a leak without an fd-identity ledger.

Run the remediated validator on both real serial logs. It must return Cell A `PARTIAL-CONTROL` and
Cell B `HARNESS-NOT-ACCEPTED`; a synthetic-only test run is insufficient. Preserve the exact
commands, output, and exit statuses under `build/op293/`.

## FREEZE / MANIFEST / COMMIT

1. Add the six pinned raw host/serial logs by explicit path. Do not add either `.img`, any core,
   or unrelated untracked work.
2. Derive Cell-A and Cell-B marker/sample ledgers from the serial logs, including first/last tick,
   distinct PIDs, process states, store series, fd series, and presence/absence counts for every
   required final marker.
3. Create an op-293 SHA-256 manifest covering every committed raw/derived non-image artifact,
   validator/test source, correction, and frozen rc scripts.
4. Verify the existing op-286 manifest against the now-staged raw logs; update only by an additive
   correction if an identity/reference defect is found.
5. Run `git diff --check`, full status, and the complete Gatekeeper test target relevant to the
   validator.
6. Create one additive commit using only explicit op-286/op-293 evidence/validator paths. Do not
   push.

## DELIVERABLE / VERDICT

Return exactly one:

- `RECORD-REMEDIATED <commit>` — all six raw logs and derived correction/ledgers/manifests are
  committed, real-log validation fails closed with the required dispositions, and unrelated work
  is untouched;
- `BLOCKED <reason>` — identity drift, missing/corrupt raw evidence, validator failure, or required
  work outside scope.

Report the result commit/parent, exact committed paths, recomputed hashes, validator command/output,
full final status/origin relationship, and confirm `guest_cells=0`.

## BOUNDARIES

- Evidence preservation/correction only. No guest, image mutation, source build, product/config
  edit, scheduling fix, new soak, or attempt relabel.
- Preserve `b3aeb7c`, `1b1c3e6`, and `dd86001` verbatim; the correction is additive.
- Never commit `.img`, `aslmanager.core`, or unrelated evidence.
- Do not claim helper size-threshold acceptance, scheduler failure, fd leak, ASL leg-4 green, or a
  product root cause beyond the cited mode-selection source.
- Do not push without separate Coordinator authorization.

## MARKERS

`GK_OP296_BASE_IDENTITY`

`GK_OP296_RAW_IDENTITIES`

`GK_OP296_REAL_LOG_VALIDATION`

`GK_OP296_CORRECTION`

`GK_OP296_MANIFEST`

`GK_OP296_COMMIT`

`GK_OP296_TERMINAL`

## RELATIONS

op-286 / op-293 / id-011 / id-040 / li-1004.

feedback: `artifact_identity_needs_content_check`, `code_reasoned_verdict_is_hypothesis`,
`harness_authoring_is_gatekeeper`, `agent_host_isolation`,
`background_exit_code_hygiene`, `no_conflate_gating_with_readiness`,
`op_state_dispatch_boundary`.
