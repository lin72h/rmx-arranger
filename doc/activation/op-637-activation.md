---
id: op-637
state: issued
agent: implementer
repo: rmx-implementer
idq: id-063
authority: read-only source trace; up to 2 diagnostic KASAN boots on copies of op-633's overlay with diagnostic settings only; commits on a diag-witness-op633 branch and in rmx-implementer; no commits to mach-fixes-6; no push
expected: 2h
issued-at: 2026-10-11T09:23Z
updated: 2026-10-11T09:23Z
---
# op-637 — Implementer: find the source of the shutdown WITNESS warning (process lock, then btag lock) on op-633's KASAN run

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 2 hours.**

Your op-633 KASAN run printed one WITNESS lock-order warning at
shutdown (`build/op633/runs/rmx-selfcheck-op633-fixed-kasan-r1-1791702221/tests/serial.txt`
from line 28749): process lock taken at `kern/kern_sig.c:2145`
(`trapsignal`), then btag lock at `kern/subr_vmem.c:758`, through a
UMA allocation. The printed stack stops at frame 17, below the caller
that held the process lock. No earlier KASAN run had it (op-607,
op-610, op-617, op-621). The question: which process took a trap
signal at shutdown, why, and whether anything changed since
`1cad29b5` (the MIG generator, regenerated `launchd`, `asld`,
`notifyd`, libraries) causes it.

1. **Source trace first:** what in `trapsignal`'s path allocates
   memory with the process lock held, and which callers reach it.
2. **Up to 2 diagnostic boots** of copies of op-633's KASAN overlay,
   with diagnostic settings only (for example `kern.logsigexit=1`, a
   deeper WITNESS stack, or core dumps kept), to name the process,
   the signal and the instruction it stopped at. No product change.
3. **Answer:** the process and signal; whether the trap is ours
   (which commit, `file:line`) or native FreeBSD; whether this lock
   order can deadlock or is a known benign pair; and the smallest fix
   direction if it is ours. If it does not recur in 2 boots, say so
   and stop.

Evidence: `docs/op637-witness.md` with the trace, both boots (load,
settings, serial paths and sha256, the warning or its absence), and
the answer; commit.

## Limits

- Diagnostic code, if any, on a `diag-witness-op633` branch, never on
  `mach-fixes-6`. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
