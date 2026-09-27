# op-282 — Implementer: fix the op-261 MACH_RCV_LARGE oversized-receive contract gap — plumb LARGE/trailer bits into the mqueue keep-on-queue decision AND make the blocked path honor LARGE-retain (RESERVED, gated on op-281 evidence)

op-282 | role: **Implementer** | EXU: **wip-gpt** | state: **[Flushed — never dispatched; Coordinator excluded external/public syscall-`LARGE` callers from 1.0-preview, and op-316 confirmed this brief was incomplete; any future fix receives a new ID/op from li-9007 after evidence]** | parent id: id-036 (CLOSED — op-249 lives here) + id-000 | L1i: li-9007 (post-preview; formerly li-1001 preview relation) | cost: implementer (small/med — kernel mach-ipc, evidence-first) | authored 2026-07-10 (Arranger seat, model Opus 4)

## ROUTING UPDATE — 2026-07-11

op-316 confirms this brief is materially incomplete: it does not bind
`mach_msg_receive_results_error` size/identity copyout or the synchronous blocked wake/result state.
The Coordinator excluded external/public syscall-`LARGE` callers from preview scope, so this op is
flushed without edit and must never be dispatched or reused. li-9007 owns future re-decomposition;
the separate libxpc trailer-admission boundary remains under id-021.

## CONTEXT (engineering framing)
Ordinary open-source OS engineering on our own kernel mach-ipc layer. rmxOS = Darwin/Mach userland on FreeBSD 15. A correctness fix to our own message-receive contract. No target, no adversary.

## WHY (one line)
op-261 (oracle2, Arranger-verified first-hand) found our single mach receive path strips `MACH_RCV_LARGE` before the keep-on-queue decision (`mach_msg.c:372`), so an oversized receive is consumed instead of retained-and-sized — breaking the grow-and-retry contract libdispatch's LARGE consumers depend on.

## PRECONDITION (why this op is RESERVED, not live)
This edits kernel mach-ipc receive code that every hosted daemon rides. Per the executing-actions-with-care rule, high-blast-radius changes get evidence first. op-281 (Gatekeeper) measures whether any live preview consumer actually hits the overflow and characterizes the observed failure. This op is held until that evidence lands and the Coordinator confirms the fix is warranted at preview scope — the fix shape is chosen from the evidence, so specifying it fully now would be premature.

## INTENT (the banked fix direction — to be finalized against op-281 evidence)
Two parts, because op-261 established (Arranger-verified) that a naive one-liner is insufficient:
1. **Immediate-receive path:** forward the keep-on-queue-relevant bits (at minimum `MACH_RCV_LARGE` and the `MACH_RCV_TRAILER_*` bits) into `ipc_mqueue_receive` at `mach_msg.c:372` — either widen the mask (`option & (MACH_RCV_TIMEOUT | MACH_RCV_LARGE | MACH_RCV_TRAILER_MASK)`) or have the mqueue layer read the already-stored `self->ith_option`. This makes `ipc_mqueue_post_on_thread:620-628` see LARGE and retain the oversized kmsg with the correct required size.
2. **Blocked-receive path:** `ipc_mqueue_finish_receive` (`:898-906`) returns `TOO_LARGE` AFTER delivery already handed the waiter the kmsg (`:632`-style dequeue happened in the sender/delivery path) and never requeues. The fix must make the blocked-LARGE case either retain/requeue the message or otherwise preserve the retain-and-report-size contract — NOT just report the size on a message that was already consumed.
Preserve the existing behavior for the common non-LARGE receive (the working green path) — no regression to notify/asl/launchd round-trips.

## SCOPE (to be finalized on dispatch)
- The two-part fix above as scoped by op-281 evidence; keep the non-LARGE path byte-for-byte behavior-identical.
- Build the kernel; confirm compile/link on the FreeBSD target.
- Runtime re-confirmation that a LARGE consumer now gets retain-and-correct-size (and the forced-overflow probe from op-281 now passes) is a FOLLOW-ON Gatekeeper pass, not this op.

## BOUNDARIES
- Do NOT dispatch or edit until op-281 evidence + Coordinator gate. This op existing does NOT authorize the edit.
- Scope is EXACTLY the MACH_RCV_LARGE keep-on-queue contract on the receive path; do NOT re-touch the op-249 fix (it PASSED), the flag-overlap/refcount carve-outs, or the send path.
- Does not decide milestone placement or release timing.

## RELATIONS
op-261 (the finding this resolves — Arranger-verified at `mach_msg.c:367/:372`, `ipc_mqueue.c:620-628/:898-906`) / op-281 (the Gatekeeper runtime-check that GATES this op — evidence sizes the fix + confirms it is warranted) / op-249 (the narrower fix that already PASSED on the same path) / op-264→op-280 (the same reserved-fix-gated-on-runtime-evidence pattern for high-blast-radius code) / li-1001 (mach-ipc substrate) / id-036. feedback: oss_engineering_framing, build_is_implementer, code_reasoned_verdict_is_hypothesis, verify_signature_divergence_claims, agent_host_isolation, op_state_dispatch_boundary.
