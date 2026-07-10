# SuperStation — rmxOS hardware-targeting positioning

Two-audience marketing brief for the **hardware** side (companion to `superapp-2.0.md`,
which covers the software/OS side). Same core story, two vocabularies.

- **Version 1** — business / non-technical readers.
- **Version 2** — technical readers.

Tier naming (fixed):

- **SuperStation Zero** = `x86-64-v3` (AVX2 / Haswell-class) — the safe fallback floor.
- **SuperStation 1.0** = Icelake-client / Zen4-class — the *main* target; default
  compiler target `-march=icelake-client`.
- **SuperStation 2.0** = APX (Advanced Performance Extensions) — the future.

> Truth-in-advertising note: the "crippled" argument below is framed at the **generic
> x86-64-v4 feature-level** (which under-describes real silicon), NOT as a claim that
> Icelake/Zen4 lack byte/word SIMD — both ship AVX512BW. Sharpen this line if a more
> specific point is intended (e.g. Zen4's double-pumped 256-bit AVX-512 datapath).

---

# Version 1 — For business people

## SuperStation: get the computer you actually paid for

Here's a strange truth about modern computers: **almost all software is compiled to run
on a chip from 2003.**

When you buy a modern Intel or AMD machine, you're buying twenty years of engineering —
faster math, smarter memory handling, dedicated circuitry for AI and encryption. But to
make one program run on *every* machine ever sold, software is usually built for the
oldest common denominator. So your brand-new CPU spends most of its life running in
first gear.

**SuperStation is the opposite bet.** Instead of building for the lowest common
denominator, rmxOS is built to *use the modern chip you already own* — the whole system
is tuned for the features today's processors actually ship with.

### The reputation problem we're fixing

There's a fashionable opinion that the classic PC chip (x86) is "old," "legacy," "bad
design" — and that the newer ARM style is simply better. That's a myth. x86 is a refined,
immensely powerful engine. It has some historical baggage, yes — but the real problem was
never the engine. **The problem is that almost nobody drives it hard.** SuperStation
drives it hard.

### The three tiers

| Tier | What it is | Who it's for |
|---|---|---|
| **SuperStation Zero** | The safe, broad floor — runs well on most machines from the last decade | Maximum compatibility |
| **SuperStation 1.0** | The main target — tuned for today's mainstream Intel/AMD (Icelake / Zen4 class) | The sweet spot: real performance on real, current hardware |
| **SuperStation 2.0** | The future — built for the next generation of x86 (APX) | Tomorrow's flagship machines |

### Why it matters

- **More speed from hardware you already own** — no new purchase required; we unlock
  capability that's been sitting idle.
- **More work per watt and per dollar** — modern instructions do in one step what old
  ones did in ten. That's real efficiency: lower energy, higher throughput, especially
  for AI and encryption workloads.
- **Future-proof by design** — a clear ladder from today's mainstream (1.0) to the next
  generation (2.0), so the platform grows with the hardware instead of freezing in the
  past.

**The pitch in one line:** *SuperStation is rmxOS tuned to the real, modern processor in
your machine — so you finally get the computer you paid for, not the one from 2003.*

---

# Version 2 — For technical people

## SuperStation: whole-userland targeting for the modern x86, not the 2003 baseline

The default state of the x86 ecosystem is an embarrassment of unused capability. Most
distributions still build the userland for **x86-64-v1/v2** — SSE2-era, ~2003. Even
**x86-64-v3** (AVX2, FMA, BMI2 — Haswell, 2013) is inconsistently adopted a decade later,
and **x86-64-v4** as a generic feature level is a lowest-common-denominator description
that leaves the interesting parts of real silicon on the table.

**SuperStation is a hardware-targeting policy: rebuild the entire userland for the
microarchitecture that's actually in the box.**

### Rehabilitating CISC — the honest case for x86

The "x86 is legacy / CISC is bad" narrative ignores what the ISA actually is today:

- **Dense variable-length encoding.** x86 code is compact, which means better
  instruction-cache utilization and higher effective fetch bandwidth — a real advantage
  for a many-small-process workload where I-cache footprint matters.
- **A modern core under a compatible front end.** The "CISC" surface is decoded into
  micro-ops feeding an aggressive out-of-order RISC-like core. You get decades of
  compatibility *and* a state-of-the-art execution engine — you don't have to choose.
- **A genuinely rich SIMD/accelerator surface.** AVX-512 isn't just "wider AVX2": mask
  registers (true per-lane predication), embedded broadcast, and the extension families —
  **VNNI** (int8/bf16 inference), **VBMI/VBMI2** (byte permutes, text), **GFNI**,
  **VAES**, **VPCLMULQDQ** (crypto), byte/word (BW) integer SIMD for small-integer and
  string work. This is dedicated silicon for exactly the workloads that matter now.

The burden is real — the encoding history, the mode baggage — but it's front-end veneer,
not the reason software is slow. Software is slow because it's compiled for a chip two
decades dead.

### The tiers, precisely

- **SuperStation Zero — `x86-64-v3` (AVX2).** The fallback floor for pre-AVX-512
  hardware. Still a huge step over the typical distro baseline; where we land when 1.0's
  feature set isn't present.
- **SuperStation 1.0 — `-march=icelake-client` (Icelake-client / Zen4 class), the default
  target.** Deliberately *not* generic `-march=x86-64-v4`: the generic v4 level is the
  crippled description — it stops at F/BW/CD/DQ/VL and omits the extensions that make
  current chips worth having. Targeting the actual Icelake-client / Zen4 feature set
  unlocks VNNI, VBMI2, GFNI, VAES, VPCLMULQDQ, byte/word SIMD, and friends across the
  *whole* rebuilt userland, not just hand-tuned hot loops.
- **SuperStation 2.0 — APX.** The next step brings x86 much of the ergonomics people
  credit to AArch64: **32 GPRs** (R16–R31, doubling the register file), **3-operand
  non-destructive (NDD) encodings**, **conditional/predicated instructions**, and
  **flag-suppression**. Concretely: fewer register spills, fewer moves, fewer
  hard-to-predict branches. It closes the register-pressure and predication gap that was
  the strongest part of the "RISC is cleaner" argument.

### APX in depth — 32 registers is a microarchitecture story, not an ISA cosmetic

**The register file that software forgot.** x86-64 exposes only **16 architectural
GPRs**, even though a modern core already has a large physical register file (hundreds of
entries) and renames onto it — the compiler can only *name* 16. So register-pressured
code (crypto, codecs, interpreters, math kernels, hash tables) constantly **spills** live
values to the stack and reloads them. Every spill is a store uop; every reload is a load
uop.

**Spills tax the whole out-of-order engine.** Those spill loads/stores aren't free
bookkeeping off to the side — they flow through the same machinery as real work:
allocation/rename slots, ROB entries, a physical register for each load result, scheduler
entries, load/store-queue slots, AGU/port cycles. Register scarcity means a large
fraction of the uops the core allocates and retires is **non-productive spill traffic**.
For a given rename/dispatch/retire width, less of that width lands on actual computation.

**This is the "lower the renamer burden to build a wider machine" point.** A wide
back-end (8-wide and beyond) only pays off if you can *feed* it independent work every
cycle. Two things starve it: too few architectural names (the compiler serializes work
through the same registers or through memory) and spill uops eating front-end/allocate
bandwidth. APX's **32 GPRs** (R16–R31) attack both — fewer spills → fewer bookkeeping
uops per useful op, and a bigger namespace → the compiler can lay out more independent
live values for the scheduler to run in parallel. The width you build gets spent on
computation, not spill cleanup.

**It only turns on with the compiler.** R16–R31 need APX's new encodings (REX2 /
EVEX-promoted). No existing binary can touch them — there is no dynamic "just use more
registers." The register allocator has to *target* 32 GPRs and codegen has to emit the
new encodings. That is the SuperStation thesis in miniature: **recompile the userland or
the silicon stays dark.** You don't get APX by buying an APX chip; you get it by building
for one — buying the feature and never turning it on is the exact failure mode we exist
to fix.

**Parity with AArch64 — closing the gap people actually cited.** AArch64 exposes 31 GPRs,
and "more registers → fewer spills → easier to feed a wide machine" was one of the two
strongest technical arguments for ARM over x86 (Apple's ~8-wide cores being the poster
child). APX brings x86 to 32 GPRs and adds **3-operand non-destructive (NDD)** forms —
which also kill the extra `mov`s x86 needed to preserve a source operand, cutting uop
count and register pressure again — plus predication / flag-suppression. That closes the
*register-count* half of the width gap.

**Honest caveat.** APX does **not** fix the *other* half: x86's variable-length decode is
still harder to widen than AArch64's fixed-length instructions (the micro-op cache
mitigates but does not erase this). APX removes the register-pressure limiter on width;
it does not make the decoder trivially wide. We claim only the half APX actually delivers.

**One-line version:** *APX gives the compiler the register namespace to feed a wide
machine and cut spill traffic — but it is compiler-gated, so buying the silicon without
rebuilding for it is paying for a feature you never switch on.*

### Co-design with SuperApp 2.0

This isn't a separate story from the software pitch — it's the other half. SuperApp 2.0
decomposes the app into **many small UNIX processes**; that model *loves* a modern x86:

- **Code density** (compact x86 encoding) means more small processes stay resident in
  cache.
- **APX's larger register file** keeps hot leaf processes in registers instead of
  spilling — exactly what small, frequently-woken workers want.
- **AVX-512 VNNI / VBMI** puts AI-inference and text/crypto acceleration directly under
  the modular workers, so a decomposed SuperApp gets accelerator throughput without a
  monolith.

**The thesis:** the modular software stack (SuperApp 2.0) and the modern hardware target
(SuperStation) are one co-designed system — rebuild the whole userland for the real chip,
and the architecture and the silicon reinforce each other instead of both running in
first gear.
