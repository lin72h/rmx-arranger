---
id: op-529
state: dropped
agent: implementer
repo: rmx-implementer
idq: id-046
authority: test and fixture builds; kernel/mach.ko reused from existing builds (no new kernel source change); 1 new ZFS image; 4 self-check boots; no push
expected: 3h
updated: 2026-10-07T05:06Z
---
# op-529 — Implementer: op-521 missing launchd reply, is it new in mach-fixes-6 (repeat on the 2de5f1d4 kernel) and where the request waits

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 3 hours** (image 45 min, repeat runs 1.25 h,
record 1 h).

op-526 reproduced op-521's failure (`docs/op524-recovered-readiness.md`,
serial `/Users/me/wip-mach/stage/vm/runs/op526-selfcheck/rmx-selfcheck-op526-repeat-paced-1791343438/serial.txt`):
in the paced repeat, `launchd_consumer_test:setup_retry` got no reply
after 71 passing cases; launchd's main thread was in a Mach receive
(`ipc_mqueue_receive`), the demand set had no members and nothing
ready, and shutdown did not finish. So the request was not waiting on
the demand set that op-515 changed. First establish whether the
failure is new on `mach-fixes-6` at all, then where the request
waits.

1. **Older kernel, same repeat.** Stage one image identical to
   `op526-fixed-tests-r1.raw` except the kernel and `mach.ko`, which
   come from `mach-fixes-5@2de5f1d4` (the build gatekeeper1 proved in
   op-511; reuse that build, no new kernel source change). Show from
   the METALOG/BOM diff that only those two files differ. Run your
   paced repeat on it for at least 200 launchd cases or until a reply
   is missing, in up to two boots. If it fails there too, the failure
   predates `mach-fixes-6`; say so.
2. **Same repeat on the `mach-fixes-6` kernel, with launchd recording
   its own state.** Extend the test-only hook in launchd's fixture
   build (`libop484_launchd.so`, compiled only with
   `LAUNCHD_CONSUMER_FIXTURE`) so that, when a control request has had
   no reply for a few seconds, launchd logs its own state: for each of
   its own receive rights in the main IPC set (`ipc_port_set` in
   `sbin/launchd/runtime.c`) and the request's reply port, the message
   count and set membership from `mach_port_get_attributes`, and which
   set its main thread is receiving on. Use the remaining boots on
   `op526-fixed-tests-r1.raw` rebuilt with that hook only (same
   kernel, same launchd binary). Report whether the request message is
   queued on a launchd port while launchd's main thread waits, or was
   never queued.
Keep both images' test files identical to op-526 except the fixture
hook in item 2.

Evidence: commits; your op record (`docs/op529-launchd-reply.md`)
with both repeat records (iterations, any missing reply, launchd's
logged state), image hashes and BOMs by path; the `selfcheck:` line.
Name a cause only with file:line from the source.

## Limits

- No kernel source, launchd product, libdispatch or libxpc change;
  the fixture hook and the repeat supervisor only. Do not fix the
  cause in this op. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
