# op-187 — Implementer: fix libxpc reply-correlation (`xpc_dictionary_create_reply` returns NULL) — the id-029 truly-green blocker for libxpc (li-007)

op-187 | role: **Implementer** (cost-30) | EXU: **wip-gpt** | state: **[Done]** — `reply-fixed`, Arranger-verified first-hand 2026-06-28. Commit `bc0ac550` on canonical `op-171-x86-64-v3-alpha`; source diff + serial (sha `fb127209…`) checked: `_XPC_FROM_WIRE` stamped on receive (xpc_misc.c:466,519), SEQID copied into reply + sync-queue routing (xpc_dictionary.c:257, xpc_connection.c), `OP122_ECHO_REPLY status=0 fallback=0`, full primitive+typed echo matrix PASS, cancel-event FAIL correctly out-of-scope (no-fold held). id-029 CLOSED. Does NOT complete li-007 truly-green — bucket-3 fill (op-189 scopes) + lifecycle/soak legs remain. | parent id: id-029 (roadmap li-007) | authored 2026-06-28 (Arranger seat, model Opus 4)

## SOURCE TREE — FIRST CANONICAL-SOURCE TOUCH, READ BEFORE ANY EDIT (Coordinator directive 2026-06-28)

This is the Implementer's first edit to canonical rmxOS source. There is **ONE and only one** editable tree — to
avoid confusion, use it exclusively and treat the rest as below.

- **CANONICAL (the one and only — edit + build HERE):** `/Users/me/wip-mach/wip-gpt/wip-rmxos`, branch
  **`op-171-x86-64-v3-alpha`**, HEAD **`c14e0904`**. ALL source edits and the rebuild land here. This is the exact
  tree op-149/op-182 certified from — same provenance. libxpc lives at `lib/libxpc/`.
- **READ-ONLY references (KEEP — not deprecated, never edit):**
  - donor: `nx/NextBSD/lib/libxpc` + `nx/NextBSD-NextBSD-CURRENT/lib/libxpc` — the libxpc donor, read for the
    donor-first fix (D2). Port FROM these INTO canonical; do not edit them.
  - stock base: `/Users/me/wip-mach/freebsd-src-official-stable-15` — pristine FB15, the diff baseline. Keep.
- **DEPRECATED — do NOT edit, do NOT mistake for source, slated for removal:** the stale per-op build snapshots
  `build/op156-base-alpha-15a6acc` (@ `15a6acc`) + `build/op156-branch-180d30b` (@ `180d30b`) — frozen id-025-era
  copies, that work is closed/merged; and the pre-libsys obj caches `build/wip-rmxos-alpha-obj` +
  `build/wip-rmxos-userland-integration-obj` (provenance-poisoned per li-1012). If you find yourself in any of
  these, you are in the wrong tree — stop and return to canonical.

## WHY (one line)

`xpc_dictionary_create_reply()` returns NULL at runtime → the responder can't build a *correlated* reply →
`send_message_with_reply_sync` blocks forever → the **core** XPC request-reply pattern doesn't complete on
rmxOS. This is the headline blocker for libxpc truly-green (id-021/li-007). Message DELIVERY already works
(plane is live); only reply-ROUTING is broken.

## CONTEXT (Arranger-verified first-hand — take as given)

- This is NOT a kernel/substrate gap. The MACH_RECV substrate is proven (id-003 filter works/op-098; id-009 UAF
  retired; id-025 deadlock closed/op-156) and the libxpc plane is LIVE bidirectionally (op-122 on op-160's plane).
  The defect is pure userland `lib/libxpc` reply-correlation.
- **rmxOS break (op-122 @ rmx-explorer `a41c8ce`):** byte-identical client `xpc-harness-plane.c` (sha256
  `34a9cac9…`, target `com.rmxos.op122.echo`) vs a launchd-job echo responder. Plane crosses both ways
  (`OP122_ECHO_PEER status=0`), but responder's `xpc_dictionary_create_reply()` returns NULL
  (`OP122_ECHO_REPLY status=1 reason=create_reply_null_fallback`) — symbol EXISTS in `libxpc.so.5` @ `0x12d30`,
  present but returns NULL. Responder fell back to a FRESH dict via `xpc_connection_send_message` → arrived on
  the event-handler path, NOT the reply-correlation path → client `…_with_reply_sync` blocked, torn down at 30s.
- **macOS truth CAPTURED (op-122 mx-a64z `234cd43`, serial `b465c783`):** the SAME client + a contract-path
  responder COMPLETES the round-trip — `reply==pong` + seqid echo + every typed echo PASS. The clean counterpart.
- **Quantified target (from the diff):** the divergence is NOT the send call (`xpc_connection_send_message(peer,
  reply)` is identical both sides) — it is the reply object's **correlation metadata**. Serial points at
  `lib/libxpc` reply-dict creation (`xpc_misc.c:458` unpack region).

## DELIVERABLES

**D1 — locate the NULL.** In `lib/libxpc` reply-construction/correlation path, determine which:
(a) a missing reply-context/connection-association on the INCOMING message object that `create_reply` needs to
copy, or (b) an unimplemented stub that just returns NULL. Report which, with file:line.

**D2 — wire the correlation (macOS-faithful, least-intrusive).** `xpc_dictionary_create_reply(incoming)` must
(a) return non-NULL AND (b) stamp the incoming message's **reply-context** — the originator's
`_with_reply_sync` correlation handle — onto the new dict, so a subsequent `xpc_connection_send_message` of that
dict routes to the originator's **reply-correlation wait**, not the connection event-handler path. Donor-first
(`nx/NextBSD` → XNU-ref → local); behavior round-trip parity, not byte-wire (nvlist locked).

**D3 — prove with op-122's UNMODIFIED client.** Re-run the byte-identical client (`34a9cac9…`, target
`com.rmxos.op122.echo`) against the launchd-job echo responder on the live plane. `…_with_reply_sync` MUST
RETURN: `reply==pong` + seqid echo + typed echoes pass — matching the macOS round-trip (`b465c783`). A correlated
reply, NOT the fresh-dict fallback. (Code-reasoned dive: the macOS target is already captured — no live-repro
wait; run the proof to capture.)

**VERDICT:** `reply-fixed` (round-trip completes on the live plane, matches macOS truth) | `walled` (report the
blocker — do not ship a fresh-dict workaround that masks the correlation gap).

## BOUNDARIES
- Userland `lib/libxpc` ONLY — NOT a kernel/substrate change (substrate is proven; plane is live).
- Do NOT touch the send call — it's identical both sides; the fix is the reply object's correlation metadata.
- Scope to reply-correlation. cancel / error-interruption / finalizer / transaction (Class-C "bucket-3") is a
  SEPARATE op — do NOT fold it in here (no-fold discipline).
- macOS-FAITHFUL: the captured `b465c783` round-trip is the spec — match its behavior; don't invent a divergent
  reply scheme (verify_signature_divergence_claims: target is quantified, conform to it).

## MARKERS
```
OP187_NULL_LOCATED      # create_reply NULL root: (a) missing incoming reply-context | (b) stub — file:line
OP187_REPLY_CORRELATED  # create_reply returns non-NULL AND stamps the originator's reply-context onto the dict
OP187_ROUNDTRIP         # op-122 UNMODIFIED client: _with_reply_sync RETURNS, reply==pong + seqid + typed echoes
OP187_NO_FALLBACK       # responder sends the CORRELATED reply, not the fresh-dict event-path fallback
OP187_VERDICT           # reply-fixed | walled
OP187_TERMINAL
```

## RELATIONS
- CLOSES id-029; UNBLOCKS id-021 / li-007 libxpc truly-green (the "send/**reply** match macOS" criterion).
- UPSTREAM: op-122 (found the break + captured the macOS target), op-160 (proved the live plane).
- DOWNSTREAM: the bucket-3 cancel/error fill (separate op); launchd's xpc_domain service plane (li-008) rides a
  solid libxpc.
- feedback: build_is_implementer (libxpc source fix + build is the Implementer's), implementer code-reasoned
  dive (macOS truth captured → no live-repro wait, run parallel to capture), least-intrusive donor-first,
  no-fold (bucket-3 separate), verify_signature_divergence_claims (match the quantified macOS round-trip),
  no_conflate_gating_with_readiness (Coordinator owns whether id-029 gates preview + the li-1008-split call).
```
