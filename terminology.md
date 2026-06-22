# Terminology & Naming Conventions (rmxOS revival)

Status: Arranger reference (workspace, living). The canonical glossary for roles, ruler
agents, repos, and namespaces on our side. Mirrors the wip-gpt `docs/terminology.md`
discipline (current terms only; record old→new maps; never accrete). Cross-refs:
`role-model-onboarding.md`, `explorer-parity-cycle-workflow.md`,
`test-pillar-partition.md`, `swift-rmxos-integration-plan.md`.

## 1. Roles

| Current term | Meaning |
|---|---|
| **Coordinator** | Human owner. Sets milestones, accepts/authorizes spends, owns cross-agent routing. |
| **Oracle** | A more powerful agent the Arranger CONSULTS when it cannot resolve a problem itself — the Arranger's escalation/consultation resource. Coordinator-mediated. (Repurposed 2026-06-20 from the retired "Composer" placeholder term.) NOT the old explorer+gatekeeper "Oracle" (that union is now **Ruler**), and NOT the lowercase "test oracle / macOS source-of-truth" sense. |
| **Arranger** | Decomposes Milestone → `block-NNN`, targets agents, reviews first-hand. (Fable.) |
| **Arbiter** | Conflict-resolution + adjudication seat. Held by the Arranger (Fable holds both). NEVER a Validator. |
| **Implementer** | Makes the product changes; closes blocks. |
| **Ruler** | Role-term for the union of **Explorer + Gatekeeper** — each is "a ruler" (a ruler *measures* rmxOS against macOS truth). Dedicated agents, own repos. |
| **Explorer** (a Ruler) | Authors parity probes, captures `mx-*`/`rx` behavior vectors, owns the mismatch ledger. Reference = real macOS, not our markers. |
| **Gatekeeper** (a Ruler) | Evidence discipline, spend-gating, dispositions. Consumes Explorer evidence read-only across the repo boundary. |
| **Validators** | GLM (enumeration/completeness) + DS4P (falsification/forward-instinct). Review legs; routed assignee-neutral. |

### Retired / renamed (old → new; older records keep old terms with this map)
- **Maestro → Coordinator** (2026-06-13).
- **Conductor → Arranger** (2026-06-13).
- **Oracle (OLD meaning = the Explorer+Gatekeeper union) → that union is now "Ruler"**
  (2026-06-20). The old role-meaning of "Oracle" is gone.
- **Composer → Oracle** (2026-06-20). The "Composer" placeholder term is RETIRED; the word
  "Oracle" is REPURPOSED to a NEW meaning: the more powerful agent the Arranger consults
  when stuck (see Roles §1). Net: "Oracle" no longer means explorer+gatekeeper (= Ruler) and
  no longer means the milestone-Composer; it means the Arranger's consult-agent.
- Disambiguation: the capital-O **Oracle** ROLE (consult-agent) is distinct from the
  lowercase "test oracle" / "real macOS is the oracle" usage in the parity docs (a generic
  source-of-truth term) and from "oracle" inside legacy artifact names (§4).

### Role tree
`Coordinator (human owner; holds Milestones/strategy) → Arranger (+Arbiter) → { Implementer,
Rulers {Explorer, Gatekeeper}, Validators {GLM, DS4P} }`
The Arranger **consults the Oracle** (a more powerful agent, Coordinator-mediated) when it
cannot resolve a problem itself. Milestones stay Coordinator-held (the former Composer slot
was never staffed; its term is now repurposed to the consult-Oracle).

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

## 4. Agent repos (split 2026-06-20: Oracle → dedicated rulers)

| Local workspace | Upstream | Role |
|---|---|---|
| `rmx-explorer` | `git@github.com:lin72h/rmx-explorer.git` | foundation Explorer ruler |
| `rmx-gatekeeper` | `git@github.com:lin72h/rmx-gatekeeper.git` | foundation Gatekeeper ruler |
| `wip-gpt-oracle` | `git@github.com:lin72h/mach-oracle.git` | legacy oracle (Elixir app + UI) — name retained as artifact id |
| `swift-rx-explorer` | (swift-rx upstream) | Swift Explorer ruler |
| `swift-rx-gatekeeper` | (swift-rx upstream) | Swift Gatekeeper ruler |

"oracle" persists only here as baked-in artifact identifiers: the `mach-oracle.git` remote,
the `wip-gpt-oracle` dir, and the `macos-oracle.v1` / `nx-r64z.macos-oracle` schema. These
are NOT role terms and stay unless separately renamed.

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

## 6. Workflow model — CPU out-of-order execution terminology (2026-06-20)

We describe the workflow with CPU OoO-execution terms: the agents are parallel **execution
pipelines**, the Arranger is the **issue + retire** unit. The discovery→implementation
pipeline IS a superscalar out-of-order machine.

| Term | Meaning | Was |
|---|---|---|
| **op-NNN** | a unit of work (a micro-operation / uop). Zero-padded, sequential project-wide, never reused. | `block-NNN` (renamed — "block" collided with "blocking") |
| **issue** | the Arranger creates + dispatches an op to a pipeline. | "dispatch" / "create the block" |
| **multi-issue** | issue several ops at once → they execute on different pipelines in parallel. | — |
| **pipeline** | an execution lane = an agent (Implementer, Explorer, Validators, Gatekeeper). | — |
| **retire** | the op is done — validated/accepted, results committed. | "accept" / "done" |
| **in-flight** | issued but not yet retired. | — |

**Out-of-order:** issued ops execute on different pipelines and may **retire out of issue
order.** The Arranger = the issue unit + retirement tracking (the reorder buffer); on a
Validator conflict or sub-threshold confidence it also acts as Arbiter.

**Pipelines (which agent runs what):**
- **Explorer** pipeline — discovery (macOS-parity).
- **Implementer** pipeline — execution / implementation.
- **Validator** pipelines (GLM, DS4P) — parallel quality-validation (genuinely superscalar:
  both review the same op concurrently).
- **Gatekeeper** pipeline — macOS-parity validation.
- **Arranger** — issue + retire (+ Arbiter on Validator conflict / confidence <8).

**Retired terms:** `block-NNN` → `op-NNN`; "dispatch a block" → "issue an op"; "accept/done"
→ "retire". Frozen/committed records keep `block-NNN` (historical); live work uses `op-NNN`.
In-flight renames: block-081→op-081, block-082→op-082, block-080a-R-fix→op-080a-R-fix.

## 7. Other standing terms (pointers, defined elsewhere)
- **Lane A / Lane B** — risk-tiered Swift sequencing (does it ride the unproven core?).
  See `swift-rmxos-integration-plan.md`.
- **Three test pillars** — Zig (low/ABI) + Elixir (orchestration spine) + swift-testing
  (high Swift/C++/macOS-API, later). See `test-pillar-partition.md`.
- **`op-NNN`** — the work-unit ID (was `block-NNN`); see §6.
- **Parity cycle** — input → author → macOS (spec + human checkpoint) → rmxOS → match/ledger
  → close. See `explorer-parity-cycle-workflow.md`.
