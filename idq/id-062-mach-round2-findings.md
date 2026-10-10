# id-062 — Mach review round 2: findings at `mach-fixes-6@b61f0f91`

- priority: high (Mach foundation round; gates li-1015 and the upper components)
- state: **CLOSED 2026-10-10 — op-607, proven by op-610 (gatekeeper1: RELEASE and KASAN 773/773 plus five MIG modes, KASAN clean); `mach-fixes-6@b127415a` on origin**
- raised: 2026-10-10, from op-604 (validator1, GLM, completeness) and op-605 (validator2,
  DeepSeek, falsification), blind
- parent: id-051 (review rounds); related: id-046 (fix list done), id-056 (name table, deferred)

## Findings and decisions (Arranger traced the must-fix ones first-hand at `b61f0f91`)

| # | From | Finding | Decision |
|---|---|---|---|
| R1 | op-604 #1 | `ipc_right_copyin_check` requires `ip_receiver == space` for `COPY_SEND`/`MOVE_SEND`/`MOVE_SEND_ONCE` (`ipc/ipc_right.c:1296-1297`), so a reply right to a port received elsewhere fails with `MACH_SEND_INVALID_REPLY` (`ipc_kmsg.c:1126`, `:1354`) | fix |
| R2 | op-605 F1 | `task_terminate` on the caller's own task clears its self ports (`kern/ipc_tt.c:300`) and leaves it running; `task_self_trap` then locks a NULL port (`:494-497`) | fix: not supported |
| R3 | op-605 F2 | `ipc_object_copyout_name` (`ipc/ipc_object.c:735`) lacks the `IP_CONTEXT_FILE` branch of `ipc_object_copyout` (`:658`): `mach_port_insert_right` with a file fd | fix |
| R4 | op-605 F3 | a file-context port with a receive disposition reaches `ipc_port_check_circularity` (`ipc/ipc_kmsg.c:1534-1538`, `:1723-1727`), which requires a port in limbo | fix: file ports take send dispositions only |
| R5 | op-604 #2 | `fo_fdpostclose` runs under `FILEDESC_XLOCK` in `fdescfree_fds` but after unlock in `closefp_impl` | document both contexts in `sys/file.h`; Mach's hook does not sleep |
| R6 | op-604 #3 | `kern_finstall` failure paths (`ipc/ipc_entry.c:649-653`, `:778-781`) drop the file without releasing the entry and its space reference | fix (latent) |
| R7 | op-604 #4 | `MACH_RCV_OVERWRITE`, scatter receive, trailers above CONTEXT refused with `MACH_RCV_INVALID_TYPE` | known 1.0 gap |
| R8 | op-604 #5 | `mach_msg_receive_results` has no caller and builds no trailer | delete |
| R9 | op-604 #6 | `ipc_entry.c` fallback `DTYPE_MACH_IPC` 17 disagrees with `sys/file.h` (18) | align |
| R10 | op-605 F4 | unbuilt NextBSD `lib/libmach/test/kqueue_tests` expects another errno; not in the suite (readiness covered by `tests/sys/mach` and `tests/lib/libdispatch`) | remove |
| R11 | op-605 F5 | `mach_port_allocate_name`: receive refuses, port set honours (tested by `mach_named_pset`), dead name substitutes another name | dead name refuses like receive |

## Overlap (stop signal, kernel-reviews.md)

None: the two reviews share no finding. Reading has not reached diminishing returns. Round 3 after
op-607, on the areas both "not reached" lists name (`ipc_kmsg.c` descriptor translation,
`ipc_port.c` internals, generated MIG servers, `lib/libmach`, `mach_vm.c`, `thread_pool.c`,
`proc_info.c`, `mach_debug.c`, `mach_processor.c`), lenses swapped.

## Fixed (2026-10-10)

op-607: R1 `84ad8508`, R2 `7e92e217`, R3 `0a7cc43e` (named insertion of a file-context port refused), R4 `cdeafe30`, R5-R11 `b127415a`. R5 resolved: both `fo_fdpostclose` call sites run without the descriptor table lock (`closefp_impl` after `XUNLOCK`; `fdescfree_fds`'s loop unlocked beside `closef`), so the hook may block like `fo_close`; the brief's "never sleeps" premise and op-604's "under `FILEDESC_XLOCK`" were both wrong. New known 1.0 gaps: `task_terminate`, named file-port insertion.
