---
id: op-523u
state: closed
cast: unicast
answers: op-520
agent: validator3
repo: rmx-validator3
idq: id-046
issued-at: 2026-10-07T01:43Z
updated: 2026-10-07T01:43Z
---
# op-523u — reply to op-520

```text
reply to op-520
agent:      validator3
outcome:    DONE — source review completed; one correctness finding
question:   Own: can valid queued messages become invisible, the filter consume them, or notification outlive its set?
access:     primary — pinned source, baseline, plan, tests and exact serial logs
score:      9/10 — source directly demonstrates permanent readiness suppression after backup recovery
verdict:    REMEDIATE — reset revocation state on valid receive-owner publication; add backup-recovery readiness and set-receive regression
evidence:   /Users/me/wip-mach/rmx-validator3/reviews/op-520/op515-op518-review.md sha256:03a41dcbeede73d076d2a5551eef93cb26d81542975a8de030547eddcdecfef3
            wip-rmxos@0facf74b sys/compat/mach/ipc/ipc_entry.c:277-386
            wip-rmxos@0facf74b sys/compat/mach/ipc/ipc_port.c:831-856
            wip-rmxos@0facf74b sys/compat/mach/ipc/ipc_right.c:1927-1950
            wip-rmxos@0facf74b sys/compat/mach/ipc/ipc_pset.c:262-282
commits:    45fc9b1
untested:   No builds or guests; recovery defect established by source trace. Cleanup: none, 0 bytes.
blockers:   none
next:       Implement F1 remediation with the backup-recovery regression.
```
