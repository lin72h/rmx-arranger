# subsystem.md — Subsystem base/strategy overview + index

Per-subsystem **base/lineage decisions**: for each Darwin userland subsystem we revive
(libdispatch, libxpc, notifyd, ASL, launchd, …), which source tree is the *base* we own and
harden, what the strategic fork is, and how settled the decision is. This is the
planning-level "which base, and why" record — distinct from:

- **backlog (`bl-NNN`, `backlogs/`)** — specific not-yet-fetched work items.
- **ops (`op-NNN`)** — in-flight implementation.

A subsystem doc answers "what do we build *on*"; a backlog item answers "what do we build
*next*"; an op answers "what is building *now*".

## Decision-state vocabulary

| state | meaning |
|---|---|
| **ACCEPTED** | base/lineage decided and owned; harden in place. Upstreams not revisited absent a new reason. |
| **CLASSIFICATION-ONLY** | pre-1.0 source assessment to steer strategy; NOT an implementation commitment. A fork may still be open. |
| **OPEN** | base or a load-bearing fork undecided; needs a Coordinator call before work. |
| **DEFERRED** | assessed, parked; revisit when the subsystem goes active. |
| **RESTRICTED** ⚠ | a modifier on any state: change-control is elevated — edits need **per-line explicit Coordinator approval** before being written (foundation subsystems whose changes have unpredictable cross-kernel blast radius). Currently: Mach IPC. |

## Index

| subsystem | base / lineage (owned) | decision | doc | key fork / open gap |
|---|---|---|---|---|
| **Mach IPC** ⚠ | NextBSD Mach IPC on **FreeBSD-15** (`lin72h/rmxOS` stable/15) | **ACCEPTED base — RESTRICTED** (per-line explicit approval) | [subsystem-mach-ipc.md](subsystem-mach-ipc.md) | **The foundation — every line change needs explicit Coordinator approval** (unpredictable cross-kernel interaction). N2 narrowed-accepted (N2C-2b deferred); Phase 0.85 handoff active. |
| **libdispatch** | NextBSD **classic-Apple-Mach** libdispatch (`lib/libdispatch`) | **ACCEPTED** (Coordinator, 2026-06-22) | [subsystem-libdispatch.md](subsystem-libdispatch.md) | Reject swift-corelibs (Linux-inward) + apple-oss (forces parked kernel track). Localized gaps → op-093, bl-001/bl-003. |
| **CoRT** (`os_object`) | Apple `os_object` runtime, **co-located in `lib/libdispatch`** (not a separate lib) | **ACCEPTED base + C/Zig-first** (Coordinator, 2026-06-22) | [subsystem-cort.md](subsystem-cort.md) | Common Object Runtime (Hubbard's NextBSD term). C runtime is base, ObjC is overlay → core default `OS_OBJECT_USE_OBJC=0`. Shared base under libdispatch + libxpc; keep co-located, do not factor out. |
| **libxpc** | NextBSD `libxpc` (nvlist-backed, Mach-native transport) | **CLASSIFICATION-ONLY** (pre-1.0) | [subsystem-libxpc.md](subsystem-libxpc.md) | Serialization fork: nvlist (NextBSD) vs MessagePack (ravynos). No ObjC NSXPCConnection; Swift layer later. |

## How a subsystem decision relates to the upstream-precedence rule

The project's least-intrusive precedence — **donor > XNU-ref > local** — governs *within* a
chosen base. The subsystem doc records the prior, coarser choice: *which base is the donor at
all*. Once ACCEPTED, port defects are fixed in the owned base (surgically, op-092-style layer
exoneration); they do NOT reopen the base choice.

## Maintenance

Add a row when a subsystem is first assessed; update its decision state as it moves
OPEN/CLASSIFICATION-ONLY → ACCEPTED (or DEFERRED). Keep this index terse — one row per
subsystem; the rationale + evidence live in the entry doc. When a base decision is accepted,
record the Coordinator + date in both this row and the entry doc.
