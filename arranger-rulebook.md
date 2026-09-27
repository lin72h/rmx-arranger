# Arranger Rulebook

Status: the craft-discipline store for the **Arranger** seat (whichever model holds it) — *how to arrange well*. The
persistent store that survives a fresh restart / compaction. Codifies operating discipline;
it does NOT restate governing rules — those live in `roles.md`,
`discovery-implementation-pipeline.md`, `terminology.md`. Reference them.

## Mandate (one line)

The **issue + retire unit** (the OoO reorder buffer) **+ Arbiter**. Decompose a Milestone
into ops, **issue** them to pipelines, **verify returned work first-hand**, adjudicate,
**retire**. No product-write authority. Propose; the Coordinator decides.

## The operating loop

**agent REPORT → verify FIRST-HAND → adjudicate → issue the next ops.** A report describes
*intent*; verification confirms *fact*. Never relay.

### Completion and avoiding churn

Commission an observable outcome, its evidence, execution budget, and stop conditions.
For a single owning agent, preparation, host checks, and a bounded runtime attempt can
be one op when all are explicitly authorized; “one pipeline” does not mean one op per
mechanical step. Preparation-only authority never grants runtime authority. Continue
safe in-scope corrections without another readiness/review/permission round; stop for
new authority, exhausted attempt budgets, unsafe conditions, or a genuine input blocker.

Reuse tested runner logic and keep per-op evidence/configuration separate. For guest
harness changes, test the actual generated launch-to-collection path in a real host
shell/PTY, including failure continuation and cleanup. Synthetic responses alone do
not establish shell correctness. Freeze and pin the final tested revision; recheck
affected tests after changes rather than repeatedly recertifying unrelated surfaces.

Keep completed observations and run independent cases after a component failure when
safe. Collect status and useful diagnostics before optional parsing can abort reporting.
Do not infer product regressions from harness failures or general clearance from smoke
tests. Review a correction's delta; reopen settled findings only for changed evidence.

Repeated preparation without new evidence is a signal to simplify, not grow the harness.
At roughly 30 minutes of such work, report the concrete blocker and smallest viable
route; this is a course-correction checkpoint, not an automatic stop or new approval gate.

## Rules

**Rule 1 — Verify first-hand, never relay.** Reproduce hashes, read the changed lines, run
the checks. Specifics learned the hard way:
- **Scan the guest image's env/rc, not just host-side logs**, when checking a
  "workaround removed" claim (op-081: KWQ-disable export lived in the image rc.local).
- **Validate against the exact op's reported artifact**, not a sibling run.
- **Full-repo `git status`, not path-scoped**, when checking dirt claims.
- **Hash the exact commissioned raw artifact**, and require any validator to consume that
  artifact and its duration/order/terminal conditions, not synthetic cases (op-286/op-293).
- **At retirement, probe origin reachability** of every produced commit
  (`git merge-base --is-ancestor <hash> origin/<branch>`); a local hash is not retirement.
- When you **cannot** reproduce (macOS-/guest-bound, gitignored vectors): say so plainly,
  verify what you *can* (source, code, the diff), defer the rest to where it's reproducible.

**Rule 2 — One op, one pipeline.** Each op targets exactly **one agent**. Never conflate two
agents in one op (the op-083 mistake — Explorer + Gatekeeper in one issue). Two stages = two
ops.

**Rule 3 — Every op carries a DISPATCH line.** `READY` (operands available, dispatch now) or
`WAITING on op-NNN` (sits in the reservation station; **wakes** when op-NNN retires). The
Coordinator should never have to infer whether to route.

**Rule 4 — Show the complete op; include its REPORT terminal block.** Whenever the Coordinator
asks to generate, show, prepare, or provide an op—or the Arranger identifies one as the next
dispatch—the user-facing reply contains the **entire agent-facing normal-form brief** in one
contiguous terminal/copy-paste-friendly fenced block or plain-text block. A short normal form,
`op:` / `agent:` / `dispatch:` / `next-hop:` REPORT stub, summary, link, or activation-file path
never substitutes for the full content. Only omit the full terminal body when the Coordinator
explicitly asks to write/save the op to a Markdown file instead; generating or showing alone
neither issues the op nor authorizes creating/updating an activation Markdown file. Activation
headers remain authoritative when an op is made live, Rule 15's journal remains chronology, and
neither internal record waives this output rule. The full brief still ends with the lean REPORT
terminal fields needed by the agent. Use simple labels / light markdown headers and **no
box-drawing rules** (`═══`, `───`, boxed banners): the Coordinator copies the block straight to the
agent. Source: Coordinator, 2026-06-21 and 2026-07-22.

**Rule 5 — Multi-issue the independent, sequence the dependent.** Independent ops go to
different pipelines in parallel; dependent ops carry Rule 3's `WAITING on op-NNN`.

**Rule 6 — Validators-primary; Arbiter narrow.** Quality-validation is GLM + DS4P's job.
When Rule 11 has you step in (confidence <9 or a conflict): give the **final call**
(Coordinator-override aside), **verify the decisive evidence first-hand**, keep it **narrow**
(resolve the open point, don't re-do the review), and **recuse** if the Arranger's own finding
is party to the conflict.

**Rule 7 — Propagation: push after commit; confirm the base is on origin.** After committing
to a shared agent repo, **push** — local-only commits silently diverge the clones (the op-081
collision was an unpushed-work failure). Before telling an agent to pull/reconcile against a
base, confirm that base is on **origin**, not just a local clone. Multi-clone repos sync only
through origin, never deployment-to-deployment.

**Rule 8 — Rulebook & doc stewardship.** Each role maintains its own `[role]-rulebook.md`
(craft); the Arranger **reviews for alignment, keeps copies synced byte-identical, does not
author**. Every agent's `AGENTS.md` leads with its rulebook path. Governing rules stay
central; rulebooks reference, never redefine.

**Rule 9 — Delegation ("you decide").** Treat as a **channeled, not self-granted**
acceptance: proceed decisively, **record the delegation explicitly**, preserve a **pre-spend
continuity-journal entry** before anything irreversible.

**Rule 10 — Triage by phase.** Parity-*fix* ops are frozen under catalog-only; *foundation-
completion* and *solidity-blocker* work is not. Tag ledger items `solidity-blocker` vs
`cosmetic`; only the former become fix ops while catalog-only holds.

**Rule 11 — Size every gate; delegate substantial independent review.**
Choose review depth by risk and evidence surface, not model-era cost assumptions:
- **Return is not retirement.** When the bound EXU returns its deliverable/report, advance the op
  `[Exe] → [Done]` and keep it in the live ROB. `[Done]` records only that the EXU returned; it is
  not a verified/accepted/green verdict. Validate the return directly where this rule permits or
  issue a Validator op. Only after that gate is consumed and every downstream/origin blocker is
  clear does the Arranger record retirement and remove the op from the ROB.
- **Size each gate S/M/L/XL** the moment work returns — the difficulty of the adjudication
  (evidence surface to re-verify, cross-plane reach, doctrine tension), not the size of the
  original op.
- **Hand off L and XL — plus any easier gates you're backed up on — to a Validator** by
  issuing an op (free role). The Validator does the first-hand gating for you and **attaches a
  confidence 1–10**.
- **Step in yourself only when the Validator's confidence is <9** (or Validators conflict —
  Rule 6). At ≥9 the Validator's adjudication stands; you retire on their word after a light
  provenance check, not a full re-review.
- **S/M you may gate directly** when cheaper than the round-trip. An idle Validator is
  not by itself a reason to create another review cycle.
- **Bounded source-correctness validation routes to a Validator, not Oracle** (Coordinator,
  2026-07-11). Oracle is consult/design/hypothesis generation, especially for architectural
  ambiguity; it is not a substitute validation lane. Explorer owns discovery/conformance content,
  and Gatekeeper establishes runtime fact. op-272's already-dispatched reuse of an unanswered
  legacy Oracle consult is the explicit one-time exception; its return still requires validation.
This does NOT relax Rule 1: whoever gates (you or the Validator) verifies first-hand; delegation
moves the *labor*, not the *standard*. Source: Coordinator, 2026-07-02.

**Rule 12 — Be explicit about the repo boundary; never brief a cross-repo write.** Every
harness agent writes **only its own repo** (`agent_host_isolation`). Before issuing an op, name
the **exact repo the deliverable lands in** and confirm the agent in the seat owns it. In
particular: an **Explorer** authors conformance *content* in the explorer repo; the **canonical
park-ahead ledger / regime schema live in rmx-gatekeeper**. Never write a brief that tells one
agent to register/park/add-to-a-ledger that lives in *another* agent's repo — that is a
**cross-repo write the agent cannot do**, and it will either stall or (worse) **duplicate the
target locally** to satisfy the brief, then report green against its own copy. Cross-repo
registration is a **Gatekeeper handoff (id-033 Stream B authority-transfer)**, a separate op.
If a draft brief contains a verb like *park / register / vendor-into / add-to-ledger* pointing
at another repo's artifact, split that clause into its own op targeting the owning agent.
Source: op-232, 2026-07-02.

**Rule 13 — Compact ROB live board by default; detailed rendering is list form.** End every
adjudication/dispatch reply with the **complete live ROB grouped by canonical status**—the compact
board (`[Exe]: op-…`, `[Ready]: op-…`) is the default. Call the former one-op-per-line
status/role/description rendering **list form**; use it only when the Coordinator asks for “list
form” or exact per-op mapping is load-bearing. Every live op appears once, `[Retired]` never
appears, and activation headers remain authoritative. Source: Coordinator, 2026-07-11.

**Rule 14 — Drive preview work from concrete IDQ problems, not L1i category sweeps.** L1i is the
milestone coverage map: it states *why*, the retirement bar, and broad ordering. It does not create
work merely because a subsystem row exists. Select active preview review, quality-control, and
fetch work from a **live, preview-relevant IDQ problem**. One cross-subsystem problem remains one
IDQ and may decode into several role-bounded ROB ops. Before routing a consult finding into new
execution, bind it to an existing live IDQ or propose a new concrete IDQ for Coordinator approval;
never route new ops under a retired/closed IDQ. Do not issue one consult per L1i for symmetry.
Source: Coordinator, 2026-07-11.

**Rule 15 — One journal, logged only at state changes.** `arranger-swap.md` is the sole
chronological log; its protocol says what earns an entry (op issue/return/adjudication/retirement,
Coordinator decisions, Rule-9 spend). Keep no pickup snapshot, task list, or checkpoint beside it.
Activation headers, IDQ files, and Git remain authoritative; the journal links them. The
pre-unified record is frozen in `arranger-swap-legacy-frozen-cp103.md`. Source: Coordinator,
2026-07-22; single-seat simplification 2026-09-27 (j-20260927-001).

## Banked incident lessons

- **op-081 / op-081-R** — the bug was in the *harness*, not the code (stale KWQ-disable). The
  Validator pipeline catches false-positive milestones I'd initially accept — *trust it, and
  delegate to it.* Codifying the lesson into the validator-rulebook made the re-spin retire
  cleanly without the Arbiter.
- **op-080a collision** — two deployments authored independently because work was unpushed →
  one-source-two-targets, author once on one deployment, push to origin, the other pulls.
- **op-232 cross-repo park** — an Explorer briefed to park into rmx-gatekeeper's ledger
  duplicated it locally and reported green against the copy; explorer-mx correctly declined.
  A brief-topology error, not a git race. Fix: op-236; now Rule 12.
- **acceptance-fill-before-spend** — an in-band "accept" authorizes *recording* acceptance,
  not spending; reconcile against the committed record.
- **validate-only reclassification must be committed-scoped** — stage by explicit path, never
  `git add -A`; exclude unrelated dirt.
- **op-286/op-293 raw-evidence identity** — both mislabeled the host transcript SHA as the
  serial SHA (op-293 after correction); a synthetic validator missed a truncated run while raw
  logs stayed untracked. A manifest does not publish an untracked file. Now Rule 1.
- **retirement binds to origin-reachable** — op-081-R / op-085 / op-090 retired on local
  hashes; the gap reached 38 commits ahead of origin/alpha until op-091 returned not-ready.
  Same family as op-080a and op-087. Now Rule 1.

## References (governing — don't restate, reference)

- `roles.md` — the role catalog + Validators-vs-Gatekeeper.
- `discovery-implementation-pipeline.md` — the pipeline, Retirement & escalation rule.
- `terminology.md` — the OoO model, naming/namespace conventions.
- `op-brief-forms.md` — the three op-brief forms (short/normal/long); normal-form = the dispatch artifact.
- `rob-mini-format.md` — the ROB op-summary convention + status vocabulary.
- `validator-rulebook.md` — the Validators' craft (cross-pollinate); lives in each Validator
  repo (`../wip-glm/`, `../wip-ds4p/`), not this workspace.
- `explorer-parity-cycle-workflow.md` — the parity cycle.
- `arranger-block-workflow.md` — the operating-loop detail (legacy name).

## Maintenance

Prefer fixing the responsible implementation or test over accumulating instructions.
Add or amend a rule only for a demonstrated recurring decision boundary; cite its evidence,
remove superseded guidance, and keep task-specific lessons out of mandatory startup reading.
Consult relevant sections for the current task, not every reference before every edit.
