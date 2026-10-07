---
id: op-542u
state: closed
cast: unicast
answers: op-539
agent: validator3
repo: rmx-validator3
idq: id-046
issued-at: 2026-10-07T09:53Z
updated: 2026-10-07T09:53Z
---
# op-542u — reply to op-539

```text
reply to op-539
agent:      validator3
outcome:    DONE — child-task setters reviewed; no correctness finding
question:   Own: can a foreign request mutate the caller, or either setter update an exited task or use a stale control port?
access:     primary — pinned source, plan, tests, fixtures and exact final serial records
score:      9/10 — direct source traces establish routing, transition ordering and ownership
verdict:    CLOSE — two checked foreign setters work; other foreign operations are refused
evidence:   /Users/me/wip-mach/rmx-validator3/reviews/op-539/op516-review.md sha256:8b71d66d5a933e4bc2fcc9bd089d38b9c68560589927b7d158df7c6df70688ab
            wip-rmxos@4de4d9ae sys/compat/mach/kern/ipc_tt.c:702-831
            wip-rmxos@4de4d9ae sys/compat/mach/ipc/ipc_kobject.c:289-331
            wip-rmxos@4de4d9ae sys/compat/mach/mach_traps.c:231-482
commits:    f8dcc76
untested:   No fresh builds/guests or forced exit/exec interleavings. Pipe waits use the outer ATF bound. Cleanup: none, 0 bytes.
blockers:   none
next:       Close the source review of op-516.
```
