---
id: op-245
state: dropped
updated: 2026-09-27T22:54Z
legacy-state: Awaiting
reset: j-20260927-004
---
# op-245 — Oracle: libnotify + asl paired subsystem quality review — 1.0-preview health read of the two notification/logging core services on the shared mach-IPC/libxpc substrate

op-245 | role: **Oracle** (consult; highest-tier, consult-only, no product-write) | EXU: **rmx-oracle-rx-x64z** | state: **[Awaiting]** | parent id: id-000 (1.0-preview core-service quality) | L1i: li-1003 (notify) / li-1007 (notifyd/asld integration) / li-1011 (release-scoping) | cost: oracle-tier (highest) | authored 2026-07-02 (Arranger seat, model Opus 4)

## CONTEXT (read first)
Open-source OS engineering — a code-reasoned 1.0-preview quality review of OUR OWN two notification/logging core services: **libnotify/notifyd** and **asl/asld**. Not security work, no external target. Both are preview core services and both ride the same mach-IPC / libxpc substrate — reviewed together so the Oracle establishes that substrate context once.

## WHY (one line)
libnotify and asl are two of the four 1.0-preview core services; asl is now THE preview system logger (FreeBSD syslogd DROPPED). Before preview, we want an Oracle quality read of both against macOS fidelity + our recent changes — paired, because they share substrate (mach IPC / libxpc) and interact (asl leans on notify for registration in Darwin).

## SCOPE
- **libnotify/notifyd:** API/semantics fidelity vs macOS (registration, coalescing, MACH_RECV-backed delivery), conformance-green integrity (li-1003 legs 1-3), and any preview-quality gaps in the recent state.
- **asl/asld:** its role as THE preview system logger (syslogd dropped) — store/query semantics, asld-live-logger wiring (op-210 lineage), macOS fidelity on load-bearing paths, and preview-quality gaps.
- **The shared seam:** how the two interact over mach IPC / libxpc, and whether any interaction (e.g. asl→notify registration) is a preview risk.
- **Frame findings in the li-1011 release-scoping buckets:** solidify-existing / low-risk-macOS-fidelity / risk-excluded — so each finding lands as preview-actionable or explicitly deferred.

## DELIVERABLE
A paired subsystem-health note (staged under rmx-oracle/): per-service quality findings + the shared-seam read, each bucketed (li-1011) and each a **hypothesis/recommendation** the Arranger routes to Explorer/Gatekeeper verification or an id — NOT a product edit and NOT a gating verdict.

## BOUNDARIES
- **Consult-only, no product-write** (oracle-tier). Stage in the Oracle's own dir (`agent_host_isolation`); propose, do not patch.
- **Code-reasoned = hypothesis** (`code_reasoned_verdict_is_hypothesis`, `verify_signature_divergence_claims`): any claimed macOS-vs-rmxOS divergence or root-cause is verified at source by an Explorer/Gatekeeper before it drives a harness change, product edit, or Coordinator decision.
- **Does NOT decide preview gating** (`no_conflate_gating_with_readiness`) — findings inform the Coordinator, they don't rule.
- **Does NOT touch the IPC-transport internals op-242 is tracing** — libxpc/launchd transport review is deliberately HELD until op-242 settles; this consult stays at the notify/asl service level, not the MACH_RECV transport defect.

## RELATIONS
li-1003 (notify legs) / li-1007 (notifyd+asld integration exposure) / li-1011 (release-scoping buckets) / op-210 (asld-live-logger wiring) / op-243 (in-flight notify soak — this consult is service-level, op-243 is the runtime soak; complementary). Held sibling: libxpc + launchd review (post-op-242-settle). feedback: code_reasoned_verdict_is_hypothesis, verify_signature_divergence_claims, no_conflate_gating_with_readiness, launchd_plist_macos_fidelity, agent_host_isolation, oss_engineering_framing.
