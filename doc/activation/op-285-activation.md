---
id: op-285
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-285 — Implementer: give libxpc connections a real object identity + a connection-specific destructor (one coordinated lifecycle correction) — RESERVED, gated on op-284 evidence

op-285 | role: **Implementer** | EXU: **wip-gpt** | state: **[Done — edit commit `778cb07442e61cdd8fb3e766b91676f2e9a261b8` is Arranger-verified and origin-reachable as of 2026-07-11; op-307 is retired at origin-reachable `40c8a93d`, while op-291 remains HARNESS-NOT-ACCEPTED and both op-311/op-312 failed harness intake; op-308 runtime acceptance remains held with no accepted successor machinery, so this op is not retired]** | parent id: id-021 (libxpc conformance bring-up) | L1i: li-007 (libxpc core service) | cost: implementer (med — object-model + destructor in a core service, evidence-first) | authored 2026-07-10 (Arranger seat, model Opus 4)

## CONTEXT (engineering framing)
Ordinary open-source OS engineering on our own IPC library. rmxOS = Darwin/Mach userland on FreeBSD 15. A correctness fix to libxpc's connection object model. No target, no adversary.

## WHY (one line)
op-284 (Gatekeeper) is measuring a source-confirmed defect: `struct xpc_connection` has no generic object header, so `xpc_get_type`/`xpc_retain`/`xpc_release`/`xpc_object_destroy` read type/flags/refcount from bytes that overlay the `xc_name` pointer, and destruction runs no connection teardown — this op fixes it, once evidence sizes it.

## PRECONDITION (why RESERVED, not live)
This edits object identity and lifetime in a preview-gating core service. Per the executing-actions-with-care rule, high-blast-radius changes get evidence first. op-284 characterizes whether any live preview consumer (esp. the aslmanager managed-mode listener) actually trips the defect and what the observed failure is. This op is held until that evidence lands and the Coordinator confirms the fix is warranted at preview scope; the fix shape is chosen from the evidence, so fully specifying it now would be premature.

## INTENT (the banked fix direction — ONE coordinated lifecycle correction, per the consult; to be finalized against op-284 evidence)
The consult was explicit that patching ONLY the type check is insufficient — treat these as one change:
1. **Object identity.** Give a connection a real generic object header (type/flags/refcount) so `xpc_get_type` returns `XPC_TYPE_CONNECTION` and `xpc_retain`/`xpc_release` operate on a real refcount — either by embedding the `struct xpc_object` header at the front of `struct xpc_connection` (so the existing casts become valid), or by a connection-specific type/retain/release path. Set type + initial refcount in `xpc_connection_create` (`xpc_connection.c:50-104`) the way `_xpc_prim_create_flags` does for ordinary objects (`xpc_type.c:175-204`).
2. **Connection destructor.** `xpc_object_destroy` (`xpc_misc.c:139-149`) must route a connection to a real teardown — Mach ports, send/recv/target queues + sources, handler/finalizer blocks, `xc_name`, pending calls, peer links — not just `free()`. Wire the empty finalizer setter (`xpc_connection.c:375-380`) and make cancel (`:300-310,433-471`) compose correctly with final release.
3. **First-message ordering (if op-284 confirms the aslmanager ordering hypothesis).** Serialize/hold first-message delivery to a new peer until peer setup (handler install) completes — the consult noted listener callbacks target `serverq` while an anonymous peer defaults to the main queue (`aslmanager.c:1594-1603`; `xpc_connection.c:83-85,580-586`), so fixing type alone would not establish handler-before-first-message ordering.
Preserve behavior for the ordinary (dict/array/primitive) objects — no regression to the pack/unpack or reply-correlation paths.

## SCOPE (to be finalized on dispatch)
- The coordinated identity + destructor (+ ordering, if confirmed) fix as scoped by op-284 evidence.
- Build libxpc; confirm compile/link on the FreeBSD target.
- Runtime re-confirmation (op-284's probes now pass: anon+named `xpc_get_type` correct, balanced retain/release, no owned-resource leak, aslmanager accept installs the handler) is a FOLLOW-ON Gatekeeper pass, not this op.

## BOUNDARIES
- Do NOT dispatch or edit until op-284 evidence + Coordinator gate. This op existing does NOT authorize the edit.
- Scope is EXACTLY the connection object identity + destructor (+ first-message ordering if confirmed); do NOT fold in the op-283 pack/unpack trivial fixes, the leak+aliasing pack seed, or the reply-correlation path (op-263).
- Does not decide milestone placement or release timing.

## RELATIONS
op-284 (the Gatekeeper premise-check that GATES this op — evidence sizes the fix + confirms warrant) / 1.0-preview solidity consult (oracle2 finding #2 — the defect this resolves) / op-263 + op-271/op-283 (sibling libxpc consults on other paths, fenced out) / op-281→op-282 + op-279→op-280 (the same reserved-fix-gated-on-evidence pattern) / id-021 (libxpc conformance) / li-007 (libxpc core service). feedback: oss_engineering_framing, build_is_implementer, code_reasoned_verdict_is_hypothesis, verify_signature_divergence_claims, no_conflate_gating_with_readiness, agent_host_isolation, op_state_dispatch_boundary.
