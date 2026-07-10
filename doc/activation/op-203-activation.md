# op-203 — Gatekeeper: PID-1 launchd robustness soak (orphan reaping + shutdown/reboot + pid1 crash floor) → harden the op-201/op-202 hybrid against the highest bar (pid1 crash == kernel panic)

op-203 | role: **Gatekeeper** (FREE) | EXU: **rmx-gatekeeper-rx-x64z** | state: **[Held — POST-PREVIEW; gated on op-202]** — authored off op-201 D3; do NOT dispatch until (a) the 1.0-preview gate is closed AND (b) op-202 produces the productionized shipped hybrid image. | parent id: id-016 (launchd bootstrap) | L1i: li-008 | cost: free | authored 2026-06-29 (Arranger seat, model Opus 4)

## WHY (one line)

op-201 proved the hybrid boots base services LIVE and bl-016 closes at runtime, but only as a one-shot boot — it did NOT soak the PID-1 init DUTIES that make launchd safe as real init: orphan REAPING (zombies actually collected), SHUTDOWN/REBOOT signaling (SIGTERM→single-user→halt clean), and the crash floor (a PID-1 userspace crash == kernel panic, the highest bar in the system). Prove these hold under sustained load before the hybrid can be a real-boot default.

## SCOPE / SUBJECT
- Consume read-only the productionized shipped hybrid image from op-202 (`shipped-hybrid-live`). Confirm first-hand it boots PID-1 launchd + rc-chainload (artifact_identity_needs_content_check) before soaking. If op-202 is not yet `shipped-hybrid-live`, this op stays HELD — do not soak the throwaway op-201 image as a stand-in.
- Harness = Elixir orchestration + Zig metal probe + DTrace `.d` + serial capture (dtrace_first_debugging); thin rc.local/launchd.d glue only, NO big shell `.rc`/`.sh` harness. A PID-1 userspace-crash bar = `proc:::signal-clear` / sigexit on the launchd PID-1, NOT an `fbt::` userspace bar (fbt_traces_kernel_only).

## THREE SOAK REQUIREMENTS

**R1 — orphan REAPING under load.** Spawn-and-orphan a churn of short-lived processes (double-fork → parent exits → child reparents to PID 1) over a sustained window; assert PID-1 launchd reaps them (no zombie accumulation: `jobmgr_reap_pid` via SIGCHLD fires, zombie count stays bounded). Instrument the zombie/proc count over time — it must not climb. → soak duty, not a one-shot.

**R2 — SHUTDOWN / REBOOT clean.** Drive `shutdown`/`reboot` (and SIGTERM→single-user, launchd's runtime.c:133 path) and assert PID-1 launchd sequences down cleanly: jobs stopped, single-user reached or halt completes, NO panic, NO hang. Capture serial across the transition.

**R3 — pid1 crash FLOOR (highest bar).** Over the whole soak window assert PID-1 launchd never takes a userspace crash (`proc:::signal-clear` / sigexit on PID 1 = a kernel panic, the worst outcome). A clean window = the floor held; ANY pid1 signal-exit is a hard FAIL → escalate to Implementer (this is the one duty where a single failure is release-blocking for the init arc).

## DELIVERABLES

**D1 — reaping proven.** Zombie/proc-count bounded over the orphan-churn window + `jobmgr_reap_pid`/SIGCHLD branch-fired evidence. → `OP203_REAPING`

**D2 — shutdown/reboot clean.** Serial across shutdown + reboot + SIGTERM→single-user: clean down-sequence, no panic/hang. → `OP203_SHUTDOWN`

**D3 — crash floor + disposition.** PID-1 crash-clean over the window (proc signal-clear on PID 1) + a robustness ledger {duty → status → evidence}. Verdict on whether the hybrid is safe as a real-boot default. → `OP203_PID1_FLOOR`

**VERDICT:** `pid1-robust-green` (reaping bounded + shutdown/reboot clean + pid1 crash-clean over the soak → hybrid safe as real init) | `pid1-fragile` (a duty FAILS — reaping leaks zombies / shutdown hangs / pid1 crashes — report which + evidence, escalate to Implementer; a pid1 crash is hard-blocking) | `walled` (image won't boot as the productionized hybrid — REPORT, do not re-stage). → `OP203_VERDICT` / `OP203_TERMINAL`

## BOUNDARIES
- Gatekeeper regression soak, FIXED bar (reaping bounded + clean shutdown + crash-clean) — not discovery (soak_is_gatekeeper). Authoring the orphan-churn driver + shutdown harness + orchestrator is in-role (harness_authoring_is_gatekeeper).
- Consume the op-202 shipped image read-only; stage in the gatekeeper owned dir (agent_host_isolation). Do NOT rebuild the image — if the hybrid config is wrong, REPORT back to op-202, don't re-stage.
- Verify first-hand — a clean `shutdown` exit code or a launchctl-list line is a claim; show zombies actually reaped (count over time) + the serial down-sequence + the proc signal-clear floor (background_exit_code_hygiene; no_conflate_gating_with_readiness).
- POST-PREVIEW fidelity/dogfood arc — must not pre-empt the 1.0-preview gate (4 core services green under `-u` launchd). The pid1-as-init robustness bar is for the dogfood real-boot, not the preview.

## MARKERS
```
OP203_REAPING     # orphan-churn: zombie/proc-count bounded over the window + jobmgr_reap_pid/SIGCHLD branch-fired
OP203_SHUTDOWN    # shutdown/reboot/SIGTERM→single-user: clean down-sequence on serial, no panic/hang
OP203_PID1_FLOOR  # PID-1 crash-clean (proc signal-clear on PID 1) over the soak + robustness ledger; pid1 crash = hard FAIL
OP203_VERDICT     # pid1-robust-green | pid1-fragile | walled
OP203_TERMINAL
```

## RELATIONS
- UPSTREAM: op-202 (productionized shipped hybrid — this soaks it; GATES this op: HELD until op-202 is shipped-hybrid-live); op-201 [Retired — hybrid-live] (one-shot boot proven; this adds the sustained pid1-duty soak); op-200 [Retired] (inherited pid1 spine: reaping runtime.c:653, SIGTERM→single-user runtime.c:133, crash-diagnosis launchd.c:322-489).
- DOWNSTREAM: if `pid1-robust-green` → the hybrid is a candidate real-boot default for the dogfood preview. If `pid1-fragile` → Implementer hardening op (the failing duty), pid1 crash is release-blocking for the init arc.
- feedback: soak_is_gatekeeper, harness_authoring_is_gatekeeper, dtrace_first_debugging, fbt_traces_kernel_only (pid1 crash bar via proc signal-clear, NOT fbt::), background_exit_code_hygiene, no_conflate_gating_with_readiness, artifact_identity_needs_content_check, agent_host_isolation. project: 10preview_gate (POST-preview — must not pre-empt the 4-core gate), mach_rebase.
```
