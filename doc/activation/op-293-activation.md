---
id: op-293
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-293 — Gatekeeper: repair op-286 evidence and discriminate aslmanager scheduling from helper reclaim

op-293 | role: **Gatekeeper Ruler** (runtime/evidence owner; no product write) | EXU:
**rmx-gatekeeper-rx-x64z** | state: **[Done — returned at Gatekeeper `dd86001`; Arranger2 M-gate
reclassifies Cell A PARTIAL-CONTROL and Cell B HARNESS-NOT-ACCEPTED; 2/2 cells consumed, no retry;
op-296 committed the raw correction; op-297 partially repaired but failed the complete record gate;
zero-cell op-298 is the completion]** |
parent: **id-011** (libasl/asld) | L1i: **li-1004** (ASL) | authored:
**2026-07-11 by Arranger2**

## DISPATCH BOUNDARY

DISPATCHED by the Coordinator to `rmx-gatekeeper-rx-x64z` only on 2026-07-11. All new harness and evidence
writes land in `/Users/me/wip-mach/rmx-gatekeeper/`. Product, Explorer, and Arranger repositories
are read-only. This op authorizes at most **2 fresh guest cells**: Cell A is the direct-helper and
observer positive control; Cell B is released only if Cell A is accepted and measures launchd's
`RunAtLoad + StartInterval=900` behavior. It does not authorize a four-hour leg-4 soak.

## WHY THIS IS A FRESH OP

op-286 returned after producing guest markers, so its Attempt 1 is consumed and cannot be retried
or relabeled. Arranger first-hand adjudication reclassified it `HARNESS-NOT-ACCEPTED`: the required
observer positive control and invocation identity were absent, and a sampled process-name Boolean
cannot prove that one process stayed alive or that launchd suppressed later starts. op-293 repairs
the durable record and performs the smallest causal discrimination before another full soak or
product fix is considered.

## INPUT IDENTITY

Read-only source image:

`/Users/me/wip-mach/wip-gpt/build/op257-aslmanager-soak/op257-aslmanager-soak.img`

- size: `17179869184` bytes;
- SHA-256: `3f6d73dffae04f146cc6533f79a659829b0cf24002e15d5321f3ab7be613e040`;
- expected asld SHA-256:
  `0c2fe9d20840f2a2295e594e43f03abda33d75b620b5b1ce2ab9bd39432fa76c`;
- expected aslmanager SHA-256:
  `301bfb1dcb2b8ed65dbaf2ba2b308395735acdf219c8efb10941f3727d011d4b`;
- expected config: `RunAtLoad=true`, `StartInterval=900`, `-size 500K`,
  `max_store_size=500000`.

Hash the source before staging. Each guest cell uses its own fresh Gatekeeper-owned clone under
`build/op293/`; never boot or mutate the product-owned source image.

## REPOSITORY PREFLIGHT AND op-286 EVIDENCE FREEZE (0/2 CELLS)

1. Record full branch/HEAD/origin relationship and `git status --short --branch` for
   `/Users/me/wip-mach/rmx-gatekeeper/`. Preserve all unrelated tracked/untracked work and stage
   only explicit paths.
2. Verify, do not assume, the existing op-286 record:
   - commit `c69b1f28749d24ad519f2056e7e3ffe1192d4c95`;
   - `build/op286/op286-a1-host.log`: 855731 bytes, SHA-256
     `b97f157c62231fb5cb76b8f8c77bbe0f80711810eb6429cf509563e4af47281a`;
   - `build/op286/op286-a1-serial.log`: 852768 bytes, SHA-256
     `2aa919a10bbae79091f2f5ad2c7147c0465ff0fcfeebc8a6eeb310e4c5aa10f9`.
3. Preserve `c69b1f2` verbatim; do not amend, rebase, or rewrite its disposition. Add an explicit
   correction record under `build/op286/` that separates observation from inference and states:
   the reported `b97f...` serial digest is the host digest; no observer positive control or
   invocation identity exists; the Arranger disposition is `HARNESS-NOT-ACCEPTED`; Attempt 1 is
   consumed; Attempt 2 was not released; the launchd lifecycle explanation is unverified.
4. Derive a complete op-286 heartbeat/sample ledger from the raw log and create a SHA-256 manifest
   covering the two raw logs, rc script, original disposition, validator/tests, correction, and
   ledger. Commit the non-image raw/derived record by explicit paths in an additive correction
   commit. Never commit `op286-attempt1.img` or unrelated evidence.

Stop before guest work on any identity mismatch. Report it; do not silently repair or replace an
artifact.

## PHASE 0 — HOST-ONLY FAIL-CLOSED PREFLIGHT (0/2 CELLS)

Create an op-293 validator and tests in the Gatekeeper repo. Shell may orchestrate commands and
file routing only; substantive marker/order/count/classification logic lives in Zig or Elixir.

Before booting:

1. Freeze and hash the run manifest, exact generated guest commands, paths, timeouts, stdin/rc
   capture, cell identities, observer program, expected marker counts/order, and verdict rules.
2. Enumerate the actual guest tracing/proc surface and compile-preflight the exact observer. It must
   capture distinct aslmanager start/exec and exit events with PID, PPID, timestamp, and process
   state/exit information. A 60-second `pgrep` Boolean is not invocation evidence.
3. Synthetic controls must reject at least: observer compile failure; diagnostic text containing
   `unlink`; missing positive control; event without a corresponding byte/file/name delta; drop
   without an event; zero/monotonic sampled drops; missing/dead heartbeats; nonnumeric required
   counters; missing/duplicate/out-of-order markers; missing or multiple verdict/terminal markers;
   no invocation identity; unexplained record loss; and a settled-read miss. Prove one complete
   valid control trace is accepted.
4. Validate the exact generated commands and observer output schema, then save test output and
   hashes. A validator that treats the verdict marker as optional or counts every sampled size
   decrease as a reclaim fails preflight.

Any failure is `SCAFFOLD-FAIL`, consumes 0/2 cells, and stops. Do not boot.

## CELL A — DIRECT HELPER / OBSERVER POSITIVE CONTROL (1/2)

Use a fresh clone. This cell validates measurement and helper behavior; it does **not** test
launchd scheduling.

1. Prove image/component identity. Inventory the store by exact file name, size, timestamp, and
   total bytes/file count.
2. Create a controlled, valid, eligible sacrificial ASL store set above 500K using copied valid
   ASL files and `touch -t`; do not shift the guest clock or fill `/`. Freeze the inserted-file
   ledger and expected policy eligibility before invoking the helper.
3. Start the exact preflighted observer, then invoke `/usr/sbin/aslmanager` directly once with the
   frozen arguments. Capture PID/PPID/start/exec/exit/status and stdout/stderr.
4. Capture event-correlated before/after store bytes, file count, and exact file-name set. Acceptance
   requires one observed helper invocation plus deletion/reclaim of an eligible named file and a
   corresponding store decrease. Log text alone, `pgrep`, or a size drop alone is insufficient.
5. Emit exactly one Cell-A verdict and clean terminal state, freeze raw evidence, and shut down.

Cell-A verdict:

- `CONTROL-ACCEPTED` — observer, invocation identity, eligible-file deletion, and store delta all
  correlate; releases Cell B.
- `HELPER-PREMISE-NOT-ACCEPTED <reason>` — instrumentation is valid but the direct helper does not
  perform the expected reclaim.
- `HARNESS-NOT-ACCEPTED <reason>` — observer/control/evidence is invalid or incomplete.

Any guest runtime marker consumes Cell A. No retry is authorized.

## CELL B — LAUNCHD SCHEDULER DISCRIMINATION (2/2; GATED)

Run only after `CONTROL-ACCEPTED`, on a second fresh clone. No direct/manual aslmanager invocation
is allowed in this cell.

1. Prove identity and capture the full loaded plist/config, `launchctl` return/status, label, and
   launchd PID. Start the same accepted process observer before loading the aslmanager job.
2. Prepare a ledgered eligible store set before `launchctl load`; capture the initial `RunAtLoad`
   invocation and its exact process lifecycle/store effect.
3. Replenish controlled eligible **copied** files between windows without invoking aslmanager and
   without modifying asld's active file. Observe at least two complete 900-second interval windows
   after threshold/eligibility is established.
4. Capture every distinct aslmanager PID/PPID/start/exec/exit/status plus process state and exact
   event-correlated store bytes/file count/name set. Sample store state at 10 seconds or finer
   around expected boundaries so concurrent growth cannot mask a reclaim.
5. If a process persists, prove whether it is live, sleeping, blocked, stopped, or zombie using
   PID-specific `ps`/`procstat` evidence. Do not infer state from process-name presence.
6. Keep asld PID/fd/RSS/alive and panic/KASSERT observations as secondary context. Emit exactly one
   Cell-B verdict, freeze raw evidence, and cleanly shut down.

Cell-B verdict:

- `SCHEDULED-PREMISE-ACCEPTED` — distinct post-RunAtLoad scheduled invocation(s) and a correlated
  eligible-file/store drop are proven across the interval window; a fresh full leg-4 op may be
  authored.
- `SCHEDULER-PREMISE-NOT-ACCEPTED job-not-invoked` — control works, configuration/eligibility and
  both windows are proven, but no post-RunAtLoad invocation occurs; include observed process state.
- `SCHEDULER-PREMISE-NOT-ACCEPTED helper-invoked-no-delete` — scheduled invocation identity is
  proven but no eligible-file/store drop occurs.
- `HARNESS-NOT-ACCEPTED <reason>` — observer/control/order/evidence is insufficient.

Any guest runtime marker consumes Cell B. No retry or conversion into a four-hour soak is
authorized.

## DELIVERABLE

Under `build/op293/`, preserve and commit by explicit paths:

- manifest, activation/source pins, generated commands, observer source/build/preflight output;
- validator/tests and complete synthetic-control output;
- Cell-A and, if released, Cell-B raw host/serial logs, event ledger, store/file ledgers, exact
  command stdout/stderr/rc, sampled series, verdict, and clean-shutdown evidence;
- SHA-256 manifest covering every raw and derived non-image artifact; and
- `op293-verdict.md` separating observed fact, inference, and unverified explanation.

Do not commit images, cores, or unrelated artifacts. Do not push without separate Coordinator
authorization. Return exact commit(s), full final repo status/origin relationship, cell count and
true **serial** digest for each cell, disposition, and smallest next hop.

## BOUNDARIES

- No product-source/build, Explorer, Arranger, governing-doc, ID, milestone, or op-state write.
- Do not diagnose or fix launchd source in this op. A valid scheduler-negative result is evidence
  for a separately routed product or configuration decision, not permission to edit.
- Direct rc.local invocation is a deterministic control only. It cannot be used to claim that
  `StartInterval` works, that launchd is defective, or that production periodic reclaim is solved.
- op-198 v6 is a wiring precedent: it proves 16 direct invocations completed, but only cycle 1
  records a real 24168-to-8 KiB store drop. Do not call it “16/16 reclaim cycles.”
- Do not release or perform the four-hour ASL leg-4 soak. The Arranger authors a new op only after
  consuming this diagnostic and any required Coordinator configuration ruling.

## MARKERS

`GK_OP293_EVIDENCE_FREEZE`

`GK_OP293_HOST_PREFLIGHT`

`GK_OP293_CONTROL_START`

`GK_OP293_CONTROL_EVENT`

`GK_OP293_CONTROL_VERDICT`

`GK_OP293_SCHEDULE_START`

`GK_OP293_INVOCATION`

`GK_OP293_STORE_DELTA`

`GK_OP293_VERDICT`

`GK_OP293_TERMINAL`

## RELATIONS

op-286 (consumed harness-invalid predecessor) / op-258 (earlier harness-invalid leg-4) / op-257
(source image) / op-198 v6 (direct-invocation wiring precedent, one observed store drop) / op-260
(store-policy hypotheses) / op-163 (original leg-4 flag) / id-011 / li-1004.

feedback: `oss_engineering_framing`, `soak_is_gatekeeper`, `harness_authoring_is_gatekeeper`,
`dtrace_first_debugging`, `artifact_identity_needs_content_check`,
`background_exit_code_hygiene`, `no_conflate_gating_with_readiness`,
`agent_host_isolation`, `op_state_dispatch_boundary`.

## ARRANGER ADJUDICATION — 2026-07-11

Gate size: **M**, checked directly first-hand by Arranger2. Return commit
`dd8600170f5a9118ce6a50958a20afe36adbbdc5` exists atop `1b1c3e6`/`b3aeb7c`; Gatekeeper is
`main` 32 ahead of `origin/main`. The report is not accepted as
`SCHEDULER-PREMISE-NOT-ACCEPTED` and does not authorize an Implementer fix.

### Accepted partial facts

- Cell A raw serial shows PID 993/PPID 15, exit 0, deletion of two July-3 ASL files, and store
  56→48 KiB. This proves a direct CLI invocation can delete TTL-eligible copied files on the image.
- Cell B raw serial shows one launchd child, PID 916/PPID 867, in `S` state at every observed
  sample from tick 10 through tick 1710; no second PID appears through the first 900-second
  boundary. This is stronger than op-286's `pgrep` Boolean and proves the observed process is live
  and sleeping, not a zombie.
- The Cell-B count-only secondary series rises from asld fd 37 at tick 0 to 91 at tick 1710.
  That is an observation only: no fd-identity census exists, and the report's “+40 fd/hour” does
  not reproduce (the endpoint slope is approximately +114/hour). Do not call it a leak yet.

### Load-bearing evidence failures

1. The reported Cell-A “serial” SHA `4c026249...` is the 14,761-byte **host** log. The true
   11,798-byte serial SHA is
   `8aaa5f197a1c8a0aba87d949a1e69f36f81aa7a4e92955b1477bafead175d9f8`.
2. The reported Cell-B “serial” SHA `53af92ae...` is the 38,278-byte **host** log. The true
   35,315-byte serial SHA is
   `6584f2d11a8761c47d7d8d0efe531a7006c77504ae051cc61ef16699846d382c`.
3. Cell A created only a 56-KiB store, not the commissioned set above 500 KiB. Its TTL deletion is
   useful but does not validate the size-threshold control; state is **PARTIAL-CONTROL**.
4. Cell B ends abruptly at tick 1710. It never reaches the required second complete 900-second
   window and emits no `STORE_FINAL`, panic check, verdict, terminal marker, or clean shutdown.
   Correct disposition is **HARNESS-NOT-ACCEPTED — truncated before two windows/terminal**.
5. The Phase-0 validator is synthetic only; it does not parse either raw run, require two complete
   windows, or enforce final/verdict/terminal uniqueness and order. Its “single invocation” unit
   test can classify after one window, contrary to the activation bar.
6. All four op-293 raw host/serial logs remain untracked, as do the two raw op-286 logs that the
   Phase-0 manifest references. `dd86001` commits only `rc_cellB.local` and the derived verdict;
   therefore the commissioned frozen evidence record is incomplete and local-only.

### Source adjudication — not a scheduler defect or library-constructor mystery

The observed sleeping process follows an explicit product branch:

- `usr.sbin/aslmanager/aslmanager.c:1590-1605` asks `VPROC_GSK_IS_MANAGED`; unmanaged execution
  calls `cli_main`, while managed execution creates the `com.apple.aslmanager` XPC listener and
  deliberately enters `dispatch_main()`.
- `sbin/launchd/core.c:8401-8403` reports every non-anonymous launchd job as managed.
- The op-257 test plist combines a named launchd job with `RunAtLoad`/`StartInterval` and CLI
  arguments. Those arguments are ignored by the managed-server branch, so a persistent PID is the
  expected mode, not evidence that StartInterval itself is broken.
- The donor/Ravyn plist instead declares `MachServices/com.apple.aslmanager` and no interval. The
  current rmxOS libasl/asld trigger calls are disabled, so the faithful on-demand path is a separate
  integration decision.

Do **not** add `exit()` after `main`: the code intentionally never returns from `dispatch_main`, and
forcing exit would break the XPC service mode. The actual preview mechanism choice is banked in
id-040. Fresh op-296 repairs/freeze-checks the evidence record host-only; it runs no guest and does
not retry either consumed cell.
