---
id: op-607
state: draft
agent: implementer
repo: rmx-implementer
idq: id-062
authority: product and test commits on mach-fixes-6 in wip-rmxos (one per item); rebuild the RELEASE and KASAN overlays; 6 self-check boots (4 + 2 spare) with the op-590 runner; test-only fixes under op-590's rule; no push
expected: 6h
updated: 2026-10-10T01:45Z
---
# op-607 — Implementer: Mach round-2 fixes (id-062) on mach-fixes-6 — reply-right check, task_terminate, file ports, small items

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 6 hours.**

Two Validators reviewed `mach-fixes-6@b61f0f91` independently. The
Arranger traced items 1-4 in the source. Start from `b61f0f91`; one
commit per item, each with a Zig test where the item has observable
behaviour. Before choosing a return code, search the existing tests
for the same call. For items 2-4, the test's "before" evidence is the
source trace below; do not boot the unfixed code for them.

1. **Reply rights held as send rights.** `ipc_right_copyin_check`
   requires `port->ip_receiver == space` for `COPY_SEND`, `MOVE_SEND`
   and `MOVE_SEND_ONCE` (`ipc/ipc_right.c:1296-1297`). A send right
   usually names a port whose receive right is in another space, so
   such a reply right is refused with `MACH_SEND_INVALID_REPLY`
   (`ipc/ipc_kmsg.c:1126`, `:1354`). Keep the receiver check only for
   `MAKE_SEND`, `MAKE_SEND_ONCE` and `MOVE_RECEIVE`, as XNU's
   `ipc_right_copyin_check_reply` does. Test: a message whose reply
   right is a copied send right to a port another process receives on
   is delivered with that reply port; also destination and reply naming
   the same send right.
2. **`task_terminate` returns `KERN_NOT_SUPPORTED`**, for the caller's
   own task too. Today it runs `ipc_task_terminate`, which sets
   `itk_self`, `itk_sself` and `itk_resume` to `IP_NULL`
   (`kern/ipc_tt.c:300`) while the process keeps running, and
   `task_self_trap`'s next call then works on a NULL port
   (`:494-497`). Task teardown belongs to process exit
   (`kern/task.c` `task_free`, `mach_task_exit`). Test: the call
   returns 46 and `mach_task_self()` still works afterwards.
3. **File ports in `ipc_object_copyout_name`.** `ipc_object_copyout`
   hands a file-context port to `ipc_entry_port_to_file`
   (`ipc/ipc_object.c:658`); `ipc_object_copyout_name` (`:735`), used by
   `mach_port_insert_right`, has no such branch. Give it the same
   handling, or refuse a file-context port there with a defined error;
   say which. Test: `mach_port_insert_right` with a file fd, then the
   space's entry and the file's reference count are as expected.
4. **File ports take send dispositions only.** A file-context port
   with a receive disposition in a message reaches
   `ipc_port_check_circularity` (`ipc/ipc_kmsg.c:1534-1538`,
   `:1723-1727`), which expects a port in limbo. Refuse a receive
   disposition for a file port at copyin with a defined error, before
   any reference is taken. Test: such a message is refused, and the
   destination port's references are unchanged.
5. **Small items:**
   - `fo_fdpostclose` runs under `FILEDESC_XLOCK` from `fdescfree_fds`
     but after the unlock from `closefp_impl`: state both contexts in
     the `sys/sys/file.h` comment, and confirm Mach's hook
     (`ipc/ipc_entry.c` `mach_port_fdpostclose`) never sleeps.
   - `kern_finstall` failure (`ipc/ipc_entry.c:649-653`, `:778-781`):
     release the entry and its space reference before dropping the
     file.
   - Delete `mach_msg_receive_results` and
     `mach_msg_receive_results_error` (`ipc/mach_msg.c:594-671`, no
     caller) and their declaration (`sys/sys/mach/message.h:860`).
   - Align the fallback `DTYPE_MACH_IPC` in `ipc/ipc_entry.c:166-168`
     with `sys/sys/file.h`.
   - Remove the unbuilt NextBSD `lib/libmach/test/kqueue_tests`; Mach
     readiness is covered by `tests/sys/mach` and
     `tests/lib/libdispatch`.
   - `mach_port_allocate_name` for a dead name returns
     `KERN_NOT_SUPPORTED`, as for a receive right
     (`ipc/mach_port.c:652-654`); port sets keep the requested name
     (`mach_named_pset` tests it).
   - Record as a known 1.0 gap: `MACH_RCV_OVERWRITE`, scatter receive
     and trailers above `MACH_RCV_TRAILER_CTX` are refused with
     `MACH_RCV_INVALID_TYPE` (`ipc/mach_msg.c:345-348`).

Then rebuild the RELEASE and KASAN overlays on the same base image
`op552-overlay-base-r3.raw` (sha256
`6f3b6e54606cecfbe3572cf5e2dee156c42499d113909351b811c41abe974059`),
recording each overlay's and manifest's sha256, and self-check both
profiles with the op-590 runner and settings. Expected on both: every
earlier and new case passes, the five MIG modes exit 0, the 400-case
repeat passes, normal power-off, no assertion or fatal trap; on KASAN,
no KASAN report. Two spare boots; a wrong new test may be fixed and
rerun within the boots (op-590's rule); a product failure or an
earlier accepted test failing stops the op.

Evidence: a new record `docs/op607-round2.md` (each item: commit,
test, source trace or before result, after result; the known gap;
overlay hashes; both runs with load, ATF counts, MIG modes, power-off
line, serial paths), commit, and a `selfcheck:` line.

## Limits

- Commits on `mach-fixes-6` in `wip-rmxos`, only for these items. No
  push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
