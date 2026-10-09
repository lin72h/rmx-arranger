---
id: op-583
state: draft
agent: implementer
repo: rmx-implementer
idq: id-046
needs: op-579
authority: product commits on mach-fixes-6 in wip-rmxos (one per item); rebuild the RELEASE and KASAN overlays; 6 self-check boots (4 + 2 spare) with the op-577 runner; no push
expected: 6h
updated: 2026-10-09T00:52Z
---
# op-583 — Implementer: id-046 last batch — stock-module struct layout, VM wrapper contract, debug sysctls, workqueue exec timing

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 6 hours.**

These are the last unscheduled id-046 findings (Advisor 1's op-392 S6
and § 3). The Arranger decided to fix them for 1.0 rather than list
them as gaps, except where item 2 says otherwise. Start from op-579's
commit `8ed4d57bf316a43aee57dbdcc72c00ae78a6df40` on `mach-fixes-6`. One commit per item, each with a test that
fails before it where the item has observable behaviour.

1. **Stock-module struct layout.** `td_machdata` and `td_twq` sit
   right after `td_emuldata` (`sys/sys/proc.h:391-393`), and
   `p_machdata`, `p_twq` right after `p_jaillist` (`:791-793`), so
   every later field moves, including `td_lastcpu` and
   `td_lkpi_task`. The offset checks stop at `td_emuldata` and
   `p_emuldata` (`sys/kern/kern_thread.c`), so the build passes.
   Modules built against stock FreeBSD 15 headers, such as drm-kmod
   from packages through LinuxKPI, then read the wrong field on our
   kernel. Move the four fields to the end of `struct thread` and
   `struct proc`, and give `DTYPE_MACH_IPC` a number that leaves
   `DTYPE_NTSYNC` at its stock value 17 (`sys/sys/file.h:77-81`).
   Test: compile-time offset checks, against stock 15's values, for
   the stock fields after the old insertion points, at least
   `td_lastcpu`, `td_lkpi_task`, `p_jaillist`'s successor and the
   last stock field of each struct. Check `libkvm`, `procstat` and
   `ps` for code that depends on the old layout.
2. **VM wrapper contract** (`sys/compat/mach/mach_vm.c`). Every
   wrapper acts on the calling process and ignores its target. For
   1.0:
   - A target other than the caller's own task returns
     `KERN_INVALID_ARGUMENT` and changes nothing. Cross-task VM
     operations become a known 1.0 gap; record it.
   - `mach_vm_protect` with `set_maximum` true sets the maximum
     protection (FreeBSD 15 expresses it with `PROT_MAX`) instead of
     ignoring the flag.
   - The MIG route returns `kern_return_t` values, not errno
     (`mach_vm_server.c:850` stores `mach_vm_protect`'s errno in
     `RetCode`), the same mapping op-569 gave the traps. Check every
     VM server routine in that file the same way.
   - The MIG `mach_vm_protect` server rejects a protection byte with
     bits outside `VM_PROT_ALL` with `KERN_INVALID_ARGUMENT`, as your
     op-579 trap check does. The request layouts do agree: the 8-byte
     offset difference you measured is the header, which
     `ipc_kmsg_copyin` widens from the user's 24 bytes to the kernel's
     32 and adds to the size (`ipc/ipc_kmsg.c:807-829`,
     `LEGACY_HEADER_SIZE_DELTA` at `:331`). Correct that section of
     `docs/op569-leftovers.md`. Our userland `vm_prot_t` is one byte
     where macOS's is an `int`, so the user stub narrows before
     sending; record that as a known 1.0 gap, no change.
   - `mach_vm_allocate` (`vm_map_insert` at `mach_vm.c:215`) observes
     `RLIMIT_VMEM` and RACCT, like `mmap` of anonymous memory.
   - Out-of-line data is still copied with one `malloc(M_NOWAIT)`
     (`mach_vm.c:550`): keep that, and confirm that a failed
     allocation returns an error to the sender with nothing leaked.
     Record it as a known 1.0 gap (large OOL sends can fail under
     memory pressure).
   Tests in Zig: one per behaviour above.
3. **Debug sysctls** (`mach.current_task_space_stats` and
   `mach.current_task_port_status`, `sys/compat/mach/mach_module.c`
   from `:125`). They walk the space's entry list holding only
   `PROC_LOCK` and read entries without a reference, so a concurrent
   close can free an entry they are reading. Either hold the space
   lock the entry list requires and take references, or build them
   only under `INVARIANTS`; say which and why. Check whether launchd,
   libxpc or a test reads them first.
4. **Workqueue state at exec.** `twq_proc_exec` runs from
   `pre_execve` (`sys/kern/kern_exec.c:321`), before exec can still
   fail, so a failed exec leaves a running process with its
   workqueue state torn down. Move it to after exec's point of no
   return. Test: a failed `execve` followed by workqueue use in the
   same process.
5. **Audit of Mach-initiated closes.** op-392 found that
   `AUDIT_SYSCLOSE` compiled to nothing in the standalone `mach.ko`.
   Confirm from the op-562 build, now built with its kernel, that it
   is compiled in. A record line is enough; no change if it is.

Then rebuild the fixed RELEASE and KASAN overlays on the same base
image `op552-overlay-base-r3.raw` (sha256
`6f3b6e54606cecfbe3572cf5e2dee156c42499d113909351b811c41abe974059`),
recording each overlay's and manifest's sha256, and self-check both
profiles with the op-577 runner (240 s install window, load gate below
40). Expected on both: all earlier and new cases pass, the five MIG
modes exit 0, the 400-case repeat passes, normal power-off, no
assertion or fatal trap; on KASAN, no KASAN report. Two spare boots,
only for a boot that stops before its commands run.

Evidence: a new record `docs/op583-last-batch.md` (each item: commit,
test, before and after result; the known gaps; overlay hashes; both
runs with load, ATF counts, MIG modes, power-off line, serial paths),
commit, and a `selfcheck:` line.

## Limits

- Product commits on `mach-fixes-6` in `wip-rmxos`, only for the five
  items. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
