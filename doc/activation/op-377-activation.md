---
id: op-377
state: returned
agent: explorer1
repo: rmx-explorer1
idq: id-016
gate: self
authority: none
updated: 2026-09-28T05:25Z
---
# op-377 — Explorer 1: re-base the op-318/op-322 PID-1 contract onto alpha2

## Outcome

Your op-322 note (`findings/nx-r64z/20260717-op322-pid1-contract-correction.md`, verdict
CORRECTED-CONTRACT-READY-FOR-VALIDATION) corrected op-318's PID-1 launchd contract at
`alpha@26655e67`. The candidate is now alpha2 `2884304b`, which contains alpha and adds 1,930
commits, mostly the upstream stable/15 merge. Before both Validators review the contract,
establish whether it still holds on alpha2. Commit one addendum note,
`findings/nx-r64z/20260928-op377-alpha2-rebase.md`, that says for each contract fact the delta
touches whether it holds or changed (with the new fact and its source lines), and ends with one
verdict: HOLDS-ON-ALPHA2 or NEEDS-AMENDMENT, listing each exact amendment.

Already checked by the Arranger (confirm, do not re-derive the contract):
- `sbin/launchd/runtime.c`, `core.c`, and `launchd.c` at `2884304b` still match op-322's sha256 pins.
- The three staging scripts in `/Users/me/wip-mach/rmx-implementer/scripts/bhyve/` still match
  op-322's pins.
- In the contract's areas, only these changed between the two commits: `sys/kern/kern_exit.c`
  (from upstream stable/15, including `9d6498310f5c` "processes: add zombie references, each of
  them prevents reap", `ecdc9cfea64c` "pdwait(2): change handling of the exited processes", and
  `83fa3c3ad844`) and 26 files under `libexec/rc/` (`rc`, `rc.conf`, `rc.subr`, `rc.d/*`).

The distinguishing questions: do the `kern_exit.c` changes alter what a PID-1 launchd reaping
unknown children observes (wait4 results, ECHILD, zombie lifetime, the raw status of C5, the
tier-K probe of C4)? Do the `libexec/rc` changes alter the rc-chain hybrid topology (op-201's
`init_path` plus the `/etc/rc` chain-load) or any row of op-318's activation-delta census?

## Inputs

- Product source `/Users/me/wip-mach/rmx-implementer/wip-rmxos`: base
  `26655e67872cd55cff0a272b32b7895f55368033` (branch alpha) and candidate
  `2884304b67fc454ee60187ce4731fca01cbefe6a` (branch alpha2, on origin). Read it with
  `git show` and `git diff` only.
- In your repo: the op-318 note `findings/nx-r64z/20260712-op318-pid1-preview-activation-contract.md`
  and the op-322 note.

## Limits

Read-only apart from the addendum note and its one commit: no builds, runs, guests, or traces, and
no push. Read-only commands such as `git show` and `git log` are fine.

Before you start, re-read OPS.md in your repo: it holds the defaults and the REPORT block.
