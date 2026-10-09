---
id: op-578u
state: closed
cast: unicast
answers: op-577
agent: implementer
repo: rmx-implementer
idq: id-046
issued-at: 2026-10-09T00:16Z
updated: 2026-10-09T00:16Z
---
# op-578u — reply to op-577

```text
reply to op-577
agent:      implementer
outcome:    BLOCKED — runner complete; test-input narrowing prevents green self-checks.
evidence:   docs/op569-leftovers.md
            build/op577/runs/rmx-selfcheck-op577-fixed-release-r1-1791504139/install/serial.txt sha256:383596ff647301de8155ea1d8d715ef23600d55fd019606533cd8d3806975f2c
            build/op577/runs/rmx-selfcheck-op577-fixed-release-r1-1791504139/tests/serial.txt sha256:983d91ef6af6b1d8106f118ff8e854c2873762fbb272e326b532535620df0919
commits:    rmx-implementer 2ed10e7 on-origin:no
            rmx-implementer c728342 on-origin:no
untested:   Fixed KASAN; replacement protection input.
blockers:   Test-source correction and overlay rebuild are outside this op's authority.
next:       Authorize a protection-input correction that survives vm_prot_t narrowing, rebuild, and rerun both profiles.
```
