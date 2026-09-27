# Parity Explorer Strategy (v2 — continuous parity loop)

Status: Arranger redesign (workspace, living). Evolves
`wip-gpt/docs/macos-semantic-validation-strategy.md` (2026-05-12) from a
Phase-0.5 validation lane into a **continuous, parallel, intrusiveness-weighted
parity-polishing loop**, with the current rmxOS state declared **1.0**. Promote
to wip-gpt doctrine on Coordinator acceptance.

Naming: this lane is the **Parity Explorer** — distinct from the Oracle's
*Explorer mode* (host-readiness). The Parity Explorer uses **real macOS as the
behavioral source of truth** to drive rmxOS toward macOS-behavior parity over
the long term.

## Mission

Use real macOS (`mx-a64z`: M4 Mac Mini, macOS 27 beta, arm64, ssh `mm4.local`)
as the behavioral oracle. Continuously generate feature test cases, run the same
case on macOS (reference) and rmxOS (`rx`, system-under-test), produce a
**discrepancy ledger**, and drive **least-intrusive** remediation to converge
rmxOS toward macOS behavior — **without blocking 1.0**.

## Core principles

1. **1.0 = current state (NextBSD revive).** The current rmxOS, discrepancies
   and all, IS the 1.0 baseline. We ship it. Discrepancies are a *prioritized
   backlog*, NOT release blockers. Parity is a polish trajectory, not a gate.
2. **Real macOS is the oracle**, not our self-authored markers — the actual
   observable macOS behavior (versioned facts: exact/equivalent/version-
   sensitive/privilege-sensitive/not-observable/intentional-divergence, per the
   v1 classification).
3. **Continuous + parallel.** Runs alongside the Implementer continuously; it
   does NOT gate foundation work. It produces a steady stream of discrepancies
   that feed the Arranger's remediation backlog. Independent lane.
4. **Differential conformance.** One portable test case → macOS (reference) +
   rmxOS (SUT) → structured behavior capture (JSON) → diff → discrepancy.
5. **Intrusiveness-weighted remediation.** For each discrepancy, score:
   - **Intrusiveness of the fix** (lower = better): config < userland-app <
     userland-lib < kernel-internal < kernel-ABI < cross-cutting-ABI.
   - **Benefit/importance**: does real software depend on it? user-visible?
     foundational vs cosmetic?
   - **Risk**: could the fix destabilize working behavior / accepted evidence?
   - **Version-confidence**: is the macOS behavior stable, or modern-only drift?
   Weight → prioritize **least-intrusive, highest-benefit, low-risk** fixes.
   Defer high-intrusiveness/low-benefit gaps as documented accepted-divergences.
6. **Don't rush mimicry.** Only close gaps worth the intrusiveness. A harmless,
   costly-to-fix discrepancy stays an *accepted/documented divergence*. Avoid
   adding complexity to mimic behavior nothing needs. (Coordinator directive.)
7. **Version-sensitivity is dominant now.** Donor ≈ macOS 10.10–10.11; reference
   = macOS 27 beta — a ~13-year gap. Most discrepancies are version-evolution,
   NOT bugs. Classify version-sensitive FIRST. The source of truth is modern
   macOS *behavior*, but weigh donor-era intent for behaviors that changed
   (ASL→unified-logging, mach_msg→mach_msg2 internals, etc.).

## The pipeline (continuous loop)

1. **Explore** — Parity Explorer generates/expands portable probes for a
   behavior area (one feature = one probe pair).
2. **Capture-reference** — run on `mx-a64z` (macOS 27) → ground-truth vectors
   (JSON, with full env metadata per v1 §Reference Environment Rules).
3. **Capture-SUT** — run the SAME probe on `rx` (rmxOS guest) → our vectors.
4. **Diff** — discrepancy ledger: per-probe macOS-vector vs rx-vector, the
   delta, the v1 classification, and a *first-pass intrusiveness pre-score*.
5. **Triage** (Arranger + intrusiveness model) — score each discrepancy
   (intrusiveness/benefit/risk/version-confidence) → prioritized remediation
   backlog.
6. **Remediate (selective)** — Arranger turns high-benefit/low-intrusiveness
   discrepancies into Implementer Blocks; the rest become documented
   accepted-divergences (with rationale).
7. **Re-verify** — after a fix, re-run the probe on `rx` → confirm the
   discrepancy closed (parity regression guard).
8. **Loop**, continuously, in parallel with foundation work.

## Role-model fit

- **Parity Explorer** = a new lane/agent. Runs on `mx-a64z` (reference capture)
  + `rx` (SUT capture). Produces the discrepancy ledger. An EVIDENCE producer
  whose *reference is real macOS* (vs the Oracle, whose reference is our own
  accepted markers). It does NOT gate the Implementer; it feeds the Arranger.
- **Arranger (me)** — triages the discrepancy ledger via the intrusiveness
  model → prioritized remediation Blocks + accepted-divergence records. The
  parity backlog is a NEW input to Block-generation, alongside the foundation
  roadmap.
- **Implementer** — closes selected discrepancies (least-intrusive-first) as
  normal Blocks on `wip-rmxos/alpha`.
- **Oracle** — unchanged; still disposes rmxOS-internal evidence. The Parity
  Explorer's macOS vectors are a *separate* reference class (not Oracle markers).
- **Validators** — review high-stakes remediation (esp. anything touching
  accepted evidence or kernel ABI) and intrusiveness/version classifications.

## Coverage (expand beyond v1 M1–M8)

v1 covered M1–M8 Mach IPC + phase matrices. The continuous loop expands to ALL
built features, each getting a probe pair (macOS + rx):
- Mach IPC (M1–M8: fork/spawn inheritance, COPY/MOVE_SEND accounting, send-once,
  port sets, MIG, bootstrap) — partially built (m1/m2 done).
- **dead-name / no-senders** (our N2/N2C-2b work: dead-name notification
  delivery, uref accounting, cross-process client-death) — high-value, directly
  matches recent foundation work.
- libdispatch MACH_RECV (source create/cancel/event).
- launchd / bootstrap check-in (the Phase 0.8/0.85 handoff facts).
- ASL (version-sensitive — modern macOS = unified logging; classify carefully).
- libxpc / XPC (later, once built — the capstone parity target).

## Repo / deployment

- **Promote `macos-validation` to a standalone Parity Explorer repo** (currently
  a `wip-gpt-oracle` subdir) so it is cleanly cloneable to `mm4` and runnable
  independently on both macOS and rmxOS. Keep the existing probes/harness/
  results/findings/manifests layout + the host-namespaced results (`mx-a64z`,
  `mx-x64z`, `rx`, `nx`).
- **Runs on both**: macOS (`clang -o probe probe.c; codesign -s - probe;
  ./probe` per v1 §Artifact Model) capturing `mx-a64z` results; rmxOS guest
  capturing `rx` results. Probes portable (C; Zig only when a probe must be
  shared mechanically with the guest).
- **Deploy to `mx-a64z`**: clone the standalone repo to `mm4.local`, run the
  capture, sync results back. (Confirm `mx-a64z` ⇔ `mm4.local` host identity.)

## Open decisions for the Coordinator

1. **Name**: "Parity Explorer" (disambiguates from Oracle Explorer mode) — ok?
2. **Standalone repo**: promote `macos-validation` out of `wip-gpt-oracle` into
   its own repo (recommended for clean clone/deploy), or run in place?
3. **Host**: confirm `mx-a64z` = `mm4.local` (the M4 Mac Mini).
4. **macOS 27 beta**: a beta as the reference oracle — record beta build + treat
   beta-specific behavior as low version-confidence until a stable 27 confirms.
5. **Intrusiveness scoring rubric**: accept the 6-level intrusiveness scale +
   the benefit/risk/version-confidence axes above, or adjust the weights?
