---
id: op-633
state: draft
agent: implementer
repo: rmx-implementer
idq: id-063
authority: test and fixture commits on mach-fixes-6 in wip-rmxos and runner changes in rmx-implementer for this item (product source only if step 2 finds a stale client in the image); rebuild the RELEASE and KASAN overlays; 6 self-check boots (4 + 2 spare) with the op-631 runner; no push
expected: 2h
updated: 2026-10-11T06:49Z
---
# op-633 — Implementer: tests and fixtures move to the regenerated MIG encoding; no stale generated clients left; full run on both profiles

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 2 hours.**

Your op-631 fix is accepted at `b37991c4`, pending review: requests
are simple unless they carry descriptors, as Apple's MIG;
`dispatch_mach_test:send_possible` passes 10/10, five kernel
notification kinds reach generated receivers, and the 400-case repeat
passes. Your stop was correct. All 21 failures are on the test side,
as your record shows: the new `send_once` setup calls
`mach_port_extract_right`, which returns `ENOSYS`
(`lib/libmach/mach/mach_misc.c:89-98`); `mach_named_pset` and
`mach_host_vm` build raw requests in the old complex encoding; and
the MIG-mode fixture still uses the op-395 toolchain's MIG
(`tools/selfcheck/op547-build.exs:5,46`), so its kernel calls return
-304 while the program exits 0. At op-621 those calls returned 0.
Start from `b37991c4`.

1. **Tests and fixtures:** `mach_named_pset.zig` and `mach_host_vm.zig`
   send the regenerated encoding (simple unless the body carries
   descriptors), with their checks unchanged; the MIG-mode fixture is
   built with the rebuilt generator; the `send_once` case gets its
   send-once right by a supported transfer. Search the tests for any
   other hand-built MIG request and update it the same way.
2. **Stale clients:** list every program and library in the final
   image (base plus overlay) that contains a generated MIG client or
   server for a kernel subsystem, and whether it was rebuilt with the
   new generator. For any that was not, rebuild it in the overlay; if
   that is not possible, stop and report the list.
3. **Self-check:** rebuild the RELEASE and KASAN overlays on
   `op552-overlay-base-r3.raw` (sha256
   `6f3b6e54606cecfbe3572cf5e2dee156c42499d113909351b811c41abe974059`),
   recording each overlay's and manifest's sha256, and run op-631's
   full plan with its order and every-case rule. Expected on both:
   every case passes; the five MIG modes exit 0 **and every kernel
   call in them returns 0** (`a_rc`, `b_rc`, `kernel_rc`, as at
   op-621); the 400-case repeat passes; normal power-off; no assertion
   or fatal trap; on KASAN, no KASAN report. A failure means the
   profile does not pass; report all failures together and make no
   product change after one. If RELEASE fails, do not boot KASAN. Two
   spare boots for harness faults; a wrong new test may be fixed and
   rerun within the boots (op-590's rule).

Evidence: add the test changes, the stale-client list and both runs
(load, ATF counts, every failure with serial lines, MIG-mode return
codes, power-off line, serial paths and sha256) to
`docs/op617-round3.md` as `### op-633`, commit, and update its
`selfcheck:` line.

## Limits

- Commits on `mach-fixes-6` in `wip-rmxos` for this item: tests and
  fixtures, and product source only for a rebuild that step 2 needs.
  No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
