# op-169 — Explorer: enumerate the baseline-buildworld header-staging walls in `freebsd-src-official-stable-15` UP FRONT (batch-audit for op-149), + pin the right build-base tree

op-169 | role: **Explorer** (FREE) | EXU: **rx-x64z** (rmx-explorer / rx1) | state: **[Done] → [Retired]** (reported `5b47fe8`; Arranger-verified first-hand 2026-06-27 — switch-base instinct CONFIRMED, but TARGET corrected NextBSD → wip-rmxos) | parent id: id-026 | L1i: li-1009 | cost: free | authored + resolved 2026-06-27 (Arranger seat, model Opus 4)

> POST-HOC CORRECTION (op-149 attempt-2, Arranger-verified first-hand 2026-06-27): this audit's load-bearing
> claim — that the wip-rmxos alpha base "moots the entire stable-15 wall-grind" — was an OVERCLAIM. The alpha
> base DID clear the mtree + thrworkq walls, but the iconv `__iconv_bool` wall SURVIVED the base switch:
> op-149 attempt-2 fails buildworld at the identical iconv wall on `wip-rmxos` @ `3c2dd7f`. Root cause is a
> `lib/libc` source-level header self-containedness defect (iconv sources identical across both trees), NOT
> the mtree Darwin-dir completeness this audit measured. The dir-count table (11 vs 8) was real but was never
> evidence about iconv. The Arranger confirmation inherited the same proxy error. Net: base switch was
> positive-but-partial, not a moot. See op-149 ATTEMPT-2 block. Lesson logged to verify-first.

---

## ARRANGER-SEAT VERIFY + CORRECTION (2026-06-27, model Opus 4, first-hand)

Report `4c55582..5b47fe8`. The "stop grinding stable-15, switch base" instinct is RIGHT, but the explorer's
counts + chosen target are WRONG — verify-first caught it before it drove a harmful base switch. Counted the
Darwin-compat dirs in each tree's `etc/mtree/BSD.include.dist` first-hand:

| tree | HEAD | Darwin dirs | missing |
|---|---|---|---|
| `freebsd-src-official-stable-15` (op-149 tip) | `4ccd2b8` | **8** | dispatch, private, xpc |
| **`wip-gpt/wip-rmxos` (alpha)** | `3c2dd7f` | **11** | — (most complete) |
| `nx/NextBSD` (donor) | `236c336` | **9** | **pthread, private** |

- Explorer said "NextBSD 8 / wip-rmxos 5 / stable-15 2" → **factually wrong**. Real ordering is
  **wip-rmxos(11) > NextBSD(9) > stable-15(8)** — the explorer inverted the top two.
- **NextBSD is the WRONG switch target:** it is the donor lineage AND is **missing `pthread`** (op-149's
  original includes wall) + `private` → switching there REINTRODUCES walls. Recommendation rejected.
- **Correct base = `wip-gpt/wip-rmxos` @ `3c2dd7f`** — the proven rmxOS ALPHA (carries the op-156 merge, builds
  the alpha image, all 11 Darwin dirs). Building v3 there moots the whole stable-15 wall-grind and isolates the
  v3 variable cleanly (proven tree, only the make.conf changes).

WHAT THE EXPLORER GOT RIGHT (credited): grinding vanilla stable-15 IS the wrong path; the 3 missing dirs
(dispatch/private/xpc) in stable-15 are real (set-diff confirmed); iconv `__iconv_bool` is a staging/ordering
artifact not a source defect (the iconv sources are identical across trees — consistent with the op-149 verify
that the typedef exists in `include/iconv.h` but wasn't staged in time). All of that is moot under the
wip-rmxos base.

RESOLUTION: discovery verified first-hand → **[Done] → [Retired]**. Drives the op-149 base re-point to
`wip-gpt/wip-rmxos` (Coordinator confirms the base switch; see id-026 / op-149).

## WHY

op-149's v3 build keeps stalling wall-by-wall on **pre-existing, v3-INDEPENDENT header-staging /
self-containedness** defects in `freebsd-src-official-stable-15` (mtree → thrworkq.h → now iconv
`__iconv_bool`). Each wall costs a full buildworld + a cost-30 Implementer cycle. This audit enumerates the
REMAINING walls of that class up front so the Implementer can batch-fix them in ONE pass, then run ONE clean
buildworld → then the actual v3 checks. Discovery offloaded to a FREE role (role-cost discipline). Read-only:
this op proposes fixes, it does NOT build or apply them.

## CONTEXT (Arranger-verified first-hand 2026-06-27 — take as given)

- `freebsd-src-official-stable-15` (HEAD `524d71df`) is a **vanilla FreeBSD checkout retrofitted with rmxOS
  header staging** (the restored mtree dirs `apple/mach/os/pthread/servers/uuid/gen/i386/libkern` are
  Darwin-compat, NOT vanilla). The retrofit is INCOMPLETE → the wall stream.
- The op-149 branch `op-149-x86-64-v3-base-tryout` already carries two fixes: mtree restore (`6abbdd6`) +
  `thrworkq.h` self-containedness (`ca9eb67`). Build against THAT branch tip, not bare `524d71df`.
- The current head wall: `lib/libc/iconv/iconv-internal.h:35` uses `__iconv_bool`, undefined at that point →
  `-Werror,-Wimplicit-int`. The typedef EXISTS in `include/iconv.h:43/45/47` (guarded) but isn't visible to
  the iconv consumers. Header-staging class.
- **No `*alpha*` source tree exists.** Candidate rmxOS-lineage trees with native staging: `nx/NextBSD`,
  `nx/NextBSD-NextBSD-CURRENT`. (`build/wip-rmxos-alpha-obj` is an OBJECT prefix, not source.)

## DELIVERABLES (two questions, in order)

### Q1 (GATE — answer FIRST) — what is the right build-base tree?
- Identify the canonical clean-building rmxOS base source among the candidates (`nx/NextBSD`,
  `nx/NextBSD-NextBSD-CURRENT`, or whichever tree actually feeds the alpha obj prefix — find it).
- Spot-check the EXACT wall-class files there: does that tree have correct `etc/mtree/BSD.include.dist`
  (apple/mach/pthread/...), a self-contained `sys/sys/thrworkq.h`, and an iconv staging that compiles
  (`__iconv_bool` visible to `iconv-internal.h` consumers)? Cite file:line.
- **Decide + report:** is the right move to (a) keep grinding `freebsd-src-official-stable-15` into shape via
  a batch-fix (Q2 below), or (b) build the v3 tryout in the NextBSD-lineage tree where staging is already
  complete — potentially mooting the wall-grind? This is the highest-leverage finding; state it plainly with
  evidence, but the final tree-choice is the Coordinator's.

### Q2 (MAIN) — enumerate the remaining header-staging walls (batch-fix list)
Assuming `freebsd-src-official-stable-15` @ the op-149 branch tip stays the base, produce a CONCRETE,
ORDERED batch the Implementer can apply in one pass:
- The **iconv `__iconv_bool` fix** precisely (the missing include or staging — cite the exact edit: which
  header to include in `iconv-internal.h`/its consumers, or which install rule stages `iconv.h`). Derive the
  faithful fix from how the NextBSD-lineage / vanilla-upstream tree resolves it.
- A **targeted scan of the SAME defect class** across the `_startup_libs` set and `lib/libc` (especially
  `*-internal.h` and other headers that reference types/macros without including their defining header) — by
  diffing the staging-relevant files against the clean target tree (Q1), NOT by guessing. List each
  suspected wall: file:line, the missing symbol/typedef, the defining header, the proposed one-line fix.
- Mark each entry **confirmed** (diff-backed against the clean tree) vs **suspected** (pattern-matched) so the
  Implementer knows which are certain.

## BOUNDARIES
- **READ-ONLY source audit. Do NOT build, do NOT apply fixes, do NOT buildworld** — builds are Implementer-only
  (wip-gpt). This op PROPOSES the batch; the Implementer applies + builds it under a follow-on op.
- Stage strictly inside rx-x64z's own owned dir; no host-global paths.
- Cite file:line for every claimed wall + every proposed fix (verify-first; prior false-divergence record).
  A "suspected" wall with no diff backing must be labeled as such, not asserted as confirmed.
- Do NOT touch the v3 make.conf / kernel-AVX questions — those are op-149's, downstream of a clean buildworld.

## DELIVERABLE MARKERS
```
OP169_BUILD_BASE          # the clean rmxOS-base tree identified; wall-class files spot-checked (cited); grind-vs-switch recommendation
OP169_ICONV_FIX           # the precise __iconv_bool fix (file:line + exact edit), diff-derived from the clean tree
OP169_WALL_BATCH          # ordered list of remaining header-staging walls: file:line / missing sym / defining header / fix / confirmed|suspected
OP169_VERDICT             # batch-ready (N walls enumerated, M confirmed) | switch-base-recommended | needs-Coordinator-decision
OP169_TERMINAL
```

## RELATIONS
- id-026 / li-1009 — the v3 baseline this unblocks. op-149 [Held] consumes this audit's batch (or its
  switch-base recommendation) before its next build attempt.
- The op-149 branch `op-149-x86-64-v3-base-tryout` (mtree + thrworkq fixes already applied) = the audit baseline.
- feedback: verify_signature_divergence_claims (cite source per wall), build_is_implementer (audit proposes,
  Implementer builds), role_costs (free discovery offloaded off the cost-30 build cycle).
