# id-052 — Mach review remainder: the routines no review has reached, and S1's open check

- id: **id-052**
- state: **WAITING — priority high (Coordinator, 2026-09-29); not scheduled**
- raised: **2026-09-29 by the Coordinator, after op-393**
- parent: id-046; related: id-051 (review rounds), [kernel-reviews.md](../kernel-reviews.md)

## Problem

Three reviews (op-389, op-392, op-393) covered the Mach integration at alpha2 `2884304b` except
these areas, which no reviewer has read:
- the `host_priv` and `mach_host` routine bodies (`sys/compat/mach/host_priv_server.c`,
  `mach_host_server.c` and the routines they dispatch to);
- `task_info` and `task_threads`;
- the other `vm_map` server routines (`vm_map_server.c`, `mach_vm_server.c`, beyond what
  op-389 #8 and op-392 §3 touched).

One check is also open. **S1** (op-392): 3 guest serial logs show a WITNESS lock-order reversal,
1st `ETAP_IPC_RPC` and 2nd `ETAP_IPC_IS`. advisor1 (op-393) matched it to NextBSD's old
`ipc_object_copyout` order, which rmxOS fixed in 60e5e76e5add (2026-04-17), and found no alpha2
path that takes the space lock while holding a port lock. The "1st … @ file:line" in those logs
decides whether the logs predate the fix or name a missed path.

## Why high

N5 (op-393) shows the task-level routines were never really exercised: every task_* call acted
on the caller. The unread host, task and VM routines are the same kind of code, reached by
launchd and libxpc on the PID-1 path.

## Done when

A findings-only review of these routines has returned, in the op-392 and op-393 form, and S1
is either tied to a pre-60e5e76e5add build or reopened as a live defect. Findings bind to id-046.
