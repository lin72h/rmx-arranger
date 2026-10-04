---
id: op-480u
state: closed
cast: unicast
answers: op-478
agent: implementer
repo: rmx-implementer
idq: id-046
issued-at: 2026-10-04T11:13Z
updated: 2026-10-04T11:13Z
---
# op-480u — reply to op-478

```text
reply to op-478
agent: implementer
outcome: DONE — partial-receive cleanup fixed; pending-request control passes.
selfcheck: base 2/2 as expected; fixed 63/63 PASS; 3/3 boots used.
evidence:
- /Users/me/wip-mach/rmx-implementer/docs/op478-libdispatch.md
- Base: /Users/me/wip-mach/stage/images/op478-base-tests.raw sha256 000d7f99d96838298f4074c626d292b521413477b4a5211123745e5745c2e432 BOM /Users/me/wip-mach/stage/artifacts/op478-base-tests-stage/bom.json
- Fixed: /Users/me/wip-mach/stage/images/op478-fixed-tests.raw sha256 de512cd342fcd0ae50f199235c49de2fc6d8ede6fa5bea9d2d42a7d82b75252f BOM /Users/me/wip-mach/stage/artifacts/op478-fixed-tests-stage-r2/bom.json
commits: wip-rmxos fa31a12e09ed 056ce77dfa6e 22334ca35eb6 on-origin:no; rmx-implementer 1e42246 b6ceb5e fb622e6 on-origin:no
cleanup: Removed six disposable copies (48 GiB logical) and 5,357 KiB of build objects. Both image pairs retained.
untested: Real kernel partial-copyout failure and OOL mappings; test injects BODY_ERROR after a real receive.
blockers: none
next: Gatekeeper proof of the staged pair.
```
