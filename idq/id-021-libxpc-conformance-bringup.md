# id-021 — libxpc: CORE preview service (li-002) — conformance substrate + "get it right" (Coordinator 2026-06-24)

- id: id-021
- **ELEVATION (Coordinator, 2026-06-24): libxpc is no longer "classification-only pre-1.0" — it is a CORE
  preview service alongside launchd/libnotify/asl, all riding {libdispatch, mach-ipc}. Directive: "make
  NextBSD's libxpc and launchd work to meet our preview quality… get it right both libxpc and launchd."
  nvlist serialization is LOCKED (ravynos-mpack fork rejected); the serialization fork is CLOSED.** This
  changes the DESTINATION (core preview quality, not catalog-then-defer) but NOT the depth-first ordering:
  notify (id-010) + asl (id-011) still close their truly-green legs first.
  **Two-plane finding (Arranger first-hand 2026-06-24): control plane (launchctl→launchd) = liblaunch/Mach/MIG,
  NOT XPC (unlike macOS); service plane (launchd xpc_domain hosting + app xpc_connection) = libxpc/nvlist =
  the long pole.** FIRST move when un-held: a free-Explorer runtime probe — "is launchd's xpc_domain service
  path LIVE end-to-end over nvlist, or stubbed?" — to calibrate how much libxpc we already have.
- state: **leg 1 DONE (op-121 `ec25e50`, Arranger-verified first-hand) → leg 2 = op-122 RESERVED but HELD
  (Coordinator depth-first directive 2026-06-24: make id-010 notify + id-011 asl *truly-green/solid*
  BEFORE opening the libxpc work).** Leg 2 dispatch text (lockstep dual-explorer run of pinned blob
  `3b6197bd…` on rx-x64z+mx-a64z, echo+diff sha) is authored + reserved as op-122; resumes once notify+asl
  soak/li-003 legs (op-123/op-124) retire. Op number not reused. First conformance op in the **lockstep
  dual-explorer dispatch shape** (see the Parity-Explorer memory / the op-116 lesson): leg 1 =
  author-once-and-pin (DONE); leg 2 = both explorers run the pinned blob UNMODIFIED + echo blob sha
  (Arranger diffs = apples-to-apples gate). Core preview service, depth-first-after-notify/asl —
  Coordinator-holdable, free-Explorer, parallel non-blocking.
  - **leg 1 verified (Arranger, first-hand):** pinned blob `findings/nx-r64z/dtrace/xpc-conformance/
    xpc-harness.c` git-blob `4b866b9f`, **sha256 `3b6197bd235e25e9cdebaecaab5562ad169c04c2febe3b024ddd2eb4427d3df6`**
    (matches report). 13 R()-cases. Recon CONFIRMED: serializer = FreeBSD nvlist (`subr_nvlist.c`/
    `subr_nvpair.c`, NOT Apple binary XPC); transport = `bootstrap_look_up` @ `xpc_connection.c:121`
    → **id-016 applies** (3rd service-client after notify/asl). **2 divergence candidates verified REAL +
    correctly OMITTED from the harness (lockstep linkability), cataloged not worked-around:**
    (1) `xpc_dictionary_set_data` (`xpc/xpc.h:2094`) + `get_data` (`:2323`) DECLARED, **zero `.c` impl** —
    genuine export gap; (2) `XPC_TYPE_*` macros = `&_xpc_type_*` extern-object address (`xpc.h:41` macro,
    `xpc_type.c:42` def) → FreeBSD LLD copy-reloc from `.so` (rx built with `-fno-PIE` as corroboration).
  - **DIVERGENCE CENSUS EXPANDED (Arranger first-hand 2026-06-24, full list in
    [li-007](../l1i/li-007-libxpc-core-service.md)):** diffed all 134 header decls vs 119 `.c` defs. Three
    classes — A architectural (nvlist wire; control-plane), B declared-but-zero-impl (15+ symbols:
    **entire `xpc_activity_*` subsystem header-only**; typed dict get/set for double/date/data/uuid/fd/
    connection; `xpc_shmem_create`/`map`; `xpc_fd_create`/`dup`; `xpc_copy`; `xpc_service_main`/
    `set_event_stream_handler`; `get_egid`; misc), C defined-but-stub (`xpc_connection_cancel` empty,
    `xpc_endpoint_create` empty/no-return, `set_finalizer_f`/`xpc_main`/`transaction_begin`/`end` no-ops,
    `get_name`="unknown", no `XPC_ERROR_*` delivery). The set_data/get_data + XPC_TYPE items above fold
    into Class B/the existing catalog.
  - **op-135 DONE/RETIRED (explorer-mx authored macOS reference + Arranger completed the join first-hand,
    2026-06-24).** Source: `MacOSX.sdk/usr/lib/system/libxpc.tbd` = 802 exported symbols (dylib is
    shared-cache-only on macOS 27 → `.tbd` is the linker-authoritative `nm -gU` equivalent — the op's
    `/usr/lib/.../libxpc.dylib` path doesn't exist, explorer correctly substituted). Evidence (rmx-explorer
    `ffddfce`, Arranger-fetched+verified): `findings/mx-a64z/dtrace/xpc-conformance/macos-truth-surface.md`
    (sha256 `9ddf1199…34b8`) + `libxpc-macos-exports.txt` (sha256 `5537e7bd…2d99`). **Join result (full in
    [li-007](../l1i/li-007-libxpc-core-service.md)):** Class-C all 7 stubs = real Apple API (genuine gaps);
    Class-B 29/33 real, 4 non-exported (`xpc_debugger_api_misuse_info`/`object_validate`/`service_main`/
    `unreachable` → macro/inline or cruft, not a link-level gap); **NEW Class-D = a whole API generation
    missing** (`xpc_session_*` ×16, `xpc_listener_*` ×10, `rich_error`, `peer_requirement`,
    `connection_activate`; activity is 20 symbols not 7) — our tree is legacy `xpc_connection`/`resume` only.
    Class-D shapes the swift-rmxOS XPCSession/XPCListener plan. li-007 was not in the explorer repo so the
    join ran here (not ferried). Op number not reused.
- raised: 2026-06-24 (next conformance subject after notify (id-010) + asl (id-011) both GREEN).
- roadmap parent: **[l1i/li-007-libxpc-core-service.md](../l1i/li-007-libxpc-core-service.md)** (promoted
  2026-06-24 out of the li-002 layer-bundle into its own dedicated L1i milestone — libxpc is a core preview
  service, the C-side IPC fabric). id-021 is li-007's IDQ carrier.
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

## Decisions (Coordinator, settled 2026-06-24)
- **serializer = nvlist, LOCKED** (ravynos-mpack rejected; fork CLOSED — was the standing XPC-assessment open item).
- **in scope: libxpc is a CORE preview service** (not "catalog now, fix post-1.0") — bring it to preview quality
  depth-first after notify/asl close.
- remaining (depth-only, not scope): wire conformance bar — match macOS nvlist wire byte-for-byte vs
  behavior-only round-trip (lean behavior-only for the preview).
