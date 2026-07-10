# op-149 — Explorer: x86-64-v3 base buildworld/kernel tryout (li-1009 P1)

op-149 | role: **Implementer** (cost-30) | EXU: **wip-gpt** | state: **[Awaiting] — RE-SCOPED 2026-06-28: the v3 buildworld/kernel goal is FULFILLED + li-1012-CERTIFIED by op-182 (clobbered clean-obj from c14e0904: v3 world + MACHDEBUGDEBUG kernel + mach.ko, all rc=0). op-149 now = ASSEMBLE the 1.0-preview bootable UEFI x86-64-v3 image FROM op-182's certified artifacts. See CURRENT SCOPE banner. Released to wip-gpt.** | parent id: id-026 | L1i: li-1009 / li-1012 | authored 2026-06-25 (Fable), revived + re-pointed 2026-06-27, base-switch confirmed 2026-06-27, RE-SCOPED to image-assembly 2026-06-28

## >>> CURRENT SCOPE (2026-06-28, Arranger seat, model Opus 4) — this supersedes the buildworld history below <<<

**The build is DONE.** op-178 (buildworld), op-180 (buildkernel MACHDEBUGDEBUG), op-181 (mach.ko), and the
op-182 clobbered do-it-once cert all GREEN at HEAD `c14e0904`. op-182's certified artifact set lives at
`build/op182-li1012-clean-cert/obj/...` (v3 world per make.conf `CPUTYPE?=x86-64-v3` + `COPTFLAGS=-O2 -pipe` +
`WITHOUT_LIB32=yes`; kernel sha `c526a91d…`; mach.ko sha `30d23616…`). The wall-by-wall buildworld grind
recorded below is HISTORY — do NOT re-run it.

**op-149's remaining deliverable: a bootable 1.0-preview image, FULL-provenance from op-182's certified set.**
- **installworld the CERTIFIED v3 world** (op-182 obj prefix) + **installkernel KERNCONF=MACHDEBUGDEBUG** to a
  FRESH disk image — NOT staging a new kernel onto a warm-provenance base userland (that would reintroduce mixed
  provenance and void li-1012). The ENTIRE image (userland + kernel + mach.ko) must trace to `c14e0904`.
- **mach.ko → `/boot/modules/mach.ko`**; loader.conf `kernel="MACHDEBUGDEBUG"`,
  `module_path="/boot/kernel;/boot/modules;/boot/MACHDEBUGDEBUG"`, `mach_load="YES"` (auto-load at boot — match
  `stage-guest.sh:470-473`). Plus harness serial console (`boot_serial`, `comconsole`).
- **UEFI/GPT ONLY** — ESP + freebsd-ufs root, NO legacy i386 BIOS/MBR (64-bit-only + UEFI-only invariant; bhyve
  boots via bhyveload per run-guest.sh, real HW via UEFI loader.efi). No `stand/i386`.
- **Content-verify, never filename/size** (artifact_identity_needs_content_check): mount the image, readelf/sha
  the staged kernel + mach.ko against op-182's cert fingerprints; confirm a v3 userland binary (e.g. bin/sh).
- **Boot-smoke before handing to op-168**: bhyveload → multiuser; `kldstat` shows `mach`; no panic. Then op-168
  Gatekeeper soak on this image is clean-provenance (no re-confirm owed).

VERDICT (one of): `preview-image-staged` (image built, content-verified vs op-182 cert, boot-smoke + mach loaded
→ hand to op-168) | `assembly-walled` (a staging/boot wall → report it, do not patch around provenance).

---

BASE RE-POINT — CONFIRMED (Coordinator 2026-06-27; op-169 Arranger-verified): attempt-1 ground vanilla `freebsd-src-official-stable-15`
wall-by-wall (mtree → thrworkq → iconv) because it is a FreeBSD checkout incompletely retrofitted with rmxOS
staging (8 Darwin dirs, missing dispatch/private/xpc). The PROVEN rmxOS alpha source `wip-gpt/wip-rmxos`
@ `3c2dd7f` (op-156 merge tip; builds the alpha image) has ALL 11 Darwin dirs → the staging walls do not
exist there. **Re-point op-149's build root to `wip-gpt/wip-rmxos`** (already in the Implementer's owned dir →
host-isolation-correct): add the v3 make.conf to the proven tree, rebuild — the only changed variable is
`CPUTYPE?=x86-64-v3` + `COPTFLAGS=-O2 -pipe`, which is the clean v3 experiment. The mtree PRECONDITION below
and the iconv wall are MOOT under this base (do not carry them forward). NextBSD was explicitly REJECTED as the
base (donor lineage, missing pthread+private — would reintroduce walls).

REVIVAL (Coordinator 2026-06-27): the x86-64-v3 + `-O2 -pipe` baseline is back ON. Build is **Implementer
(wip-gpt)** — NOT an Explorer (the prior rx2 attempt failed: rx2 didn't know how to build the OS; deeper
cause = the unsynced tree below). Runs **overnight batch, in PARALLEL with op-163 soak** (different EXU /
host — the build does NOT touch the gatekeeper soak host). On PASS, the v3 image feeds **op-168** (Gatekeeper
long stability soak = the ADOPTION GATE): if op-168 holds, v3+`-O2 -pipe` becomes the 1.0-preview build
baseline (a deliberate selling point vs Linux distros — modern-CPU-tuned, no legacy ballast).

PRECONDITION RE-VERIFIED (Fable first-hand 2026-06-27): build tree HEAD `524d71df` STILL lacks the mtree
fixes — `grep -E 'pthread|apple' etc/mtree/BSD.include.dist` → ABSENT; op-115 SHA `12330136` NOT an ancestor.
The restore below is still step-zero; without it the build dies at the includes phase (exactly what killed
rx2's run, which it mislabeled a "race").

>>> SUPERSEDED by the CONFIRMED base switch (2026-06-27): the entire stable-15 PRECONDITION/TREE-SYNC grind
>>> below is MOOT — the build now runs against `wip-gpt/wip-rmxos` @ `3c2dd7f` (target tree + SHA verified
>>> first-hand at release: `git cat-file -t 3c2dd7f` = commit "alpha: merge op-156 id-025 wait-path fix",
>>> all 11 Darwin dirs present). Do the v3 make.conf add ONLY; ignore the mtree restore / iconv / thrworkq
>>> steps that follow (they were stable-15 retrofit debt, absent in the alpha base).
assignment rationale: RE-ASSIGNED 2026-06-26. Core work is a `buildworld`+`buildkernel` on a build path
that has never completed clean (cleared wall-by-wall id-014→018→020→022) — that is Implementer-by-nature,
not Explorer scouting. Originally went to Explorer rx2, who did not know how to build the OS and cargo-culted
~393 lines of Elixir around a 2-line make.conf. STANDING RULE: builds are Implementer-only; other agents
request a build and receive the built file. The v3 codegen/disasm inspection (steps 3-5) can be done by the
Implementer on its own build, or handed to an Explorer on the SHARED image — no separate build by anyone else.

PRECONDITION — TREE-SYNC (Fable-verified first-hand 2026-06-26; do this FIRST, it is NOT a race):
- rx2's earlier run died at the includes phase: `install: target directory .../usr/include/pthread/ does not
  exist → _INCSINS Error code 64`. rx2 mislabeled this a "reproducible includes race" — it is NOT. It is the
  **id-018 missing-include-dir class** (RETIRED via op-115), re-surfacing because the build tree is unsynced.
- The build tree `/Users/me/wip-mach/freebsd-src-official-stable-15` (HEAD `524d71df`) **lacks BOTH the
  id-014 and id-018 mtree fixes**: `grep -E 'pthread|apple' etc/mtree/BSD.include.dist` → nothing, and the
  op-115 fix SHA `12330136` is NOT in its history (`git merge-base --is-ancestor 12330136 HEAD` → not a valid
  object). The validated op-113/op-115 `BSD.include.dist` entries were apparently never merged to this tree.
- FIX (not a hunt): restore the op-113/op-115 `etc/mtree/BSD.include.dist` dir entries — `apple`, `uuid`,
  `gen`, `i386`, `libkern`, `mach`, `os`, `pthread`, `servers` — into the build tree, THEN the v3 buildworld
  can actually reach the v3 question. (rx2's "v3 premise verified" was an over-claim: the build died at the
  includes phase before any v3/CPUTYPE codegen check could run.)

OBJECTIVE: prove the x86-64-v3 baseline on the BASE system — build, boot, and SAFE — as li-1009 phase 1,
before extending to ports/pkg. Mechanism already source-verified (`bsd.cpu.mk`: `x86-64-v3` →
`-march=x86-64-v3` on amd64); this validates it end-to-end.

SETUP: add to `/etc/make.conf` in the build root:
```
CPUTYPE?=x86-64-v3
COPTFLAGS= -O2 -pipe
```
Stage ONLY in the Implementer's own owned dir (host-isolation). Record the host CPU (must expose v3, else the
guest SIGILLs).

STEPS / ACCEPTANCE (all must hold):
1. `buildworld` + `buildkernel` complete clean with the v3 make.conf.
2. Resulting image **boots clean** in bhyve (the Implementer's own guest name + staging; not rx1/op-140 guests).
3. **Kernel-AVX safety (load-bearing, expected-safe — confirm):** the kernel's COPTFLAGS gets
   `-march=x86-64-v3` (`kern.pre.mk:71`) but `kern.mk:133-134` appends `-mno-aes -mno-avx` +
   `-mno-mmx -mno-sse -msoft-float` after it, which should win. Confirm empirically: the `-mno-*` are
   present in the final kernel CFLAGS AND a disassembled kernel hot path shows no AVX/SSE in kernel text.
   A kernel with in-kernel AVX/SSE is a FAIL (FPU-state corruption risk), not a pass.
4. **Codegen sanity:** show v3 actually took — an AVX2/BMI2 instruction present in a base userland binary.
5. Userland binaries run on the v3 guest (no SIGILL on a smoke set).

METHOD (op-147m): if any orchestration/assertion harness is written, Elixir spine + Zig probe + `.d`;
NO big shell harness (direct `nm`/`readelf`/`objdump`/`kldstat` ad-hoc is fine for the inspection steps).

VERDICT:
- PASS (1-5) → li-1009 P1 GREEN; advance to P2 (ports/pkg via poudriere make.conf).
- FAIL on step 3 (kernel AVX) → STOP; the global CPUTYPE is leaking into the kernel — needs a kernel
  flag fix before v3 can be a safe baseline. Route to Implementer.
- FAIL on build/boot → capture the failing build log + serial; report signature.

MARKERS:
```
OP149_MAKECONF_SET status=0
OP149_BUILDWORLD status=0
OP149_BUILDKERNEL status=0
OP149_BOOT_CLEAN status=0
OP149_KERNEL_NO_AVX status=0     # load-bearing safety check
OP149_V3_CODEGEN_PRESENT status=0
OP149_USERLAND_RUNS status=0
OP149_VERDICT p1_green=<0|1>
OP149_TERMINAL status=0
```

PUSH: Implementer branch; commit the mtree tree-sync diff (the op-113/op-115 `BSD.include.dist` restore),
the make.conf diff, build/boot logs, the kernel-flag/disasm evidence, the codegen-sanity evidence. No
multi-GB build trees / images committed. Report SHA → Fable verify → Coordinator.

CHAIN (li-1009): op-149 (this, P1 base build+boot+safety) → **op-168 (Gatekeeper long stability soak on the
v3 image = adoption gate)** → on hold-stable, adopt v3+`-O2 -pipe` as the 1.0-preview baseline → P2 ports/pkg
poudriere → P3 default the staged image. (op-149 proves the v3 image is *correct + safe*; op-168 proves it is
*stable enough to ship* — distinct questions, distinct roles: Implementer builds, Gatekeeper soaks.)

---

## ATTEMPT-1 RESULT + ARRANGER-SEAT VERIFY (2026-06-27, model Opus 4, first-hand)

Report: branch `op-149-x86-64-v3-base-tryout` (commits `6abbdd6` mtree restore, `ca9eb67` thrworkq.h
self-containedness, `4ccd2b8` evidence). Markers: `OP149_MAKECONF_SET=0`, `OP149_BUILDWORLD=1`,
`OP149_VERDICT p1_green=0`. Verified at source + logs, NOT relayed:

- **buildworld FAIL is real** — both attempt rc files = 2 (`logs/buildworld-attempt{1,2}.rc`). The
  Implementer cleared the mtree precondition (att-1) + the `thrworkq.h` self-containedness wall (its
  `ca9eb67` two-include fix), then att-2 stopped in `_startup_libs` at `lib/libc_nonshared`.
- **The wall is v3-INDEPENDENT (load-bearing finding).** `lib/libc/iconv/iconv-internal.h:35`
  `int __bsd___iconv_get_list(char ***, size_t *, __iconv_bool);` → `__iconv_bool` undefined →
  `-Werror,-Wimplicit-int`. `__iconv_bool` IS defined in `include/iconv.h:43/45/47` (guarded typedefs) but
  is not visible to the iconv `-internal.h` consumers → a **header-staging / self-containedness** wall, the
  SAME family as the mtree + thrworkq walls. `-march=x86-64-v3 -O2 -pipe` cannot produce an implicit-int
  diagnostic → the Implementer's "pre-existing, not a v3 result" call is CONFIRMED.
- **v3 was never reached.** No buildkernel, no `OP149_KERNEL_NO_AVX` (the one true correctness risk), no
  codegen proof, no userland smoke. p1_green=0 means v3 is **UNREACHED, not FALSIFIED** — the premise stands.

DIAGNOSIS: `freebsd-src-official-stable-15` (HEAD `524d71df`) is a baseline tree missing a stack of
already-validated header-staging/self-containedness fixes (mtree id-014/018, thrworkq, now iconv). Each
buildworld attempt clears one wall and surfaces the next. op-149 is currently doing DOUBLE DUTY — clearing
generic baseline-buildability debt AND testing v3 — which conflates two questions and burns an expensive
cost-30 + full-buildworld cycle per wall.

NEXT-HOP (Coordinator's call — two options, recommendation below):
- **(A) grind:** Implementer adds the iconv fix to the precondition, reruns buildworld, repeats per wall.
  Simple, but N expensive build cycles for N unknown remaining walls.
- **(B) batch-audit FIRST (recommended, cost-efficient):** a FREE Explorer enumerates ALL remaining
  header-staging/self-containedness deltas in this tree UP FRONT (diff against the known-good alpha source
  that builds clean — the `build/wip-rmxos-alpha-obj` lineage), the Implementer batch-applies them, THEN ONE
  clean buildworld → then the v3 checks. Reserves the cost-30 Implementer build for a batched fix instead of
  wall-by-wall. Offloads discovery to a free role (role-cost discipline).
- Either way the v3 make.conf + the kernel-AVX safety check (steps 3-5) are untouched and still pending —
  they only run once a baseline buildworld completes.

op-149 → **[Held]** pending the next-hop choice. This is NOT a v3 verdict; it is a baseline-buildability block.

---

## ATTEMPT-2 RESULT (alpha base) + ARRANGER-SEAT VERIFY (2026-06-27, model Opus 4, first-hand)

Report: branch `op-149-x86-64-v3-alpha`, commit `a0362e8` (tools record `wip-rmxos/tools/op149/README.md`),
pushed to origin. Markers: `OP149_MAKECONF_SET=0`, `OP149_BUILDWORLD=1`, `OP149_VERDICT p1_green=0`. Verified
at log (`build/op149-alpha-x86-64-v3/logs/buildworld.log`, rc=2) + source, NOT relayed:

- **The base switch did NOT moot the wall.** On the CONFIRMED alpha base `wip-rmxos` @ `3c2dd7f`, buildworld
  fails at the **IDENTICAL** `lib/libc/iconv/iconv-internal.h:35:48 __iconv_bool` implicit-int wall
  (`-Werror,-Wimplicit-int`), in `lib/libc_nonshared` / `_startup_libs`, rc=2 — same signature as attempt-1.
- **Root cause = source-level header self-containedness, NOT mtree staging (verified at source).**
  `lib/libc/iconv/iconv-internal.h` has NO `#include` providing `__iconv_bool`; the typedef lives only in
  `include/iconv.h:44` (`_Bool` under C99). The libc_nonshared consumer TU compiles `iconv-internal.h` with
  `<iconv.h>` NOT in scope → implicit-int. The iconv sources are IDENTICAL across stable-15 and the alpha tree
  → the wall reproduces verbatim. mtree Darwin-dir completeness (op-169's 11-vs-8 table) is IRRELEVANT to it.
- **v3 still UNREACHED, not falsified.** No buildkernel/boot/AVX-safety/codegen/smoke. p1_green=0.

CORRECTION (Arranger owns the verify-first gap): op-169's "switch base → moots the entire wall-grind" was an
OVERCLAIM, and the Arranger confirmation checked the wrong proxy (the mtree dir-count table, never evidence
about iconv). NET effect of the base switch was POSITIVE-BUT-PARTIAL: the alpha base already carries the mtree
+ thrworkq fixes, so the build sailed past those two walls and reached iconv as wall #1 — but iconv, being a
`lib/libc` include-order defect identical in both trees, survives the base change. Also: op-169's "wip-rmxos
BUILDS THE ALPHA IMAGE" provenance is now SUSPECT under a clean object prefix — a clean-obj buildworld fails at
iconv, so the alpha image was almost certainly built incrementally with `iconv.o` stale-staged, masking the
source defect. Do NOT let "it builds the image" drive further base-hunting.

NEXT-HOP (DECIDED — grind the single wall; do NOT switch base again):
- iconv is now ONE isolated, concrete, v3-INDEPENDENT wall on the BEST available base. Base-switching is proven
  not to address it. Implementer applies the **faithful iconv self-containedness fix** (make `iconv-internal.h`
  self-contained / ensure the libc_nonshared consumer pulls `<iconv.h>` first — derive the faithful edit from
  upstream FreeBSD, do not hand-roll), COMMITS it as a baseline tree fix (v3-independent), then reruns
  buildworld from a **CLEAN object prefix** → on green, continues to the v3 checks (steps 2-5).
- Folded into op-149 (one cost-30 cycle), not a separate op — single known fix.
- ESCALATION RULE: if a SECOND distinct `lib/libc` self-containedness wall appears AFTER iconv on the alpha
  base, STOP grinding blind — escalate to a compile-based audit (actually attempt the build / diff against a
  truly clean-building tree), since op-169's dir-count audit demonstrably missed iconv.

op-149 → **[Awaiting]** with the iconv precondition above; released for Coordinator re-dispatch to wip-gpt
(overnight batch). Still NOT a v3 verdict — baseline-buildability block, wall #1 of (hopefully) 1.
