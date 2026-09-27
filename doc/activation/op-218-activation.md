---
id: op-218
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-218 — Gatekeeper: independent edk2-firmware boot proof of op-217's UEFI-only id-015 image — boot via the edk2 bootrom in bhyve (NOT bhyveload, the bypass that hid the firmware path), confirm op-104 oracle green + op-215 de-spam, verdict uefi-green

op-218 | role: **Gatekeeper** (cost-0) | EXU: **rmx-gatekeeper-rx-x64z** | state: **[Done — UEFI-BOOT-CHAIN-GREEN / oracle BLOCKED by a NEW kernel panic; Arranger root-caused first-hand 2026-06-30, commit `992da36`].** D1 PARTIAL-GREEN: the **UEFI boot chain is PROVEN** — edk2 firmware → ESP → `loader.efi` → kernel → multi-user start (the panic fires during BLOCK078 RUNTIME, i.e. post-multi-user, which itself proves the full chain; `efirtc0: <EFI Realtime Clock>` is UEFI-only evidence absent under bhyveload). The mission (validate the real UEFI firmware path, kill the bhyveload false-green) is ACCOMPLISHED. BUT op-104 oracle did NOT complete: kernel `panic: Too many syscall arguments! syscall (632, mach_msg_overwrite_trap)`. **MECHANISM CORRECTED (Gatekeeper said "sy_narg too LOW" — BACKWARDS):** it is narg **too HIGH (9 > amd64's 8-slot `args[]` ceiling)**. ROOT CAUSE verified first-hand in canonical tree: `CONFIG_REQUIRES_U32_MUNGING` is referenced ONLY at `sys/sys/mach/mach_traps.h:323` and **never defined** → `#if` false → `PAD_ARG_8` = `char arg8_pad_[4]` (`:330`) → `struct mach_msg_overwrite_trap_args` rounds to 9 register slots → `SYSCALL_INIT_HELPER` derives `sy_narg=9` → amd64 `trap.c:1113/1152 KASSERT(sy_narg <= nitems(args)=8)` panics under INVARIANTS (the MACHDEBUGDEBUG debug kernel). `-Wno-error=undef` (`sys/modules/mach/Makefile:31`) masked the undefined-macro warning. NOT a UEFI issue. **[CORRECTED 2026-06-30 by op-219, Arranger re-verified:** this "latent tree-wide ABI defect / narg=9 from undefined CONFIG_REQUIRES_U32_MUNGING" mechanism was WRONG. The registered struct comes from generated `sysproto.h` (`mach_module.c:35`), not `mach_traps.h`; the munging flag is a no-op. Current canonical + op-166 `9c7706a3` are both narg **8** — **only the op-217 `f712` build snapshot is narg 9** (stale generated sysproto.h). Real cause = op-217 built from a divergent/stale snapshot. Fix re-vectored op-219(walled)→**op-221** (rebuild image from canonical lineage).]** D2 de-spam: genuinely INCONCLUSIVE (panic preempts the flood — 0 `ipc_entry_lookup` lines, but can't distinguish gate-works from panic-prevented-flood) — ACCEPTED. D3: real-HW Rocket Lake smoke STILL OWED (after the kernel fix). FIX → op-219 (Implementer): define `CONFIG_REQUIRES_U32_MUNGING` for the mach build → narg=8 → rebuild mach.ko → re-stage → op-220 (Gatekeeper) re-boots. | parent id: id-015 | L1i: li-006 (image/boot logistics) | cost: 0 | authored 2026-06-29 (Arranger seat, model Opus 4)

## WHY (one line)

op-217 (Implementer) builds the pure-UEFI GPT live image + ABI-matched de-spam `mach.ko`, but the **builder must not certify its own boot-green** — and here independence is load-bearing: every id-015 boot to date went through **`bhyveload`** (`run-guest.sh:57`), which bypasses the ESP/`loader.efi`/firmware chain, so a self-certified "boots fine" is the exact false-green this effort exists to kill. This op independently boots op-217's image through **real edk2 UEFI firmware** in bhyve — the faithful proxy for the user's UEFI-exclusive Rocket Lake hardware — and gates uefi-green on the op-104 oracle.

## SCOPE / SUBJECT (Gatekeeper boot oracle — consume op-217's artifacts, do NOT rebuild)

- **Input:** op-217's UEFI-only image (USB `.img` + UEFI ISO) + the ABI-matched gated `mach.ko`, by handoff (verify the received SHAs match op-217's recorded ones).
- **The boot MUST use real UEFI firmware:** `bhyve -l bootrom,<path>/BHYVE_UEFI.fd …` (sysutils/bhyve-firmware) — so firmware → ESP → `loader.efi` → kernel is actually exercised. **`bhyveload` is BANNED** — it is the bypass that hid the gap; a bhyveload pass is NOT evidence. run-guest.sh is wip-gpt-owned + bhyveload-shaped — do NOT cross-edit; write the edk2 bhyve invocation in the Gatekeeper's OWN dir (agent_host_isolation).
- **Oracle:** reuse the op-104 BLOCK078 boot oracle (`BLOCK078_NOTIFYD_ROUNDTRIP status=0`, 0 panic/fatal, clean shutdown) — booted to launchd multi-user through the firmware path.

## DELIVERABLES

**D1 — edk2-firmware boot proof (the validation that has never happened).** Boot op-217's memstick via `-l bootrom,…BHYVE_UEFI.fd` (NOT bhyveload) → confirm firmware → ESP → `loader.efi` → kernel → launchd multi-user, op-104 oracle green. Smoke the UEFI ISO boots via the same edk2 path. → `OP218_EDK2_BOOT`

**D2 — de-spam confirmed on the booted image.** Confirm the op-215 gated `mach.ko` actually silenced the `ipc_entry_lookup failed on 0` boot flood (boot-time line-rate ~0, vs the prior persistent spam id-015 noted). → `OP218_DESPAM_OK`

**D3 — disposition + real-HW note.** `uefi-green` (edk2-firmware boot + op-104 oracle green + de-spam confirmed) | `walled` (ESP/`loader.efi` chain fails — REPORT the exact failure point, do not fall back to bhyveload). State explicitly whether a **real-hardware Rocket Lake UEFI smoke is still owed** (bhyve+edk2 is a strong proxy, not literal silicon). → `OP218_VERDICT` / `OP218_TERMINAL`

## BOUNDARIES
- **edk2 firmware boot MANDATORY; bhyveload BANNED** — a bhyveload "green" is the false-green this op exists to prevent. If `BHYVE_UEFI.fd` is absent, that's a setup prerequisite — report it, do not fall back.
- **Consume, don't rebuild** — boot op-217's handed-over artifacts; verify received SHAs. No image/module construction here (that's op-217, Implementer).
- **Independent of the builder** — this is the whole point; the Gatekeeper, not wip-gpt, certifies uefi-green.
- Stage in the Gatekeeper's OWN dir (agent_host_isolation); do not edit wip-gpt's run-guest.sh.

## MARKERS
```
OP218_EDK2_BOOT   # boots via edk2 bootrom (firmware→ESP→loader.efi→kernel), NOT bhyveload; op-104 oracle green (BLOCK078), 0 panic, clean shutdown; ISO smoke too
OP218_DESPAM_OK   # op-215 gated mach.ko silenced the ipc_entry_lookup-failed-on-0 boot flood (line-rate ~0)
OP218_VERDICT     # uefi-green | walled
OP218_TERMINAL
```

## RELATIONS
- UPSTREAM: **op-217 (Implementer)** — produces the UEFI image + ABI-matched mach.ko this op boots; op-104 (the BLOCK078 oracle reused), op-215 (the de-spam module verified live here), id-015 / op-128 (proved boot via bhyveload — the bypass this independently closes).
- DOWNSTREAM: a `uefi-green` verdict makes id-015 the form that boots the user's UEFI-exclusive Rocket Lake box; aligns with the 64-bit-only + UEFI-only / no-BIOS project decision. Real-hardware smoke (if D3 flags it owed) is the final step before dogfooding on the box.
- HOST: needs the Gatekeeper free — gated behind the running op-165 soak; takes the host after op-165 adjudicates (parallel-authored with op-217, which runs NOW on the free Implementer).
- feedback: soak/boot-oracle independence (never Implementer proving own artifact — the false-green risk is concrete here), verify-premise-before-mechanism (bhyveload bypass found first-hand at run-guest.sh:57), agent_host_isolation, build_is_implementer (op-218 consumes, doesn't build). project: 64bit_only_no_lib32, 10preview_gate, id-015 staging model.
