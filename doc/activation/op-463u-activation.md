---
id: op-463u
state: closed
cast: unicast
answers: op-461
agent: implementer
repo: rmx-implementer
idq: id-046
issued-at: 2026-10-04T01:30Z
updated: 2026-10-04T01:30Z
---
# op-463u — reply to op-461

```text
reply to op-461
agent: implementer
outcome: DONE — F1/F2 fixed; corrected queued-port reference assertion; final pair verified.
selfcheck: fixed 55/55 PASS; base 3/3 fail as expected; 4/4 boots used.
evidence:
  docs/op461-mach-remediation.md
  build/op461/selfcheck-r2/selfcheck-base-3.json
  build/op461/selfcheck-r2/selfcheck-fixed-all-4.json
  /Users/me/wip-mach/stage/images/op461-base-tests-r2.raw
    sha256:0128ee8cde7dfd9ea297669f11a3990104c3a31688696dc4e0686ae046ffae81
  /Users/me/wip-mach/stage/artifacts/op461-base-tests-r2-stage/bom.json
  /Users/me/wip-mach/stage/images/op461-fixed-tests-r2.raw
    sha256:02452dd37e4bce74540266f3cc2a44a0ccf8342f583f4c7d91d0a36535472e9d
  /Users/me/wip-mach/stage/artifacts/op461-fixed-tests-r2-stage/bom.json
commits:
  wip-rmxos 2d9783692255 on-origin:no
  wip-rmxos 60099afc9c8a on-origin:no
  wip-rmxos 8ebcce09108f on-origin:no
  wip-rmxos b9aeeb286238 on-origin:no
  wip-rmxos 0924690c34a0 on-origin:no
  rmx-implementer 876335b50a5d on-origin:no
  rmx-implementer 3beef9558ac5 on-origin:no
  rmx-implementer bafabbe on-origin:no
cleanup: VM copies, object trees and helper disks removed; 32.48 MiB measured storage freed, plus unmeasured disk-copy storage. Original and revised staged pairs retained.
untested: concurrent interleavings beyond the controlled regression cases.
blockers: none.
next: Gatekeeper proof on the revised pair.
```
