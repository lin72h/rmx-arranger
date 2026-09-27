# id-031 — libxpc header-surface truth alignment: drop 2 declared-but-non-exported symbols

- id: id-031
- state: **RETIRED — op-295 commit `ceb46edc` passes Arranger2's first-hand
  truth/diff/build/consumer gate and is reachable from `origin/alpha` as of 2026-07-11.** Bucket 2,
  non-gating; no further code op is required.

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

## The fruit (macOS-truth-verified and corrected)

li-007's original op-135 join listed four names absent from Apple's 802-symbol export surface.
op-167 then checked the local public headers and corrected the classification: only
`xpc_debugger_api_misuse_info` and `xpc_service_main` are actually public declarations with no
implementation. The non-underscore `xpc_object_validate` and `xpc_unreachable` declarations do not
exist; their underscore-prefixed internal helpers are legitimate and remain untouched.

The two real declaration-only names are link-level liabilities if a consumer trusts the header.
Dropping exactly those two makes the public contract truer to the pinned macOS surface at near-zero
risk.

## Why low-risk / bucket-2

- The two names have **no `.c` implementation** to remove and (per the `.tbd` join) **no Apple
  export contract**; the full rmxOS tree has no caller. Pure header-surface alignment.
- Bounded + reversible (header decl removal); no substrate, no behavior change.

## Verify-FIRST (satisfied for fetch; Implementer rechecks at dispatch)

op-167 completed the free Explorer audit. Arranger2 repeated the current-tip fetch gate on
2026-07-11: `xpc_debugger_api_misuse_info` remains declared only in `xpc/debug.h`;
`xpc_service_main` and its block-local typedef remain only in `xpc/xpc.h`; the full product tree
has no definitions/callers; and the pinned 802-symbol macOS export list still hashes to
`5537e7bd1658a7c094b0515ef95accb9f98ad50cf464d4b8d8b424e057882d99` and contains neither
name. op-295 requires the Implementer to repeat the identity/truth check before editing.

## Fix shape (fetched as op-295)

- Remove exactly the 2 verified declarations and the now-unused block-local service-handler typedef;
  preserve the installed empty `debug.h`, umbrella/include/install shape, `xpc_main`, and internal
  underscore helpers. Note the disposition in li-1008 after validation.
- This is a **header-only** change → a small Implementer touch, but the audit/verify is FREE-Explorer work first.

## Relations
- **li-1011** (release-scoping principle) — minted from its bucket-2 candidate list.
- **li-1005 / li-007** (libxpc) — source of the macOS-truth join and op-167 correction.
- **id-021** (libxpc conformance bring-up) — sibling; this trims the header surface id-021 catalogs.
- **id-032** — the paired bucket-2 libxpc fidelity item (trivial stub: `get_name`).
- feedback: `verify_signature_divergence_claims` (re-confirm on alpha tip before the decl drop).
- fetched op: **op-295** (Implementer, `[Retired]`, commit `ceb46edc`; first-hand origin ancestry
  verified 2026-07-11).
