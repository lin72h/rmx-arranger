# op-217 — Implementer: build the UEFI-only id-015 live image — repackage the proven staged tree as a pure-UEFI GPT image (USB + liveCD/ISO, UFS root UNCHANGED) + ABI-match the op-215 de-spam mach.ko to id-015's kernel → hand off to op-218 for the independent edk2 boot proof

op-217 | role: **Implementer** (cost-30) | EXU: **wip-gpt** | state: **[Done — `built`, Arranger artifact-verified first-hand 2026-06-29].** D1 UEFI image: USB (`op217-id015-uefi-usb.img`, sha `bda7e45c…`) **content-verified pure-UEFI GPT** — GPT hdr `EFI PART` @ LBA1; part-1 type GUID `C12A7328…` = EFI System Partition (`op217-esp`); part-2 `516E7CB6…` = freebsd-ufs (`op217-rootfs`); NO freebsd-boot GUID; protective-MBR bootstrap area all-zero (no BIOS bootcode). UFS root = the op-128 `s2a` payload, only `/boot/modules/mach.ko` swapped. ISO (`op217-id015-uefi.iso`, sha `061abcbf…`) UEFI El Torito `et_system=efi`. D2 mach.ko (sha `3989d601…`): gate present by `nm` (`mach_ipc_entry_lookup_failed_log` + `sysctl___debug_mach_ipc_entry_lookup_failed_log` + `debug.mach` node — op-215 patch genuinely applied), rebuilt from `f71260cf4c9e` source line (the stale op-196-base `ffc67eda` correctly NOT reused); in-image kernel `/boot/MACHDEBUGDEBUG/kernel` (sha `39031adb…`) is the same f71260cf line → ABI provenance matches. Handoff manifest `OP217-HANDOFF.md`. **Open for op-218 (by design):** definitive ABI-load (kldload into running kernel w/o version mismatch) + edk2 firmware boot + de-spam runtime — proven only by the actual boot. | parent id: id-015 (developer-preview staging-model image) | L1i: li-006 (image/boot logistics) | cost: 30 | authored 2026-06-29 (Arranger seat, model Opus 4)

## WHY (one line)

The user's deploy target is a **UEFI-exclusive Intel Rocket Lake workstation**, but every id-015 boot proof booted via **`bhyveload`** (`wip-gpt/scripts/bhyve/run-guest.sh:57`), which reads `/boot/loader` straight from the guest UFS and injects the kernel — **bypassing the ESP/`loader.efi`/firmware chain entirely**. So the shipped ESP has never been exercised and the real UEFI boot path is unvalidated. This op produces the artifacts to close that: a **pure-UEFI GPT live image** (USB + ISO) from the proven staged tree, plus the op-215 gated `mach.ko` **rebuilt/verified ABI-matched** to id-015's kernel (de-spams the `ipc_entry_lookup failed on 0` boot flood). The independent edk2 boot proof is **op-218 (Gatekeeper)** — the builder does NOT self-certify boot-green here, because a false-green boot proof (bhyveload silently bypassing firmware) is the exact failure mode this whole effort exists to kill. UFS root is UNCHANGED — partition-scheme/boot-path change only, NOT the ZFS-root change (id-012). **Dispatch the free Implementer NOW, parallel to op-165** — the cost map orders roles, it does not license waiting out the busy Gatekeeper to dodge a cost-30 (implementer_cost_vs_walltime).

## SCOPE / SUBJECT (Implementer artifact production — repackage staged tree + standalone mach.ko build; NO buildworld)

- **Staged tree stays as-is:** base pre-staged rmxOS snapshot (FB15 userland + MACHDEBUGDEBUG kernel @ `f71260cf` + `mach-stable15-port.patch` + `mach.ko`) + overlay lib-copy. Do NOT rebuild world — repackage the SAME staged content under a UEFI scheme.
- **Scheme change:** current image is MBR+ESP+UFS (hybrid). Produce a **pure-UEFI GPT**: GPT scheme + `efi` ESP (`loader.efi`) + `freebsd-ufs` root (content UNCHANGED). DROP all BIOS/legacy bits (no MBR, `pmbr`, `gptboot`, `freebsd-boot`). Prefer the mkimg invocation / a wrapper over editing base `release/amd64/make-memstick.sh` — if a base release script must change, diff vs stock first (userland_port_no_buildinfra_changes; the scheme is an mkimg arg, likely no base edit needed).
- **Two forms (user said "liveCD"):** (a) USB memstick `.img`; (b) UEFI liveCD ISO via `mkisoimages.sh -u`. Honest staging-model provenance, SHA both.
- **mach.ko ABI (the genuine Implementer build):** the op-215 gated `mach.ko` (sha `ffc67eda`) was built on the **op-196 base** — verify by CONTENT (module version / symbol ABI via `readelf`/modinfo), NOT filename, whether it's ABI-compatible with id-015's MACHDEBUGDEBUG kernel @ `f71260cf`. If it diverges, **rebuild the gated module against id-015's kernel source** (standalone module path: `make -C sys/modules/mach`, MAKEOBJDIRPREFIX only, hermetic env). Fold the ABI-matched de-spam module into the image.

## DELIVERABLES

**D1 — UEFI-only live image (both forms).** Pure-UEFI GPT: GPT + `efi` ESP (`loader.efi`) + UFS root (content UNCHANGED), NO BIOS bits. Produce USB `.img` + UEFI ISO. SHA + honest staging-model provenance. → `OP217_UEFI_IMAGE`

**D2 — ABI-matched de-spam mach.ko.** Content-verify op-215 `ffc67eda` vs id-015's kernel; rebuild against id-015's kernel source if it diverges; the module in the shipped image is the gated (`ipc_entry_lookup_failed_log` default-0) one, ABI-correct for the booted kernel. → `OP217_MACHKO_ABI`

**D3 — handoff + disposition.** `built` (image + ABI-matched module ready, SHAs recorded, staged in wip-gpt's owned dir) | `walled` (scheme repackage or mach.ko ABI blocks — REPORT). Hand the image + module to **op-218 (Gatekeeper)** for the independent edk2 boot proof. → `OP217_VERDICT` / `OP217_TERMINAL`

## BOUNDARIES
- **UFS root UNCHANGED** — scheme/boot-path change only; do NOT touch root FS type or staged content. NOT the ZFS-root change (id-012).
- **Do NOT self-certify boot-green** — the edk2 firmware boot proof is op-218 (Gatekeeper, independent). This op produces artifacts + hands off; it does not stamp uefi-green. (soak/boot oracle independence — the bhyveload false-green is the exact risk.)
- **mach.ko identity by CONTENT** (artifact_identity_needs_content_check) — never adopt the op-215 module on filename/size; ABI-verify or rebuild.
- **No buildworld** — repackage the staged tree; the only compile here is the standalone `mach.ko` module if a rebuild is needed (mach_ko_standalone_module; hermetic env, scrub `/usr/local` env leak). Stage in wip-gpt's OWN dir (agent_host_isolation).

## MARKERS
```
OP217_UEFI_IMAGE  # pure-UEFI GPT live image (GPT+efi ESP+UFS, no BIOS); UFS root unchanged; USB .img + UEFI ISO; SHA + honest provenance
OP217_MACHKO_ABI  # op-215 gated mach.ko content-verified/rebuilt ABI-matched to id-015 MACHDEBUGDEBUG kernel; gate default-0
OP217_VERDICT     # built | walled
OP217_TERMINAL
```

## RELATIONS
- DOWNSTREAM: **op-218 (Gatekeeper, free)** — consumes this image + module for the independent edk2-firmware boot proof (op-104 oracle). This op produces; op-218 certifies.
- UPSTREAM: id-015 / op-128 (proved boot via bhyveload — the bypass this closes), op-215 (the gated `mach.ko` de-spam, sha `ffc67eda`, ADOPTION PENDING — this op makes it ABI-correct for id-015's kernel), op-104 (the BLOCK078 oracle op-218 reuses).
- PARALLEL: dispatch NOW alongside the running op-165 soak (different EXU; free Implementer, cost-30 — implementer_cost_vs_walltime: don't wait out the busy Gatekeeper to dodge the cost).
- feedback: build_is_implementer (artifact production = Implementer), implementer_cost_vs_walltime (use the free Implementer in parallel; cost-30 ≠ reason to wait), artifact_identity_needs_content_check (mach.ko ABI by content), agent_host_isolation (wip-gpt own dir), mach_ko_standalone_module (rebuild path), userland_port_no_buildinfra_changes (mkimg arg over base-script edit; diff vs stock). project: 64bit_only_no_lib32 (UEFI-only/no-BIOS), 10preview_gate, id-015 staging model.
