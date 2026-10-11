---
id: op-626
state: draft
agent: implementer
repo: rmx-implementer
idq: id-063
authority: product and test commits on mach-fixes-6 in wip-rmxos for this item; rebuild the RELEASE and KASAN overlays; 6 self-check boots (4 + 2 spare) with the op-622 runner; test-only fixes under op-590's rule; no push
expected: 2h
updated: 2026-10-11T05:07Z
---
# op-626 — Implementer: send-possible on an already-dead name gives an immediate dead-name notification, then the op-622 self-check

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 2 hours.**

Your op-622 stop was correct, and your source trace is confirmed. The
gap is in my op-622 brief: it said combined dead-name behaviour "stays
as it is", but before op-622 selector 66 was refused, so that
behaviour never existed for send-possible requests. XNU defines it in
`/Users/me/wip-mach/reference/xnu-xnu-12377.121.6/osfmk/ipc/ipc_right.c`,
`ipc_right_request_alloc` ("treat
send_possible requests as immediate w.r.t. dead-name"): any
send-possible request on a dead name, with sync zero or not, takes one
extra uref and sends DEAD_NAME at once. libdispatch relies on this
(`lib/libdispatch/src/source.c:2724-2732`). Start from `bf1658fe`.

1. **Fix:** in `ipc_right_dnrequest` (`sys/compat/mach/ipc/ipc_right.c`
   around 371-389 at `bf1658fe`), a send-possible request on a dead
   name is handled as immediate, whatever sync is. A plain DEAD_NAME
   request keeps today's behaviour: immediate only with sync set.
2. **Test (Zig):** add a case to `mach_send_possible_test`: selector
   66 with sync zero on an already-dead name returns success, delivers
   exactly one DEAD_NAME notification with that name and adds one
   uref; plain DEAD_NAME with sync zero on a dead name still returns
   `KERN_INVALID_ARGUMENT`.
3. **Self-check:** rebuild the RELEASE and KASAN overlays on
   `op552-overlay-base-r3.raw` (sha256
   `6f3b6e54606cecfbe3572cf5e2dee156c42499d113909351b811c41abe974059`),
   recording each overlay's and manifest's sha256, and run op-622's
   full plan with the new case added on both profiles. Expected on
   both: every case passes, including
   `dispatch_mach_test:send_death_registration` and all op-622 cases;
   the five MIG modes exit 0; the 400-case repeat passes; normal
   power-off; no assertion or fatal trap; on KASAN, no KASAN report.
   Two spare boots; a wrong new test may be fixed and rerun within the
   boots (op-590's rule); a product failure or an earlier accepted
   test failing stops the op.

Evidence: add the fix, the test and both runs (load, ATF counts, MIG
modes, power-off line, serial paths and sha256) to
`docs/op617-round3.md` as `### op-626`, commit, and update its
`selfcheck:` line.

## Limits

- Commits on `mach-fixes-6` in `wip-rmxos`, only for this item. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
