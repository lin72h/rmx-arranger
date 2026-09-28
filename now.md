# Now

What matters this milestone, in order. Rewrite this page when the path changes; history lives in
Git and the journal. Op state comes from `tools/rob board`, problem state from `idq/id-000.md`.

## Milestone

**alpha2 regression** on the path to 1.0-preview (`li-1000`, `id-042`).

## Onboarding (in progress)

The Coordinator is onboarding each role repo directly (j-20260927-007): give it a template and
render its instructions and `OPS.md` (j-20260927-016/018), then relay an onboarding op.
Singletons keep one unnumbered repo with the template inside (`rmx-arranger/arranger0/`);
Validators use `rmx-validator0` plus numbered instances.

| Role | Repo | Status |
|---|---|---|
| Implementer | `rmx-implementer` (folder is `rmx-implementer1` for now) | onboarded; op-364 returned; rename back and `implementer0/` wait until op-368/op-369 return, so nothing moves under a review |
| Gatekeeper | `rmx-gatekeeper1` (here), `rmx-gatekeeper2` (only on mm4) | converted; op-370 and op-371 in flight. After op-371 returns: replace the `rmx-gatekeeper0` copy on mm4 (README changed) and drop the old `"remote"` key and mirror comment from gatekeeper2's `instance.json` there |
| Explorer | `rmx-explorer` (here and on mm4) | pending |
| Oracle | `rmx-oracle` | pending |
| Validators | `rmx-validator1` (GLM), `rmx-validator2` (DS4P), `rmx-validator3` | onboarded and calibrated (op-365, op-366, op-367 closed) |

Old folder names stay as symlinks while anything references them: `wip-gpt`, `wip-glm`, `wip-ds4p`,
`rmx-arranger1`. Until op-364 returns, the Implementer's real folder is `rmx-implementer1` and
`rmx-implementer` is the symlink; that swaps back afterwards.

mm4 is reached as `ssh mm4`: the SSH config pins 192.168.4.47 with `HostKeyAlias mm4`, so if
mm4's address changes only `HostName` needs updating. Resolving `mm4.local` from this host (mDNS)
is deferred (j-20260928-002).

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
id-037 (conformance pipeline), id-040/id-041 (asl/notifyd), id-012 (release image), id-044
(historical preflights: fix or retire).
