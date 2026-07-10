# op-280 — Implementer: fix op-264 Finding A — serialize/relocate the `waitpid_loop` cross-thread reaper (RESERVED, gated on op-279 evidence)

op-280 | role: **Implementer** | EXU: **wip-gpt** | state: **[RESERVED — NOT dispatchable until op-279 returns runtime evidence sizing Finding A. This is pid-1 supervision code; the exact fix (and whether it is even warranted at preview) depends on which hazard modes op-279 confirms. Held so the fix intent is banked, not lost, but blocked from edit until evidence lands. Coordinator gates.]** | parent id: id-016 (bootstrap/launchd) | L1i: li-008 (launchd core service) | cost: implementer (small/med — pid-1 code, evidence-first) | authored 2026-07-07 (Arranger seat, model Opus 4)

## CONTEXT (engineering framing)
Ordinary open-source OS engineering on our own service manager (launchd). rmxOS = Darwin/Mach userland on FreeBSD 15. A reliability fix to our own pid-1 reaper path. No target, no adversary.

## WHY (one line)
op-264 Finding A found (Arranger-verified at source) that launchd's detached `waitpid_loop` reaper walks + mutates the job tables with no serialization against the main thread — the one structural hazard on the supervision path the preview daemons (notifyd/asld) actually ride.

## PRECONDITION (why this op is RESERVED, not live)
This edits **pid-1** code where an abort = system down. Per the executing-actions-with-care rule, high-blast-radius changes get evidence first. op-279 (Gatekeeper) sizes which of the three hazard modes (a abort / b stolen-zombie / c busy-spin) are real. This op is held until that evidence lands and the Coordinator confirms the fix is warranted at preview scope — the fix SHAPE is chosen from the evidence, so specifying it now would be premature.

## INTENT (the banked fix direction — to be finalized against op-279 evidence)
Per the op-264 consult PROPOSAL: route unknown-pid reaping through the main runloop — an `EVFILT_SIGNAL` SIGCHLD source on the main kqueue drives a main-thread `WNOHANG` drain that skips pids present in the job hashes (leaving managed-job reaping to the existing main-thread path), so orphan reaping no longer races the main thread's LIST_INSERT/REMOVE/free. Minimal fallback if the runloop route proves too invasive for preview: serialize `jobmgr_reap_pid` against the job-table mutations. Final choice is set from op-279's severity sizing — e.g. if only hazard (c) busy-spin is confirmed, a narrower fix may suffice.

## SCOPE (to be finalized on dispatch)
- The reaper serialization/relocation as chosen above; preserve the legitimate purpose (pid-1 FreeBSD orphan reaping).
- Build launchd; confirm compile/link on the FreeBSD target.
- Runtime re-confirmation that the op-279-confirmed hazard modes are gone is a FOLLOW-ON Gatekeeper pass, not this op.

## BOUNDARIES
- Do NOT dispatch or edit until op-279 evidence + Coordinator gate. This op existing does NOT authorize the edit.
- Scope is EXACTLY the Finding-A reaper hazard; do NOT touch Finding B (op-278), the on-demand plane, or the service plane.
- Does not decide milestone placement or release timing.

## RELATIONS
op-264 (Finding A — the hypothesis this resolves) / op-279 (the Gatekeeper runtime-check that GATES this op — evidence sizes the fix) / op-278 (the sibling Finding-B fix, already actionable) / li-008 / id-016. feedback: oss_engineering_framing, build_is_implementer, code_reasoned_verdict_is_hypothesis, verify_signature_divergence_claims, agent_host_isolation, op_state_dispatch_boundary.
