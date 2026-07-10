# op-228 — Oracle: testing-strategy review — design the conformance-first, macOS-as-truth test pipeline (Explorer authors ahead / parks not-yet-passable / migrates to Gatekeeper regression) and grade + improve the existing test posture

op-228 | role: **Oracle** (consult) | EXU: **rmx-oracle-rx-x64z** | state: **[Done — CONSULT DELIVERED 2026-07-02, Arranger-verified]** — D1-D6 delivered; staged at rmx-oracle/op-228-testing-strategy-review.md; seeded **id-033** (test-strategy pipeline, four-stream decode of E4); escalations E1-E4 Coordinator-held. | parent id: id-000 (1.0-preview roadmap consult; seeded test-strategy id-033 per Oracle output) | L1i: li-1000 (relates li-1007 integration soak / id-007 soak infra; the parity-explorer macOS-as-truth loop) | cost: **oracle-tier (highest; consult-only, no product-write)** | authored 2026-07-02 (Arranger seat, model Opus 4)

## ADJUDICATION (Arranger, 2026-07-02)
Consult **accepted, well-grounded**. Sharpest load-bearing claims re-verified first-hand:
- **NO park/skip convention** (the OOO crux, D3) — zero `@tag`/`@moduletag`/`ExUnit.configure`/`exclude` across rmx-explorer, rmx-gatekeeper, wip-gpt/test. The mechanism genuinely does not exist yet → confirms Stream A is greenfield.
- **Migration scaffold design-only** (D2) — `rmx-explorer/docs/migration-m2-authority-design.md:50-52` (`catalog/`+`mismatches/` "design only", `certification/claims/` "deferred"), :77-80 ("does not create them"), :108 ("certification/ remains absent until the R0 claims-ledger contract is accepted").
- **Three-authority split** — confirmed :48-52.
Codified → **id-033** decodes E4 into four bounded streams (A park-ahead ledger / B migration ceremony / C regime fields / D R0-minimal). E1-E4 recorded as Coordinator-held. No op cut (op_state_dispatch_boundary).

## CONTEXT (read first)
Open-source operating-system engineering — an internal, maintainer-style review of OUR OWN test infrastructure and strategy for rmxOS (a NextBSD/Darwin Mach userland — libdispatch, notify, asl, libxpc, launchd — ported onto stock FreeBSD 15/stable). This op designs how we *test* our own port against macOS behavior, exactly as any upstream OS project designs its conformance + regression suites. It is NOT security/vulnerability research, penetration testing, or anything adversarial — no external targets, no exploitation.

## WHY (one line)
The Coordinator wants a standing, ongoing test discipline — not ad-hoc per-feature greens — that (a) captures each feature's *correct* semantics from macOS-as-truth, (b) lets test authorship run **ahead of** implementation without stalling the agent pipeline, (c) matures tests into owned regression gates, and (d) doubles as the artifact through which the Coordinator learns each rmxOS feature. Designing that pipeline + grading our current posture is a roadmap-level strategy call → Oracle consult, not a Ruler task.

## THE COORDINATOR'S VISION (the subject to design + pressure-test)
An ongoing, out-of-order (OOO-pipeline-style) conformance-to-regression conveyor:

1. **Author ahead, on the Explorer side.** The two parity Explorers — **explorer-mx** (macOS host, mx-a64z) and **explorer-rx** (rmxOS host, rx-x64z), collectively **explorer-nx** — write test cases in **Elixir** (orchestration), **Zig** (metal probe), and eventually **swift-testing** (post li-9001 Swift toolchain). explorer-mx establishes the *correct semantics on macOS-as-truth*; explorer-rx drives rmxOS to match.
2. **Run ahead of the Implementer without stalling.** Tests are authored speculatively, ahead of the feature existing. A test whose feature isn't implemented yet is **marked skipped/queued** (OOO-style: issued ahead, parked, not blocking) so the rest of the agent pipeline flows — the Implementer, other Explorers, Gatekeeper never stall waiting on a not-yet-buildable test.
3. **Commit when the feature lands.** When the Implementer ships the feature, the parked test "retires" from skipped → active and must go green (rmxOS matches macOS truth).
4. **Migrate to the Gatekeeper for QA.** Once green, the test **migrates from the Explorer authoring side to the Gatekeeper side** as a standing regression / soak gate.
5. **Coordinator learns through it.** The macOS-truth conformance corpus is the living spec the Coordinator reads to understand each feature.

## SCOPE / SUBJECT (design review — READ + REASON, do NOT write product)
- **Grade the EXISTING posture first-hand**, then design the target. Read our actual test/harness tree and the standing greens; do not reason from reputation. Cite file/records.
- **Established constraints to BUILD ON, not re-litigate** (hard-won, in-force): the harness pillar is **Elixir orchestration + Zig metal probe + DTrace `.d` observation** — a big shell `.rc/.sh` harness is banned (direct CLI fine); never commit `printf`/`dprintf` scaffold; `fbt::` bars trace **kernel only** (a userspace crash bar uses `fbt::sigexit`/`proc:::signal-clear` on the target PID); XPC event-handler probes must pump a serial queue+semaphore, not main-thread sleep; **conformance-MATCH is leg-3 of a 4-leg truly-green bar** (lifecycle / traced-matrix / conformance-MATCH / soak); soak is Gatekeeper's, discovery-soak is Explorer's.
- **Fold in op-225's evidence-regime findings:** every test result must be **regime-labeled** (kernel ident, mach.ko/libdispatch flags, per-run engine evidence) — the M1 discipline. A conformance/regression pipeline that doesn't record its regime repeats the caveat op-225 surfaced.
- IN scope: the full conformance→regression lifecycle, the parked-test (skip/queue) bookkeeping, the role handoff (Explorer-author → Gatekeeper-own), authoring-language selection (Elixir/Zig/swift-testing), macOS-truth capture + diff workflow, and how it scales to future features. OUT: re-designing individual existing probes; the product code under test; picking the milestone (Coordinator-held).

## DELIVERABLES (a review document — proposal, not product edits)

**D1 — current-posture grade.** Read the existing harness + standing greens first-hand and grade them: what the Elixir/Zig/DTrace pillar does well, where conformance vs regression are conflated, coverage gaps, and how the op-225 regime-labeling gap manifests in the current suites. Overclaim-strict; "undetermined where the record doesn't say." → `OP228_POSTURE`

**D2 — conformance-to-regression lifecycle.** Define the test lifecycle rigorously: states (authored → parked/skipped → active → green → migrated-to-regression → retired-on-feature-removal), who owns each transition, and what "migrate from Explorer to Gatekeeper" means *concretely* (file move? tag? registry? re-home in the harness?). Resolve the role-boundary nuance: Explorer authors the macOS-truth conformance case; Gatekeeper owns it as a regression/soak gate; Implementer builds binaries under test — where exactly is each handoff line, and does `harness_authoring_is_gatekeeper` (orchestrator authoring = Gatekeeper) conflict with "Explorer authors conformance probes"? Reconcile it. → `OP228_LIFECYCLE`

**D3 — the non-stall (OOO) mechanism.** Design how tests authored *ahead* of implementation are parked so the pipeline never stalls, AND — critically — never silently lost. Specify the skip/queue/xfail semantics, and the **pending-gate ledger** that guarantees a parked test is *activated* (not forgotten) the moment its feature lands. What triggers the skip→active transition? How does an agent (or the Coordinator) see "N tests are parked waiting on features X, Y, Z"? This is the novel crux — grade its feasibility and design it concretely. → `OP228_NONSTALL`

**D4 — macOS-as-truth capture + diff workflow.** How explorer-mx (macOS) and explorer-rx (rmxOS) coordinate to (a) capture correct semantics on macOS and (b) diff rmxOS against them. Cover: the authoring-surface choice (when Elixir vs Zig vs future swift-testing), how a captured macOS behavior becomes a portable assertion both explorers run, and how divergences are recorded — respecting `verify_signature_divergence_claims` (a claimed rmxOS-vs-macOS divergence must be verified at source before it drives a test change). → `OP228_TRUTH`

**D5 — scale + future (swift-testing, Coordinator-learning).** How the pipeline scales to new features and onboards a future **swift-testing** surface (post li-9001 Swift toolchain). How the conformance corpus doubles as the living macOS-truth spec the Coordinator reads to learn each feature — what makes it legible as documentation, not just pass/fail. → `OP228_SCALE`

**D6 — synthesis + escalations.** One-paragraph verdict on the strategy's soundness + the sharpest risks, plus the Coordinator-decision escalations (e.g. role-boundary doctrine, whether this becomes a standing gate vs advisory, milestone placement). Flag, don't decide. → `OP228_SYNTHESIS` / `OP228_TERMINAL`

## BOUNDARIES
- **Consult-only. NO product-write** — output is a review/design document, not harness code or test files. The Oracle proposes; the Implementer/Explorer/Gatekeeper are the writers per role.
- **First-hand source/record read** — grade the *actual* harness + greens; cite file/line or committed record; do not infer from filename or reputation.
- **No milestone/doctrine calls** — role-boundary reconciliation, standing-gate status, and milestone placement are recommendations; the decision stays Coordinator-held (Arranger relays). Flag, don't decide.
- **Build on the established constraints** (harness pillar, DTrace rules, leg-model, regime-labeling) — do not re-litigate them; extend them.
- Stage any scratch in the Oracle's OWN dir (agent_host_isolation).

## MARKERS
```
OP228_POSTURE    # first-hand grade of existing test posture (harness pillar, conformance/regression conflation, coverage + regime-label gaps)
OP228_LIFECYCLE  # conformance→regression lifecycle: states, ownership, concrete Explorer→Gatekeeper migration, role-boundary reconciliation
OP228_NONSTALL   # OOO park-ahead mechanism: skip/queue/xfail semantics + pending-gate ledger so parked tests activate (never lost)
OP228_TRUTH      # explorer-mx/rx macOS-as-truth capture + diff workflow; Elixir/Zig/swift-testing surface selection; divergence-verify discipline
OP228_SCALE      # scale to new features + swift-testing onboarding; corpus as Coordinator-learning living spec
OP228_SYNTHESIS  # verdict + Coordinator-decision escalations (role doctrine, standing-gate, milestone)
OP228_TERMINAL
```

## RELATIONS
- UPSTREAM: **op-225** (evidence-regime review — its M1 regime-labeling MUST be baked into every test result here; the two consults are complementary: op-225 = "what did our greens prove," op-228 = "how should we produce greens going forward"). **op-223** (LEG A foundation review — its Item-5 test-coverage gaps [li-9004 Item 5] are concrete inputs to D1). **op-147m** (the Elixir+Zig+DTrace harness pillar — the established base).
- DOWNSTREAM: the lifecycle + non-stall design may seed a dedicated **test-strategy id** (IDQ) and, per the role split, Explorer authoring ops + Gatekeeper regression-migration ops + Implementer harness-binary builds. Coordinator-held whether it becomes a standing preview gate.
- project: parity-explorer (macOS-as-truth loop; explorer-mx mx-a64z / explorer-rx rx-x64z, GitHub-synced mach-oracle); the 4-leg truly-green bar; 1.0-preview gate.
- feedback: verify-premise-before-mechanism, verify_signature_divergence_claims (macOS-truth capture), conformance_match_is_leg3_only, harness_authoring_is_gatekeeper + build_is_implementer + soak_is_gatekeeper (the role split D2 must reconcile), dtrace_first_debugging + fbt_traces_kernel_only + xpc_probe_pump_queue (established harness constraints to build on), artifact_identity_needs_content_check + no_conflate_gating_with_readiness, agent_host_isolation. Explorer roster caveat: rx2 (rmx-explorer-2) is OUT/parked — the explorer-rx seat is rx1 (rmx-explorer / rx-x64z); do not assign rx2.
