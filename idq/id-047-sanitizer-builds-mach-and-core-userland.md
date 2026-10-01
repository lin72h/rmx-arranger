# id-047 — No sanitizer coverage of the Mach kernel code or the core userland

- id: **id-047**
- state: **IN WORK → op-396 (returned; under review in op-397)** (Coordinator started Testing 1.0, 2026-10-01)
- raised: **2026-09-28 by the Coordinator, from the Arranger's workflow review**
- parent: id-042 (1.0-preview); related: id-046, id-048, id-053, id-013
- strategy: [testing-strategy.md](../testing-strategy.md), Testing 1.0

## Problem

Nothing that runs today can catch memory-safety bugs in rmxOS's own code. The test kernel
(RMXOS-RELEASE, through MACHDEBUGDEBUG and `std.debug`) runs INVARIANTS, WITNESS and DEADLKRES.
But `mach.ko` is built as a standalone module with empty option headers, so:
- its 507 assertions are compiled out (id-046, build finding);
- so is its `CAPABILITIES` code, which skips the kernel's `fde_seqc` protocol (id-046, op-392 §3,
  checked first-hand 2026-10-01);
- INVARIANTS-only behaviour differs from what a kernel-built module would do (id-046 A1).

No run has used a sanitizer kernel. No sanitizer build exists for libdispatch, launchd, notifyd,
asl or libxpc. op-389's defects (a NULL fileops call, use after `fdrop`, an uninitialized port set,
a NULL kmsg) are the kind these tools report on the first run that reaches them.

## What stable/15 already provides

- **Kernel:** `options KASAN`, `KMSAN`, `KCSAN`, `KUBSAN`, `COVERAGE` and `KCOV`
  (`sys/conf/options:246-251`); the amd64 configurations `GENERIC-KASAN`, `GENERIC-KMSAN` and
  `GENERIC-KCSAN`, each `GENERIC-DEBUG` plus one option.
- **Flags:** the compiler flags for the kernel and for every module built with it
  (`sys/conf/kern.mk:259-331`, `kmod.mk:429-432`).
- **Run controls:** `debug.kasan.panic_on_violation`, `debug.kmsan.panic_on_violation` and
  `debug.kassert.warn_only`.
- **Userland:** `WITH_ASAN` and `WITH_UBSAN`; clang's runtimes are built in base. Full inventory in
  testing-strategy.md.

## Scope

1. Build `mach.ko` with its kernel, through `sys/modules/Makefile` (op-396).
2. Kernel profiles in `GENERIC-KASAN`'s form on top of `RMXOS-RELEASE`: P1 KASAN, P2 KMSAN (guests
   of 8 GiB or more), P3 KCSAN, and P4 KUBSAN as a trial (op-396 builds them).
3. Run them through the Gatekeeper's CI, in two modes:
   - **Survey:** report-only and `debug.kassert.warn_only=1`, collecting every report in one boot.
   - **Gate:** panic on the first report.

   Survey mode replaces this entry's earlier precondition, "fix op-389 #1 and #11 first": their
   assertions now log instead of stopping the run.
4. Suites: the Mach ATF suite (op-395), the Mach and dispatch slice (op-372), the PID-1 cell, and
   FreeBSD's kern, file and kqueue tests with `mach.ko` loaded.
5. Userland (U1): `WITH_ASAN` and `WITH_UBSAN` builds of libmach, libdispatch, libxpc, libnotify,
   libasl, launchd, notifyd, asl and their tests. TSan on the libdispatch tests as a trial.
6. Reports are grouped by stack. Mach frames become an id-046 row or a new IDQ entry; FreeBSD
   frames become upstream candidates.

## Ops

- op-396 (Implementer, returned 2026-10-01): branch `testing-1` (`42d1fdbf`, `7ccf16fa`), five
  profiles built (KUBSAN built too) and staged as
  `/Users/me/wip-mach/stage/images/op396-RMXOS-{RELEASE,KASAN,KMSAN,KCSAN,KUBSAN-final}.raw`.
  The Arranger checked the commits, flags, instrumentation, image hashes, BOMs and `loader.conf`
  first-hand. One correction: only `knote_enqueue` resolves through leak-locals (id-045).
- op-397 (validator2, issued 2026-10-01): the review of op-396.
- `testing-1` is on the public rmxOS origin at `7ccf16fa` (pushed with the Coordinator's yes,
  2026-10-01). `rmx-implementer@9d718966` is pushed when op-396 closes.
- Next, drafted once op-396 and op-398 have both closed: Gatekeeper, P0 and P1 in survey mode and
  then gate mode on the op-396 images, together with id-053's panic capture.

## Done when

A contained image boots with `mach.ko` built under its kernel's options on a KASAN kernel and runs
the Mach and dispatch slice in gate mode. P0 and P1 run for every candidate in CI, and the other
profiles once per milestone. Each report has become an IDQ entry or a fix. The release profile stays
separate.

## Notes

Sanitizers find bugs; they do not decide design (Coordinator, 2026-09-28). The Mach round's order
holds: classes A to D are designed before fixes land in those areas.
