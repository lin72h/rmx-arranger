---
id: op-616u
state: closed
cast: unicast
answers: op-612
agent: validator2
repo: rmx-validator2
idq: id-051
issued-at: 2026-10-10T03:10Z
updated: 2026-10-10T03:10Z
---
# op-616u — reply to op-612

```text
reply to op-612
agent:      validator2
outcome:    DONE — blind round-3 completeness review; report at reviews/op-612/mach-round3.md
question:   what is missing — a reference taken on one path and not released, a contract case unhandled, teardown that skips an object? Yes: ipc_kmsg_copyout_header takes two extra references on the fresh-entry reply-port path where XNU takes one, releasing only one; and the MACH_SEND_NOTIFY/MACH_RCV_NOTIFY plumbing is defined, documented and dropped.
access:     primary — rmxOS@b127415a sources read first-hand; local XNU 12377 read for comparison; xnu-792.13.8 copy fetched read-only from the opensource-apple mirror for F1's lineage; no guests
score:      9/10
verdict:    REMEDIATE — F1: delete the in-loop ip_reference(reply) at ipc/ipc_kmsg.c:2235 and :2264; F2: forward MACH_SEND_NOTIFY or refuse the flags; F3-F6 to decide and record: EVFILT_MACHPORT kn_data meaning, OOL-ports malloc-type mismatch, extract_right converting a file fd while insertion refuses it, vm_write/mach_vm_write's stub helper.
evidence:   reviews/op-612/mach-round3.md (committed 9707f4d); source citations as relayed
commits:    9707f4d (review)
untested:   no guest runs — F1 is a source trace plus reference algebra; generated server routines; host_priv_server.c / mach_host_server.c bodies; ipc/mach_debug.c
blockers:   none.
next:       Implementer to remove the extra reply-port reference (F1) and settle the notify flags (F2)
```
