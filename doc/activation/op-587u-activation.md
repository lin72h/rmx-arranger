---
id: op-587u
state: closed
cast: unicast
answers: op-583
agent: implementer
repo: rmx-implementer
idq: id-046
issued-at: 2026-10-09T01:44Z
updated: 2026-10-09T01:44Z
---
# op-587u — reply to op-583

```text
reply to op-583
agent: implementer
outcome: BLOCKED — builds complete; RELEASE stopped on stale foreign-VM expectation
selfcheck: 2/6 boots; RELEASE 90 PASS, 1 FAIL, 532 unrun; MIG 5/5 exit 0; normal power-off; no assertion/fatal trap; KASAN unbooted
evidence: docs/op583-last-batch.md
          build/op583/final-artifact-hashes.txt
          build/op583/runs/rmx-selfcheck-op583-fixed-release-r1-1791509832/tests/serial.txt
          sha256:5bbbdd8c0a47ff108d2a493ddd683baa14e091efcc1650ed3f8b4b46350bb158
commits: wip-rmxos 49c5880fbe87 on-origin:no
         wip-rmxos f99515c265d5 on-origin:no
         wip-rmxos 7b6f747160aa on-origin:no
         wip-rmxos 7e47847d63fc on-origin:no
         rmx-implementer d61f051 on-origin:no
         rmx-implementer 0c6373a on-origin:no
untested: new runtime cases, 400-case repeat, remaining earlier cases, KASAN, behavioral baseline runs
blockers: mach_child_setters.zig:248 expects 46; observed mandated 4; spare boots exclude test retries
next: follow-up op to correct that expectation, rebuild, and run both fixed profiles
```
