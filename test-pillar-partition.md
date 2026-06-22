# Test-Pillar Partition — Elixir / Zig / swift-testing (long-run doctrine)

Status: Arranger doctrine (workspace, living). Extends the existing `test-plan.md`
(Elixir high-level / Zig low-level / keep C) with the long-run three-pillar split for
the explorer parity track. Aligns to `explorer-parity-cycle-workflow.md`.

## Premise: two targets only, both Swift-native

We target **only rmxOS and macOS**. No Linux, no portability tax. Consequence: we are
NOT forced into portable-C choices to keep tests running on a third platform. Both
targets are Swift-native (macOS first-class; rmxOS once its Swift runtime solidifies),
so **swift-testing is a first-class long-run pillar, not a niche.** This is the
simplification dropping other platforms buys us.

## The model: 2 PROBE tiers + 1 ORCHESTRATION tier (not 3 peers)

The common "three pillars" framing is slightly wrong. It's really:

- **Two PROBE tiers**, split by what's under test:
  - **Zig** — the LOW tier: C-like / system-C / ABI / syscalls / Mach traps / struct &
    wire layout / port ops. No runtime, close to metal, one source runs mechanically on
    both targets.
  - **swift-testing** — the HIGH tier: Swift code itself, **C++ and the Swift↔C++ interop
    boundary** (Swift's C++ interop is first-class; Zig treats C++ as opaque), and
    high-level macOS **system-integration** behavior as a developer consumes it
    (Dispatch/XPC/Foundation/os_log/launchd APIs). Modern `import Testing`, not XCTest.
- **One ORCHESTRATION tier** above both:
  - **Elixir** — drives runs, sequences multi-step scenarios, soak / long-running /
    lifecycle control, captures env, normalizes, diffs vs the macOS-27 reference,
    classifies, owns the `findings/nx-r64z` ledger. **Replaces fragile shell harness**
    (the CRLF / shell-validator false-negatives we hit in N2 are exactly why). Elixir is
    NOT a peer probe language — it's the conductor that invokes the probes.

Two axes decide the probe tier: **abstraction level** (low C/ABI → Zig; high API →
swift-testing) and **language affinity of the code under test** (C → Zig; C++/Swift →
swift-testing). Orchestration is a cross-cut, always Elixir.

## Steady-state partition (long run, after rmxOS Swift runtime is solid)

| Under test / concern | Pillar | Why |
|---|---|---|
| Swift code (XPCSession/XPCListener, Swift Foundation use, concurrency) | swift-testing | native, idiomatic |
| C++ code + Swift↔C++ interop boundary | swift-testing | Swift C++ interop first-class; Zig can't |
| High-level macOS system-integration behavior (Dispatch/XPC/Foundation/os_log/launchd as consumed) | swift-testing | macOS exposes these natively to Swift; richest fidelity |
| C ABI / syscalls / Mach traps / struct & message wire / port ops | Zig | no-runtime, dual-target, C-ABI mastery |
| System-C substrate behavior (libmach primitives, kernel/compat surface, notifyd wire) | Zig | C-like, low-level, substrate |
| Orchestration, multi-step scenarios, soak/long-running, lifecycle, comparator + ledger | Elixir | OTP supervision/fault-tolerance/stateful control; replaces shell |

## Principled invariants (these resolve the boundary cases)

1. **Zig is PERMANENT for the substrate — swift-testing NEVER replaces it there.** You
   cannot validate the floor with a tool standing on it: swift-testing runs ON the Swift
   runtime, which runs ON libdispatch + Mach IPC. So Mach IPC, libdispatch-C internals,
   the C ABI, and the syscall/trap layer stay Zig-tested forever. This is the principled
   reason for "add, don't replace" — not politeness, a layering necessity.

2. **A given parity test uses the SAME probe language on BOTH targets.** The diff requires
   one source, two targets. You do NOT diff a Swift macOS probe against a Zig rmxOS probe.
   So a behavior can only graduate to a swift-testing parity test once Swift runs on BOTH
   targets (rmxOS Swift solid = the Lane B gate).

3. **macOS swift-testing may capture REFERENCE-AHEAD (spec discovery), parity pending.**
   Because macOS swift-testing + system frameworks are available now, we can capture rich
   macOS-27 Swift system-integration reference vectors *before* rmxOS can match — useful
   for pre-authoring Lane B spec tests. Bookkeeping must be honest: "spec captured (Swift,
   macOS), rmxOS parity PENDING (rmxOS Swift not yet solid)." Not a parity claim yet.

4. **Component tests SPLIT by substrate-vs-consumer, not by file.** Same C component can
   land in two tiers at two levels:
   - libxpc: **ABI/symbol/wire floor → Zig**; **connection-lifecycle SEMANTICS
     (reply/error/cancel) as XPCSession will consume → swift-testing** (once available).
   - libnotify/notifyd: **server wire + Mach path → Zig**; **client API as a Swift
     consumer uses it → swift-testing**. Complementary layers on one component, not a
     pick-one.

5. **Elixir owns "how the run is driven," never "what is asserted at the metal."** Point
   behavior = a probe (Zig/Swift). A sequence/soak/lifecycle = Elixir wrapping repeated
   probe invocations. Keep the conductor out of the probe and vice versa.

## Phasing (maps to the risk lanes in swift-rmxos-integration-plan.md)

- **Now**: foundation + Lane A → **Zig probes + Elixir spine**. swift-testing not yet a
  trustworthy rmxOS probe (runtime not solid). macOS side MAY pre-capture reference-ahead
  Swift vectors for Lane B spec discovery (invariant 3).
- **As rmxOS Swift runtime solidifies (Lane B gate opens)**: promote high-tier behavior
  (Swift APIs, C++ interop, system-integration semantics) to **swift-testing on both
  targets**; Zig keeps the substrate; Elixir keeps conducting. Promotion trigger = the
  swift-rmxOS Arranger's falsifiable "swift-testing solid on rmxOS" bar (open round-3 Q).

## Refinement: probe tier is chosen by what you OBSERVE, not by the subject's language

(swift-rmxOS round-3, 2026-06-20.) A Swift binary can be the test SUBJECT while the PROBE
stays Zig/Elixir — when what you observe is loader/substrate behavior, not Swift semantics.
Example (Lane A / A3): compile a tiny Swift program with swiftc, run it, and capture the
LOADER's resolution from /usr/lib/swift as the behavior vector. The subject is a Swift
binary; the probe is Zig/Elixir because you're observing rtld, not Swift's API. Rule:
**pick the probe tier by the OBSERVABLE (loader/ABI/wire → Zig; Swift API semantics →
swift-testing), regardless of what language the thing being launched is written in.** This
keeps swift-testing off the Lane A critical path even when Swift binaries are involved.

## Two complementary test GATES (different axes, both wanted)

(swift-rmxOS round-3.) Parity is not the only gate:
- **Parity gate** (this doctrine / mach-oracle): "behaves like macOS-27" — behavior-vector
  diff vs the reference. Cross-target conformance.
- **Regression gate** (swift-rmxOS toolchain): "the toolchain didn't regress" — the Swift
  build-script test suite (`-T`) vs its own baseline. Within-target non-regression.
Orthogonal axes; a feature wants both green. The parity gate is where this doctrine and the
three pillars live; the regression gate is the swift-rmxOS suite's own concern.

## One-line rule of thumb

**Testing the floor or the wire → Zig. Testing Swift, C++, or a macOS API as a developer
uses it → swift-testing. Driving the run / soak / comparing / ledgering → Elixir.**
