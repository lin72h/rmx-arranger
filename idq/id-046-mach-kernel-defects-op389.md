# id-046 — Mach kernel defects inherited from the NextBSD port (op-389, op-392, op-393)

- id: **id-046**
- state: **WAITING — Coordinator: schedule an Implementer fix batch, and decide whether it gates the preview**
- raised: **2026-09-28 by the Arranger, from advisor2 op-389 (rmx-advisor2 2f6c337)**
- parent: id-042 (1.0-preview), beside id-045

## Problem

advisor2's op-389 deep dive found 14 confirmed defects and one suspect in `sys/compat/mach/` at
alpha2 `2884304b`. Almost all are inherited unchanged from NextBSD's FreeBSD 12.0 port. Several can
be reached from ordinary user code, and some of those panic the kernel or use freed kernel memory.
Consult: `/Users/me/wip-mach/rmx-advisor2/op-389-mach-freebsd12-assumptions-alpha2.md`.

## Arranger first-hand check (`git show 2884304b:…`)

Traced at source; each holds as stated:
- **3** `mach_fileops` sets only close/stat/kinfo (`ipc_entry.c:224-230`), and `poll(2)` calls
  `fo_poll` through that NULL pointer (`sys_generic.c:1809-1822`, `file.h:400-404`). Any process
  that polls one of its Mach port names panics the kernel. The same holds for `fcntl(F_SETFL)` via
  `fo_ioctl`.
- **2** the port-name lookup returns `fp->f_data` after `fdrop` (`ipc_entry.c:353-368`).
- **4** fork copies registered, exception and bootstrap send rights into the child
  (`ipc_tt.c:193-210`). Ordinary exit never releases them.
- **5** `mach_msg_receive_results` clears `ith_kmsg` and then calls the error helper
  (`mach_msg.c:590-597`), which rereads it and passes NULL to `msg_receive_error` (`:505`).
- **9** Capsicum check is `CAP_ALL1` only and the fd is installed with NULL filecaps (`ipc_entry.c:383-395`).
- **12** `kern_finstall` takes its own hold (`:967`); the transfer path drops its reference only
  on failure (`:432-433`), so each successful transfer leaks one file reference.
- **13** `ipc_pset_alloc_name` omits the TAILQ, sx and knlist init that `ipc_pset_alloc` has
  (`ipc_pset.c:215-220` vs `250-259`).
- **1** is real code, but the shipped module does not compile its assertion. The op-364 `mach.ko`
  was built as a standalone module with an empty `opt_global.h` (`build-mach-module.log`), and has
  no assertion strings, while the RMXOS-RELEASE kernel does. So 1 (and 11's assertion) is latent
  in the shipped build and fires only in an INVARIANTS module build. With the assertion compiled
  out, 11's alternative applies: Mach cleanup closes descriptors in a shared table.
- **10** there is no `HZ` override in RMXOS-RELEASE, MACHDEBUGDEBUG or std.debug. A bhyve guest
  defaults to hz=100, so Mach millisecond timeouts run 10× long there.

Not independently traced: 6, 7, 8, 11, 14, 15 (15 is advisor2's own "suspected").

## Separate build finding

`mach.ko` is built outside the kernel configuration, so it does not share the kernel's options
(INVARIANTS and the rest). Decide whether the module should build with `KERNBUILDDIR` of its
kernel. Enabling INVARIANTS there turns 1 and 11 into panics until they are fixed.

## Proposed route (Arranger)

One Implementer fix batch with a regression probe per fix, smallest first. Order: 3, 5, 13, 12, 2,
9, 4, then 7 and 8. Then one Validator. 3 alone is a user-triggerable kernel panic, and that
argues for gating the preview on at least 3, 5 and 13. 1, 10 and 11 need the build decision
above. 14 belongs with id-045 (module load and unwind). The batch touches no PID-1 or launchd
code, so it can run alongside op-391.

## Shape (Arranger, after discussion with the Coordinator, 2026-09-28)

No fundamental mismatch: ports as fds, Mach events as kqueue filters, and task state in FreeBSD's
proc storage all remain viable on stable/15. The route is repair, not redesign, in two parts:
1. Local fixes, a few lines each: 3, 5, 13, 12, 9.
2. Pattern fixes: direct receive consumes messages during kqueue's readiness checks (6; needs
   XNU's readiness/delivery split); object lifetime across lock drops and fdrop (2, 7, 15; sweep for the
   pattern, not only three sites); task teardown on ordinary exit (4); the module build outside
   its kernel's configuration.
Part 2 decides architecture: the Mach receive and event model, the object lifetime model, and
task lifetime on FreeBSD. It starts with an Advisor architecture proposal and a Coordinator
decision before any code (Coordinator: architecture correctness first, 2026-09-28).
Caveat: one source-only review. It shows where bugs are, not that the list is complete.

## Independent second review: advisor1 op-392 (rmx-advisor1 d320d93, 2026-09-28)

advisor1 (Opus 5.5, max effort) reviewed the same scope blind to op-389:
`/Users/me/wip-mach/rmx-advisor1/op-392-mach-freebsd15-assumptions-findings.md`, 8 confirmed and
6 suspected. The session was interrupted by a safety flag after the document was committed, so the
document is complete. Areas it never reached: `mach_clock.c` and `clock_server.c`,
`mach_semaphore.c`, `ipc_kobject.c`, the MIG dispatch, `ipc_space.c`, `ipc_notify.c`, and the
trap argument path.

**Overlap with op-389:**
- op-392 F2 = op-389 #4 (task ports), plus a new aspect: an old task port rebinds to the process
  that reuses the slot.
- op-392 F3 = op-389 #3, wider: also fchmod, fchown, and the kevent read and write filters.
- op-392 F4 = op-389 #6; S2 = #2; the §3 rfork item = #11; the build fact = #1's premise.

**New in op-392; the Arranger traced F1, F5 and F6 first-hand:**
- **F1** The caller identity is a fork-time snapshot. `set_security_token` is called only at fork
  (`task.c:211`), the trailer copies it on every send (`ipc_kmsg.c:850-851`), and launchd takes
  every caller's euid, egid, uid, gid and pid from it (`runtime.c:1089-1094`). A launchd job that
  drops to a user after fork is seen as root by launchd and by libxpc peers, and a
  credential-raising exec keeps its old identity. This is a trust defect on the PID-1 path (id-016).
- **F5** A port-set receive that is interrupted or times out while a message is delivered panics
  or loses the message. NextBSD's compiled-out `assert(found)` became an unconditional `panic` in
  rmxOS's import (`thread_pool.c:92-93`).
- **F6** `_swtch_pri` calls `thread_unlock` after `mi_switch`, but stable/15's `mi_switch` already
  releases the lock (`kern_synch.c:462-468`; FreeBSD 12's did not). The trap is registered, so any
  process that calls it panics the INVARIANTS kernel. This is 12→15 drift.
- F7 (a kqueue sent in a Mach message outlives its creator's fd table) and F8 (`proc_pidbsdinfo`
  reads `p_fd` of an exiting process); suspected S1 (a lock-order reversal from rmxOS commit
  8184caaa), S4 (stale knotes), S5 (cross-task operations use the caller's fd table) and S6 (KBI
  field offsets).

**Only in op-389:** #5, #7, #8, #9, #10, #12, #13 and #14.

**Design classes (op-392 §5), the architecture answer:** A, port names are fds (F3, F7, S2–S5);
B, Mach state bound to reusable proc and thread slots with no teardown (F1, F2); C, receive
inside the kqueue filter's readiness check (F4, S1); D, a self-only model mixed with a MIG layer
that acts on other tasks (S5); E, the standalone module build. These refine part 2 of the shape
above.

**What the comparison shows:** two strong independent reviews overlapped on about five items, and
each found roughly half of the union. One review is far from complete.

## advisor1 op-393: the areas op-392 did not reach (rmx-advisor1 cd7b08c, 2026-09-29)

`/Users/me/wip-mach/rmx-advisor1/op-393-mach-remaining-areas-findings.md` (212 lines).
Arranger first-hand at `2884304b`: N1 and N5 hold as written.
- **N1** The timebase trap returns 4000000000/75189611 (`mach_clock.c:117-119`), but libmach's
  `mach_absolute_time` already counts nanoseconds (`mach_misc.c:188-196`). launchd converts with
  the ratio (`runtime.c:1511-1514`), so its 10 s respawn throttle (`core.c:4476-4478`) is about
  0.19 s and crashing jobs respawn back to back. `CLOCK_REALTIME` is also not monotonic.
- **N2** A kernel MIG reply is parked on the sending thread, not queued to its reply port. It
  reaches that thread's next receive on any port, or the thread that reuses the slot.
- **N3** Receive on a dead name dereferences a NULL object (`ipc_mqueue.c:515-517`).
- **N4** A lock shortcut compares against uninitialized variables at 17 call sites, so a lock can
  be skipped and a mutex released that the thread does not hold.
- **N5** `convert_port_to_task` returns `current_task()` before its real body (`ipc_tt.c:877-878`),
  so every task_* kernel call acts on the caller. launchd's post-fork handling sets exception and
  special ports on launchd itself instead of the child.
- Lower: a duplicate name for one send right; notifications dropped under memory pressure;
  `clock_sleep` 10x too long for its sub-second part; `clock_get_time` and the VM attribute call
  always fail; traps that report errors as -1/errno instead of kern_return_t.
- Firm-ups: **S1**: the logged `ETAP_IPC_RPC` → `ETAP_IPC_IS` reversal matches NextBSD's old
  `ipc_object_copyout` order, which rmxOS fixed in 60e5e76e5add (2026-04-17). Either those logs
  predate the fix, or the log's "1st … @ file:line" names a path not yet found; that line is the
  open check. **S2**: the ipc zones are not type-stable, so a write after free should panic
  "Memory modified after free". **F2** stands, and its teardown must land before N5's fix makes
  the stale ports reachable. **The op-392 §3 workqueue item is retracted.**
- Cleared: MIG request validation is compiled in; the clock code has no callouts; semaphores are
  unused stubs; the 7- and 8-argument traps fit amd64.
- Not reached: the host_priv and mach_host routine bodies, task_info/task_threads, and the other
  vm_map server routines.
- advisor1's proposal: fix N3, N4 and the `clock_sleep` divisor now; N1 together with the libmach
  clock change; N2 as a design fix; F2 teardown before N5.

## Batch 1 proven (2026-10-02)

op-418 (rmx-gatekeeper1 `9157b8c`): all 27 cases match on both images. Base: 14 PANIC, 12 FAIL
with their own reasons, and 1 control PASS; fixed: 27/27 PASS. Branch `mach-fixes-1` at `903c8fc2`
(13 fixes, the fix-6 follow-up, the fixture rebuild, MODULE_VERSION, fd_exhaustion IPC_SPACE, and
bounded clock tests). The branch is on the public rmxOS origin (pushed with the Coordinator's yes,
2026-10-02), and op-395 is closed. Batch 2 (step 2) is op-420.

## Findings ledger (every finding from op-389, op-392 and op-393)

This is the complete list; each consult document holds the detail. Rows with source "Arranger" come from the Arranger's own reading. "First-hand" means the
Arranger traced it at `2884304b`; "reported" means the consult's own trace only. "Both" marks
findings that both op-389 and op-392 reached.

| Source | # | Finding | Checked | Also in |
|---|---|---|---|---|
| op-389 | 1 | Untimed-wakeup assertion (latent: `mach.ko` built without INVARIANTS) | first-hand | id-047 |
| op-389 | 2 | Port-name lookup returns the entry after `fdrop` (both: op-392 S2) | first-hand | |
| op-389 | 3 | Mach fileops lack poll/ioctl, so poll() and fcntl() panic (both: op-392 F3) | first-hand | |
| op-389 | 4 | Fork copies task send rights that exit never releases (both: op-392 F2) | first-hand | |
| op-389 | 5 | Short-buffer direct kevent receive passes a NULL kmsg to cleanup | first-hand | |
| op-389 | 6 | Direct receive runs inside the kqueue readiness check and loses messages (both: op-392 F4) | reported | |
| op-389 | 7 | Sender signals a port set after dropping its last protection | reported | |
| op-389 | 8 | Failed OOL copyout frees a copy object the caller also discards | reported | |
| op-389 | 9 | Mach fd transfer drops Capsicum rights and installs full rights | first-hand | |
| op-389 | 10 | Mach millisecond timeouts run 10x long at hz=100 | first-hand (no HZ override) | |
| op-389 | 11 | rfork shared fd table: exit assertion or closing the sharer's names (both: op-392 §3) | reported | |
| op-389 | 12 | File transfer leaks a reference on success; double destroy on fd exhaustion | first-hand | |
| op-389 | 13 | Explicitly named port set skips list, lock and knlist init | first-hand | |
| op-389 | 14 | Failed module load leaves lifecycle hooks into unloaded text | reported | id-045 |
| op-389 | 15 | Suspected: pset destruction keeps an unpinned member across a lock drop | reported | |
| op-392 | F1 | Caller identity (audit token) is a fork-time snapshot that launchd trusts | first-hand | id-016 |
| op-392 | F5 | Port-set receive racing an interrupt or timeout panics (rmxOS turned an assert into a panic) | first-hand | |
| op-392 | F6 | `_swtch_pri` double-unlocks the thread lock (12→15 drift) | first-hand | |
| op-392 | F7 | A kqueue sent in a Mach message outlives its creator's fd table | reported | |
| op-392 | F8 | `proc_pidbsdinfo` reads `p_fd` of an exiting process | reported | |
| op-392 | S1 | Suspected lock-order reversal; logs show `ETAP_IPC_RPC`→`ETAP_IPC_IS`, likely pre-60e5e76e5add | open check | id-052 |
| op-392 | S3 | Mach urefs live in `f_count`; exit frees files others still reference; no-senders missed | reported | |
| op-392 | S4 | Stale knotes survive port-name reuse | reported | |
| op-392 | S5 | Cross-task space operations use the caller's descriptor table | reported | |
| op-392 | S6 | KBI: inserted proc/thread fields shift offsets for stock-built modules | reported | |
| op-392 | §3 | VM wrappers ignore the target map; `setmax` dropped; errno as kern_return_t; `mach_vm_allocate` skips RLIMIT_VMEM and RACCT; OOL buffered via malloc(M_NOWAIT) | reported | |
| op-392 | §3 | AUDIT_SYSCLOSE and seqc compiled out of `mach.ko`; debug sysctls walk entries without references; `twq_proc_exec` runs before exec can fail | seqc first-hand (2026-10-01): `kern_fdfree` writes `fde_seqc` only under `CAPABILITIES` (`ipc_entry.c:933-942`), undefined in the standalone build, while the kernel's lockless lookups rely on it (`kern_descrip.c:323-328`, `3244-3268`); rest reported | id-047 (op-396's kernel build fixes the seqc part) |
| op-392 | §3 | Workqueue per-thread state freed only on `thr_exit` | **retracted by op-393** | |
| op-393 | N1 | Timebase ratio ~53 vs nanosecond clock; launchd's 10 s respawn throttle becomes ~0.19 s | first-hand | id-016 |
| op-393 | N2 | Kernel MIG reply parked on the sending thread, not queued to the reply port | reported | |
| op-393 | N3 | Receive on a dead name dereferences a NULL object | reported | |
| op-393 | N4 | `ipc_object_translate` lock shortcut reads uninitialized variables (17 callers) | reported | |
| op-393 | N5 | `convert_port_to_task` returns the caller; task_* calls act on the caller | first-hand | id-016 |
| op-393 | N6 | Concurrent copyouts of one send right can create two names | reported | |
| op-393 | N7 | Notifications dropped on allocation failure | reported | |
| op-393 | N8 | `clock_sleep_trap`: wrong duration, clock and result codes | reported | |
| op-393 | N9 | Handlers written for user pointers are called by MIG with kernel pointers (`clock_get_time`, VM attribute always fail) | reported | |
| op-393 | N10 | Traps report kern_return_t through two conventions (-1/errno vs value) | reported | |
| Arranger | A1 | `ipc_kmsg_alloc` zeroes messages only under INVARIANTS (`ipc_kmsg.c:386-390`): the standalone `mach.ko` does not zero them, a kernel-built one does, and the zeroing hides uninitialized message bytes from KMSAN. Whether such bytes reach user space is an open check (KMSAN, instrumentation-strategy.md) | first-hand (2026-10-01) | id-047 |

Build finding (op-389, op-392, op-393): `mach.ko` is built outside its kernel's configuration →
id-047. Unreached routines → id-052.
