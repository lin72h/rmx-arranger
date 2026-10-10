---
id: op-608u
state: closed
cast: unicast
answers: op-604
agent: validator1
repo: rmx-validator1
idq: id-051
issued-at: 2026-10-10T01:46Z
updated: 2026-10-10T01:46Z
---
# op-608u — reply to op-604

```text
reply to op-604
agent:      validator1
outcome:    DONE — source-only blind round-2 review complete; 1 must-fix finding, 5 minor, extensive cleared list; deliverable at reviews/op-604/mach-round2.md (177 lines)
question:   (my lens per the brief) What is missing — rights/locks unreleased on some path, Mach contract cases unhandled, teardown skipping objects, states assumed but never set up?
access:     primary — read ipc_entry.c, ipc_right.c, mach_msg.c, ipc_mqueue.c, ipc_pset.c, ipc_object.c in full at b61f0f9164170ed9d9d2b3fd312e34eee2603f09; targeted reads of ipc_kmsg.c, kern/ipc_tt.c, kern/task.c, mach_thread.c, mach_traps.c, ipc_kobject.c, the kern_descrip/file.h hook diff, and XNU osfmk/ipc/ipc_right.c for comparison
score:      9/10 — because the findings and clearances come from direct reads of the pinned source against XNU's corresponding code; 1.0 reserved for the not-reached list (ipc_kmsg descriptor translation, ipc_port internals, generated MIG servers, libmach, mach_vm, the thread_block lock shim)
verdict:    REMEDIATE — finding 1 must be fixed for 1.0: drop ipc_right.c:1296-1300's `port->ip_receiver != space` check from the COPY_SEND/MOVE_SEND/MOVE_SEND_ONCE cases of ipc_right_copyin_check (it rejects every ordinary send right, breaking third-party reply ports and dest==reply with MACH_SEND_INVALID_REPLY at ipc_kmsg.c:1126/:1354); findings 2-4 recommended (fdpostclose dual lock context, kern_finstall-failure leaks, document the RCV_OVERWRITE narrowing); 5-6 notes
evidence:   reviews/op-604/mach-round2.md (committed 46617c2); source citations as listed in the reply as relayed
commits:    46617c2
untested:   ipc_kmsg.c descriptor translation, ipc_port.c internals, generated MIG servers, lib/libmach, mach_vm.c, thread_pool.c, and the sched_prim thread_block lock shim; no guests, no builds
blockers:   none
next:       Implementer fixes finding 1 (one condition to delete, plus a regression test for third-party reply ports); round 3 should re-check the two refactors flagged as latent
```
