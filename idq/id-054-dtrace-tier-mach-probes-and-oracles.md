# id-054 — Mach has no DTrace probes of its own, and its invariants are not assertions yet

- id: **id-054**
- state: **WAITING — priority low (Instrumentation 2.0, after Instrumentation 1.0; Coordinator, 2026-10-01)**
- raised: **2026-10-01 by the Coordinator ("2.0 will be DTrace")**
- parent: id-042; milestone: li-001 (Mach IPC invariants under load); related: id-013, id-047
- strategy: [instrumentation-strategy.md](../instrumentation-strategy.md), Instrumentation 2.0

## Problem

`sys/compat/mach` defines no SDT probes (no `SDT_PROVIDER` or `SDT_PROBE` in it at `2884304b`).
DTrace sees Mach only through fbt on function boundaries of a module built without CTF. li-001's
invariants (send and receive balance, port allocation and free balance, notifications delivered,
nothing stuck in a queue) are traced (op-099) but are not yet assertions that fail a run.

## Scope

1. **An SDT(9) provider `mach`:** probes for port life, right transfer, kmsg send and receive,
   notifications, and receive wakeups. Names follow XNU's where they exist.
2. **CTF for `mach.ko`:** this comes from building it with the kernel (id-047, op-396; `GENERIC`
   sets `WITH_CTF=1`).
3. **Invariant oracles in D:** run inside the guest beside the tests; a violated predicate fails
   the run (li-001's truly-green bar).
4. **Userland:** USDT in libdispatch beyond the timer probes (op-101), toward Apple's dispatch
   provider; job-state probes in launchd.
5. **More providers and fault injection:** kinst(4), lockstat and profile (guests have no PMU), and
   fail(9) points on Mach error paths for fault injection (id-013).
6. **Check DTrace itself:** run DTrace's own test suite (`WITH_DTRACE_TESTS`) once on rmxOS, and on
   mm4 run the same D scripts wherever the providers match.

## Done when

The Mach suite and the PID-1 cell run with the oracles active in CI, and a deliberately broken
invariant fails the run.
