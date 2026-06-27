# id-026 — x86-64-v3 base buildworld/kernel tryout (li-1009 phase 1)

- id: id-026
- state: OPEN — phase-1 tryout of the x86-64-v3 platform baseline. **REVIVED 2026-06-27 (Coordinator):**
  carrier op-149 (Implementer wip-gpt) → on PASS feeds **op-168** (Gatekeeper long stability soak = the
  ADOPTION GATE). Two-step: Implementer builds (correct + safe), Gatekeeper soaks (stable enough to ship).
  Hold-stable → adopt v3+`-O2 -pipe` as the 1.0-preview build baseline (modern-CPU / no-legacy selling point).
  **op-149 ATTEMPT-1 (2026-06-27): buildworld FAIL (rc=2), v3 UNREACHED — Arranger-verified.** Cleared mtree +
  thrworkq.h walls, then hit the pre-existing `lib/libc_nonshared` `__iconv_bool` implicit-int wall (header-
  staging class, v3-INDEPENDENT — confirmed at source). The build tree is missing a stack of already-validated
  header-staging fixes; op-149 [Held]. **op-169 batch-audit (Arranger-verified 2026-06-27) → base RE-POINT:**
  op-149 was building the WRONG tree. Vanilla `freebsd-src-official-stable-15` (8 Darwin staging dirs, missing
  dispatch/private/xpc) keeps hitting retrofit walls; the **proven rmxOS alpha `wip-gpt/wip-rmxos` @ `3c2dd7f`**
  (op-156 merge tip, builds the alpha image, all 11 Darwin dirs) has none of them. Recommendation: re-point
  op-149's build root to `wip-gpt/wip-rmxos` + add the v3 make.conf → clean v3 isolation, stable-15 walls moot.
  op-169's "switch to NextBSD" was REJECTED (donor lineage, missing pthread+private — would reintroduce walls;
  the explorer's tree counts were inverted). Awaiting Coordinator confirm of the base switch. NOT a v3 verdict.
- raised: 2026-06-25.
- L1i parent: li-1009 (x86-64-v3 platform baseline).

## What
Prove the base-system baseline as a first tryout, before extending to ports/pkg (li-1009 P2) or defaulting
the image (P3). make.conf:
```
CPUTYPE?=x86-64-v3
COPTFLAGS= -O2 -pipe
```
Mechanism source-verified (`bsd.cpu.mk`: `x86-64-v3` → `-march=x86-64-v3`). Kernel-AVX is safe by
construction (`kern.mk:133-134` `-mno-avx/-mno-sse/-msoft-float` override the `-march` that
`kern.pre.mk:71` appends to kernel COPTFLAGS); `COPTFLAGS=-O2 -pipe` keeps `-fno-strict-aliasing`
auto-added (`kern.pre.mk:67`). This item validates it end-to-end: builds, boots, and is SAFE.

## Acceptance (op-149)
1. `buildworld` + `buildkernel` complete clean with `CPUTYPE?=x86-64-v3` in make.conf.
2. Resulting image **boots clean** in bhyve.
3. **Kernel-AVX safety check (load-bearing):** confirm the kernel did NOT get vector codegen — the
   kernel build's `-mno-mmx/-mno-sse/-mno-avx/-msoft-float` survive the CPUTYPE setting. Inspect kernel
   build flags and/or disassemble a kernel hot path; no AVX/SSE in kernel text.
4. **Codegen sanity:** confirm v3 actually took — an AVX2/BMI2 instruction is present in a base userland
   binary (the flag is real, not silently dropped).
5. Userland binaries run on the v3 guest (no SIGILL).

## Risks / notes
- dev host + bhyve guest vCPU must expose v3; if the host is pre-Haswell the guest SIGILLs (record host CPU).
- relates id-017 (buildworld skip-llvm-bootstrap) — bootstrap toolchain interaction under a global CPUTYPE.
- LONG build → overnight batch (op-149 [Queued]); do NOT run interactive.

## Carriers
- **op-149** (**Implementer wip-gpt, cost-30**, [Ready — revived 2026-06-27]) — the v3 build+boot+safety+codegen
  tryout. RE-ASSIGNED from Explorer rx2: builds are Implementer-only (rx2 didn't know how to build; standing
  rule = agents request a build + receive the artifact, no build-procedure doc). The v3 disasm/codegen
  inspection (steps 3-5) runs on the Implementer's build, or on the shared image — no separate build by anyone.
- **op-168** (**Gatekeeper rmx-gatekeeper-rx-x64z**, [Queued]) — the long stability soak on op-149's v3 image.
  THE ADOPTION GATE: op-149 answers "correct + safe?", op-168 answers "stable enough to ship?". Blocked on
  op-149 PASS + the single soak-host slot (behind op-163/op-165). Hold-stable → ADOPT-V3 (Coordinator's call
  whether v3 then *gates* preview or lands adopted-but-parallel); a SIGILL/FPU/miscompile signature → route to
  Implementer, v3 stays a parallel track.

On op-149 PASS → li-1009 P1 build-green; on op-168 hold-stable → v3 baseline ADOPTED → P2 (ports/pkg poudriere)
→ P3 default the staged image.

## Tree-sync precondition (Fable-verified first-hand 2026-06-26)
rx2's earlier attempt died at the includes phase (`usr/include/pthread/ does not exist → _INCSINS Error 64`)
and was mislabeled a "reproducible includes race." It is NOT a race — it is the **id-018 missing-include-dir
class** (RETIRED via op-115). The build tree `freebsd-src-official-stable-15` (HEAD `524d71df`) lacks BOTH
the id-014 and id-018 `etc/mtree/BSD.include.dist` fixes (no `pthread`/`apple` entries; op-115 SHA `12330136`
not in history) → the validated fixes were apparently never merged to this mainline tree. op-149 must FIRST
restore the op-113/op-115 `BSD.include.dist` dir entries, then run the v3 build. "v3 premise verified" was an
over-claim: the build died before any v3/CPUTYPE codegen check ran. See op-149 PRECONDITION block.
