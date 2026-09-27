---
id: op-242
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-242 — Implementer: root-cause + fix the kernel NULL-`io_lock` panic on the MACH_RECV dispatch-source receive-error path (id-036 / debt #21) — TRACE the mechanism before any fix

op-242 | role: **Implementer** (kernel Mach-IPC dive + mach.ko fix) | EXU: **wip-gpt (Implementer seat)** | state: **[Done — FIX DELIVERED, root cause Arranger-verified first-hand; fix UNPROVEN at runtime → gated to Validator+Gatekeeper. Commit d70062591073, mach.ko f0f10008, 2026-07-02]** — see OUTCOME. | parent: op-241 (Explorer premise-check — LIVE GAP 9/10, panic confirmed first-hand) / id-036 (the defect record) | L1i: li-1002 (libdispatch/IPC substrate hardening) / li-1001 (substrate invariant) / li-1007 (core-service exposure) | cost: 30 (kernel trace-confirm + targeted fix + mach.ko build) | authored 2026-07-02 (Arranger seat, model Opus 4)

## OUTCOME (Arranger adjudication, 2026-07-02, first-hand)

**Root cause — VERIFIED first-hand, genuine bug.** The Implementer found a **flag-value collision**: libdispatch's readiness flag `DISPATCH_MACH_RECV_MESSAGE = 0x2` (`lib/libdispatch/src/source_internal.h:66`, verified) numerically equals `MACH_RCV_MSG = 0x00000002` (`sys/sys/mach/message.h:636`, verified). The public MACH_RECV source arms readiness-only with `.fflags = DISPATCH_MACH_RECV_MESSAGE` (`init.c:1250`, verified). So kernel `filt_machport` (ipc_pset.c) read the readiness flag as a direct-receive request and did an in-kernel receive with **no buffer** → `MACH_RCV_TOO_LARGE` → `msg_receive_error` → `ipc_kmsg_copyout_dest` → null-`io_lock` panic. This cleanly supersedes op-241's REFUTED "insert_right didn't init io_lock_data" guess and answers id-036 Q1 (why the error path): the receive was never meant to happen.

**Fix — reviewed first-hand (`git show d70062591073`).** New `filt_machport_direct_receive(kn)` gates direct receive on `MACH_RCV_MSG` set AND `ext[0] && ext[1]` (real buffer present); readiness-only public sources now skip the receive; internal direct-receive (which carries a buffer) stays eligible. Minimal, diff-vs-stock, well-targeted. Standalone mach.ko rebuilt scrubbed-env rc 0 → **f0f100086723a0…d7a547**.

**Trace — confirms the SYMPTOM, not yet the MECHANISM (`code_reasoned_verdict_is_hypothesis`).** The serial logs reproduce the panic backtrace first-hand (`ipc_kmsg.c:2844` null mtx → copyout_dest → msg_receive_error → mach_msg_receive). BUT: (a) the reproduced backtrace enters via **`mach_msg_overwrite_trap` (the userland receive syscall)**, NOT via `filt_machport` — so the causal link "filter's bad receive → this syscall-path panic" is REASONED (likely: the filter's no-buffer receive tears down kmsg/dest state that the probe's own handler `mach_msg(MACH_RCV_MSG)` then trips over), not shown in the trace; (b) no `TOO_LARGE` / `readiness` / `ext[` string appears in the captured logs — the flag-collision mechanism is inferred from the constants, not observed in a bar. The root cause is a STRONG hypothesis (the collision is real and verified), but the fix is **UNPROVEN at runtime** and the Implementer explicitly did NOT run the acceptance rerun.

**GATE (Rule 11 — kernel Mach-IPC receive/lock path = L/XL). Two hops:**
1. **Validator (kernel-semantics, confidence 1-10; Arranger steps in <9)** — op-246. Must confirm: (i) the fix actually removes the panic path the reproduced backtrace shows (reconcile the `filt_machport` fix with the `mach_msg_overwrite_trap` syscall-path panic — does removing the filter's bad receive fix the syscall-path trip, or does a distinct syscall-path panic remain?); (ii) **no regression to internal direct-receive** — confirm `DISPATCH_MACH_RECV_MESSAGE_DIRECT` sources actually populate `ext[0]/ext[1]`, else the gate would silently disable them; (iii) reconcile with op-098 (filt_machport success path — did it carry a buffer?) and the id-036 cross-op clue (why li-1002 `source-MACH_RECV` PASSED on the cert image while the alpha panics — version-specific mach.ko or test-config difference?).
2. **Gatekeeper (acceptance rerun) — op-247, after Validator ≥9** — build/boot the fixed mach.ko (content-check sha f0f10008 first, `artifact_identity_needs_content_check`), re-run the op-241 reproducer to a **no-panic pass**, + notifyd/libxpc/li-1007 regression check.

**Net:** real bug found + verified, credible minimal fix, honest handoff (no self-gate, no self-accept). Not retired — the runtime proof + kernel-semantics gate are owed.

## CONTEXT (read first)
Open-source OS engineering — fix a kernel Mach-IPC panic in our compat-Mach message receive path. Not security work; our own `sys/compat/mach` port/IPC code. A `DISPATCH_SOURCE_TYPE_MACH_RECV` round-trip panics the kernel at `io_lock(dest)` in `ipc_kmsg_copyout_dest`. This op TRACES the actual mechanism first, then fixes it, builds `mach.ko` standalone, and hands to a Validator kernel-semantics gate + a Gatekeeper reproducer re-run.

## WHY (one line)
op-241 confirmed first-hand (9/10, accepted) that a single-message MACH_RECV dispatch-source round-trip panics: `panic: mtx_lock() of spin mutex (null)` in `ipc_kmsg_copyout_dest → msg_receive_error → mach_msg_receive`. The kqueue filter is fine (op-098); this is a receive/copyout-layer defect. **op-241's proposed fix ("insert_right didn't init io_lock_data") is REFUTED** — the probe's send on the same port succeeded, and the send path also `io_lock(dest)`s it, so the lock was non-NULL at send. The real cause is elsewhere and must be traced, not guessed.

## SCOPE (confirm mechanism FIRST → fix → build; the op-240 discipline)
1. **Trace the mechanism before touching source (`verify-premise-before-mechanism`, `code_reasoned_verdict_is_hypothesis`, `dtrace_first_debugging`).** Reproduce with the op-241 probe (`rmx-explorer findings/nx-r64z/dtrace/mach-recv-premise/mach_recv_probe.c`) on the alpha (MACHDEBUGDEBUG). Establish, first-hand (DTrace `fbt::ipc_kmsg_copyout_dest`, `fbt::mach_msg_receive`, `fbt::msg_receive_error`, `fbt::ipc_object_destroy` + KGDB on the panic):
   - **(Q1)** Why does `mach_msg_receive` enter the `msg_receive_error` path at all? (op-098's raw round-trip receive SUCCEEDED — what differs: the dispatch source's internal servicing, a double-drain, buffer size, a right-count/type issue on the self-send?)
   - **(Q2)** What is `dest` (`kmsg->ikm_header->msgh_remote_port`) at the `io_lock` panic — a real port object with a nulled/uninitialized `io_lock_data`, a freed object (use-after-free), or a non-port pointer that slipped past `IO_VALID`?
   - Suspect first the **double-drain**: the probe arms the dispatch MACH_RECV source AND the handler calls its own `mach_msg(MACH_RCV_MSG)` on the same port (probe.c:70-87). Determine whether libdispatch's MACH_RECV source servicing itself receives/consumes/destroys the message, racing the handler's receive → the second receive operates on freed/half-torn-down kmsg state.
2. **Fix per what the trace shows — minimal, diff-vs-stock.** Depending on Q1/Q2:
   - if **UAF/double-servicing**: fix the ownership so the MACH_RECV source does NOT consume the message it only signals (Apple semantics: the handler receives; the source must not dequeue) — likely a libdispatch MACH_RECV servicing fix, NOT kernel; OR
   - if **kernel robustness**: `ipc_kmsg_copyout_dest` / `msg_receive_error` must not `io_lock` an invalid/dead dest — harden the error path (the `assert(IO_VALID(dest))` at copyout_dest is clearly insufficient on a non-INVARIANTS or malformed-pointer case); OR
   - if **genuine init gap**: fix the specific creation/insert path the trace implicates (NOT insert_right on spec — op-241's guess is already refuted).
   Do not restructure the engine; fix the liveness/robustness defect the trace names.
3. **Build** the artifact the fix lands in: `mach.ko` standalone (`make -C sys/modules/mach`, MAKEOBJDIRPREFIX only, NOT buildkernel) and/or libdispatch. Record built shas. Diff-vs-stock discipline.

## NON-SCOPE
- Does NOT implement op-241's refuted init-fix on spec (trace first).
- Does NOT self-gate kernel semantics (Validator, Rule 11 — IPC receive/lock path = L/XL) or self-run the acceptance re-run (Gatekeeper).
- Does NOT decide preview-severity C6 (Coordinator, li-1013) — supplies the trace that informs it.
- Does NOT re-open id-003 (kqueue filter proven, op-098) unless the trace contradicts it first-hand.

## DELIVERABLE
(1) A trace artifact answering Q1 (why the error path) + Q2 (what `dest` is at panic) — the confirmed mechanism, first-hand; (2) a minimal fix in the layer the trace implicates (kernel `mach.ko` and/or libdispatch), with built shas, handed to a Validator for the kernel-semantics gate (confidence 1-10; Arranger steps in <9); then to a Gatekeeper to re-run the op-241 reproducer to a **no-panic pass** + confirm no notifyd/libxpc regression. If the trace shows the panic is NOT reachable by real consumers' usage (only the probe's double-drain), report that — it reshapes C6 severity.

## BOUNDARIES
- **build_is_implementer**; Implementer builds + reasons + traces, does not self-gate or self-soak.
- **mach.ko standalone module build** (no KERNBUILDDIR fold); libdispatch built separately if the fix lands there.
- **Diff vs stock / minimal adaptation** — our compat-Mach; fix the defect, do not restructure.
- **fbt traces kernel only** — use `fbt::` bars for the kernel IPC path; for the userland dispatch servicing use `dispatch:::` USDT, not fbt userland symbols (`feedback_fbt_traces_kernel_only`).
- **Trace before fix** — a code-reasoned or panic-backtrace-reasoned root cause is a hypothesis until the trace confirms the causal path; op-241's own proposed fix is already refuted by first-hand reasoning, so do not trust any single-line root-cause without the trace (`code_reasoned_verdict_is_hypothesis`).
- Stage only in the Implementer's own tree (`agent_host_isolation`).

## RELATIONS
op-241 (premise-confirmed panic, requirement source) / id-036 (defect record). id-003 [DROPPED] / op-098 (kqueue filter proven — why this is receive-layer, and the success-path baseline Q1 diverges from). op-240 (the discipline this op mirrors: trace-confirm before fix — and the reason op-241's guessed fix gets no benefit of the doubt). li-1002 (substrate hardening); li-1001 (completion/liveness invariant); li-1007 (notifyd/asld integration exposure — the C6 severity input); li-1013 C6 (preview-severity, Coordinator). feedback: verify-premise-before-mechanism, code_reasoned_verdict_is_hypothesis, dtrace_first_debugging, build_is_implementer, mach_ko standalone module build, fbt_traces_kernel_only, no_conflate_gating_with_readiness, op_state_dispatch_boundary.
