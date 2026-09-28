# id-047 — No sanitizer coverage of the Mach kernel code or the core userland

- id: **id-047**
- state: **WAITING — priority medium (Coordinator, 2026-09-28); not scheduled**
- raised: **2026-09-28 by the Coordinator, from the Arranger's workflow review**
- parent: id-042 (1.0-preview); related: id-046, id-048, id-013

## Problem

Nothing that runs today can catch memory-safety bugs in rmxOS's own code. The test kernel
(RMXOS-RELEASE, through MACHDEBUGDEBUG and `std.debug`) runs INVARIANTS, WITNESS and DEADLKRES,
but `mach.ko` is built as a standalone module with an empty `opt_global.h`, so its own assertions
are compiled out (id-046, build finding). No run has used a sanitizer kernel. No sanitizer build
exists for libdispatch, launchd, notifyd, asl or libxpc. op-389's defects (a NULL fileops call,
use after `fdrop`, an uninitialized port set, a NULL kmsg) are the kind these tools report on the
first run that reaches them.

## What stable/15 already provides

`options KASAN`, `KMSAN` and `KCSAN` (`sys/conf/options:247-250`); the amd64 configurations
`GENERIC-KASAN`, `GENERIC-KMSAN` and `GENERIC-KCSAN`; and `GENERIC-DEBUG`. Clang provides ASan,
UBSan and TSan for userland.

## Scope

1. Build `mach.ko` with its kernel's configuration (shared with id-046's build finding). Fix
   id-046 findings 1 and 11 first, since their assertions would then fire.
2. A test-image kernel profile: KASAN first (use after free, out of bounds), then KMSAN
   (uninitialized memory), then KCSAN (data races), each on top of the Mach debug profile.
3. Userland: ASan and UBSan builds of libdispatch, launchd, notifyd, asl and libxpc for test
   images; TSan for libdispatch where it is usable.
4. Run the existing Mach and dispatch regression slice, then the PID-1 cell, under each profile.

## Done when

A contained test image boots with Mach built under its kernel's options and a KASAN kernel, and
runs the Mach and dispatch slice. Each sanitizer report becomes an IDQ entry or a fix. The release
profile stays separate.

## Notes

Architecture correctness comes first (the Advisor round and id-046's pattern fixes). This entry
finds bugs; it does not decide design.
