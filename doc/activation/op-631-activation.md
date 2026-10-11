---
id: op-631
state: closed
agent: implementer
repo: rmx-implementer
idq: id-063
authority: product and test commits on mach-fixes-6 in wip-rmxos for this item, including the MIG generator and regenerated sources; rebuild the RELEASE and KASAN overlays; 6 self-check boots (4 + 2 spare) with the op-628 runner; test-only fixes under op-590's rule; no push
expected: 4h
issued-at: 2026-10-11T06:49Z
updated: 2026-10-11T06:49Z
---
# op-631 — Implementer: generated MIG receivers accept the kernel's simple notifications (complex only with descriptors, as Apple's MIG); one run reporting every failure

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 4 hours.**

Your op-628 work is accepted at `a1232d44`: four-byte MIG alignment,
as Apple's `mig_machine.h`, with every message without a counted
array unchanged. Your stop was correct, and the cause is wider than
libdispatch routing. In your `build/op628/dispatch-protocolServer.c`,
every request checker (lines 126, 200, 274, 353, 427, 499) requires
`MACH_MSGH_BITS_COMPLEX` and a descriptor body, including
`mach_notify_send_possible`, `port_deleted`, `no_senders`,
`send_once` and `dead_name`, whose IDL
(`lib/libdispatch/src/protocol.defs`) carries only the request port
and plain data. Apple's MIG makes a message complex only when its body
carries port or out-of-line descriptors, and the kernel sends these
notifications simple (`sys/compat/mach/ipc/ipc_notify.c`). The
generator has a simple path (`usr.bin/migcom/server.c:882`) that these
routines do not take. libdispatch's dead-name decode
(`lib/libdispatch/src/source.c:3027-3030`) looks like an earlier
workaround for the same mismatch. Start from `a1232d44`.

1. **Cause:** find why `rtSimpleRequest` and `rtSimpleReply` are false
   for these routines (`usr.bin/migcom/routine.c`), compared with
   Apple's migcom
   (`https://github.com/apple-oss-distributions/bootstrap_cmds`,
   `migcom.tproj/routine.c`).
2. **Inventory:** every message the kernel builds itself rather than
   through a generated stub (the `ipc_notify.c` templates and any
   other you find), each against every in-tree generated receiver for
   it (libdispatch, launchd, libxpc and others you find), with simple
   or complex on each side, before and after the fix. Also list
   generated client/server pairs whose bits change, with the scope
   comparison you used in op-628.
3. **Fix:** in the generator, following Apple's MIG: complex only when
   the body carries descriptors. Regenerate both sides together; no
   hand edits to generated code. Leave the dead-name decode in place
   and say in your record whether it is still needed. If the fix
   cannot be made in the generator, or would require changing
   kernel-built messages, stop and report the inventory before
   changing anything.
4. **Tests (Zig):** `dispatch_mach_test:send_possible` passes; for each
   kernel-built notification kind in the inventory with a generated
   receiver in the tree, one case where that receiver accepts the
   kernel's message.
5. **Self-check:** rebuild the RELEASE and KASAN overlays on
   `op552-overlay-base-r3.raw` (sha256
   `6f3b6e54606cecfbe3572cf5e2dee156c42499d113909351b811c41abe974059`),
   recording each overlay's and manifest's sha256, and run op-628's
   full plan with the new cases added. Order and stop point change:
   run the op-622 to op-631 cases first, then the earlier accepted
   cases, the 400-case repeat and the MIG modes, and let the batch run
   every case even after one fails, recording each failure with its
   serial lines. Any failure still means the profile does not pass,
   and after a failure you make no product change in this op: report
   all failures together. If RELEASE has any failure, do not boot
   KASAN. Expected on both: every case passes; the five MIG modes
   exit 0; the 400-case repeat passes; normal power-off; no assertion
   or fatal trap; on KASAN, no KASAN report. Two spare boots for
   harness faults; a wrong new test may be fixed and rerun within the
   boots (op-590's rule).

Evidence: add the cause, the inventory, the fix, the tests and the
runs (load, ATF counts, every failure with serial lines, MIG modes,
power-off line, serial paths and sha256) to `docs/op617-round3.md` as
`### op-631`, commit, and update its `selfcheck:` line.

## Limits

- Commits on `mach-fixes-6` in `wip-rmxos`, only for this item. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
