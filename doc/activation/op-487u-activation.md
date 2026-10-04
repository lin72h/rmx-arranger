---
id: op-487u
state: closed
cast: unicast
answers: op-484
agent: implementer
repo: rmx-implementer
idq: id-046
issued-at: 2026-10-04T21:07Z
updated: 2026-10-04T21:07Z
---
# op-487u — reply to op-484

```text
reply to op-484
agent:      implementer
outcome:    BLOCKED — crash-test trigger needs clarification
evidence:   /Users/me/wip-mach/rmx-implementer/docs/op484-launchd.md
commits:    none; test drafts and record are uncommitted
selfcheck:  not run; 0/4 boots used
images:     none; hashes and BOMs unavailable
cleanup:    no disks or build objects created
untested:   all cases; drafts formatted but not runnable
blockers:   specified exit status 1 never enters the existing crash-drain path
next:       resolve the trigger choice, then complete tests before fixes

Summary (agent prose): Exit status 1 does not trigger crash draining: core.c:3821 sets j->crashed only for fatal signals, and :3840 requires it. The pending choice is to test with a fatal signal or extend draining to exit status 1.
```
