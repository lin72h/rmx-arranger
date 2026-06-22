# Initial Commit Plan

This document specifies the exact commit series for organizing the
currently uncommitted Mach import into clean, reviewable commits on
`main`.

## Current State

- `main` and `stable/15` point to the same upstream FreeBSD commit
  (`e4f02a72f7f6`).
- All Mach work is uncommitted: ~409 new files, 18 modified FreeBSD
  files, ~4,215 lines added.
- Zero local commits exist.

## Design Principles

1. **Isolate FreeBSD-modifying changes from pure additions.** Only
   commits 1 and 6 modify existing FreeBSD files. Everything else is
   pure addition.
2. **Order by dependency.** Each commit builds on the previous. The
   tree should be buildable after commits 1-5 (without Mach syscalls
   registered) and fully functional after commit 6.
3. **Each commit is a reviewable unit.** A reviewer can understand and
   evaluate each commit independently.
4. **Conflict-prone changes are separated.** Commits 1 and 6 are the
   only ones that will ever conflict with upstream merges. They are
   small and their resolution is mechanical.

## Commit Series

### Commit 1 of 6

**Subject:** `mach: add COMPAT_MACH kernel option and FreeBSD integration hooks`

**Purpose:** The smallest possible change to existing FreeBSD files that
enables the Mach subsystem. All hooks are behind `#ifdef COMPAT_MACH` or
are null operations.

**Modified files (5 files, ~15 lines):**

```
M sys/conf/options                  # +1: COMPAT_MACH opt_global.h
M sys/sys/proc.h                   # +6: td_machdata, p_machdata (#ifdef)
M sys/sys/event.h                  # +2: EVFILT_MACHPORT, bump EVFILT_SYSCOUNT
M sys/sys/file.h                   # +3: DTYPE_MACH_IPC (#ifdef)
M sys/kern/kern_event.c            # +1: null_filtops for EVFILT_MACHPORT
```

**Conflict risk:** Low. Changes are small, localized, and at specific
offsets.

**Commit message:**

```
mach: add COMPAT_MACH kernel option and FreeBSD integration hooks

Add the minimal structural hooks into FreeBSD for Mach compatibility:

- COMPAT_MACH kernel option in sys/conf/options
- Per-thread td_machdata and per-process p_machdata pointers in proc.h
- EVFILT_MACHPORT kqueue filter type in event.h (null_filtops placeholder)
- DTYPE_MACH_IPC file descriptor type in file.h

All additions are gated behind #ifdef COMPAT_MACH or are no-op
registrations. No functional change without the Mach subsystem loaded.

Upstream-Base: e4f02a72f7f6ef3a9965427679aec191e2ce34d9
NextBSD-Origin: NextBSD-CURRENT snapshot
Rebase-Notes: adapted for FreeBSD 15 struct layouts and filter table
```

---

### Commit 2 of 6

**Subject:** `mach: add Mach and Apple compatibility kernel headers`

**Purpose:** Import all kernel-facing Mach type definitions, IPC
structures, and Apple compatibility headers needed by the implementation.

**New files (~300 files, 0 modified):**

```
A sys/sys/mach/*.h, *.defs          # ~110 files: Mach kernel headers
A sys/sys/mach/device/*             # ~35 files: Mach device headers
A sys/sys/mach/ipc/*                # ~18 files: IPC type headers
A sys/sys/mach_debug/*              # ~8 files: debug info headers
A include/apple/                    # ~170 files: Apple type compatibility
A include/Availability.h
A include/AvailabilityInternal.h
A include/AvailabilityMacros.h
A include/TargetConditionals.h
```

**Conflict risk:** Zero. These directories do not exist in upstream
FreeBSD.

**Commit message:**

```
mach: add Mach and Apple compatibility kernel headers

Import Mach kernel type definitions, IPC structure declarations,
MIG interface definitions, and Apple system compatibility headers
from the NextBSD donor tree.

These headers define the Mach ABI surface: port types, message
structures, IPC space types, kern_return values, and the .defs
files used by MIG to generate server stubs.

The include/apple/ tree provides Apple system header stubs needed
for compilation of donor code that references Darwin-specific types.

Upstream-Base: e4f02a72f7f6ef3a9965427679aec191e2ce34d9
NextBSD-Origin: NextBSD-CURRENT snapshot
Rebase-Notes: no changes from donor; headers imported as-is
```

---

### Commit 3 of 6

**Subject:** `mach: add IPC core implementation`

**Purpose:** The heart of Mach IPC: port objects, IPC spaces,
rights management, entry tables, message queues, kernel message
lifecycle, and task/thread/host port integration.

**New files (22 files, 0 modified):**

```
# sys/compat/mach/ipc/ (17 files)
A sys/compat/mach/ipc/ipc_entry.c       # IPC space entry table
A sys/compat/mach/ipc/ipc_hash.c        # port-to-entry hash
A sys/compat/mach/ipc/ipc_init.c        # IPC bootstrap (SYSINIT)
A sys/compat/mach/ipc/ipc_kmsg.c        # kernel message lifecycle
A sys/compat/mach/ipc/ipc_kobject.c     # kernel object port binding
A sys/compat/mach/ipc/ipc_mqueue.c      # message queues
A sys/compat/mach/ipc/ipc_notify.c      # port notifications
A sys/compat/mach/ipc/ipc_object.c      # base IPC object refcounting
A sys/compat/mach/ipc/ipc_port.c        # port creation, destruction, refs
A sys/compat/mach/ipc/ipc_pset.c        # port sets
A sys/compat/mach/ipc/ipc_right.c       # right management
A sys/compat/mach/ipc/ipc_space.c       # per-process IPC namespace
A sys/compat/mach/ipc/ipc_table.c       # space entry table growth
A sys/compat/mach/ipc/ipc_thread.c      # per-thread IPC state
A sys/compat/mach/ipc/mach_debug.c      # IPC debug/inspection
A sys/compat/mach/ipc/mach_msg.c        # message send/receive core
A sys/compat/mach/ipc/mach_port.c       # mach_port_* kernel calls

# sys/compat/mach/kern/ (4 files)
A sys/compat/mach/kern/ipc_host.c       # host port setup (SYSINIT)
A sys/compat/mach/kern/ipc_tt.c         # task/thread port integration
A sys/compat/mach/kern/task.c           # Mach task lifecycle (SYSINIT)
A sys/compat/mach/kern/thread_pool.c    # thread pool management

# Header
A sys/compat/mach/kern_types.h          # Mach-to-FreeBSD type mappings
```

**Conflict risk:** Zero. `sys/compat/mach/` does not exist in upstream.

**Commit message:**

```
mach: add IPC core implementation

Import the Mach IPC subsystem from NextBSD: port objects, IPC spaces,
rights management, entry tables, message queues, kernel message
lifecycle, notification system, and task/thread/host port integration.

Key components:
- ipc_port.c: port creation, destruction, reference counting
- ipc_space.c: per-process IPC namespace management
- ipc_right.c: send/receive/once right semantics
- ipc_kmsg.c / mach_msg.c: kernel message lifecycle and delivery
- ipc_init.c: IPC bootstrap via SYSINIT
- kern/ipc_tt.c: mach_task_self, mach_thread_self, mach_reply_port
- kern/ipc_host.c: host port and mach_host_self
- kern/task.c: Mach task state attached to FreeBSD processes

Upstream-Base: e4f02a72f7f6ef3a9965427679aec191e2ce34d9
NextBSD-Origin: NextBSD-CURRENT snapshot
Rebase-Notes: adapted for FreeBSD 15 mutex/UMA/proc APIs
```

---

### Commit 4 of 6

**Subject:** `mach: add syscall implementations and MIG server stubs`

**Purpose:** Syscall entry points (traps), host/task/VM kernel service
implementations, and MIG-generated server dispatch stubs.

**New files (~30 files, 0 modified):**

```
# Syscall entry points and service implementations
A sys/compat/mach/mach_traps.c          # trap entry points (msg, port, vm, identity)
A sys/compat/mach/mach_task.c           # task info/policy server calls
A sys/compat/mach/mach_thread.c         # thread info server calls (SYSINIT)
A sys/compat/mach/mach_vm.c             # VM operations
A sys/compat/mach/mach_clock.c          # clock/time operations
A sys/compat/mach/mach_host.c           # host info server calls
A sys/compat/mach/mach_host_priv.c      # host priv server calls
A sys/compat/mach/mach_misc.c           # miscellaneous operations
A sys/compat/mach/mach_processor.c      # processor info
A sys/compat/mach/mach_semaphore.c      # semaphore operations
A sys/compat/mach/mach_convert.c        # type conversions
A sys/compat/mach/proc_info.c           # process info (proc_info syscall)

# MIG-generated server stubs
A sys/compat/mach/clock_server.c        # from defs/clock.defs
A sys/compat/mach/host_priv_server.c    # from defs/host_priv.defs
A sys/compat/mach/mach_host_server.c    # from defs/mach_host.defs
A sys/compat/mach/mach_port_server.c    # from defs/mach_port.defs
A sys/compat/mach/mach_vm_server.c      # from defs/mach_vm.defs
A sys/compat/mach/task_server.c         # from defs/task.defs
A sys/compat/mach/vm_map_server.c       # from defs/vm_map.defs

# MIG interface definitions (source for generated stubs)
A sys/compat/mach/defs/clock.defs
A sys/compat/mach/defs/host_priv.defs
A sys/compat/mach/defs/mach_host.defs
A sys/compat/mach/defs/mach_port.defs
A sys/compat/mach/defs/mach_vm.defs
A sys/compat/mach/defs/task.defs
A sys/compat/mach/defs/vm_map.defs

# Build
A sys/compat/mach/Makefile
```

**Conflict risk:** Zero.

**Commit message:**

```
mach: add syscall implementations and MIG server stubs

Import Mach trap entry points, kernel service implementations, and
MIG-generated server dispatch stubs from NextBSD.

Trap entry points in mach_traps.c provide the syscall-to-kernel-function
mapping for port operations, VM operations, identity queries, messaging,
and scheduling primitives.

MIG server stubs (generated from .defs files by migcom) provide the
dispatch layer for Mach server-side message handling: host info, port
operations, task operations, VM operations, and clock services.

The .defs source files are preserved for future MIG reproducibility
verification (see roadmap milestone G3).

Upstream-Base: e4f02a72f7f6ef3a9965427679aec191e2ce34d9
NextBSD-Origin: NextBSD-CURRENT snapshot
Generated-By: migcom (NextBSD snapshot revision, unverified)
Rebase-Notes: adapted for FreeBSD 15 kernel APIs
```

---

### Commit 5 of 6

**Subject:** `mach: add mach.ko module build and MACHDEBUG kernel config`

**Purpose:** Module initialization, syscall registration, kqueue filter
setup, and the debug kernel configuration.

**New files (3 files, 0 modified):**

```
A sys/compat/mach/mach_module.c     # module init, syscall registration
A sys/modules/mach/Makefile         # kmod build rules
A sys/amd64/conf/MACHDEBUG          # kernel config for testing
```

**Conflict risk:** Zero.

**Commit message:**

```
mach: add mach.ko module build and MACHDEBUG kernel config

Add the mach.ko kernel module entry point, build infrastructure, and
a MACHDEBUG kernel configuration for bhyve testing.

mach_module.c registers all Mach syscalls via syscall_helper_register()
at module load time and sets up the EVFILT_MACHPORT kqueue filter.
The module can only be loaded at boot (enforced by !cold check) and
cannot be unloaded.

sys/modules/mach/Makefile compiles the full Mach IPC subsystem into a
single mach.ko module.

MACHDEBUG is a debug kernel configuration for bhyve guest testing with
serial console, full debugging options, and COMPAT_MACH enabled.

Upstream-Base: e4f02a72f7f6ef3a9965427679aec191e2ce34d9
NextBSD-Origin: NextBSD-CURRENT snapshot
Rebase-Notes: module structure preserved from NextBSD pending future
  evaluation of in-kernel COMPAT_MACH integration
```

---

### Commit 6 of 6

**Subject:** `mach: register Mach syscall block in syscalls.master`

**Purpose:** Add the Mach syscall entries to FreeBSD's syscall table and
include all generated output files.

**Modified files (14 files):**

```
# Source (hand-edited)
M sys/kern/syscalls.master              # +339 lines: Mach syscall block

# Generated from syscalls.master (regenerated, not hand-edited)
M sys/kern/init_sysent.c
M sys/kern/syscalls.c
M sys/kern/systrace_args.c
M sys/sys/syscall.h
M sys/sys/syscall.mk
M sys/sys/sysproto.h
M lib/libsys/_libsys.h
M lib/libsys/syscalls.map
M sys/compat/freebsd32/freebsd32_syscall.h
M sys/compat/freebsd32/freebsd32_syscalls.c
M sys/compat/freebsd32/freebsd32_sysent.c
M sys/compat/freebsd32/freebsd32_systrace_args.c
```

**Conflict risk:** HIGH. This is the most conflict-prone commit.
`syscalls.master` changes whenever FreeBSD adds or modifies syscalls.
Resolution procedure: merge `syscalls.master`, then regenerate all 13
output files via:

```sh
/usr/libexec/flua sys/tools/syscalls/main.lua sys/kern/syscalls.master
```

Never hand-resolve the generated files.

**Commit message:**

```
mach: register Mach syscall block in syscalls.master

Add the Mach system call entries to FreeBSD's syscall table. The Mach
block occupies syscall numbers 600-699, providing trap entry points for:

- VM operations: mach_vm_allocate, mach_vm_deallocate, mach_vm_protect,
  mach_vm_map
- Port operations: mach_port_allocate, mach_port_destroy,
  mach_port_deallocate, mach_port_insert_right, mach_port_mod_refs,
  mach_port_move_member, and others
- Identity: mach_reply_port, thread_self_trap, task_self_trap,
  host_self_trap
- Messaging: mach_msg_trap, mach_msg_overwrite_trap
- Scheduling: swtch_pri, swtch, thread_switch
- Time: mach_timebase_info, mach_wait_until, clock_sleep_trap
- Timers: mk_timer_create, mk_timer_destroy, mk_timer_arm,
  mk_timer_cancel
- Semaphores: semaphore_signal, semaphore_wait, and variants
- Process: task_for_pid, pid_for_task, task_name_for_pid, __proc_info

All generated output files are produced by:
  /usr/libexec/flua sys/tools/syscalls/main.lua sys/kern/syscalls.master

Upstream-Base: e4f02a72f7f6ef3a9965427679aec191e2ce34d9
NextBSD-Origin: NextBSD-CURRENT snapshot
Rebase-Notes: syscall numbers preserved from NextBSD layout
```

## Execution Instructions for Codex Agent

1. Ensure `main` and `stable/15` are at the same commit.

2. Create each commit on `main` in order, using `git add` with explicit
   file paths (not `git add -A`).

3. For commit 6, verify the generated files match by running:
   ```sh
   /usr/libexec/flua sys/tools/syscalls/main.lua sys/kern/syscalls.master
   ```
   If outputs differ from the working tree files, use the regenerated
   versions.

4. After all 6 commits, push to both remotes:
   ```sh
   git push origin main
   git push backup main
   git push backup stable/15
   ```

5. Verify with:
   ```sh
   git log --oneline stable/15..main    # should show 6 commits
   git diff stable/15..main --stat      # should match the known delta
   ```

## Verification After Committing

```sh
# Build the module to confirm nothing broke
MAKEOBJDIRPREFIX="$(pwd)/../build/stable15-mach-obj" \
  make -C freebsd-src-stable-15 buildkernel KERNCONF=MACHDEBUG

# Build just mach.ko
MAKEOBJDIRPREFIX="$(pwd)/../build/stable15-mach-obj" \
  make -C freebsd-src-stable-15/sys/modules/mach
```

## Future Commits

After the initial 6-commit import, new work follows these rules:

1. Changes only in `sys/compat/mach/` or `sys/sys/mach/`: commit freely.
2. Changes to existing FreeBSD files: separate small commit, document
   the hook.
3. Changes to `syscalls.master`: regenerate outputs in the same commit.
4. Each commit is one logical change with a clear subject line.
