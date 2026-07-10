# op-281 — Gatekeeper: size the op-261 MACH_RCV_LARGE oversized-receive contract gap — does any live preview consumer actually drive an oversized LARGE receive on the syscall path? (evidence-first, BEFORE any kernel patch)

op-281 | role: **Gatekeeper** (soak/runtime-evidence owner; no product-write to the fix itself) | EXU: **rmx-gatekeeper** | state: **[Reserved — evidence-first gate for the op-261 wider finding (the `mach_msg.c:372` option-mask that kills MACH_RCV_LARGE keep-on-queue). Arranger verified the DEFECT first-hand end-to-end in the release base; what is unproven is whether any live preview consumer ever exceeds its receive buffer on a LARGE receive at runtime (it works green today because buffers are sized generously). Sizes severity BEFORE op-282 is allowed to touch kernel mach-ipc code. Coordinator dispatches.]** | parent id: id-036 (CLOSED — op-249 lives here) + id-000 | L1i: li-1001 (mach-ipc substrate) | cost: gatekeeper (soak) | authored 2026-07-10 (Arranger seat, model Opus 4)

## CONTEXT (engineering framing)
Ordinary open-source OS engineering on our own kernel mach-ipc layer. rmxOS = Darwin/Mach userland on FreeBSD 15. This is a reliability measurement of our own message-receive path — no target, no adversary. The point is runtime evidence that sizes a verified-but-latent contract gap before we decide whether/how to patch kernel code.

## WHY (one line)
op-261 (oracle2, Arranger-verified first-hand) found that our single mach receive path strips `MACH_RCV_LARGE` before the keep-on-queue decision, so an oversized receive is CONSUMED instead of retained-and-sized — but it works green today, so we measure whether any live consumer actually hits it before editing the kernel.

## THE DEFECT (already Arranger-verified first-hand in `wip-gpt/wip-rmxos` — this op does NOT re-verify it, it SIZES it)
- User `mach_msg()` → `mach_msg_overwrite_trap` (`mach_msg.c:434`, full option) → `mach_msg_receive` (`:472`) stores full option in `self->ith_option` (`:367`) but passes only `option & MACH_RCV_TIMEOUT` positionally to `ipc_mqueue_receive` (`:372`).
- The keep-on-queue-on-LARGE test reads that masked positional option (`ipc_mqueue_post_on_thread:620-628`, `ipc_mqueue_finish_receive:898-906`), so `option & MACH_RCV_LARGE` is always false there → oversized kmsg dequeued (`:632`), never requeued; `msg_receive_error` rewrites `msgh_size` to a minimal header.
- Single receive entry — libdispatch's LARGE-setting mig_server/mach-source consumers ride it. Latent because live buffers are sized large enough that the overflow never fires. Severity = what THIS op measures.

## SCOPE (what to measure — read-only observation, no code edit)
On the staging image, without touching the kernel, gather evidence sizing whether the gap is live:
1. **Overflow-occurrence watch under normal soak.** Instrument/observe the receive path (e.g. the existing `mach_debug_enable` size-mismatch print at `ipc_mqueue.c:900-904`, or a DTrace probe on `MACH_RCV_TOO_LARGE` returns) across a representative notify/asl/launchd soak. Does `TOO_LARGE`-with-`MACH_RCV_LARGE` EVER fire on real preview traffic, or do buffers always accommodate? Report counts + which consumer.
2. **Forced-overflow probe (characterize the observed failure).** Drive a deliberately oversized message to a receiver that set `MACH_RCV_LARGE` (the libdispatch mig_server grow-and-retry shape is the natural target). Observe the ACTUAL behavior against the contract: is the message lost/consumed, does the caller get a minimal-header size instead of the true required size, does the grow-retry loop misbehave or spin? Report the observed return + msgh_size + whether the message survived.

## DELIVERABLE
A staged Gatekeeper soak note (under rmx-gatekeeper/): a **confirmed-live / latent-only / inconclusive** verdict on whether preview traffic hits the gap (item 1), plus a characterization of the observed failure mode when forced (item 2), with raw counts + log/probe excerpts. One-line severity sizing that op-282 consumes to scope the kernel fix (and to decide whether it is even preview-gating vs a post-preview li-1001 seed). Report for first-hand Arranger read.

## BOUNDARIES
- Runtime observation ONLY — do NOT patch `mach_msg_receive`, `ipc_mqueue_receive`, or the keep-on-queue decision. The fix is op-282, gated on THIS evidence.
- Do NOT re-litigate the op-249 fix (that PASSED in op-261) or the flag-overlap/refcount carve-outs.
- Does not decide milestone placement or release timing — sizes severity so the Coordinator can gate op-282.

## RELATIONS
op-261 (the oracle2 consult — this sizes its wider finding; Arranger-verified at `mach_msg.c:367/:372` + `ipc_mqueue.c:620-628/:898-906`) / op-249 (the fix that PASSED — this is a DIFFERENT, wider gap on the same path) / op-282 (RESERVED — the kernel fix, gated on this evidence) / op-264→op-279 (the same evidence-first-before-high-blast-radius-patch pattern) / li-1001 (mach-ipc substrate) / id-036. feedback: oss_engineering_framing, code_reasoned_verdict_is_hypothesis, no_conflate_gating_with_readiness, verify_signature_divergence_claims, agent_host_isolation, op_state_dispatch_boundary.
