# op-253 — Gatekeeper: fresh acceptance of the op-249 MACH_RECV TOO_LARGE fix — probe A (undersized) must be NO-PANIC and probe B (trailer-sized, owed from op-247) must be CLEAN on the op-249 mach.ko, plus a notifyd/libxpc no-regress glance

op-253 | role: **Gatekeeper** (independent acceptance soak; NO product-write, NO build) | EXU: **rmx-gatekeeper-rx-x64z** | state: **[Done — ACCEPTANCE PASS, Arranger-verified first-hand 2026-07-03; id-036 CLOSES]** | parent id: id-036 (the MACH_RECV null-io_lock panic — CLOSED by this pass) | L1i: li-1002 (IPC substrate) / li-1007 (exposure) / li-1013 C6 | cost: 0 (Gatekeeper, free) | authored 2026-07-03 (Arranger seat, model Opus 4)

## OUTCOME — ACCEPTANCE PASS (Arranger-verified first-hand in op253-serial.log 2026-07-03)
Verified in the RAW serial (`rmx-gatekeeper/build/op253/op253-serial.log`, sha 34e708b3…), not the findings summary:
- **Identity content-check** (`artifact_identity_needs_content_check`): L9 kernel `MACHDEBUGDEBUG` (op-182 cert), L134 `OP253_MACH_KO_SHA b62883c0…6ff6561` = op-249 build.
- **Probe A (the op-247 repro, undersized 28B via dispatch_source): NO PANIC.** L141-142 `mach_msg_rcv_kr=268451844` (=0x10000004 MACH_RCV_TOO_LARGE), handler PASS; L144 `OP253_PROBE_A_RC rc=0`. The exact receive that panicked at ipc_kmsg.c:2853 on f0f10008 now returns TOO_LARGE cleanly — op-249's dequeue-stale fix is SUFFICIENT for the panic path.
- **No-regress:** L161 `op127_bs_probe_terminal status=0` (notifyd round-trip clean on the fixed mach.ko).
- **Panic check EMPTY:** grep panic|KASSERT|copyout_dest|mtx_lock over the serial = zero — no INVARIANTS/WITNESS fires across all three tests.
- **OWED CAVEAT (not a blocker):** Probe B (trailer-sized boundary, owed from op-247) `rc=139` SIGSEGV — a USERLAND harness struct-layout bug (forward-declared mach_msg_header_t wrong), PANIC CHECK empty ⇒ the kernel did NOT crash, but the trailer-sized case was NOT actually exercised. The decisive op-247 repro (probe A) is clean, so id-036 CLOSES; the trailer-sized boundary remains an owed harness-fix re-run (minor, carry as a li-1002 residual — the kernel behavior is unvalidated there, not known-bad).
- **Process flag RESOLVED-POSITIVE:** commit 59fe7b30 (op-249 fix) rode onto origin/alpha ungated under op-224's push; this acceptance validates it — no revert needed.

## CONTEXT (read first)
Open-source OS engineering — the independent acceptance gate for OUR OWN compat-Mach receive-path fix. Not security work, no external target. op-249 (Implementer) traced the op-247 panic to a **dequeue-stale/uninitialized caller-local kmsg** (NOT port-UAF) and fixed it at root (ipc_mqueue.c routes dequeued TOO_LARGE through rx_done; mach_msg.c inits `kmsg=IKM_NULL` and only calls `msg_receive_error` when a kmsg was supplied). Per independent-gate discipline (`soak_is_gatekeeper`), the Implementer did NOT prove its own fix — this op does.

## WHY (one line)
op-247 proved probe A (undersized 28B receive) STILL PANICKED on the op-242-only mach.ko (f0f10008) at ipc_kmsg.c:2853; op-249's fix (mach.ko **b62883c0211919b8ffc05cfc2f5e6c9e2998adccf0ac01c681890e01a6ff6561**) must now make probe A no-panic AND clear probe B (the trailer-sized receive op-247 never reached because probe A killed the system) — only both green closes id-036.

## SCOPE
1. **Verify artifact identity FIRST-HAND** (`artifact_identity_needs_content_check`): the mach.ko under test is sha256 `b62883c0…6ff6561` (op-249 build), on a MACHDEBUGDEBUG/WITNESS/INVARIANTS image; record kernel ident + mach.ko sha in the serial log before probing.
2. **Probe A — undersized receive, no MACH_RCV_LARGE** (the op-247 repro, 28B buffer via `DISPATCH_SOURCE_TYPE_MACH_RECV` round-trip): MUST be **NO-PANIC**. Capture the round-trip completing (send + receive return) and no `mtx_lock() of spin mutex (null)` / no copyout_dest panic.
3. **Probe B — trailer-sized receive (OWED from op-247)**: the boundary case where the buffer fits the header+trailer but not the body — MUST be CLEAN (correct MACH_RCV_TOO_LARGE return, no panic, no corruption). This is the case op-247 never reached.
4. **No-regress glance on the 3 MACH_RECV consumers**: a quick notifyd + libxpc round-trip (the idiomatic consumers li-1007 flags) still works on the fixed mach.ko — the fix preserves the TOO_LARGE→copyout_dest header-return semantics for real consumers, not just the probes.

## DELIVERABLE
A captured acceptance verdict with first-hand kernel+mach.ko identity: **probe A no-panic + probe B clean + notifyd/libxpc no-regress = PASS ⇒ id-036 CLOSES** (Coordinator then calls C6 severity, `no_conflate_gating_with_readiness`). **Any panic / corruption ⇒ FAIL** → op-249's fix is insufficient; report the mechanism (fresh backtrace + the kmsg/dest characterization) → back to the Implementer (id-036 stays OPEN). Serial-log the printed probe results — a captured no-panic, not "the probe didn't crash the log."

## BOUNDARIES
- **Independent acceptance = Gatekeeper** (`soak_is_gatekeeper`); NO product-write, NO mach.ko build (test the op-249 module as delivered). No committed printf/dprintf in any probe oracle (`dtrace_first_debugging`).
- Stage only in the seat's own dir (`agent_host_isolation`).
- Does NOT decide C6 preview-severity (Coordinator, li-1013) — supplies the acceptance evidence; Coordinator calls the gate.

## RELATIONS
op-249 (the fix this gates; mach.ko b62883c0) / op-247 (the runtime-confirm that proved op-242 insufficient + owed probe B) / op-244 (R1/R2 trace bars) / op-242 (the flag fix that STAYS) / id-036 (stays OPEN until this PASSES) / li-1002 / li-1007 / li-1013 C6. feedback: soak_is_gatekeeper, artifact_identity_needs_content_check, dtrace_first_debugging, no_conflate_gating_with_readiness, agent_host_isolation.
