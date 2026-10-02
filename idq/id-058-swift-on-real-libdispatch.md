# id-058 — Swift on rmxOS would run its own libdispatch beside rmxOS's

- id: **id-058**
- state: **WAITING — starts after the Mach batch-1 proof (op-416 and its rerun); ownership of the Swift-side build to confirm**
- raised: **2026-10-02 by the Coordinator**
- parent: id-042; related: id-006 (libdispatch), id-047
- tracker: [swift-real-libdispatch.md](../swift-real-libdispatch.md)

## Problem

The Swift 6.4 toolchain ships its own corelibs `libdispatch.so` and `libBlocksRuntime.so`, and
`libswiftDispatch.so` links them. On rmxOS, Swift programs would run two dispatch runtimes per
process instead of rmxOS's `libdispatch.so.5`.

## Done when

The tracker's steps 0-3 hold: global-queue servicing verified, Swift's Dispatch and concurrency built
against rmxOS's libdispatch, a guest run with one libdispatch mapped, and a macOS comparison.
