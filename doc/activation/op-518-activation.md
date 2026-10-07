---
id: op-518
state: closed
agent: implementer
repo: rmx-implementer
idq: id-046
authority: kernel and mach.ko builds (no world); 1 new ZFS fixed image (op-515's base image reused); 3 self-check boots; no push
expected: 2h
issued-at: 2026-10-07T01:07Z
updated: 2026-10-07T05:40Z
---
# op-518 — Implementer: op-515 continuation (start the Mach notification worker at SI_SUB_TASKQ; fixed image and self-check)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 2 hours** (change 20 min, fixed image 30 min,
self-check 40 min, record 30 min).

op-515 stopped correctly after its fixed image stopped during boot
(`docs/op515-mach-readiness.md`; serial
`/Users/me/wip-mach/stage/vm/runs/op515-selfcheck/rmx-selfcheck-op515-fixed-all-1791333901/serial.txt`):
`mi_startup` → `mach_mod_init` → `ipc_pset_work_init`
(`sys/compat/mach/ipc/ipc_pset.c:193-206`) →
`taskqueue_start_threads` → `kthread_add`, which panics with
"kthread_add called too soon". mach.ko is loaded by the loader, so
its module init runs at `SI_SUB_KLD`, before `proc0.p_stats` exists
(`SI_SUB_INTRINSIC`; `sys/kern/kern_kthread.c:270`). FreeBSD's own
thread taskqueues start at `SI_SUB_TASKQ`
(`sys/sys/taskqueue.h:184`). This op finishes op-515 on
`mach-fixes-6` (now `af37956e`).

Change:
1. Keep creating the queue and its task in module init, and start its
   thread from a `SYSINIT` at `SI_SUB_TASKQ` (or later), as FreeBSD
   does. It must also work when mach.ko is loaded after boot. Work
   enqueued before the thread starts waits for it; confirm nothing
   needs a notification before then.
2. Module unload drains and frees the queue as op-515 does now.
No other change to op-515's rules or tests.

Then rebuild the kernel and `mach.ko` and stage one new fixed image
(from `op417-alpha2-zfs-gpt.raw`, as op-515 did). Reuse op-515's base
image and its recorded base results; the test files stay identical.
Show the new fixed image differs from op-515's base only in the
kernel and `mach.ko` from the METALOG/BOM diff.

Self-check: one boot of the fixed image with all 87 cases op-515
planned for it, all expected to PASS; the serial log shows the worker thread
starting. If the boot stops before the tests, keep the serial log,
use one more boot only after a source correction, and report.

Evidence: the commit; an addendum to `docs/op515-mach-readiness.md`
with the change, the base results (reused) and the fixed results;
the new image's hash and BOM (by path), with op-515's base image and
BOM; the `selfcheck:` line.

## Limits

- `sys/compat/mach` only. No test change, no libdispatch, launchd or
  libxpc change. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
