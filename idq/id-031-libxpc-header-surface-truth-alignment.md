# id-031 — libxpc header-surface truth alignment: drop the 4 declared-but-non-exported symbols (macOS-truth-verified absent)

- id: id-031
- state: **OPEN — VERIFIED (op-167, Arranger-confirmed first-hand 2026-06-27); scope SHRINKS 4→2.** Bucket-2; scope-in Coordinator-owned.

## op-167 VERIFY RESULT (Arranger first-hand, NextBSD-CURRENT libxpc tree — the audited tip)

The census was **2-of-4 stale** — verify-first caught our OWN error (explorer correct, not a false claim):
- **VALID droppable cruft (2):** `xpc_service_main` (`xpc/xpc.h:2441`) + `xpc_debugger_api_misuse_info`
  (`xpc/debug.h:21`) — declared in headers, **zero `.c` def** (grep-confirmed), not exported (op-135 `.tbd`),
  **0 internal callers**. These remain the bucket-2 fix: drop the 2 decls. Near-zero risk, unchanged.
- **CENSUS ERRORS (2) — NOT droppable:** `xpc_object_validate` and `xpc_unreachable` have **no public
  (non-underscore) declaration at all**. Only internal variants exist: `_xpc_object_validate` (inline at
  `xpc/xpc.h:71`, used by the retain/release macros at `:357`/`:382`) and `_xpc_unreachable()` (macro at
  `xpc/base.h:99` = `__builtin_unreachable()`). These are legitimate internal helpers — **leave them alone**.
  The li-007 Class-B census mis-listed them; corrected there too.

→ **Fix scope is now exactly 2 header decls** (`xpc_service_main`, `xpc_debugger_api_misuse_info`).
- raised: 2026-06-27 (Arranger seat, materializing the li-1011 bucket-2 candidate list).
- roadmap parent: **li-1005 / li-007** (libxpc core service); governed by **li-1011**; catalog residue in **li-1008**.
- bucket: **2 — Low-Risk macOS-Fidelity** (header surface = closer to Apple's actual exported contract; near-zero risk).

## The fruit (already macOS-truth-verified)

li-007's macOS-truth join (op-135, Arranger-verified against `libxpc.tbd`'s 802 exported symbols) found that of
the Class-B "declared in headers but zero `.c` impl" set, **4 symbols are NOT in Apple's exported surface at all:**
- `xpc_debugger_api_misuse_info`
- `xpc_object_validate`
- `xpc_service_main`
- `xpc_unreachable`

These are header cruft (likely macros/inlines on macOS, or NextBSD-local) — declaring them in our `xpc/*.h`
without impl is a link-level liability (undefined-at-load if referenced) AND a divergence from Apple's real
surface. Dropping them makes our exported contract **truer to macOS** at near-zero risk.

## Why low-risk / bucket-2

- They have **no `.c` implementation** to remove and (per the .tbd join) **no Apple consumer contract** — so
  removing the decls cannot break a faithful caller. Pure header surface alignment.
- Bounded + reversible (header decl removal); no substrate, no behavior change.

## Verify-FIRST (source moves — li-007 explicitly warns "verify file:line before acting")

1. Re-confirm on the **alpha tip** that the 4 symbols are still header-declared with zero `.c` def (the census
   was 2026-06-24; the tree moves).
2. Re-confirm against the current macOS-truth export list that they remain non-exported (the .tbd is the
   linker-authoritative surface).
3. Confirm **no rmxOS internal caller** references them (grep the tree) — if something does, that caller is the
   real issue to resolve first, not a blind decl drop.

## Fix shape (after verify)

- Remove the 4 decls from the libxpc headers (or gate them behind a clearly-marked NextBSD-internal block if a
  caller genuinely needs one). Note the disposition in li-1008.
- This is a **header-only** change → a small Implementer touch, but the audit/verify is FREE-Explorer work first.

## Relations
- **li-1011** (release-scoping principle) — minted from its bucket-2 candidate list.
- **li-1005 / li-007** (libxpc) — source of the macOS-truth join that proved these 4 non-exported.
- **id-021** (libxpc conformance bring-up) — sibling; this trims the header surface id-021 catalogs.
- **id-032** — the paired bucket-2 libxpc fidelity item (trivial stub: `get_name`).
- feedback: `verify_signature_divergence_claims` (re-confirm on alpha tip before the decl drop).
