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
| 3 | A shared fd table (`rfork` without `RFFDG`/`RFCFDG`) shares Mach names between processes (op-389 #11). | One Mach space per fd table. Teardown must not run while the table is still shared; Mach use from a process with a shared table is rejected or defined explicitly in the step-3 brief. |
| 4 | Port names reuse fd numbers at once and carry no generation bits (`sys/sys/mach/port.h:219-230`), so a stale name can refer to a new port. macOS has generations. | Kernel objects hold references, not names (knotes pin the entry, step 2). Userland must not keep a name after deallocating it. Document this as a known difference from macOS; parity tests must not depend on generation bits. |
| 5 | Mach names count against `RLIMIT_NOFILE` and `maxfilesperproc`. | Accept it. Size limits for launchd and other daemons that hold many ports; note in release notes. |
| 6 | Cross-task operations need the other task's fd table. | D2 only: a call proceeds only when the target task and its table are held and checked (after step 3). Foreign name-space operations stay disabled in 1.0. |
| 7 | Mach names must not travel as ordinary fds. NextBSD made them non-passable (`f3af7791`). | Keep them non-passable over Unix sockets and not inherited by `fork`. Files cross Mach messages only through the file-transfer path, which preserves Capsicum rights (batch-1 fix 10). |
| 8 | Exec keeps or drops fds by fd rules, not Mach rules. | Exec policy for special and bootstrap ports is defined in step 3; Mach entries are cleaned by Mach's exec hook, not by `close-on-exec`. |
| 9 | Direct receive inside kqueue's readiness check loses messages (op-389 #6, op-392 F4). | C1: kqueue reports readiness only; receive happens in `mach_msg`. libdispatch uses its receive adapter. No direct-receive kevents in 1.0. |

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
- libdispatch or libxpc parity that needs direct-receive kevents (C3);
- the regression tests and sanitizer runs (Instrumentation 1.0) are strong enough to carry the switch.

The design for step 5 is ready in advisor2's proposal (`519ec47`): adapt XNU's namespace and
right-accounting code through FreeBSD adapters, and keep NextBSD's functions as requirements:
quotas and accounting, kqueue integration, file transfer with Capsicum rights, and
`procstat`/`fstat` visibility.
