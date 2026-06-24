# id-017 — buildworld iteration speed: skip in-tree LLVM/clang bootstrap for dev-iteration builds

- id: id-017
- state: **WAITING (pending — deferred by Coordinator 2026-06-23).** Explicitly NOT now: while the
  clean build is still being *substantiated* (id-014/op-111), we compile everything from scratch —
  we don't want a toolchain optimization introducing a confounding variable. Revisit once the clean
  build is proven and we're iterating frequently enough that the LLVM compile cost hurts.
- raised: 2026-06-23 — observed during op-111 retry: a clean `buildworld` spends most of its wall
  time in stage-3 cross-tools compiling in-tree LLVM/clang (~2,600+ `.o`, all cores saturated),
  before any rmxOS-specific work (includes / Darwin overlay / `mach.ko` / kernel) even starts.
- roadmap parent: [roadmap.md](../roadmap.md) — **Gate F** (build pipeline). Pure build-efficiency;
  no product semantics.
- relations: **id-012** (Gate-F reproducibility — see the tension below); **id-014/op-111** (the
  build that surfaced the cost).

## The cost + the knobs

FreeBSD `buildworld` stage 3 bootstraps its own toolchain from in-tree source by default (clang +
lld), so the build is self-contained and host-toolchain-independent. That LLVM compile is the long
pole — most of the wall time — and is **stock upstream, unrelated to the rmxOS overlay**. The thing
we actually iterate on (overlay/kernel/includes) comes *after* clang links and is comparatively
fast. Knobs to skip it (the build host is FreeBSD 15 with a compatible base clang/lld):
- `WITHOUT_CLANG_BOOTSTRAP=yes` + `WITHOUT_LLD_BOOTSTRAP=yes` in `src.conf` → use the host base
  toolchain (biggest win).
- external/packaged toolchain: `pkg install llvmNN` + `CROSS_TOOLCHAIN=llvmNN` → prebuilt, no compile.
- preserve the cross-tools obj across retries → only the first build pays the LLVM cost.

## The tension (why this is deferred, not declined)

Two modes, and the right one differs by purpose:
- **Canonical Gate-F reproducibility** *wants* the in-tree toolchain bootstrap — "a third party
  builds from a clean checkout" is more honestly reproducible when it doesn't lean on the host's
  clang version. So the canonical Gate-F truly-green build should keep building the toolchain.
- **Dev iteration** (expected: many retries while clearing build walls) does NOT want to recompile
  LLVM every retry — the de-risk target is the overlay/kernel, not LLVM.

So when fetched, this is **not** "always skip LLVM" — it's "skip for iteration builds, keep one
canonical from-scratch toolchain build for the Gate-F record." Short-term decision (2026-06-23):
**compile everything; don't optimize yet.**

## Truly-green criterion (if/when fetched)

- an iteration-mode build (host/packaged toolchain) produces a world+kernel functionally identical
  to the canonical from-scratch build for the rmxOS overlay/kernel surface, at a fraction of the
  wall time — with the canonical-toolchain build retained as the Gate-F reproducibility baseline.
