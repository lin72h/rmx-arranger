# id-021 — libxpc: conformance bring-up (Gate B breadth, long-pole) — substrate axis now, consumer axis Lane-B-gated

- id: id-021
- state: **leg 1 DONE (op-121 `ec25e50`, Arranger-verified first-hand) → leg 2 = op-122 RESERVED but HELD
  (Coordinator depth-first directive 2026-06-24: make id-010 notify + id-011 asl *truly-green/solid*
  BEFORE opening the libxpc long-pole).** Leg 2 dispatch text (lockstep dual-explorer run of pinned blob
  `3b6197bd…` on rx-x64z+mx-a64z, echo+diff sha) is authored + reserved as op-122; resumes once notify+asl
  soak/Gate-C legs (op-123/op-124) retire. Op number not reused. First conformance op in the **lockstep
  dual-explorer dispatch shape** (see the Parity-Explorer memory / the op-116 lesson): leg 1 =
  author-once-and-pin (DONE); leg 2 = both explorers run the pinned blob UNMODIFIED + echo blob sha
  (Arranger diffs = apples-to-apples gate). Post-preview-floor; libxpc is the long-pole,
  **classification-only pre-1.0** — Coordinator-holdable, free-Explorer, parallel non-blocking.
  - **leg 1 verified (Arranger, first-hand):** pinned blob `findings/nx-r64z/dtrace/xpc-conformance/
    xpc-harness.c` git-blob `4b866b9f`, **sha256 `3b6197bd235e25e9cdebaecaab5562ad169c04c2febe3b024ddd2eb4427d3df6`**
    (matches report). 13 R()-cases. Recon CONFIRMED: serializer = FreeBSD nvlist (`subr_nvlist.c`/
    `subr_nvpair.c`, NOT Apple binary XPC); transport = `bootstrap_look_up` @ `xpc_connection.c:121`
    → **id-016 applies** (3rd service-client after notify/asl). **2 divergence candidates verified REAL +
    correctly OMITTED from the harness (lockstep linkability), cataloged not worked-around:**
    (1) `xpc_dictionary_set_data` (`xpc/xpc.h:2094`) + `get_data` (`:2323`) DECLARED, **zero `.c` impl** —
    genuine export gap; (2) `XPC_TYPE_*` macros = `&_xpc_type_*` extern-object address (`xpc.h:41` macro,
    `xpc_type.c:42` def) → FreeBSD LLD copy-reloc from `.so` (rx built with `-fno-PIE` as corroboration).
- raised: 2026-06-24 (next conformance subject after notify (id-010) + asl (id-011) both GREEN).
- roadmap parent: [roadmap.md](../roadmap.md) — **Gate B** (layer working + conformance-matched). libxpc
  is the XPC layer; the last/long-pole conformance subject.
- relations: **id-010/id-011** (notify/asl conformance siblings — both green, supply the R()-case harness
  pattern + dual-explorer methodology); **id-016** (bootstrap-ambient — libxpc is the **3rd** service-
  client reached via `bootstrap_look_up`, after notify+asl; probe-child path applies); **project XPC
  assessment** (NextBSD libxpc = Mach-native transport [good] + nvlist serialization = the fork:
  nvlist-vs-ravynos-mpack; classify-only pre-1.0); **test-pillar partition** (libxpc SPLITS: ABI/wire →
  Zig/C substrate; connection-lifecycle-as-Swift-uses → swift-testing, **Lane-B-gated on rmxOS Swift
  solid** → NOT in scope now).
- lane (when promoted): evidence-lane + parity-lane (dual-explorer); observation-first / classify-only.

## Scope (classification-only pre-1.0)

**In (substrate axis — probe-able now via C/Zig, like notify/asl):**
1. **Recon:** characterize the libxpc surface first-hand — the Mach-native transport, the **nvlist
   serialization** path (the nvlist-vs-mpack fork — which is in-tree, how messages are encoded on the
   wire), the connection/message object API; settle any service-ownership/bootstrap question (xpc reached
   via `bootstrap_look_up` → id-016 probe-child path, as notify/asl).
2. **Author a shared substrate harness** (C or Zig — NOT swift-testing, Lane-B-gated): xpc object
   create/encode/decode round-trip (nvlist wire), connection setup over Mach transport, send/reply.
   R()-case structured output (`name: PASS|FAIL`) like notify/asl.
3. **Dual-explorer conformance (leg 2, lockstep):** the pinned blob run UNMODIFIED on rx-x64z + mx-a64z,
   blob sha echoed both sides + Arranger-diffed = apples-to-apples; divergences cataloged (classify-only).

**Out (now):** the consumer/lifecycle axis (xpc_connection lifecycle as a Swift client uses it) →
swift-testing, Lane-B-gated on rmxOS Swift; any product-source fix (observation-first; divergences ladder);
the nvlist-vs-mpack *serialization-format decision* (classification feeds it, doesn't make it — XPC-assessment item).

## Truly-green criterion (when fully promoted, post-1.0-substrate)
- the substrate harness builds + runs on both explorers UNMODIFIED (single pinned blob, shas match);
- xpc object/nvlist round-trip + Mach-transport connection send/reply match macOS truth (or each laddered);
- (later/Lane-B) connection-lifecycle parity via swift-testing once rmxOS Swift is solid.

## Open decisions (Coordinator-held)
- serialization-format conformance depth: match macOS nvlist wire byte-for-byte vs behavior-only round-trip
  (lean behavior-only pre-1.0; the nvlist-vs-mpack fork is a separate XPC-assessment decision).
- whether libxpc conformance is even in 1.0 scope or strictly post-1.0 long-pole (lean: catalog now,
  fix post-1.0).
