# libxpc Assessment — NextBSD vs ravynos (XPC strategy, classification-only pre-1.0)

Status: living Arranger findings (workspace). Classification-only pre-1.0 per the
Coordinator's strategic-interview decision — this is a source assessment to steer
XPC strategy, NOT an implementation commitment. Promote to wip-gpt doctrine when
XPC goes active. Verify file:line against the tree before acting (source moves).

## Scope

Assess the quality of NextBSD's `libxpc` as a starting point for XPC on our
Mach-IPC foundation, and identify the strategic forks. XPC is Apple's IPC
framework built ON TOP of Mach messages + libdispatch + bootstrap/launchd — i.e.
it sits atop exactly the stack this project is building.

## Sources in tree

- `nx/NextBSD/lib/libxpc` (== `nx/NextBSD-NextBSD-CURRENT/lib/libxpc`, identical):
  the nvlist-backed reimplementation assessed below.
- `nx/ravynos-darwin/Libraries/Libsystem/libxpc`: a DIFFERENT, more modern
  lineage (MessagePack serialization + a transports abstraction). The
  comparison candidate.

## NextBSD libxpc — verdict: credible base, not a skeleton

File set (~6.3k lines): `xpc_array.c` (325), `xpc_dictionary.c` (452),
`xpc_connection.c` (467), `xpc_type.c` (476), `xpc_misc.c` (543), plus the
FreeBSD nvlist backing `subr_nvpair.c` (1505) + `subr_nvlist.c` (2571).

### Transport: Mach-native and correct (the hard part, already right)

`xpc_connection.c` uses the Apple-shaped stack:
- `mach_port_allocate(..., MACH_PORT_RIGHT_RECEIVE, ...)` (:73) + insert
  `MACH_MSG_TYPE_MAKE_SEND` (:80) — real Mach ports.
- `bootstrap_check_in` (:104) / `bootstrap_look_up` (:121) — service
  registration + lookup through bootstrap/launchd.
- `dispatch_source_create(DISPATCH_SOURCE_TYPE_MACH_RECV, conn->xc_local_port, ...)`
  (:186-190) — receives via a libdispatch MACH_RECV source.

This is the decisive good news: libxpc rides **Mach IPC + bootstrap/launchd +
libdispatch MACH_RECV** — exactly the layers we are building and hardening
(N2 exercised the dispatch MACH sources; Phase 0.85 is the launchd handoff). It
is a genuine foundation exerciser, and the architecturally hard choice
(Mach transport) is already made correctly.

### Object model: complete

Full XPC type surface in `xpc_type.c`: ARRAY, BOOL, CONNECTION, DATA, DATE,
DICTIONARY, DOUBLE, ENDPOINT, ERROR, FD, INT, NULL, SHMEM, STRING, UINT, UUID
(all 16 standard types).

### Maturity: moderate, not stubbed

Low stub density — a few `/* XXX */` (`xpc_array.c:297,304`, `xpc_type.c:313`)
and one `#if 0` (`xpc_dictionary.c:296`). The `abort()`s in the nvlist files are
its own assertion macros (`PJDLOG_ABORT`), not unimplemented paths. A real
implementation with rough edges, not a placeholder.

### API surface: C only (the low-level XPC C API), no Objective-C

NextBSD libxpc is a pure **C API** — no `.m` files, no `@interface`/`NSObject`/
`#import`. Public header `lib/libxpc/xpc/xpc.h`; signatures are the canonical
Apple C surface (`xpc_object_t`, `xpc_dictionary_*`, `xpc_array_*`,
`xpc_connection_create`/`_create_mach_service`/`_set_event_handler`/
`_send_message`/`_send_message_with_reply[_sync]`/`_suspend`/`_resume`/`_cancel`/
`_get_pid`/`_euid`/`_guid`). Async surface uses Clang blocks + libdispatch
(`dispatch_queue_t`, handlers) — C-with-blocks (needs a BlocksRuntime), NOT
Objective-C.

The Objective-C XPC API is **`NSXPCConnection`**, which lives in **Foundation**,
not libxpc — a higher-level layer built ON TOP of this C API. NextBSD libxpc is
the bottom (Mach-riding) layer and does NOT provide NSXPCConnection. That would
require a Foundation implementation (GNUstep / libobjc2-class effort) — a
separate, much larger undertaking tied to the Swift/Foundation story, out of
scope for the Mach-foundation work and likely pre-1.0 entirely.

Scoping consequence: the C libxpc is the layer that exercises our Mach
foundation (classify + eventually stand up); NSXPCConnection is a distant
ObjC/Foundation epoch two layers up, not a foundation exerciser.

### The significant divergence: serialization is FreeBSD nvlist, not Apple wire

~4k of the ~6.3k lines are the nvlist backing store; the XPC types wrap it. It
serializes XPC objects as **nvlist over Mach messages** — self-consistent on our
stack, but **NOT wire-compatible with macOS XPC services**. A NextBSD-libxpc
client cannot talk to a real macOS XPC service. This was a pragmatic
stepping-stone choice (FreeBSD already had nvlist) — exactly the class of
intermediate decision the project's "preserve but improve" philosophy says to
re-examine rather than inherit blindly.

## ravynos libxpc — the modern alternative

`nx/ravynos-darwin/Libraries/Libsystem/libxpc`: uses **MessagePack
(`mpack.c`/`mpack.h`)** for serialization, has a **`transports/`** abstraction,
`examples/`, `python/` bindings, CMake build. ravynos is an actively-maintained
Darwin-compat OS, so this lineage is likely better-tended. Still not
Apple-wire-compatible, but a cleaner, transport-abstracted design.

## Layering directive (Coordinator, 2026-06-16)

Two layers, skip the ObjC middle:
1. **C libxpc — make ROCK-SOLID.** The foundation layer that rides Mach. Ours to
   own and harden.
2. **No Objective-C API, at all.** `NSXPCConnection` / Foundation XPC is
   explicitly excluded — not built.
3. **Best Swift XPC API "as macOS", later, via a separate Swift-FreeBSD agent's
   effort**, built ON TOP of the rock-solid C API (modern Swift-native XPC,
   `XPCSession`/`XPCListener`-style). Cross-agent integration, later stage.

So the stack is **C (ours, rock-solid) → [skip ObjC] → Swift (integrated)**. This
matches Apple's own direction (XPC is going Swift-native; ObjC NSXPCConnection is
the legacy layer). The C API must therefore expose a **clean, complete, STABLE
surface** — it's the binding contract the Swift layer depends on.

Interpretation of "as macOS": developer-facing API **parity/quality** with
macOS's Swift XPC, on our FreeBSD/Mach stack — NOT binary wire-interop with real
macOS XPC services. (Confirm if wrong.)

## The strategic fork: serialization (now two-way)

With wire-interop off the table (above), the Apple-native-wire option drops:
1. **nvlist** (NextBSD) — works, in-tree, mature FreeBSD-ism.
2. **MessagePack** (ravynos) — cleaner, transport-abstracted, actively maintained.

Decide by **which yields the most robust, maintainable, rock-solid C
implementation** (the rock-solidity directive is the deciding criterion), since
neither targets macOS wire compat and the Swift layer binds to the C API
regardless of the serialization beneath it.

## Fit with the roadmap

- **classification-only pre-1.0:** NextBSD libxpc is good enough to *classify
  against* — document how XPC maps onto our Mach foundation (connection setup ->
  bootstrap -> MACH_RECV source -> message shapes) without committing to its
  serialization. That classification de-risks XPC and validates that our
  Mach/dispatch/bootstrap layers expose what XPC needs.
- **dependency chain (already ours):** XPC needs Mach IPC (building), libdispatch
  MACH_RECV sources (N2-exercised), and bootstrap/launchd handoff (Phase 0.85).
  XPC is the consumer that integration-tests all three — a post-foundation
  capstone, not a parallel track.
- **serialization is a post-1.0 "improve" decision** — choose nvlist vs
  ravynos-mpack (vs Apple-native) deliberately when XPC goes active.

## Recommendation

Treat NextBSD libxpc as the **classification reference for the XPC->Mach
mapping**, and keep ravynos's libxpc on the table as the serialization/transport
comparison. The pre-1.0 deliverable is a classification artifact — "how XPC rides
our foundation, the serialization fork, what XPC requires from
Mach/dispatch/bootstrap that we must guarantee" — not an implementation.

## Open items (verify when XPC goes active)

- Connection lifecycle completeness in `xpc_connection.c` (467 lines is modest):
  reply, error events, cancellation, activation — not yet verified depth-first.
- ravynos vs NextBSD connection-semantics and transports comparison.
- Confirm the macOS-wire-interop question (collapses the serialization fork).
