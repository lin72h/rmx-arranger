# Roles

Status: canonical for the workflow: who the roles are, what may pass between them, and how
returned work is reviewed and closed. Terms: [terminology.md](terminology.md). Op states and the
board: [rob-mini-format.md](rob-mini-format.md). Brief and REPORT format:
[op-brief-forms.md](op-brief-forms.md). Current critical path: [now.md](now.md).
`wip-gpt/docs/role-governance.md` is being aligned to this file (op-339); where they differ, this
file wins.

## Roles

| Role | Repo | Does | Does not |
|---|---|---|---|
| **Coordinator** (human owner) | — | sets milestones and scope; relays every brief and REPORT by hand; accepts evidence; final appeal | — |
| **Arranger** (single seat; holds the **Arbiter** seat) | `rmx-arranger` | turns problems into ops, verifies returns first-hand, runs review, closes ops | write product source or any other repo |
| **Implementer** | `wip-gpt` (origin `project-rmx`) | sole writer of product source; builds and commits | grade its own work |
| **Explorer** | `rmx-explorer` | finds divergences from real macOS; authors parity probes; owns the mismatch ledger (`findings/nx-r64z`) | gate the Implementer |
| **Gatekeeper** | `rmx-gatekeeper` | establishes runtime fact in contained guests; owns evidence dispositions (accepted / not-accepted / consumed); guards closed work against macOS-truth and regression | accept on harness or stub facts |
| **Validators**: GLM, DS4P | `wip-glm`, `wip-ds4p` | independent correctness review of returned ops, with a 1–10 confidence. GLM finds what is *missing* (enumeration, completeness); DS4P finds what is *breakable* (falsification) | write, run guests, or dispose evidence |
| **Oracle** | `rmx-oracle` | consult: design, hypotheses, architectural ambiguity | validate or close ops |

Explorer and Gatekeeper instances are named on the "ruler" grammar in terminology §2 (for example
`rmx-explorer-rx-x64z`). The Coordinator decides; the Arranger proposes.

## How work flows

1. A problem lives in an IDQ file (`idq/id-NNN`). The milestone's critical path is in `now.md`.
2. The Arranger writes an op for **one agent in one repo** (`tools/rob new`). For discovered
   defects: the Explorer finds an observable divergence from macOS; the Arranger triages it as
   solidity-blocker or cosmetic (rulebook Rule 10); the fix op carries the Explorer's macOS
   reference as its acceptance criterion; the Implementer implements to it and the Gatekeeper
   validates against it. Non-observable internals (races, invariants, performance) the
   Implementer diagnoses itself.
3. The Coordinator relays the brief (`issued`) and later relays the REPORT back (`returned`).
4. The return is reviewed at its size (below). The Arranger then closes the op, or drops it and
   writes a new one.
5. The Gatekeeper guards closed work against macOS-truth and regression.

Ops for different agents run in parallel and may close in any order.

## Edges

| From | To | Carries | Via |
|---|---|---|---|
| Arranger | any agent | brief (op) | Coordinator, by hand |
| any agent | Arranger | REPORT | Coordinator, by hand |
| Arranger | Validator | review brief for a returned op | Coordinator, by hand |
| Arranger | Oracle | consult question | Coordinator, by hand |
| Explorer | Gatekeeper | evidence | Gatekeeper reads it |

Each agent writes only its own repo. Reading another repo is allowed when a brief names the path;
reading never grants write authority. Cross-repo work is a separate op for the owning agent.

## Review and closure

Source: Coordinator 2026-06-20; risk-sized and single threshold 2026-09-28 (j-20260927-003).

Size each return when it arrives, by the difficulty of adjudicating it (evidence to re-verify,
cross-repo reach, doctrine tension), not by the size of the original op:

| Size | Reviewer | Closes when |
|---|---|---|
| S / M | Arranger, first-hand | the Arranger verifies it |
| L | one Validator, chosen by the question (completeness → GLM, breakability → DS4P) | confidence ≥8/10 |
| XL, or on the release critical path | both Validators | both ≥8/10 **and** they agree |

- The Arranger may raise a gate one level, never lower it.
- Whoever reviews verifies first-hand. At ≥8 the Arranger closes on the Validator's word after a
  light provenance check, not a second review.
- Below 8, or when Validators conflict, the **Arbiter** (the Arranger) makes the final call:
  close, do-not-close, or remediate with a new op. Only the Arbiter does this, subject to
  Coordinator override; how to arbitrate is rulebook Rule 6.
- Closing also requires every produced commit to be reachable on origin.

**Validators and Gatekeeper are two different checks; both are needed.**

| | Validators | Gatekeeper |
|---|---|---|
| When | before closure | after closure |
| Asks | is this op correctly implemented? | does the closed result behave like macOS, and did anything regress? |
| Standard | internal correctness, evidence validity | macOS behavior and regression |
| Scope | this op | the accumulated closed state |

An op can pass the Validators yet fail the Gatekeeper, and the reverse.

## History

Old role and workflow names (Maestro, Conductor, Composer, Ruler-as-Oracle, block, ROB, EXU,
retire) are mapped in terminology §9. The June design of this flow is in
`doc/archive/discovery-implementation-pipeline.md`.
