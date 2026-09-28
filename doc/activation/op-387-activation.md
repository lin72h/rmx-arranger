---
id: op-387
state: draft
agent: advisor2
repo: rmx-advisor2
idq: id-042
needs: op-389
gate: self
authority: none
updated: 2026-09-28T08:03Z
---
# op-387 — Advisor 2: deep dive — libdispatch and the workqueue it runs on, at alpha2

## Outcome

This is open-source OS engineering: an internal architecture and code-quality review of rmxOS
code we author and ship. Same form as your op-389; don't repeat op-383 or op-389.

The lineage: Apple libdispatch-442.1.4 was ported by NextBSD onto FreeBSD 12.0, together with a
kernel pthread workqueue (`kern_thrworkq.c`); rmxOS carries both onto stable/15, and libdispatch
rides on the Mach IPC that op-389 reviewed.

The question: where does libdispatch at alpha2 `2884304b`, or the kernel workqueue under it, rely
on a kernel or libc behavior that differs from what it was written for (Darwin, or FreeBSD 12.0),
or diverge from 442.1.4's semantics, in a way that can cause a real failure: a hang or lost
wakeup, a starved or over-committed queue, a lost, duplicated or late event or timer, a leaked or
double-released object or Mach right, a crash, or a wrong result? Look where these bugs live:
the kevent and kevent64 shim and EVFILT_MACHPORT use; Mach receive, send-once and notification
handling in sources and the manager queue; workqueue thread admission, overcommit, priority and
exit, in both the library and `kern_thrworkq.c`; timers and clock units; semaphores and the
wakeup paths; fork and atfork; and the FreeBSD compatibility shims.

Return only findings, ranked by likelihood times impact. For each give: the assumption; where the
code makes it (rmxOS file:line, and the 442.1.4 or NextBSD original if it differs); what
stable/15 or XNU actually does (file:line); the concrete failure; your confidence; and the
smallest check that would confirm or clear it. Separate confirmed defects from suspected ones.
Where a failure depends on a build setting, read the build, not the config name. Leave out
checklist status and process proposals. Keep it under about 300 lines.

## Inputs

- rmxOS: `/Users/me/wip-mach/rmx-implementer/wip-rmxos` at `2884304b67fc454ee60187ce4731fca01cbefe6a`
  (read with `git show`, `git diff`, and `git log` only): `lib/libdispatch/`, `lib/libblocksruntime/`,
  `sys/kern/kern_thrworkq.c` and its headers and syscalls, and the libc/libthr parts they call.
  `origin/releng/12.0` is in the same repo.
- Apple libdispatch-442.1.4, read-only: `/Users/me/wip-mach/reference/libdispatch-442.1.4/`
  (rmxOS adds `src/freebsd_compat.h`, `src/freebsd_kevent64.c`, `src/mach-notify-decode.h`).
- NextBSD's port, FreeBSD 12.0-based, read-only: `/Users/me/wip-mach/nx/NextBSD-NextBSD-CURRENT/`
  (`lib/libdispatch/`, `sys/kern/kern_thrworkq.c`).
- XNU, read-only: `/Users/me/wip-mach/reference/xnu-xnu-12377.121.6/` (`bsd/pthread/` for the
  workqueue). It is much newer than 442.1.4; say so when a divergence may be version drift.
- Build facts: libdispatch builds with `-DDISPATCH_DEBUG=1` (`lib/libdispatch/Makefile`). The
  op-364 `mach.ko` was built as a standalone module with an empty `opt_global.h`, so the kernel's
  INVARIANTS does not apply to it.
- Known: op-372 passed the dispatch probe's 4 cases on the alpha2 image; workqueue attribution
  was untested. Your op-383 and op-389 consults, for what is already known.

Re-read OPS.md first: defaults and the REPORT block.
