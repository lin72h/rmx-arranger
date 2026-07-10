# op-194 — Explorer: libxpc FULL-SURFACE stub census (real vs partial vs stub, beyond the 3 green conformance buckets) → the gap ledger that drives the li-007/id-021 fill program

op-194 | role: **Explorer** (FREE) | EXU: **rx-x64z** (rmx-explorer / rx1) | state: **[Retired — census-complete; 13-item id-021 gap ledger pushed to main 324f832, Arranger-verified first-hand]** (verified: create_reply xpc_dictionary.c:243 genuinely PARTIAL but RECONCILES with op-187 green — conformance round-trip path works, residual is helper-completeness not broken behavior, NOT an op-187 overclaim; typed-dict accessors set_data/get_data/set_double/get_double genuinely ABSENT from lib/libxpc (not macro-generated) = true gaps; op-191 cancel+error fill confirmed REAL @ 501a1ef, op-189 stale STUBs superseded). Decode: op-197 (typed-dict substrate fill, unblocked) authored; 7 launchd-join items HELD behind op-195+op-185. | parent id: id-021 | L1i: li-007 | cost: free | authored 2026-06-29 (Arranger seat, model Opus 4)

## WHY (one line)

The 3 conformance buckets are GREEN (reply op-187, cancel+error op-191), but "EVERY NextBSD libxpc feature works" means the WHOLE public surface must be truly-green — and we don't have a current ground-truth of what's real vs stub beyond those buckets. Census it ONCE so the fill program is scoped from evidence, not from a stale 2026-06-20 stub list.

## SCOPE / SOURCE (canonical, READ-ONLY to this op)

- Subject: `/Users/me/wip-mach/wip-gpt/wip-rmxos/lib/libxpc` @ `op-171-x86-64-v3-alpha` (HEAD advances — record the HEAD you read).
- macOS-27 truth: the `libxpc.tbd` 802-symbol export set (mx-a64z parity host) — for "what should exist + what macOS does."
- Prior partial census to RECONCILE (do not trust blind — may be stale): li-007 Class-A/B/C/D + id-021; the 2026-06-20 connection-lifecycle finding flagged these stubs: `set_finalizer_f`, `xpc_endpoint_create` (empty), `xpc_main` (ignores handler), `transaction_begin/end`, `get_name` ("unknown"). op-187/op-191 may have since filled some — RE-VERIFY current state first-hand.

## DELIVERABLES

**D1 — enumerate the NextBSD libxpc public surface** present in our tree: the 16-type object model (`xpc_type.c`), `xpc_connection_*`, `xpc_endpoint_*`, `xpc_activity_*`, `xpc_dictionary/array_*`, serialization (nvlist), `xpc_main`, transactions, finalizers, target-queue, audit/credential. Name each API + file:line.

**D2 — classify each: REAL / PARTIAL / STUB.** For each, read the impl (not just the symbol) and judge: full working impl / partial (compiles, wired, but incomplete semantics) / stub (empty, no-op, returns "unknown"/NULL, ignores args). Cite file:line evidence per classification (workload_class_needs_source_read: read what it DOES). For STUB/PARTIAL, note what macOS-27 does (the conformance target).

**D3 — emit the gap ledger** under id-021: a table {api → class → file:line → macOS-behavior → est. plane it rides (pure-userland vs MACH_RECV-servicing vs launchd-join)}. This ledger is the work-breakdown the fill ops decode from — order it by (a) preview-load-bearing and (b) whether it rides the un-soaked MACH_RECV plane.

**VERDICT:** `census-complete` (full surface classified + ledger emitted → fill ops scopable) | `walled` (can't read subject/HEAD moved under you — report it).

## BOUNDARIES
- Explorer DISCOVERY — read + classify + ledger ONLY; author NO fix, edit NO product (verify_signature_divergence_claims: classifications drive fill ops, so they must be source-accurate, not guessed).
- Reconcile the stale prior census — don't re-report 2026-06-20 stubs as current without re-reading; op-187/op-191 closures may have changed them.
- Stage strictly in rx-x64z's owned dir (agent_host_isolation).

## MARKERS
```
OP194_SURFACE_ENUM    # full NextBSD libxpc public API surface enumerated (api + file:line), HEAD recorded
OP194_CLASSIFIED      # each api classed REAL/PARTIAL/STUB from impl-read (not symbol presence), macOS behavior noted for gaps
OP194_LEDGER          # id-021 gap ledger emitted, ordered by preview-load-bearing + plane-ridden
OP194_VERDICT         # census-complete | walled
OP194_TERMINAL
```

## RELATIONS
- UPSTREAM: op-187 (reply green), op-191 (cancel/error green) — the buckets already closed; this censuses the REST.
- DOWNSTREAM: the li-007/id-021 fill ops (decode from this ledger); op-185 (libxpc soak) consumes the soak-relevant subset.
- PEER: op-195 (the launchd-side calibration) — same measure-first step for li-008.
- feedback: workload_class_needs_source_read (classify by reading impl, not symbols), verify_signature_divergence_claims (source-accurate classes), depth_first_conformance (one truly-green surface), no_conflate_gating_with_readiness (measure before scoping), role_costs (free Explorer discovery off expensive cycles), agent_host_isolation.
```
