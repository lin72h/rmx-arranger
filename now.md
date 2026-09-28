# Now

What matters this milestone, in order. Rewrite this page when the path changes; history lives in
Git and the journal. Op state comes from `tools/rob board`, problem state from `idq/id-000.md`.

## Milestone

**PID-1 launchd** on the path to 1.0-preview (`li-1000`, `id-042`, `id-016`), chosen by the
Coordinator on 2026-09-28 after the alpha2 regression milestone closed (op-372, j-20260928-024).
The candidate is alpha2 `2884304b` and its op-364 image, which boots contained with the Mach and
dispatch slice passing.

## Onboarding (in progress)

The Coordinator is onboarding each role repo directly (j-20260927-007): give it a template and
render its instructions and `OPS.md` (j-20260927-016/018), then relay an onboarding op.
Singletons keep one unnumbered repo with the template inside (`rmx-arranger/arranger0/`);
Validators use `rmx-validator0` plus numbered instances.

| Role | Repo | Status |
|---|---|---|
| Implementer | `rmx-implementer` (template in `implementer0/`) | onboarded and converted (NOTICE relayed) |
| Gatekeeper | `rmx-gatekeeper1` (here), `rmx-gatekeeper2` (only on mm4) | both onboarded (op-370, op-371 closed) |
| Explorer | `rmx-explorer1` (here), `rmx-explorer2` (only on mm4) | both onboarded (op-373, op-374 closed) |
| Advisor (was Oracle) | `rmx-advisor1`–`3` (here), `rmx-advisor4` (only on mm4) | converted; instances stay local Git, template on GitHub (`lin72h/rmx-advisor0`); onboarding folds into each seat's first consult |
| Validators | `rmx-validator1` (GLM), `rmx-validator2` (DS4P), `rmx-validator3` | onboarded and calibrated (op-365, op-366, op-367 closed) |

Old folder names stay as symlinks while anything references them: `wip-gpt` (also named by
gatekeeper1's op360 runner and the id-044 preflights), `wip-glm`, `wip-ds4p`, `rmx-arranger1`,
`rmx-gatekeeper`, `rmx-explorer` (here and on mm4), `rmx-implementer1`, `rmx-oracle`,
`rmx-oracle2`, `rmx-oracle3`, and `mach-oracle` on mm4.

mm4 is reached as `ssh mm4`: the SSH config pins 192.168.4.47 with `HostKeyAlias mm4`, so if
mm4's address changes only `HostName` needs updating. Resolving `mm4.local` from this host (mDNS)
is deferred (j-20260928-002).

## Critical path

Decisions in force: j-20260922-001 (cold build of the exact candidate, manual review, accepted
containment and staging, then a small regression slice); NFS/Kerberos per op-340
(j-20260927-014); preview needs non-`-u` PID-1 launchd (Coordinator, 2026-07-12, id-042). alpha2
`2884304b` is on the public rmxOS origin. The contract to validate is op-318 as corrected by op-322
(both notes in `rmx-explorer1/findings/nx-r64z/`), written at `alpha@26655e67`, which alpha2 contains.

| # | Step | Owner | Status |
|---|---|---|---|
| 1 | Re-base the op-318/op-322 contract onto alpha2: under it, only `kern_exit.c` (stable/15 zombie-reference and pdwait changes) and 26 `libexec/rc` files changed | Explorer (explorer1) | closed: op-377, NEEDS-AMENDMENT with three exact amendments |
| 2 | Review the corrected contract: the staging and containment package (C1–C3) and the reaper package (C4–C7) | both Validators (critical path) | closed: reviews split (validator1 CLOSE 9.5, validator2 REMEDIATE 9); Arbiter REMEDIATE; op-380 corrected the BOM (BOM-CORRECTED, verified first-hand) |
| 3 | Decide the launchd service-plane bar: MachServices plus nvlist, or literal dormant `xpc_domain` | Coordinator | decided 2026-09-28: MachServices plus nvlist for the preview; `xpc_domain` deferred past it (li-008) |
| 4 | Containment helper `rmx-stage-image` and the disposable PID-1 premise image on alpha2 (base: the op-364 image; launchd identity accepted) | Implementer | op-382 issued (re-issue of op-381, which stopped correctly at the distinct-device check) with workspace `/Users/me/wip-mach/stage`; then one Validator gates the helper and BOM (op-318 chain step 2) |
| 5 | The cell runner, then the corrected reaper premise (op-279, normalized) on op-381's image | Gatekeeper | waits on 4 and its Validator gate |
| 6 | op-280's fix only if the premise is CONFIRMED; then op-202 productionization (non-`-u` PID-1, root read-write, getty, base services, the SIGUSR1-halt risk recorded) and the op-203 robustness soak | Implementer, then Gatekeeper | waits on 5 and 3 |

The alpha2 regression milestone closed on 2026-09-28: op-364 built the image, and op-372 booted it
contained (`mach.ko` loads with leak-locals 1; Mach 4/4, dispatch 4/4; clean power-off; TWQ
attribution untested; not release-wide). Detail: the journal (j-20260928-007 to -024) and id-045
(`mach.ko`'s leak-locals dependency).

Guest runs use gatekeeper1's maintained runner `build/op360/run-op360-alignment-r1.sh`,
parameterized per op (op-372's `build/op372/config.sh`): 2 vCPUs, 4 GiB, one virtio disk, serial
console, and no network, shares, or passthrough. `vmm.ko` is loaded on this host (`bdw-fx15-x64z`,
the rx-x64z seat). Image staging uses the ZFS dataset `zroot/wip-mach-stage` at
`/Users/me/wip-mach/stage` (64 GB quota, owned by `me`), a device distinct from `/` as the PID-1
contract requires (j-20260928-035).

## In parallel

Advisor review round (Coordinator, 2026-09-28), which is also each seat's onboarding: does July's
status hold at alpha2, and what are the top preview risks? op-383 advisor1 (Mach IPC and libdispatch),
op-384 advisor2 (libnotify and notifyd), op-385 advisor3 (launchd service hosting), and op-386
advisor4 on mm4 (libxpc against macOS 27). Read-only; findings bind to IDQ entries before any
follow-on op.

## Off the path (backlog, not live)

Open problems stay in their IDQ files: id-011 (asl leg 4), id-021 (libxpc lifecycle), id-033/id-034/
id-037 (conformance pipeline), id-040/id-041 (asl/notifyd), id-012 (release image), id-044
(historical preflights: fix or retire), id-045 (`mach.ko` leak-locals dependency).
