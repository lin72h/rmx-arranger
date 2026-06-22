# Explorer Parity-Cycle Workflow

Status: Arranger doctrine (workspace, living). The operational workflow for the
**macOS-parity Explorer** lane. Real macOS is the behavioral source of truth;
rmxOS converges toward it over time, least-intrusive-first, without blocking 1.0.
Lean by design — supersedes the heavier framing in `parity-explorer-strategy.md`
(kept only as a principles reference).

## Purpose

Drive rmxOS semantics toward real macOS behavior, **one feature at a time**,
human-in-the-loop, by: writing a portable test for a feature, running it on real
macOS (ground truth + a check on the human's understanding), then on rmxOS, and
recording match (success) or no-match (improvements queue).

## The parity cycle (per feature)

```
[1 INPUT]   Human is learning a macOS feature (e.g. launchd KeepAlive) and gives
            the Explorer the feature + their understanding/hypothesis.
            (Or the Explorer proposes a feature.)
   |
[2 AUTHOR]  Explorer writes a portable test for that feature:
            - Zig probe: exercises the feature, emits structured behavior JSON;
              runs on BOTH macOS and rmxOS (one source, two targets).
            - Elixir runner/comparator: drives the run, captures env, normalizes,
              diffs, classifies.
   |
[3 macOS]   Run on mm4 (macOS 27 beta) -> the real macOS behavior (mx-a64z vector).
            *** HUMAN CHECKPOINT: review it -> confirm or correct your
                understanding. macOS is the source of truth; validate the mental
                model here, BEFORE judging rmxOS. ***
   |
[4 rmxOS]   Run the SAME probe on rx (rmxOS guest) -> our behavior (rx vector).
   |
[5 DECIDE]  Compare mx-a64z vs rx:
            - MATCH    -> mark feature "parity-confirmed" (success record).
            - NO-MATCH -> push to the improvements queue, target = the macOS
              behavior, with the discrepancy + an intrusiveness tag.
   |
[6 QUEUE]   The improvements queue feeds the Arranger -> least-intrusive fix
            Blocks (block-NNN) interleaved with foundation work -> re-run the
            cycle to confirm closed (parity regression guard).
```

The macOS step (3) is deliberately first and human-gated: it both captures truth
and lets the human validate their understanding of the feature before rmxOS is
measured against it.

## Principles (lean)

1. **1.0 = current state.** rmxOS as-is is the 1.0 baseline (NextBSD revive).
   Discrepancies are a backlog, not release blockers.
2. **Real macOS is the oracle** — actual observable macOS 27 behavior, not our
   own markers.
3. **Least-intrusive first, doctrine source-preference.** Score each no-match by
   intrusiveness (config < userland-app < userland-lib < kernel-internal <
   kernel-ABI) and benefit. For the fix, follow the standing `project-doctrine.md`
   preference: **(1) existing NextBSD donor code, (2) newer XNU as a
   semantic/algorithmic reference, (3) a small isolated rmxOS patch as last
   resort.** A mismatch is NOT auto-permission to rewrite kernel IPC. Fix the
   cheap, high-value ones; defer the rest as documented accepted-divergences.
   (This is already Phase-0.5o doctrine: the oracle lane runs PARALLEL and
   NON-BLOCKING, blocking only if a finding would falsify an active milestone
   claim.)
4. **Don't rush mimicry.** Only close gaps worth the cost. Harmless + costly
   stays a documented divergence.
5. **Version-sensitivity is dominant.** Donor ~ macOS 10.10-11; reference =
   macOS 27 beta (~13yr gap) -> most deltas are version-evolution, not bugs.
   Classify version-sensitive first; record the beta build.
6. **Human-in-the-loop, per-feature.** Driven by what the human is learning; not
   a fire-and-forget batch.

## Implementation pieces (aligned to existing doctrine)

- **Language choice** (per `test-plan.md`, REFINED 2026-06-20 after explorer-mx
  raised the gap): existing C probes STAY C — do NOT rewrite to unify. **Elixir**
  for high-level behavioral/orchestration. **C vs Zig for low-level probes** turns
  on whether Zig's UNIQUE value is needed AND the Zig harness exists:
  - The existing **C foundation harness already cross-builds to BOTH targets**
    (block-074 macOS + block-073 host-cross-built→rx prove C dual-target). So the
    "same source, two targets" property is ALREADY met in C for foundation probes.
    `build.zig` is still a STUB (no Zig probe harness yet).
  - **→ Foundation probes that extend the existing C dual-target suite stay C**
    (e.g. block-080a's 6 Mach-introspection probes). Reuse the proven harness;
    don't detour into harness-building during the catalog/1.0-solidity-first phase.
  - **→ Go Zig (and stand up `build.zig`) when a probe needs Zig's UNIQUE value:**
    cross-ARCH union (one source → both x64 AND a64 for `r64z`), or probes shared
    with the swift-rx rulers / the rmxOS guest where C cross-build is awkward. Build
    the Zig harness deliberately at that first real need, with those probes as its
    first instances — never speculatively for probes C already handles.
  Zig 0.16 default; codesign `-s -`; `mach_msg()` only (not `mach_msg2`).
- **macOS run** (on mm4): build + run + capture a stable JSON behavior vector
  (the existing `nx-r64z.macos-oracle.v1` schema: env metadata + api_sequence +
  returns + right_deltas + cleanup + semantic_class). fork/spawn probes set a
  watchdog, waitpid, clean up ports, report cleanup status.
- **rmxOS run** (on `rx`): via the existing bhyve guest harness
  (`bhyve-harness.md`) — serial JSON between `=== nxplatform probe start/end ===`
  markers, `parse-serial.py`. Reuse, don't rebuild.
- **Comparator**: extend the existing mechanical pattern (`compare-m2-oracle.py`,
  `findings/nx-r64z/...`) — compare semantic class first, right-deltas not raw
  names, port-name existence not numeric names.
- **Improvements queue = the existing mismatch ledger** (`findings/nx-r64z/`):
  per-feature status (`parity-confirmed` | `mismatch`) + for mismatches the
  macOS-target behavior, the discrepancy, the classification, and the
  intrusiveness tag. The oracle is **read-only toward rmxOS source**: a mismatch
  reports the *smallest falsifiable source requirement*; the Implementer fixes;
  the oracle re-validates (per `source-oracle-responsibility-boundary.md`).
- **Layout** (reuse existing `macos-validation/`): `probes/`, `harness/`,
  `results/{mx-a64z,mx-x64z,rx,nx}/`, `findings/nx-r64z/`, Makefile (`make run
  AGENT=...`). Namespaces (Coordinator 2026-06-19): `nx-r64z` owns contract/
  schema/comparison/findings — `r` = the union of x64+a64 (portable cross-arch
  intersection), replacing the old `v` (`nx-v64z`); `mx-a64z`/`mx-x64z` run
  macOS; `rx` runs rmxOS.

## Migration: current -> desired (mostly additive)

Existing `wip-gpt-oracle/macos-validation` (16 C probes m1/m2/foundation, harness,
Makefile, 45 result JSONs, host namespaces, classification) is the INFRA base.
Carry it over; add the parity-cycle layer.

| Aspect       | Current (static suite)      | Desired (parity cycle)                       | Migration |
|--------------|------------------------------|----------------------------------------------|-----------|
| Test origin  | pre-written C probes m1-m8   | per-feature, human-input-driven, on demand   | ADD intake + on-demand authoring |
| Language     | C                            | Zig probe + Elixir runner/comparator         | ADD Zig/Elixir templates; keep C as legacy |
| macOS run    | capture vectors              | + human validates understanding (checkpoint) | ADD the human checkpoint |
| rmxOS run    | batch-compared               | same probe, right after macOS                | keep (dual-run) |
| Outcome      | classification               | match->success / no-match->queue             | ADD decision + parity ledger |
| Backlog      | implicit                     | explicit improvements queue -> Arranger      | ADD ledger/queue |

Carries over: harness, build, result namespaces, JSON schema, env capture,
classification taxonomy. New: intake, Zig+Elixir per-feature convention, macOS
human-checkpoint, parity ledger/queue.

## Host / deployment (GitHub-synced)

- Reference host `mx-a64z` = `mm4.local` (M4 Mac Mini, macOS 27 beta, arm64).
  System-under-test `rx` = rmxOS guest. (`mx-x64z` = Intel macOS, optional.)

### Agent-repo topology (split 2026-06-20 — Oracle → dedicated Explorer + Gatekeeper)

The single oracle repo was split into THREE dedicated agent workspaces, each cloned
from the old oracle (identical at `9ed6170`, diverging as each specializes), each with
its OWN upstream:

| Workspace (local) | Upstream | Agent role |
|---|---|---|
| `/Users/me/wip-mach/rmx-explorer` | `git@github.com:lin72h/rmx-explorer.git` | **Explorer** — authors probes, captures `mx-a64z`/`rx` behavior vectors, owns the mismatch ledger |
| `/Users/me/wip-mach/rmx-gatekeeper` | `git@github.com:lin72h/rmx-gatekeeper.git` | **Gatekeeper** — evidence discipline, spend-gating, disposition records |
| `/Users/me/wip-mach/wip-gpt-oracle` | `git@github.com:lin72h/mach-oracle.git` | original oracle (legacy / oracle Elixir app + UI) |

- **Explorer home is now `rmx-explorer`** — `macos-validation/`, `findings/nx-r64z/`,
  `mx-a64z/`, `rx/` live here. The two explorer sub-agents sync via the explorer
  upstream: `explorer-mx-a64z` on `mm4` and `explorer-rx-x64z` locally both clone/pull
  `git@github.com:lin72h/rmx-explorer.git`. Probes build with stock clang +
  `codesign -s -`; no extra deps.
- **Cross-repo coordination (NEW, explorer↔gatekeeper now separate repos):** the
  Explorer publishes behavior vectors + the ledger to `rmx-explorer.git`; the Gatekeeper
  consumes them (pulls the explorer repo as a read-only reference, or the Explorer
  hands a vector/ledger snapshot) and writes its dispositions to `rmx-gatekeeper.git`.
  Default convention: Gatekeeper treats the Explorer repo as read-only upstream evidence,
  same as the Explorer treats real macOS as read-only truth. Settle the exact handoff
  (pull-reference vs snapshot-handoff) when the first cross-repo spend happens.
- Divergence plan: Explorer prunes oracle-only parts (Elixir UI app) over time;
  Gatekeeper keeps the evidence-gate/preflight/disposition tooling and prunes the parity
  probe specifics. Each starts by cleaning the 6 carried-over dirty `ui/*` WIP files
  (oracle noise; reversible — the oracle copy retains them).

## First step (per Coordinator): run the existing test cases on both

Before any new scaffolding: collect + run the EXISTING 16 C probes (m1/m2/
foundation) on both targets via the existing Makefile/harness, and look at the
first real discrepancy set.
- macOS: on `mm4`, `cd macos-validation && make && make run AGENT=mx-a64z` ->
  fresh `mx-a64z` vectors on macOS 27 (record the beta build; note any probe that
  won't build/run on 27 as version-sensitive, don't invent).
- rmxOS: `make run AGENT=rx` through the bhyve guest -> `rx` vectors.
- Compare (`compare-m2-oracle.py` pattern) -> first mismatch view + findings note.
This proves the GitHub-synced both-hosts loop end-to-end on what already exists,
THEN we add the per-feature parity cycle on top.

## Roles (minimal)

Terminology (2026-06-20): **Explorer + Gatekeeper = the "Rulers"** (each is a ruler — a
ruler measures rmxOS against macOS truth). The role name **"Oracle" is retired + reserved
for future use**; use Ruler/Rulers for the agents. "oracle" survives only in artifact
names (`mach-oracle.git`, `macos-oracle.v1` schema), not as a role. They are now dedicated
agents with their own repos (`rmx-explorer` / `rmx-gatekeeper`).

- **Explorer** (a Ruler) — authors the per-feature test (Zig+Elixir), runs both targets,
  produces the cycle outcome + the improvements-queue entry. Reference = real
  macOS, not our markers; does NOT gate the Implementer.
- **Gatekeeper** (a Ruler) — evidence discipline + spend-gating + dispositions; consumes
  Explorer evidence read-only across the repo boundary. **Also runs the Explorer's
  macOS-27 parity tests AS A VALIDATION SUITE against the Implementer's build** — so
  foundation-completion work (e.g. the dispatch sub-fixes) is proven solid *against macOS*,
  not by assertion, and the test stays a regression guard. Explorer authors (from macOS
  truth) → Implementer fixes → Gatekeeper validates. (Allowed under catalog-only: that
  freezes parity-DRIVEN fix Blocks, not validation of completion work.)
- **Human (Coordinator)** — provides the feature/understanding input; validates
  understanding at the macOS checkpoint (step 3).
- **Arranger** — triages the improvements queue (intrusiveness/benefit) into
  least-intrusive fix Blocks + accepted-divergence records.
- **Implementer** — closes selected discrepancies as normal `block-NNN` work.

## Decisions (resolved 2026-06-18)

- `mx-a64z` = `mm4.local` (M4 Mac Mini, macOS 27 beta). [confirm]
- IN PLACE, same repo, GitHub-synced via `lin72h/mach-oracle` on both hosts
  (Coordinator). No standalone-repo promotion.
- Existing test cases are C (not Elixir/Zig) — run them first as-is; new tests
  use Elixir/Zig per `test-plan.md`.
- Ground in existing wip-gpt doctrine (Coordinator): macos-semantic-validation-
  strategy.md, test-plan.md, bhyve-harness.md, project-doctrine.md, source-
  oracle-responsibility-boundary.md, macos-oracle-validation-agent-handoff.md.

## Sources (existing design decisions this aligns to)

- `macos-semantic-validation-strategy.md` — oracle scope, classification matrix,
  env capture, mach_msg-only, comparison policy.
- `test-plan.md` — language choice (Elixir high-level / Zig low-level / keep C),
  Zig 0.16, Elixir 1.20/OTP29.
- `project-doctrine.md` — revival-not-rewrite, classify-before-fix, source
  preference (donor>XNU-ref>local), Phase-0.5o parallel non-blocking.
- `source-oracle-responsibility-boundary.md` — oracle read-only toward rmxOS
  source; mismatch -> smallest falsifiable requirement -> Implementer fixes.
- `bhyve-harness.md` — rmxOS guest run/serial/parse contract.
- `macos-oracle-validation-agent-handoff.md` — namespaces (nx-r64z/mx-a64z/
  mx-x64z/rx), JSON schema floor.
