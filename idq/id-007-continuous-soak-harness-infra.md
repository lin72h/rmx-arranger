# id-007 — continuous-soak harness infra (long-bhyve + continuous DTrace)

- id: id-007
- state: **RETIRED** (op-104 proof passed 2026-06-23, serial sha a8228218…). The capability gap
  surfaced when op-102 deliverable 3 could not run the 2h soak (bounded ~180s run pattern only).
  op-104 built + proved it. op-105 (the actual 2h soak + port-balance iteration-delta) wakes.
- raised: 2026-06-23 (op-102 soak deliverable; referenced by op-104 at dispatch)
- roadmap parent: [roadmap.md](../roadmap.md) — **Gate D prerequisite.** Reusable across every
  soak (libdispatch, notifyd, asl, integration), so it earns its own line, not burial in op-102.

## The gap

The standard run harness is a bounded one-shot (~180s). Gate D (integration soak) and the
op-102/id-006 libdispatch soak need a guest that **boots and loops the harness for hours** with
the invariant-oracle DTrace scripts **attached continuously** (aggregations surviving to END,
exit code captured).

## Scope (carried by op-104)

- a long-running bhyve boot the harness loops inside (not a bounded one-shot);
- continuous DTrace attach for the full duration (the 4 oracles
  msg/kmsg/queue/port-balance running the whole window);
- a soak driver (loop harness N iters / T seconds, oracles attached, one soak log + END deltas).

## Acceptance (op-104)

A short proof run (e.g. 120s) demonstrating: harness loops, dtrace stays attached, END fires
with deltas, exit propagates. Proves the infra before spending a full 2h. NO product edits.

## Status note

op-104 first pass: infra authored (commit f9ada96) but proof run failed on a corrupt re-used
image AND first-hand review found a latent `printf`/arithmetic-on-aggregations bug in the END
block (masked by the corruption). op-104 returned to the Explorer corrected.

**op-105 BLOCKED (2026-06-23) → id-009.** The 2h soak panicked on its *first* iteration — a real
kernel use-after-free (`ipc_mqueue_pset_receive` via `filt_machport`, DEADC0DE GPF). This is the
soak doing its job: a kernel crash under sustained dispatch load that op-104's 120s/451-iter proof
couldn't surface. op-105 cannot retire (`soak_fails=0` unmet) until id-009's kernel fix lands;
the existing oracle+driver are its regression harness. See id-009.

**Role split on the proving soak (corrected 2026-06-23).** The op-105 discovery soak was rightly
the **Explorer's** (it captured a behavior vector → the panic). But the *regression* soak that
proves the id-009 fix is the **Gatekeeper's**, not the Implementer's and not the Explorer's: the
oracle + bar are fixed, so the run is a disposition (admit/block op-105's retirement), which is
the Gatekeeper's defining function — not discovery. The Implementer (op-107) closes at fix +
bounded smoke-test and hands off; the 2h proving soak is a separate Gatekeeper op on
`rmx-gatekeeper-rx-x64z`. See id-009 §Scope.

**op-104 RETIRED (2026-06-23).** Proof: soak_iterations=451, soak_fails=0, soak_duration=120,
terminal status=0; tick-120s fired and printed all 4 invariant deltas (msg 1327/885, kmsg
2212/442, queue 1327/885, port 1328/1326 delta=2 — nonzero expected, op-105 refines). Fixes
verified first-hand in the committed files: aggregations → global int counters (2db58ac);
driver `rc=$?` captured before the `fails++` (2db58ac); tick-Ns self-terminate replacing
SIGINT+END, since FreeBSD dtrace can't build a probe name from a `-D` macro (175744d); and
`kldload profile` so the `tick-Ns` profile-provider probe actually fires (fa52f5f).

**Carry-forward into op-105** (first-hand caveats, not blockers):
- the tick period is **hardcoded** `tick-120s` in `soak-oracle.d`; the driver's `SOAK_DURATION`
  is a *separate* var. op-105 MUST regenerate the oracle to `tick-7200s` and keep
  `tick == SOAK_DURATION`, else the oracle exits early and silently under-covers the window.
- the `-DSOAK_SECONDS` flag on `soak-driver.sh:18` is now vestigial (oracle hardcodes the
  period) — harmless; clean up in op-105.
- port delta is end-balance only; op-105 owes the per-iteration steady-state delta (ports
  persist for queue/source lifetime, so simple end-balance can't distinguish a leak).
- **BRANCH DIVERGENCE — merge before op-105's push (do NOT force-push).** op-105's oracle commit
  `6f49516` was made on `fa52f5f`, *parallel* to op-103's pushed `6d02846` (origin/main) — same
  parent, forked. When op-105 lands, its push is non-fast-forward; **merge origin/main in**
  (repo-strategy = merge-based, never rebase/force-push). The two touch disjoint files (op-103:
  `macos-truth-*.json/.txt`; op-105: `soak-oracle-2h.d` + driver), so it should merge clean. A
  force-push here would silently drop op-103's truth record.
