---
id: op-584u
state: closed
cast: unicast
answers: op-579
agent: implementer
repo: rmx-implementer
idq: id-046
issued-at: 2026-10-09T00:52Z
updated: 2026-10-09T00:52Z
---
# op-584u — reply to op-579

```text
reply to op-579
agent:      implementer
outcome:    DONE — trap rejects unsupported bits before narrowing; both rebuilt profiles pass
selfcheck:  RELEASE and KASAN each 93/93 earlier + 50/50 new PASS; vm_protect expected=4 observed=4 ten times; MIG 5/5 exit 0; normal power-off; no assertion/fatal trap/KASAN report; 4/6 boots used
evidence:   docs/op569-leftovers.md
            build/ci/8ed4d57bf316a43aee57dbdcc72c00ae78a6df40/overlays/rmxos-release/overlay.ufs sha256:3f20fb4d436eca7debd0b0a1101c0b6277e9fdde3c0f24444831cc0beb918f35
            build/ci/8ed4d57bf316a43aee57dbdcc72c00ae78a6df40/overlays/rmxos-kasan/overlay.ufs sha256:7f4ff5cd9f78ce1a891a3da014559c9238681ddb587cc20c737afa708c1fd04a
            build/op579/runs/rmx-selfcheck-op579-fixed-release-r1-1791506175/tests/serial.txt sha256:04c3c5ab82ca10607caa8e638f80fe0992e9c9d481601b466c685929241f400f
            build/op579/runs/rmx-selfcheck-op579-fixed-kasan-r1-1791506602/tests/serial.txt sha256:563c8a891cca2e13f2d88b55d0e2448e95fff78d0df7c31e1edb49cff56f34f3
commits:    wip-rmxos 8ed4d57bf316 on-origin:no
            rmx-implementer 90d7f7523b89 on-origin:no
            rmx-implementer a20f8eb1b5b6 on-origin:no
untested:   MIG protection rejection; request layouts differ (kernel/user size 68/60, protection offset 64/56), so only the trap route was fixed
blockers:   none for this op
next:       Review the recorded fix and self-checks.
```
