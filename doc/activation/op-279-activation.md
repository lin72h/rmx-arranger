# op-279 — Gatekeeper: size op-264 Finding A — runtime-check the `waitpid_loop` cross-thread reaper (idle-boot CPU watch + kill-storm soak on a KeepAlive job) BEFORE any pid-1 patch

op-279 | role: **Gatekeeper** (soak/runtime-evidence owner; no product-write to the fix itself) | EXU: **rmx-gatekeeper** | state: **[Reserved — evidence-first gate for op-264 Finding A. Sizes severity of the `waitpid_loop` hazard with runtime measurement BEFORE op-280 (the pid-1 fix) is allowed to touch code. Coordinator dispatches after op-278 (Finding B) lands so the launchd build under test already carries the trivial cleanup.]** | parent id: id-016 (bootstrap/launchd) | L1i: li-008 (launchd core service) | cost: gatekeeper (soak) | authored 2026-07-07 (Arranger seat, model Opus 4)

## CONTEXT (engineering framing)
Ordinary open-source OS engineering on our own service manager (launchd). rmxOS = Darwin/Mach userland on FreeBSD 15. This is a reliability measurement of our own pid-1 supervision path — no target, no adversary. The point is to gather runtime evidence that sizes a hypothesized hazard before we decide whether/how to patch pid-1 code.

## WHY (one line)
op-264 Finding A is a **hypothesis** (Arranger-verified at source but never measured): the detached `waitpid_loop` reaper may (a) abort launchd, (b) steal a managed job's zombie → spurious crash classification, or (c) busy-spin a core at idle. Editing pid-1 code is high blast radius, so we **measure first** to size which hazard modes are real and how bad.

## THE HYPOTHESIS UNDER TEST (Arranger-verified first-hand in `wip-gpt/wip-rmxos`)
- `runtime.c:646-657` runs a detached free-running `for(;;)` thread (created + detached `runtime.c:260-261`) calling `waitpid(-1, 0, WNOWAIT)` → on any pid, `jobmgr_reap_pid` (`core.c:7230-7238`) walks the job tables via `jobmgr_find_by_pid_deep` (:7233) then `waitpid(pid, 0, 0)` (:7236) — with NO serialization against the main thread's LIST_INSERT/REMOVE/free of job records.
- Three hypothesized hazard modes:
  - **(a)** torn traversal / read-after-free during the deep table walk → launchd(pid-1) abort = system down. Low probability, but the loop fires on EVERY child exit.
  - **(b)** transient lookup-miss consumes a MANAGED job's zombie before the main thread does → main-thread `wait4` returns ECHILD → `job_reap` synthesizes `W_EXITCODE(-1, SIGSEGV)` → spurious "appears to have crashed" classification + garbage `LASTEXITSTATUS`.
  - **(c)** `WNOWAIT` leaves a managed zombie waitable (or no-children ECHILD) → hot loop → ~100% of one core at idle-boot.

## SCOPE (what to measure — read-only observation, no code edit)
On the staging image, launchd built from the op-278 tree (Finding B already guarded out), run two runtime observations and report raw evidence:
1. **Idle-boot CPU watch (hazard c).** Clean boot with the standard KeepAlive:true daemons (notifyd/asld via the op-134 generic boot-load). Measure launchd CPU% at steady idle over a sustained window. A hot/near-100%-of-a-core reading confirms hazard (c) is live; a near-0% reading rules it out. Report the actual numbers + how sampled.
2. **Kill-storm soak (hazards a + b).** A KeepAlive:true job repeatedly killed to force rapid child-exit churn through the reaper. Watch for: launchd abort/restart (hazard a), and log lines "Reap failed" / spurious "appears to have crashed" / wrong `LASTEXITSTATUS` on a job that exited cleanly (hazard b). Report counts + exact log excerpts over the run.

Reminder (li-008 §3 test note): do NOT run the KeepAlive soak under `-u` — the `|| uflag` at `core.c:4058` force-starts every inactive job, making KeepAlive-policy evidence VACUOUS. Confirm the run mode is non-`-u`.

## DELIVERABLE
A staged Gatekeeper soak note (under rmx-gatekeeper/): per hazard mode (a/b/c), a **confirmed / not-observed / inconclusive** verdict backed by raw numbers + log excerpts, plus a one-line severity sizing that op-280 (the fix op) consumes to decide scope. Report for first-hand Arranger read.

## BOUNDARIES
- Runtime observation ONLY — do NOT patch `waitpid_loop`, `jobmgr_reap_pid`, or any supervision code. The fix is op-280, gated on THIS evidence.
- Scope is EXACTLY the three Finding-A hazard modes; do NOT re-open Finding B (op-278), the on-demand plane, or the `xpc_domain` service plane.
- Does not decide milestone placement or release timing — sizes severity so the Coordinator can gate op-280.

## RELATIONS
op-264 (the supervision consult — this sizes its Finding A; Arranger-verified at `runtime.c:646-657` + `core.c:7230-7238`) / op-278 (the sibling Finding-B Implementer fix — lands first so this soak runs on the cleaned tree) / op-280 (RESERVED — the Finding-A fix, gated on this evidence) / op-134 (cold-boot KeepAlive:true — the boot-load under test) / li-008 / id-016. feedback: oss_engineering_framing, code_reasoned_verdict_is_hypothesis, no_conflate_gating_with_readiness, verify_signature_divergence_claims, agent_host_isolation, op_state_dispatch_boundary.
