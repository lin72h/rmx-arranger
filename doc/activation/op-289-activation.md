# op-289 — Gatekeeper: runtime premise-check Finding A (launchd calendar self-heal raises SIGUSR1, which the donor repurposed as init-compat HALT) — does an overdue calendar head actually drive the SIGUSR1→RB_HALT path on a live pid-1 guest? (evidence-first, GATES op-290)

op-289 | role: **Gatekeeper** (runtime evidence; no product write) | EXU:
**rmx-gatekeeper-rx-x64z** | state: **[Flushed — never dispatched; the 2026-07-11 census was valid
for the then-current non-PID-1 image. Coordinator's 2026-07-12 PID-1 preview ruling requires a new
candidate consumer census under op-318, but this ID stays flushed and is never revived.]** | parent: **id-016** | L1i: **li-008** | formerly gated: **op-290** | authored:
**2026-07-10; ROB status reconciled 2026-07-11 by Arranger2**

## ARRANGER BANKED CLOSURE — 2026-07-11

**2026-07-12 follow-up:** PID-1 is now preview scope, so the old topology basis is superseded.
No `StartCalendarInterval` consumer has thereby been proven. op-318 owns the new exact-config
census; any runtime premise receives a new op number.

Arranger2 re-verified the source composition at clean, origin-reachable
`alpha@40c8a93d4b3fec707b2e6ecd7762a1b20948e6e3`:

- `sbin/launchd/core.c` blob `e9ac1dca60aabe416a7bada98320384da622cc80` still has
  `calendarinterval_sanity_check()` calling `raise(SIGUSR1)` for an overdue head;
- `sbin/launchd/runtime.c` blob `d87e749eb96e940cadabea33609c018687f5c2b1` still maps
  `SIGUSR1` to `RB_HALT`; and
- `job_mig_reboot2()` immediately returns `BOOTSTRAP_NOT_PRIVILEGED` when `pid1_magic` is false,
  while `pid1_magic` becomes true only when `getpid() == 1`.

The first-hand preview-consumer census closes the commissioned runtime premise:

- the canonical preview run model is the already-decided non-PID-1 launchd `-u` model under
  id-016; PID-1 productionization/robustness are explicitly post-preview op-202→op-203;
- `-u` force-start behavior makes calendar cadence/heal evidence nonrepresentative; and
- a product-wide `*.plist` census at `40c8a93d` finds zero packaged `StartCalendarInterval` or
  `StartInterval` consumers.

Therefore the source collision is real but cannot produce the commissioned preview system-down
outcome in the shipped run model. **Verdict: BANKED POST-PREVIEW / NO LIVE PREVIEW CONSUMER.** This
is the explicit action-or-closure end of the op-273 consult loop. op-289 is flushed without a cell;
op-290 is also flushed. When op-202 makes PID-1 launchd a live product target, re-fetch new op IDs
with a current image and evidence-first PID-1 runtime gate; do not reuse op-289/op-290.

## PRIOR ROB CLEANUP — 2026-07-11

Do not dispatch this legacy card as-is. First-hand current-tip inspection confirms the load-bearing
composition still exists—`job_mig_destructor` calls `calendarinterval_sanity_check`, the overdue
head raises `SIGUSR1`, and `sighandler_init_compat` maps `SIGUSR1` to `RB_HALT`—but the card remains
pinned to `alpha@dd6e7a8` and lacks the current normal-form execution contract.

After op-306 frees Gatekeeper, normalize/re-pin the then-current Gatekeeper commit, product source
blobs, exact disposable image/BOM/kernel configuration, staging commands, one-cell boundary,
observer, fail-closed validator/controls, raw evidence paths, terminal markers, and classification.
Target this for the first Gatekeeper slot after op-306. Until that normalization is complete it is
`[Draft]`, not `[Ready]` or `[Queued]`.

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
- Read/measure + report only; no product edits (the fix is op-290, `[Hold]`, gated on this).
- Scope is EXACTLY the Finding A halt/dead-calendar premise-check — do NOT expand into the KeepAlive/restart path (op-264), the on-demand/socket plane, or launchctl/MIG interface work.
- Keep the observer alive for the full drive; an observer dying early is a FAIL, not a caveat.
- Under `-u` dev mode every dispatch pass force-starts idle jobs — cadence/heal measurements under `-u` are vacuous; soak on a real pid-1 boot.
- Does not decide milestone placement or release timing.

## RELATIONS
op-273 (the Oracle consult whose Finding A this sizes; Arranger-verified first-hand at `core.c:5882/3521/5875-5884`, `runtime.c init_compat_signals/sighandler_init_compat`, `Makefile:37`) / op-290 (the held decouple-fix this GATES) / op-264 (KeepAlive/restart sibling on the SAME core.c) / op-284→op-285 (the same evidence-first-then-held-fix pattern for high-blast-radius code) / id-016 (bootstrap/launchd) / li-008 (launchd core service). feedback: oss_engineering_framing, code_reasoned_verdict_is_hypothesis, no_conflate_gating_with_readiness, verify_signature_divergence_claims, agent_host_isolation, op_state_dispatch_boundary.
