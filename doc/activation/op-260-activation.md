# op-260 — Oracle: confirm the correctness of the ASL on-disk store write + read-back path (asl_store/asl_file) — one feature, one file pair

op-260 | role: **Oracle** (consult; highest-tier, consult-only, no product-write) | EXU: **rmx-oracle-rx-x64z** | state: **[Done — findings returned + ACCEPTED as a grounded consult 2026-07-03. First narrow-single-feature Oracle op to CLEAR the classifier (confirms: userland-service scope + no interface-mapping = accepted; kernel-mach-ipc = still blocked). Arranger VERIFIED FIRST-HAND the two flagship claims at their exact cited lines: (Q1) the record-body `fwrite`/`fflush` return is unchecked at `asl_file.c:1133-1134` (while the pointer-publish writes :1147/:1156 ARE checked — finding is precise); (2) `trigger_aslmanager()` body is `#if 0`'d dead at `usr.sbin/asl/daemon.c:853-881`. Provenance (byte-identical-to-donor) + the aslmanager.c:974-981 size-pressure claim taken as Oracle-verified, not yet Arranger-read. All findings are hypotheses (not gating; asl post-preview-floor). ROUTED: SCOPE-5 instrumentation + same-second-roll-clobber / ACL'd-unlink / unchecked-write folded into op-258 (SCOPE-4/5/6); the in-daemon-trigger-dead confirmation folded into op-257 (validates the external-StartInterval approach); unchecked-write fix RESERVED as op-266, GATED on op-258's ENOSPC leg.]** | parent id: id-011 (libasl/asld) | L1i: li-1004 (asl) | cost: oracle-tier (highest ~90/100) | authored 2026-07-03 (Arranger seat, model Opus 4)

## PREAMBLE — what this project is
rmxOS is an **open-source operating system** — a Darwin/Mach userland ported onto stock FreeBSD 15, developed in the open like FreeBSD or illumos. This is a **maintainer's own code-quality check of ONE feature of our system logger** — how the ASL daemon (asld) writes a log message to its on-disk store and reads it back for a query. Ordinary pre-release code-quality engineering on our own source. No target, no adversary, nothing to exploit — the goal is to confirm this one path is well-built for our own users.

## THE ONE FEATURE (this is the whole scope)
The ASL **on-disk store write + read-back** path in `lib/libasl/asl_store.c` and `lib/libasl/asl_file.c` (asld persists a submitted message to a store file; `asl_search` reads records back). op-170 already read part of this: `asl_store.c` holds a fixed-size `file_cache` over on-disk `FILE*`-backed store files. Confirm this one path is correct — nothing wider.

## CONTEXT
A logger's core job is: persist a message durably, then let it be queried. This path is the least-exercised part of asl (conformance covered single-shot API behavior; the store's write/rotate/read-back is what the leg-4 soak stresses), so a focused correctness pass here is worth an Oracle read before we lean on it. Plain software-engineering framing: file-handle lifetime, record framing, rotation boundary correctness, read-back consistency.

## THE QUESTIONS (all about this one path)
1. **Write.** A message → a store-file record: is the FILE* lifetime correct (open/write/flush/close paired on every path incl. write-failure and store-full)? Is the record framing/format written and terminated consistently so a reader can always parse the last record?
2. **Rotation.** When a store file rolls to a new file, is the handoff correct — no record lost or duplicated at the boundary, the cache index updated consistently, the old handle closed?
3. **Read-back.** `asl_search` reading records: is it consistent against a store file asld is concurrently appending to? (The conformance runs saw an immediate write→search return nothing — a verified macOS-faithful latency, NOT a divergence. Confirm that is a propagation-timing property of this path, not a framing/index bug that could also drop a settled record.)
4. **Coordination with reclaim (feeds op-258).** Can the retention tool (aslmanager) rotate/delete a store file while asld holds it open or mid-write — is there a lock/generation/coordination that makes reclaim safe, or is that an uncoordinated path? Name what op-258's soak should watch to prove reclaim is safe.

## DELIVERABLE
A short staged note (under rmx-oracle/): for each of the 4 questions, a finding characterized **solid / uncertain / needs-runtime-check**, each a hypothesis with `asl_store.c`/`asl_file.c` file:line citation; anything uncertain bucketed by effort/risk. Explicitly state which of the 4 op-258 should instrument. A **hypothesis** the Arranger routes to verification or seeds into li-1004 — NOT a product edit, NOT a gating verdict.

## BOUNDARIES
- Consult-only, no product-write; propose, do not patch; stage in the Oracle's own dir.
- Scope is EXACTLY `asl_store.c` + `asl_file.c` store write/read-back — do NOT expand into the submit transport, the client API matrix, or aslmanager's internals (beyond the coordination touchpoint in Q4).
- Code-reasoned = hypothesis; verified at source before it drives an edit. Prior asl reviews had 2 false signature claims — read the struct/function body before asserting a miscount.
- Does NOT decide gating (`no_conflate_gating_with_readiness`) — asl is post-preview-floor.

## RELATIONS
op-258 (asl leg-4 re-soak — Q4 + the store-size instrumentation this reasons) / op-257 (aslmanager wire-up) / op-170 (read asl_store.c file_cache; RSS = I/O buffering not leak) / id-011 / li-1004. feedback: oss_engineering_framing, code_reasoned_verdict_is_hypothesis, verify_signature_divergence_claims, no_conflate_gating_with_readiness, agent_host_isolation, op_state_dispatch_boundary.
