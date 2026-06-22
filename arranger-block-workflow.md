# Arranger Block Workflow

Status: living working document (Arranger workspace). Not yet canonical doctrine.
Promote into `wip-gpt` doctrine via the Implementer once it stabilizes.

This documents the operating loop the Coordinator and Arranger use to drive work
across the agent organization. It captures *how we dispatch*, not the role
authorities themselves (those live in `wip-gpt/docs/role-governance.md`).

## Terminology (2026-06-13 swap)

A pure term swap, no semantic change:

- **Coordinator** — the human owner (formerly "Maestro"). Root authority:
  doctrine, lanes, scope, acceptance, routing, appeals.
- **Oracle** — a more powerful agent the Arranger CONSULTS when it cannot resolve
  a problem itself (escalation/consultation resource, Coordinator-mediated).
  Repurposed 2026-06-20 from the retired "Composer" placeholder term. NOTE: this is
  NOT the old explorer+gatekeeper "Oracle" — that union is now the **Rulers**.
- **Arranger** — formerly "Conductor". Decomposes Milestones into discrete
  Blocks, targets each Block to an agent, reviews returned work first-hand, and
  sequences. Also holds the **Arbiter** seat. Consults the Oracle when stuck.
- Unchanged: **Implementer**, **Rulers** (Explorer + Gatekeeper — dedicated
  agents), **Validators** (GLM, DS4P), **Arbiter**.

Milestones/strategy stay Coordinator-held (the former Composer slot was never
staffed; its term is now repurposed to the consult-Oracle). The Arranger *arranges*
the plan into per-agent blocks; the Coordinator *coordinates* routing and owns the
decisions; the Oracle is consulted when the Arranger is stuck.

## Role tree

```text
Coordinator (human owner: doctrine, lanes, scope, acceptance, routing, appeals,
│            Milestones / overall strategy)
├── Oracle (more powerful agent; the Arranger CONSULTS it when stuck;
│           Coordinator-mediated) ......... [repurposed from ex-"Composer"]
└── Arranger (agent: Milestone -> Blocks, targets agents, reviews) + Arbiter seat
    ├── Implementer (source repo writes, scaffolds, activation records)
    ├── Rulers (Explorer + Gatekeeper — dedicated agents, own repos)
    ├── Validators (independent review: GLM, DS4P)
    └── Arbiter (resolves conflicting Validator findings; held by Arranger)
```

## Milestones and Blocks — the two-level decomposition

Work descends in two named units:

- **Milestone** (Coordinator) — a roadmap-scale unit of strategy, e.g. "close the
  N2 concurrency gate" or "Phase 0.85 generic handoff-authority extraction".
  The Coordinator defines Milestones, their order, and their acceptance intent
  (the former "Composer" slot for this was never staffed; the Coordinator holds it).
- **Block** (Arranger) — a single paste-ready request to one agent. The
  Arranger breaks a Milestone into its Block sequence (e.g. design -> scaffold
  -> activation record -> host readiness -> pre-spend review -> guest attempt),
  marks each Block parallel / sequential / gated, and targets it to an agent.

The handoff: the Coordinator supplies a Milestone (goal + constraints + acceptance
intent); the Arranger returns a Block plan and drives it to completion, reporting
Milestone-level status back up. When the Arranger cannot resolve something itself,
it consults the **Oracle** (the more powerful consult-agent, Coordinator-mediated).

## The operating loop

1. **Agent REPORT arrives** (relayed by the Coordinator).
2. **Arranger verifies first-hand.** Never accept a report's claims on trust —
   `git show` the cited commits, reproduce the cited hashes, read the changed
   lines. A report describes intent; verification confirms fact.
3. **Arranger reviews and adjudicates.** Findings-first. If Validators conflict,
   the Arbiter seat resolves (and recuses to the Coordinator if the conflict
   involves the Arranger's own finding).
4. **Arranger arranges the next Blocks** — one Block per agent task, paste-ready.
5. **Arranger marks dependencies explicitly** (see below).
6. **Coordinator routes** the Blocks (copy-paste) and makes acceptance decisions.
7. Loop.

## Block anatomy

Each Block is a self-contained, paste-ready request addressed to exactly one
agent role. A Block states:

- the target role and (for Oracle) the mode;
- the lane (evidence vs docs) per Rule 1;
- the governing pin(s) — the commits/records the work is bound to;
- the concrete task;
- scope limits (what the agent must NOT do);
- the required **REPORT block** terminal format.

### Block numbering

Blocks are named **`block-NNN`** where `NNN` is a zero-padded three-digit
sequence from `001` to `999` (e.g. `block-001`, `block-047`, `block-312`).
Numbers are assigned sequentially across the whole project and are never
reused — a `block-NNN` always refers to the same dispatch. (Superseded the
earlier single-letter A–Z scheme on 2026-06-16; it ran out of headroom for a
project this size.) Blocks are ephemeral dispatch labels, not committed
artifacts, so historical single-letter blocks are not renumbered; the
`block-NNN` scheme applies to all blocks issued from the changeover forward.

### REPORT block convention

Every agent ends its report with a fixed block so the Arranger's verification
collapses to a few git commands:

```text
REPORT
commits:      <hash> <subject>   (one per line)
record:       <governing record path> @ <hash>   | n/a (docs-lane)
status-lines: <zero-status lines> | none
attempts:     <n consumed>  serials: <paths | none>
artifacts:    <files / run dirs touched>
next-hop:     <ready | blocked: reason | disposition>
```

## Parallel vs. sequential — the explicit signal

The Arranger MUST tell the Coordinator, for every batch of Blocks:

- **Parallel** — Blocks with no dependency on each other's output. The
  Coordinator can paste them in any order / at once.
- **Sequential** — a Block that needs a value (usually a commit pin) from
  another Block's REPORT. The Arranger marks these with a fill-in placeholder
  (e.g. `<amendment pin>`) and states which prior REPORT supplies it.
- **Gated** — a Block that must not be pasted until a prior Block returns a
  specific result (e.g. a guest-spend Block held until host-readiness = ready
  AND pre-spend review = no blockers). The Arranger writes these with the gate
  conditions inline and labels them HOLD.

Rule of thumb: independent reviews fan out in parallel (Validators are cheap);
anything that pins a not-yet-existing commit is sequential; anything that spends
a guest attempt or is otherwise irreversible is gated.

## Pin-fill discipline (the `<placeholder pin>` method)

When a Block depends on a commit that does not exist yet, the Arranger writes a
**named angle-bracket placeholder** in the Block — e.g. `<accept-fill pin>`,
`<amendment pin>`, `<scaffold head>` — instead of inventing or guessing a hash.
The placeholder is filled from the supplying Block's REPORT before the dependent
Block is pasted.

Why this method works:

- **No stale or fabricated pins.** A Block never carries a hash that doesn't
  exist yet or one copied from the wrong commit. An agent's "Tree state
  reviewed" / governing pin must match the commit it actually read — the
  placeholder enforces that the spend tree equals the reviewed tree.
- **The dependency is visible.** A `<placeholder>` in a Block is a self-evident
  signal that this Block is *sequential* on another — it can't be pasted until
  the supplier's REPORT lands.
- **Cheap, explicit handoff.** When the supplying REPORT arrives, the Arranger
  states the substitution once, precisely: the literal hash to insert **and
  every location** it goes (e.g. "`<accept-fill pin>` = `44fc8b4…`; block-006:
  Governance pin, Tree state, header Request pins line; block-007: governing
  record line and the `.auth.json` reference"). The Coordinator (or the
  Arranger on relay) substitutes and pastes.

Convention: placeholder names are lowercase, descriptive of the commit they
await (`<accept-fill pin>`, not `<pin1>`), so a reader knows which REPORT feeds
them. One placeholder name = one upstream commit.

## Routing recommendations (assignee-neutral requests)

Validator requests are drafted **assignee-neutral** — the Coordinator routes,
usually to all Validators (they are cheap; exploiting free review is
deliberate). The Arranger attaches a **routing recommendation** based on bench
calibration, which the Coordinator may follow or override:

- **GLM** — strong on kernel internals and ABI correctness. Lean GLM for
  "is this mechanism correct as written" questions.
- **DS4P** — deepest traces and **falsifier instincts**. Lean DS4P for
  blast-radius / "does this change break some *other* path", contract-validity,
  and "can this claim be falsified" questions — anything that rewards actively
  trying to break the artifact rather than confirming it. (Caveat: DS4P labels
  satisfied prerequisites `blocker`; read its bottom line, not the tags.)

The recommendation is per-question-type, not a standing assignment — a
blast-radius review of a product fix leans DS4P; a kernel-internals correctness
review leans GLM; design/authorization and contested findings fan out to both.

Full bench calibration with session evidence and a routing table:
[validator-bench-calibration.md](validator-bench-calibration.md).

## Verification before acceptance

The Arranger's single review leg is the quality gate before the Coordinator
accepts. For evidence-lane work this is first-hand: reproduce hashes, read
emission sites, trace every asserted fact to an observed value. "The report
says X" is not "X is true."

## The spend-prep sequence (the irreversible-attempt pipeline)

A guest-attempt spend is the one irreversible, budgeted operation in the loop
(it consumes a falsifier slot). Its preconditions must be **committed in the
activation record**, not merely true in-band. The canonical order:

1. **pre-spend review** complete, no blockers (Validators + Arbiter on conflict);
2. **Coordinator acceptance RECORDED in the activation record** (Status flipped,
   acceptance + basis written) — an acceptance-fill commit;
3. **Explorer host readiness = ready at the accepted record pin**;
4. **Gatekeeper** executes the single attempt, disposing against the record.

The Gatekeeper reconciles against the **committed record, not the chat.** If the
record still reads `Status: pending / no guest authorized`, it will (correctly)
stale-stop even when the Coordinator has said "accept" in-band — the committed
record outranks the in-band request.

**Acceptance-fill-before-spend (rule).** A Coordinator "accept" authorizes the
Arranger to *record* the acceptance, NOT to route the Gatekeeper directly.
On "accept": first dispatch an Implementer **acceptance-fill** (flip Status to
accepted, write the acceptance + review/readiness basis; evidence-lane), THEN
route the Gatekeeper **bound to the new accepted record pin** — sequential via
`<acceptance-fill pin>`, never the pre-acceptance pin. The gating authorization
precedes the spend dispatch, same root discipline as never pasting a stale pin
(the reviewed/accepted record must equal the acted-on record).

**Pre-dispatch self-check.** Before sending any gated/spend Block, the Arranger
reconciles the bound record's *committed* Status against the gate the Block
asserts — i.e. mirror the Gatekeeper's own check one hop earlier. This catches
an ordering gap (e.g. acceptance not yet committed) before it costs a routing
round-trip. (Lesson, 2026-06-17: a spend Block routed before the acceptance-fill
was stale-stopped — zero spend lost, but a wasted hop the self-check prevents.)

**Batch the predictable tail.** The spend-prep sequence is foreseeable, so
anticipate the acceptance-fill and any readiness-rerun as *known* steps and
stage them with placeholders up front, rather than discovering each serially.
Front-loaded cheap verification protecting one expensive spend is the intended
trade for OS work — the metric that matters is *spend never wasted*, not hops
minimized; the careful pace is endorsed (Coordinator, 2026-06-17).

## Lanes (Rule 1) and currency (Rule 2)

- **Evidence lane** — full ceremony (activation record, Validator routing,
  Gatekeeper staging, attempt accounting) for anything touching runtime claims,
  markers, attempt accounting, or evidence trees.
- **Docs lane** — Implementer commit + one Arranger review + Coordinator
  acceptance; Validators optional at Coordinator routing.
- **Currency** — governance docs state only current rules; superseded text is
  deleted (git history is the archive), not annotated.

## Open questions to iterate

- Should this workflow doc become canonical `wip-gpt` doctrine, or stay an
  Arranger working note?
- Is the REPORT block worth making a hard doctrine requirement, or keep it an
  Arranger-side dispatch convention?
- Can the parallel/sequential/gated marking be made machine-checkable (e.g. a
  dependency field in each Block)?
- Where is the right boundary between "Arranger arranges" and "Implementer
  drafts its own next step"?
- Oracle (consult-agent): what triggers an Arranger→Oracle consult (when "stuck"),
  what does the Arranger hand it, and how is the consult result folded back into the
  Block plan without ceding the Arranger's review authority?
- Does "Arranger targets/assigns Blocks to agents" stay proposal-only (the
  Coordinator routes by paste), or does a staffed org grant the Arranger direct
  routing for some Block classes?
