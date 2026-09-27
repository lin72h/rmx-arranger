---
id: op-189
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-189 — Explorer: inventory the libxpc Class-C "bucket-3" fill surface (cancel / error-interruption / finalizer / transaction + typed-dict) — scopes the post-op-187 libxpc op

op-189 | role: **Explorer** (free) | EXU: **rmx-explorer** (rx1) | state: **[Done]** — `inventory-complete`, pushed @ `5439bbc`; Arranger-verified first-hand 2026-06-28. Matrix: 9 STUB + 1 PARTIAL + 6 IMPLEMENTED. Load-bearing = cancel + error-delivery; rest catalog. KEY FINDING (verified): cancel is empty `{}` in BOTH canonical AND donor `nx/NextBSD`, error-delivery machinery is ABSENT in both, and no XNU libxpc ref exists on host → the bucket-3 fill is design-from-behavioral-spec, NOT a port (donor-first does not apply to this slice). Couples to op-187's `xc_pending` (cancel must invalidate in-flight reply waiters). Next: capture macOS cancel/error contract (op-190) before the Implementer fill; Coordinator owns whether bucket-3 gates preview. | parent id: id-021 | L1i: li-007 | authored 2026-06-28 (Arranger seat, model Opus 4)

## WHY (one line)

op-187 closed id-029 (reply-correlation green: pong + seqid + full typed echo matrix PASS). The remaining gap to
libxpc truly-green (li-007) is the Class-C "bucket-3" fill — cancel / error-interruption / finalizer / transaction
+ typed-dict completeness. op-187 deliberately excluded these (no-fold); op-122's matrix still reports
`cancel_event_seen: FAIL`. Before the next libxpc Implementer dive, inventory exactly which are stubs, file:line,
what each needs — a readiness matrix that scopes that op once (the way op-186 scoped op-185).

## CONTEXT (take as given)
- READ-ONLY against canonical `wip-gpt/wip-rmxos` @ `op-171-x86-64-v3-alpha` (HEAD now `bc0ac550`, verify first-
  hand — it advances) + donor `nx/NextBSD` (read-only). libxpc at `lib/libxpc/`.
- The concrete failing bar to anchor on: op-187's op-122 run, `op122_plane_cancel_event_seen: FAIL` — the cancel-
  event delivery path. Start there, then sweep the rest of the Class-C set.
- li-005 Class-D / activity / shmem is OUT-of-preview — stays OUT of scope.

## DELIVERABLES — a readiness matrix, one row per Class-C bucket-3 item

For each li-007 Class-C function (cancel handler + cancel-event delivery, error/interruption delivery, finalizer,
transaction handlers, and the typed-dict completeness set): report exactly one state —
**STUB** (returns NULL/no-op — file:line) | **PARTIAL** (some path implemented — name what's missing) |
**IMPLEMENTED** (verify first-hand — symbol-present ≠ implemented) — and cite the donor (`nx/NextBSD`) behavior
per row so the eventual fix is donor-first scoped.

**D-summary — load-bearing vs catalog.** Which rows are load-bearing preview-fill (block libxpc truly-green) vs
catalog-only.

**D-coupling — op-187 overlap.** Flag any item op-187's reply-context plumbing (`_XPC_FROM_WIRE` flag, SEQID copy,
`xc_pending`/`xp_queue` routing in xpc_connection.c) already touches, so the next op doesn't collide or regress it.

**VERDICT:** `inventory-complete` | `blocked` (state what blocked the read).

## BOUNDARIES
- READ-ONLY discovery — no edits, no build, no authoring (Explorer = discovery; the fill is the next op's).
- VERIFY each is really a stub before listing it (verify_signature_divergence_claims — 3 prior false
  divergence/root-cause claims; symbol-present ≠ implemented).
- Do NOT fold reply-correlation (op-187's, now closed) back in.
- Do NOT pull li-005 Class-D / activity / shmem into preview scope.

## MARKERS
```
OP189_CLASSC_MATRIX   # one row per bucket-3 item: STUB|PARTIAL|IMPLEMENTED + file:line + donor ref
OP189_PREVIEW_FILL    # which rows are load-bearing preview-fill vs catalog-only
OP189_OP187_COUPLING  # any item op-187's reply-context plumbing already touches
OP189_VERDICT         # inventory-complete | blocked
OP189_TERMINAL
```

## RELATIONS
- SCOPES the post-op-187 libxpc Class-C fill op (the next libxpc Implementer dive).
- UPSTREAM: op-187 (reply-correlation CLOSED; left cancel_event FAIL as the anchor), op-122 (the full matrix).
- DOWNSTREAM: the bucket-3 fill op; op-185 (li-1007 integration soak) covers libxpc once bucket-3 lands;
  launchd's xpc_domain service plane (li-008) rides solid libxpc.
- feedback: role_costs (free Explorer discovery, off Implementer/Arranger cycles),
  verify_signature_divergence_claims (confirm a stub is real before listing), conformance_match_is_leg3_only
  (Explorer inventories; Gatekeeper validates), depth_first_conformance (drive libxpc to truly-green), no-fold.
```
