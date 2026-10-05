---
id: op-501u
state: closed
cast: unicast
answers: op-500
agent: implementer
repo: rmx-implementer
idq: id-046
issued-at: 2026-10-05T04:52Z
updated: 2026-10-05T04:52Z
---
# op-501u — reply to op-500

```text
reply to op-500
agent:      implementer
outcome:    DONE — libxpc fixes, identical tests, two ZFS images and self-checks complete
selfcheck:  fixed 74/74 PASS (5 new + 69 earlier); base 5/5 as expected (4 FAIL, unchanged cancellation PASS); 2/4 boots used
evidence:   docs/op500-libxpc.md
            /Users/me/wip-mach/stage/images/op500-base-tests-r2.raw sha256:d0dfd4f23046846a3b81e432a6e5bbfa7c531e1df2e45be13b5bf210bdb29ac0
            /Users/me/wip-mach/stage/images/op500-fixed-tests-r2.raw sha256:d9760714993507cb0c0747bffa18c998d97c553d8a81f82e82427eb35baa0fa1
            /Users/me/wip-mach/stage/artifacts/op500-base-tests-r2/bom.json
            /Users/me/wip-mach/stage/artifacts/op500-fixed-tests-r2/bom.json
commits:    wip-rmxos 6fa8f399d75a c1d8ac2a9b71 934c8d2759b6 bd6bc1b80341 6a20061b82be on-origin:no
            rmx-implementer 913ada5a5f7d on-origin:no
untested:   PORT_DIED/PORT_CHANGED classification and unchanged synchronous waits: source review only
blockers:   none
next:       Validator review and Gatekeeper acceptance
```
