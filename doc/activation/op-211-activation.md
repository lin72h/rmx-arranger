# op-211 — Explorer: libxpc connection-lifecycle preview-demand census — is launchd's xpc_domain path live-over-nvlist or stubbed, and which preview-path consumers actually depend on cancel + XPC_ERROR_* delivery → ground the bucket-3 gating call in evidence

op-211 | role: **Explorer** (FREE) | EXU: **rmx-explorer** (rx1) | state: **[Done — challenges-gate, Arranger-verified first-hand @ 7fb01ab; ONE classification corrected].** Verdict HELD on corrected grounds → bucket-3 SOFTENED to li-005 post-preview (see li-007 resolution). First-hand checks: cancel is a REAL impl (xpc_connection.c:301-310, op-191 — op-189's "empty {} stub" stale), sole caller `aslmanager.c:179` is the ONLY bucket-3 consumer outside libxpc. **CORRECTION:** rx1 classified aslmanager "not shipped + crashes" — WRONG (op-204 made it run; it's the op-198-v5 asl-reclaim tool); the true "no demand" basis is that the call sits in `noreturn xpc_server_exit()` teardown-before-exit (aslmanager.c:176-183), not a semantic dependency. Verdict right, reasoning wrong — verify-first catch. Read-only source census, NON-CONTENDING (no soak host, no asld lane) — ran parallel to op-185/op-210 without touching them. | parent id: id-021 (libxpc/li-007) | L1i: li-007 | cost: free | authored 2026-06-29 (Arranger seat, model Opus 4)

## WHY (one line)

The Arranger resolved (2026-06-29, Coordinator-delegated) that libxpc **bucket-3** (real `xpc_connection_cancel` + `XPC_ERROR_*` interruption delivery) GATES the 1.0-preview — a JUDGMENT call. This op gathers the EVIDENCE that validates-or-challenges it: (1) is launchd's `xpc_domain` service path actually LIVE end-to-end over nvlist or still stubbed (li-007 plan step 1 — measures how much we already have before any fix), and (2) which preview-path consumers actually CALL cancel / depend on error-delivery (is the gate real-demand or theoretical?). Pre-scopes the eventual fill's blast radius so the cost-30 Implementer dive lands one-pass.

## SCOPE / SUBJECT (READ-ONLY census — no edits, no build, no boot)

- **Canonical tree** `wip-gpt/wip-rmxos` @ `op-171-x86-64-v3-alpha`. Diff/grep the SOURCE; cite **file:line** for every claim (verify_signature_divergence_claims: the Arranger adjudicates first-hand — an uncited "is stubbed" / "no consumer" claim drives nothing).
- **xpc_domain liveness:** trace launchd's service-hosting path — does `xpc_domain` actually stand up a live nvlist-over-Mach service plane (real bootstrap check-in + message servicing), or is it a stub/skeleton? Name the concrete functions + their state (impl / partial / stub).
- **Consumer-demand census:** across the PREVIEW userland (launchd, notifyd, asld/aslmanager, any bundled service + the libxpc test/conformance harnesses), grep every call site of `xpc_connection_cancel`, `xpc_connection_set_finalizer_f`, `xpc_transaction_begin/end`, and any reliance on `XPC_ERROR_CONNECTION_INVALID/INTERRUPTED/TERMINATION_IMMINENT` delivery. For each: is it a REAL preview consumer (ships + runs in the preview) or test-only/dead?
- DO NOT re-inventory the stub bodies (op-189 did that) or re-capture the macOS contract (op-190 did that) — CONSUME both as inputs; this op is the DEMAND side, not the supply side.

## DELIVERABLES

**D1 — xpc_domain liveness verdict.** launchd's `xpc_domain` service path characterized live-over-nvlist | partial | stubbed, with file:line per concrete function. → `OP211_XPCDOMAIN_STATE`

**D2 — consumer-demand census.** A table {call-site → file:line → real-preview-consumer? | test-only | dead} for cancel / finalizer / transaction / error-delivery reliance across the preview userland. → `OP211_CONSUMER_DEMAND`

**D3 — disposition.** Does the evidence CORROBORATE bucket-3 gating (live consumers depend on cancel/error-delivery) or CHALLENGE it (nothing in the preview path calls it → gate is theoretical, candidate to soften to li-005)? + the fill's blast radius (how many consumers a real cancel/error-delivery impl must satisfy). REPORT — do NOT re-decide the gate (Arranger owns that); supply the evidence. → `OP211_DISPOSITION` / `OP211_VERDICT` (`corroborates-gate` | `challenges-gate` | `mixed`) / `OP211_TERMINAL`

**VERDICT:** `corroborates-gate` (real preview consumers depend on bucket-3 → gating decision stands on evidence) | `challenges-gate` (no live preview consumer → flag to Arranger that the gate may be theoretical) | `mixed` (some demand, characterize it).

## BOUNDARIES
- **READ-ONLY** — source census only; no edits, no build (build_is_implementer), no boot, no soak. Stage notes in the rx1 owned dir (agent_host_isolation, NO host /tmp).
- **Cite file:line for every claim** — a "stubbed"/"no consumer" assertion is a divergence claim; the Arranger verifies first-hand before it touches the gating call (3× prior false-divergence history).
- **Don't re-decide the gate** (no_conflate_gating_with_readiness) — Arranger owns the scope call; this op supplies evidence, names demand, does NOT pronounce preview-ready/not.
- **Don't duplicate op-189 (stub inventory) or op-190 (macOS contract)** — consume them; this is the demand census, a distinct slice.
- Non-contending by design: does NOT touch the op-185 soak host, the asld lane (op-210), or any in-flight artifact.

## MARKERS
```
OP211_XPCDOMAIN_STATE   # launchd xpc_domain path: live-over-nvlist | partial | stubbed, file:line per fn
OP211_CONSUMER_DEMAND   # call-site table {cancel/finalizer/transaction/error-delivery → file:line → real|test|dead}
OP211_DISPOSITION       # corroborates|challenges the bucket-3 gate + fill blast-radius; REPORT not re-decide
OP211_VERDICT           # corroborates-gate | challenges-gate | mixed
OP211_TERMINAL
```

## RELATIONS
- UPSTREAM: op-189 [Done] (stub inventory — the supply side), op-190 [Done] (macOS cancel/error contract), li-007 scope-call-resolved 2026-06-29 (bucket-3 gates; this grounds it in evidence).
- DOWNSTREAM: feeds the eventual libxpc lifecycle FILL (cost-30 Implementer, sequenced foundation-first behind the libdispatch MACH_RECV servicing characterization + notify/asl closing). A `challenges-gate` verdict would re-open the Arranger scope call; `corroborates-gate` hardens it + sizes the fill.
- PARALLEL/NON-BLOCKING to op-185 (soak) + op-210 (asld) — different EXU (rx1), read-only, no shared resource.
- NOTE: rx1 only (rmx-explorer). rx2 (rmx-explorer-2) is parked-for-cause — do NOT route here.
- feedback: verify_signature_divergence_claims (file:line evidence, Arranger adjudicates), no_conflate_gating_with_readiness (supply evidence, don't re-decide), build_is_implementer (read-only), agent_host_isolation. project: 10preview_gate (libxpc core service), project_explorer_roster (rx1 IN / rx2 parked).
```
