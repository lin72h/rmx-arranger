---
id: op-206
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-206 — Implementer: libxpc object-model fill — endpoint_create UB-stub + uuid/date typed dict accessors → advance li-007 past 5/13 (UNGATED object-model surface only)

op-206 | role: **Implementer** (cost-30) | EXU: **wip-gpt** | state: **[Done — fill-green @ 7a02d29; Arranger verified first-hand]** (2026-06-29). Verified at source: `xpc_endpoint_create` (xpc_connection.c:382) UB no-return KILLED → returns a real `_XPC_TYPE_ENDPOINT` from `xc_local_port`; PAIRED FIX `xpc_connection_create_from_endpoint` corrected (was the bogus `(mach_port_t)endpoint` pointer-as-port cast → now type-checks `_XPC_TYPE_ENDPOINT` + reads `xo->xo_port`, the necessary consume-side half); `set/get_date` added + the `_XPC_TYPE_DATE` serialization (previously a silent-drop empty `break;` at :180) now round-trips via `nvlist_add_date`/`NV_TYPE_DATE`; `set/get_uuid` accessors added (uuid WIRE serialization pre-existed at nv2xpc:119 / xpc2nv:195 — that's why `uuid_match=1` holds with no serialize-path diff). Build rc=0, Zig object-model probe rc=0 (date_match=1 uuid_match=1 count_match=1). Non-blocking: get_date/get_uuid skip the missing-key null-check — family-consistent with get_double/get_data, separate hardening item not an op-206 gate. Free of the op-185 soak seat; ran parallel to the overnight batch. **Scope deliberately EXCLUDES the dispatch-gated connection-lifecycle stubs** (cancel / error-interruption delivery / finalizer / transaction) — those are gated on the libdispatch MACH_RECV servicing sub-fix (li-007 §critical-convergence, debt #21) and must sequence AFTER it. This op fills only the OBJECT-MODEL surface, which is ungated. | parent id: id-021 (libxpc conformance bring-up) | L1i: li-007 | cost: 30 | authored 2026-06-29 (Arranger seat, model Opus 4)

## WHY (one line)

op-197 filled 4 typed accessors (set/get_data, set/get_double) + fixed get_name → li-007 at 5/13. The next ungated, preview-relevant gaps are pure object-model: **`xpc_endpoint_create` is a Class-C UB stub** (xpc_connection.c:379 — empty body, NO return → returns garbage), and the **uuid/date typed dict accessors are absent** (Class B — a dict carrying a uuid/date can't be read back). Both are nvlist/object-model work that does NOT touch the dispatch-gated connection servicing — fill them now off the free Implementer seat.

**VERIFY-FIRST NOTE (Arranger, do not re-derive):** `xpc_dictionary_create_reply` is ALREADY implemented (xpc_dictionary.c:284 — copies XPC_SEQID, clears `_XPC_FROM_WIRE`); it is NOT a fill target (an earlier scoping called it one — corrected here). data + double accessors are DONE (op-197). Confirm these on YOUR build HEAD before touching, then fill only the gaps below.

## SCOPE / SUBJECT (EDITABLE — rmxOS overlay, userland libxpc only)

- `lib/libxpc/xpc_connection.c` — `xpc_endpoint_create` (:379) UB no-return stub.
- `lib/libxpc/xpc_dictionary.c` — add `xpc_dictionary_set_uuid`/`get_uuid`, `xpc_dictionary_set_date`/`get_date` (mirror the op-197 set/get_data + set/get_double pattern @ :439-:520). Confirm the header decls in `xpc/xpc.h` and the matching `_XPC_TYPE_*` / nvlist type machinery first-hand.
- Reference the PROVEN pattern op-197 used: `_xpc_prim_create(_XPC_TYPE_*, val, …)` + the real private NV_TYPE serialization (op-197 added NV_TYPE_DOUBLE) — do NOT fake a type by coercing to uint/binary if a faithful nvlist representation is available; mirror how data/double were done.
- `xpc_endpoint_create`: build a real endpoint object from the connection's send port — mirror `xpc_dictionary_set_mach_recv`/`set_mach_send` (xpc_dictionary.c:313-336) which already do `_xpc_prim_create(_XPC_TYPE_ENDPOINT, val, 0)`. Pull the connection's port, package it, RETURN it (kill the no-return UB).

## DELIVERABLES

**D1 — endpoint_create returns a real object.** `xpc_endpoint_create` no longer falls off the end (no UB / no garbage return); it produces an `_XPC_TYPE_ENDPOINT` object carrying the connection's send port, mirroring the set_mach_send packaging. → `OP206_ENDPOINT`

**D2 — uuid + date typed accessors round-trip.** `set_uuid`/`get_uuid` and `set_date`/`get_date` implemented on the op-197 pattern; a dict that sets a uuid/date reads the SAME value back via its typed getter (faithful nvlist representation, not a uint/binary coercion unless that IS the faithful path — justify if so). → `OP206_ACCESSORS`

**D3 — build clean + first-hand round-trip proof.** libxpc builds (build_is_implementer); a tiny in-tree round-trip check (set uuid/date/endpoint → get back, assert equal) passes first-hand — NOT just "compiles". Report the commit + the round-trip evidence. Hand the census delta {which symbols now real} for the li-007 ledger. → `OP206_VERDICT` (`fill-green` | `walled`) / `OP206_TERMINAL`

## BOUNDARIES
- Userland libxpc overlay only — NO FB15 build-infra / share/mk / nvlist-source edits beyond what op-197 already established (if a NEW private NV_TYPE is genuinely needed for date, mirror op-197's NV_TYPE_DOUBLE addition in the libxpc-local nv path; if it reaches into base libnv source, that's a FINDING to REPORT, not an edit here — userland_port_no_buildinfra_changes).
- **DO NOT touch the connection-lifecycle stubs** (cancel / error+interruption / finalizer / transaction / xpc_main): they are gated on the libdispatch MACH_RECV servicing sub-fix (li-007 §convergence) and belong to a later sequenced op — filling them here without that sub-fix risks a stub-that-links-but-misbehaves (the dangerous Class-C pattern).
- Build is Implementer; stage in wip-gpt owned dir (agent_host_isolation). Do NOT run a soak (soak_is_gatekeeper) — a round-trip unit check is in-role; the conformance/soak validation is a separate Gatekeeper leg.
- Verify first-hand that the value ROUND-TRIPS (set→get equal), not just that the symbol links (no_conflate_gating_with_readiness; the whole Class-C danger is a symbol that links but no-ops).

## MARKERS
```
OP206_ENDPOINT    # xpc_endpoint_create returns a real _XPC_TYPE_ENDPOINT object (connection's port), no UB no-return
OP206_ACCESSORS   # set/get_uuid + set/get_date round-trip on the op-197 nvlist pattern — set value reads back equal
OP206_VERDICT     # fill-green (endpoint + uuid/date round-trip, build clean, first-hand) | walled (needs base-nvlist source change — REPORT)
OP206_TERMINAL
```

## RELATIONS
- UPSTREAM: op-197 [Done] (accessors-green @ 4983b9137c90 — set/get_data, set/get_double, get_name fix; this op continues the typed-accessor + UB-stub fill on the SAME pattern); li-007 census (Class C stubs + Class B typed accessors).
- DOWNSTREAM: li-007 toward truly-green (object-model floor). The connection-lifecycle fill (cancel/error/finalizer/transaction) is a SEPARATE later op, sequenced AFTER the libdispatch MACH_RECV servicing sub-fix — do not fold it in here.
- feedback: build_is_implementer, soak_is_gatekeeper, userland_port_no_buildinfra_changes (libxpc overlay, not base libnv source), no_conflate_gating_with_readiness (round-trip ≠ links), verify_signature_divergence_claims (create_reply was a stale fill-target — already implemented; verify each symbol's state on build HEAD before touching), agent_host_isolation. project: 10preview_gate (libxpc core service).
```
