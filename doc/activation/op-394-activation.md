---
id: op-394
state: draft
agent: advisor2
repo: rmx-advisor2
idq: id-046
authority: none
updated: 2026-10-02T01:09Z
---
# op-394 — Advisor 2: design proposal — Mach names, task state, and the receive model on FreeBSD 15

## Outcome

This is open-source OS engineering: a design proposal for rmxOS kernel code we author and ship.
The three Mach reviews found that several classes of defects come from design choices, not single
lines. Point fixes in those areas wait for a design decision; this op produces the proposal the
Coordinator decides on.

Design questions, in priority order:
- **A. Port names as file descriptors.** Entry lifetime is owned by `fo_close`, user references
  live in `f_count`, and knotes and cross-task operations go through fd tables (op-389 #2, #12;
  op-392 F3, F7, S2–S5). Should names stay fd-backed with a corrected lifetime model, move to a
  Mach-owned name table as in XNU (with fds only where files are transferred), or something else?
- **B. Mach task and thread state on reusable proc and thread slots, with no teardown.** Rights
  leak and stale ports rebind to whatever reuses the slot (op-389 #4; op-392 F1, F2; op-393 N5).
  What lifecycle should task and thread state have on FreeBSD 15, and where are its init, exec
  and exit hooks?
- **C. Receive inside the kqueue readiness check** (op-389 #6, op-392 F4, S1), and the port-set
  wakeup races (op-392 F5; op-393 N2). What receive and wakeup model fits FreeBSD 15's kqueue?
- **D. The self-only model mixed with a MIG layer that acts on other tasks** (op-392 S5, op-393
  N5). Where these meet A–C, say how.

For each: two or three options, with what each fixes, costs, and breaks for userland (libmach,
libdispatch, launchd, libxpc); your recommendation; the object lifetime and locking rules it
implies (who holds which reference, which lock orders); how it would be introduced in steps that
each keep the system booting; and which ledger findings each step retires. Name what must be
decided before any code, and what can wait. Under about 300 lines, in a new document.

## Inputs

- rmxOS: `/Users/me/wip-mach/rmx-implementer/wip-rmxos` at `2884304b67fc454ee60187ce4731fca01cbefe6a`
  (read with `git show`, `git diff`, and `git log` only); `origin/releng/12.0` is in the same repo.
- Fix batch 1 (op-395, under review): branch `mach-fixes-1` at `5fa02fb5b0ebead338aa20e94e4dfe4bd586f5dd`
  in the same repo, 13 local fixes with tests. Treat them as done, and say if any conflicts with
  an option you propose.
- NextBSD, read-only: `/Users/me/wip-mach/nx/NextBSD-NextBSD-CURRENT/`. XNU, read-only:
  `/Users/me/wip-mach/reference/xnu-xnu-12377.121.6/`.
- The three reviews: your own op-389
  (`/Users/me/wip-mach/rmx-advisor2/op-389-mach-freebsd12-assumptions-alpha2.md`), and advisor1's
  op-392 and op-393 (`/Users/me/wip-mach/rmx-advisor1/op-392-mach-freebsd15-assumptions-findings.md`,
  `/Users/me/wip-mach/rmx-advisor1/op-393-mach-remaining-areas-findings.md`). The blind round is
  over, so you may read them.

Re-read OPS.md first: defaults and the REPORT block.
