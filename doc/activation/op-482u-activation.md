---
id: op-482u
state: closed
cast: unicast
answers: op-481
agent: implementer
repo: rmx-implementer
idq: id-046
issued-at: 2026-10-04T20:04Z
updated: 2026-10-04T20:04Z
---
# op-482u — reply to op-481

```text
reply to op-481
agent: implementer
outcome: DONE — libmach destroys received descriptors correctly; libdispatch uses it.
selfcheck: base 2/2 as expected; fixed 65/65 PASS, including all 63 earlier cases; 2/3 boots used.
evidence: docs/op481-libmach.md
  Base /Users/me/wip-mach/stage/images/op481-base-tests.raw sha256 216f201198d7283305b54603173f045604234b65f0a732e614feec7a738b0060 BOM /Users/me/wip-mach/stage/artifacts/op481-base-tests-stage/bom.json
  Fixed /Users/me/wip-mach/stage/images/op481-fixed-tests.raw sha256 f5f0684e6122ed1c4e13c9fae78969dbd779087b061d258d6f8df25e9245b6c9 BOM /Users/me/wip-mach/stage/artifacts/op481-fixed-tests-stage/bom.json
commits: wip-rmxos 6837c38e7550 b2d5f5b73c02 on-origin:no; rmx-implementer 927efe2 2cff528 on-origin:no
cleanup: Removed four disposable disks and 6,861 KiB of build objects. Staged and earlier image pairs retained.
untested: Other consumer programs were not exercised.
blockers: none
next: Gatekeeper proof of the staged pair.
```
