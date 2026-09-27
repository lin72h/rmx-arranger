---
id: op-168
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-168 — Gatekeeper: x86-64-v3 + `-O2 -pipe` long stability soak (the ADOPTION GATE for the 1.0-preview build baseline)

op-168 | role: **Gatekeeper** | EXU: **rmx-gatekeeper-rx-x64z** | state: **[Done]** — soak CLEAN, adjudicated 2026-06-28 (Arranger, serial verified first-hand sha `30a39d6e…`). 4h0m7s clean boot→shutdown, no panic/Fatal-trap/SIGILL on console; durable serial carries `OP168_IMAGE_PROVENANCE status=0 kernel_ymm=5_flagged` + `OP168_SOAK_RAN status=0 duration=14400` + clean poweroff. VERDICT adopt=1 → **ADOPT-V3 DECIDED 2026-06-28 (Arranger, delegated authority): v3 is the 1.0-preview baseline.** SCOPE: adoption = preview baseline ONLY; does NOT auto-promote to P3 system-wide v3-default — P3 stays GATED on understanding the kernel 5-ymm leak path (caveat 2 below). The three caveats are tracked follow-ups, NOT adoption blockers. THREE adjudication caveats (NOT in the gatekeeper headline): (1) the quantified bars — 356M iters, fails=0, RSS-flat-630pp slope — live ONLY in the redirected guest `/tmp/op168-soak.out` (gone with the guest); they are NOT in the durable serial. The soak is CLEAN by negative console evidence (4h, no crash), but the iteration-count + RSS-slope rest on the gatekeeper's transient read, not an artifact (rc=1 was this redirect, not a crash — confirmed). (2) `kernel_ymm=5_flagged`: the "kernel vector-free by construction" invariant is empirically FALSE — 5 vpxor ymm zero-inits leaked under `-march=x86-64-v3` past kern.mk's `-mno-avx`; bar-2 PASS (xsave/xrstor held) so benign-at-runtime, but the documented invariant is broken → bears on P3 v3-default. (3) NEW finding the report omitted: durable serial shows recurring `ipc_entry_lookup failed on 0 .../mach/ipc/ipc_kmsg.c:1318` (many times at daemon-start AND shutdown) — mach IPC core, non-fatal (ran 4h clean) but unexplained → cheap Explorer look warranted. li-1001 DEFERRED: dtrace modules absent (now twice-inferred) → settle via op-184 kldload/copy gate. | parent id: id-026 | L1i: li-1009 (adoption gate) / li-1012 | authored 2026-06-27 (Arranger seat, model Opus 4) | **overnight batch**

ORIGINAL DISPATCH HEADER (preserved): state was **[In-flight]** — dispatched 2026-06-28 (Coordinator), overnight batch on the soak-host slot. Precondition (a) FULLY MET 2026-06-28: op-149 staged the clean-provenance preview image AND op-183 PUBLISHED it to the shared soak-consume handoff path (sha re-verified first-hand on the landed copy — see below). BOTH codegen markers Fable-confirmed (precondition block). Remaining gate is only (b) the single soak-host slot — Coordinator orders the queue. **Consume path (set this): `NXPLATFORM_VM_IMAGE=/Users/me/wip-mach/vm/runs/op149-preview-uefi-v3.img`** sha256 `707936a615fd8ad0b63682fd5cdf2129d5097e68f47645969d79b343e6ffba8a`, 17179869184 bytes (kernel `c526a91d…`, mach.ko `30d23616…`, HEAD c14e0904). Source artifact lives in the build EXU's dir `build/op149-preview-image/op149-preview-uefi-v3.img`; op-183 delivered it to the handoff path the Gatekeeper consumes. | parent id: id-026 | L1i: li-1009 (adoption gate) / li-1012 | authored 2026-06-27 (Arranger seat, model Opus 4) | **overnight batch**

## WHY

op-149 proves the v3 image is *correct + safe* (builds, boots, no in-kernel AVX, v3 codegen took, userland
runs). That is NOT the same as *stable enough to ship*. A miscompile or marginal-codegen bug from a global
`CPUTYPE=x86-64-v3` + `-O2 -pipe` may only surface under sustained load (FPU-state drift, BMI2/codegen edge
cases, optimizer-exposed UB). This soak is the gate that decides whether we **adopt v3+`-O2 -pipe` as the
1.0-preview build baseline** — a deliberate, modern-CPU-tuned, no-legacy stance pitched as a selling point
vs Linux distros. Hold-stable → adopt. A crash/SIGILL/miscompile signature → v3 baseline does NOT ship in
preview (route the signature to Implementer; the build stays a parallel track, not a gate).

## PRECONDITION (do not start until BOTH hold)

1. **op-149 PASS, Fable-verified first-hand — SATISFIED 2026-06-28.** The image is build-clean (installworld of
   the op-182 certified v3 world), boot-clean (bhyveload → multiuser, kldstat shows `mach`, no panic; banner
   `15.1-STABLE op-171-x86-64-v3-alpha-n283893-c14e0904f967 MACHDEBUGDEBUG amd64`). Both codegen markers closed
   first-hand by Fable: `OP149_KERNEL_NO_AVX` = STRUCTURAL — the v3 baseline is **userland-only**; the amd64
   kernel CFLAGS force `-mno-aes -mno-avx -mno-mmx -mno-sse -msoft-float` (`sys/conf/kern.mk:194-196`) and
   CPUTYPE's `-march` does NOT propagate to the kernel build (`kern.pre.mk` has no CPUTYPE/march handling) → no
   in-kernel vector codegen is possible. `OP149_V3_CODEGEN_PRESENT` = make.conf `CPUTYPE?=x86-64-v3` +
   certified `libc.so.7.full` is dense with AVX2 (2216× `%ymm0`, `vmovdqu`, `vpxor`). NB the soak still
   re-checks both LIVE on the running system per the IMAGE PROVENANCE section (cheap, and Gatekeeper owns its
   own evidence) — but the gate is no longer blocked on them.
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
- **li-1001 invariants** — DEFERRED for this gate (scope correction 2026-06-28, Arranger): the v3 baseline is
  userland-only and the kernel is vector-free by construction (kern.mk:194-196), so the kernel's codegen is
  identical to the non-v3 baseline — a kernel-invariant oracle tests nothing *v3-specific*. (Image also lacks
  the dtrace modules to run it.) The kernel-invariant assertion belongs to the leg soaks / li-1007 integration
  soak, not this codegen gate. `OP168_INVARIANTS` → deferred-with-rationale, NOT a failed bar.
- **no runaway** — fd/RSS/store slopes bounded, no monotonic growth.

**SCOPE (deliberate — codegen-stability gate, NOT service-conformance / integration soak):** exercises the
v3-compiled userland risk surface broadly (libc/libm FMA-AVX2 math, BMI2 string/mem, fs churn) with the
services up as *background load* (catch v3-induced instability in real binaries), NOT driven for conformance.
KNOWN COVERAGE EDGE: libdispatch + libmach are v3-compiled too but left cold here — closed by the future
li-1007 integration soak (op-123 notify + op-146 asl + dispatch + mach-IPC + dtrace), a separate op. CONSEQUENCE:
a clean result = "v3 userland codegen stable across the EXERCISED surface," NOT "v3 fully validated" — report
the coverage boundary, do not bury it (overclaim discipline). The narrow gate is intentional: it keeps the
adoption signal attributable (a tripped bar = v3 codegen, not service logic).

## MARKERS

```
OP168_IMAGE_PROVENANCE status=0   # booted image is the op-149 v3 build (userland AVX2 cited; kernel no-AVX cited)
OP168_SOAK_RAN status=0           # broad v3 userland+kernel load, hours-scale, oracle tick synced to duration
OP168_NO_SIGILL status=0          # zero SIGILL across the soak (dropped-flag / wrong-CPU signature)
OP168_NO_FPU_FAULT status=0       # no in-kernel-AVX FPU corruption / panic under load
OP168_NO_MISCOMPILE status=0      # no crash/abort traceable to v3 codegen; signatures captured if any
OP168_INVARIANTS deferred         # DEFERRED (kernel not v3 → no v3-specific invariant to test; dtrace absent) — not a failed bar
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
