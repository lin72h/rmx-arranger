---
id: op-232
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Partial
reset: j-20260927-004
---
# op-232 — Explorer (explorer-nx): author the libdispatch-concurrency conformance corpus TEST-FIRST — capture macOS-27 semantics as truth, park ahead of the Swift executor join, ready rx to match

op-232 | role: **Explorer** (conformance authoring) | EXU: **explorer-mx (mx-a64z, macOS-27 truth)** + **explorer-rx (rx1 / rmx-explorer, rx-x64z)** — collectively explorer-nx | state: **[Partial — content DONE + Arranger-adjudicated 2026-07-02; park-REGISTRATION mis-assigned (Arranger brief defect) → handed to op-236 (Gatekeeper Stream B). rx1 duplicate-infra quarantined; macOS truth human-checkpoint pending (Coordinator).]** | parent id: li-9001 + id-033 (Stream: first real conformance corpus through the pipeline) | L1i: li-1002 (libdispatch) / li-9001 (Swift) | cost: explorer-tier (free role; conformance authoring) | authored 2026-07-02 (Arranger seat, model Opus 4)

## ADJUDICATION (Arranger, 2026-07-02) — content MET; a repo-topology collision + one overclaim + a brief defect (gate L, Arranger-owned per Rule 6 conflict)
Two seats of one op reported divergently; verified first-hand rather than believe either.

**Verified first-hand:** `rmx-gatekeeper` still carries the canonical op-229/op-230 infra (`lib/mix/tasks/oracle.parked.ex`, `lib/rmx_os_oracle/parked_ledger.ex`, `regime` in `mismatch_v1.schema.json`). `rmx-explorer` push `8489fe7` created DUPLICATES: a second `lib/mix/tasks/oracle.parked.ex` + a parked ledger at a different path (`lib/rmx_os_oracle/concurrency/parked_ledger.ex`), alongside the legit `actor_churn.swift` enhancement.

**ACCEPTED — legitimate Explorer content (in lane):**
- macOS-27 truth capture (explorer-mx, 2d0dcbd + bfc2a5b): 3 canonical probes PASS on macOS-27 (fan_out 1000/1000; actor_churn all_consistent; deep_chain 500×10), regime DATA on truth records (XNU 13361 / native libdispatch / Apple worker-pool). **HUMAN-CHECKPOINT PENDING (Coordinator)** before these gain truth status.
- 3 Swift probes (rx1): `fan_out_taskgroup.swift` (1000 tasks), `actor_churn.swift` (500×20 + `OrderedCounter` for the D3 per-actor-mailbox ordering invariant), `deep_async_chain.swift` (500 depth × 10). Match-domain aligned to op-231 D3 (MATCH completion/exclusion/ordering/liveness/counts; EXCLUDE thread ids/counts, interleavings, timing, placement). Comparator authored.

**REJECTED / QUARANTINED — boundary violation + drift:** rx1's duplicate `oracle.parked.ex` + `concurrency/parked_ledger.ex` in rmx-explorer. rx1's "`mix oracle.parked` verified" verified the DUPLICATE, not the canonical op-229 ledger — an OVERCLAIM (verify_signature_divergence_claims family: an explorer report asserting a green that first-hand check downgrades). **Action:** the explorer keeps `actor_churn.swift` + the probes + comparator; drops the two duplicate infra files. The canonical park-registration is op-236 (Gatekeeper).

**explorer-mx was the accurate report** — it correctly declined to build Gatekeeper-lane infra (`agent_host_isolation`) and flagged the gap; its only slip was phrasing it "doesn't exist" (it exists in rmx-gatekeeper, a repo the Explorer can't reach).

**ARRANGER BRIEF DEFECT (owned):** op-232 item 2 told the Explorer to "park the corpus via op-229's mechanism," but op-229's ledger lives in rmx-gatekeeper and an Explorer cannot write cross-repo (agent_host_isolation). Cross-repo park-registration is a **Gatekeeper handoff = the id-033 Stream B authority-transfer**, not Explorer self-service. This is the first concrete case that releases Stream B's "hold until a case is ready to migrate."

**FINDING (real, explorer-mx-caught):** `comparator.ex:115` uses bare `System.cmd("swiftc", …)`; on mm4 that hits the broken dev snapshot (Foundation.swiftmodule parse fail) — must be `xcrun --toolchain XcodeDefault swiftc`. Harness-glue fix; folded into op-236 scope note (or a small explorer fix).

**Effect:** op-232's Explorer CONTENT deliverable is met (pending human checkpoint); the pipeline-registration deliverable moves to op-236 (Gatekeeper Stream B). op-232 does NOT fully retire until the corpus is registered in the canonical ledger (op-236) and the macOS vectors are human-checkpointed.

## CONTEXT (read first)
Open-source OS engineering — the macOS-as-truth parity loop for OUR OWN Swift-on-rmxOS bring-up. Not security work. This is conformance-CONTENT authoring (Explorer per op-228 D2), NOT harness infrastructure (Gatekeeper) and NOT product/toolchain build (Implementer/swift-rx).

## WHY (one line)
The Coordinator opened the libdispatch↔Swift-concurrency join (P1) and wants it done **test-first**: explorer-nx writes the macOS-27 concurrency behavior tests FIRST (the spec = ground truth), parks them ahead of the rx executor join existing (OOO, via op-229), then drives rx to match. This is the first real corpus through the op-228/id-033 pipeline AND directly executes the integration-plan's greenfield parity-first process ("write the macOS-27 behavior test FIRST, then implement rmxOS to pass").

## SCOPE (author conformance content; do NOT build product or toolchain)
1. **Capture macOS-27 truth (explorer-mx, startable NOW — design-independent).** On mm4 / mx-a64z, author portable behavior-vector probes for the Swift-concurrency semantics the plan named as the load shapes that stress the dispatch worker-pool (sub-fix #1): **(a) wide fan-out TaskGroup**, **(b) actor churn** (serial-queue create/teardown + hop), **(c) deep async/await chain** (continuation queue depth). Probe = Swift source compiled on the target emitting structured JSON; Elixir runner/comparator drives + diffs. macOS-27 result = **the spec**. HUMAN CHECKPOINT: validate the macOS behavior understanding before it is treated as truth.
2. **Park the corpus ahead (op-229 mechanism).** The rx side cannot pass until the executor join is built, so each case is **parked/xfail** with a **pending-gate ledger** entry naming the feature it waits on (the P1 executor join / sub-fix #1). Corpus does not stall the pipeline; it is not silently lost.
3. **Ready the rx-side probe (explorer-rx / rx1).** Author the same probe for rx so it is ready to run the instant the join lands; until then it stays parked. Drive rx→match is a LATER step (after the Implementer build), not this op.
4. **Regime-label every record (op-225 M1 / op-230).** Each comparison record carries kernel ident, mach.ko/libdispatch flags, and per-run engine evidence (op-227 banner or dtrace of twq syscalls) — this corpus is a live first consumer of op-230's `mismatch_v1` regime field.

## SEQUENCING (respects op-231)
- **explorer-mx macOS-27 truth capture (scope item 1): startable immediately** — capturing the reference platform's behavior is design-independent and the plan explicitly sanctions advance spec-test authoring.
- **The exact corpus shape + park/activate wiring (items 2-4): consume op-231 D3** (the Oracle's test-first plan) so the parked-ledger structure + which-semantics-first match the blessed design. Do not finalize the rx-side corpus ahead of D3.

## DELIVERABLE
A parked macOS-27-truth concurrency conformance corpus (the three stress shapes) with human-checkpointed macOS spec vectors, pending-gate ledger entries, regime-labeled comparison records, and rx-side probes ready-but-parked. Proof: macOS-27 vectors captured + validated; corpus visible in `mix oracle.parked` as "waiting on the P1 executor join"; nothing red, nothing lost.

## BOUNDARIES
- Explorer authors conformance **content**; does NOT build the executor join / servicing fix (Implementer, later op) or the Swift toolchain (swift-rx), and does NOT own the migrated regression gate (Gatekeeper).
- **verify_signature_divergence_claims** — a claimed rx-vs-macOS concurrency divergence is verified at source before it drives any fix or Coordinator decision (explorers have over-claimed divergences 3x historically).
- Harness pillar: Swift-source-on-both-targets probe + Elixir comparator (the plan's 3rd-pillar-later; swift-testing stays OFF this critical path until the executor is solid). No big shell harness; no committed printf.
- Explorer seat = **rx1** (rx2 is parked/OUT — do not assign). Stage only in the explorers' own dirs (agent_host_isolation).

## RELATIONS
- **op-231** (Oracle consult — its D3 is the test-first plan this executes; sequenced after D3 for the rx-side shape).
- **op-229** (park-ahead mechanism this corpus is the first real user of) + **op-230** (regime field on every record) + **id-033 / op-228** (the pipeline).
- **swift-rmxos-integration-plan.md** (the stress shapes (a)(b)(c) + parity-first process are drawn from its exchange round 3) + **li-9001** (Swift long-arc) + **li-1002** (libdispatch).
- **op-227** (per-run engine evidence source) + **op-225 M1** (regime labeling mandate).
- feedback: verify_signature_divergence_claims, conformance_match_is_leg3_only, harness_authoring_is_gatekeeper (this is the Explorer content half), soak_is_gatekeeper, dtrace_first_debugging, agent_host_isolation. project: parity-explorer, explorer-roster (rx1 IN, rx2 OUT).
