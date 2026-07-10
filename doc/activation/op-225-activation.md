# op-225 — Oracle: evidence-regime review — grade what our 1.0-preview foundation greens ACTUALLY prove, and design the acceptance bar (evidence matrix + release-representative soak)

op-225 | role: **Oracle** (consult) | EXU: **rmx-oracle-rx-x64z** | state: **[Done — CONSULT DELIVERED 2026-07-02, Arranger-verified first-hand].** Crux verified at source: (1) preview SHIP kernel = **MACHDEBUGDEBUG** (op-182-activation.md:9-10 "Coordinator chose the DEBUG (MACHDEBUGDEBUG) KERNCONF for 1.0-preview" + :25-26 artifacts = op-149 image source) → asserts armed + twq reachable ON THE SHIP IMAGE, materially de-escalating the caveat; (2) harness/doc default = **MACHDEBUG** (stage-guest.sh:74 `NXPLATFORM_KERNEL_CONF:-MACHDEBUG`; machdebug-scaffold.md:25 `KERNCONF=MACHDEBUG`) → historical un-overridden soaks booted the weaker regime, so the ship conf ≠ the greens' conf; (3) opt-shape (mach.ko -O0, DISPATCH_DEBUG=1) is **Makefile-owned** (Makefile:10/:18), so NO kernconf reaches release shape — the Oracle's correction stands. Consult sound; limits honestly self-labeled (date-branch engine bounds, "undetermined" not inferred, no runs). Extends op-223 E1 into **M1/M2 (musts) + C1-C4 (Coordinator calls)** — surfaced to Coordinator, held. | parent id: id-000 (1.0-preview roadmap consult) | L1i: li-1000 (relates li-1012, li-9003 Item 2) | cost: **oracle-tier (highest; consult-only, no product-write)** | authored 2026-07-02 (Arranger seat, model Opus 4)

## CONTEXT (read first)

This is **open-source operating-system engineering** — an internal, maintainer-style review of OUR OWN in-tree code and test evidence: a NextBSD/Darwin Mach userland (libdispatch, notify, asl, libxpc, launchd) ported onto stock FreeBSD 15/stable to build rmxOS. This op grades the *validity of our own regression/soak evidence* and designs a better evidence bar — the same as any upstream OS project asking "does our CI actually prove what we claim." It is NOT security/vulnerability research, penetration testing, or anything adversarial — no external targets, no exploitation.

## WHY (one line)

op-223 LEG A surfaced three cross-cutting evidence-posture caveats; the Arranger verified first-hand that they **collapse onto a single kernel-config axis** — meaning our foundation "greens" may prove materially less than the record implies, and no current build regime produces a preview-representative green. Grading that, and designing the acceptance bar to fix it, is a roadmap-level Coordinator-decision call → Oracle, not a Ruler.

## VERIFIED FINDING (Arranger first-hand, canonical tree wip-gpt/wip-rmxos @ 32f21706606f)

Three op-223 QUALITY caveats, re-grounded at source, are **coupled**:

- **(1) Assert-dead kernels.** `MACHDEBUG` = `include GENERIC` + `options COMPAT_MACH` only (`sys/amd64/conf/MACHDEBUG`). GENERIC carries no INVARIANTS; `assert(exp)` → `KASSERT(exp,(#exp))` (`sys/sys/mach/std_types.h:119`), compiled out without INVARIANTS. So on MACHDEBUG **every** Mach internal invariant is a no-op (THREAD_NOT_WAITING `ipc_pset.c:650-656`, thread_block MPASS, all ipc asserts). INVARIANTS arrives only via `include "std.debug"` — present in `MACHDEBUGDEBUG` (`sys/amd64/conf/MACHDEBUGDEBUG:1-7`), NOT in MACHDEBUG.
- **(2) Engine selection.** Same axis: `THRWORKQ` is in MACHDEBUGDEBUG only. On MACHDEBUG dispatch silently runs the userland pthread pool, not the three-layer twq engine we intend to ship on (op-223 finding #3; li-9003 Item 2; escalation E1).
- **(3) Debug-shaped bits.** mach.ko builds `-g -O0` (`sys/modules/mach/Makefile:10`); libdispatch builds `-DDISPATCH_DEBUG=1` (`lib/libdispatch/Makefile:18`). Timing-sensitive races (id-025 class) reproduce differently at `-O2`.

**The coupling (the crux):** INVARIANTS-live AND the real twq engine arrive TOGETHER on MACHDEBUGDEBUG — which is exactly the config whose `-O0 -g` / `DISPATCH_DEBUG=1` debug timing masks `-O2` races. The config closer to ship shape (MACHDEBUG) proves NEITHER invariants NOR the real engine. So **no current build regime is preview-representative** (invariants-checked AND real-engine AND `-O2`), and a "9-case dispatch green" (li-1002) means "no hang/crash under one regime," not "invariants hold under the shipped engine + timing." This tightens an over-claim in **li-1012**: op-182's clean-provenance cert used MACHDEBUGDEBUG, so its "provisional-greens caveat lifts" note holds only for invariants+engine, NOT for release timing, and says nothing about the ship kernel if that is MACHDEBUG.

## SCOPE / SUBJECT (design review — READ + REASON, do NOT write product)

- The three caveats above, treated as one evidence-regime problem. Reason about what each build regime does and does not prove.
- Ground every claim in source / build records in the canonical tree; the Arranger's citations above are a starting point, re-verify and extend as needed. If a fact (e.g. which regime hosted an existing green) cannot be established from source or committed record, say so plainly — do not infer.
- IN scope: kernel-config axis (INVARIANTS / THRWORKQ / std.debug), module + libdispatch opt-shape, and the meaning of the li-1001/li-1002/li-1003 greens. OUT: re-reviewing the IPC/dispatch mechanics already covered by op-223 LEG A; the other services (LEG B).

## DELIVERABLES (a review document — proposal, not product edits)

**D1 — evidence-regime map.** Enumerate the build regimes (MACHDEBUG, MACHDEBUGDEBUG, any others found) and, per regime, exactly what is / is not proven: invariants checked?, which concurrency engine?, opt-shape/timing fidelity?. Make the coupling explicit. → `OP225_REGIME_MAP`

**D2 — re-attribution of existing greens.** For the standing foundation greens (li-1001 op-108 soak, li-1002 9-case, li-1003), determine from source/commit/build record WHICH regime hosted each, and label each green's validity accordingly (proven / regime-limited / undetermined). Overclaim-strict; "undetermined" is an allowed and expected answer where the record doesn't say. → `OP225_REATTRIB`

**D3 — release-representative soak design.** Define the target regime that no config produces today — INVARIANTS-checked AND real twq engine AND `-O2` release-shaped — and propose how to reach it: a new kernel conf (std.debug INVARIANTS + THRWORKQ but `-O2` module), OR a staged plan (prove correctness at debug, then a separate `-O2` release soak for timing races). Specify the minimum soak that makes a foundation green preview-representative, and who owns building it (Implementer builds; Gatekeeper soaks — per role split). → `OP225_SOAK_DESIGN`

**D4 — acceptance-bar recommendation.** The bar the 1.0-preview foundation must clear before a Coordinator readiness stamp, separating must-have from nice-to-have, and naming the explicit Coordinator-decision points (does the preview ship MACHDEBUG or MACHDEBUGDEBUG or a new conf?; is the pthread-pool engine acceptable for preview?; how much `-O2` soak is required?). Flag, don't decide. → `OP225_ACCEPTANCE`

**D5 — synthesis + escalations.** One-paragraph verdict on how much the existing foundation record actually proves, plus the Coordinator-decision escalations (this extends E1). → `OP225_SYNTHESIS` / `OP225_TERMINAL`

## BOUNDARIES
- **Consult-only. NO product-write** — output is a review document, not a patch or a new kernel conf. The Oracle proposes; the Implementer is the sole writer.
- **First-hand source/record read** — every claim cites file/line or a committed build record; do not infer a regime from reputation or filename.
- **No milestone/acceptance calls** — the acceptance bar is a recommendation; the decision stays Coordinator-held. Flag, don't decide.
- Stage any scratch in the Oracle's OWN dir (agent_host_isolation).

## MARKERS
```
OP225_REGIME_MAP    # per-regime map of what is / isn't proven (invariants, engine, opt-shape); coupling explicit
OP225_REATTRIB      # existing li-1001/1002/1003 greens re-attributed to a regime + validity-labeled (undetermined allowed)
OP225_SOAK_DESIGN   # release-representative regime + how to reach it + minimum preview-representative soak + role split
OP225_ACCEPTANCE    # acceptance-bar recommendation, must-have vs nice-to-have, Coordinator-decision points flagged
OP225_SYNTHESIS     # verdict on what the record actually proves + escalations (extends E1)
OP225_TERMINAL
```

## RELATIONS
- UPSTREAM: **op-223** (LEG A review — QUALITY caveats 1/2/3 + escalation E1 are the seed); **li-1012** (clean-provenance baseline — the over-claim this review tightens); **li-9003 Item 2** (the engine-selection axis); **id-025** (the `-O2` timing-race class this soak must eventually catch); **li-1001/li-1002/li-1003** (the greens under re-attribution).
- DOWNSTREAM: the acceptance-bar recommendation feeds the Coordinator's 1.0-preview readiness stamp (Coordinator-held); D3 may seed an Implementer op (build the release-representative conf) + a Gatekeeper soak op.
- feedback: verify-premise-before-mechanism, no_conflate_gating_with_readiness (the whole point: greens ≠ readiness), artifact_identity_needs_content_check (a green must name its regime), verdict_labeling_model_honest, build_is_implementer + soak_is_gatekeeper (D3 role split), agent_host_isolation. project: mach_rebase, 10preview_gate, clean_provenance_baseline (li-1012), mach_ko_standalone_module, canonical_source_tree (wip-gpt/wip-rmxos).
