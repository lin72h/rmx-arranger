# testing.md — Testing & observability strategy overview + index

How we observe, instrument, and validate behavior across the project. **Two tiers:**

1. **Shared baseline (all roles).** Cross-cutting testing/observability doctrine every role
   follows — e.g. the DTrace-first observability strategy below. These are the defaults.
2. **Role-specific strategies/trackers.** A role may keep its own testing doc layered on top
   of the shared baseline — e.g. the **Gatekeeper** keeps a dedicated parity/regression
   **tracker** (what's been guarded, regressions caught, macOS-parity vectors). Role-specific
   docs *extend*, never contradict, the shared baseline.

This complements, not replaces: the parity cycle
([../../explorer-parity-cycle-workflow.md](../../explorer-parity-cycle-workflow.md)), the
validator craft (`validator-rulebook.md`, agent-dir doc — not in this workspace), and the
per-subsystem base docs ([../subsystem/subsystem.md](../subsystem/subsystem.md)).

## State vocabulary

| state | meaning |
|---|---|
| **ACTIVE** | adopted; the current default/standing practice. |
| **PLANNED** | agreed in principle; doc not yet authored. |
| **DRAFT** | being written / under review. |

## Index

| id | title | tier | scope (roles) | state | doc |
|---|---|---|---|---|---|
| testing-dtrace | DTrace-first observability — observe, don't perturb | **shared baseline** | all roles | **ACTIVE** | [testing-dtrace.md](testing-dtrace.md) |
| testing-gatekeeper | Gatekeeper parity/regression tracker | role-specific | Gatekeeper | **PLANNED** | _(to author)_ |

## Conventions

- Shared baseline docs: `testing-<topic>.md`. Role-specific docs: `testing-<role>.md`.
- A role-specific doc opens by naming which shared baselines it inherits, then records only
  what's specific to that role.
- Keep this index terse — one row per entry; detail lives in the entry doc.

## Maintenance

Add a row when a testing strategy or tracker is raised; mark its tier (shared vs role-specific)
and the roles it binds. Update state PLANNED → DRAFT → ACTIVE. When a role-specific doc would
contradict a shared baseline, that's a signal to revise the baseline, not to fork silently.
