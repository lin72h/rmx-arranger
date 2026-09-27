---
id: op-234
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-234 — Gatekeeper: validate the op-227 concurrency-engine banner across all three matrix cells — the per-run engine-attribution unlock

op-234 | role: **Gatekeeper** (harness run) | EXU: **rmx-gatekeeper-rx-x64z** | state: **[Done — banner VALIDATED 2/3 cells @ d541cd1, Arranger-adjudicated 2026-07-02; 2 caveats carried (SHA reconciliation + cell-1)]** | parent: op-231 D2 Sequence step 1 | L1i: li-9001 / li-1002 / li-1013 (op-225 M1 regime) | cost: gatekeeper-tier (free role; guest run + log read) | authored 2026-07-02 (Arranger seat, model Opus 4)

## ADJUDICATION (Arranger, 2026-07-02) — deliverable MET (banner validated); gate M, direct-gated (Rule 11); 2 caveats
Verified first-hand: commit `d541cd1` in rmx-gatekeeper descends from `991dae2` (op-230); adds `findings/op234-banner-validation.txt` (read in full). The runtime itself is guest-bound — not re-booted here; validated the committed record + the logical proof (Rule 1: verify what I can, defer the guest-bound).

**Deliverable MET — banner validated (the decisive proof is behaviorally self-proving):**
- Cell 2 (MACHDEBUGDEBUG, no env) → `libdispatch concurrency engine: twq kernel workqueue` (probe succeeded → kernel workqueue).
- Cell 3 (MACHDEBUGDEBUG + LIBDISPATCH_DISABLE_KWQ=1) → `pthread pool` (queue.c:755 force).
- The cell-2↔cell-3 differential on the **same kernel** (engine varies with env only) proves the banner tracks the real engine decision, not a constant — stronger corroboration than the cell-1 path would have given. Both engine strings observed; op-227's queue.c + thr_workq probe are behaviorally confirmed present (a pre-op-227 binary emits no banner at all).
- First concrete `evidence_source: init_banner` records for op-230: cell 2 `{dispatch_engine: twq_kernel}`, cell 3 `{dispatch_engine: pthread_pool}`, both `kernel_ident: MACHDEBUGDEBUG`, mach_ko `ffc67eda` (narg=8 + de-spam).

**Useful finding (procedure-affecting):** `_dispatch_log()` (init.c:474) is **silent by default** — the banner requires `LIBDISPATCH_LOG=stderr` at boot. In production the banner is silent, so any op needing engine attribution must either set that env or fall back to dtrace of the twq syscalls. **Carries to op-226 and op-235** (their regime `evidence_source: init_banner` capture depends on it).

**CAVEAT 1 — SHA reconciliation (artifact_identity_needs_content_check; my op-227 handoff precondition met in SPIRIT not LETTER).** The findings tested libdispatch sha **`35dd592a`** ("op-182 build, op-227 code present"), NOT op-227's Implementer-reported **`8623f0f4`**. Behaviorally fine (dynamic banner proves op-227 code is in `35dd592a`), but two libdispatch SHAs are now in play with no pin on which ships. **Open hygiene item:** confirm which libdispatch SHA is in the cert ship image (`c14e0904` lineage) and that it == a banner-validated binary. Folded into op-226 (reruns on the cert MACHDEBUGDEBUG image — can pin the SHA there). Not a blocker for op-227's banner-correctness retirement.

**CAVEAT 2 — cell 1 inconclusive, NON-blocking.** MACHDEBUG kernel booted (`sys/MACHDEBUG amd64`) but the test binary (`dispatch-churn-op193`) crashed before libdispatch init → banner not captured. Non-load-bearing: cell 1's expected `pthread pool` is by-construction (ENOSYS) AND the pool string is already proven on cell 3. **Cross-op link:** this crash is likely a fresh repro of the untriaged `op193-dispatch-chur.core` — **routed to op-233** (its item 3 triage). MACHDEBUG rode green in op-198 soaks, so a KBI/staging/lineage mismatch on this specific binary is the more likely cause than a MACHDEBUG defect.

**Effect:** op-227's banner mechanism is validated → op-227 RETIRES (on the mechanism; SHA-pin caveat tracked separately). op-226 [Queued] unblocked (has its banner-attribution basis).

## CONTEXT (read first)
Open-source OS engineering — validate that op-227's `libdispatch concurrency engine: %s` init banner (landed in source at `queue.c:899-900`, HEAD `106f9d7fd160`, Arranger-verified present) actually *behaves* on boot across the three engine cells. Not security work; a guest-boot + log-read on our own images. No product/test authoring.

## WHY (one line)
op-231 D2 makes this **Sequence step 1**: op-227 is landed-in-source but **unvalidated**, and until the banner is proven to report the correct engine per cell, **no engine claim anywhere is trustworthy** (op-220's UEFI green is the live precedent for a silent unattributed pool-fallback riding a MACHDEBUGDEBUG boot). This op turns the banner into the per-run attribution evidence op-230's regime block consumes (`evidence_source: init_banner`). Cheap; unlocks op-226 and every twq attribution downstream.

## SCOPE (guest run + log read; do NOT edit product)
Boot and read the banner in each cell of the op-231 engine matrix:
1. **Cell 1 — MACHDEBUG kernel** → expect banner `"pthread pool"` (twq unreachable by ENOSYS construction).
2. **Cell 2 — MACHDEBUGDEBUG kernel (the ship default), no env override** → expect `"twq kernel workqueue"` on successful TWQ_OP_INIT probe+init, OR an honest setdispatch-failure fallback log (op-227 :782-785) resolving to `"pthread pool"` — **either is a finding**; the point is the banner reports the *actual* engine, not a constant.
3. **Cell 3 — MACHDEBUGDEBUG kernel + `LIBDISPATCH_DISABLE_KWQ=1`** → expect `"pthread pool"` (queue.c:755 force).

Cross-check the banner against a second signal on at least cell 2 (dtrace of the twq syscalls, or `twq_probe_supported_features()` result) so the banner is corroborated, not self-asserted.

**Artifact-identity precondition (op-227 handoff, artifact_identity_needs_content_check / op-145 lesson):** before trusting any banner reading, confirm the booted image carries the op-227 lineage — `libdispatch.so.5` sha256 `8623f0f4c219d358bacc7c3653b7fcd8f14a809f3d3f905b8beff1dc49c25d39` and `libthr.so.3` sha256 `f4da8cde22733c18166f0e683ff24541e1884ff18680d618be8871ef24a4c7c8` (Implementer-reported at 106f9d7fd160). A same-name binary of different lineage silently invalidates the reading.

## NON-SCOPE
- Does NOT run a dispatch stress workload (that is op-235 / op-226) — this is a boot-time engine-identity check only.
- Does NOT decide the C2 pool-acceptability policy (Coordinator; D5 E1).
- Does NOT author conformance content.

## DELIVERABLE
Three regime-labeled records (one per cell) each carrying the observed banner string + the corroborating signal, proving the banner reports the true engine per cell (or surfacing a cell where it does not — itself the finding). This retires/validates op-227 and becomes the `init_banner` evidence source for op-230's regime block.

## BOUNDARIES
- Gatekeeper runs + validates; does not build product (build_is_implementer) or author conformance content (Explorer).
- Host preflight the run path before the guest boot (Gatekeeper guest-run discipline); attempt-accounting on any guest boot that emits candidate markers.
- Stage only in the Gatekeeper's own dir (agent_host_isolation).

## RELATIONS
op-231 D2 step 1 (source); op-227 (`106f9d7fd160` — the banner under validation); op-226 [Queued] (step 2, consumes this attribution); op-230 @ `991dae2` (the regime block whose `evidence_source: init_banner` this feeds); op-220 (the unattributed-green precedent this closes). feedback: harness_authoring_is_gatekeeper, soak_is_gatekeeper, artifact_identity_needs_content_check (regime/engine = part of artifact identity), dtrace_first_debugging (the corroborating signal), no_conflate_gating_with_readiness, verify-premise-before-mechanism (banner corroborated, not self-asserted). project: canonical tree = wip-gpt/wip-rmxos; ship default engine = twq (MACHDEBUGDEBUG carries THRWORKQ).
