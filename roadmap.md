# roadmap — rmxOS to a usable 1.0

- tier: **L1i**, the most abstract tier of the work hierarchy (milestones `li-NNNN` → problems
  `id-NNN` in [idq/id-000.md](idq/id-000.md) → ops `op-NNN` via `tools/rob`;
  [terminology.md](terminology.md) §6). This page says what 1.0 means and the order we get there;
  [now.md](now.md) holds the critical path of the moment.
- status: living, rewritten 2026-10-05, path updated 2026-10-08 (the June–July text is in Git at `cc7efa3`). The
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

## Path to the preview (2026-10-08)

| Stage | Status |
|---|---|
| Mach foundation, fix batches 1-3 (id-046) | done (`mach-fixes-1` to `-3` on origin) |
| Step 4 part 1: kernel reply and receive contract | done (`mach-fixes-4@0924690c`) |
| Step 4 part 2: libdispatch, launchd, libxpc adaptations | done (`mach-fixes-5@2de5f1d4`; libxpc op-500, op-502, op-507) |
| Step 4: readiness-only Mach kevents; launchd's two task setters on a child task | done (`mach-fixes-6@4de4d9ae`; op-515…op-534, op-516) — **id-046 step 4 complete** |
| id-061: launchd lost a request and could not shut down — libmach shared one MIG reply port per process | fixed, in proof (op-547; review op-549 CLOSE 9/10; proof op-550 running) |
| Overlay disks for the test loop (kernel-testing.md § 4.1) | in work (op-552) |
| Automated checking of every candidate (id-047 CI) | next after overlay disks |
| Remaining id-046 items, Mach review remainder (id-052), review round 2 (id-051) | after CI |
| PID-1 launchd (id-016) | PID 1 by default on ZFS (op-436); log queue fixed (op-449, op-470); id-061 fixed pending proof; id-060 open |
| Upper components: libnotify, launchd, libxpc deep reviews (op-384 to op-386) | held until the Mach round is done |
| asl leg 4 (id-011); libxpc lifecycle (id-021, incl. sync-reply waits on the event queue) | open, after the Mach round |
| **Real x86 hardware: bootable disk image, then installer (li-1015, high)** | gated: after the core kernel and core libraries are ready |
| Final integration soak and ship stamp (id-042) | last |

## Milestone 1 constituents

Full table and retirement rule: [l1i/li-1000.md](l1i/li-1000.md). In short:

| id | milestone | state (2026-10-08) |
|---|---|---|
| li-1001 | Mach IPC invariants hold under load | id-046 step 4 complete (`mach-fixes-6`); review round 2 and final replay owed (id-051, id-042) |
| li-1002 | libdispatch core and conformance | core green; adapted to the step 4 contract (op-468) |
| li-1003 | libnotify/notifyd truly-green | retired (op-165) |
| li-1004 | asl truly-green | legs 1-3 green, leg 4 open (id-011) |
| li-1005 | libxpc as a core service | step 4 adaptation accepted (op-500/502/507); lifecycle open, the long pole (id-021) |
| li-1006 | launchd as PID-1 core service | PID 1 by default; step 4 adapted; child-task setters fixed (op-516); id-061 fix in proof |
| li-1007 | integration soak | not started |
| li-1008 | known gaps cataloged | ongoing |
| li-1015 | rmxOS on real x86 hardware | gated on core kernel + core libraries (2026-10-08, high) |

## After the preview

- Instrumentation: sanitizers (1.0), DTrace (2.0), hwpmc (3.0) —
  [instrumentation-strategy.md](instrumentation-strategy.md).
- Swift on rmxOS's own libdispatch (id-058, [swift-real-libdispatch.md](swift-real-libdispatch.md)).
- Case-insensitive filesystems: userspace from day one, kernel and base in steps (id-027, li-1010).
- Reproducible release image (id-012, milestone 9); x86-64-v3 baseline (id-026, li-1009).
- Full macOS semantic conformance: a long arc.
