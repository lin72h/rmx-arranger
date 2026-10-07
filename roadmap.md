# roadmap — rmxOS to a usable 1.0

- tier: **L1i**, the most abstract tier of the work hierarchy (milestones `li-NNNN` → problems
  `id-NNN` in [idq/id-000.md](idq/id-000.md) → ops `op-NNN` via `tools/rob`;
  [terminology.md](terminology.md) §6). This page says what 1.0 means and the order we get there;
  [now.md](now.md) holds the critical path of the moment.
- status: living, rewritten 2026-10-05 (the June–July text is in Git at `cc7efa3`). The
  Coordinator owns the target; the Arranger keeps the page current.
- discipline: **truly-green, not paper-green.** A milestone retires only on first-hand evidence that
  its criterion holds, never on an agent's report.

## The target

| level | definition | when |
|---|---|---|
| developer-usable | build and run Darwin-style programs against Mach, dispatch and notify on FreeBSD 15 | a waypoint inside the preview |
| **1.0-preview** (milestone 1, [li-1000](l1i/li-1000.md)) | the four core services **launchd, libnotify, asl, libxpc** truly-green on **libdispatch and Mach IPC**, launchd as **PID 1** hosting them, holding under an integration soak | **current target** |
| service-usable 1.0 | the preview plus breadth, conformance to macOS on the exercised surface, gaps named | after the preview |
| self-hosting / GPU | building rmxOS on rmxOS; the memory_object → IOKit-style GPU arc | long arc, not 1.0 |

Decisions that shape the preview (Coordinator):
- Four core services, nvlist serialization locked (2026-06-24); the gate is all four truly-green
  with launchd driving them (2026-06-25).
- launchd is the real PID 1, not a `-u` daemon (2026-07-12); service plane is MachServices plus
  nvlist, `xpc_domain` deferred (2026-09-28).
- "Preview" is a label, not permission to ship thin: the target is stable and usable, solid enough
  to develop on day to day (2026-06-25).
- Speed comes from cutting scope, not quality: a macOS divergence is cataloged as a known gap
  rather than closed with a risky change (li-1011).
- Every component depends on Mach, so the Mach foundation is fixed and re-reviewed before the
  upper components (2026-09-29). Match macOS where it is cheap; keep 1.0 stable.
- New images, test images included, are ZFS-root (2026-10-03, 2026-10-05).

Usable is a threshold, not a guarantee: no known blocking defect on the target use cases, with the
remaining gaps named and bounded. We certify the surface we exercise.

## Path to the preview (2026-10-05)

| Stage | Status |
|---|---|
| Mach foundation, fix batches 1-3 (id-046) | done (`mach-fixes-1` to `-3` on origin) |
| Step 4 part 1: kernel reply and receive contract | done (`mach-fixes-4@0924690c`) |
| Step 4 part 2a: libdispatch adaptation, libmach `mach_msg_destroy` fix | done (`mach-fixes-5@b2d5f5b7`) |
| Step 4 part 2b: launchd adaptation (op-484, op-495) | done (`mach-fixes-5@0f1f76d5`) |
| Step 4 part 2c: libxpc adaptation | next |
| id-046: readiness-only Mach kevents with public KNOTE; launchd's two task setters on a child task | after libxpc (op-435 § 4 items 5-6) |
| Mach review round 2, two blind reviewers (id-051) | after the fixes |
| Automated checking of every candidate (id-047 CI) | planned |
| PID-1 launchd (id-016) | PID 1 by default on ZFS (op-436); log-queue growth fixed and soaked (op-449, op-470); robustness follow-ups in id-060 |
| Upper components: libnotify, launchd, libxpc deep reviews (op-384 to op-386) | held until the Mach round is done |
| asl leg 4 (id-011); libxpc lifecycle (id-021) | open, after the Mach round |
| Final integration soak and ship stamp (id-042) | last |

## Milestone 1 constituents

Full table and retirement rule: [l1i/li-1000.md](l1i/li-1000.md). In short:

| id | milestone | state (2026-10-05) |
|---|---|---|
| li-1001 | Mach IPC invariants hold under load | substrate proven; id-046 fixes in progress; final replay owed by id-042 |
| li-1002 | libdispatch core and conformance | core green; adapted to the step 4 contract (op-468) |
| li-1003 | libnotify/notifyd truly-green | retired (op-165) |
| li-1004 | asl truly-green | legs 1-3 green, leg 4 open (id-011) |
| li-1005 | libxpc as a core service | open, the long pole (id-021) |
| li-1006 | launchd as PID-1 core service | PID 1 by default; adapted to the step 4 contract (op-484, op-495) |
| li-1007 | integration soak | not started |
| li-1008 | known gaps cataloged | ongoing |

## After the preview

- Instrumentation: sanitizers (1.0), DTrace (2.0), hwpmc (3.0) —
  [instrumentation-strategy.md](instrumentation-strategy.md).
- Swift on rmxOS's own libdispatch (id-058, [swift-real-libdispatch.md](swift-real-libdispatch.md)).
- Case-insensitive filesystems: userspace from day one, kernel and base in steps (id-027, li-1010).
- Reproducible release image (id-012, milestone 9); x86-64-v3 baseline (id-026, li-1009).
- Full macOS semantic conformance: a long arc.
