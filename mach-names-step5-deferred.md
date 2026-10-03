# Mach names: keep NextBSD's fd design for 1.0, defer the XNU name table (step 5)

Status: decision record (Coordinator, 2026-10-02). Tracked as [id-056](idq/id-056-xnu-name-table-step5-deferred.md).
Sources: advisor2's op-394 proposal (`rmx-advisor2@6c4667b`, revised `519ec47`) and its NextBSD
rationale (`02bc161`); the review findings in [id-046](idq/id-046-mach-kernel-defects-op389.md).

## Decision

rmxOS 1.0 revives NextBSD's design: a Mach port name **is** a file descriptor (op-394 option A1,
"corrected fd backend"). The rest of 1.0's Mach work follows op-394:
- **B2:** one task or thread object per lifetime, with full teardown;
- **C1:** kqueue only signals that a message is ready; receiving happens in `mach_msg`;
- **D2:** cross-task MIG calls only where the target is held and checked.

Op-394's steps 2-4 are in 1.0. **Step 5** (switch to an XNU-style, Mach-owned name table, with
fileports for files, and possibly direct receive through a kqueue callback, C3) is **deferred past
1.0**.

Why: step 5 is a large change to kernel ownership and to the ABI, against 1.0's aim of reviving
NextBSD. NextBSD chose fds for real reasons, not just for debugging. They give allocation, fd
limits and accounting, lifetime through file reference counts, kqueue integration, file transfer,
Capsicum compatibility and `fstat`/`procstat` visibility, all for free (`02bc161`). Steps 2-4 fix
the defects and are needed under either design.

## Limitations we accept in 1.0, and the rule for each

These are the traps of "name = fd". Each rule says how 1.0 code avoids the trap.

| # | Limitation | Rule in 1.0 |
|---|---|---|
| 1 | The fd reference count is not the Mach user-reference count; using one for the other caused op-389 #2 and op-392 S2/S3. | Entries carry their own references and urefs (step 2). The fd is a proxy holding one entry reference. Never derive urefs from `f_count`, and never edit `f_count` from Mach code. |
| 2 | `close`, `closefrom`, `dup`, `dup2` and `fcntl` act on Mach names because they are fds. | Closing a Mach name revokes it under its space lock, through a descriptor-removal hook (step 2). `dup` and `dup2` of a Mach name are rejected unless a step-2 brief defines alias semantics. Batch-1 fileops give every other operation a defined error. |
| 3 | A shared fd table (`rfork` without `RFFDG`/`RFCFDG`) shares Mach names between processes (op-389 #11). | One Mach space per fd table: processes that share a table share its space and names, and the space lives until the last process using the table exits. No per-task denial of names (decided 2026-10-02, op-426). Ordinary fork, vfork and posix_spawn copy the table, so Mach names stay non-inheritable there; exec unshares, giving a fresh space. In-place `rfork` (no `RFPROC`) replaces or copies the table without Mach names; Mach rebinds the task to a fresh space lazily at its next Mach operation, keeping task-level ports (no FreeBSD hook; decided 2026-10-03, op-430). |
| 4 | Port names reuse fd numbers at once and carry no generation bits (`sys/sys/mach/port.h:219-230`), so a stale name can refer to a new port. macOS has generations. | Kernel objects hold references, not names (knotes pin the entry, step 2). Userland must not keep a name after deallocating it. Document this as a known difference from macOS; parity tests must not depend on generation bits. |
| 5 | Mach names count against `RLIMIT_NOFILE` and `maxfilesperproc`. | Accept it. Size limits for launchd and other daemons that hold many ports; note in release notes. |
| 6 | Cross-task operations need the other task's fd table. | D2 only: a call proceeds only when the target task and its table are held and checked (after step 3). Foreign name-space operations stay disabled in 1.0. |
| 7 | Mach names must not travel as ordinary fds. NextBSD made them non-passable (`f3af7791`). | Keep them non-passable over Unix sockets and not inherited by `fork`. Files cross Mach messages only through the file-transfer path, which preserves Capsicum rights (batch-1 fix 10). |
| 8 | Exec keeps or drops fds by fd rules, not Mach rules. | Exec policy for special and bootstrap ports is defined in step 3; Mach entries are cleaned by Mach's exec hook, not by `close-on-exec`. |
| 9 | Direct receive inside kqueue's readiness check loses messages (op-389 #6, op-392 F4). | C1: kqueue reports readiness only; receive happens in `mach_msg`. libdispatch uses its receive adapter. No direct-receive kevents in 1.0. |

## Receive model for 1.0 (Coordinator, 2026-10-02)

The design for C1 on the fd backend is advisor2's op-421 note (`rmx-advisor2@5bfc3e1`), with one
change. Its "native EOF retirement helper" is **not** adopted for 1.0. That helper would change
FreeBSD's `kern_event.c` and `kern_descrip.c` so that closing a Mach name delivers one EOF event per
kqueue registration before the fd number is reused.

1.0 keeps FreeBSD's native close behaviour instead: closing a Mach name silently removes its
kqueue registrations, as for any fd. Consumers learn about port death the Mach way, through
dead-name notifications and `mach_msg` errors. libdispatch cancels a source before destroying its
port. The EOF helper is deferred with step 5 (id-056).

## FreeBSD-side changes allowed for 1.0 (2026-10-02)

FreeBSD has no native way to revoke a name on descriptor removal or to refuse `dup`, so step 2
(op-420) adds two small mechanisms in FreeBSD's own extension style, as separate `kern:`/`sys:`
commits:
- `fo_fdpostclose` in a spare slot of `struct fileops` (`sys/sys/file.h`), called after the
  descriptor lock is released, for every removal path (close, closefrom, dup2 replacement,
  close-on-exec, exit);
- `DFLAG_NODUP` (`0x08`): `dup`, `dup2` and `fcntl(F_DUPFD)` refuse such descriptors with
  `EOPNOTSUPP`.

Step 3 (batch 3) adds two more, delegated to the Arranger on 2026-10-02 (j-20261002-039):
- an "exec committed" event, after the final credentials and before the return to user space;
- a non-blocking thread-exit gate in the common `thread_exit`: a plain function-pointer hook called
  under the existing `PROC_SLOCK`, as hwpmc's `PMC_CALL_HOOK_UNLOCKED` is there, not an EVENTHANDLER
  (whose mutex would block), and never by releasing the spin lock (op-427 question, 2026-10-03);
- a "thread published" event right after `thread_link` (non-sleeping, under `PROC_LOCK`), added
  2026-10-02 when op-426 showed the design's thread binding point had no native hook
  (j-20261002-043).

All are EVENTHANDLER-style, as separate `kern:` commits.

In every case the struct keeps its size, and only Mach uses these hooks, so other file types and
processes are unchanged. Any further change to FreeBSD's own code needs a Coordinator decision first
(as with the deferred kqueue EOF helper).

## Step 4 decisions (Arranger under delegation, 2026-10-03)

Plan: advisor2's op-435 note (`rmx-advisor2@42dc8247`, `op-435-mach-step4-c1-d2-plan.md`). It
supersedes op-421's EOF parts. Its six commits (pins, LARGE/trailer boundary, queued replies and
waits, consumer adaptation, pure C1 with public KNOTE, D2) are the step-4 order. Decided under
the Coordinator's rule (match macOS where it is cheap; keep 1.0 stable):

1. **D2 for 1.0 is two setters only:** `task_set_special_port` (seatbelt, access and debug-control
   selectors) and `task_set_exception_ports` on a foreign task, which is what launchd's child setup
   calls (`sbin/launchd/core.c:8610,8617`). Caller substitution (`ipc_tt.c:901-902`) is replaced by
   truthful typed conversion. Every other foreign task, space or VM call stays disabled, with the
   note's error contract (`MIG_BAD_ID`, `KERN_NOT_SUPPORTED`, `KERN_INVALID_TASK`,
   `KERN_INVALID_ARGUMENT`).
2. **Exception ports:** accept and store launchd's configuration (CRASH|GUARD|RESOURCE,
   STATE_IDENTITY|MACH_EXCEPTION_CODES); reject unknown bits. Delivery of Darwin exceptions is not
   in 1.0.
3. **Updates to existing kevent registrations** that carry receive buffers are ignored and return
   readiness only; a new buffered registration fails with `ENOTSUP`. No FreeBSD hook for uniform
   `ENOTSUP`.
4. **Consumer ownership contract:** an owner keeps a receive name and its membership until
   cancellation completes, including events already copied (libdispatch's manager batch fence,
   launchd's drain before set replacement, libxpc's cancellation count); watched names are
   released with `mach_port_deallocate`, never closed. A kqueue is used within one Mach space and
   rebuilt after table changes or exec; no FreeBSD guard for this.
5. **N6** (concurrent first copyouts can split one send right into two names) is fixable on A1
   and is added to step 4 as its own test-first commit. **N7** (a dead-name notification dropped
   when allocation fails) stays a known limitation; with no EOF it is a quiet consumer's only miss,
   so it is tracked for after 1.0 or for an allocation-pressure test.

## Known differences from macOS in 1.0

Each is a deliberate choice to keep 1.0 stable; each can be closed later.

| Area | macOS | rmxOS 1.0 | Tracked |
|---|---|---|---|
| Port names | Mach-owned table with generations; independent of fd limits | fds: no generations, counted in `RLIMIT_NOFILE` | id-056 |
| Name revocation and kqueue | XNU delivers events through its own filter callbacks | registrations are silently removed, as for any fd | id-056 |
| Direct-receive kevents | supported (libdispatch uses them) | readiness only; receive in `mach_msg` | id-056 |
| Exec | XNU resets exception ports and task identity tokens by its own rules | ordinary exec keeps the task and its bootstrap and registered ports; setuid exec gives fresh control ports; exception-port and identity-token details not matched | batch 3 |
| Cross-task task calls | broadly supported | only `task_set_special_port` (3 selectors) and `task_set_exception_ports` on another task | step 4 (op-435) |
| Mach exception delivery | delivered | launchd's exception-port configuration is stored; Darwin exceptions are not delivered | step 4 (op-435) |
| Dead-name notification under memory pressure | not dropped | may be dropped (N7) | id-046 |
| `POSIX_SPAWN_CLOEXEC_DEFAULT` | supported | absent from libc; possible because FreeBSD 15 has `O_CLOFORK` | swift-real-libdispatch.md |

## Keeping step 5 possible later

So that 1.0 code does not lock us into fds:
- All name handling goes through the entry and reference API from step 2. No new code outside
  the IPC entry layer may assume that a name is an fd (no `fget` on a Mach name, no fd-table
  walks for Mach entries).
- Userland converts between names and fds only through named functions (for example the
  fileport calls), never by a cast. Existing casts (NextBSD's `libosxsupport/fileport.c`) are
  listed and kept to those functions.
- New tests check Mach behaviour (rights, notifications, lifetimes), not fd numbers, so they keep
  passing under a name table.

## When to revisit step 5

Revisit after 1.0, or earlier if any of these happens:
- a defect that A1 cannot fix without breaking NextBSD's fd semantics;
- a macOS parity requirement that needs name generations, or names independent of fd limits;
- libdispatch or libxpc parity that needs direct-receive kevents (C3), or an EOF event when a Mach
  name is revoked (op-421's native EOF retirement helper);
- the regression tests and sanitizer runs (Instrumentation 1.0) are strong enough to carry the switch.

The design for step 5 is ready in advisor2's proposal (`519ec47`): adapt XNU's namespace and
right-accounting code through FreeBSD adapters, and keep NextBSD's functions as requirements:
quotas and accounting, kqueue integration, file transfer with Capsicum rights, and
`procstat`/`fstat` visibility.
