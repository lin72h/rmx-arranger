---
id: op-401
state: returned
agent: explorer1
repo: rmx-explorer1
idq: id-016
gate: both
authority: none beyond the defaults: documentation only; no guests; push rmx-explorer1 main
updated: 2026-10-01T09:16Z
---
# op-401 — Explorer 1: amend the PID-1 reaper contract — observe launchd as PID 1 from the kernel side

## Outcome

Context: ordinary debugging of our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source launchd as PID 1). The test checks whether launchd records each child's exit status
correctly; everything runs in a disposable VM with no network.

Write a contract amendment, `findings/nx-r64z/20261001-op401-tier-u-kernel-side.md`, to the
PID-1 reaper contract (op-318 as corrected by op-322, op-377 and op-380, all at `be1a3fb`). It
replaces Tier U, which can no longer be met.

**Why Tier U fails.** Tier U puts DTrace `pid` provider probes on launchd's `jobmgr_reap_pid`,
`job_reap` and `waitpid_loop`. That provider attaches with `ptrace`, and FreeBSD never lets
anything attach to PID 1: `create_init` sets `P_SYSTEM` on init (`sys/kern/init_main.c:838`,
identical in upstream stable/15), and `ptrace` refuses `P_SYSTEM` processes with `EINVAL`
(`sys/kern/sys_process.c:1153`). gatekeeper1 confirmed this on alpha2 in op-400: `PT_ATTACH` on
PID 1 fails with errno 22, while an ordinary process attaches and traces normally
(rmx-gatekeeper1 `f417d01`, `build/op400/runtime/rmx-op400-alpha2-20261001T085835Z-62279/serial.raw`,
lines 130-161).

**The replacement** observes PID 1 from the kernel side, which needs no attach. Define, for each
failure mode, which records prove OBSERVED and NOT-OBSERVED, and which leave it INCONCLUSIVE:
- every `wait4` call made by PID 1 (`syscall::wait4:entry/return` with `pid == 1`), with the
  thread ID, the pid argument, the return value and the raw status. This is how the detached
  `waitpid_loop` thread is told apart from launchd's main loop. Say how that thread is identified
  (for example the thread blocked in `wait4(-1, …)`) and what to do if it cannot be;
- child exits from the `proc` provider (`proc:::exit` and the reparenting of W4 and W5);
- CPU use by PID 1's threads for failure mode (c), from `profile` sampling with `pid == 1`,
  aggregated by thread;
- launchd's own records for each managed job: its raw `LastExitStatus` and its log line when
  a reap fails.

Then:
- Restate failure mode (b) in these terms: the `waitpid_loop` thread's `wait4` returns a managed
  job's pid, and launchd later records that job with the synthesized status.
- Update the Tier-1 runtime controls and the Tier-2 classifier controls to match, keeping each
  control's single named difference.
- Keep everything else in op-322: identity, verdict grammar, and product failure counted as
  product evidence.
- Check that every probe exists on alpha2 by reading the source (provider and probe names in
  `sys/cddl` and `sys/kern`). Cite file:line for each.

Write in engineering terms (see your AGENTS.md project context).

## Limits

- Documentation only: no guest runs and no product changes. Earlier contract notes stay as
  written; this note supersedes Tier U only.
- If kernel-side records cannot settle a failure mode, say so plainly. Do not weaken the
  verdict grammar to fit.

Re-read OPS.md first: defaults and the REPORT block.
