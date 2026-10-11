---
id: op-625u
state: closed
cast: unicast
answers: op-622
agent: implementer
repo: rmx-implementer
idq: id-063
issued-at: 2026-10-11T05:06Z
updated: 2026-10-11T05:07Z
---
# op-625u — reply to op-622

```text
reply to op-622
agent: implementer
outcome: FAILED — implementation and both overlays committed; RELEASE stopped at earlier accepted `dispatch_mach_test:send_death_registration`.
selfcheck: RELEASE 83 passed, 1 failed, 829 unrun; five MIG modes exit 0; normal power-off; no assertion/fatal trap; KASAN unrun; 2/6 boots used.
evidence: docs/op617-round3.md § Item 4
build/ci/bf1658fe44f57545c7e90cd14cb81939bfe44e4b/overlays/rmxos-release-op622/overlay.ufs sha256:18333c493767b0d4116f28587df6a2efe7f68a0fa324db34e863b2703d43e682
build/ci/bf1658fe44f57545c7e90cd14cb81939bfe44e4b/overlays/rmxos-kasan-op622/overlay.ufs sha256:de67352e3abcc2122b4d92a57f48c2cc260ccd1b3be0977cbdbe120b8094b5f8
build/op622/runs/rmx-selfcheck-op622-fixed-release-r1-1791694578/install/serial.txt sha256:c220cf7fe124aa5b874bb690094ce3aef1fa8abe4655261fe3752adb17123299
build/op622/runs/rmx-selfcheck-op622-fixed-release-r1-1791694578/tests/serial.txt sha256:bff9f0d399e94e0d65af94b528e02e490e1486be6b64c26403788cd5dc140cc7
Cleanup recorded in build/op622/cleanup.txt; freed 4.14 GiB.
commits: wip-rmxos 43819bf1185cdaec12f5cacc54140227f41afa30 on-origin:no
wip-rmxos c596cc5cb3145fd3b5711092d87328aed30add64 on-origin:no
wip-rmxos bf1658fe44f57545c7e90cd14cb81939bfe44e4b on-origin:no
rmx-implementer 394759e4ef9d8637f5971287ce0d138a9709fb60 on-origin:no
rmx-implementer 9b3680a0c9c78204e5bfc2c080477520789ba335 on-origin:no
untested: New notification cases, 400-case repeat, remaining RELEASE cases and KASAN.
blockers: Selector 66 with sync=0 does not immediately notify an already-dead name; ipc\_right.c:371–389 requires immediate=true. Brief mandates stopping on an earlier accepted failure.
next: Authorize correction of the combined dead-name behavior and rerun both profiles.
```
