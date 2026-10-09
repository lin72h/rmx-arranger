---
id: op-579
state: issued
agent: implementer
repo: rmx-implementer
idq: id-046
authority: one product commit on mach-fixes-6 in wip-rmxos; rebuild the RELEASE and KASAN overlays; 6 self-check boots (4 + 2 spare) with the op-577 runner; no push
expected: 3h
issued-at: 2026-10-09T00:18Z
updated: 2026-10-09T00:18Z
---
# op-579 — Implementer: reject unsupported protection bits in mach_vm_protect before narrowing; rebuild and self-check both profiles

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 3 hours.**

Your op-577 trace is right, and it points at our code, not only at the
test. The trap passes `new_protection` as an `int`
(`sys/compat/mach/mach_traps.c:518`) into `mach_vm_protect`, whose
`prot` is FreeBSD's `vm_prot_t`, a `u_char` (`sys/vm/vm.h:70`;
`sys/compat/mach/mach_vm.c:246-253`). Unsupported high bits are
dropped before anything checks them, so `0x40000000` becomes
protection 0: the range is made inaccessible and the caller is told
`KERN_SUCCESS`. On XNU, `vm_prot_t` is an `int` and `mach_vm_protect`
returns `KERN_INVALID_ARGUMENT` for bits it does not support. The MIG
route also ends in `mach_vm_protect`
(`sys/compat/mach/mach_vm_server.c:850`); its request field is typed
`vm_prot_t` (`:142`), so its width in the kernel may differ from
userland's.

So the test input in `a35ce232` is the right input, and the failing
`mach_trap_returns_test:errors` is the regression test for this fix:
it fails before the fix (your op-577 run, `observed=0`).

1. **Fix (one commit on `mach-fixes-6`, parent `a35ce232`):** check the
   full protection value before it is narrowed, on both the trap and
   the MIG route, and return `KERN_INVALID_ARGUMENT` without changing
   the mapping when it has a bit outside `VM_PROT_ALL`. First compare
   the size and offsets of `__Request__mach_vm_protect_t` in the kernel
   with the userland stub's: if they differ, that is a message layout
   defect, not narrowing; record it, fix only the trap route here, and
   say so in the reply. Before
   choosing the mask, search libmach, libdispatch, launchd and libxpc
   for callers that pass other bits (for example `VM_PROT_COPY`) and
   say what you found; if one does, accept that bit and record it.
   Correct the test comment at `tests/sys/mach/mach_trap_returns.zig:52`
   to say what is checked. Leave `set_maximum` as it is.
2. **Rebuild** the fixed RELEASE and KASAN overlays from the new
   commit as in op-569, on the same base image
   `op552-overlay-base-r3.raw` (sha256
   `6f3b6e54606cecfbe3572cf5e2dee156c42499d113909351b811c41abe974059`).
   Record each overlay's and manifest's sha256.
3. **Self-check with the op-577 runner** (240 s install window, load
   gate below 40): fixed RELEASE, then fixed KASAN, each an install
   and a test boot. Expected on both: the 93 earlier cases and all 50
   new cases pass, including `mach_trap_returns_test:errors` with
   `trap=vm_protect expected=4 observed=4`; the five MIG modes exit 0;
   normal power-off; no assertion or fatal trap; on KASAN, no KASAN
   report from boot to power-off.
4. Two spare boots, only for a boot that stops before its commands
   run. If a check fails for another reason, record it and stop.

Evidence: add the fix, the caller search, the overlay hashes and both
runs to `docs/op569-leftovers.md` (load at each boot start, ATF counts
per profile, MIG modes, power-off line, serial paths), commit, and
update the `selfcheck:` line.

## Limits

- One product commit on `mach-fixes-6` in `wip-rmxos`; no other source
  change. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
