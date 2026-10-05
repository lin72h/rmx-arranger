---
id: op-494u
state: closed
cast: unicast
answers: op-492
agent: validator3
repo: rmx-validator3
idq: id-046
issued-at: 2026-10-05T01:03Z
updated: 2026-10-05T01:03Z
---
# op-494u — reply to op-492

```text
reply to op-492
agent:      validator3
outcome:    DONE — source review complete; two ownership findings
question:   My own: can launchd use a destroyed receive name or affect another owner after name reuse?
access:     primary — pinned source, ten commits, all test hooks and cases, related kernel copyout paths
score:      9/10 — direct source traces establish stale-name use and partial-receive cleanup omission
verdict:    REMEDIATE — handle masked partial-body errors; publish j_port only after successful setup; add ownership regressions
evidence:   /Users/me/wip-mach/rmx-validator3/reviews/op-492/op484-review.md sha256:062a24ff48e07a02c83e3cba064d9035714a4ee6128695ec286842b9ee164387
            wip-rmxos@10a3fd65 sbin/launchd/core.c:1699-1720, :9627-9633, :7369-7390
commits:    120535298ea5a9dfcf6035eb1610c894274caec4
untested:   builds, guests, runtime counts; no scratch created or removed, zero bytes freed
blockers:   none; no instruction conflicts
next:       Implementer remedies the two ownership findings with focused regressions

Summary (agent prose): REMEDIATE. machservice_drain_port matches bare MACH_RCV_BODY_ERROR, missing errors with detail bits, so partial-message resources can leak. Failed job_setup_machport closes the right but leaves j->j_port populated; later lookup or teardown can use the stale name, including after reuse. Demand lookup, detach-before-close, buffer sizes, loop termination and normal-build isolation check out. Test wrappers include deliberate state changes; not purely observational.
```
