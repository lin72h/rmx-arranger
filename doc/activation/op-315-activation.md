# op-315 — Explorer: make op-279 dispatchable — current launchd reaper premise, image, run-mode, and containment preflight

op-315 | role: **Explorer — read/source/evidence preflight only** | EXU:
**rmx-explorer / nx-r64z Explorer** | state: **[Retired — local Explorer commit
`332e159bd719f7f4841c7a0f8ebe2d43461f470d` consumed as a useful partial source record after
confidence-9 op-317 validation; incomplete staging/containment is not PREP-READY; any correction
gets a new op. Coordinator later selected PID-1 preview scope; op-318 owns the new contract while
op-279/op-280 remain held.]** | parent: **op-279 / id-016** | L1i: **li-1006 (launchd core service)** |
gates: **op-279 remains [Hold]; op-280 remains [Hold]** | authored: **2026-07-11 by Arranger2**

## ARRANGER RETURN INTAKE — 2026-07-12

The Explorer returned one committed note:

`/Users/me/wip-mach/rmx-explorer/findings/nx-r64z/20260711-op315-launchd-reaper-premise-preflight.md`

- commit `332e159bd719f7f4841c7a0f8ebe2d43461f470d`, parent
  `206b5a36e78de29ae6e519a836406972aa9b7ac5`, one added path, no push;
- note 12,871 bytes / 241 lines / SHA-256
  `5d221ef98b4a76d4bec970d6e46b596d6c693d1e6d0114ecf1637ebae0d20401`, blob
  `478d4cb6cb0d0b934f419834635dda942a9acc83`;
- tracked tree clean with all three commissioned pre-existing untracked paths preserved; and
- product launchd files remain byte-identical from the dispatched `40c8a93d` pin through current
  origin `26655e67`; the three pinned sizes/hashes/blobs reproduce.

Useful source findings survive intake: `waitpid_loop` is unconditionally created/detached and uses
`WNOWAIT`; `jobmgr_find_by_pid_deep` visibly traverses the active-job/submanager structures without
a lock in the bounded body; a managed zombie can be repeatedly observed until the main path reaps
it; and ordinary `rc.local` ancestry fails the non-`-u` startup gate. These are source premises,
not runtime incidence.

The L-sized release decision is **not accepted directly** because the return leaves commissioned
questions unresolved:

1. Q2 says PID-1 is the “only valid” non-`-u` form while its own source table shows a direct child
   of PID 1 also passes `launchd.c:197`. PID-1 via `init_path` is the only *proven* candidate named,
   not the only source-permitted form.
2. Q3 returns “golden base + launchd + init_path” rather than the required exact base path/hash,
   dependent libraries/config, staging owner/mechanism, content proof, and new-image decision.
3. Q4 omits much of the commissioned fail-closed plan: exact workload/exit status, artifact and
   mapping identity, ECHILD/LASTEXITSTATUS/zombie/panic observations, terminal grammar, raw
   command/stdout/stderr/serial/rc schema, known-good and known-bad controls, and cell/shutdown bar.
4. Q5 names in-guest execution but does not bind the post-incident guest-root rejection, approved
   staging helper, host-integrity before/after inventory, or exact disposable image BOM/hash.
5. op-200/op-201 and their held op-202/op-203 route explicitly classify PID-1 productionization /
   robustness as post-preview. A source-real hazard does not by itself make that topology a
   1.0-preview gate; current non-PID-1 `-u` exposure versus banked PID-1 work must be decided.

Therefore op-315 was not PREP-READY. Confidence-9 Validator op-317 accepted the source premise and
partial classifications while confirming the scope fork; op-315 now retires. No Implementer
image-stage, guest cell, op-279 release, or op-280 fix is authorized. Any future correction gets a
new op number.

## OBJECTIVE

Resolve the facts that currently prevent op-279 from being honestly dispatched:

1. whether the `waitpid_loop` Finding-A premise still exists at the current product tip;
2. what non-`-u` execution topology actually exercises the intended launchd supervision policy;
3. whether an existing disposable image is proven to contain the exact current launchd artifact;
4. the smallest host-safe, guest-contained staging/run plan for Gatekeeper; and
5. the exact fail-closed observations needed for hazards {abort/race, stolen zombie, hot loop}.

This op produces a preflight specification, not runtime evidence and not a fix.

## DISPATCH / REPOSITORY BOUNDARY

DISPATCHED by the Coordinator on 2026-07-11. The zero-cell, no-runtime boundary remains binding.

Write only:

`/Users/me/wip-mach/rmx-explorer/findings/nx-r64z/20260711-op315-launchd-reaper-premise-preflight.md`

Read product, Arranger, Gatekeeper, and historical evidence trees only. Do not write or stage in
them. Preserve the Explorer's existing untracked paths:

- `findings/nx-r64z/dtrace/op195-serial-v2.log`;
- `lib/rmx_os_oracle/id025/integration_soak_conductor.ex`;
- `python3.11.core`.

One focused local Explorer commit containing only the commissioned note is allowed; no push.

## PINNED IDENTITIES — REPRODUCE

Explorer repository:

- branch `main`;
- `HEAD=206b5a36e78de29ae6e519a836406972aa9b7ac5`;
- `origin/main=f8006a3dbf6edb970e1ab0f5b19c2fb386731666`;
- tracked worktree clean, with the three untracked paths above preserved.

Product repository `/Users/me/wip-mach/wip-gpt/wip-rmxos/`:

- clean `alpha@40c8a93d4b3fec707b2e6ecd7762a1b20948e6e3`;
- `origin/alpha` and live remote equal that commit;
- tree `1b34024c749b5b6f4befe1fb8838a1e197e400d7`;
- `sbin/launchd/runtime.c`: 39,762 bytes / 1,584 lines / SHA-256
  `b7823622f793aa0d0827e3adde28c45d2ef30f9f5c083e6344ca6e771c859ec8` / blob
  `d87e749eb96e940cadabea33609c018687f5c2b1`;
- `sbin/launchd/core.c`: 333,020 bytes / 12,133 lines / SHA-256
  `ff2dbec2a30db9905235db628c0088334de09a72381be86a880f2304bc19dd07` / blob
  `e9ac1dca60aabe416a7bada98320384da622cc80`;
- `sbin/launchd/launchd.c`: 17,328 bytes / 705 lines / SHA-256
  `a9c96d6b84241134c9a5bd694fa66b5532dbc9363b25da3f26645205b7ea650e` / blob
  `be81cddead0a6a7fd0576e829af393d2e7c80602`.

Accepted op-278 launchd artifact, read-only:

`/Users/me/wip-mach/wip-gpt/build/op278-launchd-exit-detail/obj/Users/me/wip-mach/wip-gpt/wip-rmxos/amd64.amd64/sbin/launchd/launchd`

- 338,728 bytes;
- SHA-256 `bcdc0e5e54015dffd7ef32430665d169bd388478ff10405ef9d3ed33fd4ca897`;
- FreeBSD 15.1 x86-64 PIE, dynamically linked;
- built from op-278 commit `7291ad2a722b65661ff096ef09357b8756eb108f`, whose launchd source blob
  remains the current `core.c` blob above.

Stop `BLOCKED IDENTITY-DRIFT` if a pinned source/artifact identity differs. Unrelated local dirt in
the control/Gatekeeper trees is recorded but not repaired.

## REQUIRED READS

Read completely or through the named load-bearing bodies:

- `/Users/me/wip-mach/rmx-arranger/doc/activation/op-279-activation.md`;
- `/Users/me/wip-mach/rmx-arranger/doc/activation/op-280-activation.md`;
- `/Users/me/wip-mach/rmx-arranger/doc/activation/op-278-activation.md`;
- `/Users/me/wip-mach/rmx-arranger/doc/host-guest-isolation-incident-2026-07-11.md`;
- `runtime.c:238-266,646-657,760-786,1240-1320,1510-1530`;
- `core.c:4050-4065,6820-6880,6960-7025,7220-7250,11870-11910`;
- `launchd.c:140-220` including `-u`, PID/PPID, and startup checks;
- existing op-134/launchctl KeepAlive evidence and the bounded op-286/op-293 image/manifests only
  as needed for image/run-mode provenance.

## Q1 — CURRENT PREMISE

Verify from current source, without broad launchd review:

- creation/detachment and lifetime of `waitpid_loop`;
- exact `waitpid` flags and behavior for child/no-child/zombie cases;
- the call into `jobmgr_reap_pid` and all job-table traversal/mutation synchronization visible in
  the bounded bodies;
- whether op-278 or later commits changed any load-bearing Finding-A body;
- which hazard remains source-reachable: abort/use-after-free, managed-zombie theft/misclassification,
  or idle hot-loop.

Classify each `SOURCE-SOLID`, `SOURCE-NOT-SUPPORTED`, or `RUNTIME-ONLY`. Do not report a runtime
hazard as confirmed from source.

## Q2 — VALID EXECUTION TOPOLOGY

The existing op-279 instruction “do not run under `-u`” is load-bearing because `core.c:4058`
force-starts inactive jobs when `uflag` is set. Determine exactly:

- whether non-`-u` launchd must be PID 1, a direct child of PID 1, or another supported topology;
- what startup check at `launchd.c:197` permits/rejects;
- whether a second launchd instance inside an ordinary `rc.local` shell would be invalid;
- the smallest disposable guest boot topology that exercises real KeepAlive policy without making
  the assertion vacuous;
- whether that topology alters the normal preview boot model and, if so, how it must be labeled.

Return one exact topology or `NO-VALID-TOPOLOGY-YET <missing prerequisite>`; do not leave the choice
to Gatekeeper at runtime.

## Q3 — ARTIFACT / IMAGE CENSUS

Read-only census these bounded candidates and their existing provenance records:

- `/Users/me/wip-mach/wip-gpt/build/op257-aslmanager-soak/op257-aslmanager-soak.img` — reported
  SHA-256 `3f6d73dffae04f146cc6533f79a659829b0cf24002e15d5321f3ab7be613e040`;
- `/Users/me/wip-mach/rmx-gatekeeper/build/op286/op286-attempt1.img` — 17,179,869,184 bytes,
  reported derived from the op-257 image;
- `/Users/me/wip-mach/rmx-gatekeeper/build/op293/op293-cellA.img` and `op293-cellB.img` — each
  17,179,869,184 bytes, plus their existing manifests/logs.

Using only existing manifests/logs/static files—no mount, boot, target execution, or privilege—ask
whether any candidate proves `/sbin/launchd` equals the exact op-278 artifact and has the topology
required by Q2. Filename/lineage alone is insufficient.

If none does, return the exact smallest Implementer staging prerequisite: source artifact, image
base, in-image destination, dependent libraries/config, expected content proof, and whether a new
image is required. Do not stage it yourself.

## Q4 — MINIMAL GATEKEEPER EVIDENCE PLAN

Specify, but do not execute, the smallest op-279 runtime plan:

- idle window length and strict CPU sampling method for hot-loop detection;
- one bounded KeepAlive child-exit workload with known intended exit status;
- exact launchd PID/artifact/mapping identity before the workload;
- exact observations for launchd survival/restart, stolen zombie/ECHILD, incorrect crash or
  `LASTEXITSTATUS`, unreaped zombies, CPU, and panic;
- fail-closed terminal grammar and raw command/stdout/stderr/serial/rc capture;
- smallest known-good self-control and known-bad detector control;
- one attempt/cell boundary and clean shutdown.

The plan must distinguish `CONFIRMED`, `NOT-OBSERVED`, `HARNESS-NOT-ACCEPTED`, and
`INFRASTRUCTURE-NOT-ACCEPTED`. “No crash” alone is not a Finding-A verdict.

## Q5 — HOST/GUEST CONTAINMENT

Give an exact future staging/execution boundary that cannot repeat the op-235/op-306 failures:

- no host target execution, `dlopen`, preload, or constructor-bearing library load;
- no host `/etc`, `/boot`, rc, module, or loader mutation;
- no arbitrary privileged shell/redirection/heredoc;
- no unset/empty/root guest destination;
- artifact transfer or image creation owned by the correct EXU;
- disposable image/BOM/hash and host-integrity checks before/after;
- runtime begins only inside the authorized guest cell.

If no existing approved mechanism satisfies this, say `NEEDS-CONTAINMENT-PREREQUISITE`; do not
invent authority or silently switch to bhyve execution.

## EXCLUSIONS

- no guest boot, image mount/mutation, privilege, host runtime, build, staging, or target load;
- no product, Arranger, Gatekeeper, Oracle, or Validator write;
- no op-280 fix design beyond naming which evidence would warrant it;
- no op-278 reopening, xpc_domain/service-plane audit, PID-1 productionization, ASL work, libxpc
  work, broad launchd parity, or post-preview feature;
- no ID/op allocation, dispatch, retirement, milestone decision, or claim that op-279 is green.

## RETURN

Return one:

- `PREP-READY EXISTING-IMAGE <path> <sha256>` — exact artifact/topology/containment proven from
  existing records;
- `PREP-NEEDS-IMPLEMENTER-STAGE <exact prerequisite>`;
- `PREP-NEEDS-CONTAINMENT-PREREQUISITE <exact missing control>`;
- `PREP-INCONCLUSIVE <missing fact>`;
- `BLOCKED IDENTITY-DRIFT <fact>`.

Report note path/bytes/lines/SHA-256, source/artifact/image census, Q1-Q5 answers, complete repo
status, commit/parent, push=0, and unavailable reproduction.

Markers:

```text
EXPLORER_OP315_INPUT_IDENTITY
EXPLORER_OP315_REAPER_PREMISE
EXPLORER_OP315_RUN_TOPOLOGY
EXPLORER_OP315_IMAGE_CENSUS
EXPLORER_OP315_GATEKEEPER_PLAN
EXPLORER_OP315_CONTAINMENT
EXPLORER_OP315_TERMINAL
```

## RELATIONS

op-264 → op-279 → op-280; op-278; op-134; id-016; li-1006.

feedback: `agent_host_isolation`, `artifact_identity_needs_content_check`,
`code_reasoned_verdict_is_hypothesis`, `verify_premise_before_mechanism`,
`no_conflate_gating_with_readiness`, `launchd_no_autoscan`, `op_state_dispatch_boundary`
