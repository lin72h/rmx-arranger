# Swift on rmxOS's real libdispatch — tracker

Status: living tracker, opened 2026-10-02 (Coordinator). IDQ: [id-058](idq/id-058-swift-on-real-libdispatch.md).
Background and the June design: [swift-rmxos-integration-plan.md](swift-rmxos-integration-plan.md)
(Lane B1, § Restart). Update this file whenever a step changes state; the journal records the why.

## Goal

A Swift program on rmxOS uses **one** libdispatch: rmxOS's Apple-derived `/usr/lib/libdispatch.so.5`
(with `libBlocksRuntime.so.0`), the same one libxpc, launchd and notifyd use. Swift's `Dispatch`
module and Swift concurrency (`async`/`await`, `Task`) both run on it, as on macOS.

## Why it matters

The Swift 6.4 toolchain (`/usr/local/swift`, swift-rx lane) ships its own swift-corelibs
`libdispatch.so` (soname `libdispatch.so`, `RUNPATH $ORIGIN`) and `libBlocksRuntime.so`, and
`libswiftDispatch.so` links both (checked with `readelf -d`, 2026-10-02). On rmxOS a Swift program
would run two dispatch runtimes in one process: two main queues, two thread pools, and Swift never
reaching the Mach and workqueue behaviour rmxOS provides. Swift on macOS has one.

## What we already know (June 2026 exchange rounds)

- **Link level is satisfied.** On a non-Apple ELF platform the Swift concurrency runtime uses only
  classic `dispatch.h` (its fallback executor calls `dispatch_async_f` on global queues). rmxOS's
  libdispatch exports that whole set (`dispatch_async_f`, `dispatch_after_f`, `_dispatch_main_q`,
  `dispatch_queue_attr_make_with_qos_class`, `dispatch_source_create`, …). No executor port is
  needed for v1. `swift_task_enqueueGlobal*` hooks are Swift runtime override points, not libdispatch
  symbols.
- **Behaviour was the risk.** In June the libdispatch workqueue aborted unless
  `LIBDISPATCH_DISABLE_KWQ=1` (a pending-count underflow in `src/queue.c`), and the MACH_RECV source
  stayed dark. Swift's executor puts all its work on global queues, so it depends on exactly that
  path. op-372 (2026-09-28) later passed the dispatch slice 4/4, but workqueue attribution was not
  tested.
- **Not v1:** the cooperative pool and swift-job hooks (true macOS-style concurrency scheduling and
  QoS). That is a later fidelity milestone.

## Steps

| # | Step | Owner | Status |
|---|---|---|---|
| 0 | **Prerequisite:** global-queue servicing works on rmxOS without `LIBDISPATCH_DISABLE_KWQ`: many `dispatch_async_f` jobs on global queues complete under load, and the workqueue really runs them (attribution checked, for example with DTrace on the kernel workqueue). | rmxOS Gatekeeper | not started; after the Mach batch-1 proof |
| 1 | **Build against rmxOS:** `libswiftDispatch` and `libswift_Concurrency` built against rmxOS's dispatch headers and `libdispatch.so.5` and `libBlocksRuntime.so.0`. The corelibs libdispatch and BlocksRuntime are not installed on rmxOS. A list of every symbol or header the Swift overlay needs that rmxOS lacks or spells differently. | swift-rx implementer (ownership to confirm) | not started |
| 2 | **Run in a contained rmxOS guest:** a Swift program using Dispatch queues, a `DispatchSource` on a Mach port, and Swift concurrency (`async`/`await`, `Task`, task groups). `procstat -v` shows only `/usr/lib/libdispatch.so.5` mapped; the Mach-port source fires. | rmxOS Gatekeeper | not started |
| 3 | **Compare with macOS:** the same program's observable behaviour on mm4. | Explorer (explorer2 on mm4) | not started |
| 4 | **Findings feed the libdispatch review:** every failure becomes an IDQ row or a libdispatch fix candidate; nothing is patched around in Swift. | Arranger | — |

## Rules

- One libdispatch per process is the acceptance bar. A program that maps both copies is a failure,
  even if it works.
- Fix behaviour in rmxOS's libdispatch, not by bundling or wrapping in the Swift toolchain.
- Swift-side tests follow the test-pillar doctrine (swift-testing for Swift behaviour); the guest
  check uses our Gatekeeper's runner.
- Brief wording follows [safety-flag-avoidance.md](safety-flag-avoidance.md).

## Open questions

1. Who directs the swift-rx agents (`/Users/me/wip-rnx/swift-rx-{implementer,explorer,gatekeeper}`):
   their own Arranger, with this file as the rmxOS-side contract, or this Arranger?
2. Which toolchain target: the swift-rx `swift64` port (x86-64-v3, assertions on) or FreeBSD's
   `lang/swift6` 6.4.0 layout? The swift-rx comparison (2026-10-02) recommends keeping the RNX layout
   and testing the official one as well.
3. Does the Swift runtime belong in rmxOS's base (as `/usr/lib/swift`, the macOS way, Lane A1) for
   this step, or stay in `/usr/local/swift` until later?

## Log

- 2026-10-02: tracker opened; the two-libdispatch problem found; steps 0-4 defined (j-20261002-021).
