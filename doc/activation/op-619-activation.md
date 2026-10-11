---
id: op-619
state: issued
agent: implementer
repo: rmx-implementer
idq: id-048
needs: none
authority: a new RMXOS-KASAN-KCOV kernel config and tools in rmx-implementer; reduced regression cases as test-only commits on a new branch gen-op619 from mach-fixes-6@93b3735d (never on mach-fixes-6); 12 boots (each a disposable copy, at most 30 min of guest time each); no push
expected: 6h
issued-at: 2026-10-11T09:57Z
updated: 2026-10-11T09:57Z
---
# op-619 — Implementer: generated-input testing of the Mach traps inside a KASAN guest (id-048, step 1): kcov kernel, in-guest tester, first campaign

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 6 hours.**

Review rounds 2 and 3 of the Mach code found 19 defects with no
finding in common between the reviewers, so reading alone is not
converging.
This op adds coverage-guided generated-input testing of the Mach
system calls, run inside a disposable guest with the same containment
as every other run: no network, the corpus on the guest disk, the
serial log on the host. Start from `mach-fixes-6` at
`93b3735d1d8bef1f15e013599d0a56bab3968b61` (on origin; proven
1042/1042 on RELEASE and KASAN, including send-possible
notifications and the MIG generator fixes).

1. **Kernel:** a profile `RMXOS-KASAN-KCOV` (`include RMXOS-KASAN`,
   plus `options COVERAGE` and `options KCOV`; both are in
   `sys/conf/options`, and `sys/kern/kern_kcov.c` is the coverage
   device, kcov(4)). Build it with `mach.ko` as for the other
   profiles and make an overlay on `op552-overlay-base-r3.raw`
   (sha256
   `6f3b6e54606cecfbe3572cf5e2dee156c42499d113909351b811c41abe974059`).
2. **Tester (in `rmx-implementer/tools/`, Zig):** a program that runs
   in the guest, opens kcov for its own thread, and repeatedly builds a
   short sequence of Mach calls from a corpus entry: port and port-set
   allocation and destruction, right insertion and extraction,
   `mach_msg` send and receive with generated headers and descriptors
   (port, port-array and out-of-line), notification requests, kevent
   registration on ports and sets, and thread or process exit in the
   middle of a sequence. It keeps an input that reaches new coverage,
   writes the corpus to the guest disk, and prints one line per new
   input and a summary line to the serial console. Each sequence runs
   in a forked child, so the parent survives a child that is stopped.
   Host-test its generation and corpus code first (the trap calls
   need the guest).
3. **Runner:** reuse your op-633 runner. A campaign boot runs the
   tester for up to 30 minutes of guest time. If the guest stops, the
   runner keeps its serial log and the corpus disk, and the next boot
   starts from the saved corpus on a fresh copy of the installed
   image. Record the load at each boot start.
4. **First campaign:** up to 12 boots. Whenever a boot ends in a
   kernel stop or a KASAN report, take the last input from the serial
   log, reduce it to the smallest sequence that still shows the same
   report, and write it as a Zig test under `tests/sys/mach/` in a
   test-only commit on `gen-op619`, failing on the current code.
   Record what our code does at which `file:line`, from the report
   and the source; the fix comes in a later op. Stop early after
   three distinct reports. Known and not counted as a report:
   `pid 1 comm launchd: signal 11` lines after `All buffers synced.`
   at shutdown (op-637, tracked separately).

Evidence: a new record `docs/op619-generated-input.md` (kernel profile
and overlay hashes, the tester's commit and host test, each boot's
load, duration, coverage at the end and outcome, each distinct report
with its reduced test and `file:line` reading, the corpus size and
path), commit.

## Limits

- No product source change; reduced tests only, as test-only commits
  on `gen-op619`; `mach-fixes-6` stays at `93b3735d`.
- No network in any guest. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
