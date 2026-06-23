# testing-dtrace — DTrace-first observability ("observe, don't perturb")

- tier: **shared baseline** (all roles)
- state: **ACTIVE** (adopted 2026-06-22)
- index: [testing.md](testing.md). Verify file:line and guest capability before acting.

## The rule

**Prefer DTrace (FreeBSD's tracing infrastructure) over hand-added `printf`/`dprintf`
instrumentation for diagnosing runtime behavior.** Do not commit ad-hoc debug prints into
product source. Observation should not require editing — least of all editing the code under
investigation.

## Why (verified, from op-093)

The op-093 `dispatch_after` debugging used hand-added `dprintf(2, "OP093_T …")` lines in
`lib/libdispatch/src/source.c`. That approach is costly, and in this case actively
counterproductive:

1. **It reinvents probes that already exist.** libdispatch ships a DTrace USDT provider —
   `lib/libdispatch/src/provider.d` defines the `dispatch` provider with `queue-push`/`-pop`,
   `callout-entry`/`-return`, and **timer probes** (`DISPATCH_TIMER_CONFIGURE`,
   `DISPATCH_TIMER_PROGRAM`, timer-fire), wired via `trace.h`'s `_dispatch_trace_timer_*`
   behind `DISPATCH_USE_DTRACE`. The WIP `dprintf` at `_dispatch_timers_run2` sits one line
   from the existing `_dispatch_trace_timer_fire` probe.
2. **Recompile + redeploy per iteration** — the slow loop ("hours").
3. **Must be stripped before commit** — diff pollution + risk of shipping debug code.
4. **Heisenberg on timing bugs.** `dprintf(2,…)` is a synchronous, lock-taking write to fd 2;
   for a timing/race bug (op-093 is a manager-bootstrap race) it can mask or shift the very
   race being chased. DTrace probe overhead is far lower and less perturbing.
5. **It edits the core to observe it** — the opposite of the Mach-IPC RESTRICTED doctrine
   ("don't touch the foundation"). DTrace is observation-only: zero product change, no approval
   gate tripped, and it lets us inspect the timer/IPC core *without editing it*.

## Tooling, in order of preference

1. **Built-in USDT** — build the DTrace/introspection variant (`-DDISPATCH_USE_DTRACE=1`); the
   semantic `dispatch:::timer-*` / `queue-*` / `callout-*` probes light up with no source
   edits. Use first when a subsystem already defines a provider (libdispatch does).
2. **`pid` provider** — ad-hoc function entry/return/args/timestamps on any function
   (`_dispatch_source_set_timer2`, `_dispatch_kq_update`, `_dispatch_mgr_timer_timeout_fire`)
   with **no recompile and no source edit**. The default for "where does control actually go".
3. **Kernel probes** — `syscall::kevent*`, `fbt::*kqueue*`/timer/callout. Correlate userland
   arming with kernel submission + fire in **one script** to settle boundary questions
   definitively — e.g. op-093's open (a) *never-submitted* vs (b) *submitted-but-not-processed*.

## The fuller toolbox — USDT is one provider of many

The 3-tier order above is the *common* path, not the limit. **USDT is only one DTrace
provider, and the least important for our goals.** A subsystem with no built-in instrumentation
is still fully observable — verified 2026-06-22: libdispatch ships Apple's USDT provider, but
**libnotify / libasl / libxpc / notifyd / asl have none** (no `.d`, no `DTRACE_PROBE`, no
signpost/firehose — the modern Apple firehose mechanism belongs to the apple-oss lineage we
rejected). That lack barely costs us, because the strong techniques don't need the target
pre-instrumented:

**Recover/extend visibility (no source edit, no rebuild):**
- **`pid`** — entry/return/args/return-values on *any* userland function; recovers most of what
  a hand-authored USDT provider would give. The default lens for an uninstrumented consumer.
- **`syscall`** — every kernel boundary the consumer crosses (Mach traps, kqueue, `_umtx_op`).
- **`sched` (off-cpu)** — `sched:::off-cpu` + blocking stack tells you *why* a thread blocked and
  for how long: deadlocks, a Mach receive that never wakes, priority inversion. Gold for the IPC path.
- **`profile`** — timer-sampled stacks (`profile-997`) for "where is it spending time / hung".
- **`proc`** — process/thread/signal lifecycle (crashes, unexpected signals, spawn races).
- **`lockstat`/`plockstat`** — lock contention; `libthr` already ships `plockstat.d`, so pthread
  contention in consumers is observable today (useful for the concurrency-hardening rungs).

**Higher-value techniques (provider-agnostic — stronger than USDT-watching):**
- **DTrace as a *test oracle*, not just a tracer.** Express invariants as predicates and let a
  test *fail* on violation: `mach_msg_send` vs `_receive` balanced (no leaked messages),
  `ipc_port` alloc vs dealloc balanced (no port-right leak), every `queue-push` matched by a
  `callout-entry` (no stuck work). The probe *becomes the assertion* — a far stronger bar than
  exit-code 0.
- **Cross-layer correlation in one script** — `pid` (consumer) + libdispatch USDT + kernel `fbt`
  (mach-ipc) + `syscall`, shared aggregations, one trace → end-to-end causality without any
  subsystem needing its own USDT (the op-094/op-098 pattern).
- **Aggregations as quantitative parity metrics** — `@quantize(latency)`, `@count` turn a soak
  run into hard numbers (mach_msg round-trip p50/p99 rmxOS vs macOS), feeding the macOS-as-truth
  parity loop with *measurements*, not pass/fail.
- **Fault injection** — `chill()`/`stop()` at a probe to inject delay and *provoke* IPC races
  (teardown, dead-name) instead of waiting for them. **Destructive — test-guest only.**

## When suitable (and when not)

"Make good use of DTrace **when suitable**" — it is not a universal hammer:
- It **complements** functional tests, it does not replace them — observation/perturbation, not
  a correctness oracle by itself (except the explicit invariant-oracle pattern above).
- **Confirm provider availability first-hand on the guest** — `KDTRACE_HOOKS`/`fbt`/`pid` are
  proven, but `sched`/`profile`/`lockstat` availability is *verified, not assumed* (load
  providers individually; see enablement doc).
- **Destructive actions** (`chill`/`stop`/`raise`/`copyout`) are **test-guest only**, never near
  shared state.
- Reach for the lightest tool that answers the question: `pid`/USDT before `fbt`, a targeted
  probe before a fault-injection campaign. Don't instrument what a one-line predicate settles.

## Precondition — verify, don't assume

DTrace needs kernel support in the **rmxOS guest**:
- `options KDTRACE_HOOKS` (+ `KDTRACE_FRAME` for `fbt` stack walks) compiled into the test
  kernel; the dtrace provider modules built + staged; userland `pid`/USDT also need the
  framework loaded.
- The custom Mach kernel may not be built with DTrace hooks — **check on the guest before
  mandating a DTrace-based op**. If absent: enable it in the test kernel, or fall back to
  USDT-only / a single targeted print for that one case.

### Guest state — see the enablement doc

Verified guest state (hooks present; modules built/staged once; `dtraceall` fails on unbuilt
`kinst`/`systrace_freebsd32` → load providers individually), the build/stage recipe, the
on-guest proof (op-094), and the standing continue/enforce decision live in the companion
[testing-dtrace-enablement.md](testing-dtrace-enablement.md).

## Legitimate exceptions (when a print is still right)

- Very-early bring-up paths that run **before** the dtrace framework is up.
- Kernel paths before DTrace init.
- A value no probe exposes, where a one-off print is genuinely cheaper than a custom USDT
  probe — but then add a *real* USDT probe if it'll be needed again, don't leave the print.

In all cases: a debug print is **throwaway** — it never lands in a committed artifact.

## Immediate application (op-093)

Build `DISPATCH_USE_DTRACE=1`; use the existing `dispatch:::timer-*` probes + a `pid`/kernel
script to pin (a)/(b); **remove the `OP093_T` dprintfs entirely** rather than stripping them
later — contingent on the guest KDTRACE_HOOKS check above.
