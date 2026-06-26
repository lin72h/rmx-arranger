# id-026 — x86-64-v3 base buildworld/kernel tryout (li-1009 phase 1)

- id: id-026
- state: OPEN — phase-1 tryout of the x86-64-v3 platform baseline. Carrier op-149 [Queued, overnight].
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

## Carrier
op-149 (**Implementer, cost-30**, [Held — re-assigned 2026-06-26]) → on PASS, li-1009 P1 green → P2 (ports/pkg
poudriere). RE-ASSIGNED from Explorer rx2: builds are Implementer-only (rx2 didn't know how to build; standing
rule = agents request a build + receive the artifact, no build-procedure doc). The v3 disasm/codegen
inspection (steps 3-5) runs on the Implementer's build, or on the shared image — no separate build by anyone.

## Tree-sync precondition (Fable-verified first-hand 2026-06-26)
rx2's earlier attempt died at the includes phase (`usr/include/pthread/ does not exist → _INCSINS Error 64`)
and was mislabeled a "reproducible includes race." It is NOT a race — it is the **id-018 missing-include-dir
class** (RETIRED via op-115). The build tree `freebsd-src-official-stable-15` (HEAD `524d71df`) lacks BOTH
the id-014 and id-018 `etc/mtree/BSD.include.dist` fixes (no `pthread`/`apple` entries; op-115 SHA `12330136`
not in history) → the validated fixes were apparently never merged to this mainline tree. op-149 must FIRST
restore the op-113/op-115 `BSD.include.dist` dir entries, then run the v3 build. "v3 premise verified" was an
over-claim: the build died before any v3/CPUTYPE codegen check ran. See op-149 PRECONDITION block.
