---
id: op-634u
state: closed
cast: unicast
answers: op-633
agent: implementer
repo: rmx-implementer
idq: id-063
issued-at: 2026-10-11T07:13Z
updated: 2026-10-11T07:14Z
---
# op-634u — reply to op-633

```text
Updated the fixtures and generator binding. **Both profiles passed 1,042/1,042 cases**, the 400-case repeat, and all five MIG modes with kernel return codes 0.

KASAN emitted a shutdown WITNESS lock-order warning; its full trace is recorded in op-633 (docs/op617-round3.md:1264). No assertion, fatal trap or KASAN report. Removed 2.534 GiB of superseded files. No push.

reply to op-633
agent: implementer
outcome: DONE — fixtures migrated, active image endpoints audited, both profiles run; shutdown WITNESS finding recorded.
selfcheck: RELEASE 1042/1042 PASS; KASAN 1042/1042 PASS; repeat 400/400 each; five MIG modes exit 0 with all kernel return codes 0; 4/6 boots.
evidence: docs/op617-round3.md § op-633
evidence: build/op633/runs/rmx-selfcheck-op633-fixed-release-r1-1791701971/tests/serial.txt sha256:cf838d99cf7c23f3cb994ab5f5098029fa91e313b53b19e27fc808bee14d25a2
evidence: build/op633/runs/rmx-selfcheck-op633-fixed-kasan-r1-1791702221/tests/serial.txt sha256:281ba440cf9205138a76d9a8cb539fa0e2898165c10bbb5cc9e103e75e0fecb4
evidence: build/ci/93b3735d1d8bef1f15e013599d0a56bab3968b61/overlays/rmxos-release-op633-r2/overlay.ufs sha256:81b08b76f594431e7d83db97f9c353cfe3d603efcbb0e51599368c4e03f9b183
evidence: build/ci/93b3735d1d8bef1f15e013599d0a56bab3968b61/overlays/rmxos-kasan-op633-r2/overlay.ufs sha256:7b3a7452b5b52f9441248f2c55a3822aada1eede11b10dbb09c84a58ad1729fe
commits: wip-rmxos 93b3735d1d8bef1f15e013599d0a56bab3968b61 on-origin:no
commits: rmx-implementer b534460bee274611b0e3ac90fa927eac4ff380db on-origin:no
commits: rmx-implementer ae847713260da5b4593d554144982079fe77b8c3 on-origin:no
commits: rmx-implementer a3226b4a7ce2fd3b8d9800b9c715799c906bd1bf on-origin:no
untested: Cause of shutdown WITNESS process-lock→btag-lock warning.
blockers: none for this op.
next: Investigate the recorded shutdown lock-order warning in a separate op.
```
