# op-290 — Implementer: decouple launchd's calendar self-heal from SIGUSR1 (kill the halt collision) + re-arm the global calendar timer on head-delete — RESERVED, gated on op-289 evidence

op-290 | role: **Implementer** | EXU: **wip-gpt** | state: **[RESERVED — gated on op-289 runtime evidence + a Coordinator init-compat-signal-ownership decision. This op existing does NOT authorize the edit. Fix shape banked from op-273's first-hand-adjudicated Finding A (system-DOWN failure mode); to be finalized against op-289's observed manifestation.]** | parent id: id-016 (bootstrap/launchd) | L1i: li-008 (launchd core service) | cost: implementer (small — 1-to-3-line class fix in a core service, but HIGH blast radius; evidence-first) | authored 2026-07-10 (Arranger seat, model Opus 4)

## CONTEXT (engineering framing)
Ordinary open-source OS engineering on our own service manager. rmxOS = Darwin/Mach userland on FreeBSD 15. A correctness fix to launchd's calendar-schedule self-heal path. No target, no adversary.

## WHY (one line)
op-273 found (Arranger-verified first-hand) that launchd's calendar self-heal `raise(SIGUSR1)` (`core.c:5882`) shares the signal the donor repurposed as init-compat HALT (`runtime.c sighandler_init_compat` → `job_mig_reboot2(root_jobmgr, RB_HALT)`), and the heal is reachable on every MIG completion (`job_mig_destructor:3521`) — so the overdue-calendar recovery can halt the machine. This op decouples the heal from the signal.

## PRECONDITION (why RESERVED, not live)
This edits the recovery path of a preview-gating core service with a system-down failure mode. Per the executing-actions-with-care rule, high-blast-radius changes get evidence first. op-289 characterizes whether a live pid-1 preview config actually trips the halt / dead-calendar funnel and what the observed failure is. Held until that evidence lands and the Coordinator (a) confirms the fix is warranted at preview scope and (b) rules the init-compat SIGUSR1 signal-ownership question (below), which the fix shape depends on.

## INTENT (banked fix direction — to be finalized against op-289 evidence)
1. **Decouple the heal from the signal (primary).** Replace `raise(SIGUSR1)` at `core.c:5882` with a DIRECT `calendarinterval_callback()` call — same main-thread context, no signal round-trip; the callback is idempotent and re-arms via `setalarm`. This removes the collision at the source regardless of the signal-ownership call.
2. **Re-arm the global calendar timer on head-delete (closes the liveness gap at source).** Have `calendarinterval_delete` (`core.c:5864-5873`) re-arm the global one-shot timer when it unlinks the current head (one `kevent_mod`), so removing the earliest-due entry cannot leave the whole calendar plane quiet (op-273 §3/§4 liveness gap; also masks a backward clock step's dead-plane window).
3. **Init-compat SIGUSR1 ownership (Coordinator decision — fix depends on it).** `kill -USR1 1` currently means BOTH "FreeBSD init halt" (donor intent) and "kick the calendar" (Apple internal); they cannot coexist. If the halt contract is KEPT: additionally fix the `job_mig_reboot2` type confusion (takes `job_t`, passed `jobmgr_t root_jobmgr` — `runtime.c`; silenced by `Makefile:37`) and the stale-`ldc`/creds assumption on the shutdown path (`core.c:8743-8765`). If dropped/moved (or `-u`/non-pid1 only), item 1 alone suffices for the calendar path.
Preserve the verified-SOLID behavior — StartInterval kernel-periodic re-arm, cronemu math, same-second multi-entry pass, teardown memory-safety — no regression.

## SCOPE (to be finalized on dispatch)
- The decouple fix (item 1) + head-delete re-arm (item 2) + the type/creds fix (item 3) IF the Coordinator keeps the init-compat halt contract.
- Build launchd; confirm compile/link on the FreeBSD target (note the fix should let `Makefile:37`'s `-Wno-error=incompatible-pointer-types` be revisited if item 3 removes the type confusion — flag, do not silently drop the flag).
- Runtime re-confirmation (op-289's halt funnel no longer reachable; calendar plane survives a head-delete; a stepped clock degrades to fires-late/fires-early + self-heal, not halt) is a FOLLOW-ON Gatekeeper pass, not this op.

## BOUNDARIES
- Do NOT dispatch or edit until op-289 evidence + the Coordinator gate (warrant + signal-ownership call). This op existing does NOT authorize the edit.
- Scope is EXACTLY the calendar self-heal decouple + head-delete re-arm (+ type/creds fix if halt kept); do NOT fold in the KeepAlive/restart path (op-264), the plist-fidelity items (id-030), or the trivia banked to li-008 (memset(sizeof(0)), plist(5) notes, Makefile comment).
- Does not decide milestone placement or release timing.

## RELATIONS
op-289 (the Gatekeeper premise-check that GATES this op — sizes the fix + confirms warrant) / op-273 (the Oracle consult, Finding A — the defect this resolves; Arranger-verified first-hand) / op-264 (KeepAlive/restart sibling on the SAME core.c) / op-284→op-285 (the same reserved-fix-gated-on-evidence pattern) / id-016 (bootstrap/launchd) / li-008 (launchd core service). feedback: oss_engineering_framing, build_is_implementer, code_reasoned_verdict_is_hypothesis, no_conflate_gating_with_readiness, agent_host_isolation, op_state_dispatch_boundary.
