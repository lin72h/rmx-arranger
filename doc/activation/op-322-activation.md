# op-322 — Explorer: correct the op-318 PID-1 containment and reaper contract after op-321

op-322 | role: **Explorer — bounded contract correction only** | EXU:
**rmx-explorer-rx-x64z (rx1; owns op-318 note and PID-1 evidence)** | state: **[Done — Explorer
returned CORRECTED-CONTRACT-READY-FOR-VALIDATION at confidence 9/10; identity matched; XL return
split into independent staging and reaper Validator gates before retirement]** |
DISPATCH: **CONSUMED — relayed by Coordinator to rmx-explorer-rx-x64z** | parent:
**retired op-318/op-321 / id-016 / id-042** | L1i: **li-1006 / li-008 / li-1013** |
relations: **held op-202/op-203/op-279/op-280** | authored: **2026-07-17 by Arranger2**

## RETURN / ARRANGER INTAKE — 2026-07-22

Explorer returned one additive correction note:

- `/Users/me/wip-mach/rmx-explorer/findings/nx-r64z/20260717-op322-pid1-contract-correction.md`;
- 41,160 bytes / 376 lines / SHA-256
  `b6a08dc33f4416dc102c6e2675e5584c8a1fd4bd0c5bc574ddb6adbbfc9c8158`;
- local commit `3620e5b9d571432e383fd2833fbaafce99a56e6c`, parent `9355ad42e2647846e601ae2200507daefd59ce74`;
- Explorer ahead/behind origin/main `3/1`, tracked clean, exactly the three expected untracked paths;
  push=0 and the findings commit is not origin/main-reachable.

Arranger reproduced the note/commit identities, one-path commit, all ten required
`EXPLORER_OP322_*` markers, `OP322_VERDICT: CORRECTED-CONTRACT-READY-FOR-VALIDATION`, confidence 9,
and terminal status 0. The return is **XL**: C1/C2 govern host-safe staging and artifact identity;
C3-C7 govern process/probe/wait-status/control/verdict correctness; C8 carries topology, signal,
and legacy dispositions. `[Done]` records return only, not validation or retirement.

To remove the false global serialization identified after dispatch, validation splits without
splitting or rewriting the Explorer artifact:

1. staging package — C1 + C2 + staging-relevant C8, independently gated before any Implementer
   helper/disposable-image brief;
2. reaper package — C3-C7 + reaper/signal-relevant C8, independently gated before any Gatekeeper
   reaper cell.

The two gates may run in parallel and neither consumes the other's verdict. A staging-package pass
may release helper/image authoring while the reaper gate continues. No helper, image, runtime cell,
product edit, legacy-op normalization, or retirement is released by this intake alone.

## OBJECTIVE

Write one additive correction note that replaces only op-318's unsafe/invalid containment-helper
and reaper-control sections. Preserve its validated partial facts: PID-1/non-`-u` intent,
no-acceptable-base conclusion, disposable-versus-production image split, 18-row activation census,
existing-helper deficit census, and named SIGUSR1 risk. Produce an exact, host-safe contract that
can be independently gated before an Implementer containment-helper/disposable-image brief.

This is not a new architecture review, image census, product fix, helper implementation, build,
stage, or runtime probe.

## REPOSITORY / WRITE BOUNDARY

Write only:

`/Users/me/wip-mach/rmx-explorer/findings/nx-r64z/20260717-op322-pid1-contract-correction.md`

One focused local Explorer commit containing only that new note is allowed. No push. Preserve the
tracked tree and these three pre-existing untracked paths byte-for-byte:

- `findings/nx-r64z/dtrace/op195-serial-v2.log`;
- `lib/rmx_os_oracle/id025/integration_soak_conductor.ex`;
- `python3.11.core`.

Read other repositories; write none. No product/Arranger/Gatekeeper/host/image write, build,
target execution, `dlopen`, preload, guest, image mount/stage/mutation, privilege, host
configuration, network, op/ID allocation, dispatch, release, retirement, or ship decision.

## PINNED INPUTS — STOP `BLOCKED IDENTITY-DRIFT <fact>`

Explorer `/Users/me/wip-mach/rmx-explorer/`:

- `main@9355ad42e2647846e601ae2200507daefd59ce74`;
- parent `332e159bd719f7f4841c7a0f8ebe2d43461f470d`;
- `origin/main=f8006a3dbf6edb970e1ab0f5b19c2fb386731666`, ahead/behind `2/1`;
- tracked clean; exactly the three untracked paths above;
- op-318 note: 48,127 bytes / 436 lines / SHA-256
  `180361ecdc772e2a63ca6ba05c76797524729314feb9ad7cb26056e834b73dfe`.

Canonical op-321 adjudication:

- `/Users/me/wip-mach/rmx-arranger/doc/activation/op-321-activation.md`;
- 17,506 bytes / 356 lines / SHA-256
  `c9227a25107606391abab4297bf77d51e953032c2fefea75aa1d490a05f30604`;
- Validator3 verdict `VALIDATED-WITH-CORRECTIONS`, confidence 7/10;
- Arranger Arbiter final call `PREP-NOT-ACCEPTED AS IMPLEMENTER/RUNTIME CONTRACT` with bounded
  correction routed here.

Product `/Users/me/wip-mach/wip-gpt/wip-rmxos/`:

- clean, origin-aligned `alpha@26655e67872cd55cff0a272b32b7895f55368033`, tree
  `aa9d4f44716b0793ca4de6ae67c7d819cf7ab15d`;
- launchd/source and staging-script pins remain those reproduced by op-318/op-321;
- stop if any bounded source or script changed.

The op-322 Ready header and id-016/id-042 routing deltas are expected control changes, not product
drift.

## REQUIRED READS

Read completely:

- op-318 note;
- op-321 activation including return/Arbiter block and G1–G8 brief;
- host-isolation incident;
- current `stage-guest.sh`, `image-staging-guard.sh`, `run-guest.sh` and direct helpers;
- bounded launchd source for `waitpid_loop`, `jobmgr_reap_pid`, `wait4`/`last_exit_status`,
  launchd data export, PID-1 signals/calendar, admission/init, and job loading;
- FreeBSD target headers/source/manuals needed to establish exact `ps`, `procstat`, DTrace,
  wait-status, and process-observation semantics.

Do not copy Validator conclusions without re-deriving the corrected contract.

## C1 — HOST-SAFE CONTAINMENT SELF-TEST

Replace the physical-host `/etc/rc.conf` mutation with an exact fixture mechanism:

- inventory function accepts an explicit, test-only root or injected file set;
- production mode hard-binds the real protected inventory and refuses test overrides under
  privilege;
- negative tests mutate only a user-owned fixture tree/mock manifest;
- no self-test writes physical `/etc`, `/boot`, modules, loader configuration, mount table, or
  other protected host state;
- test the empty/root/`/etc`/`/boot`/mounted/wrong-device/wrong-image/stale-lock/BOM/sentinel and
  simulated-delta refusals before privilege wherever possible.

Preserve explicit argv, no privileged shell/heredoc/tee/redirection, atomic install, mount/device
identity, lock/cleanup, before/after inventory, guest marker, and in-image BOM equality.

Split ownership exactly:

- Implementer/product repository owns the stage-helper source and disposable image build/stage;
- Gatekeeper repository owns later cell-runner/orchestration and runtime evidence;
- never require either EXU to write the other's repository.

Marker: `EXPLORER_OP322_CONTAINMENT`.

## C2 — ARTIFACT / BOM IDENTITY RULE

State load-bearingly:

- unchanged source proves source equivalence only;
- `bcdc0e5e...` is historical op-278 artifact identity, not an automatic current rebuild hash;
- the Implementer must pin full build environment/commands/flags and build a fresh artifact;
- exact equality to `bcdc0e5e...` is accepted only if reproduced;
- otherwise stop for Arranger acceptance of the new content hash before image staging;
- host-built artifact SHA must equal the in-image `/sbin/launchd` SHA and BOM row.

Marker: `EXPLORER_OP322_ARTIFACT_IDENTITY`.

## C3 — PID / EXECUTABLE IDENTITY COMMANDS

Replace the invalid `comm == /sbin/launchd` and hash-of-`procstat`-text checks. Specify exact
FreeBSD commands/output fields that establish independently:

- PID 1 command name is `launchd`;
- executable path/mapped object resolves to `/sbin/launchd`;
- hash the actual executable file/object, not command output text;
- arguments contain no exact `-u` token;
- loader config, candidate BOM, and runtime process identity agree.

If any field cannot be proven statically on the target version, define a fail-closed preflight
observation and classify it runtime-owed; do not invent output grammar.

Marker: `EXPLORER_OP322_PROCESS_IDENTITY`.

## C4 — REAPER / ECHILD OBSERVATION

Remove kernel `fbt::jobmgr_reap_pid` and libc-style `fbt::waitpid:return` claims.
`jobmgr_reap_pid` is userspace launchd. Specify a target-valid observation scheme, distinguishing:

- userspace function entry/return (only through a proven userspace provider/symbol regime);
- kernel syscall/wait return and ECHILD (only through proven FreeBSD providers/arguments);
- source/log/process-state fallback when a provider is unavailable.

For every probe/command, give provider, module/function/name pattern, arguments, required symbol
shape, availability preflight, and what fact it distinguishes. Missing required probes must stop
as harness-not-accepted, not silently disappear through `-Z` or an empty trace.

Marker: `EXPLORER_OP322_REAPER_OBSERVATION`.

## C5 — RAW WAIT-STATUS CONTRACT

Derive the exact table from current launchd source and FreeBSD wait macros:

- normal exit 0;
- normal exit 1;
- SIGSEGV death;
- `wait4` failure synthesis `W_EXITCODE(-1, SIGSEGV)`.

Record raw stored/exported integer plus `WIFEXITED`, `WEXITSTATUS`, `WIFSIGNALED`, and `WTERMSIG`
interpretation. Terminal evidence must record both raw and decoded fields. Never compare a raw
status directly with a signal name or assumed shell `128+signal` convention.

Marker: `EXPLORER_OP322_WAIT_STATUS`.

## C6 — TRUE FAIL-CLOSED CONTROLS

Delete the `launchctl setenv` fake-status fixture. Replace it with controls that actually exercise
the evidence classifier, for example a content-pinned known-good record plus deliberately mutated
copies with wrong raw status, wrong decode, missing reap event, missing terminal, reordered wave,
or absent probe. The validator must accept the known-good and reject every mutation.

Keep runtime workload controls separate from offline parser/oracle mutation controls. State exact
inputs, expected classifications, and nonzero/failed result on any accepted known-bad.

Marker: `EXPLORER_OP322_FAIL_CLOSED_CONTROLS`.

## C7 — PER-AXIS AND AGGREGATE VERDICTS

For each hazard `(a) torn traversal`, `(b) managed-zombie theft`, `(c) managed-exit hot loop`,
return exactly one:

- `OBSERVED`;
- `NOT-OBSERVED`; or
- `INCONCLUSIVE`.

Define aggregate results without collision:

- `PREMISE-CONFIRMED` only when at least one named axis is `OBSERVED`, its evidence is valid, and
  the report states all other axis outcomes;
- `PREMISE-NOT-OBSERVED` only when the complete bounded workload and controls pass and every axis
  is `NOT-OBSERVED`;
- `HARNESS-NOT-ACCEPTED` for missing/invalid identity, probe, capture, grammar, control, manifest,
  or inconclusive axis caused by the harness;
- `INFRASTRUCTURE-NOT-ACCEPTED` only for host/image/hypervisor/staging infrastructure failure that
  prevents a valid product observation;
- a product panic, launchd death, corrupt exit accounting, or service failure under valid identity
  is product evidence and must be reported as the relevant observed failure, never hidden as
  infrastructure.

Marker: `EXPLORER_OP322_VERDICT_GRAMMAR`.

## C8 — TOPOLOGY / SIGNAL / LEGACY CORRECTIONS

Carry these corrections into the authoritative contract:

- exact `/etc/launchd.d` scan mechanism is runtime owed, not source-proven by `jobmgr_init`;
- SIGTERM currently logs/breaks; it does not source-prove a single-user transition;
- zero shipped `StartCalendarInterval` plists proves no live calendar consumer only;
- external/accidental SIGUSR1→PID-1 halt remains a named id-016/id-042 productionization risk;
- do not revive op-289/op-290 or allocate a new ID;
- preserve useful op-202/op-203/op-279 contract content in any superseding/re-pinned briefs;
- op-280 remains conditional and may normalize in place only after accepted premise evidence.

Marker: `EXPLORER_OP322_SCOPE_CORRECTIONS`.

## RETURN / VERDICT

Return exactly one:

- `CORRECTED-CONTRACT-READY-FOR-VALIDATION` — C1–C8 complete and internally consistent;
- `CORRECTION-INCOMPLETE <items>`;
- `BLOCKED IDENTITY-DRIFT <fact>`.

Report note path/bytes/lines/SHA-256, commit/parent/status, exact changed paths, input identities,
C1–C8 result, unavailable reproduction, push=0, and boundary.

Required markers:

```text
EXPLORER_OP322_INPUT_IDENTITY
EXPLORER_OP322_CONTAINMENT
EXPLORER_OP322_ARTIFACT_IDENTITY
EXPLORER_OP322_PROCESS_IDENTITY
EXPLORER_OP322_REAPER_OBSERVATION
EXPLORER_OP322_WAIT_STATUS
EXPLORER_OP322_FAIL_CLOSED_CONTROLS
EXPLORER_OP322_VERDICT_GRAMMAR
EXPLORER_OP322_SCOPE_CORRECTIONS
EXPLORER_OP322_TERMINAL
```

REPORT

```text
op: op-322
agent: rmx-explorer-rx-x64z
dispatch: bounded op-318 PID-1 contract correction complete
next-hop: Arranger sizes the correction return and routes validation before any Implementer helper/image stage
```

## RELATIONS / FEEDBACK

retired op-318→retired op-321→op-322; held op-202/op-203/op-279/op-280; id-016/id-042;
li-1006/li-008/li-1013.

feedback: `agent_host_isolation`, `artifact_identity_needs_content_check`,
`verify_premise_before_mechanism`, `code_reasoned_verdict_is_hypothesis`,
`no_conflate_gating_with_readiness`, `build_is_implementer`, `soak_is_gatekeeper`,
`one_op_one_pipeline`, `op_state_dispatch_boundary`.
