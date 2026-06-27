# op-168 — Gatekeeper: x86-64-v3 + `-O2 -pipe` long stability soak (the ADOPTION GATE for the 1.0-preview build baseline)

op-168 | role: **Gatekeeper** | EXU: **rmx-gatekeeper-rx-x64z** | state: **[Queued]** — blocked on (a) op-149 producing the v3 image (PASS, Fable-verified) AND (b) the single soak-host slot (held by op-163, then op-165). Coordinator orders the soak queue. | parent id: id-026 | L1i: li-1009 (adoption gate) | authored 2026-06-27 (Arranger seat, model Opus 4) | **overnight batch**

## WHY

op-149 proves the v3 image is *correct + safe* (builds, boots, no in-kernel AVX, v3 codegen took, userland
runs). That is NOT the same as *stable enough to ship*. A miscompile or marginal-codegen bug from a global
`CPUTYPE=x86-64-v3` + `-O2 -pipe` may only surface under sustained load (FPU-state drift, BMI2/codegen edge
cases, optimizer-exposed UB). This soak is the gate that decides whether we **adopt v3+`-O2 -pipe` as the
1.0-preview build baseline** — a deliberate, modern-CPU-tuned, no-legacy stance pitched as a selling point
vs Linux distros. Hold-stable → adopt. A crash/SIGILL/miscompile signature → v3 baseline does NOT ship in
preview (route the signature to Implementer; the build stays a parallel track, not a gate).

## PRECONDITION (do not start until BOTH hold)

1. **op-149 PASS, Fable-verified first-hand** — the v3 image is build-clean, boot-clean, `OP149_KERNEL_NO_AVX`
   confirmed (no in-kernel vector codegen — load-bearing), `OP149_V3_CODEGEN_PRESENT` confirmed. Soaking an
   image that failed the kernel-AVX safety check is pointless (it's a known FAIL, not a stability question).
2. **soak-host free** — single slot; op-163 (asl leg-4) holds it, op-165 (notify leg-4) is queued. op-168
   joins that queue. Coordinator prioritizes (op-165 confirms the just-merged id-025 fix; op-168 is a
   platform-bet gate — both legitimate, both overnight).

## IMAGE PROVENANCE (Gatekeeper checks the RUNNING system, not the on-disk artifact)

- Boot the op-149 v3 image; confirm FIRST-HAND it is the v3 build: a base userland binary carries an AVX2/BMI2
  insn (cite `objdump`), AND the running kernel shows NO in-kernel AVX/SSE (cite the kernel-flag/disasm
  evidence op-149 pushed, or re-check live). A soak on a non-v3 or unsafe-kernel image proves nothing.

## WHAT TO SOAK (broad v3-codegen stress — NOT a service-conformance soak)

This is a *build-flags-are-safe* soak, distinct from the per-service leg-4 soaks. Exercise the v3-compiled
base broadly + long:
- Sustained mixed userland load (the available base/ports binaries — build/compile loops, fs churn, libc/libm
  math paths where FMA/AVX2 codegen lives, string/mem routines). Hours-scale.
- The **li-1001 mach-ipc substrate invariant oracle on the v3 kernel** (send/recv balanced, port alloc/dealloc
  balanced, no stuck enqueue, dead-name delivered) — confirms the v3 *kernel* holds the same invariants the
  baseline kernel does (a miscompiled kernel would drift these).
- Whatever core services are up on the image, left running under the load (notifyd/asld if present) — watch
  for v3-induced instability, not service conformance.

## FIXED BAR (Gatekeeper-owned)

- **no SIGILL** anywhere (the v3-on-wrong-CPU / dropped-flag signature) — watch via `proc:::signal-clear`/
  `fbt::sigexit` for SIGILL(4) on the soaked PIDs.
- **no FPU-state corruption / panic** — the in-kernel-AVX risk surfacing under load (kernel must stay quiet;
  no unexpected FP exceptions, no panic, no silent data corruption in checksummed workloads).
- **no crash / no miscompile signature** — no segfault/abort traceable to optimizer-exposed UB; if a binary
  crashes, capture the signature + the offending object's build flags.
- **li-1001 invariants FLAT** on the v3 kernel across the full soak (asserted, not traced).
- **no runaway** — fd/RSS/store slopes bounded, no monotonic growth.

## MARKERS

```
OP168_IMAGE_PROVENANCE status=0   # booted image is the op-149 v3 build (userland AVX2 cited; kernel no-AVX cited)
OP168_SOAK_RAN status=0           # broad v3 userland+kernel load, hours-scale, oracle tick synced to duration
OP168_NO_SIGILL status=0          # zero SIGILL across the soak (dropped-flag / wrong-CPU signature)
OP168_NO_FPU_FAULT status=0       # no in-kernel-AVX FPU corruption / panic under load
OP168_NO_MISCOMPILE status=0      # no crash/abort traceable to v3 codegen; signatures captured if any
OP168_INVARIANTS status=0         # li-1001 mach invariants flat on the v3 kernel (asserted)
OP168_NO_RUNAWAY status=0         # fd/RSS/store slopes bounded
OP168_VERDICT adopt=<0|1>         # ADOPT-V3 (hold-stable → preview baseline) | UNSTABLE (signature → Implementer)
OP168_TERMINAL status=0
```

## GATES (Arranger verifies first-hand)

- The terminal marker is a CLAIM — check the RAW slopes + signal/panic logs first-hand, not an unconditional
  `status=0`, before ADOPT-V3 counts (overclaim discipline, id-011).
- ADOPT-V3 is a Coordinator decision, not the Gatekeeper's: op-168 supplies the stability evidence; whether
  v3 then *gates* preview or lands as the adopted-but-parallel baseline is the open li-1009 scoping call.
- hours-scale → overnight batch (long-ops directive), behind op-163/op-165 on the host.

## CHAIN

op-149 (Implementer: v3 build+boot+safety, PASS) → **op-168 (this: Gatekeeper stability soak)** → ADOPT-V3
→ v3+`-O2 -pipe` = 1.0-preview build baseline → li-1009 P2 (ports/pkg poudriere at v3) → P3 (default the
staged image). UNSTABLE → signature to Implementer; v3 stays a parallel track, not a preview gate.

## RELATIONS
- li-1009 (x86-64-v3 baseline) — this is the adoption gate for P1→adopt.
- id-026 (P1 tryout) — op-149 sibling carrier.
- li-1001 (mach substrate invariants) — the oracle reused here to prove the v3 *kernel* holds.
- feedback: soak_is_gatekeeper (this is fixed-bar regression soak = Gatekeeper, not Implementer proving own
  build), build_is_implementer (op-149 builds; op-168 only consumes the image), no_conflate_gating_with_readiness.
