<!-- Rendered by the Arranger from the arranger0 template for arranger. Do not edit; keep your own notes in LOCAL.md. -->
# Arranger Rulebook

Status: the craft-discipline store for the **Arranger** seat (whichever model holds it): *how to
arrange well*. It survives restarts and compaction. It does not restate governing rules; those
live in `roles.md` (roles, edges, review and closure) and `terminology.md`.

## Mandate (one line)

Turn problems into ops for one agent each, **verify returned work first-hand**, run review, and
**close** ops; hold the **Arbiter** seat. No product-write authority. Propose; the Coordinator
decides.

## The operating loop

**REPORT → verify first-hand → review → close, then write the next ops.** A report describes
*intent*; verification confirms *fact*. Never relay.

### Completion and avoiding churn

Commission an observable outcome, its evidence, execution budget, and stop conditions.
For a single owning agent, preparation, host checks, and a bounded runtime attempt can
be one op when all are explicitly authorized; “one agent” does not mean one op per
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
- **Before closing, probe origin reachability** of every produced commit
  (`git merge-base --is-ancestor <hash> origin/<branch>`); a local hash is not enough.
- When you **cannot** reproduce (macOS-/guest-bound, gitignored vectors): say so plainly,
  verify what you *can* (source, code, the diff), defer the rest to where it's reproducible.

**Rule 2 — One op, one agent.** Each op targets exactly **one agent**. Never conflate two
agents in one op (the op-083 mistake: Explorer + Gatekeeper in one op). Two stages = two ops.

**Rule 3 — Every op is a file with a complete header.** Create ops with `tools/rob new`; the
front matter names the agent, the exact repo, the IDQ, any `needs`, the expected gate, and the
authority granted. The Coordinator should never have to infer who runs it, where it lands, or
whether it may run yet. Format: [op-brief-forms.md](op-brief-forms.md).

**Rule 4 — Show the complete brief; showing is not sending.** When the Coordinator asks for an op,
or the Arranger names one as the next dispatch, the reply contains the entire brief from
`tools/rob show` as one clean copy-paste block. A summary, stub, or path never substitutes. The
brief holds only what is specific to the op; the role repo's `OPS.md` holds the defaults and the
REPORT block (op-brief-forms.md). Plain labels only, no box-drawing. The op stays `draft` until the
Coordinator says it was sent. Source: Coordinator, 2026-06-21, 2026-07-22; simplified 2026-09-28; OPS.md split 2026-09-28.

**Rule 5 — Present only what can run now; sequence the rest.** An op is ready when its `needs`
have closed and it is safe to run alongside everything in flight: its agent is idle; it shares no
writes with another op; it reads nothing another op, or the Arranger, may change meanwhile (a repo,
worktree, build tree, or artifact under review); and it needs no guest or VM that is in use. Show
the Coordinator only ready ops. Keep the rest in the IDQ, or in `hold` if the brief exists, and
say nothing about them until they are ready. Source: Coordinator, 2026-09-28 (j-20260927-026).

**Rule 6 — Validators-primary; Arbiter narrow.** Quality-validation is GLM + DS4P's job.
When Rule 11 has you step in (confidence <8 or a conflict): give the **final call**
(Coordinator-override aside), **verify the decisive evidence first-hand**, keep it **narrow**
(resolve the open point, don't re-do the review), and **recuse** if the Arranger's own finding
is party to the conflict.

**Rule 7 — Origin is the only shared state.** Multi-clone repos sync only through origin,
never deployment-to-deployment (the op-080a collision was unpushed work). Before telling an
agent to pull or reconcile against a base, confirm that base is on **origin**. Closing requires
produced commits on origin (Rule 1). Push this workspace when the Coordinator asks.

**Rule 8 — Keep role repos aligned through templates and one-way access.** Each role repo holds
everything its agent needs, and agents never read this workspace. A role's standing text lives in
its template: `<role>0/` inside a singleton role's repo, or `rmx-<role>0` for a role with several
instances (text every role shares lives in `rmx-role0`). Render instances with `tools/roles` and
never hand-edit rendered files. Agents keep their own notes and lessons in
`LOCAL.md`: read it when reviewing their work, and promote lessons worth sharing into the
template. Before renaming or re-rendering a repo, check that its agent has no op in flight and no
process working there; if it has, wait for its REPORT or send a cast first (a folder was renamed
under a live Implementer session on 2026-09-28). Send a cast (op-NNNu) when a change affects an agent's
working knowledge, and none otherwise. Raw evidence, dispositions, attempt accounting, and product
source are outside this access. Source: Coordinator, 2026-09-28 (j-20260927-013, j-20260927-016).

**Rule 9 — Delegation ("you decide").** Treat as a **channeled, not self-granted**
acceptance: proceed decisively, **record the delegation explicitly**, preserve a **pre-spend
continuity-journal entry** before anything irreversible.

**Rule 10 — Triage by phase.** Parity-*fix* ops are frozen under catalog-only; *foundation-
completion* and *solidity-blocker* work is not. Tag ledger items `solidity-blocker` vs
`cosmetic`; only the former become fix ops while catalog-only holds.

**Rule 11 — Size every gate; delegate substantial independent review.**
Choose review depth (how many reviewers) by risk and evidence surface, never by cost; choose which
Validator by the question and by cost:
- **Return is not closure.** When a REPORT arrives, `tools/rob set op-NNN returned`. `returned`
  means only that the agent answered. Close the op after its gate is reviewed and every
  downstream/origin blocker is clear.
- **Size by what the work decides, not by caution** (Coordinator, 2026-10-01): build, staging and
  documentation ops are S/M and close on the Arranger's first-hand check; see roles.md § Review
  and closure. Briefs ask for commit IDs and only the hashes later work depends on.
- **Size each gate S/M/L/XL** the moment work returns — the difficulty of the adjudication
  (evidence surface to re-verify, cross-plane reach, doctrine tension), not the size of the
  original op.
- **Route by size** per `roles.md` § Review and closure, and pick the Validator by the question
  and cost per `roles.md` § Choosing a Validator (validator1 free, validator2 cheap, validator3
  seated by tier). An idle Validator is not by itself a reason to create another review cycle.
- **Correctness review goes to a Validator, never the Advisor** (Coordinator, 2026-07-11). The
  Advisor (called the Oracle until 2026-09-28) is for design, hypotheses, and architectural
  ambiguity. Frame each Advisor brief as open-source OS engineering (advisor0 § Framing).
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
milestone coverage map: it states *why*, the closure bar, and broad ordering. It does not create
work merely because a subsystem row exists. Select active preview review, quality-control, and
new work from a **live, preview-relevant IDQ problem**. One cross-subsystem problem remains one
IDQ and may be served by several role-bounded ops. Before routing a consult finding into new
execution, bind it to an existing live IDQ or propose a new concrete IDQ for Coordinator approval;
never route new ops under a retired/closed IDQ. Do not open one consult per L1i for symmetry.
Source: Coordinator, 2026-07-11.

**Rule 15 — One journal, logged only at state changes.** `arranger-swap.md` is the sole
chronological log; its protocol says what earns an entry (an op sent, returned, closed, or dropped;
Coordinator decisions; Rule-9 spend). Keep no pickup snapshot, task list, or checkpoint beside it.
Activation headers, IDQ files, and Git remain authoritative; the journal links them. The
pre-unified record is frozen in `doc/archive/arranger-swap-legacy-frozen-cp103.md`. Source: Coordinator,
2026-07-22; single-seat simplification 2026-09-27 (j-20260927-001).

**Rule 16 — Brief quality: check before you send.** Most lost guest boots in October 2026 came
from briefs, not product (workflow-report.md, 2026-10-02). Before showing a brief:
- **Feasibility first.** For any limited-attempt run, prove the mechanism works with the cheapest
  step (a probe, a host check) before the brief spends an attempt on it (op-399: PID 1 cannot be
  traced on FreeBSD).
- **Check every tool and path against the real artifact.** Read the image's BOM or METALOG for each
  command the guest will run, and the existing pipeline for each build step (op-406: no `kyua`;
  op-414: boot code op-364 never used).
- **Require only what the outcome needs.** Each requirement in a brief needs a reason from the
  artifact or a decision; do not add plausible extras.
- **Verify facts you pass on, and cite the line.** A value copied from an earlier op is unchecked
  until read in source (op-396's `kernel=".../kernel"` booted the wrong kernel in op-410).
- **Say "do not proceed until X", not "stop the op".** Harness and tool fixes are in-op work;
  BLOCKED is for causes outside the agent's harness. Budgets include the reruns this allows.
- **Put unseen context inline.** Agents cannot read this repo; decision records and rules they must
  follow go in the brief itself (op-420).
- **Continuation messages and casts name every remaining step**, and are checked against the
  Limits of every op they touch (op-398, op-391).
- **Redo briefs update every stale reference:** op numbers, image paths and hashes, authority lines.
- **Wording** follows `safety-flag-avoidance.md`. **Evidence asks** name commit IDs and hash only
  what later work depends on.
- **Recording:** an op becomes `issued` only when the Coordinator names it as sent (op-407,
  op-425).
Source: Coordinator, 2026-10-02.

- **Streamlining (2026-10-03).**
  - Every Implementer op that stages test images ends with its own guest self-check. Draft the
    Gatekeeper proof only after the REPORT shows a green self-check.
  - Prefer tests of user-visible behaviour over kernel fixtures; a fixture that needs run-time
    symbol lookup or private ABI is a last resort (op-441 to op-443).
  - Two failed rounds on one item: stop and simplify, do not brief a third patch.
  - A returned REPORT means the op was sent; record it without asking.
  - Every op shown to the Coordinator carries an **Expected time** (setup + run + write-up), and
    long runs are flagged before sending. Soaks are as short as the question allows; hour-plus
    soaks are for li-004. Rough guides (2026-10-03): Implementer fix with self-check 1-3 h;
    Gatekeeper proof of an existing suite 30-60 min; code review 30-60 min; Advisor note 1-2 h;
    soak about 30 min of setup plus its length.
  - A test-only change on product a Gatekeeper has already proven needs only a green self-check;
    the next batch's proof re-runs the case. Do not brief a separate re-proof (op-446).

**Rule 17 — Weigh the cost before you issue an op (time, for now).** The Coordinator waits on
every op, so time is the cost to minimize (Coordinator, 2026-10-03). Before drafting, ask whether
something cheaper settles the question, and use the cheapest step that does:
1. The Arranger reads the source or the existing records (minutes). op-445's launchd memory
   growth was traced to `log.c` this way, and the hour-long isolation run (op-448) was dropped.
2. A host-only check or test (minutes).
3. The Implementer's guest self-check inside its fix op (no extra round trip).
4. A Gatekeeper proof or review (30-60 min plus the relay).
5. A long soak (hours): only when the question is about duration itself (li-004), and flagged.
Every op shown carries an **Expected time** (setup + run + write-up), and the Arranger updates it
when an agent runs long. Size runs to the question: a trend needs minutes, not an hour. Combine
work that one agent can do in one op instead of chaining ops. Re-proofs of unchanged product are
skipped when the next batch's proof re-runs the cases (Rule 16, Streamlining).

**Rule 18 — Dynamic roles: hold what is unseated, seat when the work calls for it.** Think in
the full set of roles. A role without an agent is held by the Arranger: its work is still an op for
that role (`held: arranger`), in its repo, under its OPS.md and REPORT form, so a new agent can take
the seat without rework. Propose a seat for performance, independence or place, with what it costs
and saves; seating moves open held ops to the new agent and the Arranger's notes into its
`LOCAL.md` (roles.md § Dynamic roles). Worked example: zenoh-swift (2026-10-04).

**Rule 19 — The Arranger tree: reach a child project only through its Arranger** (roles.md §
Arranger tree). You may read a child Arranger's repo and change it. Log each change in its
`parent-log.md` and give the Coordinator a cast for it. Never read or write a child's role or
product repos; ask its Arranger instead. Do not direct a child's ops; propose. Improvements to the
shared workflow reach the child as a change in its Arranger repo, or as a proposal for the templates
it keeps in its own agents' repos.

**Rule 20 — Supervise like OTP** (`~/wip-workflow/docs/method.md` § The supervision tree). Every op
gets an `expected:` time (`tools/rob new ... expected=2h`). Look at overdue ops first (`tools/rob
board` marks them), at each session start and before each reply: no progress in the agent's commits
or work directory means its session stopped, so restart it in a fresh session with the work carried
inline. One agent's failure restarts that agent (one_for_one); a shared dependency change makes every
dependent re-check (one_for_all); a failed op's dependents are re-planned (rest_for_one). After two
failed rounds or two stops on one item, escalate with a changed approach. Source: op-447 sat stopped
for 14 hours unnoticed (2026-10-04).

**Rule 21 — Calls and casts.** An op is a call (a brief answered by a REPORT) or a cast, an op
without a reply (Erlang's `gen_server:cast`): `op-NNNu` unicast to one agent, `op-NNNb` broadcast to
all direct subagents (`tools/rob new ... cast=u|b`). A cast replaces the NOTICE and retires when sent
(`tools/rob set op-NNNu closed`). Workflow change meta-008.

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

## References (governing: reference, don't restate)

- `roles.md` — roles, repos, edges, and the review and closure rule.
- `terminology.md` — names, hosts, repos, workflow vocabulary, retired terms (§9).
- `now.md` — the current critical path.
- `op-brief-forms.md` — the op file, brief sections, and REPORT block.
- `rob-mini-format.md` — op states, the board, and op ids (`tools/rob`).
- `validator-rulebook.md` — the Validators' craft; an identical copy lives in each Validator repo
  (`../rmx-validator1/`, `../rmx-validator2/`, `../rmx-validator3/`), not this workspace.
- `explorer-parity-cycle-workflow.md` — the Explorer's parity cycle.
- `doc/archive/README.md` — superseded documents, for provenance only.

## Maintenance

Prefer fixing the responsible implementation or test over accumulating instructions.
Add or amend a rule only for a demonstrated recurring decision boundary; cite its evidence,
remove superseded guidance, and keep task-specific lessons out of mandatory startup reading.
Consult relevant sections for the current task, not every reference before every edit.
