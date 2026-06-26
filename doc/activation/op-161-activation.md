# op-161 — Validator-DS4P: falsify the op-160 deferral scope (is the xpc service-plane spine truly buildable with Class-D/activity/shmem/fd deferred?)

op-161 | role: **Validator-DS4P** (cost-4 — falsification) | state: READY dispatch (authorized) | parent ids: id-021 + id-016 | authored 2026-06-26 (Arranger seat, model Opus 4)
purpose: de-risk the cost-30 op-160 BEFORE it sinks build hours. op-160 scopes the preview to the xpc_domain↔xpc_connection service-plane spine (send→reply→cancel→error over nvlist, launchd-hosted) and DEFERS as li-1008 catalog: Class-D (xpc_session_*/xpc_listener_*/rich_error/peer_requirement/connection_activate), xpc_activity_*, xpc_shmem_*, xpc_fd_*, typed dict get/set beyond the plane. Falsify that deferral line. Inspection-only, NON-BLOCKING, runs IN PARALLEL with op-160.

DISTINCT FROM op-160's own calibration (do not duplicate it): the Implementer's Deliverable-1 finds the first BROKEN seam on the live path. This op asks the orthogonal question — **is any DEFERRED symbol secretly ON the critical path of the send→reply→cancel→error launchd-job plane?** Implementer = "where does it break"; DS4P = "is my deferral safe."

FALSIFICATION TARGETS (for EACH: prove off-path with file:line evidence, or surface it as critical-path):
- **F1 — Class-D leakage.** Does the legacy `xpc_connection` send/reply/cancel/error path call into any `xpc_session_*` / `xpc_listener_*` / `connection_activate` / `rich_error` / `peer_requirement` symbol? Trace the connection lifecycle (`xpc_connection.c`) — if the legacy path is self-contained, deferral holds; if it reaches a Class-D symbol, that symbol is critical-path and must enter op-160 scope.
- **F2 — error delivery dependency.** `XPC_ERROR_*` delivery is a Class-C stub op-160 WILL fill. Does correct error delivery transitively require `rich_error` (Class-D) or any deferred type? If yes, the deferral under-scopes op-160.
- **F3 — endpoint/domain hosting.** launchd's xpc_domain hosting + `xpc_endpoint_create` (Class-C, to be filled) — does hosting a domain or accepting a connection touch `xpc_shmem_*` / `xpc_fd_*` (e.g. for large-message or fd-passing transport)? If the nvlist transport falls back to shmem/fd for any in-plane message size, shmem/fd is critical-path, not deferrable.
- **F4 — typed get/set on path.** The send/reply round-trip encodes/decodes an nvlist dict. Which `xpc_dictionary_get/set_*` typed accessors does the e2e demo actually traverse? Confirm the plane needs only the already-in-scope types, not the deferred ones (double/date/data/uuid/fd/connection).
- **F5 — id-016 model soundness.** op-160 validates via launchd-job only (shell-launch out of scope, port=0). Falsify: is there ANY in-plane step where the hosted domain or the client needs ambient bootstrap that the launchd-job model does NOT provide? (i.e. does the plane secretly need id-016 decision (a) to function, not just to be reached?)

DELIVERABLE / GATE (advisory, NOT a block on op-160):
- Per-target verdict: DEFERRAL-SAFE (off-path, file:line) or CRITICAL-PATH (the symbol + where the plane reaches it). 
- If any target = CRITICAL-PATH → fast signal to the Implementer to pull that symbol into op-160 scope BEFORE deep build (saves the cost-30 from a mid-build wall). If all SAFE → confirms op-160's scope line, de-risks the dispatch.
- Inspection only — no build, no run. Source-cite every claim.

MARKERS:
```
OP161_F1_CLASSD status=0        # legacy xpc_connection path reaches Class-D? safe(off-path) | critical(symbol+site)
OP161_F2_ERRORDELIV status=0    # XPC_ERROR_* delivery needs rich_error/deferred type? safe | critical
OP161_F3_ENDPOINT_SHMEM status=0# domain hosting / endpoint touches shmem/fd in-plane? safe | critical
OP161_F4_TYPED_GETSET status=0  # round-trip needs only in-scope dict types? safe | critical
OP161_F5_BOOTSTRAP status=0     # launchd-job model sufficient for the plane to FUNCTION? safe | critical
OP161_VERDICT status=0          # deferral line holds? SAFE | UNDER-SCOPED (list the pull-ins)
OP161_TERMINAL status=0
```

PUSH: report per-target verdicts → Arranger-seat first-hand check → feed any CRITICAL-PATH finding to op-160 (scope pull-in) immediately; if all SAFE, record the deferral line as falsification-confirmed for li-1008. Advisory to op-160, does NOT gate or merge.

CHAIN (preview long poles): op-160 (service plane build) ∥ **op-161 (DS4P falsify the deferral scope)** → any critical-path pull-in folds into op-160 before deep build → op-122 dual-explorer conformance ∥ Gatekeeper soak → li-1005 + li-1006 truly-green.
