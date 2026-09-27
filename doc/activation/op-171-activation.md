---
id: op-171
state: dropped
updated: 2026-09-27T22:54Z
legacy-state: In-flight
reset: j-20260927-004
---
# op-171 — Implementer: make the v3 buildworld ELEGANT — strip with the toolchain that BUILDS (LLVM binutils), retire the host-binary objcopy/strip override, fold in the 2-line mach_debug staging fix → one clean-obj image for op-168

op-171 | role: **Implementer** (cost-30) | EXU: **wip-gpt** | state: **[In-flight]** — dispatched 2026-06-27 (overnight batch; parallel to soak host; build EXU only) | parent id: id-026 | L1i: li-1009 / li-1012 P0 | authored 2026-06-27, REVISED 2026-06-27 (Arranger seat, model Opus 4 — root cause now VERIFIED first-hand, supersedes the transient-race / cherry-pick framing)

## WHY (one line)

op-149's FIRST cold-obj v3 buildworld hit a toolchain wall at the shared-lib debug-split: the in-tree
**elftoolchain `elfcopy` (frozen 2018, `$Id segments.c 3615`, tree stamp r3769) cannot even PARSE a modern
lld-linked `.so` — it dies at `elf_begin()` with `ELF_E_ARGUMENT` ("Invalid argument") on `libsys.so.7.full`
and `libc.so.7.full`** — and the Implementer punched through it across attempts 5/5b/6 with ad-hoc per-attempt
host-binutils overrides (`OBJCOPY=/usr/bin/objcopy`, `STRIPBIN=/usr/bin/strip` in side `make-with-host-*.conf`
files). That host-binary injection muddies image provenance right before op-168 (the v3 ADOPTION-GATE soak)
consumes it. This op replaces the workaround with the ELEGANT, sanctioned, committed fix — **strip with the
same LLVM binutils that already does every other objcopy/strip in the build** — produces ONE clean-obj image
from committed source, and folds in the small staging fix so the run completes in a single pass.

## ROOT CAUSE (Arranger-verified FIRST-HAND 2026-06-27 — take as given, supersedes the prior "transient race" / "elftoolchain cherry-pick" framing)

The earlier brief hypothesised a transient/race OR a small elftoolchain `segments.c` cherry-pick. Both are
**FALSIFIED by first-hand reproduction.** The verified facts:

- **It is a TOOL MISMATCH, not a code bug and not a race.** rmxOS links shared libs with modern **lld**, which
  emits a `.relro_padding` (SHT_NOBITS) section plus a `PT_GNU_RELRO` / RW `PT_LOAD` whose `MemSiz >> FileSiz`.
  elftoolchain `libelf` REJECTS this layout at **`elf_begin()`** — the INPUT-parse step, *before* any segment
  copy logic runs. So the failure is in the input parser, NOT in `segments.c:copy_phdr`/`add_to_inseg_list`
  (where Agent 4 located it — that read was WRONG; that code never executes on these inputs).
- **Proven DETERMINISTIC and UNIVERSAL, not rmxOS-specific.** I ran the stable/15-built elftoolchain `elfcopy`
  by hand on the real ELFs: it fails every time at `elf_begin()`. Running it on **stock FreeBSD `/bin/sh`**
  (which has the identical `.relro_padding` + GNU_RELRO `msz>fsz` layout) ALSO fails. So this is a categorical
  limitation of frozen-2018 elftoolchain against modern lld output — any sufficiently modern `.so` trips it.
  The attempt-3 meta's "transient; manual objcopy succeeded" was warm-WORLDTMP confusion (see post-mortem), not
  a real race.
- **There is NO faithful donor for a tool fix.** FreeBSD `main`'s `contrib/elftoolchain/elfcopy/segments.c` is
  BYTE-IDENTICAL to ours (both `$Id ... 3615`); upstream elftoolchain is frozen. So "cherry-pick the upstream
  patch" (the originally-authorized Path A) is **both impossible (no newer donor) and unnecessary (wrong code)**.
- **llvm-objcopy/llvm-strip strip the EXACT same ELFs cleanly (rc=0).** The toolchain that BUILDS the binaries
  can also strip them. The fix is to USE it for the debug-split, which is what every warm build was already
  silently doing.
- **v3-INDEPENDENT (verified):** the debug-split is a post-codegen symbol operation and the parse-reject
  reproduces on non-v3 stock binaries (`/bin/sh`) — it is baseline-buildability debt, same class as iconv,
  NOT a v3 codegen artifact. (Q1 below re-confirms on the actual build to close it formally.)

## WHY IT TRIGGERED NOW (the post-mortem — prevents recurrence)

The `objcopy`/`strip` *name* is a LINK installed by whichever binutils the active `MK_LLVM_BINUTILS` selects
(elfcopy when `==no`, llvm-objcopy when `!=no` — mutually gated in `usr.bin/elfcopy/Makefile` and
`usr.bin/clang/llvm-objcopy/Makefile`). The cross-tools `XMAKE` forces `MK_LLVM_BINUTILS=no`
(`Makefile.inc1:812`) — so in a FRESHLY-populated WORLDTMP, `objcopy`=elfcopy. **Every prior project build was
warm/incremental** and reused a WORLDTMP where `llvm-objcopy` had ALREADY overwritten the `objcopy` link, so
the strip step quietly used LLVM and nobody noticed elfcopy couldn't do the job. The op-149 v3 run was the
**first cold-obj buildworld this tree has had on this host** (li-1012 provenance principle, now manifest in the
toolchain layer) and reached the `libsys`/`libc` debug-split while elfcopy was still the active `objcopy`. Same
warm-cache masking that li-1012 flagged for test images — here it masked a toolchain limitation for the whole
project.

## STATE NOW — YOU ARE MID-ATTEMPT-9, INTERRUPTED (reconcile your own dirty state BEFORE anything else)

This op did not start you from a clean slate. You were INTERRUPTED part-way through attempt-9 (the libkvm
`nlist` wall) and the build environment is in an INCONSISTENT state carried across attempts 3→9. Do NOT build
on top of it — reset to a known-clean point FIRST:

- **Discard the host-binutils workaround entirely.** The side configs `make-with-host-objcopy.conf`
  (`OBJCOPY=/usr/bin/objcopy`) and `make-with-host-llvm-binutils.conf` (`+ STRIPBIN=/usr/bin/strip`) in the
  build dir are the workaround this op RETIRES — delete them; do not source them; clear any
  `OBJCOPY=`/`STRIPBIN=` exports from your shell/env. The fix is the in-tree LLVM wiring below, not these.
- **The obj prefix is POISONED — full clobber, do not reuse.** Across attempts 3-9 the prefix accumulated
  stale `.o`/`.so.N.full`, partially-stripped libs, half-staged headers, and (att-6) a partly-built
  clang/llvm bootstrap. The attempt-9 `nlist` "missing n_other/n_desc" error is itself a STALE STAGED
  `sys/nlist_aout.h` from these incremental retries (op-172-addendum: source has all 5 fields, no real
  divergence) — it will NOT reproduce on a clobbered prefix. Treat NO object/header from attempts 3-9 as
  trustworthy. Wipe the obj prefix to bare and rebuild from zero (Q3).
- **Reconcile the working tree before committing fixes.** Confirm `git status --porcelain` on branch
  `op-149-x86-64-v3-alpha`: the only intended committed content is the clean 2-line `tools/op149/make.conf`
  (+ the prior faithful iconv fix). Anything else uncommitted from the attempt-3→9 scramble (experimental
  edits, the side configs) is NOT part of the fix — back it out so your two NEW commits (Q0 mach_debug, Q2
  toolchain) land on a clean base. If you find in-progress edits you don't recognize, STOP and report — do
  not silently discard (could be real work).
- **Only AFTER the above is clean** do you apply Q0/Q2/Q2b and run the single cold build (Q3). The whole point
  is ONE clean pass from committed source — not attempt-10 layered on attempt-9's residue.

## THE ELEGANT FIX (decided 2026-06-27 per Coordinator "you decide, make an elegant solution")

**Strip with the toolchain that builds.** Make the build-time `objcopy`/`strip` used for the shared-lib
debug-split resolve to the in-tree **llvm-objcopy/llvm-strip** (already built, already the system `objcopy` on
the host, already proven to strip these ELFs). Keep elftoolchain `elfcopy` ONLY for its genuine niche —
ELF→PE32+ translation for EFI boot programs (`Makefile.inc1:3039-3040`), which llvm-objcopy can't do and which
never touches a modern `.so`. Then RETIRE the host-binary side-configs entirely; nothing reaches outside the
tree.

Mechanism is **Implementer's call** (build_is_implementer — you own the build, pick the cleaner of these and
report which + why):
- **(pref) point the world/cross strip vars at the in-tree LLVM tools** — e.g. wire `XOBJCOPY`/`XSTRIPBIN`
  (consumed in the world CROSSENV at `Makefile.inc1:855`) to the in-tree `llvm-objcopy`/`llvm-strip` so the
  debug-split uses them while elfcopy still builds for EFI; OR
- **stop `XMAKE` forcing `MK_LLVM_BINUTILS=no`** for the cross-tools stage (un-gate at `Makefile.inc1:812`) so
  `objcopy`/`strip` are llvm's from bootstrap onward — verify EFI PE32+ still builds (elfcopy is still in
  `_elftctools`, just no longer owning the `objcopy` name).
Choose the one that is least-intrusive on the FB-15 base and keeps EFI building; commit it with the root cause
in the message. This is a SEPARATE committed baseline-buildability change from the v3 make.conf.

## DELIVERABLES (in order)

**Q0 (FIRST — the 2-line mach_debug staging fix, committed + faithful).**
- op-172 (verdict `reconciliation-plus-residual`, SHA 068773f, Arranger-verified) reduced the header-staging
  wall to ONE faithful 2-line change: restore `sys/mach_debug` to header staging. Apply: (1)
  `include/Makefile` — add `sys/mach_debug` to the LSUBDIRS/staging list alongside the existing `sys/mach`
  entry (donor: NextBSD `include/Makefile`, which carries `mach_debug` in SUBDIR; wip-rmxos dropped it); (2)
  add the matching `sys/mach_debug` node to `etc/mtree/BSD.include.dist` so the dir exists at stage time.
  Adapt donor convention to FB-15 (`${SRCTOP}/sys`, `${SDESTDIR}`). Commit as its OWN faithful change
  (donor-cited), SEPARATE from the toolchain fix and the v3 make.conf.
- **nlist is a PHANTOM, not an edit:** op-172-addendum proved the attempt-9 libkvm "`struct nlist` lacks
  n_other/n_desc" was a STALE STAGED header from incremental retries — `sys/sys/nlist_aout.h` has all 5 fields
  identically across wip-rmxos/stable-15/NextBSD, no Darwin competitor exists. The CLEAN clobber (Q3) dissolves
  it. If it RECURS on a clobbered prefix: capture the exact compiler error + inspect the staged header vs
  source BEFORE proposing anything — do NOT hand-roll (verify-first; divergence framing refuted).

**Q1 (GATE, fast — formally close v3-independence on the real build).**
- The root cause is already proven v3-independent (the parse-reject reproduces on stock `/bin/sh`). Confirm it
  carries into the build: the debug-split now uses LLVM binutils regardless of v3, and `buildworld` reaches the
  `libsys`/`libc` strip without the host override. If for any reason the LLVM-strip step behaves differently
  under v3 vs non-v3 (it must not — strip is post-codegen) → STOP + escalate to Arranger. Otherwise record
  `OP171_V3_INDEPENDENT yes` with the evidence (the strip step succeeded on the v3 obj with no host binary).

**Q2 — commit the elegant fix (per THE ELEGANT FIX above).**
- Wire build-time `objcopy`/`strip` for the debug-split to in-tree llvm-objcopy/llvm-strip (your chosen
  mechanism); keep elfcopy for EFI PE32+; DELETE the `make-with-host-*.conf` side files and remove any
  `OBJCOPY=/usr/bin/...`/`STRIPBIN=/usr/bin/...` from the build invocation. Commit with the verified root cause
  (elftoolchain `elf_begin()` parse-reject of lld `.relro_padding`/GNU_RELRO; no donor; LLVM strips cleanly) in
  the message. **HARD CONSTRAINT:** `tools/op149/make.conf` stays the clean 2-line v3 experiment — no toolchain
  vars baked into it.

**Q2b — add the FAIL-FAST guard (so this can never silently recur).**
- Add a cheap assertion, BEFORE the `libraries` stage, that the active WORLDTMP `objcopy`/`strip` is
  llvm-objcopy/llvm-strip (e.g. check `objcopy --version` identifies LLVM, or the link target resolves to
  llvm-objcopy) — fail the build with a clear message if elfcopy is winning the name. This converts a future
  9-wall serial header-by-header hunt into ONE explicit error at the right place. Keep it minimal and in-tree
  (a guard in the relevant `bsd.*.mk`/build step or a tools check — Implementer's call on the cleanest spot);
  do NOT over-engineer.

**Q3 — produce the CLEAN image + reach the v3 checks.**
- `buildworld` + `buildkernel` complete from a **CLEAN object prefix** (full clobber — no stale `.o`/`.full`
  staging masking the iconv, toolchain, OR mach_debug fix; the att-2 "builds the image" provenance was
  incremental-masked and the attempt-9 nlist phantom was a stale staged header — do not repeat that), driven by
  committed source + the clean make.conf + the committed Q0 mach_debug fix + the committed Q2 toolchain fix
  ALONE. No manual host-binary injection at the command line.
- Then run op-149 steps 3-5 on the resulting image: `OP149_KERNEL_NO_AVX` (load-bearing safety),
  `OP149_V3_CODEGEN_PRESENT`, userland smoke. (This op carries op-149 across the finish line build-wise; the v3
  verdict markers remain op-149's — report them there.)

## VERDICT (one of)
- `clean-v3-image` → buildworld+buildkernel clean from committed source on a clobbered obj prefix, LLVM-strip +
  mach_debug + fail-fast guard committed, host overrides retired, steps 3-5 reached → hand the image to op-168,
  op-149 advances to its v3 verdict.
- `toolchain-deeper` → wiring LLVM strip into the debug-split has unexpected fallout (e.g. an EFI PE32+ build
  regression from un-gating MK_LLVM_BINUTILS) → report scope + which mechanism failed, do NOT ship a half-fix;
  Arranger decides.
- `v3-coupled` (Q1 negative, should not happen) → the strip step behaves v3-dependently → real v3 finding,
  STOP + escalate.

## BOUNDARIES
- Implementer-only build EXU (wip-gpt); runs on the BUILD host, NOT the soak host — parallel-safe with the
  op-163/op-165 soak queue (build does not touch the gatekeeper host).
- Stage strictly inside wip-gpt's own owned dir; no host-global paths. (Retiring the host-binutils override is
  exactly this rule — the fix must be self-contained in the tree, using the IN-TREE llvm-objcopy/llvm-strip,
  not `/usr/bin/objcopy`.)
- Commit the toolchain fix and the mach_debug fix as TWO separate baseline-buildability changes, both separate
  from the v3 make.conf, each with its root-cause in the message. Push branch + SHA → Arranger verify
  first-hand (clean-obj provenance: confirm no host `/usr/bin/objcopy`/`strip` in the build invocation, the obj
  prefix was clobbered, and the debug-split used in-tree LLVM tools) → Coordinator.
- Faithful fixes only — the mach_debug fix is donor-sourced (NextBSD); the toolchain fix uses the build's own
  in-tree LLVM binutils (no external/hand-rolled tool).

## MARKERS
```
OP171_MACHDEBUG_APPLIED     # 2-line sys/mach_debug staging fix committed (include/Makefile + BSD.include.dist, donor-cited, own commit); cite SHA
OP171_OBJCOPY_ROOTCAUSE     # VERIFIED: elftoolchain elfcopy fails at elf_begin() on lld .relro_padding/GNU_RELRO; deterministic, universal (stock /bin/sh too); no donor; LLVM strips clean
OP171_V3_INDEPENDENT        # debug-split (LLVM strip) reproduces/behaves identically off v3: yes|no (Q1 gate; expected yes)
OP171_ELEGANT_FIX           # build-time objcopy/strip wired to in-tree llvm-objcopy/llvm-strip (mechanism: XOBJCOPY/XSTRIPBIN | un-gate MK_LLVM_BINUTILS=no); elfcopy kept for EFI; host overrides deleted; make.conf clean; cite SHA
OP171_FAILFAST_GUARD        # pre-libraries assertion that WORLDTMP objcopy/strip = LLVM (fails loud if elfcopy wins the name); cite where
OP171_CLEAN_OBJ_BUILD       # buildworld+buildkernel from a CLOBBERED obj prefix, no manual host-binary injection
OP171_REACHED_CHECKS        # op-149 steps 3-5 reached on the clean image (AVX-safety/codegen/smoke) — verdict to op-149
OP171_VERDICT clean=<0|1>   # clean-v3-image | toolchain-deeper | v3-coupled
OP171_TERMINAL
```

## RELATIONS
- id-026 / li-1009 / li-1012 P0 — the v3 clean baseline. op-171 unblocks op-149's build completion + op-168's
  clean-provenance soak; it IS li-1012's P0 toolchain-debt retirement.
- op-149 [Awaiting] — the build op this finishes; its v3 verdict markers (OP149_*) report THERE, not here.
- op-168 [Queued] — the ADOPTION-GATE soak; its IMAGE_PROVENANCE check needs an image built reproducibly from
  committed source with NO unrecorded host-tool substitution — exactly what op-171 guarantees.
- op-172 [Retired] — produced the mach_debug staging reconciliation (Q0) and the nlist-phantom finding.
- NOTE (Arranger): the elftoolchain-vs-lld limitation is a standing baseline fact (frozen elftoolchain can't
  process modern lld `.so`) — the fail-fast guard + cold-build discipline (li-1012) are the prevention. If a
  future need for elfcopy-on-`.so` arises (it should not), that is a separate id, not this op.
- feedback: build_is_implementer (this builds + commits + picks the wiring mechanism), agent_host_isolation
  (retire the host-binary reach — use IN-TREE LLVM tools), verify_signature_divergence_claims (root cause is
  MEASURED first-hand, not asserted; Agent-4's segments.c claim was refuted by reproduction),
  artifact_identity_needs_content_check (clean-obj clobber so image provenance = committed source),
  no_conflate_gating_with_readiness (a host-binutils workaround "builds an image" ≠ a clean adoptable baseline),
  complete_once_not_iterative (mach_debug + toolchain + guard land together so the cold build passes in ONE pass).
```
