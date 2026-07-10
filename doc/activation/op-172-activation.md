# op-172 — Explorer: produce the EXACT NextBSD-faithful `include/Makefile` staging reconciliation (port the donor's Darwin/mach staging onto wip-rmxos's FB-15 base) — kills the header-staging wall class at the root

op-172 | role: **Explorer** (FREE) | EXU: **rx-x64z** (rmx-explorer / rx1) | state: **[Retired]** — MOOT, self-retired 2026-06-29 (Arranger; verified-moot discovery doc). The header-staging wall CLASS this op theorized is empirically closed: op-182 certified a clean clobbered world+MACHDEBUGDEBUG kernel from c14e0904, op-149 boots (`707936a6`), op-168 soaked it CLEAN 4h — the clean cert covered the staging class. The actual root cause of the cold-build grind was the `/usr/local` env leak into the elfcopy build (op-176), NOT the `include/Makefile` divergence this op hypothesizes; and it referenced the superseded `op-149-x86-64-v3-alpha` branch (canonical is `op-171-x86-64-v3-alpha`). No reconciliation needed; nothing to dispatch. PRIOR state: [Held] — LIKELY MOOT / pending-retire (2026-06-28). Premise was op-149's cold-obj buildworld header-staging GRIND, but that wall class is empirically closed: op-182 certified a clean clobbered world+MACHDEBUGDEBUG kernel from c14e0904, op-149 boots (707936a6), and the actual root cause was the `/usr/local` env leak into the elfcopy build (op-176 — NOT the `include/Makefile` divergence this op theorizes). Also references the superseded `op-149-x86-64-v3-alpha` branch (canonical is now `op-171-x86-64-v3-alpha`). Do NOT dispatch — confirm the clean cert covered the staging class, then RETIRE. | parent id: id-026 | L1i: li-1009 / li-1012 P0 | cost: free | authored 2026-06-27 (Arranger seat, model Opus 4)

## WHY (one line)

op-149's cold-obj buildworld keeps hitting header-staging walls (attempt-9 lib/libkvm `nlist.h` collision now;
Availability.h CLEARED at attempt-9; sys/mach headers at attempt-7; iconv/thrworkq earlier). Each cleared wall
exposes the NEXT staging collision — the signature of a structurally-wrong include/Makefile, not N independent
bugs. Root cause is NOT missing headers — it is that wip-rmxos's `include/Makefile`
was **rewritten onto the newer FreeBSD-15 base and DIVERGED from NextBSD's Darwin/mach staging machinery**, and
the warm caches hid it. Coordinator directive: **do NOT invent a fix — use NextBSD's solution.** This op
produces the EXACT line-level reconciliation (port the donor's staging sections onto wip-rmxos's FB-15 base) so
the Implementer applies ONE faithful, donor-sourced change that clears the whole staging-wall class — instead of
grinding one header at a time. READ-ONLY: proposes the precise edit, does not build/apply.

## CONTEXT (Arranger-verified first-hand 2026-06-27 — take as given)

- Donor: `nx/NextBSD` @ `236c336`, `include/Makefile` (424 lines). Target: `wip-gpt/wip-rmxos`
  `include/Makefile` (529 lines, branch `op-149-x86-64-v3-alpha`).
- Both trees HAVE the headers as files AND in `INCS` (`include/{Availability,AvailabilityInternal,
  AvailabilityMacros,TargetConditionals}.h` exist; wip-rmxos lists them at `include/Makefile:17-37`). So the wall
  is **staging structure/ordering, NOT absent headers** — do not "re-add" or hand-roll any header.
- Confirmed divergences (NextBSD → wip-rmxos), all in the Darwin/mach staging area:
  - `SUBDIR`: NextBSD `+= apple gen libkern mach **mach_debug** os servers`; wip-rmxos DROPPED `mach_debug`.
  - `sys/mach` staging references: NextBSD **18**, wip-rmxos **2**.
  - `WRONGLY_ADDED_AS_FILES= gen apple/uuid` (a known staging-hazard workaround): present in NextBSD, **gone**
    in wip-rmxos.
  - NextBSD's coherent `# APSL headers` `INCS+=` block was dissolved into wip-rmxos's main `INCS`.
- This single divergence plausibly explains BOTH the Availability.h wall AND the attempt-7 sys/mach header wall
  (same root). wip-rmxos's FB-15 base legitimately differs (newer headers stdbit/stdckdint/exterr, netlink,
  dev/wg…) → this is a **reconciliation (port the donor's staging sections), NOT a wholesale file copy.**

## DELIVERABLES (cite file:line for every claim — verify-first; explorers have made false claims)

**Q1 — pin the LIVE failing consumer + its build PHASE (confirm the fix actually targets it).**
- CURRENT live wall (attempt-9): `lib/libkvm` fails to compile — `struct nlist` lacks `n_other`/`n_desc`,
  `n_name` treated as mutable `char *`. The Implementer's read is "header collision, not v3 codegen" — this is
  a HYPOTHESIS to VERIFY, not assume. From the attempt-9 log + the actual include path, identify **WHICH
  `nlist.h` wins** (FreeBSD `<nlist.h>` vs a Darwin/Mach-O `<mach-o/nlist.h>` vs a hybrid) and **why** (staging
  order, a wrongly-staged apple/mach-o header, or an `-I` ordering hazard). NB: a pure Mach-O nlist.h shadow
  drops `n_other` but KEEPS `n_desc`; libkvm losing BOTH means the winning header is NOT cleanly "the Darwin
  one" — READ it and name it, do not guess. Confirm v3-INDEPENDENCE (a header collision is v3-neutral, but
  verify — same discipline as op-171 Q1; do not assert).
- Also pin **which buildworld phase** libkvm compiles in (`bootstrap-tools` / `build-tools` / `cross-tools` /
  `includes` / `libraries` / …). This decides whether an `include/Makefile` staging-order reconciliation even
  addresses it:
  - consumer in `includes`/`libraries` (after header staging) → staging-structure fix applies (expected).
  - consumer in an EARLY phase (`bootstrap`/`build-tools`, before headers stage) → that's a PHASE INVERSION,
    a different/harder fix → FLAG it; the include/Makefile port alone won't fix it.
- (Historical, for the class picture: the now-CLEARED `<Availability.h>` consumer and the attempt-7 sys/mach
  consumer — note their phases too if cheaply visible, to size Q3 coverage.)

**Q2 (MAIN) — the EXACT NextBSD-faithful reconciliation diff.**
- Produce the precise, line-level edits to wip-rmxos `include/Makefile` that port NextBSD's Darwin/mach staging
  onto the FB-15 base: restore `mach_debug` to `SUBDIR`, restore the `sys/mach` staging blocks (the 18→2 gap),
  restore `WRONGLY_ADDED_AS_FILES` (and any partner target logic it gates), and any APSL-block staging ordering
  NextBSD relies on. For each edit: cite NextBSD `include/Makefile:line` (the donor source) → the corresponding
  wip-rmxos insertion point (`include/Makefile:line`).
- Mark each edit **confirmed** (donor-line-backed, applies cleanly on FB-15 base) vs **needs-care** (FB-15 base
  conflict — name the conflict + the faithful resolution). Do NOT guess; where the FB-15 base differs enough
  that the donor line can't be ported verbatim, say so and propose the minimal faithful adaptation.

**Q3 — confirm class coverage (now load-bearing — the wall list has grown).**
- Enumerate every staging-collision wall seen so far and state, per wall, whether the ONE reconciliation
  covers it: (a) `<Availability.h>` (cleared attempt-9), (b) attempt-7 `sys/mach` headers, (c) **attempt-9
  `lib/libkvm` `nlist.h` collision** (the live one — is the winning-nlist.h fix part of the same donor
  staging port, or a SIBLING staging conflict needing its own donor-faithful edit?), (d) iconv/thrworkq
  siblings (independent or covered). State plainly: does this ONE reconciliation clear the header-staging
  wall CLASS, or are there residual non-include-Makefile walls (e.g. iconv's libc_nonshared include-path,
  already fixed) that remain separate? If libkvm/nlist is a sibling, propose its donor-faithful edit too.

**VERDICT (one of):**
- `reconciliation-ready` → exact diff produced, N edits (M confirmed), covers the class → hand to Implementer.
- `reconciliation-plus-residual` → diff produced BUT named residual walls remain (list them).
- `phase-inversion` (Q1) → the failing consumer precedes header staging → include/Makefile port insufficient →
  escalate with the inverted phase/consumer named.

## BOUNDARIES
- READ-ONLY source/Makefile audit. Do NOT build, edit, apply, or buildworld (builds are Implementer-only).
- Stage strictly inside rx-x64z's own owned dir; no host-global paths.
- **Faithful = donor-sourced.** Every proposed edit must trace to a NextBSD `include/Makefile` line (donor >
  local, least-intrusive). NO hand-rolled headers, NO invented ordering, NO new staging mechanism — this op
  mirrors NextBSD, it does not design (Coordinator directive: no architectural decision now).
- Cite file:line for every claim (verify-first; prior false-divergence record). "Suspected" edits labeled as
  such, not asserted as confirmed.

## MARKERS
```
OP172_FAIL_CONSUMER_PHASE   # live attempt-9 lib/libkvm consumer: which nlist.h wins + why + buildworld phase (log cite); v3-independent y/n
OP172_RECONCILE_DIFF        # exact line-level NextBSD->wip-rmxos include/Makefile staging edits; donor-line cited per edit
OP172_EDIT_CONFIRMED_COUNT  # N edits total, M confirmed (donor-backed, clean on FB-15) vs needs-care
OP172_CLASS_COVERAGE        # does the one reconciliation clear the staging-wall class? residual walls listed
OP172_VERDICT               # reconciliation-ready | reconciliation-plus-residual | phase-inversion
OP172_TERMINAL
```

## RELATIONS
- id-026 / li-1009 / **li-1012 P0** — the clean-baseline this unblocks. op-149 [In-flight] consumes the
  reconciliation; op-171 (toolchain elegance) is the sibling baseline-buildability pass.
- op-149 attempt-7/8 — the sys/mach + Availability.h walls this reconciles at the root.
- DOWNSTREAM (RESERVED, author after this reports): Implementer applies the OP172 reconciliation diff to
  wip-rmxos `include/Makefile` (one faithful commit), reruns cold buildworld → header-staging class cleared.
- feedback: verify_signature_divergence_claims (cite donor file:line per edit; "missing header" framing already
  refuted — headers exist), build_is_implementer (audit proposes, Implementer applies), role_costs (free
  discovery off the cost-30 build cycle), agent_host_isolation, and the parity-explorer least-intrusive
  donor>XNU-ref>local rule (NextBSD IS the donor).
```
