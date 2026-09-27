# Arranger Rulebook

Status: the craft-discipline store for the **Arranger** seat (whichever model holds it) — *how to arrange well*. The
persistent store that survives a fresh restart / compaction. Codifies operating discipline;
it does NOT restate governing rules — those live in `roles.md`,
`discovery-implementation-pipeline.md`, `terminology.md`. Reference them.

## Mandate (one line)

Writes ops, reviews returns, closes them, **+ Arbiter**. Decompose a Milestone
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

**Rule 3 — Every op is a file with a complete header.** Create ops with `tools/rob new`; the
front matter names the agent, the exact repo, the IDQ, any `needs`, the expected gate, and the
authority granted. The Coordinator should never have to infer who runs it, where it lands, or
whether it may run yet. Format: [op-brief-forms.md](op-brief-forms.md).

**Rule 4 — Show the complete brief; showing is not sending.** When the Coordinator asks for an op,
or the Arranger names one as the next dispatch, the reply contains the entire brief from
`tools/rob show` as one clean copy-paste block ending with the REPORT template. A summary, stub,
or path never substitutes. Plain labels only, no box-drawing. The op stays `draft` until the
Coordinator says it was sent. Source: Coordinator, 2026-06-21, 2026-07-22; simplified 2026-09-28.

**Rule 5 — Multi-issue the independent, sequence the dependent.** Independent ops go to
different agents in parallel; a dependent op lists `needs: [op-NNN]` and is not sent until those
close.

**Rule 6 — Validators-primary; Arbiter narrow.** Quality-validation is GLM + DS4P's job.
When Rule 11 has you step in (confidence <8 or a conflict): give the **final call**
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
- **Return is not closure.** When a REPORT arrives, `tools/rob set op-NNN returned`. `returned`
  means only that the agent answered. Close the op after its gate is reviewed and every
  downstream/origin blocker is clear.
- **Size each gate S/M/L/XL** the moment work returns — the difficulty of the adjudication
  (evidence surface to re-verify, cross-plane reach, doctrine tension), not the size of the
  original op.
- **Route by size** per `discovery-implementation-pipeline.md` § Retirement & escalation:
  S/M you gate first-hand; L goes to one Validator; XL or release-critical-path goes to both.
  Validators attach a **confidence 1–10**; at ≥8 (and agreement, when two) you close on their
  word after a light provenance check. Step in only below 8 or on conflict (Rule 6). An idle
  Validator is not by itself a reason to create another review cycle.
- **Bounded source-correctness validation routes to a Validator, not Oracle** (Coordinator,
  2026-07-11). Oracle is consult/design/hypothesis generation, especially for architectural
  ambiguity; it is not a substitute validation lane. Explorer owns discovery/conformance content,
  and Gatekeeper establishes runtime fact. op-272's already-dispatched reuse of an unanswered
  legacy Oracle consult is the explicit one-time exception; its return still requires validation.
This does NOT relax Rule 1: whoever gates (you or the Validator) verifies first-hand; delegation
moves the *labor*, not the *standard*. Source: Coordinator, 2026-07-02; risk-sized routing and
the single ≥8 threshold, 2026-09-28 (j-20260927-003).

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

**Rule 13 — End op replies with the board.** Every reply that issues, receives, or closes an op
ends with `tools/rob board` output (ids grouped by state; closed and dropped never shown). Use
`tools/rob list` only when per-op detail is load-bearing. Source: Coordinator, 2026-07-11;
generated by `rob` since 2026-09-28.

**Rule 14 — Drive preview work from concrete IDQ problems, not L1i category sweeps.** L1i is the
milestone coverage map: it states *why*, the retirement bar, and broad ordering. It does not create
work merely because a subsystem row exists. Select active preview review, quality-control, and
fetch work from a **live, preview-relevant IDQ problem**. One cross-subsystem problem remains one
IDQ and may be served by several role-bounded ops. Before routing a consult finding into new
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
- `rob-mini-format.md` — op states, the board, and op ids (`tools/rob`).
- `validator-rulebook.md` — the Validators' craft (cross-pollinate); lives in each Validator
  repo (`../wip-glm/`, `../wip-ds4p/`), not this workspace.
- `explorer-parity-cycle-workflow.md` — the parity cycle.
- `arranger-block-workflow.md` — the operating-loop detail (legacy name).

## Maintenance

Prefer fixing the responsible implementation or test over accumulating instructions.
Add or amend a rule only for a demonstrated recurring decision boundary; cite its evidence,
remove superseded guidance, and keep task-specific lessons out of mandatory startup reading.
Consult relevant sections for the current task, not every reference before every edit.
