---
id: op-550
state: issued
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-061
authority: 4 boots max on copies of the op547 ZFS pair, 5 min each; doas vmm.ko, bhyve; push rmx-gatekeeper1 main
expected: 1h30m
issued-at: 2026-10-08T02:10Z
updated: 2026-10-08T02:10Z
---
# op-550 — Gatekeeper 1: proof of op-547 (per-thread MIG reply port, ZFS pair, launchd repeat)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 1.5 hours.**

id-061 is the missing `launchd control reply` and the shutdown that
did not finish, which you saw in op-521. Its cause: libmach shared one
MIG reply port among all threads of a process. op-547 makes it
per-thread (`mach-fixes-6@e2fa6df9`, only libmach changes). New test
program `/usr/tests/lib/libmach/mig_reply_ports_test` with modes
`identity`, `concurrent`, `dealloc`, `exit`, `fork`. Expected results:
`/Users/me/wip-mach/rmx-implementer/docs/op547-mig-reply-port.md`
(base: `build/op547/runtime/result-3.json` in that repo).

Images (ZFS, work on copies; test files identical; check from the
BOMs that only libmach differs):
- base = `mach-fixes-6-op547-base@e29f8b15` (`cb664232` + the tests):
  `/Users/me/wip-mach/rmx-implementer/build/op547/r2/images/op547-base-tests-r2.raw`
  sha256 `f577e6628047290f48eae60debf8b9b97ecae08be37389c6f15b4607ebbf2144`
  BOM `/Users/me/wip-mach/stage/artifacts/op547-base-tests-r2/bom.json`
- fixed = `mach-fixes-6@e2fa6df9`:
  `/Users/me/wip-mach/rmx-implementer/build/op547/r2/images/op547-fixed-tests-r2.raw`
  sha256 `1d7ca523895fab9bff0e518c991fa6fc3e6fa7350db07136d1a9d236bc503387`
  BOM `/Users/me/wip-mach/stage/artifacts/op547-fixed-tests-r2/bom.json`

Use your op-540 harness, extended to the new program and to the
paced launchd repeat (`/usr/tests/lib/launchd/op526_repeat 100`);
check every command against the image first.
1. Base: one boot with the five new modes. Expected, from the base
   record: `identity`, `concurrent`, `dealloc` and `exit` show one
   shared reply port (the same name in every thread; `concurrent`
   ends with `MIG_REPLY_MISMATCH` (-301); the exiting thread's receive
   right stays); `fork` works on base too.
2. Fixed: one boot with all 93 earlier cases and the five new modes,
   all expected to PASS (distinct per-thread names, no -301, the
   exiting thread's right released, the child uses its own port).
3. Fixed: one boot with the paced launchd repeat (400 cases), expected
   no `launchd control reply missing`, then a normal shutdown and
   power-off.
One spare boot, only for a boot that fails before its commands run.

Result: one table, expected against observed, with the serial line for
each case or mode, each FAIL's printed reason, the repeat's count and
the power-off line, and every mismatch listed.

Evidence by path; hash only each boot's raw serial log. Commits on
origin.

## Limits

- No product edits. If one case cannot run, record it and finish the
  others.

Re-read OPS.md first: defaults and the reply block.
