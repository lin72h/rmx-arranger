# id-032 — libxpc trivial stub fidelity: `xpc_connection_get_name` returns the literal `"unknown"` (cheap real-value fix)

- id: id-032
- state: **OPEN — VERIFIED (op-167, Arranger-confirmed first-hand 2026-06-27); fix shape DETERMINED, still bucket-2.** Scope-in Coordinator-owned.

## op-167 VERIFY RESULT (Arranger first-hand, NextBSD-CURRENT libxpc tree)

- Stub confirmed: `xpc_connection_get_name` (`xpc_connection.c:269`) `return ("unknown"); /* ??? */` at `:272`.
- `xc_name` field EXISTS (`xpc_internal.h:108`, `const char *xc_name;`) but is **never referenced in
  xpc_connection.c** — `xpc_connection_create` zero-inits the struct and never assigns it → NOT retained.
- **Fix shape (2 lines, Implementer touch):** assign at create (`conn->xc_name = name;` in the create path) +
  return it (`return (conn->xc_name);`). macOS-faithful per header docs: **named → name; peer/anonymous → NULL.**
  Confirmed still bucket-2 (pure accessor over create-time state; no MACH_RECV dispatch dependency).
- raised: 2026-06-27 (Arranger seat, materializing the li-1011 bucket-2 candidate list).
- roadmap parent: **li-1005 / li-007** (libxpc core service); governed by **li-1011**.
- bucket: **2 — Low-Risk macOS-Fidelity** (one stub → its real value; bounded, no substrate, no dispatch dependency).

## The fruit

li-007's Class-C census found `xpc_connection_get_name` (`xpc_connection.c:269` at census time) is a STUB that
returns the literal string `"unknown"` instead of the connection's actual service name. It is **real
Apple-shipped API** (confirmed in the macOS-truth 802-export join). The connection already knows its name (it
was created via `bootstrap_check_in`/`look_up` on a named Mach service / `xpc_connection_create_mach_service`),
so returning the real value is a small, self-contained fix — no dispatch-servicing dependency.

## Why this one is bucket-2 (and cancel/error delivery is NOT)

Unlike the other Class-C stubs (`xpc_connection_cancel`, error/interruption delivery), `get_name` does **not**
ride the MACH_RECV dispatch-source servicing sub-fix (foundation debt #21, the firehose-adjacent risk that
pushes cancel/error into li-1011 bucket-3). It is a pure accessor over state the connection already holds →
genuinely low-hanging. Keep the scope to JUST the accessor; do NOT let it pull in the cancel/error/finalizer
class (that is bucket-3 for preview).

## Verify-FIRST (source moves)

1. Re-confirm on the **alpha tip** that `xpc_connection_get_name` still returns the literal `"unknown"` (census
   was 2026-06-24, `:269` — the line moves).
2. Confirm the connection object carries the service name at the point `get_name` is called (where the name is
   stored on the `xpc_connection_t` — the create/check-in path). If the name is NOT retained on the object, the
   fix is "retain it at create time + return it" (slightly larger but still bounded); if it IS retained, the fix
   is a one-line accessor.

## Fix shape (after verify)

- Return the connection's stored service name; fall back to a faithful value (NULL or the macOS-observed default)
  only where macOS does — cross-check macOS `xpc_connection_get_name` behavior for unnamed/anonymous connections
  so the fix is faithful, not just non-literal.
- Small Implementer touch; the verify is FREE-Explorer first.

## Relations
- **li-1011** (release-scoping principle) — minted from its bucket-2 candidate list.
- **li-1005 / li-007** (libxpc) — Class-C census source; note the OTHER Class-C stubs stay bucket-3 (dispatch-gated).
- **id-031** — the paired bucket-2 libxpc fidelity item (header-surface drop).
- **id-029** — the libxpc bucket-1 solidify item (request-reply correlation); higher load-bearing than this.
- feedback: `verify_signature_divergence_claims` (re-confirm the stub + name-retention on alpha tip first).
