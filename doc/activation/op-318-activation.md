# op-318 — Explorer: exact PID-1 preview activation contract — topology, current-tip disposable image/BOM, containment, and runtime split

op-318 | role: **Explorer — discovery/specification only** | EXU:
**rmx-explorer-rx-x64z (rx1; owns op-200/op-201/op-315 evidence)** | state: **[Retired — partial
topology/image/activation facts banked; helper/reaper contract PREP-NOT-ACCEPTED after op-321;
replacement op-322 Ready]** | DISPATCH: **CONSUMED — no stage, helper implementation,
legacy-op disposition, or runtime released** | parent:
**id-016 + id-042** | L1i: **li-1006 / li-008** | relations: **retired op-200/op-201/
op-315/op-317; held op-202/op-203/op-279/op-280** | authored: **2026-07-12 by Arranger2**

## RETURN / INTAKE — 2026-07-17

Explorer returned one focused local commit:

- note: `/Users/me/wip-mach/rmx-explorer/findings/nx-r64z/20260712-op318-pid1-preview-activation-contract.md`;
- 48,127 bytes / 436 lines / SHA-256
  `180361ecdc772e2a63ca6ba05c76797524729314feb9ad7cb26056e834b73dfe`;
- commit `9355ad42e2647846e601ae2200507daefd59ce74`, parent
  `332e159bd719f7f4841c7a0f8ebe2d43461f470d`;
- Explorer ahead/behind origin `2/1`, tracked tree clean, exactly three commissioned untracked
  paths preserved, push 0;
- verdict `PREP-NEEDS-CONTAINMENT-HELPER`, confidence 9.

Arranger intake reproduced the note/commit/status identities and sized the return **XL**. The
topology, no-acceptable-base census, 18-row activation delta, containment-helper proposal,
one-cell reaper plan, and seven-step role/disposition recommendations cross product, image,
runtime, and safety planes. They are hypotheses pending independent Validator op-321.

Validator attention is specifically required for several potentially load-bearing edges: the
claim that unchanged source reproduces op-278's binary absent a pinned build environment; exact
PID-1 scan/root-rw/single-user mechanisms; physical-host self-test safety (a helper must never
mutate real `/etc/rc.conf` to simulate a delta); the proposed `ps`/`procstat`/DTrace/launchctl
observations; exit-status semantics; the known-bad fixture; classification of a valid-workload
panic as product evidence rather than infrastructure; and the contradiction between calling a
falsified hazard `PREMISE-CONFIRMED` versus `PREMISE-NOT-OBSERVED`.

No recommendation to flush op-202/op-203/op-279 or normalize op-280 is accepted yet. No product,
helper, stage, guest cell, privilege, image mutation, or runtime action is released.

## AUTHORITY / WHY

Coordinator ruling, 2026-07-12: **launchd must be PID 1 in 1.0-preview**. This closes op-317's
topology fork in favor of non-`-u` PID-1 launchd, but op-317 also established that the image stage,
fail-closed reaper plan, and post-incident containment contract are incomplete. Produce the exact
contract required before an Implementer image stage or Gatekeeper cell can be authored. Do not
stage, boot, execute, or fix anything.

## REPOSITORY / DISPATCH BOUNDARY

Write only:

`/Users/me/wip-mach/rmx-explorer/findings/nx-r64z/20260712-op318-pid1-preview-activation-contract.md`

Read the product, Arranger, Gatekeeper, and historical evidence trees as needed; write none of
them. One focused local Explorer commit containing only the commissioned note is allowed. No push.
Preserve the existing Explorer branch divergence and these untracked paths byte-for-byte:

- `findings/nx-r64z/dtrace/op195-serial-v2.log`;
- `lib/rmx_os_oracle/id025/integration_soak_conductor.ex`;
- `python3.11.core`.

No guest boot, cell, image mount/copy/mutation, privilege, host target execution, `dlopen`, preload,
constructor-bearing target load, build, source edit, staging, host configuration write, ID/op
allocation, release, dispatch, retirement, or milestone decision.

## PINNED INPUTS — REPRODUCE OR STOP `BLOCKED IDENTITY-DRIFT <fact>`

Explorer repository `/Users/me/wip-mach/rmx-explorer/`:

- branch `main`;
- `HEAD=332e159bd719f7f4841c7a0f8ebe2d43461f470d`;
- parent `206b5a36e78de29ae6e519a836406972aa9b7ac5`;
- `origin/main=f8006a3dbf6edb970e1ab0f5b19c2fb386731666`;
- ahead/behind `1/1`, tracked tree clean, exactly the three untracked paths above.

Product repository `/Users/me/wip-mach/wip-gpt/wip-rmxos/`:

- clean, origin-aligned `alpha@26655e67872cd55cff0a272b32b7895f55368033`;
- tree `aa9d4f44716b0793ca4de6ae67c7d819cf7ab15d`;
- `sbin/launchd/runtime.c`: SHA-256
  `b7823622f793aa0d0827e3adde28c45d2ef30f9f5c083e6344ca6e771c859ec8`;
- `sbin/launchd/core.c`: SHA-256
  `ff2dbec2a30db9905235db628c0088334de09a72381be86a880f2304bc19dd07`;
- `sbin/launchd/launchd.c`: SHA-256
  `a9c96d6b84241134c9a5bd694fa66b5532dbc9363b25da3f26645205b7ea650e`.

Accepted Explorer notes:

- op-200: 8,907 bytes / 125 lines / SHA-256
  `5eb5ecf76b9a40e1edef1f18595fa24cea80d52a72d9b8677f91ac58eb55b4eb`;
- op-201: 4,386 bytes / 71 lines / SHA-256
  `66301ae6f4cfc7c481703b3ceba5a646662bdf000f1f8be0f4ede6085f0e9228`;
- op-315: 12,871 bytes / 241 lines / SHA-256
  `5d221ef98b4a76d4bec970d6e46b596d6c693d1e6d0114ecf1637ebae0d20401`.

Current staging/runtime scripts are read-only inputs, not accepted containment by implication:

- `/Users/me/wip-mach/wip-gpt/scripts/bhyve/stage-guest.sh` SHA-256
  `6753c0b179c5a9ef6de02583feea7a8083673fb83ed0a02047c492597a5a3cf1`;
- `image-staging-guard.sh` SHA-256
  `b92e97f5df38b9ce9c22588cd2da81246130b20a7e18810d5ffd4676404a19a2`;
- `run-guest.sh` SHA-256
  `251ab6ddc5b09e333629cd7be5450c480b39be8acb2d70dfb5b1bbc88d2d8630`.

Record unrelated drift; do not repair it. If product or commissioned evidence identity differs,
stop. A changed active control header caused only by this op's Ready→Exe dispatch is not product
identity drift; record the exact delta.

## REQUIRED READS

Read completely:

- op-200, op-201, op-202, op-203, op-279, op-280, op-315, and op-317 activations;
- the three accepted Explorer notes above;
- `idq/id-016-ambient-mach-bootstrap-port.md` and `idq/id-042-1.0-preview-todo.md`;
- `l1i/li-008-launchd-core-service.md` and `l1i/li-1000.md`;
- `doc/host-guest-isolation-incident-2026-07-11.md`;
- the three staging/runtime scripts above and every helper they directly source or execute;
- the bounded current source bodies for PID/PPID/`-u` admission, `pid1_magic`, rc/job loading,
  signal ownership, `waitpid_loop`, main-thread child exit/reap, shutdown/reboot/single-user, and
  scheduled-launch behavior.

Use committed text manifests/logs for image/evidence census. Static file hashing, `git show`,
`readelf`, `nm`, and source reading are allowed. Do not mount, attach, load, or execute a target.

## Q1 — FREEZE THE PREVIEW TOPOLOGY

Write one unambiguous topology contract:

- `/sbin/launchd` is PID 1 through `init_path`, without `-u`;
- the exact op-201 `/etc/rc` chain-load mechanism and where/how PID-1 launchd loads it;
- ownership/order of `/etc/rc`, launchd jobs, getty, shutdown/reboot, and single-user entry;
- root read-write criterion and the exact op-201 residual to close;
- ambient bootstrap criterion for a non-launchd descendant;
- which historical `rc.local`/generic-boot-load bridge is removed, retained, or made inert so
  services are not started twice.

Distinguish `PROVEN BY OP-200/201`, `CURRENT-TIP SOURCE-SUPPORTED`, and `RUNTIME-OWED`. Do not
promote the disposable 2026-06-29 calibration into current-candidate proof.

## Q2 — EXACT CURRENT-TIP DISPOSABLE IMAGE / BOM CONTRACT

Census bounded existing staging-model candidates and records, including:

- `/Users/me/wip-mach/build/op128-dev-preview/dev-preview-memstick.img` and `staging.img`;
- the op-257/op-286/op-293 lineage named by op-315;
- any later content-addressed candidate explicitly referenced by id-015/id-042 or committed
  Gatekeeper manifests.

Name exactly one base or return `NO-ACCEPTABLE-BASE <reason>`. For the selected base provide:

- absolute path, byte size, SHA-256, partition/boot regime, and provenance limit;
- a complete source-artifact → in-image-destination BOM for kernel, Mach module, loader/rc config,
  launchd/launchctl, liblaunch, libdispatch, libnotify/notifyd, libasl/asld/aslmanager and production
  plist, libxpc, dependent libraries, rc-chain plist/script, and all probes;
- required rebuilds from current origin versus reusable content-proven artifacts;
- exact `init_path`, launchd arguments, plist locations, service ordering, and duplicate-start
  exclusions;
- pre/post image hash and in-image hash/metadata proof for every load-bearing item;
- whether the result is a disposable premise image, a production candidate, or two separate
  images. Do not conflate them.

Filename, ancestry, host build output, or “golden base” alone is not content proof.

## Q3 — PID-1 ACTIVATION-DELTA CENSUS

Moving from FreeBSD init + `launchd -u` to PID-1 enables or changes code/config that old preview
evidence did not exercise. Census only load-bearing preview consequences:

- `pid1_magic`, PID/PPID admission, bootstrap inheritance, signal ownership, shutdown/reboot,
  single-user, reaping, and crash behavior;
- `-u` force-start removal and its effect on KeepAlive/on-demand evidence;
- op-273's calendar/SIGUSR1 collision and whether the exact candidate has any build-enabled,
  configured `StartCalendarInterval` consumer; distinguish `StartInterval`;
- launchd self-scan versus explicit chain-load/generic boot-load and duplicate service ownership;
- root-rw/getty/base duties and any current preview service that depended on rc.local ordering.

For each return `LIVE-CONSUMER`, `NO-LIVE-CONSUMER`, `RUNTIME-OWED`, or `PRODUCT-PREREQUISITE`,
with source/config coordinates. op-289/op-290 are flushed and cannot be revived; recommend a new
ID only if a live preview consumer is proven.

## Q4 — CONTAINMENT AND STAGING CONTRACT

Evaluate the current helper chain against the incident controls. An exact future stage must bind:

- one owning EXU and one approved helper entry point;
- explicit source and destination arguments with no nested shell interpolation;
- rejection, before privilege, of unset/empty/root/`/etc`/`/boot`, stale, unmounted, wrong-device,
  wrong-image, and missing-sentinel guest roots;
- canonical approved-workspace path, active mount, expected md partition/source, and device/fs
  distinct from host `/`;
- unprivileged construction/hash followed by atomic explicit-path installation;
- host integrity inventory before/after for `/etc/rc.conf`, `/etc/rc.local`, `/etc/rc.d`,
  `/boot/loader.conf`, and `/boot/modules`, with any delta a hard stop;
- no arbitrary privileged shell, heredoc, redirection, `tee`, target execution, `dlopen`, or
  preload on the host;
- target execution only after a guest-runtime marker inside the authorized cell;
- image lock, cleanup, final unmount/detach, BOM, sync, and clean shutdown.

Return `CONTAINMENT-EXACT` only if an existing helper and tests already prove all requirements.
Otherwise return `NEEDS-IMPLEMENTER-CONTAINMENT-HELPER` with the smallest exact helper/test contract.
Do not write the helper.

## Q5 — CORRECTED OP-279 FAIL-CLOSED PREMISE

Specify the smallest one-cell PID-1 runtime premise after the disposable image stage:

- verify in-guest PID 1, executable/mapping hash, boot config, component BOM, and non-`-u` state;
- sample CPU during controlled managed-child exit windows, not only idle, so the managed-zombie
  hot loop can be observed/falsified;
- use exact bounded managed and unmanaged child counts with known exit status;
- observe `waitpid_loop`/`jobmgr_reap_pid`, ECHILD, `LASTEXITSTATUS`, spurious crash labels,
  zombie population, launchd survival/restart, CPU, panic/KASSERT, and service availability;
- include known-good observation controls and a known-bad detector fixture that must be rejected;
- bind raw serial/stdout/stderr/command/rc identities, ordered terminal grammar, manifest,
  final inventory, sync/shutdown, and one attempt/cell consumption boundary;
- classify only `PREMISE-CONFIRMED`, `PREMISE-NOT-OBSERVED`, `HARNESS-NOT-ACCEPTED`, or
  `INFRASTRUCTURE-NOT-ACCEPTED`.

Near-zero idle CPU does not rule out the managed-exit hot loop. “No crash” is not a complete
reaper verdict. This is a plan only; execute nothing.

## Q6 — ROLE-CORRECT NEXT CHAIN

Return a minimal dependency chain, with no op numbers allocated, separating:

1. Implementer-owned containment helper/product artifact build/disposable image stage;
2. Validator correctness gate for the returned implementation/stage contract;
3. Gatekeeper-owned corrected reaper premise;
4. Implementer reaper fix only if evidence warrants;
5. Gatekeeper post-fix regression if a fix lands;
6. Implementer-only productionization/root-rw/config stage; and
7. Gatekeeper PID-1 robustness plus final id-042 all-up evidence.

State whether legacy op-202/op-203/op-279/op-280 can be normalized in place or should be flushed
as mis-scoped and re-fetched. Do not issue, release, edit, or retire them.

## RETURN / VERDICT

Return exactly one:

- `PREP-READY-PID1-CONTRACT <base-path> <sha256>` — Q1-Q6 exact and no containment prerequisite;
- `PREP-NEEDS-CONTAINMENT-HELPER <exact contract>` — topology/image/runtime split exact, helper missing;
- `PREP-NEEDS-IMAGE-BASE <missing fact>`;
- `PREP-INCONCLUSIVE <missing fact>`; or
- `BLOCKED IDENTITY-DRIFT <fact>`.

Report note path/bytes/lines/SHA-256, input identities, Q1-Q6, selected image/base/BOM, complete
Explorer status, commit/parent, push=0, and unavailable reproduction.

Markers:

```text
EXPLORER_OP318_INPUT_IDENTITY
EXPLORER_OP318_PID1_TOPOLOGY
EXPLORER_OP318_IMAGE_BOM
EXPLORER_OP318_ACTIVATION_DELTA
EXPLORER_OP318_CONTAINMENT
EXPLORER_OP318_REAPER_PLAN
EXPLORER_OP318_ROLE_SPLIT
EXPLORER_OP318_TERMINAL
```

REPORT

```text
op: op-318
agent: rmx-explorer-rx-x64z
dispatch: zero-cell PID-1 preview contract preflight complete
next-hop: Arranger sizes the return L/XL and routes an independent Validator before any Implementer stage
```

## RELATIONS / FEEDBACK

op-200→op-201→op-318; op-315→op-317; held op-279→held op-280; held op-202→held op-203;
id-016/id-042; li-1006.

feedback: `agent_host_isolation`, `artifact_identity_needs_content_check`,
`verify_premise_before_mechanism`, `code_reasoned_verdict_is_hypothesis`,
`no_conflate_gating_with_readiness`, `launchd_no_autoscan`, `build_is_implementer`,
`soak_is_gatekeeper`, `op_state_dispatch_boundary`.
