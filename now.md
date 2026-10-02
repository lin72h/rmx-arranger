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

## Next: the Mach foundation round (Coordinator, 2026-09-29)

Every component depends on Mach, so upper components (libdispatch, libnotify, launchd, libxpc)
wait until the Mach foundation is fixed and re-reviewed. In order:
1. Fix the id-046 findings, each with an in-tree regression test that fails before the fix.
   **Batch 1 done (2026-10-02):** 13 fixes plus follow-ups, 27/27 proven before and after (op-418),
   `mach-fixes-1` on origin. **Batch 2 done (2026-10-02):** op-394 step 2, proven 4/4 plus 27/27
   (op-424), `mach-fixes-2` on origin. Batch 3 (step 3, lifetimes) is op-427.
   Design classes A (port names as fds) and B (Mach state on reused proc/thread slots) are
   decided before point fixes land in those areas (kernel-reviews.md).
2. Consistent automated checking (CI), built and run by the Gatekeeper and read by the Validators: the candidate built with
   `mach.ko` under its kernel's configuration, booted contained, and the Mach regression suite run
   every time (id-047 starts here).
   **Instrumentation 1.0** (Coordinator, 2026-10-01) starts now: sanitizers and post-mortem debugging
   (id-047, id-053, id-048), then DTrace (2.0, id-054) and hwpmc (3.0, id-055). Plan:
   [instrumentation-strategy.md](instrumentation-strategy.md). op-396 (drafted) builds `mach.ko` with its kernel
   and the sanitizer profiles from alpha2. It needs the Implementer, as op-395 does, so the
   Coordinator picks the order. The Gatekeeper's survey run follows op-398 (op-391's redo).
   Design (2026-10-02): keep fd-backed port names for 1.0 and do op-394 steps 2-4; step 5 (XNU
   name table) is deferred, see [mach-names-step5-deferred.md](mach-names-step5-deferred.md).
3. Round 2 of the Mach review (id-051, id-052): two blind reviewers on different models.
The pre-fix baseline of launchd's reaper (read its results with N1 in mind) continues as op-398. op-391 stopped before staging because its own classifier did not compile (dropped 2026-10-01).
4. Then the upper components. op-387 (libdispatch) was dropped because its pin will be stale; it
   will be re-drafted against the fixed candidate. op-384, op-385 and op-386 are on hold.

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
| 4 | Containment helper `rmx-stage-image` and the disposable PID-1 premise image on alpha2 (base: the op-364 image; launchd identity accepted) | Implementer | closed: op-388 (image `031885…`, 28 BOM rows, host inventories equal); op-390 validator2 CLOSE 9/10 |
| 5 | The corrected reaper premise: harness and Tier-2 classifier controls, a workload overlay on a copy of the premise image, then one cell | Gatekeeper | closed 2026-10-03: op-429 **PREMISE-NOT-OBSERVED** (bounded to this cell); op-431 and op-432 both 9/10; Arbiter accepted two recorded deviations (j-20261003-008) |
| 6 | op-280 stays held (premise not observed, no fix); next op-436 (supersedes op-202) productionization (non-`-u` PID-1, root read-write, getty, base services, the SIGUSR1-halt risk recorded) and the op-203 robustness soak | Implementer, then Gatekeeper | op-436 drafted 2026-10-03; Gatekeeper acceptance and op-203 soak follow |

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

## Swift integration (restarted 2026-10-02)

Swift on rmxOS's real libdispatch, one copy per process: [swift-real-libdispatch.md](swift-real-libdispatch.md)
(id-058). Starts after the Mach batch-1 proof.

## In parallel

Advisor review round (Coordinator, 2026-09-28): the goal is a correct architecture, with defects
as its evidence. One seat, in sequence (Advisors are expensive).
advisor2: op-383 (Mach consult; closed) → op-389 (Mach deep dive; closed, 14 confirmed defects →
id-046) → op-387 (libdispatch and workqueue deep dive, same form; drafted) → op-384 (libnotify) →
op-385 (launchd). advisor4 runs op-386 (libxpc against macOS 27) on mm4 when chosen. Findings bind
to IDQ entries before any follow-on op. id-046's fix batch (Implementer) awaits the Coordinator.
Kernel review rounds and the plan for round 2: [kernel-reviews.md](kernel-reviews.md) (id-051).

## Off the path (backlog, not live)

Open problems stay in their IDQ files: id-011 (asl leg 4), id-021 (libxpc lifecycle), id-033/id-034/
id-037 (conformance pipeline), id-040/id-041 (asl/notifyd), id-012 (release image), id-044
(historical preflights: fix or retire), id-045 (`mach.ko` leak-locals dependency).
