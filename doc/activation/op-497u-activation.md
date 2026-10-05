---
id: op-497u
state: closed
cast: unicast
answers: op-495
agent: implementer
repo: rmx-implementer
idq: id-046
issued-at: 2026-10-05T02:45Z
updated: 2026-10-05T02:45Z
---
# op-497u — reply to op-495

```text
reply to op-495
agent:      implementer
outcome:    DONE — both fixes committed; ZFS pair self-checked; no push
selfcheck:  base 1/1 as expected (FAIL); fixed 69/69 PASS, including all 68 earlier cases; 2/3 boots
evidence:   docs/op495-launchd.md
            /Users/me/wip-mach/stage/images/op495-base-tests-r1.raw sha256:1ef992bec62b8f273074965b44c7c3fb28130538680da327e86a2e0c832ec2c0
            /Users/me/wip-mach/stage/artifacts/op495-base-tests-r1/bom.json
            /Users/me/wip-mach/stage/images/op495-fixed-tests-r1.raw sha256:aca18a6b8b5511fd6ed693142ead67f54446ac7b22123b22604b9858bf7e7c57
            /Users/me/wip-mach/stage/artifacts/op495-fixed-tests-r1/bom.json
commits:    wip-rmxos 68e847c31223112a30f64040c61adf012d9b4f0c 0f1f76d5077bc9bd24c25dbaa8651866a7fc4448 on-origin:no
            rmx-implementer b90aaa0b8a6359eb1f84c47bc5c63b2d4a956b91 on-origin:no
untested:   drain runtime; allocation/registration failure injection — source review only
blockers:   none
next:       Gatekeeper verification of the ZFS pair
```
