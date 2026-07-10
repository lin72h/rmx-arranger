# op-190 — Explorer (parity / macOS-truth): capture the macOS XPC cancel + error-delivery behavioral contract — the truth target for the bucket-3 fill (post-op-189)

op-190 | role: **Explorer** (free) | EXU: **mx-a64z** (macOS parity) | state: **[Done]** — `contract-captured`, pushed `7ef3b9a`; adjudicated 2026-06-28. macOS contract: local cancel→`XPC_ERROR_CONNECTION_INVALID`; remote death→`XPC_ERROR_CONNECTION_INTERRUPTED`; cancel-during-`_with_reply_sync`→waiter RETURNS `XPC_TYPE_ERROR` (invalidated, not dropped)+handler INVALID; errors = shared singletons (`xpc_equal`), `XPC_TYPE_ERROR`, dict_count=1. Artifact `op190-macos-cancel-truth.log` sha `7ba521d1…` (macOS 27.0 arm64 M4). KEY: op-122's cancel "(no event)" was a TEST artifact (main-thread sleep never pumped the queue) — macOS DOES fire it with serial-queue+semaphore pumping; does NOT shrink rmxOS scope (op-189 confirmed rmxOS cancel is an empty stub). Both bucket-3 precursors now closed → fill authorable (op-191). | parent id: id-021 | L1i: li-007 | authored 2026-06-28 (Arranger seat, model Opus 4)

## WHY (one line)

op-189 verified (Arranger first-hand) that cancel + error-delivery are empty in BOTH canonical AND donor
(`nx/NextBSD`), with no XNU libxpc reference on host → the bucket-3 fill is design-from-behavioral-spec, NOT a
port. The op-122 → op-187 pattern proved the right way to do a from-spec libxpc fix is to capture the macOS truth
FIRST and conform to it. This op captures the cancel/error contract so the Implementer designs to a quantified
target, not guesswork.

## CONTEXT (take as given)
- mx-a64z is the macOS parity EXU (captured op-122's `b465c783` round-trip). macOS libxpc IS the truth.
- macOS libxpc is closed-source — this is BEHAVIORAL capture (what the API delivers at runtime), not a source read.
- Anchor defect: op-122 `op122_plane_cancel_event_seen: FAIL` on rmxOS — the cancel event never fires. Capture
  what macOS fires in its place.

## DELIVERABLES — capture the observable contract (runtime, not source)

**D1 — cancel contract.** On `xpc_connection_cancel(peer)` AND on remote peer-close: which handler fires (event
handler) and with what object — `XPC_ERROR_CONNECTION_INVALID` vs `_INTERRUPTED` vs `_TERMINATION_IMMINENT`?
Capture the exact error constant and WHEN each applies (local cancel vs remote death vs reply-pending).

**D2 — error-delivery contract.** The `XPC_ERROR_*` object the event handler receives — is it the shared
singleton error dict? what keys? how does the client discriminate an error from a normal message
(`xpc_get_type(obj) == XPC_TYPE_ERROR`)?

**D3 — cancel-vs-pending-reply ordering (the op-187 coupling).** With a `_with_reply_sync` in flight, cancel the
connection: does the pending reply handler get invoked with an error object, or silently dropped? This is exactly
the `xc_pending` waiter-invalidation op-187's reply-context must support — capture what macOS delivers to the
waiter.

Capture as a serial/log artifact with sha (op-122-style, like `b465c783`), under mx-a64z's owned dir.

**VERDICT:** `contract-captured` (cancel/error/ordering behavior quantified → bucket-3 fill has a target) |
`blocked` (state what blocked the capture).

## BOUNDARIES
- macOS BEHAVIORAL capture ONLY — no source (closed), no rmxOS edit, no fill authoring.
- agent_host_isolation: stage in mx-a64z's owned dir only.
- Capture the contract; do NOT design the rmxOS impl — that's the Implementer fill op, gated on this capture
  + the Coordinator's preview-scope call on bucket-3.

## MARKERS
```
OP190_CANCEL_CONTRACT    # which handler fires + exact XPC_ERROR_* on local-cancel / remote-death / reply-pending
OP190_ERROR_DELIVERY     # the XPC_TYPE_ERROR object the handler receives: keys, singleton, type-discrimination
OP190_REPLY_INVALIDATION # cancel vs in-flight _with_reply_sync: what the pending waiter receives (error vs drop)
OP190_ARTIFACT           # captured serial/log path + sha (macOS truth, op-122-style)
OP190_VERDICT            # contract-captured | blocked
OP190_TERMINAL
```

## RELATIONS
- TRUTH TARGET for the bucket-3 cancel/error fill op (next libxpc Implementer dive; gated on this capture +
  Coordinator preview-scope call).
- UPSTREAM: op-189 (found donor empty → from-spec), op-122 (the round-trip capture this mirrors), op-187
  (the `xc_pending` reply-context cancel must invalidate).
- DOWNSTREAM: the Implementer bucket-3 fill; op-185's libxpc leg.
- feedback: role_costs (free parity Explorer), verify_signature_divergence_claims (quantified macOS target),
  parity_explorer (macOS-as-truth), least-intrusive (conform to captured truth — donor empty so capture replaces
  the port rung), no_conflate_gating_with_readiness (Coordinator owns whether bucket-3 gates preview).
```
