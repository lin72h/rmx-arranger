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
| Implementer | `rmx-implementer` (folder is `rmx-implementer1` for now) | onboarded; op-364 closed; rename back and `implementer0/` wait until op-372 returns, so nothing moves under a run |
| Gatekeeper | `rmx-gatekeeper1` (here), `rmx-gatekeeper2` (only on mm4) | both onboarded (op-370, op-371 closed) |
| Explorer | `rmx-explorer1` (here), `rmx-explorer2` (only on mm4) | both onboarded (op-373, op-374 closed) |
| Advisor (was Oracle) | `rmx-advisor1`–`3` (here), `rmx-advisor4` (only on mm4) | converted (local Git); remotes and onboarding next |
| Validators | `rmx-validator1` (GLM), `rmx-validator2` (DS4P), `rmx-validator3` | onboarded and calibrated (op-365, op-366, op-367 closed) |

Old folder names stay as symlinks while anything references them: `wip-gpt` (also named by
gatekeeper1's op360 runner and the id-044 preflights), `wip-glm`, `wip-ds4p`, `rmx-arranger1`,
`rmx-gatekeeper`, `rmx-explorer` (here and on mm4), and `mach-oracle` on mm4.
Until op-372 returns (it reads the image from `rmx-implementer/build/`), the Implementer's real
folder is `rmx-implementer1` and `rmx-implementer` is the symlink; that swaps back afterwards.

mm4 is reached as `ssh mm4`: the SSH config pins 192.168.4.47 with `HostKeyAlias mm4`, so if
mm4's address changes only `HostName` needs updating. Resolving `mm4.local` from this host (mDNS)
is deferred (j-20260928-002).

## Critical path

Decisions in force: j-20260922-001 (cold build of the exact candidate, manual review, accepted
containment and staging, then a small regression slice; the generic preflight checker is off the
path). NFS/Kerberos: op-340's policy, confirmed by the Coordinator (j-20260927-014). Kernel NFS options
and NFS modules are off, NFS userland stays dormant, Kerberos is at upstream defaults, and
OpenSSH/OpenSSL/ACLs are kept. Branch `alpha2` is on the public rmxOS origin at `2884304b`
(pushed 2026-09-28 by Coordinator decision).

Baseline (op-361, verified): the deliverable is the op-358 image, an 8 GiB UFS root and raw GPT
image built from the alpha2 candidate (`15c185c0` plus three uncommitted profile paths), with
the op-343 kernel and `mach.ko` loaded at boot by `loader.conf`. Composition succeeded (makefs
and mkimg rc 0; extracted partition byte-for-byte equal). Image hashes re-verified first-hand (j-20260927-011). Correction (op-370, verified first-hand): the image *was* booted. The Gatekeeper's op359 and
op360 ran it on 2026-09-25, and op360's third attempt loaded `mach.ko`, passed the bounded Mach
(4/4) and dispatch (4/4) probes, and shut down cleanly. TWQ attribution was untested, and this is
not release-wide acceptance. That `mach.ko` was built with clang 19.1.7 against the clang/LLD
21.1.8 kernel; op-364 rebuilt it with the kernel's toolchain.

| # | Step | Owner | Status |
|---|---|---|---|
| 1 | Re-establish the baseline from disk | Implementer (op-361) | closed |
| 2 | Index the op-335…op-358 build chain for review | Implementer (op-362) | closed: `rmx-implementer/docs/alpha2-build-chain.md` |
| 3 | Coordinator reviews the build and image evidence | Coordinator | done: decisions in j-20260927-014 |
| 4 | Commit the profile on alpha2; rebuild `mach.ko` with the kernel toolchain; compose a new image | Implementer (op-364) | closed: alpha2 `2884304b` on origin; `build/op364-20260928T001637Z`; GPT image `8f546a93…` |
| 5 | Review op-364 | both Validators (release critical path) | closed: both CLOSE, validator1 9.5 (op-368), validator2 9 (op-369) |
| 6 | Accepted containment, then staging of the op-364 image | Gatekeeper | op-372 (bundled with step 7): issued |
| 7 | Boot: `mach.ko` loads and initializes, `task_self_trap` works; then the small regression slice (boot/base, Mach IPC, dispatch/workqueue) | Gatekeeper | op-372 |

Carry into the boot test (op-369): `mach.ko` needs the kernel's LOCAL `knote_enqueue`, which
resolves only through leak-locals (`debug.link_elf_leak_locals=1`, the default) and the symbol
table the loader passes. op360 already saw the op-358 module, which has the same dependency, load
at boot on this kernel and loader. The op-364 boot must still record it; a failure reads
`symbol knote_enqueue undefined`.

For steps 6–7 (op-370): reuse gatekeeper1's op360 runner (`build/op360/run-op360-r2.sh` with its
Expect plan). It pins the op-358 image through `wip-gpt` paths, so a run brief must re-pin it to
op-364's image (`8f546a93…`). It enforces 2 vCPUs, 4 GiB, one virtio disk, serial console, no
network, shares, or passthrough, and a fresh verified disk copy per attempt. No formal containment
disposition exists (op345 recorded the approved `vmm` load), and `vmm` is not loaded now, so a run
needs authority to load it. The host is `bdw-fx15-x64z` (the rx-x64z seat).

## Off the path (backlog, not live)

Open problems stay in their IDQ files: id-011 (asl leg 4), id-016 (PID-1 launchd; op-322's
staging/reaper contract still needs Validator review), id-021 (libxpc lifecycle), id-033/id-034/
id-037 (conformance pipeline), id-040/id-041 (asl/notifyd), id-012 (release image), id-044
(historical preflights: fix or retire).
