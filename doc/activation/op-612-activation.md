---
id: op-612
state: draft
agent: validator2
repo: rmx-validator2
idq: id-051
authority: none beyond the defaults: read-only; no guests
expected: 4h
updated: 2026-10-10T02:37Z
---
# op-612 — Validator 2: Mach review round 3 (blind) of mach-fixes-6@b127415a — what is missing

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). This is a source-only correctness review of kernel code
we author and ship, so that the Implementer can fix it.

**Expected time: about 4 hours.**

Round 2 (two Validators, blind) found eleven defects with no overlap
between the reviewers; they are fixed at `mach-fixes-6@b127415a7435`
and pass 773/773 on RELEASE and KASAN kernels. No overlap means
reading has not yet reached diminishing returns, so this is round 3:
you and one other Validator, on a different model, again without
seeing each other's work, on the parts neither round-2 reviewer
reached. Do not read the other Validator's repo or earlier review
documents: read the code as it is now.

Your lens is completeness: what is missing. A reference, right or
lock taken on one path and not released on another; a Mach contract
case the code does not handle (a disposition, a flag, an error
return, a count); teardown that skips an object; a state the code
assumes but never sets up.

What to read, most effort first:
1. Message bodies: descriptor copyin, copyout and destruction in
   `sys/compat/mach/ipc/ipc_kmsg.c` (port, port-array and OOL
   descriptors, file-context ports, partial failure part-way through
   a body).
2. Port internals: `ipc/ipc_port.c` (allocation, destruction, dead-name
   and no-senders notification requests, `ipc_port_check_circularity`).
3. The VM routines: `mach_vm.c` and the hand-written parts of
   `vm_map_server.c` and `mach_vm_server.c`.
4. The round-2 fixes: `git diff b61f0f91 b127415a -- sys lib`.
5. `lib/libmach` (traps, `mach_msg`, reply ports, `mach_msg_destroy`),
   then `kern/thread_pool.c`, `proc_info.c`, `mach_debug.c`,
   `mach_processor.c`, and the `thread_block` lock handling in the
   scheduler shim.
Generated MIG stubs (`*_server.c`, `*_user.c`): check each routine
you read for its request-to-object translation and the release of
what it translated, on success and on error.

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
  `task_info` flavors other than basic return not-supported;
  `task_terminate` and named insertion of a file-context port return
  not-supported; `MACH_RCV_OVERWRITE`, scatter receive and trailers
  above `MACH_RCV_TRAILER_CTX` are refused.
A finding that only an XNU-style name table could fix: tag it "needs
the name table" and keep it short.

Write `reviews/op-612/mach-round3.md`, under about 250 lines: findings
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
  `b127415a7435d89be0a74ddd5aee094a0e5de100` (read with `git show`,
  `git diff`, `git log`, `git grep` only). History since alpha2:
  `git log --oneline 2884304b..b127415a -- sys/compat/mach sys/sys/mach`.
- XNU, read-only: `/Users/me/wip-mach/reference/xnu-xnu-12377.121.6/`
  (`osfmk/ipc`, `osfmk/kern`). NextBSD, read-only:
  `/Users/me/wip-mach/nx/NextBSD-NextBSD-CURRENT/`.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
