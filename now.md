# Now

What matters this milestone, in order. Rewrite this page when the path changes; history lives in
Git and the journal. Op state comes from `tools/rob board`, problem state from `idq/id-000.md`.

## Milestone

**alpha2 regression** on the path to 1.0-preview (`li-1000`, `id-042`).

## Onboarding (in progress)

The Coordinator is onboarding each role repo directly (j-20260927-007): rename to `rmx-<role>`,
rewrite its instructions for the current workflow, add its `OPS.md` op contract, then relay one
read-only onboarding op.

| Role | Repo | Status |
|---|---|---|
| Implementer | `rmx-implementer` (was `wip-gpt`) | onboarded (op-361 closed); op-362 closed; op-363 draft |
| Gatekeeper | `rmx-gatekeeper` | after the Implementer rounds |
| Explorer | `rmx-explorer` | pending |
| Oracle | `rmx-oracle` | pending |
| Validators | `wip-glm`, `wip-ds4p`, `rmx-validator3` | pending |

`../wip-gpt` stays a symlink to `rmx-implementer` until no repo references the old path.

## Critical path

Decisions in force: j-20260922-001 (cold build of the exact candidate, manual review, accepted
containment and staging, then a small regression slice; the generic preflight checker is off the
path). NFS/Kerberos: j-20260922-003 as revised by op-340 in chat. Kernel NFS options and NFS
modules are off, NFS userland stays dormant, Kerberos is at upstream defaults, and
OpenSSH/OpenSSL/ACLs are kept. Coordinator to confirm (j-20260927-010).

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
| 3 | Coordinator reviews the build and image evidence by hand | Coordinator | ready |
| 4 | Accepted containment, then staging of the op-358 image | Gatekeeper | waits on 3 |
| 5 | Boot: `mach.ko` loads and initializes, `task_self_trap` works; then the small regression slice (boot/base, Mach IPC, dispatch/workqueue) | Gatekeeper | waits on 4 |

## Off the path (backlog, not live)

Open problems stay in their IDQ files: id-011 (asl leg 4), id-016 (PID-1 launchd; op-322's
staging/reaper contract still needs Validator review), id-021 (libxpc lifecycle), id-033/id-034/
id-037 (conformance pipeline), id-040/id-041 (asl/notifyd), id-012 (release image).
