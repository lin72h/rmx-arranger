# id-013 — chaos-testing: add fault-injection to the testing strategy (future)

- id: id-013
- state: **WAITING (future)** — not blocking 1.0. soak-testing (the endurance tier) is proven and
  carries li-001/D today (op-108). chaos-testing is an **additive hardening discipline** layered on
  later; fetch when the Coordinator decides to invest. No precondition beyond the soak rig existing
  (it does — id-006/id-007), which chaos-testing extends.
- raised: 2026-06-23 (Coordinator: "okay to use soak-testing and future add chaos-testing to our
  full testing strategy")
- roadmap parent: [roadmap.md](../roadmap.md) — hardening of **li-001** (mach-ipc invariants) and
  **li-004** (integration soak). Sharpens those gates from "survives natural churn" to "survives
  *injected* adversity"; not a new gate.
- term: defined in [terminology.md](../terminology.md) §8 — soak-testing (have) vs chaos-testing
  (this, future). **Distinct test type, not a soak rename.**
- relations: **id-006/id-007** (the soak rig + oracles this extends — reuse the DTrace invariant
  oracles as the pass/fail judge); **id-009** (the UAF soak-testing caught by *luck of timing* over
  2h — chaos-testing would have forced it deterministically in seconds: the motivating example).

## Why add it (the id-009 lesson)

soak-testing found the id-009 UAF, but only because the natural create/destroy timing *eventually*
collided — op-105 happened to hit iteration 1, op-104's 120s run never did. That is luck. The defect
was a precise window: pset lock dropped, then `ip_lock(port)` on a port a concurrent teardown frees.
chaos-testing **forces** that window — inject a port free exactly during the lock-drop — so the race
is provoked deterministically in seconds instead of waited-for over hours. It converts "we ran long
enough to get unlucky" into "we caused the exact adversity on purpose." Stronger evidence, faster.

## Scope (when promoted) — candidate injectors, all DTrace-first / in-tree

**In (the fault-injection toolkit, built on existing substrate):**
1. **`KFAIL_POINT` injection points** — FreeBSD's kernel fault-injection framework is present
   (`sys/sys/fail.h` + `sys/kern/kern_fail.c`) but **placed nowhere** (0 usages in `sys/`). Place
   fail points at the mach-ipc serialization windows (e.g. force a delay/yield at the
   `ips_unlock`→`ip_lock` gap in `ipc_mqueue_pset_receive`), `debug.fail_point.*` sysctl-tunable —
   so a regression test can *open the window* on demand. **This is a product-source change**
   (compat/mach) → Coordinator-owned, careful blast radius, isolated/guarded so it is no-op unless
   the sysctl is armed.
2. **DTrace destructive timing perturbation** — `chill()`/`raise()`/`stop()` (fasttrap, in-tree) to
   widen race windows from the *probe* side with **zero product-source change** (preferred first
   step — consistent with DTrace-first + observation-only). Cheaper than KFAIL_POINT; try first.
3. **Resource adversity** — memory pressure, port-table near-exhaustion, scheduler perturbation
   (per-QoS `rtprio` churn — ties to id-008), randomized syscall delay/failure — to stress
   allocation/teardown paths under scarcity.
4. **Oracle reuse** — the same soak invariant oracles (msg/kmsg/queue/port balance, flat slope, no
   panic) judge the injected runs. The injector changes; the pass bar does not.

**Out:** the soak rig itself (have — id-006/007); product *correctness* fixes (chaos-testing
*finds*, the Implementer *fixes* in its own op); any injector left armed in a shipping build
(injection must be debug/sysctl-gated, off by default — never in the dev-preview/1.0 image path).

## Role fit (mirrors the soak split — terminology §1, feedback on soak ownership)

- **Explorer** authors the injectors + the chaos scenario (discovery: "what adversity exposes what")
  and captures the behavior vector when a new injector surfaces a defect.
- **Gatekeeper** runs a *fixed-bar* chaos scenario as a regression gate (injector + oracle + bar
  fixed = a disposition), same as the soak proving gate.
- **Implementer** never proves its own fix via chaos it authored.

## Truly-green criterion (what "chaos-testing in the strategy" must mean)

- at least one injector deterministically reproduces a *known* window (validate against id-009:
  arm the injection, watch the unfixed kernel fault in seconds, the fixed kernel hold) — proving the
  injector actually forces the condition, not just adds noise;
- injectors are debug/sysctl-gated, off by default, provably absent from the shipping image path;
- the soak invariant oracles pass under injection on the fixed kernel — adversity caused, invariants
  still held.

## Open decisions (Coordinator-held, at fetch)
- priority: post-1.0 hardening, or pull in earlier as a regression-strength multiplier on the
  kernel-race class (id-009-like defects)?
- first injector: DTrace destructive (zero source change, cheapest) vs KFAIL_POINT (deterministic,
  but product-source touch) — recommend DTrace-destructive first to prove the concept, KFAIL_POINT
  second for the deterministic regression gate.
- scope of "adversity": concurrency-timing only (the id-009 class), or include resource scarcity +
  scheduler perturbation in the first cut?
