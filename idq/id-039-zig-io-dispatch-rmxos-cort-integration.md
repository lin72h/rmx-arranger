# id-039 — Zig `std.Io.Dispatch` on rmxOS: generated bindings, CoRT lifetimes, and shared scheduling

- id: **id-039**
- state: **WAITING — design banked under li-9006; post-preview/non-gating.** No package/product or
  ROB op is authorized. Coordinator must name the Zig-side executor and writable package
  repository, and the shared native `dispatch_activate` gap must be dispositioned first.
- raised: 2026-07-11 (Arranger2 adjudication of the unnumbered Oracle design note plus op-003m/
  op-004m read-only catchup review).
- primary L1i: **li-9006** (Zig `WorkClass` → canonical Dispatch/TWQ queues).
- relations: **subsystem-cort**, **li-9005** (shared QoS/activation substrate), **li-9003**
  (TWQ attribution/QoS), **li-1002 / id-006** (native Dispatch), **li-1012** (provenance),
  **li-9001 / id-038** (Swift/C borrowed-queue bridge sibling).

## SOURCE RECORD AND ADJUDICATION

Banked Oracle note:

`/Users/me/wip-mach/rmx-oracle/zig-cort-dispatch-integration-design.md`

- SHA-256: `5f40eecbeaf6bb11668ad5cfe8ea5c20a8da2ce829e1d522d66047c1de39103b`
- length: 160 lines
- verdict: **DESIGN-BANKED / PREP-SUFFICIENT with corrections**.

The central proposal is retained: use Zig's injected I/O interface and existing Dispatch-backed
implementation through an rmxOS-owned package, keeping native libdispatch as the sole process-wide
workqueue owner. The note's stronger “only target gates”/small fixed adaptation-set framing is not
accepted as fact. op-003m read only the head; op-004m performed a symbol-class census but explicitly
did not complete a sequential full-file read. Arranger first-hand review corrected several claimed
FreeBSD gaps because Zig already has reusable BSD implementations. Any implementation begins with
a fresh complete audit of the pinned source, not a predeclared six-site patch.

## VERIFIED BASELINE

li-9006 pins the current facts at Zig `0.16.0@44d9672f` and then-current master `e4b325c1`:

- `std.Io` is injected through a VTable; async/concurrent carry no portable priority parameter.
- upstream ships `Io.Dispatch` with a caller-provided `target_queue`.
- FreeBSD's automatic `Io.Evented` provider remains Kqueue; Dispatch is not the default.
- x86_64 fiber support is already true; it is not the initial unknown.
- the Dispatch provider relies on function-pointer APIs and `dispatch_activate`.
- network operations in the pinned provider are unavailable.
- the snapshot allocates roughly 60 MiB-plus per fiber and requires explicit measurement.
- native rmxOS lacks `dispatch_activate`; one shared product closure must serve Swift and Zig.
- copied Darwin constants are unsafe (`LOW=-1` upstream binding versus rmxOS `LOW=-2`).

The portability audit must reuse rather than duplicate Zig's existing BSD paths where applicable:
BSD dirent iteration, `F.KINFO` fd-path handling, and `KERN_PROC_PATHNAME` executable-path logic are
already present elsewhere in std. Darwin-signature `sendfile` and `fcopyfile` paths require
compile-time OS selection or replacement. `std.c.dispatch` remains Darwin-gated, so the package
needs rmxOS-native generated/verified bindings rather than importing the Darwin namespace.

## ARCHITECTURE CONTRACT

```text
Zig WorkClass / borrowed target queue
  → one canonical named queue mapping
  → rmx.Io.Dispatch
  → native rmxOS libdispatch
  → pthread_workqueue / TWQ
```

- Five concrete semantic classes plus `.inherit`; no public numeric Dispatch/pthread encoding.
- `.inherit` is distinct from forced default and consumes an explicit ambient/borrowed contract.
- Native libdispatch owns `_pthread_workqueue`; Zig never initializes TWQ directly and never loads
  a second libdispatch.
- `OwnedQueue` and `BorrowedQueue` are thin CoRT lifetime wrappers over the co-located C runtime,
  not a new library or ObjC layer.
- Swift/C passes a borrowed `dispatch_queue_t` or a validated semantic C enum, never
  `TaskPriority.rawValue`.

## DECODED EXECUTION LADDER

### P0 — complete portability audit + native package surface

- Pin the Zig revision and read `Io/Dispatch.zig` completely.
- Inventory every OS-conditioned call and map it to reuse, compile-time selection, replacement, or
  an explicit unsupported case; no fixed patch count is assumed.
- Generate/check rmxOS Dispatch bindings from the exact linked headers; use named QoS and `_f`
  APIs and include the legacy-LOW mismatch as a negative fixture.
- Implement/test `OwnedQueue`/`BorrowedQueue` lifetime rules without ObjC or Blocks.
- Consume and genuinely exercise the shared native `dispatch_activate` implementation.

### P1 — fixed-class `rmx.Io.Dispatch` pilot

- Instantiate one provider against one chosen target queue; test all five concrete classes and
  `.inherit` independently.
- Exercise Future/Group, async/concurrent, timer/sleep, cancellation, mutex/futex, and teardown.
- Pin engine attribution and prove the intended TWQ lane for every concrete class.
- Measure one/two/N-fiber resident and virtual memory against a frozen laboratory ceiling.
- Treat unavailable networking as an expected negative; never count it as coverage.

### P2 — borrowed-queue bridge

Pass a named Swift/C target queue into Zig. Prove balanced promotion of borrows across async work,
host teardown, cancellation, late callbacks, and multiple Zig instances sharing native Dispatch.

### P3 — differential conformance

Explorer authors a supported-contract Future/Group/timer/cancellation workload in
`rmx-explorer`; Gatekeeper separately registers/runs it in `rmx-gatekeeper`. Compare Apple and
rmxOS observable semantics and retain engine/TWQ traces. Do not merge those repository writes.

### P4 — later priority/escalation work

Per-operation class propagation must survive every resume, timer/source wake, wait, cancellation,
group, and child path. It waits on real thread-QoS/override work and a separate design/evidence
gate; it is not part of P0/P1.

## FETCH GATES

1. Coordinator names the Zig executor and writable package repository; `nx/zig-master` stays
   read-only upstream source.
2. Native `dispatch_activate` has one accepted product design/implementation path shared with
   li-9005.
3. Pinned full-file portability audit and generated-binding plan are reviewed before edits.
4. Repository ownership is split explicitly for package, Explorer content, Gatekeeper evidence,
   and native product changes.

## BOUNDARIES

- Do not switch FreeBSD's default provider from Kqueue.
- Do not fork `Io.VTable`, add per-operation priority, copy Darwin magic constants, require
  ObjC/Blocks, initialize TWQ directly, or claim networking support.
- No package location is invented by this ID; `/Users/me/wip-mach/nx/zig-master` is read-only.
- This is a decoded design seed only. The Coordinator fetches it into fresh ops when gates clear.
- feedback: `verify-premise-before-mechanism`, `verify_signature_divergence_claims`,
  `artifact_identity_needs_content_check`, `agent_host_isolation`, `build_is_implementer`,
  `no_conflate_gating_with_readiness`, `verdict_labeling_model_honest`.
