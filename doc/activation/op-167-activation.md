# op-167 — libxpc bucket-2 verify-FIRST sweep (id-031 header-surface + id-032 get_name stub) on the alpha tip

- op: op-167
- state: **[Done] → [Retired]** (reported `4c55582`; Arranger-verified first-hand 2026-06-27)
- role: **Explorer** (FREE) · EXU: **rx-x64z** (rmx-explorer / rx1)
- drives: **id-031** (header-surface truth) + **id-032** (`xpc_connection_get_name` stub) under **li-1011 bucket-2 / li-1005·li-007**
- cost: free (source-read only; NO product edit, NO build, NO soak-host)
- raised: 2026-06-27 (Arranger seat) — parallel to op-163 soak; non-blocking

## WHY (one line)

Two libxpc bucket-2 fidelity items need an alpha-tip re-confirm before they can be scoped-in;
the census they rest on is 2026-06-24 and the tree moves. This sweep produces the classification
that feeds the Coordinator's scope-in — it does NOT change product.

## SCOPE — read-only audit, libxpc tree at current alpha tip. Two parts, one sweep.

### Part A (id-031) — header-surface truth, the 4 non-exported symbols

A1. Re-confirm each of the 4 is STILL header-declared with ZERO `.c` definition on the alpha tip:
    `xpc_debugger_api_misuse_info`, `xpc_object_validate`, `xpc_service_main`, `xpc_unreachable`.
    Report file:line of each decl; confirm no `.c` def (grep the whole libxpc tree).
A2. Re-confirm each remains NON-exported against the macOS-truth surface (`libxpc.tbd`, the 802-export
    join from op-135 — linker-authoritative). Flag any that NOW appears exported (would flip the verdict).
A3. Grep the ENTIRE rmxOS tree for any internal caller of the 4. If a caller exists, that caller is the
    real issue — name it; do NOT recommend a blind decl drop over a live caller.

### Part B (id-032) — `xpc_connection_get_name` stub

B1. Re-confirm `xpc_connection_get_name` STILL returns the literal `"unknown"` at its current line
    (census was `xpc_connection.c:269`, 2026-06-24 — the line moves). Report file:line + the literal.
B2. Determine whether the connection's real service name is ALREADY retained on the `xpc_connection_t`
    at the point `get_name` is called — trace the create/check-in path
    (`bootstrap_check_in`/`look_up`/`xpc_connection_create_mach_service`). Report WHERE the name is stored
    (struct field) if retained; report "NOT retained" if it is dropped at create.
    → This decides fix shape: retained = one-line accessor; not-retained = retain-at-create + return.
B3. Cross-check macOS `xpc_connection_get_name` behavior for unnamed/anonymous connections (what does
    Apple return — NULL? a default?) so the eventual fix is faithful, not merely non-literal.

## DELIVERABLE (report markers)

- `OP167_ID031_DECLS` — 4 symbols, file:line of each decl, `.c`-def absence confirmed (or the exception)
- `OP167_ID031_EXPORT` — each still non-exported vs `.tbd` (or flipped)
- `OP167_ID031_CALLERS` — internal callers found (names) or NONE
- `OP167_ID032_STUB` — current file:line + the literal return value confirmed (or changed)
- `OP167_ID032_RETENTION` — name retained-on-object (struct field) | NOT-retained → fix-shape call
- `OP167_ID032_MACOS` — macOS get_name behavior for unnamed/anon connections
- `OP167_VERDICT` — per-id: still-valid-bucket-2 / changed / needs-Coordinator-flag
- `OP167_TERMINAL`

## BOUNDARIES

- READ-ONLY. No edits, no build, no header drop, no accessor change — this op only audits + classifies.
- Do NOT pull in the OTHER Class-C stubs (`xpc_connection_cancel`, error/interruption delivery) — those
  ride the MACH_RECV dispatch sub-fix (bucket-3); they are explicitly OUT of this op.
- Stage strictly inside rx-x64z's own owned dir; no host-global paths.
- Verify-first feedback applies: cite header/source file:line for every claim — prior explorers reported
  false divergences (asl_close/asl_next/op-138). Source is the authority, not the census.

## RELATIONS

- li-1011 (bucket-2 driver list) · li-1005/li-007 (libxpc census + op-135 macOS-truth join)
- id-031, id-032 (the two ids this sweep verifies) · id-029 (libxpc bucket-1, NOT in scope here)
- feedback: verify_signature_divergence_claims, agent_host_isolation

---

## ARRANGER-SEAT VERIFY + TERMINAL RESOLUTION (2026-06-27, model Opus 4, first-hand on NextBSD-CURRENT libxpc tree)

Report `9061288..4c55582` (SHA `4c55582`) verified at source, NOT relayed. The report CORRECTS the prior
li-007 census; per verify-first discipline (explorers have claimed false divergences 3×) a census-correction
is exactly the kind of claim that must be source-confirmed before it rewrites scope. It checks out — the
explorer was RIGHT (this is a caught census error, not a false claim):

- **OP167_ID031_DECLS — CONFIRMED 2-valid / 2-stale.** Public decls present: `xpc_service_main` (`xpc/xpc.h:2441`),
  `xpc_debugger_api_misuse_info` (`xpc/debug.h:21`). NO public decl for `xpc_object_validate` / `xpc_unreachable`
  — only `_xpc_object_validate` (inline `xpc/xpc.h:71`) + `_xpc_unreachable` (macro `xpc/base.h:99`). Census error
  confirmed.
- **OP167_ID031_EXPORT — non-exported** rests on op-135 `.tbd` join (prior Arranger-verified); re-affirmed.
- **OP167_ID031_CALLERS — 0** `.c` def or caller of the 2 valid symbols (Grep, whole libxpc tree, empty).
- **OP167_ID032_STUB — CONFIRMED** `xpc_connection.c:269` → `return ("unknown"); /* ??? */` at `:272`.
- **OP167_ID032_RETENTION — CONFIRMED NOT retained:** `xc_name` field at `xpc_internal.h:108`, but the string
  `xc_name` never appears in `xpc_connection.c` → never assigned at create, never read by get_name.

OUTCOME (both feed Coordinator scope-in with concrete, verified fix shapes):
- **id-031** scope SHRINKS 4→2: drop 2 header decls (`xpc_service_main`, `xpc_debugger_api_misuse_info`).
  near-zero risk, still bucket-2. The 2 census-error symbols are left alone (internal helpers).
- **id-032** still bucket-2, fix shape DETERMINED: 2-line retain-at-create + accessor; named→name, anon→NULL.
- li-007 Class-B census corrected in place (2 droppable, not 4).

RESOLUTION: op-167 was a verify-first FREE-Explorer audit; results Arranger-confirmed first-hand → **[Done] →
[Retired]** (Arranger self-retires verified discovery/docs). No product changed by this op (read-only by design).
