# id-048 — No fuzzing of the Mach trap surface or the userland message parsers

- id: **id-048**
- state: **WAITING — priority medium (Coordinator, 2026-09-28); needs id-047 and a containment decision**
- raised: **2026-09-28 by the Coordinator, from the Arranger's workflow review**
- parent: id-042 (1.0-preview); related: id-047, id-046, id-013

## Problem

Nothing exercises the Mach kernel surface with generated input: the traps, the MIG subsystems,
port rights and port sets, `EVFILT_MACHPORT`, and fd transfer through Mach. op-389 found 14
defects in that surface by reading. Coverage-guided fuzzing finds this class continuously and
catches regressions. Userland code that decodes input from other processes is not fuzzed either:
launchd's MIG requests and plists, libxpc message deserialization, and notifyd and asl message
handling.

## What exists

stable/15 has kcov(4) (`kern/kern_kcov.c`, `options KCOV` and `COVERAGE`), the coverage source
syzkaller uses; syzkaller supports FreeBSD guests. Clang's libFuzzer covers userland decoders.

## Scope

1. syzkaller descriptions for the Mach traps and MIG calls (message send and receive, right
   operations, port sets, Mach kevents, fd transfer), run against the id-047 KASAN kernel in
   disposable bhyve guests on this host.
2. libFuzzer harnesses for the userland decoders, where they can be isolated from a running
   Mach kernel.
3. Every crash is reduced to a reproducer and becomes an IDQ entry or a fix. The corpus is kept.

## Blockers

- id-047: a sanitizer kernel and `mach.ko` built with its kernel's options.
- **Containment:** a syzkaller manager drives its guests over a network (ssh), and the current
  guest containment allows no network. Fuzzing needs its own decision: an isolated host-only
  network with no uplink, or a separate fuzzing host. It also needs a standing guest budget,
  since fuzzing boots many disposable guests.

## Done when

A campaign runs for an agreed period on the Mach surface with crashes triaged, and the userland
decoder harnesses run in the same way.
