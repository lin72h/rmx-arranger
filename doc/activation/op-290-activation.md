# op-290 — Implementer: decouple launchd's calendar self-heal from SIGUSR1 and re-arm the global calendar timer

op-290 | role: **Implementer** (sole product writer) | EXU: **wip-gpt / wip-rmxos** | state:
**[Flushed — never dispatched; op-289's old non-PID-1 no-consumer basis must be re-censused under
the new PID-1 preview topology, but this speculative fix ID stays closed. Any warranted fix receives
a new op after op-318 and fresh runtime evidence.]** | parent: **id-016 / op-289** | L1i: **li-008** |
authored: **2026-07-10; ROB status reconciled 2026-07-11 by Arranger2**

## ARRANGER CLOSURE — 2026-07-11

**2026-07-12 follow-up:** Coordinator promoted PID-1 into preview. That changes the topology but
does not authorize this edit or prove a configured calendar consumer. op-318 performs the new
census; op-290 remains flushed.

No product edit was authorized or performed. The source collision remains banked, but op-289's
current-tip census proves it is dormant in the preview's non-PID-1 `-u` run model and has no
packaged interval consumer. op-290 is therefore flushed rather than held indefinitely. If the
post-preview op-202 PID-1 image lands, re-fetch the runtime premise and any resulting fix with new
op IDs and a fresh Coordinator signal-ownership decision.

## CONTEXT (engineering framing)
Ordinary open-source OS engineering on our own service manager. rmxOS = Darwin/Mach userland on FreeBSD 15. A correctness fix to launchd's calendar-schedule self-heal path. No target, no adversary.

## WHY (one line)
op-273 found (Arranger-verified first-hand) that launchd's calendar self-heal `raise(SIGUSR1)` (`core.c:5882`) shares the signal the donor repurposed as init-compat HALT (`runtime.c sighandler_init_compat` → `job_mig_reboot2(root_jobmgr, RB_HALT)`), and the heal is reachable on every MIG completion (`job_mig_destructor:3521`) — so the overdue-calendar recovery can halt the machine. This op decouples the heal from the signal.

## PRECONDITION (why HOLD, not live)
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
op-289 (the Gatekeeper premise-check that GATES this op — sizes the fix + confirms warrant) / op-273 (the Oracle consult, Finding A — the defect this resolves; Arranger-verified first-hand) / op-264 (KeepAlive/restart sibling on the SAME core.c) / op-284→op-285 (the same held-fix-gated-on-evidence pattern) / id-016 (bootstrap/launchd) / li-008 (launchd core service). feedback: oss_engineering_framing, build_is_implementer, code_reasoned_verdict_is_hypothesis, no_conflate_gating_with_readiness, agent_host_isolation, op_state_dispatch_boundary.
