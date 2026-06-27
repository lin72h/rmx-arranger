# op-149 — Explorer: x86-64-v3 base buildworld/kernel tryout (li-1009 P1)

op-149 | role: **Implementer** (cost-30) | EXU: **wip-gpt** | state: **[Held] — attempt-1 reported buildworld FAIL (rc=2), v3 question UNREACHED; blocked on pre-existing baseline-tree walls (Arranger-verified first-hand 2026-06-27). Next-hop = Coordinator's call (see ATTEMPT-1 RESULT block).** | parent id: id-026 | L1i: li-1009 | authored 2026-06-25 (Fable), revived 2026-06-27

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
