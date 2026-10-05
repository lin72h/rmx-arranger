---
id: op-495
state: draft
agent: implementer
repo: rmx-implementer
idq: id-046
gate: self
authority: launchd builds (no world); 2 ZFS images; 3 self-check boots; no push
expected: 2h
updated: 2026-10-05T03:30Z
---
# op-495 — Implementer: op-484 remediation (masked partial-receive error; stale j_port)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 2 hours** (test 30 min, fixes 20 min, two
images and self-checks 45 min, record 20 min).

validator3 reviewed op-484 (`mach-fixes-5@10a3fd65`): the demand
lookup, detach-before-close, drain buffers and loop exit, and the
test-hook isolation hold. Two fixes, on the same branch in
`build/op468/source`:

1. **Partial receive in the drain** (`sbin/launchd/core.c:7369-7381`):
   the switch matches bare `MACH_RCV_BODY_ERROR`, but the kernel ORs
   detail bits into that result (`ipc_kmsg_copyout_body` builds it
   with `|=`), so a partly received message falls to `default` and
   its rights are never released. Match it as libdispatch does,
   `(mr & ~MACH_MSG_MASK) == MACH_RCV_BODY_ERROR`, then
   `mach_msg_destroy`. No runtime test for this one (the drain cases
   stay out of scope); say in the record how the change is covered.
2. **Stale `j->j_port` after a failed setup**
   (`core.c:1699-1720`, `job_setup_machport`): when
   `runtime_add_mport` or `launchd_mport_notify_req` fails, the right
   is closed but `j->j_port` keeps the old name, and the caller at
   `core.c:9627-9631` then returns that name with
   `BOOTSTRAP_SUCCESS`. Create the right in a local, publish it to
   `j->j_port` only after every step succeeds, and leave
   `j->j_port == MACH_PORT_NULL` on every failure path.
   Test first (Zig, in `tests/lib/launchd`, with your fixture): make
   the notification request fail once for a chosen job, then check
   that `j->j_port` is `MACH_PORT_NULL`, the closed name is not
   handed out, a retry sets up a fresh working port, and an
   unrelated right that later reuses the old name is untouched.

Then two ZFS images (from `op417-alpha2-zfs-gpt.raw`, reusing the
existing world): base = `10a3fd65` + the new test (test-only hooks
on a side line as before), fixed = the fixes + the same tests (test
files identical). Self-check: the new case fails on base and passes
on fixed; all 68 earlier cases pass on fixed. Keep op-484's r7 pair.
Give the base test line a branch name (for example
`mach-fixes-5-op484-base` at `5565ec56`, and one for this op's base)
so those commits are kept.

Evidence: the commits; your op record with both fixes, the test and
its base and fixed results; both image hashes and BOMs (by path); the
`selfcheck:` line.

## Limits

- launchd and its tests only. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
