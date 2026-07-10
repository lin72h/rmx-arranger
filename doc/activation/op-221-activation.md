# op-221 — Implementer: rebuild the id-015 UEFI image from CANONICAL lineage (kernel + mach.ko same-lineage, narg=8) — abandon the stale op-217 `f712` snapshot whose generated sysproto.h registers `mach_msg_overwrite_trap` at 9 register slots → re-stage → hand to op-220 for the edk2 re-boot oracle

op-221 | role: **Implementer** (cost-30) | EXU: **wip-gpt** | state: **[Done — FIXED, Arranger-verified first-hand 2026-06-30].** Canonical-lineage UEFI image rebuilt, narg=8 restored, f712 abandoned. VERIFIED: (1) revert landed — canonical HEAD `32f21706606f Revert "mach: enable LP64 syscall arg munging"` atop `483073c`; (2) narg=8 BY CONTENT — generated sysproto.h view 64/8, `mach_module.o` (`e0eed686…`, byte-identical to op-166 + op-219_current) `osx_syscalls[21].sy_narg=8`; (3) same-lineage — kernel `c526a91d` is the op-182 li-1012 clean-cert MACHDEBUGDEBUG kernel (canonical baseline, NOT f712), mach.ko `ffc67eda` is canonical narg=8 AND == op-215's gated module (carries the 12b349 ipc_entry_lookup de-spam gate too); (4) in-image content confirmed first-hand (`op221-usb-content-proof.txt`) — `/boot/kernel/kernel`+`/boot/MACHDEBUGDEBUG/kernel`=`c526a91d`, `/boot/modules/mach.ko`=`ffc67eda`; (5) UEFI form — GPT-only ESP+UFS no-BIOS, ISO `et_system=efi`. Artifacts: USB `106a373c…` (3.1GB), ISO `218554…` (6.2GB). NOTE: reused loader.conf has stale `kernel=` blocks (TWQDEBUG/MACHDEBUG) above MACHDEBUGDEBUG — last-wins boots MACHDEBUGDEBUG+`mach_load=YES` correctly, op-220 confirms at banner. NOT boot-certified here → op-220. | parent id: id-015 | L1i: li-006 (image/boot logistics) | cost: 30 | authored 2026-06-30 (Arranger seat, model Opus 4)

## WHY (one line)

op-219 PROVED (content-level, Arranger re-verified) the `mach_msg_overwrite_trap` narg=9 panic is **NOT** a source-macro gap and **NOT** tree-wide: the registered arg struct comes from **generated `sysproto.h`** (`mach_module.c:35` includes `<sys/sysproto.h>`; `SYSCALL_INIT_HELPER` takes `sizeof` of *that* struct, not the `mach_traps.h`/`PAD_ARG_8` one), and `CONFIG_REQUIRES_U32_MUNGING` is a no-op for it. Current canonical = narg **8**; op-166 `9c7706a3` = narg **8**; **only the op-217 `f712` build snapshot = narg 9** (its generated sysproto.h has a stale 9-slot `mach_msg_overwrite_trap_args` vs canonical's corrected 8-field struct). So the op-217 image was simply built from a **divergent/stale snapshot**. The fix is to rebuild the id-015 UEFI image from the **one canonical tree** (already narg=8), not to do surgery on the dead f712 snapshot.

## SCOPE / SUBJECT (rebuild id-015 image from canonical; same-lineage kernel+module; reuse op-217 UEFI packaging recipe)

- **Source = canonical only:** `wip-gpt/wip-rmxos` @ `op-171-x86-64-v3-alpha` (the ONE editable tree). Do NOT build from, regenerate, or patch the deprecated `f712` `src-f712-op215`/`obj-f712-op215` snapshot — abandon it.
- **Kernel + mach.ko MUST be same-lineage.** The narg=9 lives in the loaded module's `osx_syscalls[]` AND the op-217 kernel shares f712's 72-byte `mach_msg_overwrite_trap_args` view — so a canonical narg=8 module dropped into the f712 kernel is a NEW cross-lineage ABI mismatch. Build BOTH the MACHDEBUGDEBUG kernel and `mach.ko` from canonical (narg=8, consistent 64-byte struct). NO cross-lineage module swap (that is exactly the trap op-217 fell into).
- **Reuse op-217's proven UEFI packaging** (pure-UEFI GPT, ESP→`loader.efi`, no BIOS/no installer — the chain op-218 proved green) and the staged userland overlay (lib-copy, lineage-tolerant). The change vs op-217 is ONLY the lineage of the kernel+modules, not the image FORM.
- **Revert the no-op flag commit** `483073c69646` ("mach: enable LP64 syscall arg munging") on canonical — proven to change nothing (mach_module.o byte-identical with/without), and its message overclaims a fix. Clean the tree honestly; do NOT keep a phantom "fix enabled" commit.
- **Hermetic build** (scrub the `/usr/local` `C_INCLUDE_PATH`/`LIBRARY_PATH` leak, op-176). Stage in wip-gpt's OWN dir (`agent_host_isolation`). NO buildworld beyond what the id-015 image recipe already requires.

## DELIVERABLES

**D1 — canonical narg=8 kernel+module, proven BY CONTENT.** Build the MACHDEBUGDEBUG kernel + `mach.ko` from canonical; prove the staged `mach_module.o`/`mach.ko` `osx_syscalls[21].sy_narg == 8` by content (readelf/disasm the registered sysent, or recompute `sizeof/sizeof(register_t)` from the *generated* sysproto.h actually used), and that the kernel's `mach_msg_overwrite_trap_args` view is the matching 64-byte one. → `OP221_CANON_NARG8`

**D2 — re-staged UEFI image (canonical lineage).** Package the canonical kernel+modules into the op-217 UEFI image form (USB `.img` + UEFI ISO if cheap). SHA both. Confirm by content the in-image kernel AND mach.ko are the canonical narg=8 lineage (not f712). → `OP221_IMAGE_REBUILD`

**D3 — flag revert + disposition.** Confirm `483073c` reverted on canonical (or justify keeping, with proof it is harmless AND the message corrected). Verdict `fixed` (canonical narg=8 image re-staged, SHAs recorded, ABI-consistent) | `walled` (canonical build/image blocks — REPORT exact wall). Hand the re-staged image to **op-220 (Gatekeeper)** for the edk2 re-boot oracle. → `OP221_VERDICT` / `OP221_TERMINAL`

## BOUNDARIES
- Build from CANONICAL only; the f712 snapshot is dead — do NOT regenerate/patch it.
- Kernel + mach.ko same-lineage; NO cross-lineage module swap.
- Image identity BY CONTENT (`artifact_identity_needs_content_check`) — narg=8 + lineage proof, never filename/size.
- Hermetic build (op-176). wip-gpt's OWN dir (`agent_host_isolation`).
- This is rmxOS-owned port code + image packaging, NOT FB15 base build-infra (`userland_port_no_buildinfra_changes`).

## MARKERS
```
OP221_CANON_NARG8   # canonical MACHDEBUGDEBUG kernel + mach.ko; osx_syscalls[21].sy_narg==8 by CONTENT; kernel arg-struct view 64-byte (same-lineage)
OP221_IMAGE_REBUILD # id-015 UEFI image rebuilt from canonical lineage (op-217 packaging form); USB+ISO SHA; in-image kernel+mach.ko confirmed canonical by content
OP221_VERDICT       # fixed | walled  (incl. 483073c no-op flag reverted)
OP221_TERMINAL
```

## RELATIONS
- UPSTREAM: **op-219** (proved walled + corrected the root cause to a stale f712 snapshot, not a source-macro gap), op-218 (proved the UEFI boot chain green; surfaced the panic), op-217 (the UEFI packaging recipe + the f712 image being replaced), op-166 (`9c7706a3`, a narg=8 reference module — proof the defect is NOT tree-wide).
- DOWNSTREAM: **op-220 (Gatekeeper, free)** — edk2 re-boots THIS canonical-lineage image, drives the op-104 oracle to the completion op-218 couldn't reach + confirms op-215 de-spam. [Awaiting], re-gated on op-221 `fixed` (was op-219).
- feedback: verify-premise-before-mechanism (the registered struct is sysproto.h not mach_traps.h — verified by which header mach_module.c includes + binary sy_narg invariance to the flag), build_is_implementer (kernel+module+image rebuild = Implementer), artifact_identity_needs_content_check (narg + lineage by content), mach_ko_standalone_module, agent_host_isolation, userland_port_no_buildinfra_changes, canonical_source_tree (build from the ONE canonical tree; f712 snapshot deprecated). project: 64bit_only_no_lib32, id-015 staging model, li-1012 clean-provenance.
