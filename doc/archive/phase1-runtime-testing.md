# Phase 1: Runtime Testing Plan

This document defines the systematic runtime validation of the Mach
kernel subsystem on FreeBSD 15 in a bhyve guest.

## Prerequisites

1. The 6-commit series from `commit-plan.md` is applied to `main`.
2. The MACHDEBUG kernel and mach.ko module build successfully:

   ```sh
   MAKEOBJDIRPREFIX="$(pwd)/../build/stable15-mach-obj" \
     make -C freebsd-src-stable-15 buildkernel KERNCONF=MACHDEBUG
   ```

3. A bhyve guest image exists at `../vm/runs/nxplatform-dev.img`.
4. The bhyve harness scripts work (stage, boot, parse serial output).

## Overview

Phase 1 has four stages, each with clear pass/fail criteria:

| Stage | Goal | Kernel options |
| --- | --- | --- |
| 1A | Boot and module load | MACHDEBUG (default) |
| 1B | Syscall surface probe | MACHDEBUG (default) |
| 1C | IPC core lifecycle | MACHDEBUG (default) |
| 1D | WITNESS and INVARIANTS run | MACHDEBUG + WITNESS + INVARIANTS |

Stages are sequential. Do not proceed to the next stage until the
current stage passes.

## Stage 1A: Boot and Module Load

**Goal:** Confirm the MACHDEBUG kernel boots in bhyve and mach.ko loads
without panicking.

### Steps

1. Build and stage the guest:

   ```sh
   NXPLATFORM_KERNEL_CONF=MACHDEBUG \
   scripts/bhyve/stage-guest.sh
   ```

2. Boot the guest:

   ```sh
   scripts/bhyve/run-guest.sh
   ```

3. In the guest (or via serial probe), verify:

   ```sh
   # Kernel identity
   sysctl -n kern.bootfile          # should mention MACHDEBUG
   sysctl -n kern.conftxt | grep MACHDEBUG

   # Module loaded
   kldstat | grep mach              # should show mach.ko
   dmesg | grep "mach services"     # should show "mach services loaded"

   # Sysctl tree
   sysctl mach                      # should show mach.debug_enable

   # No panics or WITNESS complaints in dmesg
   dmesg | grep -i panic            # should be empty
   dmesg | grep -i witness          # should be empty (or not present)
   ```

### Pass criteria

- [x] Kernel boots to multi-user
- [x] mach.ko appears in kldstat
- [x] "mach services loaded" in dmesg
- [x] mach sysctl node exists
- [x] No panics or lock-order violations in dmesg

### Fail actions

| Symptom | Action |
| --- | --- |
| Kernel panic during boot | Check SYSINIT ordering. IPC init, task init, thread init, and host init all run at SI_SUB_KLD. Check for NULL dereferences in bootstrap paths. |
| mach.ko fails to load | Check `mach_mod_init()` in mach_module.c. The `!cold` check may reject the load if timing changed in FreeBSD 15. |
| WITNESS violation | Record the lock ordering complaint. This is a FreeBSD 12->15 delta issue. Fix before proceeding. |
| kqueue registration fails | Check `EVFILT_MACHPORT` number. If FreeBSD 15 added new filters, the number may collide. |

---

## Stage 1B: Syscall Surface Probe

**Goal:** Systematically call every registered Mach syscall and record
whether it succeeds, returns an error, or crashes.

### Test program

Write a minimal C test program `mach_probe.c` that calls each syscall
category and reports results via stdout JSON. The program runs in the
bhyve guest.

```c
// Skeleton structure - each test is a function that:
// 1. Makes the syscall
// 2. Records: syscall name, return value, errno
// 3. Prints JSON: {"syscall":"name","rv":N,"errno":N,"status":"ok|error|crash"}
```

### Syscall categories and test cases

Each test case records: syscall name, return value, status.

#### Category 1: Scalar / Timebase (expected: PASS)

| Syscall | Test | Expected |
| --- | --- | --- |
| `mach_timebase_info` | Call with valid pointer | Returns 0, info populated |
| `mach_wait_until` | Wait until now+1 | Returns 0 |
| `clock_sleep_trap` | Sleep 0 seconds | Returns 0 or KERN_NOT_SUPPORTED |

#### Category 2: Scheduling (expected: PASS or benign)

| Syscall | Test | Expected |
| --- | --- | --- |
| `swtch_pri` | Call with pri=0 | Returns 0 (voluntary context switch) |
| `swtch` | Call | Returns 0 |
| `thread_switch` | Call with thread=0, option=0, time=0 | Returns 0 or error |

#### Category 3: Identity (expected: PASS if IPC init works)

| Syscall | Test | Expected |
| --- | --- | --- |
| `task_self_trap` | Call | Returns a port name (>0) or MACH_PORT_NULL |
| `thread_self_trap` | Call | Returns a port name (>0) or MACH_PORT_NULL |
| `host_self_trap` | Call | Returns a port name (>0) or MACH_PORT_NULL |
| `mach_reply_port` | Call | Returns a port name (>0) or MACH_PORT_NULL |

These are the most important tests in this stage. If they return valid
port names, the per-process IPC space is being initialized correctly.
If they return MACH_PORT_NULL, the IPC space initialization failed
silently. If they crash, the IPC init has a bug.

#### Category 4: Port operations (expected: PASS or error)

| Syscall | Test | Expected |
| --- | --- | --- |
| `mach_port_allocate` | Allocate MACH_PORT_RIGHT_RECEIVE | Returns 0, name populated |
| `mach_port_deallocate` | Deallocate the port from above | Returns 0 |
| `mach_port_allocate` + `mach_port_destroy` | Alloc then destroy | Returns 0 |
| `mach_port_mod_refs` | Modify refs on a known port | Returns 0 or error |
| `mach_port_insert_right` | Insert send right | Returns 0 or error |

#### Category 5: VM operations (expected: PASS)

| Syscall | Test | Expected |
| --- | --- | --- |
| `mach_vm_allocate` | Allocate 1 page, anywhere | Returns 0, addr populated |
| `mach_vm_deallocate` | Deallocate the page from above | Returns 0 |
| `mach_vm_protect` | Change protection on allocated page | Returns 0 |

#### Category 6: Messaging (expected: PASS or TIMEOUT)

| Syscall | Test | Expected |
| --- | --- | --- |
| `mach_msg_trap` (send) | Send inline msg to self via reply port | Returns 0 or error |
| `mach_msg_trap` (receive) | Receive on the reply port | Returns 0 or timeout |
| `mach_msg_trap` (send+receive) | Combined send/receive | Returns 0 or error |

#### Category 7: UNSUPPORTED stubs (expected: error return)

| Syscall | Test | Expected |
| --- | --- | --- |
| `semaphore_wait_trap` | Call | KERN_NOT_SUPPORTED |
| `semaphore_signal_trap` | Call | KERN_NOT_SUPPORTED |
| `task_for_pid` | Call | KERN_NOT_SUPPORTED |
| `mach_port_construct` | Call | KERN_NOT_SUPPORTED |
| `mach_port_destruct` | Call | KERN_NOT_SUPPORTED |
| `mach_port_guard` | Call | KERN_NOT_SUPPORTED |
| `mach_port_unguard` | Call | KERN_NOT_SUPPORTED |

These must return KERN_NOT_SUPPORTED, not panic. If any panics, the
UNSUPPORTED macro variant needs to be fixed (see `sys/sys/mach/std_types.h`
lines 147-151).

#### Category 8: Timer operations

| Syscall | Test | Expected |
| --- | --- | --- |
| `mk_timer_create` | Call | Returns port name or error |
| `mk_timer_destroy` | Destroy the timer from above | Returns 0 or error |
| `mk_timer_arm` | Arm with future time | Returns 0 or error |
| `mk_timer_cancel` | Cancel the armed timer | Returns 0 or error |

#### Category 9: Process operations

| Syscall | Test | Expected |
| --- | --- | --- |
| `pid_for_task` | Query own task port | Returns own pid or error |
| `task_name_for_pid` | Query own pid | Returns port name or error |

### Output format

The test program emits JSON to stdout between the probe markers so the
existing `parse-serial.py` can validate it:

```
=== nxplatform probe start ===
{"component":"mach","probe":"mach_timebase_info","status":"ok","rv":0}
{"component":"mach","probe":"task_self_trap","status":"ok","rv":259,"note":"port_name=259"}
{"component":"mach","probe":"mach_port_allocate","status":"error","rv":4,"note":"KERN_INVALID_ARGUMENT"}
{"component":"mach","probe":"mach_msg_trap","status":"crash","note":"signal 11"}
=== nxplatform probe end ===
```

### Pass criteria

- All Category 1 (scalar) tests pass.
- All Category 7 (UNSUPPORTED) tests return error, not panic.
- Identity syscalls (Category 3) return valid port names.
- No kernel panics or crashes during any test.

### Acceptable failures

- Category 6 (messaging) may fail if the message path has bugs.
  Record the failure mode and proceed to Stage 1C.
- Category 4 (port ops) may partially fail. Record which operations
  work and which don't.
- Category 8 (timers) may be unimplemented. Record and proceed.

### Critical failures (block further testing)

- Any kernel panic stops testing. Capture the panic with
  `scripts/bhyve/collect-crash.sh` and diagnose before continuing.
- Identity syscalls returning MACH_PORT_NULL means per-process IPC
  space initialization is broken. This must be fixed before any
  port or messaging tests are meaningful.

---

## Stage 1C: IPC Core Lifecycle

**Goal:** Verify that port objects, IPC spaces, and rights have correct
lifecycle behavior (no leaks, no use-after-free, no stuck references).

### Tests

These are separate test programs, run sequentially in the bhyve guest.

#### Test 1C-1: Port allocation and deallocation

```
1. Allocate 1000 receive rights
2. Verify all have distinct names
3. Deallocate all 1000
4. Allocate 1000 again
5. Verify names can be reused (space entry table is recycled)
6. Deallocate all
```

**Check:** Compare UMA zone stats before and after. Port zone count
should return to baseline. Use `vmstat -z | grep ipc` in the guest.

#### Test 1C-2: Process exit cleanup

```
1. Fork a child process
2. In the child: allocate 100 ports, then exit
3. In the parent: wait for child
4. Check UMA zone stats: port count should return to pre-fork baseline
```

**Check:** This verifies that process exit destroys the IPC space and
frees all ports. A leak here means the process exit hook
(`p_machdata` cleanup) is not wired correctly.

#### Test 1C-3: Send right transfer

```
1. Allocate a receive right (port A)
2. Insert a send right for port A into own space
3. Verify mach_port_mod_refs reports correct ref count
4. Deallocate the send right
5. Verify the receive right is still valid
6. Destroy port A
```

#### Test 1C-4: Fork and IPC space inheritance

```
1. Allocate a port in the parent
2. Fork
3. In the child: check if the parent's port name is valid
   (Mach semantics: IPC spaces are NOT inherited on fork,
   each process gets its own space. Verify this.)
4. In the child: allocate own port, verify independent namespace
```

#### Test 1C-5: Concurrent allocation stress

```
1. Spawn 8 threads
2. Each thread: allocate and deallocate 10000 ports in a loop
3. Join all threads
4. Check UMA zone stats for leaks
```

**Check:** This exercises lock contention on the IPC space lock.
Must complete without deadlock or panic.

### Pass criteria

- All 5 tests complete without panic or deadlock.
- UMA zone stats show no port/space/entry leaks after each test.
- Process exit correctly cleans up IPC state.
- Fork creates independent IPC spaces (no inheritance).

---

## Stage 1D: WITNESS and INVARIANTS

**Goal:** Run the Stage 1A-1C tests under FreeBSD's lock-order checker
and invariant assertion system.

### Setup

Modify `kernel/MACHDEBUG` to add:

```
options INVARIANTS
options INVARIANT_SUPPORT
options WITNESS
options WITNESS_SKIPSPIN
options LOCK_PROFILING
```

Rebuild the kernel and repeat Stages 1A through 1C.

### What to watch for

1. **WITNESS lock-order reversals:** These indicate that the Mach IPC
   lock hierarchy conflicts with FreeBSD 15's lock ordering. Each
   reversal must be analyzed:
   - Is it a real deadlock risk? (Two threads can reach the lock
     pair in opposite order.)
   - Is it a false positive? (The paths are mutually exclusive.)
   - Fix real reversals before proceeding.

2. **INVARIANTS assertion failures:** These catch NULL pointer
   dereferences, invalid reference counts, double-frees, and other
   corruption. Each assertion failure is a real bug.

3. **LOCK_PROFILING data:** Collect via `sysctl debug.lock.prof.stats`.
   This is not pass/fail but gives baseline data for future
   optimization.

### Pass criteria

- All Stage 1A-1C tests pass with WITNESS and INVARIANTS enabled.
- Zero WITNESS lock-order reversals involving Mach locks.
- Zero INVARIANTS assertion failures.

### Expected issues

The FreeBSD 12->15 delta likely changed lock ordering in:
- Process lock (`p_lock`) relative to thread lock (`td_lock`)
- VM map lock relative to other kernel locks
- UMA zone lock behavior

The Mach IPC code has its own lock hierarchy:
- Port lock (`ip_lock`)
- Space lock (`is_lock`)
- Object lock (`io_lock`)
- Port set lock
- Message queue lock

These two hierarchies must interleave correctly. WITNESS will tell us
if they don't.

---

## Deliverable

After Phase 1, produce `docs/runtime-status.md` with this structure:

```markdown
# Runtime Status

Date: YYYY-MM-DD
FreeBSD base: <commit hash>
Test kernel: MACHDEBUG [+WITNESS +INVARIANTS]

## Stage 1A: Boot and Module Load
Status: PASS/FAIL
Notes: ...

## Stage 1B: Syscall Surface Probe
| Syscall | Status | Return | Notes |
| --- | --- | --- | --- |
| mach_timebase_info | PASS | 0 | ... |
| task_self_trap | PASS | 259 | port name |
| ... | ... | ... | ... |

## Stage 1C: IPC Core Lifecycle
| Test | Status | Notes |
| --- | --- | --- |
| 1C-1 Port alloc/dealloc | PASS | No leaks |
| 1C-2 Process exit cleanup | FAIL | Port leak: 3 ports not freed |
| ... | ... | ... |

## Stage 1D: WITNESS and INVARIANTS
WITNESS violations: 0/N
INVARIANTS failures: 0/N
Lock profile data: <path to collected output>

## Summary
- Working: <list>
- Broken: <list>
- Blocked: <list with reasons>
```

## Timing Estimate

| Stage | Expected effort |
| --- | --- |
| 1A Boot and load | 1 session: build, stage, boot, verify |
| 1B Syscall probe | 1-2 sessions: write test program, run, collect results |
| 1C Lifecycle tests | 2-3 sessions: write 5 test programs, run, analyze |
| 1D WITNESS/INVARIANTS | 1-2 sessions: rebuild, rerun, analyze violations |

Phase 1 total: approximately 5-8 working sessions.

## What Comes After Phase 1

Phase 1 produces the ground truth. Based on results:

- If 1A fails: fix boot/init before anything else.
- If 1B shows identity syscalls broken: fix IPC space init (highest
  priority, everything depends on it).
- If 1C shows leaks: fix lifecycle before expanding functionality.
- If 1D shows WITNESS violations: fix lock ordering before adding
  complexity.
- If everything passes: proceed to Phase 2 (locking and lifetime
  audit) with confidence.
