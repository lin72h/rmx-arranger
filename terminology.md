# Terminology & Naming Conventions (rmxOS revival)

Status: Arranger reference (living). Names, namespaces, hosts, repos, and the workflow vocabulary.
Role definitions live in [roles.md](roles.md); this file does not restate them. Current terms
only; old terms are mapped once, in §9. Cross-refs: `explorer-parity-cycle-workflow.md`,
`test-pillar-partition.md`, `swift-rmxos-integration-plan.md`.

## 1. Roles

Definitions, repos, and the review rule: [roles.md](roles.md). Naming notes only:

- **agent** — one autonomous worker: a harness, a model, and its tools. Each non-human role is
  held by one or more agents; only the Coordinator is human.
- **Oracle** (capital O) is the consult role. It is distinct from the lowercase "test oracle" /
  "real macOS is the oracle" sense in parity docs, and from "oracle" inside legacy artifact names
  (§4).
- **Ruler** — naming family for Explorer and Gatekeeper instances (§2); each measures rmxOS
  against macOS truth. Not a separate role.
- **Arbiter** — the Arranger's seat for final calls on sub-threshold or conflicting reviews.
  Never a Validator.

## 2. Ruler naming convention

Three forms, one structure:

**Full external name = `{ruler-repo}-{host-namespace}` = `{project}-{role}-{platform}-{arch}z`**

| Slot | Values |
|---|---|
| project | `rmx` (foundation) · `swift-rx` (Swift integration) |
| role | `explorer` · `gatekeeper` |
| platform | `mx` (macOS) · `rx` (rmxOS) |
| arch | `a64` (arm64) · `x64` (x86_64) · `r64` (union x64+a64) — always trailed by `z` |

**Arch-letter rule: `v` is PERMANENTLY RETIRED as a CPU/arch designation.** `v` was the old
union letter (`nx-v64z`); replaced by `r` (`r64` = union of x64+a64). Going forward the only
arch letters are `a64` / `x64` / `r64` — never `v`. `v` survives ONLY in frozen historical
`nx-v64z` filenames pending their migration to `nx-r64z`. Do not reintroduce `v` for any CPU.

| Form | Pattern | Example |
|---|---|---|
| **Full** (cross-agent / outside) | `{project}-{role}-{platform}-{arch}z` | `rmx-explorer-mx-a64z` |
| **Short codename** (internal) | `{role}-{platform}` | `explorer-mx` |
| **Vector / host namespace** | `{platform}-{arch}z` | `mx-a64z` |

The full name reads "which ruler, deployed where." Same host, different projects stay
unambiguous: `rmx-explorer-mx-a64z` vs `swift-rx-explorer-mx-a64z`.

### Roster
- Foundation: **`rmx-explorer-mx-a64z`** (READY on `mm4`, 2026-06-20) · `rmx-explorer-rx-x64z` ·
  `rmx-gatekeeper-mx-a64z` · `rmx-gatekeeper-rx-x64z`.
- Swift (swift-rx arranger names theirs on this grammar): `swift-rx-explorer-mx-a64z` ·
  `swift-rx-explorer-rx-x64z` · `swift-rx-gatekeeper-*`.

## 3. Hosts

| Host | Machine |
|---|---|
| `mm4` / `mm4.local` | M4 Mac Mini, macOS 27 beta, arm64 — the macOS-27 reference (single truth host for BOTH ruler pairs). |
| `rx` guest | rmxOS-Mach bhyve guest (system-under-test). |
| (`mx-x64z`) | Intel macOS reference, optional. |

## 4. Agent repos

Each agent writes only its own repo. Paths are under `/Users/me/wip-mach/`. Role repos are being
renamed to `rmx-<role>` as each is onboarded (j-20260927-007).

| Local workspace | Upstream | Role |
|---|---|---|
| `rmx-arranger` | `git@github.com:lin72h/rmx-arranger.git` | Arranger |
| `rmx-implementer` (product source in `rmx-implementer/wip-rmxos`; `wip-gpt` is a transitional symlink) | `git@github.com:lin72h/project-rmx.git` | Implementer |
| `rmx-explorer` | `git@github.com:lin72h/rmx-explorer.git` | Explorer |
| `rmx-gatekeeper` | `git@github.com:lin72h/rmx-gatekeeper.git` | Gatekeeper |
| `wip-glm` | none (not a Git repo) | Validator GLM |
| `wip-ds4p` | none (not a Git repo) | Validator DS4P |
| `rmx-oracle` | none (not a Git repo) | Oracle |
| `rmx-validator3` | none (not a Git repo) | Validator (active: reviewed op-339/op-341 on 2026-09-22) |
| `wip-gpt-oracle` | `git@github.com:lin72h/mach-oracle.git` | legacy oracle (Elixir app + UI); evidence trees under `priv/runs/` |
| `swift-rx-explorer`, `swift-rx-gatekeeper` | swift-rx upstream | Swift-project rulers |

"oracle" persists in baked-in artifact identifiers only: the `mach-oracle.git` remote, the
`wip-gpt-oracle` dir, and the `macos-oracle.v1` / `nx-r64z.macos-oracle` schema. These are not
role terms.

## 5. Namespaces (two kinds — keep distinct)

- **Contract namespace** — owns schema / comparison / findings: `nx-r64z` (foundation) ·
  `swift-r64z` (Swift — adopted by swift-rx 2026-06-20, replacing the proposed `sx-r64z`).
  (`r` = union of x64+a64.)
- **Host / vector namespace** — identifies the capture host+arch in result vectors:
  `mx-a64z`, `mx-x64z`, `rx-x64z` / `rx`.
- **CANONICAL FORM = z-form, `r` prefix** (ruling 2026-06-20, explorer-rx raised a 3-way
  conflict): `nx-r64z` / `mx-a64z` / `rx-x64z`. Two axes settled: (1) `v`→`r` (Coordinator
  decision — `nx-v64z` is the OLD prefix); (2) the trailing `z` STAYS (the Coordinator's own
  rename kept it — "`nx-v64z` → `nx-r64z`" — and the agent-naming convention is z-form,
  `rmx-explorer-mx-a64z`). SUPERSEDED: a checked-in `catalog/README.md` in the explorer repo
  declared no-z canonical (`nx-r64`/`mx-a64`, `z`="historical") — that is a stale pre-split
  agent declaration, to be corrected. MIGRATION: 45 live files are still `nx-v64z` (host
  `mx-a64z` already correct); the `nx-v64z`→`nx-r64z` contract rename of those FROZEN
  evidence files is a separate gatekeeper-policed namespace migration (data unchanged, label
  only) — does NOT block new work; new batches (block-080a) write `nx-r64z` directly;
  document `nx-v64z ≡ nx-r64z` until migrated.

## 6. Workflow model (rewritten 2026-09-28)

The workflow is an explicit graph. **Nodes** are the roles in `roles.md`; **edges** are briefs and
REPORTs, and every edge is relayed by hand through the Coordinator, who is also the approval point.
Each op is one node-to-node task: one agent, one repo, one outcome.

**Work tiers** (most abstract → most concrete):

| Tier | Id | Holds |
|---|---|---|
| L1i (roadmap) | `li-MNNN` | what a milestone means and its coverage bar ([roadmap.md](roadmap.md), `l1i/`) |
| IDQ (problems) | `id-NNN` | a concrete open problem and why it matters ([idq/id-000.md](idq/id-000.md)) |
| op (work) | `op-NNN` | one agent's task toward an IDQ; state via `tools/rob` |

An IDQ is served by one or more ops. Work is chosen from live, preview-relevant IDQ problems, not
by visiting every L1i row (Coordinator, 2026-07-11). The current critical path is in
[now.md](now.md).

**Op states, board, and ids:** [rob-mini-format.md](rob-mini-format.md). **Brief and REPORT
format:** [op-brief-forms.md](op-brief-forms.md); each role repo's `OPS.md` holds its defaults. **Review rule:** [roles.md](roles.md) § Review
and closure. Old workflow terms: §9.

**L1i numbering:** `li-MNNN`, where M is the milestone (1 = 1.0-preview, index
[l1i/li-1000.md](l1i/li-1000.md); 2 = service-usable 1.0; 9 = infrastructure) and `li-M000` is the
milestone index. Filenames are number-only. The older flat `li-001…li-008` map into this scheme
via li-1000. A milestone closes when its truly-green criterion holds on first-hand evidence.

## 7. Other standing terms (pointers, defined elsewhere)
- **Lane A / Lane B** — risk-tiered Swift sequencing (does it ride the unproven core?).
  See `swift-rmxos-integration-plan.md`.
- **Three test pillars** — Zig (low/ABI) + Elixir (orchestration spine) + swift-testing
  (high Swift/C++/macOS-API, later). See `test-pillar-partition.md`.
- **`op-NNN`** — the work-unit id; see §6 and `rob-mini-format.md`.
- **Parity cycle** — input → author → macOS (spec + human checkpoint) → rmxOS → match/ledger
  → close. See `explorer-parity-cycle-workflow.md`.

## 8. Test/evidence vocabulary — soak-testing & chaos-testing (2026-06-23)

Two members of the testing strategy. One is the established, proven term; the other is a named
**future** addition. They are **distinct test types, not a rename** — both judged by **invariant
oracles** (DTrace assertions on kernel-internal balances), "the probe *is* the test", and both
overclaim-strict (a pass means "ran it, invariants held," never "looks correct").

| term | what it does | status | carries |
|---|---|---|---|
| **soak-testing** (the current term — use it) | sustained high-rate workload over an hours-scale run; manufactures adversarial *timing* as a side effect of churn (e.g. MACH_RECV create/destroy racing the receive walk); DTrace oracles assert msg/kmsg/queue/port balance + flat slope (no leak) + no panic. | **PROVEN** (op-104 infra → op-105 2h oracle → **op-108** retired id-009 on it) | id-006 / id-007 (the rig) |
| **chaos-testing** (future addition to the strategy) | *actively injects* faults — port frees mid-receive, scheduler perturbation, memory pressure, randomized syscall delay/failure, controlled interleavings — to go from "survives natural churn" to "survives injected adversity." Industry "chaos engineering" (Chaos Monkey lineage) = this fault-injection sense. | **NOT BUILT — future** | **id-013** |

**Relationship:** soak-testing stresses with *load* and catches what sustained churn happens to
expose (it found id-009 because the natural timing eventually collided). chaos-testing stresses
with *injected faults* and forces the rare condition deterministically instead of waiting for luck.
Complementary, not hierarchical — soak is the endurance floor we have; chaos is the adversarial
addition we add later. Do **not** retroactively relabel soak as chaos.

**Native hooks for chaos-testing when we build it (first-hand, in-tree):** FreeBSD `KFAIL_POINT`
(`sys/sys/fail.h` + `sys/kern/kern_fail.c`) is present but **placed nowhere yet** (0 usages in
`sys/`) — ready for injection points in the mach-ipc paths; DTrace destructive actions
(`chill`/`raise`/`stop`, via fasttrap) give timing perturbation consistent with DTrace-first.

## 9. Retired terms

Older records keep their original words; read them with these maps.

**Roles**

| Old | Current | Since |
|---|---|---|
| Maestro | Coordinator | 2026-06-13 |
| Conductor | Arranger | 2026-06-13 |
| Oracle (Explorer + Gatekeeper union) | Explorer and Gatekeeper (naming family "ruler") | 2026-06-20 |
| Composer | Oracle (consult role) | 2026-06-20 |
| Executor, EXU, Ex | agent | 2026-09-28 (introduced 2026-06-26) |
| Arranger1 / Arranger2, SWAP, mutex, epoch | single Arranger seat | 2026-09-27 |
| `wip-gpt` (Implementer repo folder) | `rmx-implementer` | 2026-09-28 |

**Workflow**

| Old | Current |
|---|---|
| ROB, reorder buffer, live ROB board | the board (`tools/rob board`) |
| EXU, pipeline, backend | agent |
| issue / dispatch / fetch | create the op / Coordinator sends it |
| `[Draft]` `[Ready]` `[Awaiting]` | `draft` |
| `[Exe]` `[In-flight]` `[Air]` `[Queued]` | `issued` |
| `[Done]` | `returned` |
| `[Hold]` `[Held]` | `hold` |
| `[Retired]`, retire | `closed`, close |
| `[Flushed]`, flush | `dropped`, drop |
| `op-NNNm` (meta lane) | plain `op-NNN` for new work |
| `block-NNN` | `op-NNN` |
| DISPATCH line, `WAITING on op-NNN` | `needs:` in the op header |
| IDQ **FETCHED** / **RETIRED** | IDQ **IN WORK** / **CLOSED** |
| "Retirement & escalation rule" (`discovery-implementation-pipeline.md`) | `roles.md` § Review and closure |
