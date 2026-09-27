---
id: op-208
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-208 — Implementer: produce a UEFI-bootable USB smoke image from the certified v3 preview image (op149-preview-uefi-v3 / 707936a6) + OVMF pre-flight → de-risk the Rocket Lake metal-boot axis before the dogfood preview

op-208 | role: **Implementer** (cost-30) | EXU: **wip-gpt** | state: **[Done — smoke-image-ready, Arranger-verified first-hand @ no-source-edit]** — USB `op208-rocketlake-live-usb.img` (sha 102149a2…, 16G) staged; OVMF/EDK2 preflight reached root login over serial + clean shutdown (serial log verified first-hand: BdsDxe→BOOTX64.EFI→kernel `op-171-x86-64-v3-alpha…c14e0904` → ufs root → `login: root`); bring-up checklist delivered. Caveats: USB is certified bits with ONE overlay edit (rc.local auto-shutdown disabled, preserved in-image) → sha≠707936a6 by design; OVMF CPU was a Broadwell Xeon (soak-host VM) NOT Rocket Lake — OVMF predicts, the user confirms on metal. asld SIGSEGV NOT hit (line 161 `Starting syslogd` — asld dormant/unwired, matches op-207/op-210). **Hand-off: the user dd's the image + boots the Rocket Lake box; a confirmed physical boot is the remaining gate for op-209.** The "Build-1 hardware-smoke" — produces a burn-ready USB from the ALREADY-CERTIFIED v3 image + OVMF-preflights it, so the user can boot it on the Rocket Lake workstation. Independent of the dogfood gates (op-185 / op-198 v5 / a fixed-binary rebuild) — this de-risks the orthogonal HARDWARE axis in parallel. | parent id: id-026 (x86-64-v3 baseline) + preview hardware bring-up | L1i: 10preview_gate | cost: 30 | authored 2026-06-29 (Arranger seat, model Opus 4)

## WHY (one line)

Every cert/soak to date is VM-only (bhyve). Real Rocket Lake metal introduces a whole untouched risk axis — UEFI firmware handoff, NVMe, GPU/efifb console, USB HID, NIC link. Before the dogfood USB (Build-2, gated on op-185 + op-198 v5 + an op-204/206/207 rebuild), cut a hardware-smoke USB from the CERTIFIED v3 image to answer ONE question: **does the v3 userland+kernel boot on the user's Rocket Lake workstation?** Minimize variables — use the certified bits, not a fresh build.

## SCOPE / SUBJECT

- **Source artifact (USE THIS — do NOT rebuild):** `/Users/me/wip-mach/vm/runs/op149-preview-uefi-v3.img` (the op-149 v3 UEFI preview image, **707936a6 lineage** — boots in VM per op-149, op-168 4h adopt-soak clean, op-182 v3 cert). Confirm its sha first-hand before staging (artifact_identity_needs_content_check). A fresh build-from-HEAD would add a SECOND variable to a hardware test — that's Build-2/dogfood, a separate op.
- **Target:** the user's Rocket Lake workstation = Intel 11th-gen, comfortably x86-64-v3 (AVX2/BMI2/FMA) + UEFI-class firmware. The v3 baseline is SAFE on this target — the "5 ymm leaked / kernel not fully vector-free" caveat is about OLDER hardware, moot here. 64-bit-only + UEFI-only (project_64bit_only_no_lib32) → the smoke IS the UEFI boot test.
- **LIVE-boot smoke, NOT an install.** Boot the certified image live off USB; do NOT script the case-insensitive-OpenZFS `/Users` disk install (a separate later step, only after the box is known to boot).

## DELIVERABLES

**D1 — burn-ready USB image.** Produce a dd-able raw USB image (or confirm the certified disk image is directly dd-able to a USB stick and UEFI-boots as a live disk). Verify the UEFI boot chain present + correct: GPT, EFI System Partition, `loader.efi`. Stage in the wip-gpt owned dir + sha. → `OP208_USB_IMAGE`

**D2 — OVMF/UEFI pre-flight (the real de-risk).** Boot the USB image under **OVMF** (EDK2 UEFI firmware — the same firmware family as real hardware, a far better metal predictor than bhyve's bootrom). Prove first-hand it reaches multi-user / a login prompt over serial, root mounts, no UEFI-handoff wall. Capture serial. Don't make the user the first to discover it won't UEFI-boot. → `OP208_OVMF_PREFLIGHT`

**D3 — hardware bring-up checklist + hand-off to the user.** A concise checklist for the PHYSICAL Rocket Lake boot (the op does NOT need physical hardware — this is a hand-off): what to watch at each stage — UEFI device-path handoff → `loader.efi` → kernel → efifb/console → NVMe root mount → USB keyboard → NIC link; how to capture (serial header if the board has one, else screen photo); the caveats (LIVE boot only / no disk install yet; asld unwired so no asl crash; v3 safe on this CPU). → `OP208_BRINGUP_CHECKLIST` / `OP208_VERDICT` (`smoke-image-ready` | `walled`) / `OP208_TERMINAL`

**VERDICT:** `smoke-image-ready` (USB image staged + OVMF-preflight-boots-to-login + checklist delivered → user can burn + boot the Rocket Lake box) | `walled` (the certified image won't produce a UEFI-bootable USB / won't OVMF-boot — REPORT the blocker, don't improvise a rebuild).

## BOUNDARIES
- **Use the CERTIFIED image (707936a6) — do NOT rebuild from HEAD.** That's Build-2/dogfood (a separate op carrying the op-204/206/207 fixes); mixing a fresh build into a hardware smoke confounds two variables. The current image's static asld is harmless (op-207 finding: unwired, FreeBSD syslogd is the live logger).
- LIVE-boot smoke, NOT an install — do NOT script the case-insensitive-ZFS `/Users` install (separate later step).
- Build/stage is Implementer (build_is_implementer); stage in wip-gpt owned dir (agent_host_isolation, NO host /tmp).
- The PHYSICAL boot is the USER's — deliver the image + checklist; do NOT claim a hardware result the op can't produce (no_conflate_gating_with_readiness: **OVMF-boots ≠ metal-boots** — it's a predictor; the user confirms on the box). Verify first-hand the OVMF boot REACHES login (not just "qemu/OVMF started") — background_exit_code_hygiene.

## MARKERS
```
OP208_USB_IMAGE          # dd-able UEFI-bootable USB image from op149-preview-uefi-v3 (707936a6) — GPT+ESP+loader.efi verified, staged+sha
OP208_OVMF_PREFLIGHT     # boots under OVMF/UEFI to multi-user/login over serial, root mounts — first-hand, serial captured
OP208_BRINGUP_CHECKLIST  # per-stage hardware bring-up checklist + caveats, handed to the user for the physical Rocket Lake boot
OP208_VERDICT            # smoke-image-ready | walled
OP208_TERMINAL
```

## RELATIONS
- UPSTREAM: op-149 (image 707936a6 boots in VM), op-168 (4h adopt-soak clean), op-182 (v3 cert). project_preview_platform_bets (v3 baseline carried to cert), id-026.
- DOWNSTREAM: de-risks the metal axis for the dogfood **Build-2 USB** (gated on op-185 integration-green + op-198 v5 asl reclaim + a rebuild carrying op-204/206/207). A clean metal smoke = hardware bring-up proven; a `walled` smoke = a hardware/driver finding to fix BEFORE any dogfood. NOTE: 707936a6 carries the old static asld but it's UNWIRED (op-207) → the smoke won't hit the asld SIGSEGV.
- feedback: build_is_implementer, artifact_identity_needs_content_check (confirm the 707936a6 sha first), agent_host_isolation, no_conflate_gating_with_readiness (OVMF≠metal), background_exit_code_hygiene (OVMF reaches login, not just "started"). project: 10preview_gate, project_preview_platform_bets, project_64bit_only_no_lib32 (UEFI-only — the smoke is the UEFI boot test).
```
