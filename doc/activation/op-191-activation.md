# op-191 — Implementer: implement libxpc bucket-3 cancel + error-delivery to the op-190 macOS contract (the last load-bearing libxpc fill before the leg)

op-191 | role: **Implementer** (cost-30) | EXU: **wip-gpt** | state: **[Done]** — `bucket3-fixed`, adjudicated 2026-06-29 (Arranger, VERIFIED first-hand). Commit `501a1ef` on `op-171-x86-64-v3-alpha` (xpc_connection.c/xpc_type.c/xpc_misc.c/xpc_internal.h). Serial `0b856c37…`: all markers PASS x3 rounds — error singletons (INVALID/INTERRUPTED type+equal+distinct+count=1), local cancel (event fired+INVALID, idempotent), in-flight waiter invalidation (reply returned+invalid, handler fired+invalid), reply roundtrip GREEN (op-187 UNREGRESSED), remote death (event fired+INTERRUPTED); PROBE_FAILS=0, TERMINAL=0. VERIFIED first-hand: (1) probe PUMPS the queue — `dispatch_queue_create`+`dispatch_semaphore_wait/signal`, handlers signal a sem the test waits on, NOT main-thread sleep (the op-190 false-pass trap is honored; EVENT_FIRED markers are real). (2) Remote-death is BETTER than the report stated — PRIMARY path is Mach-native `DISPATCH_SOURCE_TYPE_MACH_SEND`/`DISPATCH_MACH_SEND_DEAD` on `xc_remote_port` (macOS-faithful dead-name), with a redundant `DISPATCH_SOURCE_TYPE_PROC` secondary; both funnel through idempotent `xpc_connection_interrupt`. rc=1 = benign poweroff artifact (serial TERMINAL=0). **libxpc CONFORMANCE now complete (reply+cancel+error all green); soak/lifecycle leg (op-185) remains — conformance-green ≠ truly-green.** RELEASED 2026-06-28: bucket-3 preview-scope call MADE (Arranger, delegated authority) → **cancel/error-delivery GATES 1.0-preview** (libxpc is a core service; "truly-green" requires connection-lifecycle signalling; this is solidify-existing, not the risk-excluded bucket). Dispatch-ready. Both precursors CLOSED: op-189 proved cancel/error-delivery are empty in BOTH canonical AND donor `nx/NextBSD` (design-from-spec, NOT a port); op-190 captured the macOS behavioral target (local cancel→`XPC_ERROR_CONNECTION_INVALID`, remote death→`_INTERRUPTED`, cancel-during-`_with_reply_sync`→waiter RETURNS `XPC_TYPE_ERROR` invalidated-not-dropped, errors = shared singletons/`xpc_equal`/`XPC_TYPE_ERROR`/dict_count=1). The fill is now fully specified → authorable. HELD only on the Coordinator's call whether bucket-3 cancel/error gates 1.0-preview (no_conflate_gating_with_readiness — I do not pre-empt that). Release to [Awaiting] on that call. | parent id: id-029 (libxpc) | L1i: li-007 | authored 2026-06-28 (Arranger seat, model Opus 4)

## WHY (one line)

op-187 closed the libxpc REPLY path (round-trip green); op-189+op-190 closed the precursors for the remaining
load-bearing slice — connection cancel + error delivery — which is an empty stub on rmxOS with a now-quantified
macOS target. This op implements that slice to the captured contract, the last libxpc fill before the integration
leg (op-185).

## SOURCE TREE (take as given — canonical, single editable tree)

- EDIT: `wip-gpt/wip-rmxos` @ branch `op-171-x86-64-v3-alpha` (HEAD `bc0ac550`, the op-187 reply-fix tip).
- READ-ONLY: `nx/NextBSD*` (donor) + stock FB-15 — donor cancel/error is EMPTY (op-189), so this is
  design-from-spec conforming to op-190's macOS capture, NOT a donor port. No other tree is editable.

## CONTEXT (op-189 + op-190 verified, take as given)

- rmxOS `xpc_connection_cancel` is an empty `{}` body; error-delivery machinery absent (op-189, Arranger-verified
  first-hand in canonical AND donor).
- macOS contract (op-190 artifact `op190-macos-cancel-truth.log` sha `7ba521d1…`, macOS 27.0 arm64):
  - local `xpc_connection_cancel(peer)` → event handler fires `XPC_ERROR_CONNECTION_INVALID`.
  - remote peer death → event handler fires `XPC_ERROR_CONNECTION_INTERRUPTED` (distinct constant).
  - cancel with a `_with_reply_sync` in flight → the pending waiter RETURNS an `XPC_TYPE_ERROR` object
    (invalidated, NOT silently dropped) AND the event handler gets INVALID.
  - the `XPC_ERROR_*` objects are shared singletons (`xpc_equal`-identifiable), type `XPC_TYPE_ERROR`,
    `dict_count == 1`.
- op-187 already built the reply-context plumbing (`xc_pending` / `xp_queue` waiter routing) this op must
  invalidate on cancel — the coupling is real, not new.

## DELIVERABLES (conform to the op-190 contract; cite the contract line per behavior)

**D1 — error singletons.** Define the `XPC_ERROR_*` shared singleton dicts (`CONNECTION_INVALID`,
`CONNECTION_INTERRUPTED`) as `XPC_TYPE_ERROR`, `xpc_equal`-identifiable (one canonical instance each, returned by
ref), `dict_count == 1`. Match the op-190 type-discrimination contract (`xpc_get_type(obj) == XPC_TYPE_ERROR`).

**D2 — local cancel.** Implement `xpc_connection_cancel` to (a) deliver the `CONNECTION_INVALID` singleton to the
connection EVENT handler, and (b) invalidate every pending `conn->xc_pending` waiter by RETURNING the
`XPC_TYPE_ERROR` singleton to it (op-187 coupling — the sync waiter returns with the error, does not keep
blocking). Idempotent: a second cancel is a no-op.

**D3 — remote death.** On remote peer close, fire the DISTINCT `CONNECTION_INTERRUPTED` singleton to the event
handler (not INVALID) — match the op-190 local-vs-remote split exactly.

**D4 — prove (queue-pumping probe, NOT main-thread sleep).** The conformance probe MUST drive a serial dispatch
queue + semaphore (or `dispatch_main()`) so the event handler actually runs — a main-thread `sleep()` false-FAILs
a correct impl (op-190 lesson; this is exactly the artifact that masked op-122's "no event"). Prove: cancel fires
INVALID, remote death fires INTERRUPTED, in-flight `_with_reply_sync` waiter returns `XPC_TYPE_ERROR`,
`op122_plane_cancel_event_seen` now PASS, AND the op-187 reply round-trip is UNREGRESSED. Capture as a serial/log
artifact with sha.

**VERDICT:** `bucket3-fixed` (cancel/error delivered to the op-190 contract, cancel_event_seen PASS, reply
unregressed → libxpc fill complete, op-185 leg unblocked) | `walled` (state what blocked — do not improvise an
off-contract behavior).

## BOUNDARIES

- EDIT canonical `wip-gpt/wip-rmxos` @ `op-171-x86-64-v3-alpha` ONLY. Donor/stock read-only.
- DESIGN-FROM-SPEC to the op-190 macOS contract — donor is empty (op-189), so there is no port to follow; do NOT
  invent behavior outside the captured contract (no extra error constants, no `_TERMINATION_IMMINENT` unless
  op-190 shows it — it does not for these cases).
- Touch the cancel/error slice + its `xc_pending` invalidation only; do NOT re-open the op-187 reply path beyond
  the invalidation hook. Build/prove is Implementer's (build_is_implementer); the harness probe pumps its queue.
- Stage strictly inside wip-gpt's owned dir; no host-global paths (agent_host_isolation).

## MARKERS
```
OP191_ERROR_SINGLETONS   # XPC_ERROR_* shared singletons defined: XPC_TYPE_ERROR, xpc_equal-identifiable, dict_count==1
OP191_LOCAL_CANCEL       # xpc_connection_cancel fires CONNECTION_INVALID to event handler + invalidates xc_pending waiters (return XPC_TYPE_ERROR)
OP191_REMOTE_DEATH       # remote peer-close fires distinct CONNECTION_INTERRUPTED
OP191_PROVE              # queue-pumping probe (serial queue+semaphore, NOT main-thread sleep): cancel/remote/reply-pending all match op-190
OP191_NO_REGRESS         # op-187 reply round-trip unregressed; op122_plane_cancel_event_seen now PASS
OP191_VERDICT            # bucket3-fixed | walled
OP191_TERMINAL
```

## RELATIONS
- UPSTREAM: op-189 (donor empty → from-spec), op-190 (macOS contract = the target), op-187 (the reply-context
  `xc_pending` plumbing this invalidates on cancel).
- DOWNSTREAM: op-185 (libxpc integration leg) — this is the last load-bearing libxpc fill before it.
- GATED ON: Coordinator bucket-3 preview-scope call (whether cancel/error gates 1.0-preview) — release [Held]→
  [Awaiting] on that decision, NOT before.
- feedback: build_is_implementer (builder implements + proves from its own tree), verify_signature_divergence_claims
  (op-189 donor-empty finding already first-hand verified — don't re-port), xpc_probe_pump_queue (D4 MUST pump the
  queue), least-intrusive (design-from-spec because donor is genuinely empty — the port rung is exhausted),
  no_conflate_gating_with_readiness (Coordinator owns the gate), agent_host_isolation, role_costs (cost-30 build).
```
