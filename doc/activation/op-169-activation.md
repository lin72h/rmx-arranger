# op-169 — Explorer: enumerate the baseline-buildworld header-staging walls in `freebsd-src-official-stable-15` UP FRONT (batch-audit for op-149), + pin the right build-base tree

op-169 | role: **Explorer** (FREE) | EXU: **rx-x64z** (rmx-explorer / rx1) | state: **[Ready]** (authored, not dispatched) | parent id: id-026 | L1i: li-1009 | cost: free (source audit, read-only; NO build, NO soak-host) | authored 2026-06-27 (Arranger seat, model Opus 4) | parallel-safe (no contention with op-163 soak)

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
