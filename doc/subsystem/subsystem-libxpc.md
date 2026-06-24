# subsystem-libxpc — base/lineage decision (NextBSD libxpc, classification-only pre-1.0)

- subsystem: libxpc (Apple's low-level C XPC IPC framework — Mach + libdispatch + bootstrap)
- base candidate (owned): NextBSD `libxpc` — `nx/NextBSD/lib/libxpc` (nvlist-backed)
- comparison candidate: ravynos `libxpc` — `nx/ravynos-darwin/Libraries/Libsystem/libxpc`
  (MessagePack + transports abstraction)
- decision: **CLASSIFICATION-ONLY (pre-1.0)** — source assessment to steer XPC strategy, NOT
  an implementation commitment. Base is credible; the serialization fork is still open.
- index: [subsystem.md](subsystem.md). Deep first-hand assessment:
  [xpc-libxpc-assessment.md](../../xpc-libxpc-assessment.md).
  Verify file:line against the tree before acting.

## Why this exists

XPC is built ON TOP of Mach messages + libdispatch + bootstrap/launchd — exactly the stack
this project is building. So libxpc is the consumer that integration-tests our whole Mach
foundation. The base question: own NextBSD's nvlist libxpc, or the more modern ravynos one.

## NextBSD libxpc — verdict: credible base, not a skeleton

~6.3k lines: `xpc_array.c`, `xpc_dictionary.c`, `xpc_connection.c`, `xpc_type.c`,
`xpc_misc.c`, plus the FreeBSD nvlist backing (`subr_nvpair.c`, `subr_nvlist.c`).

- **Transport: Mach-native and correct (the hard part, already right).** `xpc_connection.c`
  uses the Apple-shaped stack: `mach_port_allocate(MACH_PORT_RIGHT_RECEIVE)` +
  `MACH_MSG_TYPE_MAKE_SEND`; `bootstrap_check_in`/`bootstrap_look_up` for service
  registration/lookup; `dispatch_source_create(DISPATCH_SOURCE_TYPE_MACH_RECV, …)` to receive.
  It rides **Mach IPC + bootstrap/launchd + libdispatch MACH_RECV** — the layers we build and
  harden. The architecturally hard choice (Mach transport) is already made correctly.
- **Object model: complete.** All 16 standard XPC types in `xpc_type.c`.
- **Maturity: moderate, not stubbed.** Low stub density (a few `/* XXX */`, one `#if 0`); the
  `abort()`s are its own assertion macros, not unimplemented paths.
- **API surface: pure C (the low-level XPC C API), no Objective-C.** Canonical Apple C surface
  (`xpc_object_t`, `xpc_dictionary_*`, `xpc_connection_*`); async uses Clang blocks +
  libdispatch (needs a BlocksRuntime). No `NSXPCConnection` (that's Foundation/ObjC, a higher
  layer — out of scope).

## The significant divergence — serialization is FreeBSD nvlist, not Apple wire

~4k of the ~6.3k lines are the nvlist backing store. It serializes XPC objects as **nvlist
over Mach messages** — self-consistent on our stack, but **NOT wire-compatible with macOS XPC
services** (a NextBSD-libxpc client can't talk to a real macOS XPC service). A pragmatic
stepping-stone (FreeBSD already had nvlist) — the class of intermediate decision to re-examine
rather than inherit blindly.

## ravynos libxpc — the modern alternative

MessagePack (`mpack.c`) serialization, a `transports/` abstraction, examples/python bindings,
CMake. Actively maintained Darwin-compat OS, so likely better-tended; still not
Apple-wire-compatible, but a cleaner transport-abstracted design.

## Layering directive (Coordinator, 2026-06-16) — skip the ObjC middle

1. **C libxpc — make ROCK-SOLID.** The foundation layer that rides Mach. Ours to own/harden.
2. **No Objective-C API at all.** `NSXPCConnection` / Foundation XPC explicitly excluded.
3. **Best Swift XPC API "as macOS", later**, built ON TOP of the rock-solid C API (modern
   Swift-native `XPCSession`/`XPCListener` style), via a separate Swift-FreeBSD agent.

Stack: **C (ours, rock-solid) → [skip ObjC] → Swift (integrated)** — matching Apple's own
direction (XPC is going Swift-native; ObjC NSXPCConnection is legacy). The C API must expose a
**clean, complete, STABLE** surface — it's the binding contract the Swift layer depends on.
"as macOS" = developer-facing API **parity/quality**, NOT binary wire-interop with real macOS
XPC services.

## The strategic fork — serialization (decide when XPC goes active)

Wire-interop is off the table, so the Apple-native-wire option drops. Choose between:
1. **nvlist** (NextBSD) — works, in-tree, mature FreeBSD-ism.
2. **MessagePack** (ravynos) — cleaner, transport-abstracted, actively maintained.

Deciding criterion: **which yields the most robust, maintainable, rock-solid C
implementation** — since neither targets macOS wire compat and the Swift layer binds to the C
API regardless of the serialization beneath it.

## Fit with the roadmap

- **classification-only pre-1.0:** NextBSD libxpc is good enough to *classify against* —
  document how XPC maps onto our Mach foundation (connection → bootstrap → MACH_RECV source →
  message shapes) without committing to its serialization. This de-risks XPC and validates that
  our Mach/dispatch/bootstrap layers expose what XPC needs.
- **dependency chain (already ours):** XPC needs Mach IPC (building), libdispatch MACH_RECV
  sources, bootstrap/launchd handoff (Phase 0.85). XPC is the consumer that integration-tests
  all three — a post-foundation capstone, not a parallel track.
- **serialization is a post-1.0 "improve" decision** — nvlist vs ravynos-mpack, chosen
  deliberately when XPC goes active.

## Open items (verify when XPC goes active)

- Connection lifecycle depth in `xpc_connection.c` (467 lines is modest): reply, error events,
  cancellation, activation — not yet verified depth-first.
- ravynos vs NextBSD connection-semantics + transports comparison.
- The MACH_RECV path libxpc rides is the same one parked in `id-003` (kernel
  `filt_machport`) — XPC's Mach-receive depends on that kernel gap eventually closing.
