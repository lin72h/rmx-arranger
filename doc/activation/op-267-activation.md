# op-267 — Oracle: confirm the correctness of libxpc's connection cancellation / teardown path — one feature, one file

op-267 | role: **Oracle** (consult; highest-tier, consult-only, no product-write) | EXU: **rmx-oracle-rx-x64z** | state: **[Void — DUPLICATE of op-263, withdrawn before dispatch 2026-07-04 (never sent to Oracle — cost saved). Arranger cross-checked the returned `rmx-oracle/op-263-xpc-reply-correlation-findings.md`: op-263 §4 already read the ENTIRE teardown machinery this op would have asked — cancel (`xpc_connection.c:300-310`), `invalidate → complete_pending` waiter-drain (:433-449), remote-DEAD watcher (:216-225), peer PROC-EXIT watcher (:499-517), handler-once (§2, remove-before-dispatch :592-603), and the cancel-vs-recv-queue-match double-remove/UAF (§3), plus the second-epoch hang hole (xc_interrupted one-shot never reset → 2nd sync call hangs). All four intended questions (handler-once / waiter-drain / port+refcount release / cancel-vs-death convergence) are covered there. The only sliver op-263 did not itemize — Mach send/recv port deallocation at the final connection free — is Arranger-verifiable at source, not worth an Oracle-tier consult. No dispatch.]** | parent id: id-021 (libxpc conformance bring-up) | L1i: li-007 (libxpc core service) | cost: oracle-tier (highest ~90/100) | authored 2026-07-04 (Arranger seat, model Opus 4)

## PREAMBLE — what this project is
rmxOS is an **open-source operating system** — a Darwin/Mach userland ported onto stock FreeBSD 15, developed in the open like FreeBSD or illumos. This is a **maintainer's own code-quality check of ONE feature of our IPC library (libxpc)** — how a connection is shut down when it is cancelled or its peer goes away. Ordinary pre-release code-quality engineering on our own source. No target, no adversary, nothing to exploit — the goal is to confirm this one path is well-built for our own users.

## THE ONE FEATURE (this is the whole scope)
libxpc's **connection cancellation / teardown** in `xpc_connection.c`: when a connection is cancelled (`xpc_connection_cancel`) or its peer dies, libxpc drains in-flight items, wakes any reply waiters, runs the cancellation handler, releases the send/recv Mach ports and dispatch source, and frees the connection object. op-263 already read the reply-correlation happy path (`send_message_with_reply`, the `xc_pending` TAILQ + dispatch_semaphore) on this same file — this reads the shutdown side of the same object. Confirm this one teardown path is correct — nothing wider.

## CONTEXT
An IPC library's connection object must die cleanly: every caller blocked waiting for a reply is released, every kernel resource it held is returned exactly once, and the user's cancellation handler fires exactly once. This is the least-exercised corner of the connection lifecycle (the conformance matrix drove the live send/reply path; teardown-under-cancel and teardown-under-peer-death are the edges). Plain software-engineering framing: handler-once semantics, waiter drain, port/refcount release, and cancel-vs-death convergence.

## THE QUESTIONS (all about this one path)
1. **Handler-once.** Is the cancellation handler invoked exactly once, and only after in-flight items have drained — never twice, never skipped (e.g. cancel racing an already-completing connection)?
2. **Reply-waiter drain.** On cancel/death, is every caller blocked in `send_message_with_reply` (the `xc_pending` waiters op-263 mapped) woken with a cancellation/error reply — none left blocked forever on a semaphore that will never be signalled?
3. **Port + refcount release.** Are the send/recv Mach ports, the dispatch source, and the connection's retain count each released exactly once — no port right leaked, no over-release / use-after-free, no double `dispatch_release`?
4. **Cancel-vs-death convergence.** Do explicit `xpc_connection_cancel` and peer-death (a dead-name notification mid-flight) converge on the same teardown without racing into double-teardown or a torn half-freed state?

## DELIVERABLE
A short staged note (under rmx-oracle/): for each of the 4 questions, a finding characterized **solid / uncertain / needs-runtime-check**, each a hypothesis with `xpc_connection.c` file:line citation. Anything uncertain, bucket by effort/risk. A **hypothesis** the Arranger routes to verification or seeds into li-007 — not a product edit, not a release decision.

## BOUNDARIES
- Read + advise only; propose, do not edit. Stage the note in the Oracle's own dir.
- Scope is EXACTLY the connection cancel/teardown path in `xpc_connection.c` — do NOT expand into the reply-correlation happy path (op-263 covered it), the dictionary serializer/encode, the Mach transport wire format, or the `xpc_domain` service-hosting plane. No interface-shape / cross-platform comparison work.
- Treat every observation as a hypothesis to confirm at source before it drives an edit. Read the actual struct/function body before flagging a lifetime or refcount issue (prior asl/notify reviews had false signature claims).
- Does not decide release timing or milestone placement.

## RELATIONS
op-263 (the reply-correlation happy path on the SAME file — this is its teardown sibling) / op-260 + op-262 + op-264 (the same narrow accepted style) / id-021 (libxpc conformance bring-up) / li-007 (libxpc core service). feedback: oss_engineering_framing, code_reasoned_verdict_is_hypothesis, verify_signature_divergence_claims, no_conflate_gating_with_readiness, agent_host_isolation, op_state_dispatch_boundary.
