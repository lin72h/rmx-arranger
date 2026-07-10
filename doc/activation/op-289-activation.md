# op-289 — Gatekeeper: runtime premise-check Finding A (launchd calendar self-heal raises SIGUSR1, which the donor repurposed as init-compat HALT) — does an overdue calendar head actually drive the SIGUSR1→RB_HALT path on a live pid-1 guest? (evidence-first, GATES op-290)

op-289 | role: **Gatekeeper** (runtime evidence; no product-write) | EXU: **rmx-gatekeeper** | state: **[Ready / DISPATCH-RECOMMENDED — authored 2026-07-10 (Arranger1 seat) from op-273's first-hand-adjudicated Finding A. Source composition VERIFIED first-hand at wip-gpt/wip-rmxos @ alpha `dd6e7a8` (raise(SIGUSR1)@core.c:5882 in calendarinterval_sanity_check; SIGUSR1→RB_HALT in runtime.c sighandler_init_compat via job_mig_reboot2(root_jobmgr,…); sanity_check called at core.c:3521, last line of job_mig_destructor = every MIG completion; Makefile:37 silences the job_t/jobmgr_t type confusion). This op measures whether the deterministic source path MANIFESTS as an observable halt / dead-calendar-plane on a live pid-1 guest BEFORE the fix (op-290) is warranted. Coordinator dispatches.]** | parent id: id-016 (bootstrap/launchd) | L1i: li-008 (launchd core service) | cost: gatekeeper (small pid-1 boot probe + clock-step drive) | authored 2026-07-10 (Arranger seat, model Opus 4)

## CONTEXT (engineering framing)
Ordinary open-source OS engineering on our own service manager. rmxOS = Darwin/Mach userland on FreeBSD 15. launchd is a 1.0-preview core service (li-008). This measures whether a source-confirmed self-heal/signal collision actually halts a live pid-1 guest, BEFORE we edit the heal path. No target, no adversary.

## WHY (one line)
op-273 (Oracle, Arranger-verified first-hand) found launchd's calendar self-heal `raise(SIGUSR1)` (`core.c:5882`) collides with the donor's init-compat SIGUSR1→RB_HALT handler (`runtime.c sighandler_init_compat` → `job_mig_reboot2(root_jobmgr, RB_HALT)`); the heal is reachable on every MIG completion (`job_mig_destructor:3521`) — a system-DOWN failure mode whose real exposure needs a runtime read before we commit the fix.

## THE CONFIRMED SOURCE COMPOSITION (Arranger-verified 2026-07-10 — so the probe measures a real thing)
- `calendarinterval_sanity_check` (`core.c:5875-5884`): head `when_next < now` → `raise(SIGUSR1)`.
- `sighandler_init_compat` (`runtime.c`): `case SIGUSR1: rflags |= RB_HALT; job_mig_reboot2(root_jobmgr, rflags)` (fallthrough from SIGUSR2 RB_POWEROFF); installed via `launchd_runtime_init2` unconditionally.
- Reachability: `sanity_check()` is the LAST statement of `job_mig_destructor` (`core.c:3521`) → runs on all MIG traffic.
- Type confusion: `job_mig_reboot2(job_t)` passed `jobmgr_t root_jobmgr`; compiles only because `Makefile:37` = `-Wno-error=incompatible-pointer-types`. On the halt path `job_log`/`job_assumes` read jobmgr memory through the job_s layout → garbled log / pid-1 crash. `:8743-8750` walks the stale `ldc->pid` ancestry → outcome is timing-dependent (halt / crash / silent no-op) and creds-dependent (euid==0 common at boot → halt; euid!=0 → BOOTSTRAP_NOT_PRIVILEGED no-op, heal still fires via the kevent).

## WHAT TO MEASURE (premise-check, from the consult's own NEEDS-RUNTIME-CHECK list)
On a pid-1 rmxOS guest, under a crash/serial observer:
1. **The halt funnel.** Boot pid-1 with ONE `StartCalendarInterval` job, force the calendar head overdue (a deliberately wrong RTC + a boot-time clock step, ntpd -g style, OR a >1s main-loop stall past a due time), then drive ONE root MIG request to completion. Observe: does the box HALT (RB_HALT), pid-1 crash, garble-log, or silently no-op? Record the euid on the driving MIG path (root vs non-root) since it gates the outcome.
2. **The dead-calendar plane.** Delete the earliest-due of TWO calendar jobs (remove its job) and confirm the survivor's next fire: expect the global one-shot timer spent with nothing due → calendar plane quiet until a MIG-traffic heal (or halt). Characterize reproduces / does-not / unreachable-in-preview-config.
3. **Control.** Show a known-good baseline: the SAME calendar job with the head NOT overdue completes MIG traffic with no SIGUSR1 raised (observer proves it can distinguish fire from no-fire).

## DELIVERABLE
A short staged evidence note (rmx-gatekeeper dir): per the three items, OBSERVED behavior with the known-good control, characterized **reproduces / does-not-reproduce / unreachable-in-preview-config**. State plainly whether a LIVE preview pid-1 config trips the halt, or whether it is present-but-dormant (e.g. `-u`/non-pid1 gates it). This sizes op-290 and tells the Coordinator whether the fix is warranted at preview scope. Commit the raw serial + harness (not a multi-GB image). Not a product edit, not a release decision.

## BOUNDARIES
- Read/measure + report only; no product edits (the fix is op-290, RESERVED, gated on this).
- Scope is EXACTLY the Finding A halt/dead-calendar premise-check — do NOT expand into the KeepAlive/restart path (op-264), the on-demand/socket plane, or launchctl/MIG interface work.
- Keep the observer alive for the full drive; an observer dying early is a FAIL, not a caveat.
- Under `-u` dev mode every dispatch pass force-starts idle jobs — cadence/heal measurements under `-u` are vacuous; soak on a real pid-1 boot.
- Does not decide milestone placement or release timing.

## RELATIONS
op-273 (the Oracle consult whose Finding A this sizes; Arranger-verified first-hand at `core.c:5882/3521/5875-5884`, `runtime.c init_compat_signals/sighandler_init_compat`, `Makefile:37`) / op-290 (the RESERVED decouple-fix this GATES) / op-264 (KeepAlive/restart sibling on the SAME core.c) / op-284→op-285 (the same evidence-first-then-reserved-fix pattern for high-blast-radius code) / id-016 (bootstrap/launchd) / li-008 (launchd core service). feedback: oss_engineering_framing, code_reasoned_verdict_is_hypothesis, no_conflate_gating_with_readiness, verify_signature_divergence_claims, agent_host_isolation, op_state_dispatch_boundary.
