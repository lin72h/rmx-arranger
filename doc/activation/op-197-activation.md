---
id: op-197
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-197 — Implementer: fill the pure-userland xpc_dictionary completeness gaps (set_data/get_data/set_double/get_double + get_name) → first depth-first fill off the op-194 id-021 ledger

op-197 | role: **Implementer** (cost-30) | EXU: **wip-gpt** | state: **[Done — accessors-green @ 4983b9137c90; Arranger source-verified first-hand]** (2026-06-29). D1: all 4 accessors landed in xpc_dictionary.c (set_data/get_data w/ `size_t *length`, set_double/get_double); DOUBLE serialized via a REAL private `NV_TYPE_DOUBLE` wire type (nv.h/subr_nvlist.c/subr_nvpair.c), NOT crammed into int64; get_double/get_data return the documented sentinel on type-mismatch; round-trips xpc2nv↔nv2xpc both ways. D2 get_name: CORRECTLY subject-verified as `xpc_connection_get_name` (connection name, not dict key-name) — replaced `return("unknown") /* ??? */` with strdup'd service name on creation → real name for named services + NULL for anonymous, macOS-contract-faithful (honors verify_signature_divergence_claims: no wrong-symbol fix). D3: conformance probe (Zig+Elixir+`.d`, rc=0) — the `op197-probe-stubbed.out` artifact is a STANDALONE userland probe, the correct conformance surface for this pure-userland tranche (rides no Mach plane); leg-3 conformance-match, NOT the integration soak (op-185). li-007 ledger: 5 of the op-194 13-item census now filled (4 accessors + get_name); create_reply PARTIAL = separate small follow-on; the 7 launchd-join items REMAIN HELD behind op-195 → libxpc NOT yet full-surface-green. | parent id: id-021 | L1i: li-007 | cost: 30 | authored 2026-06-29 (Arranger seat, model Opus 4)

## WHY (one line)

op-194 censused libxpc full-surface and found the typed-dictionary value accessors set_data/get_data/set_double/get_double genuinely ABSENT from `lib/libxpc` (header-declared, no impl) + get_name a STUB returning "unknown". These are PURE-USERLAND, ride no Mach/launchd plane → the cleanest depth-first fill toward "EVERY NextBSD libxpc feature works." Fill them to truly-green first; the higher-risk launchd-join gaps wait on op-195.

## SCOPE / SUBJECT (EDITABLE — rmxOS overlay)

- `lib/libxpc/xpc_dictionary.c` @ `op-171-x86-64-v3-alpha` (record HEAD). Header truth: `lib/libxpc/xpc/xpc.h` (decls at set_double:2047, set_data:2094, get_double:2275, get_data:2323).
- Existing pattern to MIRROR (already REAL in the file): the int64/uint64/string/bool/uuid/data accessors + `xpc2nv_primitive` serialization switch (xpc_dictionary.c:132-189). Implement the missing accessors the SAME way — `_xpc_prim_create` for the value + `xpc_dictionary_set_value`, and the symmetric getter via the dict lookup → primitive value extraction.
- macOS-27 truth: the `xpc.h` doc contracts for each (return semantics, length out-param for get_data, NULL/0 on type-mismatch).

## DELIVERABLES

**D1 — implement the 4 missing typed accessors** in xpc_dictionary.c: `xpc_dictionary_set_data`, `xpc_dictionary_get_data` (with the `size_t *length` out-param), `xpc_dictionary_set_double`, `xpc_dictionary_get_double` — mirroring the existing int64/data accessor idiom. Each must round-trip through the dict AND serialize correctly: confirm `xpc2nv_primitive` / the nv→xpc inverse already cover `_XPC_TYPE_DATA` (it does, c:167-171) and `_XPC_TYPE_DOUBLE` — **if DOUBLE is missing from the serialization switch, add it** (parity with int64). Type-mismatch returns the documented sentinel (NULL/0). → `OP197_TYPED_ACCESSORS`

**D2 — fix get_name** (op-189 flagged it returns "unknown"): make it return the real name per the macOS contract (read the impl + xpc.h doc to confirm which object's name — dictionary key-name vs connection name — before "fixing"; verify_signature_divergence_claims: don't fix the wrong symbol). If it's genuinely a launchd-join-only feature with no userland meaning, REPORT that and DEFER rather than fabricate a value. → `OP197_GET_NAME`

**D3 — prove truly-green, not just compiled.** Extend/author a Zig+Elixir conformance probe (harness pillar: Elixir orchestration + Zig metal probe + `.d` observation; NO shell harness) that round-trips each filled accessor (set→serialize→deserialize→get, value-identity) and matches the macOS-27 behavior vector. Conformance is leg-3; this op delivers the FILL + the conformance probe (depth_first_conformance). → `OP197_CONFORMANCE`

**VERDICT:** `accessors-green` (4 accessors + get_name filled, round-trip + serialization conformance-matched, builds clean into libxpc) | `walled` (a gap turns out to ride a plane / need launchd-join — report it, don't force). → `OP197_VERDICT` / `OP197_TERMINAL`

## BOUNDARIES
- Pure-userland fill ONLY — these accessors must NOT pull in Mach/launchd servicing. If any does (e.g. get_name needs the connection plane), that item is mis-tranched → REPORT and DEFER to the launchd-join program (op-195-gated), do not force it here.
- Mirror the existing in-file accessor idiom; do NOT re-architect the dict or the nvlist serialization (nvlist is LOCKED). Add the missing DOUBLE serialization case only if absent.
- Conformance probe = Elixir+Zig+`.d` (dtrace_first_debugging); never commit printf/dprintf.
- Edit only `lib/libxpc`; stage in wip-gpt owned dir (agent_host_isolation). Implementer fills + authors the conformance probe; the soak is separate (soak_is_gatekeeper).
- ADJACENT-BUT-OUT-OF-SCOPE (noted, do NOT expand into): `xpc2nv_primitive` has no-op `break;` for DATE/SHMEM/ENDPOINT (c:153-187) — latent serialization gaps NOT on the op-194 ledger; leave them, flag if you touch that switch for DOUBLE.

## MARKERS
```
OP197_TYPED_ACCESSORS   # set_data/get_data/set_double/get_double implemented, mirror int64 idiom, serialization covers DATA+DOUBLE
OP197_GET_NAME          # get_name returns real name per macOS contract (or REPORTED+DEFERRED if launchd-join-only)
OP197_CONFORMANCE       # Zig+Elixir round-trip + macOS-27 behavior-vector match (leg-3), no shell harness
OP197_VERDICT           # accessors-green | walled
OP197_TERMINAL
```

## RELATIONS
- UPSTREAM: op-194 [Retired] (id-021 census; these 5 are the pure-userland tranche of the 13-item ledger; create_reply PARTIAL is a separate small follow-on; the 7 launchd-join items are HELD behind op-195).
- DOWNSTREAM: id-021/li-007 progress toward libxpc full-surface-green; op-185 libxpc soak consumes the green surface. The launchd-join tranche (finalizer/endpoint_create/xpc_main/transaction_begin/end/copy_entitlement/activity_*) is sequenced AFTER op-195 calibration + op-185 soak.
- PEER: op-195 [Retired] (launchd live/dark calibration) — its ledger gates the launchd-join libxpc fills. (op-199 launchctl-unload, the peer "small independent fill" on this same wip-gpt seat, is [Done] — seat now free for op-197.)
- feedback: depth_first_conformance (fill→conformance leg before next subject), workload_class_needs_source_read (mirror the real in-file idiom; read get_name's actual subject before fixing), verify_signature_divergence_claims (don't fix the wrong symbol), dtrace_first_debugging (Elixir+Zig+.d probe), no_conflate_gating_with_readiness (green = conformance-matched round-trip, not just compiles), build_is_implementer, soak_is_gatekeeper, agent_host_isolation.
```
