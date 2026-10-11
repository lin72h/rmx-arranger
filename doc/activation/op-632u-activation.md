---
id: op-632u
state: closed
cast: unicast
answers: op-631
agent: implementer
repo: rmx-implementer
idq: id-063
issued-at: 2026-10-11T06:49Z
updated: 2026-10-11T06:49Z
---
# op-632u — reply to op-631

```text
Committed the MIG generator fix, regenerated endpoints, tests, and op-631 record (docs/op617-round3.md:913).

RELEASE: **1,012 passed, 21 failed, all 1,033 ran**. Failures comprise ten send-once setup failures, ten old-format VM requests, and one old-format named-port-set request. Dispatch recovery passed 10/10; the repeat passed 400/400. KASAN remains unrun as required. Removed 4.322 GiB of superseded files. No push.

reply to op-631
agent: implementer
outcome: PARTIAL — fix committed; RELEASE failed; KASAN withheld.
selfcheck: RELEASE 1012 PASS / 21 FAIL; repeat 400/400; five MIG modes exit 0 with stale-client -304 observations; normal power-off; no assertion/fatal trap; 2/6 boots.
evidence: docs/op617-round3.md § op-631
evidence: build/op631/runs/rmx-selfcheck-op631-fixed-release-r1-1791700709/tests/serial.txt sha256:038b1a91a2058807bf815a609eb6b1dec42b91c66eb070e0245a09a1e15d6986
evidence: build/ci/b37991c40ac2fa69b64479f541cca3bed4c0a357/overlays/rmxos-release-op631/overlay.ufs sha256:27af1893cc08b38cc06e2a14572c8e7f649cc9cfbb84a92945987172d9be79f3
evidence: build/ci/b37991c40ac2fa69b64479f541cca3bed4c0a357/overlays/rmxos-kasan-op631/overlay.ufs sha256:0fe7cb926c9fc05d1c9c2be6cff167b0e8bb2d3305ed3f34c37d4f17b192afd3
commits: wip-rmxos 3ba1f28d82fd27cc07321c50a050b91160824bdc on-origin:no
commits: wip-rmxos a4e79df468a760832d8ab4071a615c8fbe111fdf on-origin:no
commits: wip-rmxos b37991c40ac2fa69b64479f541cca3bed4c0a357 on-origin:no
commits: rmx-implementer f395bbf102b8d7ebdc9614f1a19872b7446456f2 on-origin:no
commits: rmx-implementer ab9e88a0e0d81646a3d67fc9662023ccdfaa8c1a on-origin:no
commits: rmx-implementer a7d04508f02d0b4c350162334309f3b2c63512a1 on-origin:no
commits: rmx-implementer 85bba27e3ae43b8cdc58aeaeaed930855f6b6020 on-origin:no
untested: KASAN runtime; SEND_ONCE receiver acceptance.
blockers: Earlier accepted fixture failed; stop rule applies.
next: Authorize fixture ABI/generator-binding corrections and supported send-once setup before rerunning both profiles.
```
