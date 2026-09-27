---
id: op-229
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-229 — Gatekeeper: build the park-ahead OOO mechanism + pending-gate ledger (the non-stall crux) — parked/xfail tags + committed ledger + `mix oracle.parked` diff task

op-229 | role: **Gatekeeper** (harness-authoring) | EXU: **rmx-gatekeeper-rx-x64z** | state: **[Done — COMPLETE 2026-07-02 @ 2771dbc, Arranger-verified first-hand]** | parent id: id-033 (Stream A) | L1i: li-1000 (relates li-1007 / id-007 soak infra; the parity-explorer loop) | cost: gatekeeper-tier (free role; harness-authoring) | authored 2026-07-02 (Arranger seat, model Opus 4)

## ADJUDICATION (Arranger, 2026-07-02) — deliverable MET
Verified first-hand at 2771dbc: `ExUnit.start(exclude: [:parked, :xfail])` (test_helper.exs:4); committed ledger (parked_ledger.ex) + `mix oracle.parked` diff task (Lock 1, advisory/`--strict`); demo parked+xfail test. Ran: `mix oracle.parked --strict` → exit 0 "LEDGER AND TAGS AGREE (2 reconciled)"; the 2 parked/xfail are excluded and never redden the suite (the deliverable). Lock 2 activation documented (feature-op retire → untag → activated:true → `--strict` reconciles).
**Report-claim correction:** the report said "suite GREEN" — the park mechanism is green, but the Gatekeeper repo has **4 pre-existing unrelated failures** in env_test.exs / stable15_env_matrix_test.exs (confirmed failing at parent 3b43f9d, before this op; neither op-229 nor op-230 touched those files). Not an op-229 defect; flagged separately for the Coordinator (see ROB note).

## CONTEXT (read first)
Open-source OS engineering — OUR OWN Elixir test harness for the rmxOS Mach userland. Not security work. This authors test-orchestration scaffolding (Gatekeeper harness-authoring per the op-228 D2 role split); it writes NO product code and NO conformance content (that is Explorer's).

## WHY (one line)
op-228 D3 verified first-hand there is **NO park/skip convention** in any harness tree (zero `@tag`/`@moduletag`/`ExUnit.configure`/`exclude` across rmx-explorer, rmx-gatekeeper, wip-gpt/test) — so a test authored *ahead* of its feature has no way to park without either failing the suite or being silently deleted. This is the novel crux of the Coordinator's OOO vision: author-ahead must never stall the pipeline AND never silently lose a parked test.

## SCOPE (the two-flavor park + the ledger; op-228 D3)
1. **Two park flavors.**
   - **parked** — feature absent: an `@tag`-excluded case (via `ExUnit.configure(exclude:)`) that does NOT run, so a not-yet-buildable test never reddens the suite.
   - **xfail** — feature partial/landing: runs, expected-fail, and **self-activates** (flips to a normal green expectation) when the feature lands.
2. **Committed parked-ledger.** A checked-in ledger (one record per parked/xfail test) naming: the test, the feature it waits on, the IDQ id / feature-op it is blocked by. This is the "N tests parked waiting on X,Y,Z" register the Coordinator reads.
3. **`mix oracle.parked` diff task.** A mix task that reconciles ledger ↔ actual parked tags: **fails** if a parked/xfail test exists with no ledger entry, or a ledger entry names no live test. This is Lock 1 — parked tests cannot silently drift.
4. **Lock 2 hook (design + wire the trigger, do not fake a feature).** The activation trigger is a feature-op reaching [Retired]/[Done]: document + wire how that flips its parked test skip→active. If no live feature-op is ready to demo against, stub the hook with a synthetic ledger entry and prove the diff task catches drift both ways.

## NON-SCOPE (explicit)
- Does **NOT** author conformance test content (Explorer/explorer-nx owns the macOS-truth cases).
- Does **NOT** decide whether `mix oracle.parked` becomes CI/retirement-blocking vs advisory — that is **E2 (Coordinator)**. Build it advisory-capable; the gating switch is a later flip.
- Does **NOT** touch product source (userland-port; this is harness only).

## DELIVERABLE
Working parked/xfail tagging + a committed parked-ledger + a green `mix oracle.parked` that demonstrably fails on injected drift (both directions) and passes when ledger and tags agree. Proof: a demo parked test that is excluded from a run, appears in the ledger, and is caught if removed from either side.

## BOUNDARIES
- Gatekeeper **authors harness + dry-run validates**; does not build product binaries (build_is_implementer) and does not author conformance content (Explorer).
- Build on the established pillar: Elixir orchestration (op-147m); no big shell `.rc/.sh` harness; no committed `printf`/`dprintf`.
- Stage only in the Gatekeeper's own dir (agent_host_isolation).

## RELATIONS
id-033 Stream A (source; the HIGH-feasibility first-to-build stream); op-228 D3 (design) + D2 (role split — this is harness *infrastructure*, Gatekeeper's per the reconciled doctrine, pending E1 stamp); op-147m (harness pillar). feedback: harness_authoring_is_gatekeeper, soak_is_gatekeeper, dtrace_first_debugging (no committed scaffold printf), no_conflate_gating_with_readiness (advisory now, E2 decides gating), op_state_dispatch_boundary, agent_host_isolation. Explorer seat is rx1 (rx2 parked) — but this op is Gatekeeper, not Explorer.
