---
id: op-392
state: closed
agent: advisor1
repo: rmx-advisor1
idq: id-046
gate: self
authority: none
updated: 2026-09-28T10:21Z
---
# op-392 — Advisor 1: independent deep dive — Mach's FreeBSD 12 assumptions revived on stable/15

## Outcome

This is open-source OS engineering: an internal architecture and code-quality review of rmxOS
code we author and ship. It is an independent review: another Advisor covered the same ground,
and we will compare the two. Do not read other Advisors' repos (`rmx-advisor2`–`rmx-advisor4`).

The lineage: XNU's Mach was ported by NextBSD onto FreeBSD 12.0 kernel interfaces, and rmxOS
imported that port onto FreeBSD stable/15 (snapshot `8c6a1c15`, then 28 commits). Every assumption
NextBSD made about FreeBSD 12 internals, and every place it departed from XNU, is now suspect.

The question: where does the Mach kernel integration at alpha2 `2884304b` rely on a FreeBSD
kernel behavior that differs between 12.0 and stable/15, or diverge from XNU semantics it claims
to preserve, in a way that can cause a real failure: a panic, a leak, a lost or duplicated message
or right, a use-after-free, a deadlock, or a wrong result? Look where these bugs live: proc, thread,
and task lifecycle and reuse; file and fd ops and their locking; kqueue and knote ownership;
locking, lock order, sleep, and wakeup; epoch and SMR; VM and copyin/copyout; credentials and
audit; Capsicum; syscall and event-handler registration; and module init order.

Return only findings, ranked by likelihood times impact. For each give: the assumption; where the
code makes it (rmxOS file:line, and the NextBSD original if it differs); what FreeBSD 15 actually
does (file:line in stable/15) or what XNU does (file:line); the concrete failure; your confidence;
and the smallest check that would confirm or clear it (a source trace, a probe, or a test).
Separate confirmed defects from suspected ones. Where a class of failures comes from the design
rather than one line, say so and name the design choice. Leave out checklist status and process
proposals. Keep it under about 300 lines.

## Inputs

- rmxOS: `/Users/me/wip-mach/rmx-implementer/wip-rmxos` at `2884304b67fc454ee60187ce4731fca01cbefe6a`
  (read with `git show`, `git diff`, and `git log` only): `sys/compat/mach/`, `sys/sys/mach/`,
  `sys/modules/mach/`, the FreeBSD files Mach calls into, and the Mach history from the import
  snapshot `8c6a1c15b394` onward. Where a failure depends on a build setting, read the build
  (`sys/modules/mach/Makefile`, the kernel config), not the config name. FreeBSD 12.0 interfaces
  are in the same repo as `origin/releng/12.0`; stable/15 is the base under alpha2.
- NextBSD's original port, FreeBSD 12.0-based, read-only: `/Users/me/wip-mach/nx/NextBSD-NextBSD-CURRENT/`.
- XNU, read-only: `/Users/me/wip-mach/reference/xnu-xnu-12377.121.6/` (`osfmk/ipc`, `osfmk/kern`).
  It is a newer XNU than NextBSD ported from; say so when a divergence may be version drift rather
  than a porting choice.

Re-read OPS.md first: defaults and the REPORT block.
