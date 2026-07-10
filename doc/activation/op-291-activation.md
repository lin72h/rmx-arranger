# op-291 — Gatekeeper: acceptance pass for op-285's libxpc managed-lifecycle fix — the 4-part augmented runtime bar (provenance-gated), the FOLLOW-ON that op-285 deferred

op-291 | role: **Gatekeeper** (runtime evidence; no product-write) | EXU: **rmx-gatekeeper** | state: **[Ready / DISPATCH-RECOMMENDED — authored 2026-07-10 (Arranger1 seat) as the FOLLOW-ON acceptance pass op-285 explicitly deferred. op-285's EDIT is LANDED + Arranger1-verified first-hand at wip-gpt/wip-rmxos @ alpha `778cb07` (all 4 release-scope items confirmed at source; see op-285 header). This op measures whether the fix HOLDS at RUNTIME on a provenance-established build. Coordinator dispatches.]** | parent id: id-021 (libxpc conformance bring-up) | L1i: li-007 (libxpc core service) | cost: gatekeeper (small — guest lib swap + lifecycle drive + one managed-mode listener probe) | authored 2026-07-10 (Arranger seat, model Opus 4)

## CONTEXT (engineering framing)
Ordinary open-source OS engineering on our own IPC library. rmxOS = Darwin/Mach userland on FreeBSD 15. libxpc is a 1.0-preview core service (li-007). op-285 gave `struct xpc_connection` a real object header + a connection destructor + serialized first-message delivery + NULL-handler guards. This confirms the fix holds at runtime BEFORE libxpc is treated as green. No target, no adversary.

## WHY (one line)
op-284 (the premise-check) confirmed the defect at runtime; op-285 (Arranger1-verified first-hand at `778cb07`) landed the edit; per `no_conflate_gating_with_readiness` the edit landing is NOT acceptance — the 4-part augmented bar below (folded from op-284's own gaps) is the runtime evidence that sizes green.

## THE FIX UNDER TEST (Arranger-verified at source, so the probe measures a real thing)
- Object identity: `struct xpc_object xc_object` embedded at front of `struct xpc_connection` (`xpc_internal.h:110`).
- Destructor: `xpc_object_destroy` → `xpc_connection_destroy` (`xpc_misc.c:140`, `xpc_connection.c:563`+) — ports/queues/sources drained, finalizer, pending-call + peer + constructor-failure cleanup.
- First-message ordering: accept handler runs inline on the listener's serial recv queue; first message delivered via `xpc_connection_dispatch_event` only after peer setup returns.
- NULL-handler guard at every delivery site.
- Implementer's build claim (to be provenance-checked, NOT trusted): `libxpc.so.5` sha256 `9854f45b60b2223ce47d43b6cc51f68378f86460c74c4002690e469506cce713`, 200080 B.

## THE 4-PART AUGMENTED BAR (in order — folded from op-284's gaps; carried verbatim from op-285)
(a) **Artifact-provenance content-check FIRST.** op-284's guest libxpc sha `6393a714…` matched NONE of the host-staged builds (li-1012 problem live) — so BEFORE any probe result counts, the acceptance serial MUST print a libxpc sha that EQUALS the freshly-built fix artifact's sha (`9854f45b60b2223ce47d43b6cc51f68378f86460c74c4002690e469506cce713`). No sha match ⇒ probe results are void.
(b) **Full lifecycle sequence — not no-crash-only.** Balanced retain/release + resume/cancel/final-release + an owned-resource (port/queue/source) LEAK CENSUS at teardown. The destructor must actually reclaim what the connection owns.
(c) **Named-connection byte-0 re-check on the provenance-established build.** op-284's named-all-zeros was attributed to the stale deployed lib — it MUST NOT reproduce on a current build pre-fix, and POST-fix `xpc_get_type` must read the real `XPC_TYPE_CONNECTION` byte for BOTH anonymous and named connections.
(d) **Managed-mode reachability MEASURED.** `vproc_swap_integer VPROC_GSK_IS_MANAGED` under a launchd-hosted start + one real aslmanager listener drive IF reachable — confirming the accept path installs the peer handler before the first message on a live consumer.

## DELIVERABLE
A short staged evidence note (rmx-gatekeeper dir): the provenance sha match (or void), then per (b)/(c)/(d) the OBSERVED behavior against a known-good pre-fix control where meaningful, each characterized **passes / fails / unreachable-in-preview-config**. State plainly whether libxpc's connection lifecycle is GREEN at runtime on the provenance-established fix build. Commit the raw serial + harness (not a multi-GB image). Not a product edit, not a release decision.

## BOUNDARIES
- Read/measure + report only; no product edits (the fix already landed as op-285).
- Provenance FIRST: if the on-guest libxpc sha ≠ the fix artifact sha, STOP and report a provenance failure — do not report lifecycle results against an unknown lib (this is exactly op-284's li-1012 trap).
- Scope is EXACTLY the op-285 connection-lifecycle acceptance — do NOT expand into the op-283 pack/unpack path, the reply-correlation path (op-263), or other libxpc consults.
- Keep the observer alive for the full drive; an observer dying early is a FAIL, not a caveat.
- Does not decide milestone placement or release timing (sizes green; the Coordinator rules the milestone).

## RELATIONS
op-285 (the Implementer edit this ACCEPTS — Arranger1-verified first-hand at alpha `778cb07`) / op-284 (the premise-check whose 4 gaps this bar folds in) / 1.0-preview solidity consult (oracle2 finding #2 — the original defect) / op-289 (sibling evidence-first Gatekeeper pass on launchd, same epoch) / op-263 + op-271/op-283 (sibling libxpc paths, fenced out) / id-021 (libxpc conformance) / li-007 (libxpc core service). feedback: oss_engineering_framing, code_reasoned_verdict_is_hypothesis, no_conflate_gating_with_readiness, verify_signature_divergence_claims, agent_host_isolation, op_state_dispatch_boundary.
