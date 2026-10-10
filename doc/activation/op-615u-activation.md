---
id: op-615u
state: closed
cast: unicast
answers: op-611
agent: validator1
repo: rmx-validator1
idq: id-051
issued-at: 2026-10-10T03:08Z
updated: 2026-10-10T03:08Z
---
# op-615u — reply to op-611

```text
reply to op-611
agent:      validator1
outcome:    DONE — blind round-3 review complete; 1 critical must-fix, 1 medium, 1 carried low; deliverable at reviews/op-611/mach-round3.md (146 lines)
question:   (falsification lens per the brief) For each invariant the code relies on — reference ownership, lock coverage, what survives a lock drop or sleep, out-parameter contracts — which path breaks it?
access:     primary — read ipc_kmsg.c's descriptor copyin/copyout/destruction paths in full at b127415a7435d89be0a74ddd5aee094a0e5de100, the b61f0f91..b127415a fix diff, ipc_entry.c close/alloc paths, ipc_kmsg.h struct/macros, and XNU osfmk/ipc/ipc_kmsg.c's ool-ports routine for comparison
score:      9/10
verdict:    REMEDIATE — finding 1 must be fixed for 1.0: ipc_kmsg_copyin_body's expansion shift memmoves the message base into the struct ipc_kmsg tail because ikm_set_header gives the header no leading headroom; dsc_adjust = 4 × port descriptors; finding 2 recommended: ool-ports deallocate=TRUE should unmap pnlength (4×count), not plength (8×count)
evidence:   reviews/op-611/mach-round3.md (committed dfcdc4d); source citations as relayed
commits:    dfcdc4d
untested:   ipc_port.c internals, mach_vm.c and the hand-written VM server routines, lib/libmach, kern/thread_pool.c, proc_info.c, mach_debug.c, mach_processor.c, the thread_block lock shim, generated MIG stubs; no guests, no builds
blockers:   none
next:       Implementer fixes finding 1 with a regression test carrying ≥5 port descriptors; round 4 on the areas neither round reached
```
