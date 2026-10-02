---
id: op-410
state: closed
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-047
gate: self
authority: guest boots: up to 4 on copies of op396-RMXOS-RELEASE.raw and op396-RMXOS-KASAN.raw, 15-minute cap each; loader variables through bhyveload -e; doas: load vmm.ko if absent, and the runner's bhyve calls; push rmx-gatekeeper1 main
updated: 2026-10-02T03:09Z
---
# op-410 — Gatekeeper 1: first sanitizer boots — op-372 slice on the op-396 RELEASE and KASAN images (Instrumentation 1.0 survey)

## Outcome

Context: ordinary testing of our own open-source OS (rmxOS: FreeBSD 15 with Apple's open-source
Mach IPC). A sanitizer kernel checks our kernel code's memory use while normal tests run. Everything
runs in disposable bhyve guests with no network.

First Instrumentation 1.0 run: boot two op-396 images and run your op-372 Mach and dispatch slice on each,
then report every sanitizer or assertion message.

Images (alpha2 code, `mach.ko` built with its kernel; work on copies):
- P0: `/Users/me/wip-mach/stage/images/op396-RMXOS-RELEASE.raw` sha256 `dbeeac23beba9535045fa1df57f149d318a18404ea255e57f02293b45fc15700`
- P1: `/Users/me/wip-mach/stage/images/op396-RMXOS-KASAN.raw` sha256 `6385b61895fdb6232be1a9ac1457d1fb3d397aa379b50538c9583c870a0bbfd8`

The kernels live in `/boot/RMXOS-RELEASE/` and `/boot/RMXOS-KASAN/`; update the slice's identity
checks to these images' kernel and `mach.ko` hashes (from their BOMs under
`/Users/me/wip-mach/stage/artifacts/op396-RELEASE/` and `op396-KASAN/`).

Run each image in survey mode: pass `debug.kasan.panic_on_violation=0` and
`debug.kassert.warn_only=1` as loader variables (`bhyveload -e`), so every report is logged and the
run continues. In this build `mach.ko` has its assertions compiled in for the first time, so
op-389 #1 and #11 may log assertion messages; that is expected.

Report, for each image: whether `mach.ko` loads (its symbols resolve through leak-locals, id-045),
the slice results, and every KASAN or assertion message with the backtrace after it, grouped by
stack, each marked as in Mach code (`sys/compat/mach`) or elsewhere. Do not judge causes; the
Arranger turns reports into IDQ rows.

Evidence by path; hash only each boot's raw serial log. Commits on origin.

## Limits

- Survey only: no product edits, and no changes to the images beyond run copies.
- If a boot stops in the debugger, record the backtrace from the serial log and end the boot.

Re-read OPS.md first: defaults and the REPORT block.
