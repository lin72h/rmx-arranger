---
id: op-509u
state: closed
cast: unicast
answers: op-507
agent: implementer
repo: rmx-implementer
idq: id-046
issued-at: 2026-10-06T23:56Z
updated: 2026-10-06T23:56Z
---
# op-509u — reply to op-507

```text
reply to op-507
agent:      implementer
outcome:    DONE — reconnect avoids delivery-queue waits; process watcher follows the current server
evidence:   docs/op507-libxpc.md
            /Users/me/wip-mach/stage/images/op507-base-tests-r1.raw
            sha256:1147204f8d54213a21f69d2ceebf9aca2775442b6e4dca4c8ae6d0a4759ee7da
            /Users/me/wip-mach/stage/images/op507-fixed-tests-r1.raw
            sha256:791ae666dbe60f1e7ba9f1bf1bccc95ef76fc05cd8f2f71988846338f9869986
            /Users/me/wip-mach/stage/artifacts/op507-base-tests-r1/bom.json
            /Users/me/wip-mach/stage/artifacts/op507-fixed-tests-r1/bom.json
            build/op507/selfcheck-r1/selfcheck-base-1.json
            build/op507/selfcheck-r1/selfcheck-fixed-all-2.json
commits:    wip-rmxos 004eb90b5d479e327ddfb79f28b4e28740a4c24d on-origin:no
            wip-rmxos 2de5f1d4112d433f7ae1ebbdd10bfe2ab450d34e on-origin:no
            rmx-implementer fd8ef03e51c68be1223f14980519daecf536b521 on-origin:no
untested:   Excluded synchronous-reply waits; real launchd namespace restart; credential-only PID replacement
blockers:   none
next:       Validator review and Gatekeeper verification
```
