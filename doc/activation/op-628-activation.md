---
id: op-628
state: closed
agent: implementer
repo: rmx-implementer
idq: id-063
authority: product and test commits on mach-fixes-6 in wip-rmxos for this item, including MIG generator or regenerated server sources; rebuild the RELEASE and KASAN overlays; 6 self-check boots (4 + 2 spare) with the op-626 runner; test-only fixes under op-590's rule; no push
expected: 3h
issued-at: 2026-10-11T05:25Z
updated: 2026-10-11T06:18Z
---
# op-628 — Implementer: MIG request size for counted inline arrays agrees between user clients and kernel servers, then the op-626 self-check

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 3 hours.**

Your op-626 fix is accepted at `3745c74b`:
`dispatch_mach_test:send_death_registration` passes on both branches
(`releases=1`). Your stop was correct. The MIG mismatch you found is
older than op-622: `sys/compat/mach/mach_port_server.c` has not
changed since `8c6a1c15` (April). For `mach_port_set_attributes`, the
generated client computes `(sizeof(Request) - 72) + _WALIGN_(4 *
port_infoCnt)` (your `build/op626/mach_portUser.c:2205`), while the
server checks against `sizeof(__Request) - 68`
(`mach_port_server.c:3553-3569`). The same call is made by launchd
(`sbin/launchd/core.c:1734`, 2017, 6681, 7579) and libdispatch
(`lib/libdispatch/src/queue.c:4283`), whose results are only logged,
so those calls probably fail today too. Start from `3745c74b`.

1. **Cause, then inventory:** confirm the failing check by source
   trace and host-side arithmetic (the header size the server sees
   after copyin included). Find why the two sides differ (which
   generator, or which generator version, produced each), and list
   every routine in the kernel-served subsystems whose request or
   reply carries a counted inline array, with the size each side
   computes. Add the list to your record.
2. **Fix:** one convention for both sides, produced by the generator
   (no hand edits to generated code), following XNU's MIG where the
   two differ. If the fix would change messages for routines without
   counted inline arrays, or would need more than the affected server
   and client sources regenerated, stop and report the inventory
   before changing anything.
3. **Tests (Zig):** `mach_port_set_attributes` with
   `MACH_PORT_LIMITS_INFO` count 1 and `MACH_PORT_TEMPOWNER` count 0
   return `KERN_SUCCESS`, and the limit is read back with
   `mach_port_get_attributes`; launchd's call form (count
   `sizeof(limits)`) behaves as on XNU; a count above the array's
   maximum still returns `MIG_BAD_ARGUMENTS`; one valid call for each
   other affected routine in the inventory.
4. **Self-check:** rebuild the RELEASE and KASAN overlays on
   `op552-overlay-base-r3.raw` (sha256
   `6f3b6e54606cecfbe3572cf5e2dee156c42499d113909351b811c41abe974059`),
   recording each overlay's and manifest's sha256, and run op-626's
   full plan with the new cases added on both profiles. Expected on
   both: every case passes, including all op-622 and op-626 cases;
   the five MIG modes exit 0; the 400-case repeat passes; normal
   power-off; no assertion or fatal trap; on KASAN, no KASAN report.
   Two spare boots; a wrong new test may be fixed and rerun within the
   boots (op-590's rule); a product failure or an earlier accepted
   test failing stops the op.

Evidence: add the cause, the inventory, the fix, the tests and both
runs (load, ATF counts, MIG modes, power-off line, serial paths and
sha256) to `docs/op617-round3.md` as `### op-628`, commit, and update
its `selfcheck:` line.

## Limits

- Commits on `mach-fixes-6` in `wip-rmxos`, only for this item. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
