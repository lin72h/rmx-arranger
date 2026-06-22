# doc.md — top-level index of the doc trees

Entry point to the structured documentation trees. Each tree has its own index (the `*.md`
named after the directory); this file points at those indexes and lists their current entries.
Keep terse — one line per doc; detail lives in the entry, state lives in the tree's own index.

## subsystem/ — per-subsystem base/lineage decisions

"What we build *on*." For each Darwin userland subsystem: which source tree is the owned base,
the strategic fork, and how settled the decision is. Index: [subsystem/subsystem.md](subsystem/subsystem.md).

| doc | subsystem | decision |
|---|---|---|
| [subsystem/subsystem-mach-ipc.md](subsystem/subsystem-mach-ipc.md) | Mach IPC (the foundation) ⚠ | ACCEPTED base — **RESTRICTED** (per-line explicit approval) |
| [subsystem/subsystem-libdispatch.md](subsystem/subsystem-libdispatch.md) | libdispatch | ACCEPTED — classic-Apple-Mach base; reject swift-corelibs + apple-oss |
| [subsystem/subsystem-libxpc.md](subsystem/subsystem-libxpc.md) | libxpc | CLASSIFICATION-ONLY (pre-1.0); nvlist vs ravynos-mpack fork open |

## testing/ — testing & observability strategy

"How we observe and validate." Two tiers: a **shared baseline** (all roles) plus
**role-specific** strategies/trackers that extend it. Index: [testing/testing.md](testing/testing.md).

| doc | title | tier / scope | state |
|---|---|---|---|
| [testing/testing-dtrace.md](testing/testing-dtrace.md) | DTrace-first observability — observe, don't perturb | shared baseline · all roles | ACTIVE |
| _testing/testing-gatekeeper.md_ | Gatekeeper parity/regression tracker | role-specific · Gatekeeper | PLANNED (to author) |

## Related indices (other trees)

- [backlogs/bl-000.md](../backlogs/bl-000.md) — backlog (`bl-NNN`): identified work not yet
  fetched into the IDQ/ROB. "What we build *next*."

## Maintenance

When a new doc tree is added (its own directory + `<dir>.md` index), add a section here. When a
tree gains/retires an entry, update its row. This index lists *what exists and where*; the
authoritative state for each entry stays in that tree's own index.
