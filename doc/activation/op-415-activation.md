---
id: op-415
state: issued
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-047
needs: []
gate: self
authority: guest boots: up to 4 on copies of op413-RMXOS-KASAN.raw (4 GiB) and op413-RMXOS-KMSAN.raw (8 GiB), 20-minute cap each; loader variables through bhyveload -e; doas: load vmm.ko if absent, and the runner's bhyve calls; push rmx-gatekeeper1 main
updated: 2026-10-02T03:50Z
---
# op-415 — Gatekeeper 1: KASAN and KMSAN survey boots on op-413's images — op-372 slice (Instrumentation 1.0)

## Outcome

Context: ordinary testing of our own open-source OS (rmxOS: FreeBSD 15 with Apple's open-source
Mach IPC). A sanitizer kernel checks our kernel code's memory use while normal tests run. Everything
runs in disposable bhyve guests with no network.

Repeat op-410's survey for the instrumented profiles it could not reach. op-410's KASAN boots ran the
RELEASE kernel, because op-396's images named the kernel as `kernel="RMXOS-KASAN/kernel"`. op-413
restaged the images with `kernel="RMXOS-KASAN"` and `kernel="RMXOS-KMSAN"`.

Images (alpha2 code, `mach.ko` built with its kernel; work on copies):
- `/Users/me/wip-mach/stage/images/op413-RMXOS-KASAN.raw` sha256 `b1f44761eab6b11df96e760fc0ad44e9262aff4c148489d7d951bb6752e39422` (4 GiB guest)
- `/Users/me/wip-mach/stage/images/op413-RMXOS-KMSAN.raw` sha256 `a3eff4dcaaa7a4a8097c65af49e7bd9592b72a5ed96b89054ad546851846131a` (8 GiB guest; kmsan(9) asks for at least 8 GB)

Before any wave of the slice, check `kern.bootfile` and `kern.ident` in the guest: they must name the
profile's kernel. If not, stop that boot and report it. Run as in op-410: survey mode
(`debug.kasan.panic_on_violation=0` or `debug.kmsan.panic_on_violation=0`, and
`debug.kassert.warn_only=1`, through `bhyveload -e`), then your op-372 slice, with identity
checks updated to these images' BOMs (`/Users/me/wip-mach/stage/artifacts/op413-KASAN/`, `op413-KMSAN/`).

Report for each profile: kernel identity, whether `mach.ko` loads, the slice results, and every
sanitizer or assertion message with the backtrace after it, grouped by stack and marked as in Mach
code (`sys/compat/mach`) or elsewhere. KMSAN is slow (two to three times); give the slice the time it
needs within the cap.

Evidence by path; hash only each boot's raw serial log. Commits on origin.

## Limits

- Survey only: no product edits, and no changes to the images beyond run copies.
- If one profile fails for a reason outside your harness, record it and still run the other.

Re-read OPS.md first: defaults and the REPORT block.
