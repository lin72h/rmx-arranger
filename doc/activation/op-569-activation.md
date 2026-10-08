---
id: op-569
state: draft
agent: implementer
repo: rmx-implementer
idq: id-046
expected: 5h
authority: sys/compat/mach fixes; tests in tests/sys/mach and tests/lib/libmach; kernel, mach.ko and test builds via tools/ci/build; overlays; 8 self-check boots; no push
updated: 2026-10-08T08:03Z
---
# op-569 — Implementer: id-046 leftover batch — OOL copyout double free (#8), MIG handlers given kernel pointers (N9), one trap return convention (N10), failed load leaves hooks (#14)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 5 hours.**

Four id-046 findings from the Mach reviews were left for after step 4.
Each is still present at `mach-fixes-6@13628bbe` (checked today). Fix
them on `mach-fixes-6` on top of `13628bbe`, each as its own commit
with an in-tree regression test that fails before the fix and passes
after:

1. **#8 (op-389): a failed out-of-line copyout frees the copy object
   twice.** `vm_map_copyout_kernel_buffer` frees `copy` unconditionally
   (`sys/compat/mach/mach_vm.c:654`), although its contract says the
   caller keeps it on failure (`:594-595`); the receive path then calls
   `vm_map_copy_discard` on it (`sys/compat/mach/ipc/ipc_kmsg.c:2506-2512`,
   which frees it at `mach_vm.c:1199`). The space allocated at `:612`
   is also left mapped. Fix: free only on success and release the new
   allocation on failure. The failing copyout is hard to reach from
   user space, so give it a forced error path: a fail(9) point
   (`KFAIL_POINT_CODE`) at the copyout, which the test enables through
   its `debug.fail_point` sysctl. On KASAN the unfixed path should
   report the second free.
2. **N9 (op-393): MIG calls handlers written for user pointers with
   kernel pointers.** `clock_get_time` copies a 16-byte
   `struct timespec` with `copyout` into `mach_timespec_t *`
   (`sys/compat/mach/mach_clock.c:111-118`), but `_Xclock_get_time`
   passes `&OutP->cur_time`, a kernel reply field
   (`clock_server.c:336`). `mach_vm_machine_attribute` copies in and
   out through `valuep` (`mach_vm.c:443-487`), which MIG passes as
   `&In0P->value` (`mach_vm_server.c:1930`, `vm_map_server.c:2603`).
   Fix: separate the trap entry (user pointer) from the MIG entry
   (kernel pointer), and fill `mach_timespec_t` field by field. Test
   through the MIG calls libmach exposes; where one has no reachable
   caller today (no clock port), say so and test the kernel-pointer
   path you can reach.
3. **N10 (op-393): traps report `kern_return_t` in two ways.** Most
   traps put it in `td_retval[0]` and return 0. Some return it, or a
   `copyout` errno, through the syscall error path, so callers see -1
   with `errno` set: `_kernelrpc_mach_port_allocate_trap`
   (`sys/compat/mach/mach_traps.c:255-271`),
   `_kernelrpc_mach_port_destroy_trap` (`:386-396`), and the
   `mach_vm_*` traps from `:409`. libmach returns the trap result
   unchanged (`lib/libmach/mach/mach_misc.c:78`), so Darwin callers get
   -1 instead of `KERN_*`. Fix: every trap that returns
   `kern_return_t` reports it through `td_retval[0]`; a failed
   `copyout` of an out-parameter becomes `KERN_INVALID_ADDRESS`. Test:
   each changed trap returns the expected `KERN_*` value on one
   failure (an invalid right, an unknown name, an invalid address).
   Check that no caller in `lib/` or `sbin/launchd` relies on -1;
   list any you find, and change none.
4. **#14 (op-389): a failed module load leaves lifecycle hooks
   registered.** `mach_mod_init` refuses a load after boot
   (`sys/compat/mach/mach_module.c:262-269`), but the module's
   SYSINITs have already registered process and thread event handlers
   (`kern/task.c:1223-1233`, `mach_thread.c:313-321`) and other init
   (`ipc/ipc_init.c:272`, `kern/ipc_host.c:607`, `ipc/ipc_pset.c:220`)
   that nothing removes; after the failed load the module text is
   freed while the handlers still point into it. Fix: none of that
   init runs, or all of it is undone, when the load is refused. A
   guest test needs a boot without `mach.ko`; if that is impractical
   within the boots, record the source trace showing every
   registration is skipped or removed, and say why.

Runs: build with `tools/ci/build` for RELEASE and KASAN. Base is
op-565's overlays (`13628bbe`), already built
(`build/ci/13628bbe681acb64308b5f8a7d584b86704d9914/overlays/`). Show
each new test failing on the base RELEASE overlay (and #8's on base
KASAN if a boot remains), then on both fixed overlays: the new tests
pass and the full suite (93 earlier cases and the five MIG modes)
still passes, with no new assertion or KASAN report. A case that stops
the guest gets one re-run after its fix. A new assertion or KASAN
report outside these four is a finding: record it with its serial
lines and file:line, do not fix it here.

Evidence: commits; your op record (`docs/op569-leftovers.md`): each
fix with its test and file:line, base and fixed results per profile,
any finding; final overlay hashes and manifest differences against
op-565's; the `selfcheck:` line.

## Limits

- Changes in `sys/compat/mach` and the two test directories only. No
  library or launchd change; callers relying on the old convention are
  listed, not changed. No other id-046 item. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
