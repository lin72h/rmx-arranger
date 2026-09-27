# Roles

Status: the canonical role catalog for the rmxOS-revival workflow — *who* the roles are and
*what* each does. Process mechanics live in the referenced docs; this is the definitions
home. (Onboarding narrative is separate: `role-model-onboarding.md`.)

## Role tree

```
Coordinator (human owner: doctrine, acceptance, routing, scope, appeals, Milestones)
├── Oracle (more powerful consult-agent; the Arranger escalates to it when stuck)
└── Arranger (+ Arbiter seat): writes ops, reviews returns, closes them
    ├── Implementer ............ execution pipeline (sole product-write authority)
    ├── Rulers
    │   ├── Explorer ........... discovery pipeline
    │   └── Gatekeeper ......... POST-retirement final guard
    └── Validators GLM + DS4P .. PRE-retirement correctness gate (superscalar)
```

## How an op flows

The Arranger writes an op (one agent, one repo) → the **Coordinator relays it by hand** → the
agent executes and returns a REPORT → the Coordinator relays the REPORT back → the op is reviewed
at its risk size (Arranger, one Validator, or both) → the Arranger **closes** it → the
**Gatekeeper** guards the closed state against macOS-truth. Ops for different agents run in
parallel and may close in any order. States and format: `rob-mini-format.md`,
`op-brief-forms.md`; critical path: `now.md`.

## Edges (who may send what to whom)

| From | To | Carries | Via |
|---|---|---|---|
| Arranger | any agent | brief (op) | Coordinator, by hand |
| any agent | Arranger | REPORT | Coordinator, by hand |
| Arranger | Validator | review brief for a returned op | Coordinator, by hand |
| Arranger | Oracle | consult question | Coordinator, by hand |
| Explorer | Gatekeeper | evidence, read-only across the repo boundary | Gatekeeper reads it |

Writes: each agent writes only its own repo; the Implementer alone writes product source.

## Definitions

- **Coordinator** — the human owner. All authority delegates from here; acceptance of
  evidence/claims, scope changes, doctrine changes, and appeals terminate here. Holds the
  Milestones. The Arranger proposes; the Coordinator decides.
- **Oracle** — a more powerful agent the Arranger **consults** when it cannot resolve a
  problem itself (escalation/consultation resource, Coordinator-mediated). Repurposed
  2026-06-20 from the retired "Composer" placeholder. **NOT** the old explorer+gatekeeper
  "Oracle" — that union is now the **Rulers**.
- **Arranger** — writes ops, reviews what comes back, and closes them. Decomposes a
  Milestone into ops, issues them to pipelines, reviews returned work, sequences. Holds the
  **Arbiter** seat. No product-write authority.
- **Arbiter** (held by the Arranger) — steps in **only** when a Validator is <8/10 or two
  conflict; gives the **final call** (Coordinator-override aside); verifies the decisive
  evidence **first-hand**; narrow (resolves the open point, doesn't re-do the review).
  Recuses to the Coordinator if the Arranger's own finding is party to the conflict.
- **Implementer** — the **execution pipeline**; **sole** product/source write authority
  (commits, scaffolds, records). Executes issued ops (the implementation). Does **not**
  self-grade — the Validators retire its op.
- **Rulers** — Explorer + Gatekeeper, two **dedicated agents** (the ex-"Oracle" union; own
  repos `rmx-explorer` / `rmx-gatekeeper`, not modes of one agent):
  - **Explorer** (discovery pipeline) — authors macOS-parity probes, captures behavior
    vectors on both targets, owns the mismatch ledger (`findings/nx-r64z`). Reference =
    **real macOS**, not our markers. Vocabulary "ready / not-ready / smallest-requirement".
    Does not gate the Implementer.
  - **Gatekeeper** (**POST-retirement final guard**) — validates the *retired* result
    against macOS-truth: catches regression / behavioral divergence in already-retired
    changes. Owns evidence dispositions (accepted / not-accepted / consumed) + the evidence
    discipline (raw-evidence-immutable, spend-gating). Consumes Explorer evidence read-only
    across the repo boundary.
- **Validators (GLM + DS4P)** — the **PRE-retirement correctness gate.** Independent,
  **superscalar** reviewers of the Implementer's op: *"is it correctly implemented?"*
  (soundness, evidence-validity). **GLM** = enumeration/completeness; **DS4P** =
  falsification/forward-instinct. Review is risk-sized (S/M Arranger, L one Validator, XL/critical-path
  both); close at ≥8/10 (and agreement when two review); below threshold or conflict → the Arbiter.
  Rule: `discovery-implementation-pipeline.md` § Retirement & escalation. No write authority, no dispositions. Maintain the
  shared `validator-rulebook.md`.

## Validators vs Gatekeeper — two stages, two standards (need both)

| | **Validators (GLM + DS4P)** | **Gatekeeper** |
|---|---|---|
| Stage | PRE-retirement | POST-retirement |
| Asks | "Is this op *correctly implemented*?" | "Does the retired result *behave like macOS* — and did it *regress*?" |
| Standard | correctness (internal) | macOS-truth + regression (external) |
| Prevents | a wrong implementation from retiring | a regression slipping into already-retired changes |
| Scope | this op | the retired state vs macOS-truth |

An op can pass the Validators (code is sound) yet fail the Gatekeeper (behavior diverges
from macOS / regressed something), and the reverse. Full treatment +
OoO analogy: `discovery-implementation-pipeline.md`.

## Retired / renamed terms

- **Maestro → Coordinator**, **Conductor → Arranger** (2026-06-13).
- **Oracle (old = explorer+gatekeeper union) → Ruler**; **Composer → Oracle** (consult-agent)
  (2026-06-20).
- **block-NNN → op-NNN**; "dispatch" → "issue"; "accept/done" → "retire" (2026-06-20).
- Frozen/committed records keep the old terms (historical); live work uses the new.

## References

- `discovery-implementation-pipeline.md` — the pipeline, the Validators-vs-Gatekeeper
  detail, the Retirement & escalation rule.
- `terminology.md` — the OoO model, naming/namespace conventions.
- `validator-rulebook.md` — the Validators' craft-discipline.
- `explorer-parity-cycle-workflow.md` — the Explorer's per-feature parity cycle.
- Canonical doctrine surface (authoritative, product repo): `wip-gpt/docs/role-governance.md`
  — *currently stale on the recent role evolution; sync is a tracked Implementer op.*
