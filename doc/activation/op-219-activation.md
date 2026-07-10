# op-219 — Implementer: fix the `mach_msg_overwrite_trap` narg=9 panic — define `CONFIG_REQUIRES_U32_MUNGING` for the mach build so the trap arg structs use proper LP64 slotting (narg≤8) → rebuild mach.ko → re-stage into the op-217 UEFI image → hand to op-220 for the re-boot oracle

op-219 | role: **Implementer** (cost-30) | EXU: **wip-gpt** | state: **[Done — WALLED; root cause CORRECTED, Arranger-verified first-hand 2026-06-30].** The munging define is a proven **no-op** for the registered arg count, and my op-218/op-219 mechanism was WRONG. PROOF (Implementer first-hand, Arranger re-verified): `mach_module.c:35` includes `<sys/sysproto.h>` — `SYSCALL_INIT_HELPER`'s `sizeof(struct mach_msg_overwrite_trap_args)` resolves to the **generated `sysproto.h`** struct, NOT the hand-written `mach_traps.h`/`PAD_ARG_8` one I diagnosed. `CONFIG_REQUIRES_U32_MUNGING` only gates mach_traps.h, so it changes nothing: the rebuilt mach_module.o is **byte-identical** (`e0eed686…`) to op-166's, both `sy_narg=8`. The narg-probe is invariant to the flag (current 64/8 with AND without; f712 72/9 with AND without). **NOT a latent tree-wide defect** (op-218 overclaim retracted): current canonical = narg **8**, op-166 `9c7706a3` = narg **8**; **only the op-217 `f712` build snapshot = narg 9** (its *generated* sysproto.h carries a 9th register slot vs canonical's corrected 8-field struct). Real root cause = op-217 was built from a **stale/divergent f712 snapshot**, not a source-macro gap. The committed flag `483073c69646` ("mach: enable LP64 syscall arg munging") is a no-op whose message overclaims → revert under the corrected op. FIX → **op-221** (rebuild the id-015 UEFI image from CANONICAL lineage — same-lineage kernel+mach.ko, narg=8 — abandoning f712; NOT a cross-lineage module swap). | parent id: id-015 | L1i: li-006 (image/boot logistics) | cost: 30 | authored 2026-06-30 (Arranger seat, model Opus 4)

## WHY (one line)

op-218 PROVED the UEFI boot chain (firmware→ESP→`loader.efi`→kernel→multi-user — the mission), but the op-104 oracle then panicked: `Too many syscall arguments! syscall (632, mach_msg_overwrite_trap)`. Arranger root-caused first-hand (NOT the Gatekeeper's "sy_narg too low" — that is BACKWARDS): `CONFIG_REQUIRES_U32_MUNGING` is referenced once at `sys/sys/mach/mach_traps.h:323` and **never defined** in the tree → `#if` false → `PAD_ARG_8` expands to a real field (`char arg8_pad_[4]`, `:330`) → `struct mach_msg_overwrite_trap_args` rounds to **9 register slots** → `SYSCALL_INIT_HELPER` (`mach_module.c:225`) sets `sy_narg=9` → amd64 `trap.c:1113/1152 KASSERT(sy_narg <= nitems(args)=8)` panics under INVARIANTS (the MACHDEBUGDEBUG kernel). `-Wno-error=undef` (`sys/modules/mach/Makefile:31`) hid the undefined-macro warning. This is a **latent tree-wide ABI defect** (every mach.ko from this tree computes narg=9; prior boots survived only because their workload never called `mach_msg_overwrite_trap` directly and/or ran a non-INVARIANTS kernel). Defining the macro is the XNU-faithful fix — it is the "this kernel uses 64-bit arg layout" switch and ALSO corrects per-arg padding to proper 8-byte LP64 slots (the undefined/uint32 path mis-slots every mach trap arg on LP64).

## SCOPE / SUBJECT (config-define + standalone mach.ko rebuild + image re-stage; NO buildworld)

- **The fix site is rmxOS-OWNED port code** (`sys/compat/mach` + `sys/sys/mach`), NOT FreeBSD base build-infra — so this is in-scope, not a `userland_port_no_buildinfra_changes` violation. Do NOT edit FB15 base `share/mk`/Makefile.inc1/toolchain.
- **Define `CONFIG_REQUIRES_U32_MUNGING`** so `#if CONFIG_REQUIRES_U32_MUNGING` (mach_traps.h:323) is TRUE → `PAD_ARG_8` empty + `PAD_(t)` uses the uint64 base → all mach trap arg structs slot at 8-byte LP64 boundaries. Preferred: `-DCONFIG_REQUIRES_U32_MUNGING=1` in `sys/modules/mach/Makefile` CFLAGS (mirrors the existing `-DCOMPAT_MACH` at :30), OR a shared opt/config header included by both the module and any in-kernel mach consumer. Confirm by content that `PAD_ARG_8` now empties and the three users (overwrite @389, +608, +724) drop to ≤8 slots.
- **Do NOT "fix" by removing the KASSERT or shipping a non-INVARIANTS kernel** — that MASKS the defect (the latent over-read / mis-slotting stays). Keep MACHDEBUGDEBUG; the fix must make the assertion pass LEGITIMATELY (narg=8, correctly-slotted args).
- **Rebuild mach.ko standalone** (`mach_ko_standalone_module`: `make -C sys/modules/mach`, MAKEOBJDIRPREFIX only, NO KERNBUILDDIR; **hermetic env — scrub the `/usr/local` `C_INCLUDE_PATH`/`LIBRARY_PATH` leak**, the op-176 wall). Stage in wip-gpt's OWN dir (`agent_host_isolation`).

## DELIVERABLES

**D1 — munging config defined + narg proof.** `CONFIG_REQUIRES_U32_MUNGING` defined for the mach build; rebuilt mach.ko's `mach_msg_overwrite_trap` sysent has **`sy_narg == 8`** — proven BY CONTENT (recompute `sizeof(struct mach_msg_overwrite_trap_args)/sizeof(register_t)`, or `readelf`/disasm the registered sysent, or a compile-time `_Static_assert`), NOT by filename. → `OP219_MUNGING_FIX` / `OP219_MACHKO_NARG8`

**D2 — re-staged UEFI image.** Swap ONLY `/boot/modules/mach.ko` in the op-217 image with the narg=8 rebuild (the op-217 `cp`-stage precedent — kernel + UFS root otherwise UNCHANGED, MACHDEBUGDEBUG kept). Produce the re-staged USB `.img` (+ UEFI ISO if cheap). SHA both. Confirm the in-image module is the narg=8 one by content. → `OP219_IMAGE_RESTAGE`

**D3 — blast-radius note + disposition.** Confirm by content whether a prior preview image's mach.ko (e.g. op-166 `9c7706a3`) ALSO computes narg=9 (→ latent tree-wide, as the source predicts) and state which workloads/kernels are at risk (only direct `mach_msg_overwrite_trap` callers on INVARIANTS — flag if any preview soak path qualifies). `fixed` (narg=8 module re-staged, SHAs recorded) | `walled` (build/define blocks — REPORT). Hand the re-staged image + module to **op-220 (Gatekeeper)** for the edk2 re-boot oracle. → `OP219_VERDICT` / `OP219_TERMINAL`

## BOUNDARIES
- Minimal, donor-faithful fix = DEFINE the macro (XNU's own switch); do NOT hack PAD_ARG_8 locally, remove the KASSERT, or drop INVARIANTS (those mask, not fix).
- mach.ko identity BY CONTENT (`artifact_identity_needs_content_check`) — narg proof + in-image module hash, never filename/size.
- Hermetic build (scrub `/usr/local` env leak, op-176). NO buildworld — standalone module + image re-stage only.
- Stage in wip-gpt's OWN dir (`agent_host_isolation`). Kernel + UFS root UNCHANGED.

## MARKERS
```
OP219_MUNGING_FIX    # CONFIG_REQUIRES_U32_MUNGING defined for the mach build; PAD_ARG_8 now empty
OP219_MACHKO_NARG8   # rebuilt mach.ko: mach_msg_overwrite_trap sy_narg==8, proven by CONTENT (sizeof/readelf/static-assert)
OP219_IMAGE_RESTAGE  # op-217 image with /boot/modules/mach.ko swapped to the narg=8 build; kernel+UFS unchanged; SHA
OP219_VERDICT        # fixed | walled
OP219_TERMINAL
```

## RELATIONS
- UPSTREAM: **op-218** (the edk2 boot that surfaced the panic + proved the UEFI chain), op-217 (the UEFI image to re-stage), op-104 (the BLOCK078 oracle op-220 re-runs).
- DOWNSTREAM: **op-220 (Gatekeeper, free)** — re-boots the op-219 image via edk2 firmware, drives the op-104 oracle to completion (the run op-218 couldn't finish) + the op-215 de-spam confirmation that was inconclusive. [Awaiting], gated on op-219 `fixed`.
- feedback: verify-premise-before-mechanism (the "sy_narg too low" → "narg=9 too high" correction; mechanism root-caused at source before authoring the fix), build_is_implementer (config-define + rebuild + image = Implementer), mach_ko_standalone_module (the rebuild path), artifact_identity_needs_content_check (narg by content), agent_host_isolation, userland_port_no_buildinfra_changes (fix is in rmxOS-owned `sys/compat/mach`, NOT FB15 base — in-scope). project: 64bit_only_no_lib32 (the munging/LP64 arg-slotting interplay — the 64-bit-only posture is exactly where the undefined munging config bites), id-015 staging model, li-1012 clean-provenance.
```
