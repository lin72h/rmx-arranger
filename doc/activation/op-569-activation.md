---
id: op-569
state: issued
agent: implementer
repo: rmx-implementer
idq: id-046
authority: sys/compat/mach fixes; tests in tests/sys/mach and tests/lib/libmach; kernel, mach.ko and test builds via tools/ci/build; overlays; 8 self-check boots; no push
expected: 5h
issued-at: 2026-10-08T08:23Z
updated: 2026-10-08T08:23Z
---
# op-569 — Implementer: finish the id-046 leftover batch (#8, N9, N10, #14): runs and record

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 3 hours.**

This op makes four small corrections from the id-046 review ledger,
each with an in-tree regression test. The code work is done; what
remains is the self-check runs and the record.

Work so far (all yours, on disk):
- `mach-fixes-6` above `13628bbe`:
  - `849c27c9` N9: the VM attribute and clock MIG routines use the
    request and reply message fields directly;
  - `d1566327` N10: every Mach trap returns its `kern_return_t` as a
    value through `td_retval[0]`;
  - `a02388da` #8: `vm_map_copyout_kernel_buffer` leaves the copy
    object to its caller when copyout fails, as its contract says
    (`sys/compat/mach/mach_vm.c:594-595`), and removes the new mapping;
  - `c07ae8e8` #14: the five Mach SYSINITs do nothing on a load after
    boot, matching `mach_mod_init`;
  - `9b958207` keeps the timer-create trap's name-returning convention.
- `mach-fixes-6-op569-base` (`26b8c8ed`): the new tests and the
  fail(9) point on the unchanged `13628bbe` code.
- Overlays under `build/ci/` for `26b8c8ed` (base) and `9b958207`
  (fixed), RELEASE and KASAN.
- Base RELEASE run, 2 of 8 boots:
  `build/op569/runs/rmx-selfcheck-op569-base-release-r1-1791452506/tests/serial.txt`.
  Cases 0-3 fail as expected; case 4 (`mach_ool_failure_test`) stops
  the guest in `vm_map_copy_discard` from
  `ipc_kmsg_copyout_ool_descriptor`, which is the #8 behavior the
  fix corrects.
- Uncommitted runner work: `tools/ci/build.exs`,
  `tools/selfcheck/op569.exs`.

Remaining, within 6 boots:
1. Fixed RELEASE and fixed KASAN overlays (`9b958207`): the new tests
   pass, all 93 earlier cases and the five MIG modes pass, and the
   serial log shows no new assertion or KASAN report. One spare boot
   for a boot that fails before its commands run; base KASAN for case
   4 only if two boots are left after both fixed runs.
2. Anything new outside these four items: record it with its serial
   lines and file:line; do not fix it here.
3. #14: the source trace showing each registration in the five
   SYSINITs is skipped on a load after boot.
4. N10: list the callers in `lib/` and `sbin/launchd` that compare a
   trap result with -1; change none.
5. Commit the runner changes, then write `docs/op569-leftovers.md`:
   each correction with its test and file:line, base and fixed results
   per profile, any finding, overlay hashes and manifest differences
   against op-565's, and the `selfcheck:` line.

## Limits

- Changes in `sys/compat/mach`, `tests/sys/mach`, `tests/lib/libmach`
  and your runner only. No library or launchd change. No other id-046
  item. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
