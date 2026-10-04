---
id: op-477u
state: closed
cast: unicast
answers: op-474
agent: validator3
repo: rmx-validator3
idq: id-046
issued-at: 2026-10-04T10:30Z
updated: 2026-10-04T10:30Z
---
# op-477u — reply to op-474

```text
reply to op-474
agent:      validator3
outcome:    DONE — source review complete; two findings
question:   My own: can copied cancellation affect a reused name, or bounded receive lose readiness, while tests miss ownership faults?
access:     primary — pinned source, eleven commits, tests, kernel receive/kevent paths and Implementer record
score:      9/10 — direct source traces establish the cleanup omission and release-method mismatch
verdict:    REMEDIATE — dispose partial BODY_ERROR resources; deallocate unregister's returned send-once right; add regressions
evidence:   /Users/me/wip-mach/rmx-validator3/reviews/op-474/op468-review.md sha256:8454f13f7e6c069049d68425c233696da38ec746821ae5f4bf9a0db51c4de462
            wip-rmxos@015e7723076e705b2bbf2f1f19ab284419583155 lib/libdispatch/src/source.c:2793-2804
            wip-rmxos@015e7723076e705b2bbf2f1f19ab284419583155 lib/libdispatch/src/source.c:2969-2995
            wip-rmxos@015e7723076e705b2bbf2f1f19ab284419583155 sys/compat/mach/ipc/mach_msg.c:436-452
commits:    aafa03d1c7d8cb56ff47b638e609dc33dbccad6a
untested:   builds, guests, runtime counts; partial-copyout and pending-notification release regressions
blockers:   none; no instruction conflicts
next:       Implementer remedies F1 and F2 with focused ownership regressions

Summary (agent prose): REMEDIATE, two findings: source.c:2793 MACH_RCV_BODY_ERROR can leave received rights or mappings in the buffer that the manager discards without release; source.c:2994 unregister consumes its returned send-once right through a MIG send rather than mach_port_deallocate (inherited from base). Cancellation fencing and readiness after the 32-attempt bound hold. The six tests miss both.
```
