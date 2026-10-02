# id-055 — No performance measurement of Mach IPC, dispatch or launchd; guests cannot use hardware counters

- id: **id-055**
- state: **WAITING — priority low (Instrumentation 3.0, after Instrumentation 2.0; Coordinator, 2026-10-01); needs bare metal**
- raised: **2026-10-01 by the Coordinator ("3.0 will be hwpmc")**
- parent: id-042; related: id-054
- strategy: [instrumentation-strategy.md](../instrumentation-strategy.md), Instrumentation 3.0

## Problem

Nothing measures how fast Mach IPC, libdispatch or launchd are, so neither regressions nor
pathologies (such as N1's timebase error, which changed launchd's respawn throttle) show up as
numbers. hwpmc(4) and hwt(4) are in base, but bhyve guests have no PMU: the vmm reports zeros
for the performance-monitoring CPUID leaf (`sys/amd64/vmm/x86.c:484-490`).

## Scope

1. **Bare metal:** rmxOS has to boot on real hardware, either this host (Xeon E5-2680 v4,
   Broadwell; hwpmc and Intel PT support it) or a dedicated machine. This is a Coordinator decision
   on hardware and containment.
2. **Benchmarks:** pmcstat counting and sampling for mach_msg round trips, port operations,
   dispatch queue throughput and launchd spawn. Flame graphs, a baseline per candidate, and a
   regression budget in CI.
3. **Tracing:** hwt(4) Intel PT traces for hangs and latency outliers. XRay (in base) for userland
   functions where PT is not available.
4. **macOS comparison:** the same benchmarks on mm4.

## Done when

Each candidate has a recorded performance baseline from bare metal, and CI flags a regression
beyond the budget.
