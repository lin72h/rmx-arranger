---
id: op-604
state: draft
agent: validator1
repo: rmx-validator1
idq: id-051
authority: none beyond the defaults: read-only; no guests
expected: 4h
updated: 2026-10-10T00:21Z
---
# op-604 — Validator 1: Mach review round 2 (blind) of mach-fixes-6@b61f0f91 — what is missing

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). This is a source-only correctness review of kernel code
we author and ship, so that the Implementer can fix it.

**Expected time: about 4 hours.**

The Mach integration has been through four reviews and six fix
branches (`mach-fixes-1` to `-6`) since alpha2 `2884304b`. Its fix list is done and proven on
RELEASE and KASAN kernels at `mach-fixes-6@b61f0f916417`. This is the
second independent round: you and one other Validator, on a different
model, review the same code without seeing each other's work. Do not
read the other Validator's repo, and do not read earlier review
documents: read the code as it is now. Where the two of you find the
same things, reading has done its job.

Your lens is completeness: what is missing. A reference, right or
lock taken on one path and not released on another; a Mach contract
case the code does not handle (a disposition, a flag, an error
return, a count); teardown that skips an object; a state the code
assumes but never sets up.

What to read, most effort first:
1. The IPC core: `sys/compat/mach/ipc/` (rights, entries, ports, port
   sets, messages, queues, notifications, spaces).
2. Names as file descriptors: the Mach fileops and the descriptor
   hooks in FreeBSD (`git diff 2884304b b61f0f91 --
   sys/kern/kern_descrip.c sys/sys/file.h`).
3. Task and thread objects and their lifetime: `sys/compat/mach/kern/`,
   `mach_task.c`, `mach_thread.c`, and the hooks in
   `sys/kern/kern_exec.c`, `kern_thread.c`, `kern_thr.c`,
   `kern_kthread.c`, `sys/sys/proc.h`.
4. Readiness-only Mach kevents (`ipc/ipc_pset.c` and the kqueue
   filter), the trap layer (`mach_traps.c`), the MIG dispatch
   (`ipc/ipc_kobject.c`) and the hand-written server routines.
5. `lib/libmach`.
Generated MIG stubs (`*_server.c`, `*_user.c`) only where a routine you
read depends on them.

Decided for 1.0, so judge the code against it rather than propose
changing it:
- A Mach port name is a file descriptor (NextBSD's design). Entries
  carry their own references and user references; the descriptor
  holds one entry reference; Mach code never derives user references
  from `f_count` or edits it.
- Closing a Mach name revokes it under its space lock, through the
  descriptor-removal hook; `dup` and `dup2` of a Mach name are
  refused; every other fd operation has a defined error.
- One Mach space per fd table; processes sharing a table share its
  space. Ordinary fork, vfork and posix_spawn copy the table, so
  names are not inherited; exec unshares and gives a fresh space.
- Names reuse fd numbers without generation bits; kernel objects hold
  references, never names. Names count against `RLIMIT_NOFILE`.
- One task or thread object per lifetime, with full teardown.
- Mach kevents report readiness only; receiving happens in `mach_msg`.
  Closing a name removes its kqueue registrations silently, as for
  any fd.
- Cross-task calls: only `task_set_special_port` (seatbelt, access and
  debug-control selectors) and `task_set_exception_ports` on another
  task; every other call on another task returns
  `KERN_NOT_SUPPORTED`. Exception ports are stored; Darwin exceptions
  are not delivered.
- Accepted 1.0 gaps, not findings: a dead-name notification may be
  lost when allocation fails; VM operations on another task, one-byte
  userland `vm_prot_t`, large OOL sends failing under memory
  pressure; `TASK_NAME_PORT`, `mach_vm_read`, `task_threads` and
  `task_info` flavors other than basic return not-supported.
A finding that only an XNU-style name table could fix: tag it "needs
the name table" and keep it short.

Write `reviews/op-604/mach-round2.md`, under about 250 lines: findings
ranked by likelihood times impact, each with the rmxOS
`file:line`, what the code does and which rule or Mach contract it
does not meet (XNU's or NextBSD's lines where they differ), your
confidence, the smallest check that would confirm it (a test or a
source trace), and the fix direction. Add a "checked and cleared"
list and a list of what you did not reach. In the reply, `verdict`
means: `CLOSE` if you found nothing that must be fixed for 1.0,
`REMEDIATE` with the findings that must.

## Inputs

- rmxOS: `/Users/me/wip-mach/rmx-implementer/wip-rmxos` at
  `b61f0f9164170ed9d9d2b3fd312e34eee2603f09` (read with `git show`,
  `git diff`, `git log`, `git grep` only). History since alpha2:
  `git log --oneline 2884304b..b61f0f91 -- sys/compat/mach sys/sys/mach`.
- XNU, read-only: `/Users/me/wip-mach/reference/xnu-xnu-12377.121.6/`
  (`osfmk/ipc`, `osfmk/kern`). NextBSD, read-only:
  `/Users/me/wip-mach/nx/NextBSD-NextBSD-CURRENT/`.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
