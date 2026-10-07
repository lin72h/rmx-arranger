# Instrumentation strategy: 1.0 sanitizers and debugging, 2.0 DTrace, 3.0 hwpmc

Status: Arranger doctrine, living. Direction from the Coordinator, 2026-10-01 (j-20261001-001).
Problems: id-047 (sanitizers), id-048 (fuzzing), id-053 (post-mortem debugging), id-054 (DTrace),
id-055 (hwpmc). Milestone tie: li-001 (Mach invariants under load).

**Naming (Coordinator, 2026-10-02).** *Instrumentation* is the umbrella term for everything that
makes the system check or report on itself while it runs: compiler-inserted sanitizers and
coverage, DTrace probes, and hardware performance counters and traces. Each tool is an
*instrument*. A build with an instrument compiled in is an *instrumented profile*, such as
`RMXOS-KASAN`. Swift uses the same word (SE-0550's `@instrumentation`).

"Instrumentation 1.0, 2.0 and 3.0" name the tiers of this strategy. They are not rmxOS releases and
have nothing to do with the 1.0-preview milestone.

## The idea

A tier changes how the system under test is built or observed. It does not change which tests
exist. The same candidate, images, guest runner and test suites run in every tier, and each tier
adds one lens:

- **1.0** makes the kernel and userland check their own memory use and assertions, and makes every
  failure debuggable afterwards. Tools: sanitizers, LLDB.
- **2.0** makes Mach behaviour observable and turns invariants into assertions. Tool: DTrace.
- **3.0** measures performance on real hardware. Tools: hwpmc, hwt.

Everything is built from what FreeBSD already ships, in FreeBSD's own form, so stable/15 merges keep
working, and anything outside Mach can go upstream. `test-pillar-partition.md` is a separate choice
(which language a probe is written in): every pillar's tests run under every tier.

## Why FreeBSD makes this cheap

- LLVM is part of the source tree: alpha2 carries LLVM 21.1.8 (`lib/clang/include/VCSVersion.inc`)
  and builds the kernel and world with it. The sanitizer runtimes are built in base: ASan, UBSan,
  MSan, TSan, libFuzzer, profile (coverage), XRay, CFI and SafeStack (`lib/libclang_rt/Makefile`).
  `cc -fsanitize=fuzzer,address` works with no ports.
- The kernel build knows the sanitizers. One `options` line sets the compiler flags for the kernel
  and for every module built with it (`sys/conf/kern.mk:259-331`, `sys/conf/kmod.mk:429-432`).
- The world build knows them too: `WITH_ASAN`, `WITH_UBSAN` (`share/mk/bsd.sanitizer.mk`), `INIT_ALL`.
- Debuggers come with it. Base LLDB includes the FreeBSD kernel-core plugin
  (`lib/clang/liblldb/Makefile:481-485`) and scripts in Lua. Ports LLDB (llvm21 on this host) links
  libkvm and scripts in Python. kgdb (ports gdb) is installed here.
- DTrace, hwpmc(4) and hwt(4) are in base.

Apple's XNU uses the same structure. KASAN is a kernel variant built on its development
configuration (`xnu/makedefs/MakeInc.def:429`, `san/memory/`), kcov/ksancov feeds its fuzzers
(`san/coverage/`), and `tools/lldbmacros/` provides LLDB commands for IPC, kqueues, workqueues and
KASAN. Copying that structure brings rmxOS closer to macOS as well as to FreeBSD.

## What FreeBSD 15 provides (alpha2 `2884304b`)

### Kernel

| Tool | Enable | Upstream form | Limits | Our use |
|---|---|---|---|---|
| KASAN | `options KASAN` | `GENERIC-KASAN` = `include GENERIC-DEBUG` + one option (amd64, arm64) | checks the kernel map, not the direct map (kasan(9)); 6 kernel stack pages (`amd64/include/param.h:130-136`); boot tunable `debug.kasan.panic_on_violation`, default 1 | 1.0, first |
| KMSAN | `options KMSAN` | `GENERIC-KMSAN` (amd64, arm64) | 2–3× slower; 2 bytes of shadow per byte; at least 8 GB RAM (kmsan(9)); uninstrumented modules give false reports | 1.0, second |
| KCSAN | `options KCSAN` | `GENERIC-KCSAN` (amd64 only) | data races; expect reports from base, so filter to Mach frames | 1.0, third |
| KUBSAN | `options KUBSAN` (`kern/kern_ubsan.c`, from NetBSD) | no `GENERIC-KUBSAN` upstream, so it is the least maintained | may not build | 1.0, trial |
| kcov | `options COVERAGE`, `options KCOV` | kcov(4), the coverage source syzkaller uses | none known | coverage of our suites; kernel fuzzing (id-048) |
| GCOV | `options GCOV` | sets flags only for gcc (`kern.pre.mk:104-109`) | does nothing under clang | not usable |
| INVARIANTS, WITNESS, DEADLKRES | `std.debug`, already in `RMXOS-RELEASE` | | in `mach.ko` only when it is built with the kernel | every profile |
| KASSERT controls | `debug.kassert.warn_only` (runtime and boot) | `kern/kern_shutdown.c:725-764` | | survey mode |
| memguard(9), redzone(9) | `DEBUG_MEMGUARD`, `DEBUG_REDZONE` | | one malloc type at a time | narrow a KASAN report |
| INIT_ALL=pattern | build variable (`kern.mk:339-348`) | | `zero` is ignored for amd64 kernels | cheap check for uninitialized stack |
| fail(9) | `KFAIL_POINT_*` | | | 2.0 fault injection (id-013) |

### Userland

| Tool | Enable | Limits | Our use |
|---|---|---|---|
| ASan, UBSan | `WITH_ASAN`, `WITH_UBSAN` | instruments shared libraries and dynamic programs only, not static ones (`bsd.sanitizer.mk`); `WITH_ASAN` installs llvm-symbolizer as addr2line (`src.opts.mk:517-520`) | libmach, libdispatch, libxpc, libnotify, libasl, launchd, notifyd, asl and their tests; launchd is dynamic (`sbin/launchd/Makefile`) |
| TSan | runtime in base; no build option | does not see workqueue threads that the kernel creates | trial on the libdispatch tests only |
| MSan | runtime in base; no build option | every library, libc included, must be instrumented | not planned |
| libFuzzer | `-fsanitize=fuzzer,address` | | message decoders (id-048) |
| Source coverage | `-fprofile-instr-generate -fcoverage-mapping`; llvm-cov, llvm-profdata in base | | userland coverage |
| XRay | runtime in base | | 3.0 option for function-level tracing |
| Swift code | `-sanitize=address,thread` in the Swift driver; per-function opt-out with SE-0550's `@instrumentation(disable: …)` and `#if instrumentation(…)` once rmxOS's Swift toolchain has it (the proposal is still in review) | TSan cannot see kernel-created workqueue threads; SE-0550 can exempt just the affected functions | the swift-testing tier, later |

### Debugging, tracing and performance

- DDB with panic scripts (ddb(8), `/etc/ddb.conf`), textdumps and minidumps, savecore(8),
  crashinfo(8). Python kgdb scripts already live in `sys/tools/gdb/`.
- DTrace: fbt, sdt (SDT(9)), kinst, lockstat, profile, pid/USDT. `GENERIC` sets `WITH_CTF=1` and
  `KDTRACE_HOOKS`.
- hwpmc(4) and hwt(4) (`sys/dev/hwt`, `HWT_HOOKS`). **bhyve guests have no PMU:** the vmm reports
  zeros for the performance-monitoring CPUID leaf (`sys/amd64/vmm/x86.c:484-490`).

## Staying aligned with FreeBSD

1. **Use FreeBSD's switches, not our own flags.** A sanitizer profile is a kernel configuration in
   `GENERIC-KASAN`'s form: `include RMXOS-RELEASE`, `ident RMXOS-KASAN`, `options KASAN`. Each
   profile then differs from the tested candidate by exactly one option, so any report comes from
   the sanitizer, not from a configuration difference.
2. **Build `mach.ko` with the kernel**, through `sys/modules/Makefile`, gated on a kernel option as
   other modules are (`sys/modules/Makefile:452`). Only then does it get its kernel's
   `opt_global.h`, so the 507 assertions in `sys/compat/mach` go live; the build also passes it the
   sanitizer flags, CTF and debug files. Today it is built on its own with an empty `opt_global.h`
   (op-364 build log, line 14: `touch opt_global.h`).
3. **INVARIANTS checks behaviour; it must not change it.** `ipc_kmsg_alloc` zeroes messages only
   under INVARIANTS (`compat/mach/ipc/ipc_kmsg.c:386-390`). That is a defect in its own right, and it
   also hides uninitialized message bytes from KMSAN. Every such place is listed (op-396) and fixed
   through id-046.
4. **Tests (Coordinator, 2026-10-02).** FreeBSD's existing tests (ATF and Kyua, `/usr/tests/sys`
   for kern, file and kqueue) run as they are, because Mach changes those subsystems. New rmxOS
   tests use the project's own modern stack, consistently, as `test-pillar-partition.md` sets out:
   Zig for the substrate (Mach traps, IPC, the C ABI), swift-testing for the high level, and Elixir
   to drive runs. They need not be FreeBSD-upstreamable. op-395's tests are Zig programs that link
   ATF; they stay until a migration op moves them to the Zig convention.
5. **Annotate private allocators the way UMA does** (`kasan_mark`, `kmsan_mark`). Today every Mach
   allocation goes through UMA or malloc(9) (`ipc_init.c:184-186`, `task.c:1144`,
   `mach_thread.c:264`, `ipc_kmsg.c:765-773`), so no annotations are needed yet. A private cache
   added later needs them. A file that must not be instrumented uses FreeBSD's `NOSAN` compile rule,
   not ad hoc flags.
6. **Debugger extensions follow `sys/tools/gdb/`:** Python, a README and a self-test.
7. **Commits use FreeBSD's form** (`subsystem: summary`). FreeBSD-side changes stay separate from
   Mach changes so that each can go upstream on its own.
8. **Upstream what is not Mach:** sanitizer reports in FreeBSD code, KUBSAN repairs, KMSAN
   interceptor gaps, and LLDB kernel-core problems (llvm-project#180061).

## Instrumentation 1.0: sanitizers and post-mortem debugging

### Profiles

| Profile | Kernel configuration | Userland | Guest | Cadence |
|---|---|---|---|---|
| P0 debug | `RMXOS-RELEASE`, with `mach.ko` built with the kernel | as shipped | 2 vCPU, 4 GiB | every candidate |
| P1 KASAN | `RMXOS-KASAN` | as shipped | 2 vCPU, 4 GiB | every candidate |
| P2 KMSAN | `RMXOS-KMSAN` | as shipped | 8 GiB or more | each milestone |
| P3 KCSAN | `RMXOS-KCSAN` | as shipped | 2+ vCPU, 4 GiB | each milestone; Mach frames only |
| P4 KUBSAN | `RMXOS-KUBSAN` (trial) | as shipped | 4 GiB | if it builds |
| U1 ASan+UBSan | P0 or P1 | `WITH_ASAN` and `WITH_UBSAN` for the core libraries, daemons and their tests | 4 GiB | each milestone |
| P5 coverage | `RMXOS-KCOV` (`COVERAGE` + `KCOV`) | as shipped | 4 GiB | each milestone; reports which Mach code the suites reach |

### Two run modes

- **Gate:** default tunables. The first violation panics, which gives CI a pass or fail.
- **Survey:** `debug.kasan.panic_on_violation=0` (boot), `debug.kmsan.panic_on_violation=0` and
  `debug.kassert.warn_only=1`. Every report is collected in one boot. Used for baselines, where known
  defects (op-389 #1 and #11 fire assertions) would otherwise stop the run at the first one. This
  replaces id-047's earlier "fix #1 and #11 first".

### What runs

The same suites in every profile: the Mach ATF suite (op-395), the Mach and dispatch slice
(op-372), the PID-1 cell (op-398), and FreeBSD's kern, file and kqueue tests with `mach.ko` loaded.

### Every failure can be debugged afterwards (id-053)

- **Panic capture in every test image:** a DDB panic script prints `bt`, `show alllocks`, `ps` and
  `alltrace` to the serial console, writes a dump, and stops without rebooting. FreeBSD's own
  mechanisms: `ddb_enable`, `/etc/ddb.conf`, `dumpdev`.
- **Stalls too, not only panics (id-061, op-544):** when a guest hangs (a missing reply, a
  shutdown that does not finish), send it an NMI on every vCPU (`bhyvectl --inject-nmi --cpu=N`;
  the guest's NMIs are broadcast and DDB waits for every CPU) so the same DDB script dumps every
  thread. This is the first diagnostic for any hang; reproducers come after the dump.
- **Debug files with every image:** `kernel.debug` and `mach.ko.debug` are listed in its BOM.
- **Triage on the host:** LLDB (ports llvm21, Python; or base LLDB, Lua) on the vmcore, and kgdb as
  FreeBSD developers' reference. First check: LLDB loads `mach.ko`'s symbols from a vmcore, which is
  an open item on llvm-project#180061.
- **Mach commands for LLDB:** port the IPC subset of XNU's `tools/lldbmacros` (`ipc.py`: showipc,
  showtaskipc, showrights, showport, showpset, showkmsg, showmqueue, findportrights; parts of
  `kevent.py` and `workqueue.py`) to rmxOS's structures. They go under `sys/tools/lldb/` in
  `sys/tools/gdb/`'s form and keep XNU's command names, so macOS kernel habits carry over. The
  source is APSL, like the Mach code: `/Users/me/wip-mach/reference/xnu-xnu-12377.121.6/tools/lldbmacros/`.
- **Userland cores** (launchd, libdispatch, notifyd): LLDB as today.
- **Upstream:** follow llvm-project#180061 (FreeBSD LLDB work, now aimed at LLVM 24: message buffer,
  crashed-thread selection, module symbols, a new kernel-core test suite). Our tree has LLVM 21, so
  these arrive with a later LLVM import or a newer ports LLDB. Report and contribute the failures we
  can reproduce.

### Reports become problems

Group sanitizer and KASSERT reports by stack. A report in Mach frames becomes an id-046 ledger row
(or a new IDQ). A report in FreeBSD frames becomes an upstream candidate. A confirmed report gets a
regression test in `tests/sys/mach`, written before its fix as in op-395.

### Fuzzing (the LLVM half of id-048)

- **Userland:** libFuzzer harnesses for the decoders (launchd's MIG and plist handling, libxpc's
  nvlist, notifyd, asl), built from base with `-fsanitize=fuzzer,address`. They run on the host and
  need no guest.
- **Fuzz-only bypasses:** checks that reject random input (audit trailer, sender credentials) are
  skipped only behind one compile switch, `RMX_FUZZING`. The release image's BOM check confirms
  that switch is absent.
- **Two cadences:** a short smoke run for every candidate, and long runs that keep their corpus.
  Every crashing input stays in the corpus as a regression input. (This follows
  apple/swift-network-evolution#147.)
- **Kernel:** syzkaller, or a self-contained in-guest fuzzer that reads kcov, on P1 + P5. It waits
  for a containment decision.

### Order

1. **op-396 (Implementer):** build `mach.ko` with the kernel; add the `RMXOS-KASAN`, `-KMSAN`,
   `-KCSAN` and trial `-KUBSAN` configurations; build P0 to P4 from alpha2; stage one image per
   profile. No guests.
2. **Gatekeeper, after op-398:** boot P0 and P1 from those images, survey mode first and then gate
   mode, and run the slice. Set up panic capture and show one vmcore opening in LLDB and in kgdb.
   This becomes CI's sanitizer leg.
3. **Reports go to id-046.** Fixes follow the Mach round's order, with classes A to D designed first.
4. **Then:** P2, P3 and P4 surveys; U1 userland builds; libFuzzer harnesses; Mach LLDB commands; P5
   coverage.
5. **On the fixed branch:** P0 and P1 for every candidate; the other profiles for each milestone.

## Instrumentation 2.0: DTrace (id-054)

Make Mach's behaviour observable in FreeBSD's way, and turn invariants into assertions (li-001).

- **An SDT(9) provider `mach` in `sys/compat/mach`, which has no probes today.** Probes for port
  life, right transfer, kmsg send and receive, notifications and receive wakeups, written with
  `SDT_PROVIDER_DEFINE` and `SDT_PROBE_DEFINE*`. Names follow XNU's where XNU has them, so
  scripts carry over from macOS.
- **CTF for `mach.ko`**, which comes with building it in the kernel (`WITH_CTF=1`), so probe
  arguments are typed.
- **Invariant oracles in D:** send and receive balance, port allocation and free balance,
  no-senders and dead-name notifications delivered, and no message stuck in a queue. The op-099
  library is promoted from tracer to oracle. Oracles run inside the guest beside the tests, and a
  violated predicate fails the run.
- **USDT:** libdispatch's timer probes (op-101) grow toward Apple's dispatch provider; launchd
  gets job-state probes.
- **More providers:** kinst(4) for instruction-level probes in the `-O0` Mach code, lockstat for
  contention, and profile for sampling inside guests, which have no PMU.
- **Fault injection:** fail(9) points on Mach error paths (message allocation, copyin and copyout,
  right allocation), plus DTrace destructive actions (id-013).
- **Comparison with macOS:** run DTrace's own test suite (`WITH_DTRACE_TESTS`) once on rmxOS. On
  mm4, run the same D scripts wherever the providers match.

## Instrumentation 3.0: hwpmc (id-055)

Performance on real hardware.

- **Needs bare metal.** bhyve exposes no PMU, so rmxOS has to boot on real hardware: this host
  (Xeon E5-2680 v4, Broadwell, which hwpmc and Intel PT support) or a dedicated machine. The
  Coordinator decides.
- **Benchmarks:** pmcstat sampling and counting for mach_msg round trips, port operations, dispatch
  queue throughput and launchd spawn. Flame graphs, a baseline per candidate, and a regression
  budget.
- **Tracing:** hwt(4) Intel PT traces for hangs and latency outliers, giving exact control flow
  without instrumentation. XRay for userland functions where PT is not available.
- **Comparison:** the same benchmarks on macOS (mm4).

## Roles

- The Implementer writes the product side: kernel configurations, the module build, SDT probes,
  LLDB commands and fuzz harnesses.
- The Gatekeeper runs every tier (it owns CI, j-20260929-005), keeps the panic capture and dumps,
  and disposes evidence. The Validators read the results.
- Existing guest containment covers 1.0 and 2.0. Kernel fuzzing (a network or a self-contained
  fuzzer) and 3.0 (bare metal) need Coordinator decisions first.

## Open decisions (Coordinator)

1. Whether op-396 goes before op-395 or after it (both need the one Implementer).
2. 8 GiB guests for KMSAN (the host has 128 GiB).
3. Bare metal for 3.0.
4. Containment for kernel fuzzing (id-048).
5. When to send upstream (FreeBSD, LLVM), and who sends.
