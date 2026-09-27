# op-005m — META: Gatekeeper host/guest isolation guard and fresh-context resumption preflight

op-005m | lane: **META / SAFETY CONTROL — does not consume a project ROB number** | role:
**Gatekeeper Ruler** | EXU: **a fresh `rmx-gatekeeper-rx-x64z` session, not session
`d8a8cfa4-7056-40f6-a655-79c1ce56cb3c`** | state: **[Flushed — returned BLOCKED WRONG-CONTEXT
from the explicitly quarantined session; correct fail-closed stop before any write/test/privilege/
runtime/guest action; first-hand no-write verification passed; reissued as op-006m for a genuinely
fresh Gatekeeper session]** | parent:
**host/guest isolation incident 2026-07-11 / op-235 / block-071 / op-306** | authored:
**2026-07-11 by Arranger2 at Coordinator request**

## RETURN / ARRANGER ADJUDICATION — 2026-07-11

The Coordinator relay landed in quarantined session
`d8a8cfa4-7056-40f6-a655-79c1ce56cb3c`. Gatekeeper acknowledged all three incidents and returned
`BLOCKED WRONG-CONTEXT` exactly as commissioned, without editing its own controls.

Arranger2 reproduced first-hand:

- Gatekeeper remains `main@0ee8758062791c0063bca6f3dae086e674bec0aa`, parent `9a9e4cd`,
  `origin/main@4b16fd1`, ahead 39;
- tracked diff is empty and the preserved untracked census remains 47 paths;
- `AGENTS.md` remains SHA-256
  `485cb58600689bc045eb230becd4d67e08d56b192e9de62fa018aff3bc32f438`; and
- all four new deliverable paths are absent: the protocol doc, guard module, Mix task, and test.

This is a successful fail-closed control but no primary deliverable, so op-005m is `[Flushed]`, not
`[Done]`. The work is reissued under next meta-control ID op-006m; IDs are not reused. The old
session remains quarantined and containment remains active.

## AUTHORITY / EFFECT

The Coordinator requested a Gatekeeper meta-op to prevent recurrence. This card establishes the
fresh-context safety-control work. It does **not** authorize a guest cell, privilege, staging,
target execution, `dlopen`, image mutation, push, or resumption of ordinary Gatekeeper ops.

The old Gatekeeper session is quarantined read-only. Do not resume it, clean it, amend its commits,
or overwrite its untracked op-306 artifacts. Start this op only in a new Gatekeeper session and
report the new session identifier before any write.

## DISPATCH BOUNDARY

DISPATCHED by the Coordinator on 2026-07-11. Execute only in the fresh Gatekeeper session.

Write only `/Users/me/wip-mach/rmx-gatekeeper/`. Read the Arranger incident and activation records
below read-only. The product, Arranger, Explorer, Oracle, Validator, host configuration, guest
images, mountpoints, and every other repository are read-only:

- `/Users/me/wip-mach/rmx-arranger/doc/host-guest-isolation-incident-2026-07-11.md`
- `/Users/me/wip-mach/rmx-arranger/doc/activation/op-235-activation.md`
- `/Users/me/wip-mach/rmx-arranger/doc/activation/op-306-activation.md`
- `/Users/me/wip-mach/rmx-arranger/doc/activation/op-310-activation.md`

Before editing, record the fresh session ID, `pwd`, branch/HEAD/origin, and full repository status.
Require `pwd=/Users/me/wip-mach/rmx-gatekeeper`. Preserve every pre-existing tracked/untracked
artifact. Stop `BLOCKED WRONG-CONTEXT` if the session ID is the quarantined one or the writable root
is not exact.

## REQUIRED BASE / INPUT IDENTITIES

Gatekeeper repository at authoring:

- branch/HEAD: `main@0ee8758062791c0063bca6f3dae086e674bec0aa`;
- parent: `9a9e4cd852e9b8835b3662a8a37fe13e985a0818`;
- `origin/main@4b16fd1b65e76cfcdb40de96069e13d3d702e3cf`, 39 commits behind HEAD;
- tracked tree clean; large historical untracked evidence set present; and
- pre-edit `AGENTS.md` SHA-256:
  `485cb58600689bc045eb230becd4d67e08d56b192e9de62fa018aff3bc32f438`.

Arranger inputs at authoring:

| path | SHA-256 |
|---|---|
| `doc/host-guest-isolation-incident-2026-07-11.md` | `9c8764a452133ff36634b8fe50a44387ff120972ffaf6a26d60e69658092e8cc` |
| `doc/activation/op-235-activation.md` | `cc9f0cec7dfb14114def70f443db8fbe7ba477fae869339960bd614d31e85984` |
| `doc/activation/op-306-activation.md` | `f9cd2124064c418802a58e3dc44f43b074f6c6053626cce3299bd81d3bbef4b2` |
| `doc/activation/op-310-activation.md` | `0caaa745dff3fea2506cd4cea26838aef25f4597ac6933213c27b74c422a5494` |

Stop on Gatekeeper tracked drift, wrong HEAD, or input-identity mismatch. Do not clean, reset,
stash, amend, or absorb drift. A later explicit Arranger amendment may repin these identities.

## CONFIRMED INCIDENT PREMISES

Treat these as confirmed control facts, not hypotheses:

1. op-235 expanded an unset guest-root variable across nested quotes, wrote the physical host's
   `/etc/rc.local`, and its harness induced five physical-host power-offs.
2. historical Explorer block-071 repeated the same quote/empty-root class and appended to physical
   host `/etc/rc.conf` twice.
3. op-306's nominally host-only `dlopen` loaded libmach and executed its `mach_init` constructor on
   the physical host twice. Static inspection is not equivalent to loading or execution.

## PERMANENT HARD STOPS

Add these as current Gatekeeper operating doctrine. They apply to every future activation unless
the Coordinator issues a more restrictive explicit amendment; an ordinary op may not waive them.

1. Never issue `doas sh -c`, `sudo sh -c`, a privileged heredoc, privileged redirection, or
   privileged `tee`. Never pass a constructed command string to a privileged shell.
2. Never interpolate a destination through nested quote boundaries. Source, guest root, and
   relative destination must remain separate argv values through the final installer invocation.
3. Never use an unset/empty guest-root value. Shell glue, if unavoidable, must begin with
   `${guest_root:?}` and still pass the guarded helper below; that expansion alone is not proof.
4. Never write directly to physical-host `/etc`, `/boot`, `/var`, `/usr/local`, `/root`, or module
   paths from a guest-staging activation.
5. Never run an rmxOS target-linked executable, `dlopen` an rmxOS library, preload target stubs, or
   load a target module on the physical host. `readelf`, `nm`, `objdump`, hashing, and source reads
   are static inspection; executable probes and library loads are runtime execution.
6. Target runtime requires a separately authorized disposable bhyve cell with exact image/BOM,
   attempt accounting, and serial capture. Never silently replace a forbidden host run with bhyve.
7. Any guard failure, host-integrity delta, ambiguous mount/device identity, or unexpected
   privilege request is a hard stop. Preserve facts and report; do not repair or retry in-band.

## DELIVERABLE A — DURABLE GATEKEEPER DOCTRINE

In the Gatekeeper-owned repository only:

1. Add a concise mandatory `Host/Guest Isolation` section to `AGENTS.md` that links to the detailed
   protocol below and states the hard stops, fresh-context rule, and no-op-waiver rule.
2. Create `docs/host-guest-isolation.md` with the complete procedure, incident-class examples,
   static-versus-runtime classification, guarded staging sequence, negative controls, tripwire,
   evidence record, and stop/report rules.
3. Do not copy sensitive authentication logs or full agent transcripts. Cite the Arranger incident
   record and its content identities.

## DELIVERABLE B — GUARDED STAGING HELPER

Author the following Gatekeeper-owned paths:

- `lib/rmx_os_oracle/guest_stage_guard.ex`
- `lib/mix/tasks/oracle.guest.stage.ex`
- `test/rmx_os_oracle/guest_stage_guard_test.exs`

The Mix task must accept separate, mandatory arguments equivalent to:

```text
mix oracle.guest.stage \
  --source <owned-repo-file> \
  --guest-root <mounted-root> \
  --relative-dest <path-beneath-root> \
  --expected-device <exact-/dev/md...partition> \
  --sentinel <relative-sentinel-path> \
  --sentinel-sha256 <expected-digest> \
  --evidence-out <owned-repo-json-path> \
  --check-only | --apply
```

Do not invoke a shell for validation or installation. External commands must be fixed executables
with separate argv arrays. `--apply` may call only one reviewed explicit-path installer path after
all guards pass; it must never call `sh`, `tee`, or a redirection. This op may author and unit-test
the `--apply` code with a fake command adapter, but must **not execute `--apply`**, acquire privilege,
mount, or touch a guest/host destination.

Before any privilege request, the helper must prove all of the following:

1. source is a regular nonsymlink file under canonical
   `/Users/me/wip-mach/rmx-gatekeeper/`, with size and SHA-256 captured;
2. guest root is supplied, canonical, nonempty, not `/`, not `/etc`, not `/boot`, not a host-system
   prefix, and is beneath an activation-approved workspace path;
3. guest root is the exact active mountpoint, not merely a directory beneath one;
4. the mounted source equals `--expected-device`, matches the approved `/dev/md...` partition
   pattern, and its filesystem/device identity differs from physical-host `/`;
5. the commissioned sentinel exists beneath that root, is nonsymlink, and matches the exact
   expected digest/image/BOM identity;
6. relative destination is nonempty and relative, contains no `..`, canonicalizes beneath the
   guest root, and neither it nor an existing parent escapes through a symlink;
7. a pre-stage host-integrity inventory has been captured for `/etc/rc.conf`, `/etc/rc.local`,
   `/etc/rc.d`, `/boot/loader.conf`, and `/boot/modules`; missing paths are explicit states; and
8. the exact fixed installer executable plus argv, source digest, canonical destination, mount,
   device, sentinel, and tripwire digest are frozen in the evidence record.

After a successful future `--apply`, before returning success, the helper must prove the installed
guest file digest/mode and recompute the host tripwire. Any host delta is
`HOST-INTEGRITY-INCIDENT`, never PASS. Evidence JSON must be written atomically inside the
Gatekeeper repo and record real command rc/stdout/stderr digests without rewriting failure to zero.

## REQUIRED FAIL-CLOSED CONTROLS

Unit tests must use temporary unprivileged fixtures and a fake mount/stat/installer adapter. They
must prove that the installer/privilege adapter is called **zero times** for each rejection:

- guest root missing, unset, empty, `/`, `/etc`, `/boot`, or another host-system prefix;
- nonexistent, stale, or non-mountpoint root;
- root on the physical-host filesystem/device;
- wrong, malformed, or unexpected `/dev/md...` source;
- missing, symlinked, or wrong-digest sentinel;
- absolute, empty, `..`-escaping, or symlink-escaping destination;
- source outside the Gatekeeper repo, source symlink, or source mutation after hashing;
- argv containing whitespace, quotes, glob characters, semicolons, `$()`, or newlines (prove it is
  handled as data or rejected, never interpreted);
- preflight-to-apply mount/device/sentinel change; and
- any host-tripwire change.

Include one fully synthetic accepted check-only fixture and one fake-adapter apply fixture proving
the installer receives exact separate argv. Synthetic acceptance is helper evidence only; it is
not guest/product evidence and does not lift containment.

Run only unprivileged checks:

```text
mix format --check-formatted \
  lib/rmx_os_oracle/guest_stage_guard.ex \
  lib/mix/tasks/oracle.guest.stage.ex \
  test/rmx_os_oracle/guest_stage_guard_test.exs
mix test test/rmx_os_oracle/guest_stage_guard_test.exs
mix test
git diff --check
```

Record exact commands, real rc values, test counts, and the pre-existing full-suite failure set.
Do not call a failing or excluded suite green.

## COMMIT / PRESERVATION

Create one focused local commit containing only the five commissioned paths:

- `AGENTS.md`
- `docs/host-guest-isolation.md`
- `lib/rmx_os_oracle/guest_stage_guard.ex`
- `lib/mix/tasks/oracle.guest.stage.ex`
- `test/rmx_os_oracle/guest_stage_guard_test.exs`

Stage by explicit path. Do not use `git add -A`; do not amend/rebase; do not push. Preserve all
historical untracked files, especially `build/op306/` binaries and incident-related logs/images.

## RETURN / HOLD SEMANTICS

Return exactly one:

- `CONTROL-DRAFT-READY <commit>` — doctrine and helper draft complete, all unprivileged controls
  pass; **Gatekeeper execution hold remains active pending independent validation and explicit
  Coordinator release**;
- `CONTROL-NOT-ACCEPTED <reason> <commit-or-none>`; or
- `BLOCKED <reason>`.

Do not return `RESUMED`, `SAFE`, or `HOLD-LIFTED`. This meta-op cannot make those decisions.

## REPORT

```text
REPORT
op:                    op-005m
session:               <fresh session id>
repo / branch / head:  <exact>
prior session avoided: yes|no
incident ack:          op-235=yes block-071=yes op-306=yes
doctrine paths:        <identities>
guard paths:           <identities>
negative controls:     <count/pass/fail; privilege-adapter calls>
targeted / full tests: <real counts and rc>
privilege calls:       0 required
host runtime:          0 required
guest cells:           0 required
commit / parent:       <exact>
full status:           <tracked and untracked summary>
verdict:               CONTROL-DRAFT-READY|CONTROL-NOT-ACCEPTED|BLOCKED
next-hop:              independent Validator review; Coordinator alone may lift hold
```

## MARKERS

```text
GK_OP005M_FRESH_CONTEXT
GK_OP005M_INCIDENT_ACK
GK_OP005M_DOCTRINE
GK_OP005M_GUARD
GK_OP005M_NEGATIVE_CONTROLS
GK_OP005M_NO_PRIVILEGE
GK_OP005M_NO_HOST_RUNTIME
GK_OP005M_COMMIT
GK_OP005M_TERMINAL
```

## RELATIONS

`doc/host-guest-isolation-incident-2026-07-11.md`; op-235 historical correction; op-306 host-runtime
correction; op-310 static-only gate. This is a safety-control prerequisite for all future
Gatekeeper privileged/staging/runtime/guest work, including op-289, op-305, and op-308.
feedback: `agent_host_isolation`, `op_state_dispatch_boundary`, `background_exit_code_hygiene`,
`artifact_identity_needs_content_check`, `no_conflate_gating_with_readiness`.
