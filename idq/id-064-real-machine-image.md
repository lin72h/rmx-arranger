# id-064 — first rmxOS image that boots on a real machine (x86-64 Rocket Lake, UEFI)

- priority: high (Coordinator, 2026-10-11: "I do want a version that I can run on real machine")
- state: **DEFERRED — until rmxOS is properly ready (Coordinator, 2026-10-11)**
- raised: 2026-10-11 (j-20261011-018, j-20261011-020)
- related: id-015 (staging-model image, proven in VMs), id-012 (installer route, deferred)

## Target

Coordinator's machine: x86-64 Intel Rocket Lake (11th generation desktop), UEFI. Other hardware
(storage, network, graphics) to be confirmed by the Coordinator or found at first boot.

## Route

1. op-641 (explorer1): inventory of what the proven VM image lacks for a UEFI real-machine boot.
2. Implementer: one USB-bootable RELEASE image from the pushed `mach-fixes-6` head, booted once in
   a UEFI bhyve guest, then handed to the Coordinator.
3. The Coordinator boots it on the machine; first-boot findings come back as ops.

Decisions (Coordinator, 2026-10-11): op-637 stopped blocking the `mach-fixes-6@93b3735d` push.
Then: "I don't think we are ready for real machine ... should do it after we done job properly and
really ready": id-064 deferred, op-641 held; op-619 returns to its place on the Mach path.
The Coordinator's need is standing: plan toward a real-machine image, not a rush to one.
