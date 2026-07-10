# op-227 — Implementer: make dispatch's concurrency-engine selection honest and loud (libthr kernel probe + init-time engine banner) — the do-regardless evidence-hygiene half of N2

op-227 | role: **Implementer** (product-write) | EXU: **wip-gpt (Implementer seat)** | state: **[Retired — 2026-07-02: source verified @ 106f9d7fd160 + banner runtime-VALIDATED by op-234 @ d541cd1 (twq/pool dynamic, 2 definitive cells). Open hygiene item carried to op-226: reconcile the ship libdispatch SHA (op-234 tested 35dd592a, not the reported 8623f0f4 — behaviorally op-227 code, but pin which ships).]** | parent id: id-000 (op-223 LEG A synthesis, improvement N2 — hygiene half) | L1i: li-1000 (li-9003 Item 2 disposition (b); supports op-225 C2(ii)) | cost: 30 | authored 2026-07-02 (Arranger seat, model Opus 4)

## ADJUDICATION (Arranger, 2026-07-02) — source deliverable MET; gate S (direct-gated, Rule 11); runtime deferred to op-234
Implementer landed 106f9d7fd160 and reported source+build+static-proof, runtime explicitly deferred. Gate sized **S** (source landing + static proof; runtime handed to a separate op) → Arranger gated directly rather than round-trip a Validator (Rule 11 S/M carve-out).

**Verified first-hand at 106f9d7fd160 (all PASS):**
- Commit touches exactly the two claimed files: `lib/libdispatch/src/queue.c` (+12/-2), `lib/libthr/thread/thr_workq.c` (+31/-2).
- **Honest per-run probe** confirmed: the constant-mask `twq_supported_features()` is renamed `twq_requested_features()`; new `twq_probe_supported_features()` issues a real `TWQ_OP_INIT` `twq_sys_kernreturn`, caches via `tr_supported_checked`, returns `0` on `-1`/failure else `(granted & requested)`; `twq_runtime_init_locked` now calls the probe once (cached). This is the fix for the op-225 finding (libthr advertised FINEPRIO unconditionally — thr_workq.c:196-201 constant) — engine capability is now kernel-granted, per-run.
- **Engine banner** `queue.c:899` `_dispatch_log("libdispatch concurrency engine: %s", ...)` and **setdispatch-failure log** `queue.c:784` `"...setdispatch failed: %d"` both present. Commit message asserts observability-only (engine-selection path preserved) — consistent with the diff.

**NOT re-verified here (correctly out of Implementer scope / handed to op-234):**
- Build-clean (rc 0) + built-artifact SHAs (libdispatch.so.5 `8623f0f4c219...`, libthr.so.3 `f4da8cde2273...`) taken as reported; not re-hashed. **Handoff flag to op-234 (artifact_identity_needs_content_check, op-145 lesson):** the Gatekeeper must confirm the *booted image* carries these exact SHAs, not merely "a libdispatch" — a same-name binary of different lineage would silently invalidate the banner reading.
- Runtime two-regime proof: Implementer correctly did NOT guest-run (not Implementer's job; build_is_implementer / soak_is_gatekeeper). The two-cell (MACHDEBUGDEBUG→twq / MACHDEBUG→pool) + cell-3 (DISABLE_KWQ→pool) boot proof IS op-234 — already dispatched. **op-227 retires when op-234 reports green.**

## CONTEXT (read first)
Open-source OS engineering — OUR OWN libdispatch/libthr on the FreeBSD-hosted Mach compat layer. Not security work.

## WHY (one line)
op-223 finding #3 / QUALITY caveat 2: libthr's `_pthread_workqueue_supported()` returns a **constant** (`thr_workq.c:196-201`) advertising FINEPRIO with no kernel probe, and when THRWORKQ is absent the kernel returns ENOSYS and dispatch **silently** falls back to the userland pthread pool. So a concurrency green can't say which engine it rode. This is the **do-regardless hygiene half** of N2 (op-223 N2 disposition (b) / li-9003 Item 2 (b)) — independent of the accept-the-pool decision; it makes engine identity *visible* so every future green is attributable.

## SCOPE (two small, targeted changes)
1. **Honest probe.** Replace the constant `twq_supported_features` (`lib/libthr/thread/thr_workq.c:196-201`) with an actual kernel probe (attempt `TWQ_OP_INIT` / detect `sys_twq_kernreturn` availability) so `_pthread_workqueue_supported()` reflects the *running* kernel, not a compile-time constant.
2. **Loud banner.** At dispatch root-queue init (`lib/libdispatch/src/queue.c` `_dispatch_root_queues_init`, ~:873) emit a one-time log — via the proper log facility, NOT raw printf — naming the engine actually bound (real twq kernel workqueue vs userland pthread pool). Remove the silent-only fallback (`assume_zero`-only at ~:782).

## NON-SCOPE (explicit — do not drift)
- Does **NOT** decide whether the pool is acceptable for preview → that is op-225 **C2** (Coordinator).
- Does **NOT** force THRWORKQ into the harness/evidence kernel conf → that is **M2**.
- The engine-selection MECHANISM is unchanged; only its *honesty + visibility* changes.

## DELIVERABLE
Built libthr + libdispatch where the engine is probed (not asserted) and logged at init. Proof: on MACHDEBUGDEBUG the banner reads "twq kernel"; on MACHDEBUG it reads "pthread pool" — a visible swap, never a silent one.

## BOUNDARIES
- Implementer **builds**; does not soak/adjudicate its own change (Gatekeeper/Validators gate — the banner then feeds op-226's regime label).
- **Diff vs stock first** — this is our libthr/libdispatch, not base infra (userland-port-no-buildinfra-changes).
- The banner is a deliberate, kept engine-identity init log — not debug scaffold; keep it minimal and behind the normal log facility (never a committed printf/dprintf).

## RELATIONS
op-223 N2 / #3 (source); li-9003 Item 2 disposition (b) (the do-regardless engine-provenance discipline); op-225 C2(ii) (this is the small patch C2(ii) would require — authored early because it is hygiene, not contingent on the pool-acceptance call); li-1013 Item 1 (M1 per-run engine evidence leans on this banner); op-226 (consumes the banner as regime evidence). feedback: build_is_implementer, verify-premise-before-mechanism, userland-port-no-buildinfra-changes, dtrace_first_debugging (banner = kept init log, not debug printf).
