# op-231 — Oracle: consult on the libdispatch↔Swift-concurrency join (P1) — grade the behavior-ready gate + design the test-first (macOS-27-truth) conformance plan for the first Swift integration feature

op-231 | role: **Oracle** (consult) | EXU: **rmx-oracle-rx-x64z** | state: **[Done — consult DELIVERED 2026-07-02 @ rmx-oracle/op-231-swift-dispatch-join-review.md; Arranger spine-verified first-hand; full-claim verification DELEGATED to op-233 (L gate, Rule 11)]** | parent id: li-9001 (Swift toolchain long-arc) + the cross-project swift-rmxos-integration-plan; relates id-033 (test pipeline) | L1i: li-9001 / li-1002 (libdispatch) / li-1000 (relates the foundation TWQ blocker) | cost: **oracle-tier (highest; consult-only, no product-write)** | authored 2026-07-02 (Arranger seat, model Opus 4)

## ADJUDICATION (Arranger, 2026-07-02) — consult DELIVERED; gate sized L, delegated (Rule 11)
Oracle delivered a five-block consult (D1 gate / D2 sequence / D3 test-first plan / D4 role fit / D5 synthesis) at rmx-oracle/op-231-swift-dispatch-join-review.md, all markers present (OP231_GATE→TERMINAL).

**Gate size: L** (large cross-plane verification surface: libdispatch/queue.c + libthr/thr_workq.c line-cites, kernel THRWORKQ conf matrix, commit ancestry, op-227 banner, op-228/id-033 doctrine reconciliation). Per Rule 11 the full first-hand verification is delegated to a Validator (op-233); Arranger performed a light provenance spot-check on the load-bearing spine only.

**Arranger spine spot-check (first-hand, all PASS):**
- canonical HEAD = `106f9d7fd160` ✓ (matches consult).
- `5675145df333` (Jun-20 grant-clamp/handoff fix) IS an ancestor of `c14e0904` (op-182 cert source) — `git merge-base --is-ancestor` YES ✓ (the fix is in the certified ship lineage, as claimed).
- `queue.c:755` honors `LIBDISPATCH_DISABLE_KWQ` (cell-3 pool-force) ✓.
- `queue.c:899-900` op-227 banner `"libdispatch concurrency engine: %s" → "twq kernel workqueue" | "pthread pool"` ✓ (landed-in-source, unvalidated — matches consult's P1).
- `THRWORKQ` present in `sys/amd64/conf/MACHDEBUGDEBUG` (1), absent in `MACHDEBUG` (0) ✓ — the 3-cell engine matrix stands.
- op-229 @ `2771dbc` + op-230 @ `991dae2` already Arranger-verified (prior session) — the park-ahead + regime-block premises hold.

**DELEGATED to op-233 (not spot-checked here — the L labor):** the `5675145` diff mechanics (grant clamp `MIN(admitted,pending)`, `spawn_needed` overcount, `twq_pick_bucket_locked` handoff); `thr_workq.c:1090-1155` accounting; sub-fix #2 (#21 MACH_RECV) open-status separation; and first-hand triage of the untriaged **`op193-dispatch-chur.core`** (Jun-29, post-fix — engine/kernel/workload undetermined; a standing contrary-evidence flag until triaged). op-233 attaches confidence 1-10; Arranger steps in only if <9.

**Verdict accepted (pending op-233):** join is READY for its design + test-first phase now (op-232 mx-capture + the layer-1 substrate op have no dependency on anything unproven); the Implementer build gate is NOT cleared — sub-fix #1 is present-but-unproven (zero engine-attributed twq runtime evidence; zero Swift-shape stress evidence on either engine). A pool-engine v1 smoke is a legitimate explicitly-labeled milestone, a false green if it stands in for ship-engine (twq-default) readiness.

**Ops seeded (this adjudication):** op-233 (Validator L-verification, [Awaiting]); op-234 (op-227 banner validation across 3 cells — Sequence step 1, [Awaiting]); op-235 (layer-1 substrate stress shapes — E4 seat called = Gatekeeper harness; [Held on op-233 ≥9]). E1/E2/E3/E5 flagged Coordinator-held (see D5). op-226 already [Queued]; op-232 item 1 startable now.

## CONTEXT (read first)
Open-source OS engineering — OUR OWN Swift-on-rmxOS bring-up. rmxOS is a Darwin/Mach userland (libdispatch, libmach, libxpc, launchd, asl) on FreeBSD 15. The Coordinator has **opened the libdispatch↔Swift-concurrency join (P1)** — the first Swift integration slice — for its **design + test-first phase** (NOT the Implementer build; that stays gated on this consult + the tests). Not security work; internal maintainer-style integration + test design.

## WHY (one line)
swift-rx (the sibling Swift-6.4 arranger, shared Coordinator) has a launchable 6.4 toolchain and P1 = "rebuild libswiftDispatch + libswift_Concurrency against rmxOS libdispatch → concurrency smoke." The cross-project contract (3 resolved exchange rounds) established the **ABI is satisfied** (our libdispatch exports the ~80 classic `dispatch.h` symbols; no executor port for v1) but flagged the crux: **ABI-satisfied ≠ behavior-ready** — Swift's fallback executor `dispatch_async_f`'s to global queues, which rides the dispatch **worker-pool/TWQ servicing** (sub-fix #1 / completion-debt #19, the historical KWQ abort). Whether that services correctly on our CURRENT engine (twq dormant → userland pthread-pool fallback, per op-225 / li-9003 Item 2) is unproven. The Coordinator wants (a) that gate graded first-hand and (b) the join done **test-first, macOS-27 as truth** — exercising the new op-228/id-033 pipeline: explorer-nx authors the macOS concurrency semantics ahead, parks them (op-229), drives rx to match.

## SCOPE / SUBJECT (READ + REASON; do NOT write product or tests)
Read first-hand and cite: our `lib/libdispatch/src/queue.c` root-queue + worker-pool servicing path, the pthread-pool fallback (op-225 / thr_workq.c constant probe, being fixed by op-227), the `dispatch_async_f`→global-queue execution path Swift's fallback executor uses, and the swift-rmxos-integration-plan exchange rounds (esp. "one fix, three consumers" → the two dispatch-servicing sub-fixes). Build on — do NOT re-litigate — the established constraints (Elixir+Zig+DTrace harness pillar; 4-leg truly-green bar; op-225 M1 regime labeling; op-228/id-033 lifecycle + park-ahead mechanism op-229; the plan's parity-first process).

## DELIVERABLES (a consult document — proposal, not product/test edits)

**D1 — behavior-ready gate, graded first-hand.** Does Swift's fallback executor (`dispatch_async_f` → global concurrent queue → worker-pool servicing) actually RUN work on our current libdispatch, or does it hit the KWQ/TWQ abort the daemons did? Grade the CURRENT state (post-op-227 honesty, twq still dormant / pthread-pool fallback per op-225 C2-pending): can the **pthread-pool fallback** service global-queue dispatch adequately for a v1 concurrency smoke, or must sub-fix #1 (real TWQ worker-pool servicing) land first? Overclaim-strict; "undetermined where the servicing path doesn't say." → `OP231_GATE`

**D2 — join sequencing.** Given D1, define the concrete P1 sequence: what must be true on the rmxOS side before the executor-hook probe (flip libdispatch provider seam → does Swift Concurrency ride it?) is meaningful, and where op-227 (engine banner/probe), op-225 C2 (pool-acceptability), and the sub-fix #1 TWQ work sit relative to the join. Is a v1 smoke on the pthread-pool fallback a legitimate milestone, or a false green? → `OP231_SEQUENCE`

**D3 — the test-first conformance plan (the headline deliverable).** Design, concretely, how explorer-nx does this join **test-first with macOS-27 as truth**, using the op-228/id-033 pipeline: which macOS-27 Swift-concurrency semantics to capture FIRST as the spec (the plan's stress shapes — wide-fan-out TaskGroup / actor churn / deep async-await chain → all stress sub-fix #1); how each is authored as a portable behavior vector (Swift-source-on-both-targets probe emitting JSON, Elixir comparator), captured on mm4/mx-a64z (human checkpoint), then run on rx; how they are **parked ahead** (op-229 skip/xfail + pending-gate ledger) since the rx executor join isn't built yet, and what triggers skip→active. Respect `verify_signature_divergence_claims` (a claimed rx-vs-macOS concurrency divergence is verified at source before it drives a fix). → `OP231_TESTFIRST`

**D4 — regime + role fit.** How the op-225 M1 regime label (kernel ident, mach.ko/libdispatch flags, per-run engine evidence via the op-227 banner) attaches to every concurrency comparison record here (this is a live first consumer of op-230's `mismatch_v1` regime field). And the role split: explorer-nx authors the conformance content; the Implementer build (rebuild libswiftDispatch / any sub-fix #1 servicing work) is a LATER Implementer op; Gatekeeper owns the migrated regression gate. Where are the handoff lines for THIS join? → `OP231_ROLEFIT`

**D5 — synthesis + escalations.** One-paragraph verdict on join readiness + the sharpest risks (esp. false-green on the pthread-pool fallback), plus Coordinator-decision escalations: does P1 proceed on the fallback or wait for sub-fix #1; the swift-rx toolchain-readiness handoff needed before any Implementer build; milestone placement (post-preview per li-9001). Flag, don't decide. → `OP231_SYNTHESIS` / `OP231_TERMINAL`

## BOUNDARIES
- **Consult-only. NO product-write, NO test-write** — output is a design/consult document. The executor join + any servicing fix is a later Implementer op; the conformance tests are explorer-nx's to author.
- **First-hand source read** — grade the actual servicing path + cite the plan's exchange rounds; do not infer from the plan's summaries alone.
- **No milestone/doctrine calls** — proceed-on-fallback vs wait-for-sub-fix-#1, and milestone placement, are recommendations; the decision stays Coordinator-held.
- **swift-rx boundary** — the Swift-side toolchain build + libswiftDispatch overlay is swift-rx's domain (build_is_implementer applies cross-track); this consult speaks authoritatively only for the rmxOS libdispatch foundation + the parity test design. Flag the swift-rx handoff, don't assume it.
- Stage scratch in the Oracle's OWN dir (agent_host_isolation).

## MARKERS
```
OP231_GATE       # behavior-ready gate graded first-hand: does Swift's fallback executor run on current libdispatch (pthread-pool) or need sub-fix #1 TWQ servicing?
OP231_SEQUENCE   # concrete P1 join sequence; where op-227 / op-225 C2 / sub-fix #1 sit; is a fallback smoke legit or false-green
OP231_TESTFIRST  # the test-first macOS-27-truth conformance plan via op-228/id-033: which semantics first, parked-ahead (op-229), rx-match
OP231_ROLEFIT    # op-225 M1 regime label on every record (op-230 first consumer); explorer-author / Implementer-build / Gatekeeper-own handoff lines
OP231_SYNTHESIS  # verdict + escalations (proceed-on-fallback vs wait; swift-rx handoff; milestone)
OP231_TERMINAL
```

## RELATIONS
- **swift-rmxos-integration-plan.md** (the cross-project contract; 3 resolved exchange rounds; the "two dispatch-servicing sub-fixes" + "one fix, three consumers" analysis is the direct backing) + **swift-darwin-native-path.md** (Layer B pthread/lock rides the same TWQ solidity gate) + **doc/swift-handoff/nextbsd-dispatch-provenance.txt** (our libdispatch.so.5 ABI: 145 dispatch_* exports, HAVE_PTHREAD_WORKQUEUES=1).
- **op-228 / id-033** (the test pipeline this exercises; op-229 park-ahead mechanism + op-230 regime field are its live first consumers).
- **op-227** (engine banner/probe — the per-run engine evidence D4 leans on) + **op-225 C2** (pthread-pool acceptability — Coordinator-pending; D1/D2 inform it) + **li-9003 Item 2** (dormant twq engine).
- **li-9001** (Swift toolchain long-arc — Path A FreeBSD-triple first; this join is post-preview, does NOT gate li-1000) + **li-1002** (libdispatch).
- project: parity-explorer (explorer-mx mx-a64z macOS-27 truth / explorer-rx rx1); swift-rx (sibling arranger, op-068 track). feedback: verify-premise-before-mechanism, verify_signature_divergence_claims, conformance_match_is_leg3_only, build_is_implementer, soak_is_gatekeeper, harness_authoring_is_gatekeeper (vs explorer-authors-conformance — per op-228 D2), no_conflate_gating_with_readiness, dtrace_first_debugging, agent_host_isolation. Explorer seat = rx1 (rx2 parked).
