# op-220 — Gatekeeper: re-boot op-219's narg=8 re-staged UEFI image via edk2 firmware, drive the op-104 oracle to the completion op-218 couldn't finish, confirm op-215 de-spam, verdict uefi-green

op-220 | role: **Gatekeeper** (cost-0) | EXU: **rmx-gatekeeper-rx-x64z** | state: **[Done — UEFI-GREEN 2026-06-30, commit 3b43f9d, Arranger-confirmed first-hand].** Genuine edk2 (BdsDxe / FreeBSD EFI loader / EFI Firmware BHYVE rev 1.00 / \EFI\BOOT\BOOTX64.EFI / efirtc0 — NOT the bhyveload userboot path op-222 used, so the false-green is genuinely avoided). D1: panic GONE (0 `panic`/`Too many syscall arguments` — op-221 narg=8 mach.ko ffc67eda holds at runtime), 18 libs status=0, BLOCK078_NOTIFYD_ROUNDTRIP status=0 via the launchd-child bootstrap path (PATH 2: bootstrap_look_up kr=0, register rc=0, post rc=0, check rc=0 check=1; PATH 1 shell-context rc=1000000 is the expected op-127 limitation), BLOCK078_TERMINAL status=0. D2: 0 ipc_entry_lookup — definitive de-spam (op-218 couldn't measure past the panic). D3: uefi-green. REAL-HW Rocket Lake UEFI smoke STILL OWED (bhyve+edk2 is a strong proxy, not literal silicon) — the final step before dogfooding. (was: [Awaiting — gate CLEARED 2026-06-30: op-221 FIXED + Arranger-verified]) Boot op-221's canonical-lineage UEFI image: USB `106a373c…` / ISO `218554692b…`; in-image kernel `c526a91d` (op-182 clean-cert MACHDEBUGDEBUG), mach.ko `ffc67eda` (canonical narg=8 + op-215 de-spam gate — so D2 de-spam is on the SAME module, no separate fold-in). **Sequenced AFTER op-198 v6 soak** (preview-first holds the host overnight); op-220 takes the host after. At boot, CONFIRM the banner shows the INVARIANTS MACHDEBUGDEBUG kernel loaded (loader.conf has stale TWQDEBUG/MACHDEBUG `kernel=` blocks above it — last-wins should pick MACHDEBUGDEBUG, verify don't assume). | parent id: id-015 | L1i: li-006 (image/boot logistics) | cost: 0 | authored 2026-06-30 (Arranger seat, model Opus 4)

## WHY (one line)

op-218 PROVED the UEFI boot chain (firmware→ESP→`loader.efi`→kernel→multi-user) but the op-104 oracle then panicked: `Too many syscall arguments! (632, mach_msg_overwrite_trap)` — `mach_msg_overwrite_trap_args` computed to **9** register slots (`CONFIG_REQUIRES_U32_MUNGING` undefined → `PAD_ARG_8` real). op-219 defines the macro → narg=**8** → re-staged image (only `/boot/modules/mach.ko` swapped, kernel+UFS unchanged, MACHDEBUGDEBUG kept). This op re-boots THAT image through real edk2 firmware and drives the oracle to the completion op-218 couldn't reach — the builder must not certify its own re-boot.

## SCOPE / SUBJECT (Gatekeeper re-boot oracle — consume op-219's artifacts, do NOT rebuild)

- **Input:** op-219's re-staged UEFI image (USB `.img` + UEFI ISO if produced) + the narg=8 `mach.ko`, by handoff — verify received SHAs match op-219's recorded ones, and confirm by content the in-image module is the narg=8 build (`artifact_identity_needs_content_check`).
- **Boot MUST use real UEFI firmware:** `bhyve -l bootrom,<path>/BHYVE_UEFI.fd …` — **`bhyveload` BANNED** (the bypass op-218 exists to kill). Write the edk2 invocation in the Gatekeeper's OWN dir (`agent_host_isolation`); do NOT cross-edit wip-gpt's run-guest.sh.
- **Oracle:** the op-104 BLOCK078 boot oracle, re-run to the completion op-218 was preempted from.

## DELIVERABLES

**D1 — edk2 boot, oracle GREEN past the panic.** Boot op-219's image via `-l bootrom,…BHYVE_UEFI.fd` → confirm `mach_msg_overwrite_trap` no longer panics (the narg=8 fix holds at runtime), `BLOCK078_NOTIFYD_ROUNDTRIP status=0`, 0 panic/fatal, clean shutdown. ISO smoke too if cheap. → `OP220_ORACLE_GREEN`

**D2 — de-spam confirmed (the conclusive run op-218 couldn't get).** With the panic gone, the boot flood is no longer preempted — confirm the op-215 gated `mach.ko` actually silenced `ipc_entry_lookup failed on 0` (boot-time line-rate ~0). This closes op-218's INCONCLUSIVE D2. → `OP220_DESPAM_OK`

**D3 — disposition + real-HW note.** `uefi-green` (edk2 boot + op-104 oracle green + de-spam confirmed) | `walled` (REPORT exact failure point; do NOT fall back to bhyveload). State explicitly that a **real-hardware Rocket Lake UEFI smoke is still owed** (bhyve+edk2 is a strong proxy, not literal silicon) — the final step before dogfooding. → `OP220_VERDICT` / `OP220_TERMINAL`

## BOUNDARIES
- **edk2 firmware MANDATORY; bhyveload BANNED** — a bhyveload "green" is the false-green this chain exists to prevent.
- **Consume, don't rebuild** — boot op-219's handed-over artifacts; verify received SHAs + in-image module by content. No image/module construction (that's op-219, Implementer).
- **Independent of the builder** — the Gatekeeper, not wip-gpt, certifies uefi-green.
- Stage in the Gatekeeper's OWN dir (`agent_host_isolation`).

## MARKERS
```
OP220_ORACLE_GREEN  # edk2 boot, mach_msg_overwrite_trap no longer panics (narg=8 holds), BLOCK078 status=0, 0 panic, clean shutdown; ISO smoke too
OP220_DESPAM_OK     # op-215 gated mach.ko silenced ipc_entry_lookup-failed-on-0 (line-rate ~0) — closes op-218's inconclusive D2
OP220_VERDICT       # uefi-green | walled
OP220_TERMINAL
```

## RELATIONS
- UPSTREAM: **op-219 (Implementer)** — produces the narg=8 re-staged image this op boots; op-218 (proved the UEFI chain + surfaced the panic), op-217 (the base UEFI image), op-104 (the BLOCK078 oracle re-run), op-215 (the de-spam module re-confirmed live).
- DOWNSTREAM: a `uefi-green` verdict makes id-015 the form that boots the user's UEFI-exclusive Rocket Lake box (64-bit-only + UEFI-only / no-BIOS). Real-hardware Rocket Lake smoke (D3 flags it owed) is the final step before dogfooding.
- HOST: needs the Gatekeeper free; gated on op-219 reporting `fixed`.
- feedback: soak/boot-oracle independence (never builder proving own artifact), verify-premise-before-mechanism (oracle green proven from BLOCK078 status + absence of the narg panic, not inferred), agent_host_isolation, build_is_implementer (op-220 consumes, doesn't build), artifact_identity_needs_content_check (in-image module narg=8 by content). project: 64bit_only_no_lib32, id-015 staging model, li-1012 clean-provenance.
