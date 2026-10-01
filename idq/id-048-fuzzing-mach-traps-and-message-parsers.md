# id-048 — No fuzzing of the Mach trap surface or the userland message parsers

- id: **id-048**
- state: **WAITING — priority medium (Coordinator, 2026-09-28); userland harnesses can start any time; the kernel side needs id-047 and a containment decision**
- raised: **2026-09-28 by the Coordinator, from the Arranger's workflow review**
- parent: id-042 (1.0-preview); related: id-047, id-046, id-013
- strategy: [testing-strategy.md](../testing-strategy.md), Testing 1.0 (fuzzing)

## Problem

Nothing exercises the Mach kernel surface with generated input: the traps, the MIG subsystems,
port rights and port sets, `EVFILT_MACHPORT`, and fd transfer through Mach. op-389 found 14
defects in that surface by reading. Coverage-guided fuzzing finds this class continuously and
catches regressions. Userland code that decodes input from other processes is not fuzzed either:
launchd's MIG requests and plists, libxpc message deserialization, and notifyd and asl message
handling.

## What exists

stable/15 has kcov(4) (`kern/kern_kcov.c`, `options KCOV` and `COVERAGE`), the coverage source
syzkaller uses; syzkaller supports FreeBSD guests. libFuzzer is built in base
(`lib/libclang_rt/Makefile`: fuzzer, fuzzer_no_main), so `cc -fsanitize=fuzzer,address` needs no
ports. XNU feeds its own fuzzers from kcov/ksancov (`xnu/san/coverage/`).

## Scope

1. syzkaller descriptions for the Mach traps and MIG calls (message send and receive, right
   operations, port sets, Mach kevents, fd transfer), run against the id-047 KASAN kernel in
   disposable bhyve guests on this host.
2. libFuzzer harnesses for the userland decoders, where they can be isolated from a running
   Mach kernel. They need no guest and no id-047 kernel, so they can start first. Shape, taken from
   apple/swift-network-evolution#147 (reviewed 2026-10-01):
   - call the MIG server routines (launchd, notifyd, asl) and libxpc's nvlist decoder directly
     in-process, with fuzzed `mach_msg_header_t` buffers;
   - skip the checks that reject random input (audit trailer, sender credentials, reply-port
     validity) only behind one compile switch, `RMX_FUZZING`. A fuzz binary built without it
     refuses to run, and the release image's BOM check shows the switch is absent;
   - start each harness in a chosen state (a job running, exiting or removed; a connection
     cancelled), because the bugs the PR found were in messages arriving during teardown;
   - give each target its own time budget (deep targets long, narrow decoders short). Run a short
     smoke for every candidate and a long run that keeps its corpus; every crashing input stays in
     the corpus as a regression input.
3. Every crash is reduced to a reproducer and becomes an IDQ entry or a fix. The corpus is kept.
4. syzkaller descriptions include teardown during use: destroy a port with queued messages, move
   a port set while a member dies, kill the receiver during `EVFILT_MACHPORT`, and exit a thread or
   task mid-receive. id-046 classes A and B live there.

## Blockers

- id-047: a sanitizer kernel and `mach.ko` built with its kernel's options.
- **Containment:** a syzkaller manager drives its guests over a network (ssh), and the current
  guest containment allows no network. Fuzzing needs its own decision: an isolated host-only
  network with no uplink, or a separate fuzzing host. It also needs a standing guest budget,
  since fuzzing boots many disposable guests.
  A third option keeps today's containment: a self-contained fuzzer inside the guest that calls
  the Mach traps and reads kcov coverage, with its corpus on the guest disk. On a panic, the host
  saves the serial log and boots a fresh guest from the saved corpus. Disk in, disk out, no
  network. It is slower than syzkaller and not yet tried on FreeBSD 15.

## Done when

A campaign runs for an agreed period on the Mach surface with crashes triaged, and the userland
decoder harnesses run in the same way.
