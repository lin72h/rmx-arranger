---
id: op-638u
state: closed
cast: unicast
answers: op-636
agent: validator1
repo: rmx-validator1
idq: id-063
issued-at: 2026-10-11T09:33Z
updated: 2026-10-11T09:33Z
---
# op-638u — reply to op-636

```text
reply to op-636
agent:      validator1
outcome:    DONE — send-possible + MIG generator review complete; 2 must-fix findings, 1 low, generator changes cleared; deliverable at reviews/op-636/review.md (107 lines)
score:      8/10
verdict:    REMEDIATE — (1) non-immediate send-possible registrations never fire (ipr_sparm = immediate in ipc_right_dnrequest; ipc_port_spnotify requires ipr_sparm); (2) MACH_SEND_NOTIFY does not self-arm on first use (ipc_port_request_capture needs a pending spreq slot) and returns MACH_SEND_TIMED_OUT instead of MACH_SEND_WILL_NOTIFY
evidence:   /Users/me/wip-mach/rmx-validator1/reviews/op-636/review.md (committed f07769b)
commits:    f07769b
untested:   Apple bootstrap_cmds file-by-file comparison (not local); end-to-end dispatch behavior with an armed timeout; mach_send_possible.zig coverage; docs/op617-round3.md reconciliation; regenerated VM/task server bodies beyond RetCode spots
blockers:   none
next:       Implementer fixes findings 1-2 and extends mach_send_possible.zig
```
