# Discovery → Implementation Pipeline — splitting the Explorer and Implementer

Status: Arranger doctrine (workspace, living). The transition plan from "Implementer does
everything (hunt + fix + self-grade)" toward a parallel pipeline: **the Explorer DISCOVERS
bugs (via macOS-parity), the Implementer IMPLEMENTS the fixes, the Gatekeeper VALIDATES** —
the three stages running in parallel. macOS-27 is the truth that *defines* what a bug is.

## Why split

Today the Implementer hunts for the bug, fixes it, and grades itself against its own smoke
(block-081 was exactly this). Three problems: (1) the correctness standard is the
Implementer's judgment, not macOS; (2) hunting + fixing are serialized in one role; (3)
coverage is opportunistic (only what the Implementer stumbles on). Splitting fixes all
three: macOS defines correctness, the two functions run in parallel, and the parity catalog
covers systematically.

## The target pipeline (steady state)

```
 EXPLORER                 ARRANGER              IMPLEMENTER            GATEKEEPER
 discover (parity)   ->   triage queue     ->   implement to       -> validate fix vs
 macOS vs rmxOS           solidity-blocker      the macOS-truth        the macOS reference
 = divergence queue       -> fix Block          spec (no hunting,      (regression guard)
 (the bug backlog)        cosmetic -> defer      no self-grading)
```

**Parallel, pipelined:** Explorer discovers batch N+1 **while** Implementer fixes batch N
**while** Gatekeeper validates batch N-1. The Explorer never waits on the Implementer; it
keeps cataloging *ahead*, so the queue stays full. The Arranger is the buffer/triage between
discovery and implementation.

## The discovery split — what migrates, what stays

- **Migrates to the Explorer — OBSERVABLE behavioral divergences:** API returns, IPC
  servicing, error codes, dispatch behavior — anything a parity probe can *see* differ from
  macOS. (block-081's bugs — MACH_RECV source dark, KWQ abort — were this class; the
  Implementer only self-discovered them because the Explorer wasn't ready yet.)
- **Stays with the Implementer — NON-OBSERVABLE internals:** races, invariant violations,
  perf, anything that doesn't surface in a probe. The Implementer self-diagnoses these with
  its own instrumentation. The Explorer can't catalog what it can't observe.

So the rule: **as Explorer coverage grows, observable divergences move from
Implementer-self-discovery to Explorer-discovery; the Implementer keeps the
non-observable internals + all the actual implementation.**

## Catalog-only, refined

The standing "catalog-only / 1.0-solid-first" freeze splits by the divergence's nature:
- **Cosmetic parity gaps** (macOS behaviors that don't block solidity) → stay cataloged,
  deferred to post-1.0. Still frozen.
- **Solidity-blocker gaps** (the Explorer finds something that blocks rmxOS from working
  like macOS — e.g. dispatch not servicing) → become fix Blocks now. This is the Explorer
  *feeding* the Implementer — the whole point of the split, and it IS the 1.0 track.

The Arranger's triage separates the two: solidity-blocker → Block; cosmetic → ledger.

## The gradual phases (don't hard-switch)

**Phase A — prove the loop once (NOW).** Run block-082: Explorer authors the macOS-27
dispatch reference, explorer-rx captures the *post-block-081* rmxOS behavior, Gatekeeper
validates the landed fix vs macOS-truth. First real exercise of the loop on a real fix.
Outcome either ratifies block-081 or finds a gap our self-smoke missed — both prove the loop
works. **Prerequisite: don't expand the model until the loop is proven once.**

**Phase B — Explorer discovers the NEXT area, in parallel.** While the Implementer does the
next foundation-completion item, the Explorer catalogs the area *ahead* (e.g. the next
dispatch/launchd/notifyd/ASL behavior) to surface its gaps *before* the Implementer reaches
them. First instance of parallel discovery feeding implementation: Explorer catalogs area X
→ Arranger turns the solidity-blockers into Blocks → Implementer implements. **The
Implementer stops self-hunting in areas the Explorer covers.**

**Phase C — Explorer as the primary discovery engine; full pipeline.** The Explorer's
continuous catalog is the primary source for observable foundation gaps; the Implementer
works the queue; the three stages run steady-state parallel. Implementer self-discovery is
reserved for non-observable internals. The macOS-parity catalog *is* the bug backlog.

## Mechanics to stand up

1. **The divergence queue = the Explorer's mismatch ledger** (`findings/nx-r64z`), tagged
   per entry: `solidity-blocker` vs `cosmetic` + intrusiveness. The tag drives triage.
2. **Triage = Arranger** turns `solidity-blocker` entries into fix Blocks (partial lift of
   catalog-only for solidity-blockers; cosmetic stays frozen).
3. **Handoff contract = the macOS-truth spec travels with the Block.** Each fix Block
   carries the Explorer's macOS reference vectors as the acceptance criterion. The
   Implementer implements *to that spec*; the Gatekeeper validates *against it*. No
   self-grading.
4. **Parallel discipline = the Explorer always catalogs AHEAD** of the Implementer (one area
   forward), so the Implementer never idles hunting and never self-discovers an
   observable bug.

## Roles, restated for the pipeline

- **Explorer** — the discovery engine. Continuous macOS-parity; produces the tagged
  divergence queue. Owns "what is a bug" (= deviation from macOS), never "how to fix it."
- **Implementer** — the implementation engine. Pulls Blocks, implements to the macOS spec.
  Owns the fix + non-observable internals; does NOT define correctness or self-grade.
- **Gatekeeper** — the validation engine. Validates each fix vs the macOS reference;
  regression-guards.
- **Arranger** — the buffer/triage. Decomposes the queue into Blocks, sequences, keeps the
  pipeline flowing, holds the change-lane discipline.

## Validators vs Gatekeeper — two validation stages, two standards (Coordinator 2026-06-20)

Both validate, but at *different stages* against *different standards* — you need both.

| | **Validators (GLM + DS4P)** | **Gatekeeper (rmx-gatekeeper)** |
|---|---|---|
| Stage | **PRE-retirement** | **POST-retirement** |
| Question | "Is this op *correctly implemented*?" | "Does the retired result *behave like macOS* — and did it *regress* anything?" |
| Standard | correctness (code soundness, logic, evidence-validity, falsification) | macOS-behavioral-truth + regression |
| Prevents | a **wrong implementation from retiring** | a **regression/divergence in already-retired changes** slipping through |
| Scope | this op | the retired state (recent changes) vs macOS-truth |
| When | gates retirement | the **final guard**, after retirement |

**Flow:** execute (Implementer) → **Validators** gate retirement (correctness; ≥8/10 +
agree) → **RETIRE** → **Gatekeeper** guards the retired state against macOS-truth.

**Why both — they catch different classes.** An op can pass the Validators (the code *is
correct*) yet fail the Gatekeeper (the *behavior* diverges from macOS, or it regressed
something). And the reverse — behavior matches macOS but the implementation is internally
unsound. Validators ask *"is it right?"*; the Gatekeeper asks *"does it match macOS, and did
it break anything?"* — internal correctness vs external truth, per-op vs accumulated-state.

**OoO analogy:** the Validators are the retirement-validation logic (an op can't commit if
it's wrong/faulted); the Gatekeeper is the post-commit guard that verifies the committed
architectural state against the golden reference (real macOS) and catches mis-speculation /
regression after the fact.

## Retirement & escalation rule (GOVERNING, Coordinator 2026-06-20)

An op flowing through the Validator pipelines (GLM + DS4P, superscalar) **retires ONLY if
both ≥8/10 AND they agree.** Otherwise:

- **If either Validator is <8/10, OR they conflict → the Arbiter (Arranger) steps in — and
  ONLY the Arbiter.** No other pipeline adjudicates.
- **The Arbiter gives the FINAL call** (subject only to Coordinator override). When stepping
  in, the Arbiter **verifies the decisive evidence first-hand**, then rules one of:
  *retire* / *do-not-retire* / *remediate* (issue a re-spin op).
- The Arbiter's step-in is **narrow**: resolve the specific sub-threshold/conflict question,
  not re-do the whole review. The Validators' ≥8 findings stand; the Arbiter only adjudicates
  the open point.

Why "only the Arbiter": a single, accountable final-call point prevents adjudication drift
and keeps the Validators as parallel reviewers, not competing deciders. First exercised on
op-081 (DS4P 7/10 + GLM 8.5/10 split on the KWQ question → Arbiter verified the rc.local
export first-hand → do-not-retire → remediation op-081-R).

## The honest checkpoint

The split only becomes real when discovery actually leaves the Implementer. The signal of
success: a foundation bug gets fixed where **the Implementer never hunted for it** — the
Explorer handed it the macOS-truth gap and the Implementer just implemented. Until that
happens at least once (Phase A→B), the pipeline is design, not practice.
