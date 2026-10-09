---
id: op-586
state: closed
agent: implementer
repo: rmx-implementer
idq: id-046
needs: op-583
authority: product commits on mach-fixes-6 in wip-rmxos (item 0 and one per finding group); rebuild the RELEASE and KASAN overlays; 6 self-check boots (4 + 2 spare) with the op-583 runner; no push
expected: 7h
issued-at: 2026-10-09T20:44Z
updated: 2026-10-09T21:08Z
---
# op-586 — Implementer: op-568's host, task and VM findings — three panic paths, VM copy and map semantics, truthful task routines

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 7 hours.**

Advisor 2 read the host, task and VM server routines no earlier review
had reached, at `8ed4d57b`. The Arranger traced F1-F6 and F10 in the
source. Most are routines inherited from NextBSD as stubs that report
success, or adapters with the wrong FreeBSD contract. The 1.0 rule: a
routine either does what Mach says or returns `KERN_NOT_SUPPORTED`
with every output left empty and every input right released; never a
success it did not earn. Each "not supported" below is a known 1.0 gap
to record.

Start from op-583's final commit
`7e47847d63fcb6076050dae3ea8bd4b24966c706` on `mach-fixes-6` (line
numbers below are at `8ed4d57b`; op-583 moved some). One
commit per group, each with a Zig test that fails before it (a guest-only
failure counts: say so, and show it in the self-check's base column if
you run one).

0. **Correct op-583's foreign-task VM result.** Your op-583 RELEASE
   run stopped at `mach516 case=refused fact=14 expected=46
   observed=4`: `mach_vm_allocate` on a child task. The test is right
   and the op-583 brief was wrong. op-516's accepted contract returns
   `KERN_NOT_SUPPORTED` (46) for every operation on another task
   (`tests/sys/mach/mach_child_setters.zig:239-248`), so the VM
   wrappers must too. Change `7e47847d`'s foreign-target result from
   `KERN_INVALID_ARGUMENT` to `KERN_NOT_SUPPORTED`, and change any new
   op-583 test that expects 4 for another task. Keep
   `KERN_INVALID_ARGUMENT` for a port that is not a task at all.
   Before choosing any other return code in this op, search the
   existing tests for the same call.
1. **Three panics on ordinary self calls.**
   - `vm_allocate` through MIG on the caller's own task: the server
     gets its map from `convert_port_entry_to_map`, which always
     returns `NULL` (`sys/compat/mach/mach_convert.c:51-55`), and
     `mach_vm_allocate` locks that map (`mach_vm.c:200`). Convert the
     caller's own task port to its map, holding a reference the
     server's `vm_map_deallocate` releases; another task's port
     returns `KERN_NOT_SUPPORTED`, a port that is not a task
     `KERN_INVALID_ARGUMENT`.
   - `task_get_special_port(TASK_NAME_PORT)` passes `itk_nself`, which
     nothing creates, to `ipc_port_make_send`
     (`kern/ipc_tt.c:651-653`). Return `KERN_NOT_SUPPORTED` for this
     selector; launchd already refuses it
     (`sbin/launchd/core.c:6597-6607`).
   - `processor_set_default`: `default_pset`'s mutex is never
     initialized and `active` never set (`kern/ipc_host.c:204,
     276-289`), but `convert_pset_name_to_port` locks it and reads
     `active` (`:557-570`). Initialize the mutex and set `active`
     before the ports are enabled. Initialize `realhost.lock`
     (`mach_host.c:21`) at the same point; the host exception
     routines lock it (`kern/ipc_tt.c:1333,1490,1679`).
2. **`mach_vm_copy`** (`mach_vm.c:359-378`): size 0 copies one page
   and then the unsigned size wraps; an overlapping copy to a higher
   address overwrites source pages before reading them. Size 0
   returns success with nothing changed; overlapping ranges copy
   correctly (copy from the end when the destination is above the
   source). Tests: canary pages around a size-0 copy; three distinct
   pages copied one page up.
3. **libmach `mach_vm_map`** (`lib/libmach/mach/mach_misc.c:153-160`)
   declares `mask` before `size`, the reverse of Mach's prototype, so
   a standard caller's size and mask swap. Put them in Mach's order.
4. **`mach_vm_map` adapter** (`mach_vm.c:140-170`):
   - A fixed request (no `VM_FLAGS_ANYWHERE`) must map at exactly the
     given address or fail; today it searches (`VMFS_ALIGNED_SPACE` or
     `VMFS_ANY_SPACE`) and can map elsewhere. Use `VMFS_NO_SPACE` for
     fixed requests.
   - `VM_INHERIT_NONE` and `VM_INHERIT_SHARE` must take effect;
     today both fall through to FreeBSD's default, copy, so a NONE
     mapping survives `fork`. The map trap always asks for NONE
     (`mach_traps.c:451-452`).
   - The alignment mask goes through `ffs()` on an `int` and a
     `0xffffffff` mask wraps to 0, turning an anywhere request into a
     fixed one. Convert a 64-bit mask to the log2 alignment
     `VMFS_ALIGNED_SPACE` expects, or reject masks it cannot express.
   - Check `cur_protection` and `max_protection` against
     `VM_PROT_ALL` before narrowing, as op-579 did for protect
     (`mach_traps.c:451` passes a full `int`).
   Tests: fixed request on an occupied page fails and leaves its data;
   fixed request on a free page lands exactly there; NONE mapping
   absent in a fork child; large mask; protection `0x103` rejected
   with no mapping made.
5. **Routines that report success without doing the work:**
   - `mach_vm_read` (`mach_vm.c:393-420`) never reads the source,
     never sets its outputs, and leaves a mapping behind. Return
     `KERN_NOT_SUPPORTED` with nothing allocated.
   - `task_threads` (`kern/task.c:469-576` under `#if 0`) returns
     success with no list. Return `KERN_NOT_SUPPORTED`.
   - `task_info`: `convert_port_to_task_name` always returns `NULL`
     (`mach_convert.c:72-75`), so every call fails. Convert the
     caller's own task port: under the port lock, check it is active
     and bound, take a task reference, and release it through a real
     destructor (`sys/sys/mach/std_types.h:162` makes it a no-op
     today). Implement `TASK_BASIC_INFO` truthfully from the
     process's vmspace and rusage (today all its assignments are
     under `notyet`, `kern/task.c:737-769`); every other flavor
     returns `KERN_INVALID_ARGUMENT` or `KERN_NOT_SUPPORTED`.
     Another task's port returns `KERN_NOT_SUPPORTED`.
6. **Inheritance values** (`mach_vm_inherit`, both MIG routes,
   `mach_vm.c:263-271`): the value is narrowed to FreeBSD's one-byte
   `vm_inherit_t` before any check, and FreeBSD's 3 means zero-fill,
   not Mach's 3. Validate the Mach value, then translate it (SHARE,
   COPY, NONE; reject the rest). Compare the kernel and user request
   layouts first, allowing for the 8-byte header widening on copyin
   (op-583 item 2), and record the result.

Then rebuild the RELEASE and KASAN overlays on the same base image
`op552-overlay-base-r3.raw` (sha256
`6f3b6e54606cecfbe3572cf5e2dee156c42499d113909351b811c41abe974059`),
recording each overlay's and manifest's sha256, and self-check both
profiles with your op-583 runner. This run also covers what op-583
left unrun (its new cases, the repeat, KASAN). Expected on both: all
earlier and new cases pass, op-583's and this op's, the five MIG modes exit 0, the 400-case repeat passes,
normal power-off, no assertion or fatal trap; on KASAN, no KASAN
report. Two spare boots, only for a boot that stops before its
commands run.

Evidence: a new record `docs/op586-host-task-vm.md` (item 0 and each group:
commit, test, before and after; the known gaps; overlay hashes; both
runs with load, ATF counts, MIG modes, power-off line, serial paths),
commit, and a `selfcheck:` line.

## Limits

- Product commits on `mach-fixes-6` in `wip-rmxos`, only for item 0
  and the six groups. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
