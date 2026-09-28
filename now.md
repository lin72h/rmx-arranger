# Now

What matters this milestone, in order. Rewrite this page when the path changes; history lives in
Git and the journal. Op state comes from `tools/rob board`, problem state from `idq/id-000.md`.

## Milestone

**alpha2 regression** on the path to 1.0-preview (`li-1000`, `id-042`).

## Onboarding (in progress)

The Coordinator is onboarding each role repo directly (j-20260927-007): make it an instance
`rmx-<role>N` of a template `rmx-<role>0` (j-20260927-016), render its instructions and `OPS.md`,
then relay a NOTICE or an onboarding op. Templates so far: `rmx-role0`, `rmx-arranger0`,
`rmx-validator0`.

| Role | Repo | Status |
|---|---|---|
| Implementer | `rmx-implementer1` (was `wip-gpt`, `rmx-implementer`) | onboarded; op-364 in flight; `rmx-implementer0` conversion waits for its REPORT |
| Gatekeeper | `rmx-gatekeeper` | next |
| Explorer | `rmx-explorer` | pending |
| Oracle | `rmx-oracle` | pending |
| Validators | `rmx-validator1` (GLM), `rmx-validator2` (DS4P), `rmx-validator3` | instances of `rmx-validator0`; NOTICEs to relay |

Old folder names (`wip-gpt`, `rmx-implementer`, `wip-glm`, `wip-ds4p`, `rmx-arranger`) stay as symlinks while
anything still references them.

## Critical path

Decisions in force: j-20260922-001 (cold build of the exact candidate, manual review, accepted
containment and staging, then a small regression slice; the generic preflight checker is off the
path). NFS/Kerberos: op-340's policy, confirmed by the Coordinator (j-20260927-014). Kernel NFS options
and NFS modules are off, NFS userland stays dormant, Kerberos is at upstream defaults, and
OpenSSH/OpenSSL/ACLs are kept. Branch `alpha2` exists only locally (not on rmxOS origin or the
backup remote); whether to push it is open.

Baseline (op-361, verified): the deliverable is the op-358 image, an 8 GiB UFS root and raw GPT
image built from the alpha2 candidate (`15c185c0` plus three uncommitted profile paths), with
the op-343 kernel and `mach.ko` loaded at boot by `loader.conf`. Composition succeeded (makefs
and mkimg rc 0; extracted partition byte-for-byte equal). Image hashes re-verified first-hand (j-20260927-011). It has never been mounted or booted.
`mach.ko` compatibility is static only, and module and kernel toolchains differ (clang 19.1.7 vs
clang/LLD 21.1.8).

| # | Step | Owner | Status |
|---|---|---|---|
| 1 | Re-establish the baseline from disk | Implementer (op-361) | closed |
| 2 | Index the op-335…op-358 build chain for review | Implementer (op-362) | closed: `rmx-implementer/docs/alpha2-build-chain.md` |
| 3 | Coordinator reviews the build and image evidence | Coordinator | done: decisions in j-20260927-014 |
| 4 | Commit the profile on alpha2; rebuild `mach.ko` with the kernel toolchain; compose a new image | Implementer (op-364) | in flight: alpha2 `2884304b`; `build/op364-20260928T001637Z` |
| 5 | Review op-364 | both Validators (release critical path) | waits on 4 |
| 6 | Accepted containment, then staging of the op-364 image | Gatekeeper | waits on 5 |
| 7 | Boot: `mach.ko` loads and initializes, `task_self_trap` works; then the small regression slice (boot/base, Mach IPC, dispatch/workqueue) | Gatekeeper | waits on 6 |

## Off the path (backlog, not live)

Open problems stay in their IDQ files: id-011 (asl leg 4), id-016 (PID-1 launchd; op-322's
staging/reaper contract still needs Validator review), id-021 (libxpc lifecycle), id-033/id-034/
id-037 (conformance pipeline), id-040/id-041 (asl/notifyd), id-012 (release image).
