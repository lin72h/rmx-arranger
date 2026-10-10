# id-063 — Mach review round 3: findings at `mach-fixes-6@b127415a`

- priority: high (Mach foundation round)
- state: **OPEN — fix batch op-617 drafted 2026-10-10**
- raised: 2026-10-10, from op-611 (validator1, falsification) and op-612 (validator2, completeness), blind
- parent: id-051; related: id-062 (round 2)

## Findings and decisions (traced first-hand at `b127415a` where marked)

| # | From | Finding | Decision |
|---|---|---|---|
| T1 | op-611 #1 (traced) | `ikm_set_header` puts the header at `kmsg + 1` with no room below it (`sys/sys/mach/ipc/ipc_kmsg.h`); copyin's descriptor expansion moves `mach_msg_base_t` down by 4 bytes per port descriptor (`ipc/ipc_kmsg.c:1862-1865`) over the 40-byte `struct ipc_kmsg` tail, and above 10 descriptors before the allocation | fix: header placed with headroom, as XNU |
| T2 | op-611 #2 (traced) | OOL port-array copyin reads `pnlength` (4 × count) names but with `deallocate` unmaps `plength` (8 × count) of the sender's memory (`ipc_kmsg.c:1671-1693`) | fix |
| T3 | op-612 F1 (traced) | `ipc_kmsg_copyout_header`, fresh-entry reply path, takes one reference in the loop (`:2235` or `:2264`) and one after it (`:2272`); `ipc_right_copyout` transfers one into the new entry; the epilogue releases one (`:2375-2376`); the in-loop one leaks, every message for send-once replies | fix |
| T4 | op-612 F2 (traced) | `MACH_SEND_NOTIFY` is ignored; libdispatch arms a send-possible notification after `MACH_SEND_TIMED_OUT` and waits for it (`lib/libdispatch/src/source.c:3495`, `:3531-3535`); libnotify also sets it (`libnotify.c:517`); XNU: `ipc_port_request_sparm` | fix: implement send-possible notifications |
| T5 | op-612 F4 | OOL port arrays allocated with `M_MACH_TMP` (`ipc_kmsg.c:1674`) and freed through `KFREE`, which uses `M_MACH_KALLOC` (`std_types.h:141-143`) in descriptor cleanup | fix: one malloc type |
| T6 | op-612 F5 | `mach_port_extract_right` returns a file-context port as a send right while named insertion refuses it | fix: refuse consistently |
| T7 | op-612 F3 | `EVFILT_MACHPORT` `data` is the ready member's name, not Darwin's message size | known 1.0 gap: the readiness-only design (op-435), tested by `mach_readiness.zig:59`; the review's "only test deleted" is wrong |
| T8 | op-612 F6 | `mach_vm_write` always returns `KERN_NOT_SUPPORTED` | known 1.0 gap |
| — | op-611 "carried" | `kern_finstall` failure leak | already fixed by op-607 (`ipc_entry_put` releases the space reference) |

## Overlap

None again: rounds 2 and 3 found 11 and 8 distinct defects with no finding shared between the two
reviewers in either round (one function, the OOL port-array copyin, holds T2 and T5, two different
defects). Reading is not converging. Next: machine checking on top of the remaining reading
(kernel-reviews.md § Decision, item 5: generated-input testing under KASAN, id-048).

Process note: validator2 fetched an old XNU copy from a network mirror for lineage (op-612), outside
its read-only defaults; the finding does not depend on it.
