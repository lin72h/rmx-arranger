# Roles

Status: canonical for the workflow: who the roles are, what may pass between them, and how
returned work is reviewed and closed. Terms: [terminology.md](terminology.md). Op states and the
board: [rob-mini-format.md](rob-mini-format.md). Brief and REPORT format:
[op-brief-forms.md](op-brief-forms.md). Current critical path: [now.md](now.md).
The Arranger keeps every role repo aligned with this file through one-way access (§ Edges);
agents read only their own repo.

## Roles

| Role | Repo | Does | Does not |
|---|---|---|---|
| **Coordinator** (human owner) | — | sets milestones and scope; relays every brief and REPORT by hand; accepts evidence; final appeal | — |
| **Arranger** (holds the **Arbiter** seat) | `rmx-arranger` | turns problems into ops, verifies returns first-hand, runs review, closes ops; keeps every role repo's instructions aligned (one-way access) | write product source; change evidence or attempt accounting |
| **Implementer** | `rmx-implementer` (origin `project-rmx`) | sole writer of product source; builds and commits | grade its own work |
| **Explorer**: explorer1 (rx-x64z), explorer2 (mx-a64z) | `rmx-explorer1` here; `rmx-explorer2` on mm4 | finds divergences from real macOS; authors parity probes; owns the mismatch ledger (`findings/nx-r64z`) | gate the Implementer |
| **Gatekeeper**: gatekeeper1 (rx-x64z), gatekeeper2 (mx-a64z) | `rmx-gatekeeper1` here; `rmx-gatekeeper2` on mm4 | establishes runtime fact in contained guests; owns evidence dispositions (accepted / not-accepted / consumed); guards closed work against macOS-truth and regression | accept on harness or stub facts |
| **Validators**: validator1 (GLM), validator2 (DS4P), validator3 | `rmx-validator1`, `rmx-validator2`, `rmx-validator3` | independent correctness review of returned ops, with a 1–10 confidence. GLM finds what is *missing* (enumeration, completeness); DS4P finds what is *breakable* (falsification) | write, run guests, or dispose evidence |
| **Advisor**: advisor1, advisor2, advisor3 | `rmx-advisor1`, `rmx-advisor2`, `rmx-advisor3` | consult of last resort: design, hypotheses, architectural ambiguity | review correctness, validate or close ops, write product source |

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
| Arranger | Advisor | consult question | Coordinator, by hand |
| Explorer | Gatekeeper | evidence | Gatekeeper reads it |
| Arranger | any role repo | direct changes to instructions, `OPS.md`, and docs | one-way access; a NOTICE via the Coordinator when it affects the agent's work |

Each agent other than the Arranger writes only its own repo and reads another repo only when a
brief names the path; reading never grants write authority. An agent's cross-repo work is a
separate op for the owning agent.

**One-way access** (Coordinator, 2026-09-28). The Arranger can read and change every role repo; no
other agent reads or writes the Arranger's repo, so agents see its work only through briefs,
notices, and the files in their own repo. The Arranger uses this to keep each role repo
self-contained and aligned with this file. When a change could affect what an agent knows or is
working on (its instructions, its op contract, paths it uses, files of an op in flight), the
Arranger sends a NOTICE through the Coordinator; other changes need none. Limits: raw evidence,
evidence dispositions, and guest-attempt accounting are never changed (corrections are new
records), and product source stays the Implementer's.

Each role repo has an `AGENTS.md` (standing rules) and an `OPS.md` (its op contract: brief format,
defaults, and the REPORT block), so a brief carries only what is specific to its op.

## Templates and instances

Source: Coordinator, 2026-09-28 (j-20260927-016, singleton layout j-20260927-018). Every role is a
class with a template (its standing text) and instances; `rmx-role0` is the root template with
text every role shares (project context, the NOTICE rule, the REPORT block, the evidence limits).

- **A role with one instance** is one repo with no number, `rmx-<role>`. The repo is the instance
  (implicitly instance 1, id `<role>`), and its template lives inside it in `<role>0/`:
  `rmx-arranger/arranger0/`, and `rmx-implementer/implementer0/` once op-364 returns.
- **A role with several instances** has a template repo `rmx-<role>0` and numbered instance repos
  `rmx-<role>N` with ids `<role>N`: `rmx-validator0` and `rmx-validator1` to `rmx-validator3`.
- **Growing a singleton**: move `<role>0/` out to `rmx-<role>0`, rename the repo `rmx-<role>1`,
  and add `rmx-<role>2`.
- **An instance on another host** (the Gatekeeper's and Explorer's Mac instances on mm4) exists
  only there, and ops name its repo as `host:/path`. The Arranger keeps no copy and works on it
  over SSH; the Coordinator relays to its agent the same way. A plain copy of its class template
  (no `.git`) sits beside it for reading; replace it when the template changes. To re-render the
  instance, copy its `instance.json`, `.rendered.lock`, `LOCAL.md`, and rendered files into a
  temporary workspace that links `rmx-role0` and the class template, run
  `ROLES_WORKSPACE=<that workspace> tools/roles render <instance>`, and copy the rendered files
  and lock back. `tools/roles check` covers only this host.

Every instance repo holds:

- `instance.json`: only what differs from the template (variables and block overrides),
  maintained by the Arranger;
- rendered files (`AGENTS.md`, `OPS.md`, role docs), which begin "Rendered by the Arranger" and
  are regenerated with `tools/roles`, never edited in place;
- `LOCAL.md`: the agent's own notes and lessons, which the Arranger may promote into the
  template;
- `.rendered.lock`: digests that stop a render from overwriting local edits;
- everything else the instance works on.

Current classes also include gatekeeper0 (gatekeeper1 here, gatekeeper2 on mm4), explorer0
(explorer1 here, explorer2 on mm4), and advisor0 (advisor1, advisor2, advisor3; the Advisor was
called the Oracle until 2026-09-28).

## Review and closure

Source: Coordinator 2026-06-20; risk-sized and single threshold 2026-09-28 (j-20260927-003).

Size each return when it arrives, by the difficulty of adjudicating it (evidence to re-verify,
cross-repo reach, doctrine tension), not by the size of the original op:

| Size | Reviewer | Closes when |
|---|---|---|
| S / M | Arranger, first-hand | the Arranger verifies it |
| L | one Validator, chosen by the question and cost (§ Choosing a Validator) | confidence ≥8/10 |
| XL, or on the release critical path | two Validators, by default validator1 + validator2 | both ≥8/10 **and** they agree |

- The Arranger may raise a gate one level, never lower it.
- Whoever reviews verifies first-hand. At ≥8 the Arranger closes on the Validator's word after a
  light provenance check, not a second review.
- Below 8, or when Validators conflict, the **Arbiter** (the Arranger) makes the final call:
  close, do-not-close, or remediate with a new op. Only the Arbiter does this, subject to
  Coordinator override; how to arbitrate is rulebook Rule 6. Before ruling, the Arbiter may ask
  validator3 for a third opinion.
- Closing also requires every produced commit to be reachable on origin.

### Choosing a Validator

Source: Coordinator, 2026-09-28 (j-20260927-021). Risk decides how many reviewers; the question
and cost decide which. Costs are relative (0 free, 10 most expensive) and are kept only here: never
in a role template or instance file, where Validators would see them and could be biased by them.

| Validator | Strength | Cost |
|---|---|---|
| validator1 (GLM) | completeness: finds what is missing | 0 (free) |
| validator2 (DS4P) | falsification: finds what breaks | 1 |
| validator3 (model seated per session by the Coordinator) | general | luna-max 1, sol-medium 3, astra-medium 6, astra-max 8, astra-ultra 9 |

- The default pair for XL or critical-path gates is validator1 + validator2 (cost 1 in total).
- For an L gate, use validator1 when the question is completeness and validator2 when it is
  falsification.
- Use validator3 as a third opinion when the pair disagrees or scores below 8, or when a question
  needs a stronger model. Choose the tier by stakes: luna-max or sol-medium for routine checks,
  astra-medium for hard ones, astra-max or astra-ultra only for release-deciding calls. Name the
  tier in the op's `agent` field, for example `validator3 (astra-medium)`.

**Validators and Gatekeeper are two different checks; both are needed.**

| | Validators | Gatekeeper |
|---|---|---|
| When | before closure | after closure |
| Asks | is this op correctly implemented? | does the closed result behave like macOS, and did anything regress? |
| Standard | internal correctness, evidence validity | macOS behavior and regression |
| Scope | this op | the accumulated closed state |

An op can pass the Validators yet fail the Gatekeeper, and the reverse.

## History

Old role and workflow names (Maestro, Conductor, Composer, Ruler-as-Oracle, Oracle, block, ROB,
EXU, retire) are mapped in terminology §9. The June design of this flow is in
`doc/archive/discovery-implementation-pipeline.md`.
