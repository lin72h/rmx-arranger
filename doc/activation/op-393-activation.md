---
id: op-393
state: closed
agent: advisor1
repo: rmx-advisor1
idq: id-046
needs: op-392
gate: self
authority: none
updated: 2026-09-28T11:06Z
---
# op-393 — Advisor 1: finish the Mach review — the areas op-392 did not reach

## Outcome

This is open-source OS engineering: a correctness and robustness review of rmxOS kernel code we
author and ship, so that the Implementer can fix it. It completes your op-392 review; the goal is
correct code, and each finding should point toward its fix.

Your op-392 review did not reach these parts of the Mach integration at alpha2 `2884304b`:
- `sys/compat/mach/mach_clock.c` and `clock_server.c`: the clock calls and their timer callouts,
  including a pending callout whose port is destroyed;
- `sys/compat/mach/mach_semaphore.c`;
- `sys/compat/mach/ipc/ipc_kobject.c` and the MIG server dispatch (`*_server.c`, the `defs/`);
- `sys/compat/mach/ipc/ipc_space.c` and `ipc/ipc_notify.c`;
- the trap argument path in `mach_traps.c` (how amd64 passes the arguments, and the
  `mach_msg_overwrite_trap` tail).

Also firm up the op-392 claims that rest on shallow checks: the workqueue per-thread state that
is freed only on `thr_exit`; the port-set zone's flags behind S2; F2's rebinding case; and
S1. For S1, existing guest serial logs show a WITNESS lock-order reversal between
`ETAP_IPC_RPC` (1st) and `ETAP_IPC_IS` (2nd), not the pair S1 predicts. Explain it from source.
This is best effort: cover what you can, and list what you did not reach.

Same form as op-392: confirmed and suspected findings, ranked by likelihood times impact, each
with the assumption, the rmxOS lines (and NextBSD's or XNU's where they differ), the concrete
incorrect behavior, your confidence, and the smallest regression test or source trace that would
confirm it; plus the fix direction. Add a "checked and cleared" list and any design cause that is
new beyond op-392's classes A to E. Write it as a new document; don't edit op-392's. Under about
200 lines. Also add your LOCAL.md note: `mach.ko` is built standalone, so the kernel's option
headers do not apply to it.

## Inputs

- rmxOS: `/Users/me/wip-mach/rmx-implementer/wip-rmxos` at `2884304b67fc454ee60187ce4731fca01cbefe6a`
  (read with `git show`, `git diff`, and `git log` only); `origin/releng/12.0` is in the same repo.
- NextBSD, read-only: `/Users/me/wip-mach/nx/NextBSD-NextBSD-CURRENT/`. XNU, read-only:
  `/Users/me/wip-mach/reference/xnu-xnu-12377.121.6/`.
- Your own op-392 document. Still do not read other Advisors' repos.

Re-read OPS.md first: defaults and the REPORT block.
