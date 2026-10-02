---
id: op-416
state: closed
agent: implementer
repo: rmx-implementer
idq: id-046
needs: []
gate: self
authority: build: mach.ko (fixed branch, and the base build with only the MODULE_VERSION line), libmach and the tests; restage the base + tests and fixed + tests images; no guest runs; no push
updated: 2026-10-02T04:17Z
---
# op-416 — Implementer: resolve op-411's three mismatch causes — mach MODULE_VERSION, fd_exhaustion result code, bounded clock tests — and restage both test images

## Outcome

Context: ordinary bug fixing and testing in our own open-source OS (rmxOS: FreeBSD 15 with
Apple's open-source Mach IPC).

op-411 (rmx-gatekeeper1 `13f1212`, `build/op411/findings.md`) confirmed 20 of 27 cases, including
op-408's 13 base panics and `short_buffer` on the fixed image. Resolve the three causes of the
other seven, each as its own commit on `mach-fixes-1` (after `1045a24b`):

1. **The fixture cannot load.** `translate_fixture/adapter.c:84` has
   `MODULE_DEPEND(rmx_translate_fixture, mach, 1, 1, 1)`, but `mach.ko` declares no version
   (`sys/compat/mach/mach_module.c:298-304` has `DECLARE_MODULE` only). Add `MODULE_VERSION(mach, 1)`
   in FreeBSD's usual form. For the base image, build `mach.ko` from `2884304b` plus only this line,
   and say so in the BOM, so the "before" behaviour stays alpha2's.
2. **`mach_file_lifetime_test:fd_exhaustion` on the fixed image** returned
   `MACH_RCV_BODY_ERROR|MACH_MSG_IPC_KERNEL` (0x1000480c); the test expects
   `MACH_RCV_BODY_ERROR|MACH_MSG_IPC_SPACE`. Decide which is right from XNU's copyout path
   (`/Users/me/wip-mach/reference/xnu-xnu-12377.121.6/`): a receiver that has no room for a new name
   versus a kernel resource shortage. Cite the XNU lines. Change the code or the test to match, and
   record the reason.
3. **`mach_clock_test:absolute` and `:past` on the base image** ran into op-411's 15-second outer
   timeout, because the unfixed code sleeps far too long (the defect itself). Make these tests bound
   their own wait, so the unfixed code gives an ATF FAIL inside the test. Leave their fixed-image
   expectations as they are.

Rebuild and restage both images as before. Update `tests/sys/mach/EXPECTATIONS.md` if anything
changes. Evidence: the three commits, the XNU citation for 2, both image hashes and the BOMs (by path).

## Limits

- Only these three changes. No push of `wip-rmxos`.

Re-read OPS.md first: defaults and the REPORT block.
