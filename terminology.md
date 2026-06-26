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
| **op-NNNm** | the **only** legal op-id variant: the `m` suffix marks the **op-147m method** form of an op. No other suffix exists. | — |
| **issue** | the Arranger creates + dispatches an op to a pipeline. | "dispatch" / "create the block" |
| **multi-issue** | issue several ops at once → they execute on different pipelines in parallel. | — |
| **pipeline** | an execution lane = an agent (Implementer, Explorer, Validators, Gatekeeper). | — |
| **retire** | the op is done — validated/accepted, results committed. | "accept" / "done" |
| **in-flight** | issued but not yet retired. (OoO concept; the ROB display tag for this state is **`[Exe]`** — renamed `[In-flight]` → `[Air]` → `[Exe]` 2026-06-26.) | — |

**Out-of-order:** issued ops execute on different pipelines and may **retire out of issue
order.** The Arranger = the issue unit + retirement tracking (the reorder buffer); on a
Validator conflict or sub-threshold confidence it also acts as Arbiter. The Arranger surfaces
the live in-flight set as a **ROB** list at the end of each op reply — see
[rob-mini-format.md](rob-mini-format.md).

**Op-id form (Coordinator 2026-06-26):** an op id is `op-NNN`, optionally with the single
suffix `m` (`op-147m`). **No compound / continuation ids** — never `op-151-cont`, `op-151-2`,
`op-151a`. Follow-on or redo work always takes the **next free `op-NNN`**, never a decorated
version of the original.

**`[Flushed]` op state (Coordinator 2026-06-26):** when an op **does not work out** (fails,
dead-ends, or was mis-scoped), mark it `[Flushed]` and **re-issue the work under a brand-new
`op-NNN`** — the flushed op id is closed, not continued. (CPU analogy: a mis-speculated uop is
*flushed* from the pipeline; the re-fetch gets a fresh slot.) Distinct from `[Done]`: an op that
delivered its primary objective is `[Done]` even when a follow-on is needed (the follow-on is its
own new op number). Full ROB status vocabulary lives in [rob-mini-format.md](rob-mini-format.md).

**Work hierarchy (abstraction tiers): `L1i → IDQ → ROB`** — the CPU instruction path,
most-abstract to most-concrete. Each tier has an architectural name (primary) and a friendly
alias (in parens); ids in backticks. (Renamed 2026-06-24: roadmap→**L1i**/`li-NNN`,
backlog→**IDQ**/`id-NNN`; op→**ROB**/`op-NNN` unchanged.)

| Tier (alias) | Artifact | Meaning | OoO analogy |
|---|---|---|---|
| **L1i** (roadmap) | `li-NNN` ([roadmap.md](roadmap.md)) | most abstract — *what usable 1.0 means and in what order* (the milestone ladder `li-001`…`li-006`, the arcs). Durable; rarely changes. | the program resident in the L1 instruction cache, before fetch |
| **IDQ** (backlog) | `id-NNN` ([idq/id-000.md](idq/id-000.md)) | **pending** — decoded from an L1i instruction, queued; identified but **not yet fetched** into flight. Concrete enough to fetch. | decoded uops in the instruction-decode queue, awaiting fetch/issue |
| **ROB** (op) | `op-NNN` (§6 above) | **in-flight** — fetched → issued; owned by a pipeline; executes → retires. | a uop in the reorder buffer |

**Promotion chain:** an **L1i** instruction (`li-NNN`) is **decoded** into one or more **IDQ** items
(`id-NNN`); an IDQ item is **fetched** into one or more **ROB** entries (`op-NNN`). Promotion =
fetch (the same word the IDQ uses; state `FETCHED → op-NNN`). Direction of detail: L1i =
why/what-order · IDQ = what (pending) · ROB = how (now).

**L1i numbering — milestone-grouped 4-digit `li-MNNN` (expanded 2026-06-25):** the leading digit
**M** = the **milestone number**; **NNN** = the instruction within that milestone. **`li-M000`** is
the special **milestone-INDEX** entry (names what the milestone means + lists its constituents);
**`li-M001 … li-M999`** are its constituent instructions. Milestones: **M=1 = 1.0-preview**
(index [l1i/li-1000.md](l1i/li-1000.md)); M=2 = full service-usable 1.0 (reserved); M=9 =
infrastructure/long-arc (reserved). **Filenames are number-only — `l1i/li-NNNN.md`** (no descriptive
suffix); `l1i/li-X000.md` is implicitly the index for `li-X001…li-X999`. The original flat
`li-001…li-008` are being migrated under this scheme (mapping in li-1000); the standalone
`l1i/li-007`/`li-008` files stand as li-1005/li-1006 detail until physically renamed.

**Retirement:** "usable 1.0" = all six **L1i** milestones (`li-001`…`li-006`) **retired**. An `li-NNN`
retires when its **truly-green** criterion holds (first-hand evidence, overclaim-strict) — the same
in-order retirement an instruction undergoes once its uops complete. (We dropped the earlier "Gate
A–F" naming 2026-06-24: the milestones *are* the `li-NNN`, and "pass a gate" → "retire an `li-NNN`".
The lowercase verb "gated on X" = blocked-by-X is kept; so is the **Gatekeeper** role.)

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

## 7. Other standing terms (pointers, defined elsewhere)
- **Lane A / Lane B** — risk-tiered Swift sequencing (does it ride the unproven core?).
  See `swift-rmxos-integration-plan.md`.
- **Three test pillars** — Zig (low/ABI) + Elixir (orchestration spine) + swift-testing
  (high Swift/C++/macOS-API, later). See `test-pillar-partition.md`.
- **`op-NNN`** — the work-unit ID (was `block-NNN`); see §6.
- **Parity cycle** — input → author → macOS (spec + human checkpoint) → rmxOS → match/ledger
  → close. See `explorer-parity-cycle-workflow.md`.
