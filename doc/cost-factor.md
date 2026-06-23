# cost-factor.md — per-role cost factors for op-planning

Status: Arranger reference (workspace, living). The canonical cost map the Arranger weights when
planning ops — specifically when hunting **multi-issue** (parallel-pipeline) opportunities.
Cross-refs: [terminology.md](../terminology.md) §1 (roles) + §6 (issue/multi-issue/pipeline),
[backlogs/bl-000.md](../backlogs/bl-000.md).

## Why this exists

Ops execute on parallel pipelines (one per agent). Spreading independent, precondition-met work
across idle pipelines ("multi-issue") is how throughput is won — but pipelines are not equal cost.
The Arranger weights parallelization decisions by the spend below: prefer the cheap/free pipelines,
spend the expensive ones deliberately.

## Cost map (cost factor /100; lower = cheaper)

| role | cost /100 | model / note |
|---|---|---|
| **Explorer** | **0 — free** | runs on the GLM model (free for the Coordinator) |
| **Gatekeeper** | **0 — free** | runs on the GLM model |
| **Validator-GLM** | **0 — free** | the GLM model |
| **Validator-DS4P** | **4** | falsification / forward-instinct validator |
| **Implementer** | **30** | the executor (product-source changes) |
| **Arranger** (Fable) | **50** | issue + retire + Arbiter; the costliest cycle on the board |

Costs are **model-dependent and current-as-of-2026-06-23** — "free" reflects the GLM model being
free for the Coordinator today; if the model backing a role changes, update this row.

## How the Arranger applies it

- **Hunt multi-issue every planning turn.** When deciding "what's next," explicitly check which idle
  pipelines can take independent, precondition-met work in parallel — do not default to serial.
- **Parallelize freely onto the free roles** (Explorer / Gatekeeper / GLM). Zero marginal cost ⇒
  spreading discovery, soak/disposition, and enumeration across them is near-free velocity.
- **DS4P (4) is cheap** — use falsification liberally where it adds signal.
- **Implementer (30) is the expensive executor** — issue deliberately, batch, and **never
  duplicate**. A duplicate/churned Implementer dispatch is ~30/100 of pure waste (cf. the op-108
  number collision). Issue-hygiene matters most here.
- **Arranger (50) is the costliest cycle** — be decisive (fewer round-trips); **offload
  discovery/exploration to the free Explorer rather than doing it on Arranger cycles**; reserve
  Arranger spend for what only it can do: adjudication, routing, retirement tracking.

## Hard caveat — cost never overrides correctness

Rule-1 first-hand verification before retiring a load-bearing gate stays the Arranger's, and stays
first-hand. Cost-awareness optimizes *discovery delegation*, never *verification rigor*. A cheap
agent's report is still verified before a gate retires.
