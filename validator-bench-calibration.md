# Validator Bench Calibration

Status: living working document (Arranger workspace). Companion to
`arranger-block-workflow.md`. Evolves as new review evidence accumulates —
update the evidence lines when a validator demonstrates a new strength or miss.

This documents what the two Validators (GLM, DS4P) are each strongest at, so the
Arranger's routing recommendation on an **assignee-neutral** request matches the
question to the reviewer. Routing is always the Coordinator's call; this is the
recommendation rationale.

Both Validators: review-only (no writes, dispositions, or guest runs); verify
first-hand at the line level; cite file:line; produce reliable bottom-line
verdicts at high confidence (typically 9–9.5/10).

## GLM — enumeration and completeness

Signature: *exhaustive coverage of a space.* When the question is "did we
account for everything," GLM is the one. **Catches the missing thing.**

Strengths:
- Caller / guard / clause enumeration; comprehensive mapping tables.
- Kernel-internals and ABI correctness.
- Arithmetic and value derivations verified by hand.

Severity tags are calibrated — when GLM says no-blockers, it means it.

Session evidence:
- Found the **fourth dropped clause** (Implementer fallback-reason duty) in the
  role-governance consolidation that DS4P, the Arranger's own review, and the
  prior safeguard-restore had all missed.
- Token-0 fix: enumerated **all 19 `server_preflight` callers**, verified
  `make_client_id(pid,0)` collision-free first-hand at `libnotify.c:47`, and
  localized the bug to `server_preflight` by confirming sibling sites already
  handled token-0.
- Review point 5: full assertion-by-assertion fidelity table (old shell checks
  → new Elixir validator).

## DS4P — falsification and forward instinct

Signature: *"what could break this, and what's missing for next time."* When the
question is adversarial — can this claim be falsified, does this change touch
another path — DS4P is the one. **Catches the breakable thing.**

Strengths:
- Blast radius and contract-conformance ("does this respect the documented API
  contract").
- Edge cases and byte-level tracing.
- Precedent citation; forward-looking refinements that prevent future failures.

Operating caveat: **DS4P over-tags severity** — it labels satisfied
prerequisites `blocker`. Read its bottom line, not its tags; the Arranger
normalizes the severity before reporting up.

Session evidence:
- Review point 1 (concurrency design): surfaced the emission-site /
  producer-attribution requirement, the registered-name correlation, the
  first-failing-layer rule, the stale-lock edge case, and the AAD reconciliation
  field — a stack of refinements that pre-empted future failures.
- Review point 5: went to **raw bytes** (`cat -v` showing `data=1^M`, counted
  152 CRs) to prove the CRLF diagnosis — deeper than anyone else went.
- Token-0 fix: worked the blast radius through the centralized-preflight pattern
  and traced the dead-client chain end-to-end.

## Neither dominates

The two are a **complementary pair, and each has caught what the other missed**:
GLM found the dropped clause DS4P missed; DS4P went to raw bytes where GLM
stopped at the marker. That mutual coverage is the argument for fanning out to
both on high-stakes work — e.g. the token-0 product fix, where DS4P answered
"does `>=0` break another path" and GLM answered "did we cover every caller."
Different halves of the same risk; the union was airtight.

## Routing guidance

| Question type | Lean |
| --- | --- |
| Completeness sweep / "did anything get dropped" | GLM |
| Kernel-internals / ABI correctness | GLM |
| Blast radius / "does this break another path" | DS4P |
| Falsifiability / contract-conformance / edge cases | DS4P |
| "What's missing for next time" | DS4P |
| Product fixes, claim-expanding gates, contested findings | both (split the question) |

Always: requests are drafted assignee-neutral; the Coordinator routes (often to
all — review is cheap, exploiting it is deliberate). Normalize DS4P's severity
tags to its bottom line.
