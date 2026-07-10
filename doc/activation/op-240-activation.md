# op-240 — Implementer: fix the twq serial-queue drain-liveness defect — the handoff must not push `dq_running > dq_width` on a serial queue mid-drain (op-238's product-divergence requirement)

op-240 | role: **Implementer** (twq/libdispatch source dive + product fix) | EXU: **wip-gpt (Implementer seat)** | state: **[Done — PREMISE REFUTED, no product change; Arranger-verified first-hand 2026-07-02]** — the DTrace-confirm gate caught it: op-238's `dq_running>dq_width` mechanism did NOT fire; op-235 churn was a harness measurement artifact. No commit; alpha clean @ 106f9d7fd160. | parent: op-238 (DS4P (b) product-divergence, 9/10 — now REFUTED) → op-235 churn → op-231 D3 layer 1 | L1i: li-1002 (libdispatch hardening) / li-1001 (substrate invariant — serial-queue completion under load) | cost: 30 (code-reasoned dive + targeted DTrace confirm + product fix) | authored 2026-07-02 (Arranger seat, model Opus 4)

## OUTCOME (premise refuted — no product bug; Arranger-verified on 3 artifacts, 2026-07-02)
The Implementer ran op-238's scope task 1 (confirm the mechanism FIRST via DTrace before any fix) and **refuted the product-divergence hypothesis**. No product source changed — the verify-premise-before-mechanism gate did its job. Arranger-verified first-hand:
- **Harness source (rmx-gatekeeper `build/op235/op235-substrate.c` `run_churn`):** only the serial half is grouped — `dispatch_group_async_f(g, sq, …)` at :102 — while the global half `dispatch_async_f(gq, …)` at :103 is **ungrouped**. `dispatch_group_wait(g)` at :109 therefore waits on only 500 of the 1000 `expected = iters*2` (:114) callbacks; `completed` counts BOTH halves. So the count returns in [500,1000] by timing — precisely the 517/576/1000 variance. **Arranger-confirmed at source.**
- **Counts log (`build/op240-twq-serial/…counts.serial.log`):** `group_leave=500` on EVERY run (incl. `completed=576`) → the serial half always completes 500/500 and never strands work. **Arranger-confirmed first-hand.**
- **DTrace guard (`…dtrace.serial.log`):** `OP240_SERIAL_OVERRUN` count = **0** across all runs → the `dq_running > dq_width` guard never fired. DS4P's mechanism did not occur. **Arranger-confirmed first-hand.**

**Verdict:** op-235's churn 517/1000 is a **harness measurement artifact** (only half the work is grouped, `dispatch_group_wait` returns before the ungrouped global half runs), NOT dropped work and NOT a product defect. Both prior mechanisms were wrong: op-235-Gatekeeper's "premature `dispatch_release(sq)`" and op-238-DS4P's "`dq_running>dq_width` serial strand." No commit; `wip-rmxos` clean @ `106f9d7fd160`.

**Next-hop:** correct the harness (group the global half too, or explicitly wait for it) + re-run churn — re-scoped into op-239 (Gatekeeper). If the corrected harness STILL drops work, reopen the product investigation with the cleaner signal.

## CONTEXT (read first)
Open-source OS engineering — fix a serial-queue drain-liveness defect in our libdispatch/twq engine. Not security work; our own compat-Mach + libdispatch source. This op confirms the mechanism at source + trace, then fixes it, builds `mach.ko` (twq lives kernel-side) + libdispatch, and hands to a Validator kernel-semantics gate + a Gatekeeper acceptance re-run.

## WHY (one line)
op-238 (DS4P 9/10, Arranger provenance-checked) proved op-235's churn dropped-work (517/1000 on a serial queue) is a **product divergence, not a harness bug**: the harness idiom is Apple-conformant (submission retains the target queue, `queue.c:3199`), but `5675145`'s handoff change (`twq_pick_bucket_locked` replacing `twq_pick_pending_bucket_locked`) can spawn a second worker for a serial queue that already has an active drain → `dq_running > dq_width` (1) → the draining worker bails at the overcommit guard (`queue.c:3545`) and items in `dq_items_tail` are stranded. `5675145` correctly fixed #19 (grant overcount) for CONCURRENT queues; this is its serial-queue side-effect.

## SCOPE (confirm → fix → build; Implementer product-write)
1. **Confirm the mechanism first (`verify-premise-before-mechanism`, dtrace_first_debugging).** Reproduce op-235's churn (serial-queue create/async/release, work hops sq→global, 500 iters) on the twq cell and DTrace `dq_running` vs `dq_width` at the drain guard (`queue.c:3545`) + the twq spawn decision (`twq_pick_bucket_locked` / `twq_addthreads_common` `thr_workq.c:1090-1155`). Show the `dq_running==2`-on-a-serial-queue strand event first-hand — do not fix from op-238's reasoning alone (it is code-reasoned, 9/10, not yet trace-confirmed).
2. **Fix so the handoff never lets `dq_running` exceed `dq_width` on a serial queue mid-drain.** DS4P's two candidate shapes (choose per the trace, minimal-diff, do NOT restructure the engine): (a) keep the SAME worker draining a serial queue across handoff (restore the relevant `twq_pick_pending_bucket_locked` invariant without reintroducing the #19 grant overcount `5675145` fixed), or (b) make the spawn/grant path in `twq_addthreads_common` not grant a new worker for a serial queue that already has `dq_running >= dq_width`. Preserve the `5675145` grant clamp for concurrent queues (op-233-confirmed) — the fix must not regress fan_out/chain.
3. **Build** `mach.ko` (standalone module: `make -C sys/modules/mach`, MAKEOBJDIRPREFIX only, NOT buildkernel) + libdispatch. Record built shas. Diff-vs-stock discipline.

## NON-SCOPE
- Does NOT touch the `5675145` concurrent-fan-out grant clamp except as needed to scope the serial-queue case (must not regress op-235 fan_out/chain).
- Does NOT self-adjudicate the kernel semantics (Validator gate, Rule 11 — twq handoff = L/XL) or self-run the acceptance soak (Gatekeeper, op-239).
- Does NOT address sub-fix #2 (#21 MACH_RECV, separate, still open) or churn cells 1&3/macOS self-check (op-239).

## DELIVERABLE
(1) A trace artifact confirming (or refuting) the `dq_running > dq_width` serial-queue strand mechanism; (2) if confirmed, a minimal fix to the twq handoff/grant path with built `mach.ko` + libdispatch shas, handed to a Validator for the kernel-semantics gate (confidence 1-10; Arranger steps in <9), then to op-239 (Gatekeeper) as the empirical acceptance re-run (churn must complete 1000/1000 across runs, fan_out/chain must not regress). If the trace REFUTES the mechanism, report that with the trace — op-238's verdict is code-reasoned, and a refutation reopens the churn root-cause.

## BOUNDARIES
- **build_is_implementer**; Implementer builds + reasons + traces, does not self-gate semantics or self-soak.
- **mach.ko standalone module build** (twq is kernel-side); no KERNBUILDDIR fold.
- **Diff vs stock / minimal adaptation** — our compat-Mach + libdispatch; fix the liveness bug, do not restructure the engine.
- Stage only in the Implementer's own tree (agent_host_isolation).
- `no_conflate_gating_with_readiness` — this defect's preview-severity (serial queues are pervasive in the core services notifyd/asld → possible li-1007 soak exposure) is a **Coordinator** call; flag it, do not self-declare a gate.

## RELATIONS
op-238 (the requirement — DS4P (b) 9/10) → op-235 churn → op-231 D3 layer 1. `5675145df333` (the handoff change that introduced this) / op-233 [Done 9/10] (its grant mechanics, must not regress). op-239 **[Held — Gatekeeper churn re-run, now gated on THIS fix]** (acceptance: churn 1000/1000 + fan_out/chain no-regress + cells 1&3 + macOS-27 self-check). li-1002 (libdispatch hardening); li-1001 (serial-queue completion-under-load substrate invariant); li-1013 (leftover punch-list — cataloged); li-1013 Item 1 / op-225 C2 (pool-arm evidence — op-239 supplies). feedback: verify-premise-before-mechanism, dtrace_first_debugging, build_is_implementer, verify_signature_divergence_claims, no_conflate_gating_with_readiness, mach_ko standalone module build, op_state_dispatch_boundary (authored [Awaiting]).
