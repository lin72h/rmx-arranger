---
id: op-413
state: hold
agent: implementer
repo: rmx-implementer
idq: id-047
needs: op-412
gate: self
authority: change rmx-stage-image's rmx-stage-kernel/v1 loader check; restage op-396's KASAN and KMSAN images as new files; no guest runs; no push
updated: 2026-10-02T03:09Z
---
# op-413 — Implementer: correct the kernel= line in instrumented-profile images (it names a directory), restage the KASAN and KMSAN images

## Outcome

Context: ordinary testing of our own open-source OS (rmxOS: FreeBSD 15 with Apple's open-source
Mach IPC).

op-410 (rmx-gatekeeper1 `ca5ac4a`, `build/op410/findings.md`) booted the op-396 KASAN image, but the
loader started the RELEASE kernel, and the KASAN `mach.ko` then failed to load
(`__asan_load4_noabort` undefined). Cause: in `loader.conf`, `kernel=` names a directory under
`/boot`, and the loader appends `/kernel` (`stand/lua/config.lua:717-800`). op-396's images say
`kernel="RMXOS-KASAN/kernel"`, so the loader looks for `/boot/RMXOS-KASAN/kernel/kernel` and falls
back to another kernel. `rmx-stage-image`'s `rmx-stage-kernel/v1` check requires that wrong form.

1. Change the `rmx-stage-kernel/v1` consumer check and its self-test to `kernel="<config>"`
   (`mach_name` stays the full path). Leave the `rmx-stage-image/v1` path unchanged.
2. Restage the KASAN and KMSAN profiles as new image files from the same op-396 artifacts, with
   `kernel="RMXOS-KASAN"` and `kernel="RMXOS-KMSAN"`.
3. Show from the loader source that the new line selects `/boot/<config>/kernel`, and note in your
   record that op-364's and op-388's `kernel="RMXOS-RELEASE/kernel"` only works by fallback. Do not
   change those images.

Evidence: the helper commit, both new image hashes, and the BOMs (by path).

## Limits

- No product source change. Do not touch the existing op-396, op-364 or op-388 images.

Re-read OPS.md first: defaults and the REPORT block.
