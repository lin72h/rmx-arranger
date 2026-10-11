---
id: op-630u
state: closed
cast: unicast
answers: op-628
agent: implementer
repo: rmx-implementer
idq: id-063
issued-at: 2026-10-11T06:17Z
updated: 2026-10-11T06:18Z
---
# op-630u — reply to op-628

```text
Implemented and committed the MIG array fix. RELEASE stopped at the dispatch send-possible routing defect; KASAN remains unrun. Record: docs/op617-round3.md. Cleanup freed 4.46 GiB. No push.

reply to op-628
agent: implementer
outcome: PARTIAL — MIG fix passes new cases; dispatch notification routing blocks the full self-check.
selfcheck: RELEASE 117 PASS / 1 FAIL / 855 unrun; five MIG modes exit 0; normal power-off; 4/6 boots used.
evidence: docs/op617-round3.md; build/op628/runs/rmx-selfcheck-op628-fixed-release-r2-1791698622/tests/serial.txt sha256:f6b5eeb5a76b93cf341f1e4e4dad8870b788c57be22b3743e0b311672423c2d9
commits: wip-rmxos e27b4b6c2a606de5b61bca5b38d5fd3a4d65bd08 on-origin:no
commits: wip-rmxos a1232d44088b0f734529003e49925535b58d41fd on-origin:no
commits: rmx-implementer e0eaa79168af8d938ff908205fd8ef6aba48dab4 on-origin:no
commits: rmx-implementer 9865cb4ba43f943e5ac53195f67f409fc2dd3e0d on-origin:no
commits: rmx-implementer fdd19047a4fd435e08075aecd028c676822ac921 on-origin:no
untested: KASAN, remaining/repeated cases, valid clock and privileged-host RPCs.
blockers: libdispatch's generated checker rejects the kernel's simple selector-66 notification.
next: Authorize notification-layout routing correction, then rerun both profiles.
```
