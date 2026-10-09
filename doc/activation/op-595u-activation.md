---
id: op-595u
state: closed
cast: unicast
answers: op-590
agent: implementer
repo: rmx-implementer
idq: id-046
issued-at: 2026-10-09T21:51Z
updated: 2026-10-09T21:51Z
---
# op-595u — reply to op-590

```text
reply to op-590
agent: implementer
outcome: BLOCKED — RELEASE complete; KASAN runtime coverage remains
selfcheck: RELEASE 723/723 PASS; MIG 5/5 exit 0; normal power-off; no assertion/fatal trap; KASAN unrun; boots 6/6
evidence: build/ci/b61f0f9164170ed9d9d2b3fd312e34eee2603f09/overlays/rmxos-release-op590/overlay.ufs sha256:0dc0de0c632583e5703d9b300370cd66b69b44946a997a88da751f36ce2026e2
evidence: build/ci/b61f0f9164170ed9d9d2b3fd312e34eee2603f09/overlays/rmxos-kasan-op590/overlay.ufs sha256:9d865e0fb17f11ef70c86a103248ccf5f6df5df6c6f81b85c51cbb4b370f8259
evidence: build/op590/runs/rmx-selfcheck-op590-fixed-release-r3-1791582016/tests/serial.txt sha256:0be51b4dda201b352650a3d8c54bc55233e15248b0714c47609b4049c0b46e18
evidence: docs/op586-host-task-vm.md
commits: wip-rmxos 521da1c20dd0 on-origin:no
commits: wip-rmxos df3e88094fe0 on-origin:no
commits: wip-rmxos b61f0f916417 on-origin:no
commits: rmx-implementer c465303 on-origin:no
commits: rmx-implementer f5d3210 on-origin:no
commits: rmx-implementer d523a10 on-origin:no
commits: rmx-implementer 6730622 on-origin:no
untested: KASAN cases, MIG modes and sanitizer runtime
blockers: six-boot budget exhausted by authorized test-correction retries
next: authorize two KASAN boots on the retained b61f0f916417 overlay
```
