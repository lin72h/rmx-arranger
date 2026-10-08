---
id: op-554u
state: closed
cast: unicast
answers: op-550
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-061
issued-at: 2026-10-08T02:41Z
updated: 2026-10-08T02:41Z
---
# op-554u — reply to op-550

```text
reply to op-550
agent:      gatekeeper1
outcome:    FAILED — one fixed-suite mismatch; MIG observations and 400 repeats pass
attempts:   consumed 3/4; base PASS sha256:523f4dab3e045b072dfb6b5f845250db5b53f56f872ba4339b0deae2648632a7; fixed FAIL sha256:970766e86dfa90f91b563d867b7c21450b2a4f45ed306ea0eccc6372bad102ed; repeat PASS sha256:9f39b10050af41ba5484691fb158db9bd684abf5af532cc002794eeff076a3b7
disposition: not-accepted — build/op550/disposition.json
evidence:   build/op550/results-r2.md; build/op550/findings.md; build/op550/repeat-observations.json; build/op550/attempt-ledger-r2.json
commits:    rmx-gatekeeper1 d37da44653517469490c7540ccdb1135ea094f0e on-origin:yes
untested:   allocation/key exhaustion and exhaustive fork schedules; spare unused
blockers:   none
next:       Implementer investigates peer_send_error fact13 expected1 observed2
```
