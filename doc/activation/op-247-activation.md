---
id: op-247
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-247 — Gatekeeper: acceptance rerun of the op-242 MACH_RECV fix on the fixed mach.ko — A/B the original undersized probe vs a trailer-sized-buffer variant to a no-panic verdict, and settle fix-sufficiency (op-244 R1)

op-247 | role: **Gatekeeper** (acceptance boot + reproducer rerun; NO product-write, NO fix) | EXU: **rmx-gatekeeper-rx-x64z** | state: **[Done — VERDICT: op-242 fix NECESSARY-BUT-NOT-SUFFICIENT. Probe A (undersized, 28B) STILL PANICS on fixed mach.ko f0f10008 at ipc_kmsg.c:2853 via mach_msg_overwrite_trap→syscall (NOT filt_machport) — op-244 R1 CONFIRMED at runtime, trigger is filter-independent. id-036 does NOT close → error-path-hardening Implementer op-249 authored (premise-gated). Commit 117e718, 2026-07-03]** | parent: op-242 (fix under test) / op-246 (semantics spine PASSED 9/10, released this) / id-036 (defect) | L1i: li-1002 (IPC substrate) / li-1007 (exposure) / li-1013 C6 (preview-severity) | cost: 0 (Gatekeeper, free) | authored 2026-07-02 (Arranger seat, model Opus 4)

## OUTCOME (Arranger adjudication, 2026-07-03, defect site re-verified first-hand)

**Verdict ACCEPTED: op-242's fix is necessary-but-not-sufficient. op-244's R1 is CONFIRMED at runtime.** Probe A (undersized, 28B header-only, dispatch_source) still panics on the fixed mach.ko f0f10008 — `panic: mtx_lock() of spin mutex (null) @ ipc_kmsg.c:2853`, backtrace `ipc_kmsg_copyout_dest → mach_msg_overwrite_trap → syscall 632`. The **syscall** error path, NOT `filt_machport` — exactly the filter-independent trigger op-244 R1 predicted and I source-verified. The runtime panic now matches the source reasoning end-to-end. id-036 **cannot close** on this gate.

**Two adjudication notes:**
1. **Fix DIRECTION correction (re-verified ipc_kmsg.c:2846-2853 first-hand).** The Gatekeeper's suggested "NULL-check before mtx_lock" is INSUFFICIENT: `dest = kmsg->ikm_header->msgh_remote_port` is **non-null** at panic (per op-244 R2 the "(null)" is the lock NAME; class decodes SPIN ⇒ non-null garbage ⇒ `dest` points at freed/recycled memory). A NULL-check passes the garbage straight through. `copyout_dest` is *supposed* to run on TOO_LARGE (mach_msg.c header: changed to work like `MACH_RCV_HEADER_ERROR`). So the real defect is a UAF/staleness — WHY is `dest`/the kmsg stale on this path — not a missing guard. → op-249 is **premise-gated (trace before edit, op-240 discipline)** on op-244 R2/R3 bars.
2. **Probe B is OWED (not a blocker).** B (trailer-sized, 36B) "not reached" — A panicked the whole system first. B needs a fresh boot. Expected clean (trailer-sized buffer never hits TOO_LARGE → never enters the error path), which would confirm the defect is confined to undersized receives — folded into op-249's acceptance gate, low-risk but not yet proven.

**ROUTING:** op-249 (Implementer, premise-gated error-path hardening) authored + released [Awaiting]. Per boundary the Gatekeeper reported the named site; Arranger files the op (no diagnose-and-self-fix). id-036 stays OPEN until op-249's fix passes a fresh Gatekeeper acceptance (probe A clean + B clean).

## CONTEXT (read first)
Open-source OS engineering — a boot-and-reproduce acceptance gate on OUR OWN fixed compat-Mach receive path. Not security work, no external target. op-242 delivered the flag-collision fix (mach.ko **f0f10008**, commit **d70062591073**); op-246 confirmed the fix is regression-safe + semantically correct (source-level) but flagged sufficiency UNPROVEN. This op is the runtime proof — the last gate before id-036 can close.

## WHY (one line)
The fix is regression-safe (op-246 Q2, first-hand) but its SUFFICIENCY is open: op-244's R1 (Arranger-verified) shows the copyout panic is reachable **filter-independently** by any undersized userland receive (`MACH_RCV_MSG`, no `MACH_RCV_LARGE` → `TOO_LARGE` → dequeue-anyway → error path). op-242's fix touches the FILTER; R1's trigger is in the SYSCALL error path. So booting the fixed mach.ko and rerunning ONLY the original probe is not enough — we need the A/B that isolates whether the filter fix alone stops the panic, or whether an error-path-hardening op is still required.

## SCOPE — boot fixed mach.ko, run the A/B (falsify: assume it still panics until proven clean)
1. **Boot the fixed image.** mach.ko **f0f10008** / commit d70062591073 on the op-182 MACHDEBUGDEBUG cert image (WITNESS/INVARIANTS armed — the ship kernel per op-182). Verify kernel + mach.ko identity FIRST-HAND (uname + module sha), don't trust the filename (`artifact_identity_needs_content_check`).
2. **A/B the reproducer** (`rmx-explorer findings/nx-r64z/dtrace/mach-recv-premise/mach_recv_probe.c`):
   - **A = original undersized probe** (bare `mach_msg_header_t`, `MACH_RCV_MSG`, NO `MACH_RCV_LARGE`, size=sizeof(header) — probe.c:74-83, unchanged).
   - **B = trailer-sized-buffer variant** (same round-trip, receive buffer sized for header + minimum trailer, OR add `MACH_RCV_LARGE`). Author B by editing only the probe's receive buffer/option; keep the dispatch-source arm identical so the ONLY delta is the userland receive sizing.
3. **Read the discriminator:**
   - **A no longer panics** ⇒ op-242's filter fix removed the corrupting receive → fix is SUFFICIENT → id-036 closes on this gate. Keep B as the confirmation (must also pass).
   - **A STILL panics (B clean)** ⇒ the R1 error-path trigger is filter-independent and LIVE → op-242's fix is necessary-but-not-sufficient → a SEPARATE gated Implementer op (harden `msg_receive_error`/`copyout_dest` to not `io_lock` a stale/invalid `dest` on `TOO_LARGE`) is the real fix. Do NOT self-author it — report the named site; Arranger files the id + releases the op.
   - **Both panic** ⇒ fix ineffective at runtime, escalate (contradicts op-242 + op-246 — re-examine identity per step 1).

## DELIVERABLE
A 2x2 boot verdict table (probe A/B × panic/clean) with first-hand kernel+mach.ko identity, the exact panic backtrace if any, and a one-line verdict: **fix SUFFICIENT (id-036 closes)** / **fix necessary-but-not-sufficient → error-path-hardening op needed (named site)**. Feeds li-1013 C6 (does the residual, if any, stay a preview blocker) and li-1007 (consumer exposure).

## BOUNDARIES
- **Acceptance boot + rerun ONLY — NO product-write, NO mach.ko/build, NO fix** (`soak_is_gatekeeper` / independent-gate: never the seat that authored the fix proves it). A named residual defect → separate gated Implementer op, Arranger releases it (never diagnose-and-self-fix).
- **Do NOT re-derive op-246's semantics spine** — it PASSED 9/10; this is the runtime layer, not a source re-review.
- One kernel image (op-182 cert + fixed mach.ko); stage only in the seat's own dir (`agent_host_isolation`).
- **Does NOT decide C6 preview-severity** (Coordinator, li-1013) — supplies the runtime evidence, Coordinator calls the gate (`no_conflate_gating_with_readiness`).

## RELATIONS
op-242 (fix under test) / op-246 (semantics PASS, released this) / op-244 (R1 — the A/B rationale; error-path-hardening candidate) / op-241 (panic premise + the reproducer) / op-098 (filt_machport success path) / li-1002 / li-1007 / li-1013 C6. Escalation twin: a gated error-path-hardening Implementer op IF probe A still panics. feedback: soak_is_gatekeeper, artifact_identity_needs_content_check, code_reasoned_verdict_is_hypothesis, no_conflate_gating_with_readiness, agent_host_isolation.
