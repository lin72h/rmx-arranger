---
id: op-409
state: draft
agent: implementer
repo: rmx-implementer
idq: id-046
gate: self
authority: build: the tests/sys/mach fixture module and the test set; restage the two op-395 test images with rmx-stage-image; no guest runs; no push
updated: 2026-10-02T02:32Z
---
# op-409 — Implementer: rebuild the Mach test fixture module so the kernel can load it, and restage op-395's images

## Outcome

Context: ordinary bug fixing and testing in our own open-source OS (rmxOS: FreeBSD 15 with
Apple's open-source Mach IPC).

op-408 (rmx-gatekeeper1 `18f721d`, `build/op408/findings.md`) ran op-395's tests: 13 base cases
gave their expected results, but the fixture module did not load:
`kldload: unexpected relocation type 10, symbol index 3`. The fixture
`tests/sys/mach/translate_fixture` (`rmx_translate_fixture.ko`) contains five `R_X86_64_32`
relocations, which the amd64 kernel linker does not accept. The three programs that load it
(`mach_translate_test`, `mach_proc_info_test`, `mach_timeout_test`) are untested.

Rebuild the fixture the way FreeBSD builds kernel modules (`sys/conf/kmod.mk`: kernel code model,
no red zone, no unwind tables, `-ffreestanding`), on top of `mach-fixes-1`, as one commit.
Before staging, show from `readelf -r` that the module uses only relocation types the amd64 kernel
linker accepts; cite the accepting code in `sys/amd64/amd64/elf_machdep.c`.

Restage the two images (base + tests, fixed + tests) as op-395 did, changing only the fixture
(and anything that must change with it). Evidence: the commit, the relocation listing, both new
image hashes, and the BOM and inventories (by path).

## Limits

- Change only the fixture's build and, if needed, its sources. Leave the Mach fixes and the other
  tests as they are.
- No push of `wip-rmxos`.

Re-read OPS.md first: defaults and the REPORT block.
