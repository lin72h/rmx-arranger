# op-209 — Implementer: FreeBSD-release bsdinstall memstick installer (stock TUI → NVMe install on Rocket Lake) for the dogfood preview — HELD, gated on op-208 smoke + the dogfood service gates

op-209 | role: **Implementer** (cost-30) | EXU: **wip-gpt** | state: **[Held — POST-SMOKE / dogfood Build-2]** — gated on (1) op-208 `smoke-image-ready` + a CONFIRMED physical Rocket Lake boot (the hardware axis proven before we invest in an installer), AND (2) the dogfood service gates: op-185 `integration-green` + op-198 v5 asl reclaim + a rebuild carrying op-204/206/207. This is the REAL bsdinstall installer the user asked for (dd → default TUI → install to NVMe), distinct from op-208's live smoke. | parent id: id-026 (v3 baseline) + preview dogfood install | L1i: 10preview_gate | cost: 30 | authored 2026-06-29 (Arranger seat, model Opus 4)

## WHY (one line)

op-208 answers "does the v3 image boot on the Rocket Lake metal." Once that's YES, the user wants a standard FreeBSD memstick installer — dd to USB, boot, use the stock **bsdinstall** TUI to install rmxOS onto the workstation's NVMe for persistent dogfooding. The release machinery is present in the overlay (`release/Makefile`, `release/amd64/make-memstick.sh`, `mkisoimages.sh`, `usr.sbin/bsdinstall/`); this op builds + proves the installer path, which has NEVER been certified (op-128's memstick was a boot-smoke, not a bsdinstall-to-disk run).

## SCOPE / SUBJECT

- **Build from the DOGFOOD tree (HEAD carrying op-204/206/207 fixes)** — NOT the certified-707936a6 live image. This IS Build-2/dogfood, so it waits on the dogfood gates above. Record the build HEAD.
- Reuse FreeBSD's stock release path: `make release` / `distributeworld` → rmxOS dist sets (base.txz/kernel.txz) → `release/amd64/make-memstick.sh` → a dd-able `memstick.img` with the **stock bsdinstall TUI**. Do NOT hand-roll a custom installer — reuse the FreeBSD method (userland_port_no_buildinfra_changes: if `release` needs an overlay fix, diff vs stock first + REPORT, don't fork the framework).
- **ZFS layout = STOCK case-sensitive for first contact** (the default bsdinstall zfsboot layout). The phased case-insensitive OpenZFS `/Users` is a SEPARATE follow-on — NOT baked into this first installer (confirm at dispatch; this is the recorded default, flag if the Coordinator wants case-insensitive `/Users` from day one).

## DELIVERABLES

**D1 — rmxOS dist sets.** `make release`/`distributeworld` produces clean rmxOS base.txz/kernel.txz (the sets bsdinstall installs). Verify they unpack to a coherent rmxOS userland (Darwin overlay present, the op-204/206/207 fixed binaries included). → `OP209_DIST_SETS`

**D2 — memstick installer built.** `make-memstick.sh` → a dd-able `memstick.img` with the stock bsdinstall TUI. Verify the UEFI boot chain (GPT/ESP/loader.efi) + that it boots to the bsdinstall TUI. Stage + sha. → `OP209_MEMSTICK`

**D3 — full install-to-disk PROVEN in OVMF before any burn.** Under OVMF/UEFI, run bsdinstall against a virtual NVMe target: stock TUI → install rmxOS → reboot → the INSTALLED system boots to login off the virtual disk (not the installer). This certifies the install path end-to-end so the user isn't the first to run it. Capture serial. → `OP209_INSTALL_PROVEN` / `OP209_VERDICT` (`installer-ready` | `walled`) / `OP209_TERMINAL`

**VERDICT:** `installer-ready` (dist sets clean + memstick boots the TUI + a full OVMF bsdinstall-to-disk reboots to login → user can burn + install on Rocket Lake) | `walled` (release/distributeworld won't package rmxOS sets / bsdinstall won't install our userland / the installed system won't reboot — REPORT the blocker).

## BOUNDARIES
- Reuse the FreeBSD release/bsdinstall framework — NO fork, NO FB build-infra edits (diff vs stock + REPORT if `release` needs a fix). Build is Implementer; stage in wip-gpt owned dir (agent_host_isolation).
- STOCK case-sensitive ZFS for this first installer — the case-insensitive `/Users` is explicitly a phased follow-on, out of scope here.
- Verify the INSTALLED system reboots to login in OVMF (no_conflate_gating_with_readiness: "memstick boots the TUI" ≠ "the install works"; the install-to-disk + reboot is the real bar). OVMF-proves ≠ metal-proves — the user confirms on the box.

## MARKERS
```
OP209_DIST_SETS        # make release/distributeworld → clean rmxOS base.txz/kernel.txz (op-204/206/207 fixes included)
OP209_MEMSTICK         # make-memstick.sh → dd-able UEFI memstick with stock bsdinstall TUI; GPT/ESP/loader.efi verified, staged+sha
OP209_INSTALL_PROVEN   # OVMF: stock TUI installs rmxOS to a virtual NVMe → reboots → installed system reaches login (not the installer)
OP209_VERDICT          # installer-ready | walled
OP209_TERMINAL
```

## RELATIONS
- UPSTREAM: op-208 (the live smoke — proves the hardware boots before we build the installer); op-185 + op-198 v5 + op-204/206/207 (the dogfood service gates — this carries their fixes); op-128 (prior memstick = a boot-smoke, NOT a certified bsdinstall-to-disk — this op is the real installer).
- DOWNSTREAM: the persistent dogfood install on the Rocket Lake workstation (north star: dogfood rmxOS off FreeBSD 15). The case-insensitive `/Users` ZFS layout is a phased follow-on after a stock install is proven.
- feedback: build_is_implementer, userland_port_no_buildinfra_changes (reuse release, don't fork), artifact_identity_needs_content_check, no_conflate_gating_with_readiness (install-to-disk+reboot is the bar, not "TUI boots"; OVMF≠metal), agent_host_isolation, background_exit_code_hygiene. project: 10preview_gate, project_preview_platform_bets (v3 dogfood), project_64bit_only_no_lib32 (UEFI-only).
```
