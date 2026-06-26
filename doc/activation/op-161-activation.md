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

---

## ARRANGER-SEAT VERDICT (2026-06-26, model Opus 4) — op-161 = SAFE confirmed (on first-hand source, NOT on DS4P's evidence)

DS4P's bottom line (deferral holds, zero critical-path pull-ins) is **CORRECT** — but verified independently against the active product tree `wip-gpt/wip-rmxos/lib/libxpc/`, because DS4P's evidence contains three fabricated code descriptions (reconstruction-from-memory pattern, same class as the op-158 parent-SHA error).

**Dispositive facts I verified first-hand:**
- **F1 linchpin TRUE** — grep of all 7 libxpc sources (subr_nvlist.c, subr_nvpair.c, xpc_array.c, xpc_connection.c, xpc_dictionary.c, xpc_misc.c, xpc_type.c): `xpc_session_*`, `xpc_listener_*`, `xpc_connection_activate`, `xpc_rich_error_*`, `xpc_peer_requirement_*`, `xpc_activity_*`, `xpc_shmem_*` = **0 defining files each**. The spine cannot reach code that does not exist. Deferral safe.
- **F3 TRUE** — no `xpc_shmem.c`/`xpc_fd.c` source exists at all → no transport fallback to shmem/fd for any message size. Transport is Mach + nvlist only. `xpc_connection_create_from_endpoint` (xpc_connection.c:132-143) stores the endpoint as a port (`conn->xc_remote_port = (mach_port_t)endpoint`, :141) — metadata only, no alloc.
- **F5 TRUE** — bootstrap_check_in (:104) / bootstrap_look_up (:121) / "bootstrap" string (:115-116); launchd-job model supplies bootstrap_port. No hidden dependency on id-016 decision (a) to FUNCTION.
- **F2 / F4 conclusions hold** — no `xpc_error_create`/rich_error infra exists (Class-C error fill starts from zero, no transitive Class-D dep); deferred serializer type-cases (DATE/DATA/UUID/FD/SHMEM/CONNECTION/DOUBLE/ERROR) are dead code unless a deferred-typed value is present, which the basic plane does not emit.

**DS4P evidence flagged (3 fabrications — verdict unharmed, reliability noted):**
1. F1 table: claimed `xpc_connection_cancel` (:263) calls `dispatch_release, mach_port_mod_refs`. **Actual body is EMPTY `{ }`** (:262-266) — Class-C stub per the op-160 census. (Empty → reaches no Class-D, so the SAFE conclusion is if anything stronger.)
2. F3: cited field `conn->xc_remote_endpoint`. **Actual is `conn->xc_remote_port`** (:141).
3. F4: claimed "`xpc_send` explicitly asserts `xo_xpc_type == _XPC_TYPE_DICTIONARY` (line 398)." **No such assert** — `xpc_send` (:362) just calls `xpc_pipe_send`; line 398 is `xpc_connection_recv_message`.

**CONSEQUENCE:** op-160's deferral line (li-1008 catalog: Class-D / activity / shmem / fd) is **falsification-confirmed SAFE** — no critical-path pull-in folds into op-160. The Implementer may scope to the send→reply→cancel→error spine as planned. op-161 → [Done] (advisory, non-blocking; did not gate op-160). DS4P evidentiary reliability flagged for the third time (op-158 SHA, now op-161 ×3 code fabrications) — future DS4P verdicts to be source-checked, not relayed.
