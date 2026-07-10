# id-035 — fd-backed dead-name user-reference correctness: is the archived mach-uref fix a live gap in alpha, or already handled?

- id: id-035
- state: **RETIRED no-op — 2026-07-02. op-237 premise-check returned NEGATIVE (no live gap): the archived commits are divergent from alpha's dead-name accounting, not missing. Arranger-verified at source (`ipc_object.c:177/:216` fresh dead name = `|1` no hold; `ipc_entry.c:668/:671` helper special-cases dead names to raw refs → adding a hold would double-count to 2). No cherry-pick; archive stays as the record.**
- **RE-CONFIRMED 2026-07-03 (Arranger, first-hand):** a background probe re-surfaced the two commits as "not in alpha" (patch-id absent) and this was momentarily mis-read as a possible latent `ipc_right_delta` delta=-1 UAF (translation layer `ipc_entry_mach_urefs` present at ipc_entry.c:662, alloc paths lack `ipc_entry_hold`). FALSE ALARM — re-verified the helper body: ipc_entry.c:667-668 special-cases `MACH_PORT_TYPE_DEAD_NAME` to `return ipc_entry_refs(entry)` (raw f_count), so a fresh `|1` dead name reports uref=1 correctly and afa1588's hold would double-count to 2. **Do NOT re-open on a patch-id-absent signal alone** — the divergence is by design; the decisive evidence is the dead-name special-case in the helper, not the alloc-path hold. Matches op-249's separate lesson: read the helper body before inferring a refcount miscount (`verify_signature_divergence_claims`).
- raised: 2026-07-02 (Arranger seat, model Opus 4).
- roadmap parent: **li-1014** (the salvage instruction) → **li-1001** (mach-ipc substrate invariant; dead-name delivery). Adjacent: id-001 / id-003 (kernel Mach IPC).
- decode: one bounded question → one Validator-gated Implementer op (op-237).

## THE QUESTION

Branch consolidation left a single source-of-truth `alpha` @ `106f9d7fd160`. The audit proved every archived `backup/*` ref is already-in-alpha / superseded / vendor-history **except two fd-backed dead-name user-reference commits** preserved in `backup/opus/mach-uref-fix`:
- `afa158860c29` — ipc: bump f_count for initial dead-name user reference → `sys/compat/mach/ipc/ipc_object.c` (+2)
- `8e2912e6127b` — ipc_entry: Mach-uref translation layer for fd-backed entries → `sys/compat/mach/ipc/ipc_entry.c` (+16), `ipc_right.c`, `sys/sys/mach/ipc/ipc_entry.h` (+3)

alpha's `ipc_entry.c` / `ipc_right.c` / `ipc_object.c` already carry uref/f_count logic (12 / 34 / 2 matches). **Unknown whether these two commits close a live correctness gap or are already-handled / divergent.** Dead-name delivery is a li-1001 evidence gate AND a repeat false-claim area (`verify_signature_divergence_claims`) — so this must be verified at source, not assumed from titles, and cannot be blindly merged.

## DISPOSITION (premise-first)

1. **Premise-check** (op-237, `verify-premise-before-mechanism`): read alpha's fd-backed initial-dead-name uref path; determine if the archived behavior is present, absent, or divergent.
2. **Abandon** if already-handled/divergent → the archive stays as the record; id-035 + li-1014 retire no-op.
3. **Cherry-pick** the two commits onto alpha as a `mach.ko` standalone-module build (NOT a branch merge — the parent branch is 598 behind) ONLY on a proven gap → Validator-gates the kernel semantics (Rule 11; confidence 1–10, Arranger steps in <9), then a Gatekeeper dead-name soak leg (li-1001 invariant).

## BOUNDARIES

- **Not a branch merge** — the two commits only; parent branch drags releng/15.1 + donor import.
- **build_is_implementer** + `mach.ko` standalone-module build; the Implementer does NOT self-adjudicate the semantics (Validator gate) or self-soak (Gatekeeper).
- **op_state_dispatch_boundary** — op-237 authored [Awaiting]; Coordinator dispatches.
- Not a 1.0-preview gate unless the premise-check proves a live dead-name correctness gap.

## RELATIONS

- **li-1014** (source instruction) + **li-1001** (parent invariant). **op-237** (the Implementer op this decodes to).
- **branch-consolidation audit** (2026-07-02, Arranger first-hand) — single-tree `alpha` @ `106f9d7fd160`; the sole not-yet-in-alpha useful content.
- feedback: `verify_signature_divergence_claims`, `verify-premise-before-mechanism`, `build_is_implementer`, `soak_is_gatekeeper`, Rule 11 Validator-gating, `op_state_dispatch_boundary`, `mach_ko standalone module build`.
