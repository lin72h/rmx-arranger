# subsystem-cort — CoRT (Common Object Runtime, `os_object`) — C/Zig-first base

- subsystem: **CoRT** — the Common Object Runtime (Apple/libSystem `os_object`). The
  refcounted object base every Darwin libSystem object derives from.
- name: **"CoRT"** is our standing term (Coordinator, 2026-06-22), after Jordan Hubbard's
  NextBSD talk ("Common Object Runtime & libdispatch", ~23:57). In source it is the
  `os_object` layer — there is no module literally named CoRT.
- base (owned): inherited with libdispatch — **co-located in `lib/libdispatch`**, NOT a
  separate library. Files: `os/object.h`, `os/object_private.h`, `src/object.c` (C runtime),
  `src/object.m` (ObjC overlay), `src/object_internal.h`, `src/inline_internal.h`.
- decision: **ACCEPTED base + C/Zig-first directive** (Coordinator, 2026-06-22) — keep
  co-located (Apple-faithful); core default **`OS_OBJECT_USE_OBJC=0`** so the runtime stays
  pure-C and Zig-bindable.
- index: [subsystem.md](subsystem.md). Sits under [subsystem-libdispatch.md](subsystem-libdispatch.md)
  (physical home) and beneath [subsystem-libxpc.md](subsystem-libxpc.md) (a consumer).
  Verify file:line against the tree before acting (source moves).

## What CoRT is (from the NextBSD talk, mapped to source)

Hubbard's pitch: a **thread-safe environment for multi-core** by **bringing Objective-C's
low-level retain/release memory semantics to plain C-level objects**, so libdispatch (GCD) can
safely manage object lifetime across a dynamic, self-scaling worker pool instead of hand-rolled
POSIX threads. That mechanism is exactly the `os_object` layer in our tree:

- A refcounted object model (`os_retain`/`os_release`) applied to C structs via a vtable
  (`src/object.c`: `_os_object_alloc_realized`, `_os_object_retain/release`,
  `_os_object_xref_dispose`; fast-path inlines in `src/inline_internal.h`).
- The **shared base** under `dispatch_object_t`, `xpc_object_t`, `voucher_t`, and
  `os_object_t` itself — one retain/release model + one typed-handle (`*_t`) convention across
  **GCD and XPC**. That unification *is* "common." **(Caveat — verified 2026-07-02: in our tree
  this is true for the dispatch family but only type-deep for XPC — libxpc forks its own
  refcount. See "Consumer wiring" below.)**
- The **atomic** retain/release internals are the object-lifecycle half of the talk's
  thread-safety claim; the manager thread + TWQ workers are the scheduling half. Same
  subsystem, two halves.

## The key structural fact — C runtime is the base, ObjC is the overlay

`os/object.h:62-72` switches on `OS_OBJECT_USE_OBJC`:

- **`=0` → pure C.** `src/object.c` is the real runtime: vtable + atomic refcount, opaque
  typed handles, `os_retain`/`os_release` as plain C functions. No ObjC dependency.
- **`=1` → ObjC overlay.** `src/object.m` makes those same C objects *also* answer
  `-[retain]`/`-[release]`, join ARC, and enter Cocoa collections. This is the macOS default
  *because Apple has a modern ObjC runtime there* — it is an overlay **on top of** the C
  runtime, not a replacement for it.

So the C object model came first; ObjC is layered on for platforms that want it. **C-and-Zig
first is the original design intent, not a downgrade.** It also matches the libxpc layering
directive already on record (C rock-solid → skip ObjC → Swift).

## Decision — `OS_OBJECT_USE_OBJC=0` as the core default

1. **Build the core subsystems with `OS_OBJECT_USE_OBJC=0`.** Keeps CoRT pure-C — the clean,
   stable C ABI that is the binding contract for everything above it.
2. **Zig binds straight to that C ABI** — `@cImport` the `os/object.h` + per-type headers,
   `extern` `os_retain`/`os_release` and the typed handles. No ObjC shim to work around.
3. **The ObjC overlay stays off** in the core (consistent with libxpc "no NSXPCConnection").
   It is not deleted — it remains the optional Darwin-parity path — just not the core default.

## Co-location doctrine — document as a layer, do NOT factor out

CoRT physically lives in `lib/libdispatch`; on Darwin it is exported outward via libSystem. It
is **not** its own repo or `.dylib`, and that is the Apple/NextBSD shape.

- **Do not split CoRT into a standalone `libcort`/`libos_object`.** That is a structural
  divergence from the Apple layout — the "Linux-inward reshaping" the project doctrine forbids
  (Mach/Apple primitives *outward*). Least-intrusive precedence (`donor > XNU-ref > local`)
  applies: the donor co-locates, so we co-locate.
- **Treat CoRT as a *logical* subsystem, not a physical one.** This doc records the layering
  and the C/Zig-first decision; the source stays where Apple put it. First-class status comes
  from a clean, stable, documented C API surface — not from relocating directories.

## Verified first-hand (2026-06-22) — it is ALREADY pure-C, ObjC not linked

Confirmed against the tree, not inferred from Apple's design. The "does CoRT work as a C API
without ObjC?" question is settled **yes**, with three independent proofs:

1. **Refcount runtime is pure C.** `src/object.c` does retain/release as atomic ops on an int
   field — `dispatch_atomic_inc2o/dec2o(obj, os_obj_xref_cnt, relaxed)` (object.c:58,73),
   surfaced as `os_retain`/`os_release` + `dispatch_retain`/`dispatch_release`. No ObjC message
   send in the path.
2. **The ObjC toll-free bridge compiles to nothing.** Every `DISPATCH_OBJECT_TFB(...)` in
   object.c expands to an **empty macro** under `USE_OBJC=0` (object_internal.h:240) — the ObjC
   branch disappears at preprocess time.
3. **The build excludes ObjC entirely.** `Makefile` `SRCS` compiles `object.c`/`data.c`, **not**
   the `object.m`/`data.m` overlays (absent from SRCS). Flags `-DUSE_OBJC=0
   -DOS_OBJECT_USE_OBJC=0` (Makefile:16,18). Link line `LIBADD = BlocksRuntime mach thr sys`
   (Makefile:33) — **no `-lobjc`, no objc4**. ObjC is not just unused, it is not linked.

**The one real non-ObjC dependency: Blocks.** Build uses `-fblocks -D__BLOCKS__=1` and links
**BlocksRuntime** (in-tree at `contrib/llvm-project/compiler-rt/lib/BlocksRuntime/`). Blocks ≠
ObjC: a Clang closure extension with a tiny standalone ABI (`Block_layout` +
`_Block_copy`/`_Block_release` + `_NSConcreteStackBlock`/`Global`), satisfied by libBlocksRuntime
with zero ObjC. CoRT/dispatch needs BlocksRuntime, not objc4.

## Consumer wiring — verified first-hand (2026-07-02): transitive via dispatch, and libxpc forks the refcount

Who actually exercises CoRT, checked against the tree (canonical `wip-gpt/wip-rmxos`). Two clean facts + one divergence:

1. **Zero DIRECT `os_object` API use in any core service.** grep for `os_object`/`os_retain`/`os_release`/`OS_OBJECT`/`_os_object` across `lib/libnotify`, `lib/libasl`, `usr.sbin/notifyd`, `usr.sbin/asl` (asld), `usr.sbin/aslmanager`, `sbin/launchd` → **no matches**. None of the four core services call the runtime by hand.

2. **Heavy INDIRECT use via libdispatch objects.** The same dirs carry **386 `dispatch_*` calls across 32 files** (queues, sources, async, semaphores, `dispatch_mach`). Because the core builds `-DOS_OBJECT_USE_OBJC=0`, every `dispatch_queue_t`/`dispatch_source_t` those services create is a C-runtime `os_object`, and its retain/release/dispose flows through `src/object.c`. **So launchd, notifyd, asld, and the libnotify/libasl clients all exercise CoRT — transitively, through the dispatch object lifecycle, never the `os_object` API directly.** The CoRT hot path in production is dispatch-object churn, not hand-written `os_retain`.

3. **libxpc is the divergence — `xpc_object_t` is an os_object by TYPE, not by runtime.** `xpc/xpc.h` declares `xpc_object_t` via the `OS_OBJECT_DECL` machinery (11 refs) — so at the type/handle level it matches the shared model. **But the implementation forks its own refcount:** `xpc_misc.c:152-173` implements `xpc_retain`/`xpc_release` on a private `xo->xo_refcnt` (`atomic_add_int`/`atomic_fetchadd_int`), **not** `_os_object_retain`/`_os_object_release`. So libxpc's own objects do **not** bind to the CoRT runtime; libxpc touches CoRT only via the dispatch objects it uses for Mach transport.

**Fidelity gap (vs macOS / libSystem):** on Darwin `xpc_object_t` genuinely *is* an `os_object` sharing the runtime — `os_retain`/`os_release` work uniformly on dispatch and XPC handles, and that cross-family unification is load-bearing. In our tree the unification is skin-deep for XPC: the header type-declares it, but the refcount is a parallel `xo_refcnt`. Likely benign for single-library use; it bites any code that expects `os_retain(xpc_obj)` or cross-object-family `os_object` behavior. This is the concrete divergence the CoRT-testing entry (Open items) should target — capture the macOS os_object∪xpc unification as truth and diff rmxOS against it (an op-228 D4 candidate). Verified at source, not inferred (`verify_signature_divergence_claims`).

## Zig integration — two tiers

**Focused execution track:** [li-9006](../../l1i/li-9006.md) owns the generated rmxOS Dispatch
bindings, CoRT-lite `OwnedQueue`/`BorrowedQueue` lifetime wrappers, fixed-class `std.Io.Dispatch`
pilot, and Swift/C borrowed-queue bridge. “CoRT-lite” is a thin Zig wrapper over this co-located C
runtime, never a new library or relocation. [id-039](../../idq/id-039-zig-io-dispatch-rmxos-cort-integration.md)
is the decoded, WAITING audit-first seed; it authorizes no package/product work until the
Coordinator names the Zig executor/repository and the shared `dispatch_activate` path is settled.

**Tier 1 — works today, zero blocks, zero ObjC.** The dispatch C API ships function-pointer
(`_f`) twins for essentially every block entry point — confirmed on our headers:
`dispatch_async_f` (queue.h:133), `sync_f` (199), `after_f` (752), `apply_f` (265),
`barrier_async_f`/`sync_f` (833/892), `once_f` (once.h:78), `group_async_f`/`notify_f`
(group.h:120/230), `source_set_event/cancel/registration_handler_f` (source.h:404/463/738).
Each takes `void *context, dispatch_function_t function` (a plain `void (*)(void*)` + ctx). Zig
binds via `@cImport` + `extern`, passing `fn(?*anyopaque) callconv(.c) void` + a context
pointer; CoRT `os_retain`/`os_release` are trivial externs. **The whole core is drivable from
Zig now with no blocks and no ObjC** — and this is the macOS-faithful low-level surface, so it
is the first-class C+Zig base.

**Tier 2 — ergonomic Zig closures via Blocks (optional).** To pass a Zig closure where the API
wants a block (or use block-only calls like `dispatch_block_create`), Zig synthesizes a Block
literal (`Block_layout` struct + link the already-linked BlocksRuntime). Reference points:
- **Vexu/arocc PR 971 (native block support)** — aro is Zig's C frontend behind
  `translate-c`/`@cImport`; today it can't represent `^` block syntax (block-param decls get
  dropped — which is *why* Tier-1 uses `_f`). This PR is the path to `@cImport` parsing
  block-shaped decls natively. Track it; don't depend on it yet.
- **mitchellh/zig-objc** — use ONLY as a Block-literal *layout reference*, **not a dependency**:
  it pulls toward the ObjC runtime we exclude. Take the blocks half, leave the ObjC half.

**Directives:** (1) bind Tier-1 now; (2) treat Blocks as an ergonomic layer over BlocksRuntime,
not a requirement; (3) hold the line — **no objc4** (the build already proves it is unnecessary).

## Fit with the roadmap

- CoRT is **foundation shared by libdispatch AND libxpc** — both bind to its retain/release +
  typed-handle model. Hardening it is hardening both at once; its C ABI must stay **STABLE**.
- It is the natural seam for the **first-class C + Zig API** goal across the core subsystems:
  the C backend is already locked (`USE_OBJC=0`); expose a complete/stable surface, bind Zig.
- The Swift track (later, per the libxpc layering) sits *above* this, on the same C base.

## Open items (verify when binding)

- Enumerate the **block-only APIs with no `_f` twin** (e.g. `dispatch_block_create`, some
  io/data handlers) — the exact set where Tier-2 (Block synthesis) is mandatory vs optional.
- Confirm `translate-c`/`@cImport` behavior on the block-param decls on our header set (expected:
  silently dropped → bind via `_f` or hand-written externs until arocc PR 971 lands).
- Decide whether CoRT warrants its own testing entry (atomic-refcount / lifecycle invariants)
  layered on the shared DTrace-first baseline. **Concrete first target (from the 2026-07-02
  consumer-wiring finding): the libxpc `xo_refcnt` vs `os_object` divergence** — a conformance
  probe that asserts the macOS os_object∪xpc unification (`os_retain`/`os_release` uniform across
  dispatch and XPC handles) and shows where rmxOS's forked refcount breaks it. Natural op-228 D4
  candidate.
- **cort refcount base is CLEARED but has one production-silent residual (op-244, 2026-07-02).**
  The base matches canonical dispatch-500.x and is locally UNMODIFIED since vendor import
  7f9f2a5ff50b (zero post-import commits to object.c/object_internal.h/inline_internal.h/init.c) —
  no unbalanced retain/release found on the MACH_RECV path. BUT the "release while external
  references exist" (internal-count underflow) guard is checked ONLY under `DISPATCH_DEBUG`
  (inline_internal.h:119-123). In a production (non-DISPATCH_DEBUG) build, one unbalanced
  `_dispatch_release` = silent early dispose = UAF with no crash at the release site. Not a live
  defect today; it is the *failure mode* any future unbalanced release would take. A cort
  conformance/invariant probe (above) should assert this underflow guard fires. Full context:
  rmx-oracle/op-244-cort-lifetime-findings.md §1/§R4.
