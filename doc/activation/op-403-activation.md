---
id: op-403
state: closed
agent: validator2
repo: rmx-validator2
idq: id-016
gate: self
authority: none beyond the defaults: read-only; no guests
updated: 2026-10-01T09:27Z
---
# op-403 — Validator 2: review op-401 — kernel-side observation of the PID-1 reaper

## Outcome

Context: ordinary debugging of our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source launchd as PID 1). The test checks whether launchd records each child's exit status
correctly, inside a disposable VM with no network.

Review op-401 (explorer1). You are one of two reviewers; do not read the other's notes before
your REPORT. Your lens: falsification: where a rule would let a wrong verdict through.

The artifact: `rmx-explorer1@f1df370a6b4e30e64cef98c556898b67a3b6d31d`
`findings/nx-r64z/20261001-op401-tier-u-kernel-side.md` (sha256
`1277d76973c929250efa62600c34438e26f43e0e00dff010157e3e799cdc6acd`). It replaces Tier U of the
PID-1 reaper contract. Tier U's `pid` provider cannot attach to PID 1, because FreeBSD sets
`P_SYSTEM` on init (`sys/kern/init_main.c:838`) and `ptrace` refuses such processes
(`sys/kern/sys_process.c:1153`; confirmed in op-400, rmx-gatekeeper1 `f417d01`).

Claims to check:
1. Every probe and field it relies on exists on alpha2 `2884304b` as cited (`syscall::wait4`,
   `fbt::proc_reap`, `fbt::proc_reparent`, `proc:::create` and `exit`, `profile-997`), and the
   cited lines say what the note says they do.
2. The status rules are right: return `args[1]` is not the status pointer; the detached loop's
   NULL pointer (`sbin/launchd/runtime.c:644-656`) forces `proc_reap`-based status; no status is
   invented on error or zero return.
3. The thread identification (the detached thread by its repeated `wait4(-1, NULL, WNOWAIT)` and
   same-thread consuming wait; the main thread by pid-specific waits tied to labels) is sound,
   and every case where it fails leads to INCONCLUSIVE, not to a guess.
4. For each failure mode (a), (b), (c), the OBSERVED, NOT-OBSERVED and INCONCLUSIVE rules can be
   decided from the named records, and none weakens op-322's verdict grammar. op-322 is at
   rmx-explorer1 `be1a3fb`, `findings/nx-r64z/20260717-op322-pid1-contract-correction.md`.
5. The updated Tier-1 and Tier-2 controls each keep a single named difference, and together cover
   every rule a classifier must enforce.

Distinguishing question: can each failure mode be decided correctly from kernel-side records alone
on alpha2, without attaching to PID 1 and without loosening the grammar?

Re-read OPS.md first: defaults and the REPORT block.
