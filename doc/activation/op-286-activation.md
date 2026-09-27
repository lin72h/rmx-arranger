---
id: op-286
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-286 — Gatekeeper: premise-gated ASL leg-4 reclaim and durability re-soak

op-286 | role: **Gatekeeper Ruler** (soak/evidence owner; no product write) | EXU: **rmx-gatekeeper-rx-x64z** | state: **[Done — Gatekeeper returned Attempt 1; Arranger M-gate reclassifies it HARNESS-NOT-ACCEPTED; 1/2 consumed, Attempt 2 not released; raw-evidence/origin blockers remain; fresh diagnostic is op-293]** | parent: **id-011** (libasl/asld) | L1i: **li-1004** (ASL) | authored: **2026-07-10; normalized/adjudicated 2026-07-11 by Arranger2**

## DISPATCH BOUNDARY

DISPATCHED to `rmx-gatekeeper-rx-x64z` only. Work and durable evidence land only in
`/Users/me/wip-mach/rmx-gatekeeper/`. Product and Explorer repositories are read-only. This
activation authorizes at most **2 guest attempts**: Attempt 1 is the reclaim premise check; Attempt
2 is the full soak and is released only by an accepted Attempt-1 premise.

## OBJECTIVE

Close the ASL leg-4 evidence gap left by op-258 without papering over its invalid harness:

1. first prove that the op-257 image can automatically invoke a real aslmanager reclaim after the
   store crosses its forced 500K threshold; then
2. only if that premise holds, run the corrected four-hour durability soak and establish bounded
   store behavior, repeatable reclaim, record conservation, ENOSPC behavior, settled read-after-write,
   daemon survival, fd stability, and Mach-IPC balance.

If the automatic reclaim premise does not hold, stop after Attempt 1 and return the smallest
falsifiable wiring/configuration requirement. Do not spend the four-hour attempt on a mechanism
already shown dark.

## INPUT IDENTITY

Read-only source image:

`/Users/me/wip-mach/wip-gpt/build/op257-aslmanager-soak/op257-aslmanager-soak.img`

- size: `17179869184` bytes
- SHA-256: `3f6d73dffae04f146cc6533f79a659829b0cf24002e15d5321f3ab7be613e040`
- expected in-image asld SHA-256: `0c2fe9d20840f2a2295e594e43f03abda33d75b620b5b1ce2ab9bd39432fa76c`
- expected in-image aslmanager SHA-256:
  `301bfb1dcb2b8ed65dbaf2ba2b308395735acdf219c8efb10941f3727d011d4b`
- test-image config: aslmanager plist loaded/started through rc.local, `StartInterval=900`,
  `-size 500K`, and `max_store_size=500000`.

Hash the source image before staging. Boot only a Gatekeeper-owned copy/clone under
`build/op286/`; never mutate the product-owned source image. Host evidence must record the source
hash, working-copy hash before first boot, exact bhyve command, and in-guest component hashes.

## PRIOR FAILURE — MUST NOT RECUR

Read first-hand:

- `/Users/me/wip-mach/rmx-gatekeeper/build/op258/rc.local`
- `build/op258/op258-soak-serial.log`
- `build/op258/op258-soak-host.log`

op-258 survival data is usable, but its leg-4 verdict is not:

1. the reclaim DTrace observer failed to compile because `syscall::unlink*:entry` matched no probe;
2. verdict grep counted the word `unlink` in that compiler diagnostic as one reclaim;
3. plateau logic read `/tmp/op258-host.log`, which the heartbeat never wrote; and
4. a nonnumeric panic-count shell value produced `0: bad number` and fell into the verdict path.

The observed series was monotonic (`store_kb=700` near start to `10752` at 14,340 seconds) with
`asld_fd=37`; no real reclaim or plateau was established. An unsanctioned/background run is context
only and cannot satisfy any bar in this activation.

## REPOSITORY PREFLIGHT

1. Record full `git status --short --branch`, branch, HEAD, and origin relation for
   `/Users/me/wip-mach/rmx-gatekeeper/` before work. Existing unrelated untracked evidence belongs
   to prior work; preserve it and never stage broadly.
2. `build/op286/` was absent at activation authoring. If it already exists at dispatch, stop and
   inventory it before writing; do not mix attempts or overwrite evidence.
3. Put every op-286 artifact under `build/op286/`. Stage/commit later by explicit paths only; never
   use `git add -A` or absorb unrelated dirty files.
4. Reconcile this activation against the canonical Arranger file
   `/Users/me/wip-mach/rmx-arranger/doc/activation/op-286-activation.md` before guest spend. A
   conflicting committed/local record is a stale-stop, not permission to improvise.

## PHASE 0 — HOST-ONLY FAIL-CLOSED PREFLIGHT (0/2 ATTEMPTS)

Before booting a guest:

1. Implement substantive marker/order/count/verdict logic in **Zig or Elixir**. Shell may only
   orchestrate existing commands, file routing, staging, and guest invocation.
2. The wrapper must expose and pass host-only build/stage/command-generation preflight using the
   exact paths, timeout, stdin, rc-capture, and generated command file used by activation.
3. Emit, validate, and hash the generated guest command file before activation.
4. Run synthetic controls proving the validator rejects at least: observer compile failure; a fake
   diagnostic containing `unlink`; zero real reclaims; monotonic store growth; missing/dead
   heartbeat input; nonnumeric counters; absent terminal marker; out-of-order markers; unexplained
   record loss; and a settled read miss. Also prove one valid synthetic trace is accepted.
5. Enumerate the actual guest probe surface before choosing DTrace/FBT. Compile-preflight the exact
   observer. A sampled store-size/file-count drop is required even if a tracing marker is used.

Failure here is `SCAFFOLD-FAIL`, consumes 0/2 attempts, and stops for correction. Do not boot.

## ATTEMPT 1 — RECLAIM PREMISE CHECK (1/2)

Use a fresh Gatekeeper-owned image clone and a short deterministic sequence:

1. Prove artifact identity and that launchd has the expected aslmanager job/config loaded.
2. Establish an observer positive control against an eligible sacrificial store file: the observer
   must capture a real aslmanager process/reclaim event and a corresponding store byte/file-count
   drop. Log text or a substring alone is never an event.
3. Reset to a clean measured store. Without manual reclaim, flood sequence-numbered records past
   500K and observe at least two configured StartInterval windows.
4. Capture aslmanager invocation identity, before/after store bytes and file count, affected file
   names, asld PID/fd/RSS, and serial/host terminal state.

Attempt-1 disposition:

- `PREMISE-ACCEPTED` — observer positive control works and the launchd-driven run produces a real
  reclaim plus store drop. This alone releases Attempt 2.
- `HARNESS-NOT-ACCEPTED` — observer/control/validator fails. Stop; do not infer a product defect.
- `RECLAIM-PREMISE-NOT-ACCEPTED` — observer control works, threshold and schedule were reached, but
  automatic reclaim did not occur. Stop and distinguish job-not-invoked, helper-invoked-no-delete,
  eligibility/configuration, or other smallest falsifiable requirement.

Any candidate runtime marker consumes Attempt 1. Preserve and hash raw evidence before analysis.
No retry is authorized.

## ATTEMPT 2 — FULL LEG-4 SOAK (2/2; GATED ON PREMISE-ACCEPTED)

Start from another fresh clone of the source image. Run `SOAK_DURATION=14400` with 60-second or
finer sampling. Before activation, freeze in the run manifest the store ceiling, quiescent-fd
tolerance, exact reclaim event definition, record ledger equation, timeouts, and all terminal
markers; do not tune them after seeing results.

Required evidence/bar:

1. **Repeatable bounded reclaim.** Minimum validity is one real reclaim; PASS additionally requires
   a complete repeated sawtooth: grow → real drop → regrow → second real drop. Each reclaim must
   have process/event identity plus sampled store byte/file-count decrease. Zero or one-only cycle
   is not a plateau PASS.
2. **Per-tick series.** Record store bytes and file count (primary), asld fd count, RSS, PID/alive,
   aslmanager invocation/reclaim count, and the existing Mach-port/kmsg/mqueue balance invariants.
   Do not demand send/receive equality where ASL has legitimate asymmetry.
3. **FD and durability.** asld remains alive without PID change, panic, hang, or degraded terminal;
   fd count returns within the predeclared quiescent tolerance and has no positive leak slope.
4. **Record conservation.** Use sequence IDs and account for policy deletion explicitly:
   `sent = retained + explicitly-reclaimed + explicit-send-failures`. Capture the IDs represented
   by a file before reclaim deletes it. Sets must be disjoint; any unexplained gap or duplicate is
   a fail. Bucket gaps against same-second roll replacement and unlink-while-open windows, but do
   not convert correlation into a root-cause claim.
5. **ENOSPC.** Fill only a bounded store filesystem while preserving `/` headroom. asld must
   survive. Capture send/write results and inspect the day-file chain for a torn record or quiet
   forward truncation around `asl_file.c:1133-1134`. Never repeat op-198's root-filesystem OOM.
6. **Settled read-after-write.** Record retry/latency distribution. A record whose save completed
   but a fresh store open still misses after the frozen settle window is a fail.
7. **Fail-closed terminal.** Exact marker counts, strict order, one terminal verdict, command rc,
   timeout state, and clean guest shutdown are mandatory. Missing/duplicate/out-of-order terminal
   evidence is harness-invalid, never PASS.

Any failure consumes Attempt 2. Stop, preserve evidence, and report the smallest falsifiable
requirement; no rerun or mechanical correction is authorized by this brief.

## VERDICT

- `LEG4-ACCEPTED` — Attempt 1 premise accepted and every Attempt-2 bar above passed.
- `LEG4-NOT-ACCEPTED <bar>` — runtime evidence valid but one or more named bars failed.
- `HARNESS-NOT-ACCEPTED <reason>` — evidence cannot support the runtime claim.
- `RECLAIM-PREMISE-NOT-ACCEPTED <reason>` — Attempt 1 disproved automatic reclaim; Attempt 2 not
  spent.

Gatekeeper recommends disposition; only the Arranger adjudicates and retires id-011 state.

## DELIVERABLE

Under `/Users/me/wip-mach/rmx-gatekeeper/build/op286/`, preserve at minimum:

- run manifest and activation/source pins;
- Zig/Elixir validator plus its synthetic-control results;
- thin wrapper and hashed generated guest command file;
- image/component identity ledger;
- Attempt-1 host log, raw serial, samples, and disposition;
- if released, Attempt-2 host log, raw serial, full sample series, record-conservation ledger,
  ENOSPC evidence, and verdict;
- SHA-256 manifest covering every raw and derived evidence file; and
- `op286-verdict.md` separating observed fact, inference, and unverified explanation.

Freeze raw digests before curation. Commit only the run manifest, harness/validator, non-image raw
logs, ledgers, digest manifest, and verdict by explicit paths. Do not commit the 16GiB working image,
cores, or unrelated prior evidence. Do not push without separate Coordinator authorization.

End the return with Gatekeeper's structured block:

```text
REPORT
block:        op-286
agent:        rmx-gatekeeper-rx-x64z
outcome:      accepted | not-accepted | consumed
commits:      <gatekeeper commit sha + subject>
attempts:     consumed N/2 + each serial SHA-256 + pass/fail
disposition:  <verdict + basis + record/evidence pin>
next-hop:     <smallest next step or falsifiable requirement>
```

## BOUNDARIES

- No product-source, product-build, Explorer, Arranger, governing-doc, or milestone-state write.
- Do not allocate or author a follow-on op. If evidence warrants a product change, report only the
  smallest source/configuration requirement for Arranger routing.
- Legacy notes call the unchecked-write follow-on “RESERVED op-266,” but no op-266 activation
  artifact exists and that old number must not be created or reused. A warranted follow-on receives
  the then-current next free project op from the Arranger.
- No result from an unsanctioned/background run counts toward this activation.
- Building/cross-building missing binaries is Implementer work. Stop and request the exact artifact.
- This soak does not decide preview scope or release timing.

## MARKERS

`GK_OP286_SOURCE_IDENTITY`

`GK_OP286_HOST_PREFLIGHT`

`GK_OP286_ATTEMPT1_PREMISE`

`GK_OP286_ATTEMPT2_SOAK`

`GK_OP286_RECORD_CONSERVATION`

`GK_OP286_ENOSPC`

`GK_OP286_TERMINAL`

## RELATIONS

op-258 (harness-invalid predecessor) / op-257 (consumed image) / op-260 (store-path hypotheses) /
op-163 (original leg-4 flag) / op-198 (root-fill OOM lesson) / op-133 (soak lineage) / id-011 /
li-1004.

feedback: `oss_engineering_framing`, `soak_is_gatekeeper`, `harness_authoring_is_gatekeeper`,
`build_is_implementer`, `dtrace_first_debugging`, `artifact_identity_needs_content_check`,
`background_exit_code_hygiene`, `no_conflate_gating_with_readiness`,
`verify_signature_divergence_claims`, `agent_host_isolation`, `op_state_dispatch_boundary`.

## ARRANGER ADJUDICATION — 2026-07-11

Gate size: **M**, gated directly first-hand by Arranger2. The Gatekeeper return boundary is
accepted, but its `RECLAIM-PREMISE-NOT-ACCEPTED / job-not-invoked-periodically` disposition is
**not accepted**. Canonical disposition: **`HARNESS-NOT-ACCEPTED`**.

Verified facts:

- Gatekeeper `main@c69b1f28749d24ad519f2056e7e3ffe1192d4c95` is 29 commits ahead of
  `origin/main`; `git show --check c69b1f2` is clean.
- both raw logs contain 35 heartbeats; store size grows monotonically from 40 to 2572 KiB,
  store-file count remains 4, asld fd count remains 37, and asld is alive at every tick;
- the returned Elixir validator reproduces `reclaim_count=0` and
  `verdict={:fail, :zero_reclaims}`;
- `aslmanager_running=yes` is only a sampled `pgrep -x` Boolean. No PID/start/exec/exit/status,
  process state, invocation count, or reclaim-event identity was recorded; therefore the evidence
  cannot distinguish one stuck process, a zombie, repeated invocations, or helper-invoked-no-delete;
- the required observer positive control and sacrificial-file/store-drop control are absent from
  the run script and raw evidence. This fails the prerequisite for
  `RECLAIM-PREMISE-NOT-ACCEPTED` and forbids a launchd lifecycle conclusion;
- the validator's ten tests do not implement the commissioned full control set: the terminal
  verdict is optional, and record-conservation, settled-read, missing/dead-heartbeat, and observer
  positive-control gates are absent or incomplete;
- the report labels `b97f157c...` as the serial digest, but that is the host-log SHA-256. The
  actual serial SHA-256 is
  `2aa919a10bbae79091f2f5ad2c7147c0465ff0fcfeebc8a6eeb310e4c5aa10f9`;
- commit `c69b1f2` contains the disposition, rc script, validator, and tests only. The host/serial
  logs remain untracked and no digest manifest was delivered.

Attempt 1 is nevertheless **consumed** because candidate runtime markers were produced. The brief
authorizes no retry or relabel; Attempt 2 remains closed because no accepted premise exists.
Secondary survival/fd observations are usable only as narrow context. The claimed equivalence to
the StartCalendarInterval failure and the proposed launchd root cause remain unverified.

op-293 is the fresh evidence slot. It first preserves/corrects the op-286 raw record, then runs a
positive-control cell and a separately instrumented launchd-scheduler cell. A direct rc.local
invocation is a helper/observer control, not a substitute for proving the production scheduling
premise or for the still-open four-hour leg-4 gate.
