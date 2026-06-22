# Swift-on-rmxOS Integration Plan (cross-project draft)

Status: Arranger draft (rmxOS side), for exchange with the swift-rmxOS (Swift 6.4
porting) Arranger. Shared Coordinator. This frames the integration; the Swift-side
specifics are the swift-rmxOS Arranger's domain to correct/expand — I speak
authoritatively only for the rmxOS C foundation.

**PHASE (Coordinator 2026-06-19): DESIGN / PLANNING ONLY — NO IMPLEMENTATION.**
This document is a design artifact + a cross-project contract. Identified work
items (e.g. the libdispatch Swift-executor-hook gap, the C-surface tiers) are
PLANNED, NOT to be dispatched/built now. No implementation Blocks for any of this
until the Coordinator calls the implementation phase. (Mirrors the parity track's
catalog-not-fix discipline: here it's plan-not-implement.)

## Goal

Swift on rmxOS that behaves **like Swift on macOS, not Swift on Linux** — by
riding rmxOS's macOS-compatible foundation (Mach IPC, Darwin libdispatch, launchd,
libxpc) rather than the FreeBSD-native stack, and by distributing the Swift
runtime the macOS way (shared system dylibs), not the Linux way (static per binary).

Principles (shared project doctrine): Mach-primitives-outward; think like Apple
engineers; preserve-but-improve; real macOS is the parity source of truth; current
rmxOS = 1.0 baseline (Swift integration is additive, not a 1.0 gate).

## Layered architecture (the stack)

```
  Swift applications + modern Swift XPC API (XPCSession/XPCListener "as macOS")
            |                                   [swift-rmxOS owns]
  Swift runtime + stdlib + Foundation + Dispatch  (shared system dylibs)
            |                                   [swift-rmxOS owns; rides v]
  -------- the integration contract: C ABI surface --------
            |
  rmxOS Darwin userland: libdispatch, libxpc, libmach, libnotify, launchd, ASL
            |                                   [rmxOS owns — IN-TREE + COMPILING]
  rmxOS Mach-compat kernel (Mach IPC, ports, dead-name, THRWORKQ) over FreeBSD 15
                                                [rmxOS owns — parity-validated]
```

The **deliberately-skipped ObjC middle** (NSXPCConnection / Foundation-ObjC) stays
excluded; the Swift XPC API binds directly to the rock-solid C libxpc.

## Pillar 1 — Dynamic Swift system libraries (macOS-like distribution + ABI)

The macOS model: the Swift runtime + stdlib + Foundation + Dispatch ship WITH the
OS as shared dylibs (e.g. /usr/lib/swift); binaries link dynamically; one system
copy shared by all; stable ABI / binary compatibility. The Linux model: static-
link the runtime into each binary (duplication, larger binaries, no system runtime).

rmxOS should do it the macOS way:
- Build the Swift runtime + stdlib + Foundation + Dispatch as **shared system
  dylibs**, installed in an rmxOS system location (the rmxOS analogue of macOS
  /usr/lib/swift).
- Toolchain (swiftc) configured to **dynamically link** against the system Swift
  libs by default (not `-static-stdlib`).
- The dynamic linker (rtld) resolves the Swift system dylibs; install-name /
  rpath conventions macOS-shaped.
- Target the **stable Swift ABI** so binaries get macOS-like binary compatibility
  (a swift-rmxOS decision — feasibility on the rmxOS/Darwin ABI is theirs).
- Payoff: shared runtime (no per-binary duplication), smaller binaries, system-
  managed Swift updatable independently of apps.

Open to swift-rmxOS: which Swift libs become "system" (runtime/stdlib/Foundation/
Dispatch/XCTest?); the install path + dyld/rpath conventions; stable-ABI
feasibility; how `swift build` defaults change.

## Pillar 2 — macOS-like system integration (Mach / libdispatch / launchd / XPC)

Swift's lower layers must ride the **Darwin stack rmxOS now provides**, not the
FreeBSD-native one:
- **Concurrency / Dispatch**: Swift concurrency + Dispatch ride rmxOS's **Darwin
  libdispatch** (over Mach + the kernel workqueue/THRWORKQ), NOT the
  epoll/kqueue FreeBSD libdispatch. rmxOS's libdispatch is in-tree + compiling;
  parity already shows MACH_RECV + dead-name behavior tracking macOS.
- **IPC / services**: Foundation's IPC + the Swift XPC API ride **Mach + the C
  libxpc + launchd** (the rmxOS Darwin stack), per the XPC layering directive:
  rock-solid C libxpc -> [skip ObjC] -> modern Swift XPC (XPCSession/XPCListener).
- **Service management**: Swift daemons are **launchd-managed** (rmxOS launchd),
  the macOS way (plist + bootstrap check-in), not rc.d.
- **Logging**: ASL/os_log path (rmxOS ASL stack), version-sensitive vs modern
  unified logging — cataloged by the parity explorer.

## The integration contract (rmxOS provides <-> Swift needs)

The join point is the **C ABI surface** rmxOS exposes, which the Swift layer binds
to. rmxOS commits to a clean, complete, STABLE C surface:
- libdispatch (GCD C API + Mach sources), libxpc (the C XPC API), libmach
  (mach_msg/port/bootstrap), liblaunch (check-in), libnotify, ASL.
- The Darwin ABI shape (calling conventions, struct layouts, mach_msg) the Swift
  runtime/Foundation expects.
swift-rmxOS depends on this surface; rmxOS keeps it stable + parity-validated.

## Current state + dependencies

- rmxOS foundation: Mach-compat kernel + the full Darwin userland are **in-tree
  and compiling** (build-integration just completed on `alpha`). Core Mach IPC +
  COPY/MOVE_SEND accounting **parity-match macOS-27** (8/12 probes); known gaps
  cataloged (mach_port_names, M2 body-descriptor delivery).
- DEPENDENCY: Swift integration needs the foundation **functional, not just
  compiling** — i.e. runtime validation (the libs run, daemons boot) + the
  parity gaps that Swift actually exercises (libdispatch, libxpc) closed or known.
  So Swift integration is gated on foundation maturity, not blocked-on but
  paced-by it.

## Parity-driven validation

Use the parity explorer (real macOS-27 = source of truth) to validate that
rmxOS's **Swift-relevant** behavior matches macOS: libdispatch sources/queues,
Mach IPC, libxpc connection semantics, launchd check-in. Swift "behaves like
macOS" exactly when these match. Swift-exercised behaviors become a priority
slice of the parity catalog.

## Platform-Path Strategy — the both-DNA principle (GOVERNING, Coordinator directive 2026-06-20)

rmxOS is **NextBSD**: a FreeBSD-15 base + a Darwin userland → it carries **both FreeBSD and
macOS DNA**. The Swift integration leverages both, with one preference trajectory for every
platform-path fork:

1. **START — FreeBSD default.** The base is FreeBSD; v1 targets the FreeBSD triple +
   FreeBSD libc/libthr. Proven, working starting position — don't fight it.
2. **AIM — the macOS/Darwin path (long-term).** Wherever Swift has a macOS-optimized path
   (`os_unfair_lock`, struct pthread, `__DARWIN_C_LEVEL` full visibility, `os(macOS)` Darwin
   code paths), opt INTO it by leveraging rmxOS's Darwin DNA (the `include/apple/` surface,
   the Mach/dispatch substrate). Inherit macOS's optimizations instead of re-deriving them.
   This is the project thesis — "as macOS."
3. **AVOID / TEMP-ONLY — the Linux-mimic path.** Upstream's FreeBSD-Swift cures often make
   FreeBSD "import like Linux." Use that ONLY as a last resort or a *temporary, marked*
   stopgap to unblock — never as the destination. Mimicking Linux squanders our Darwin DNA
   and keeps us papercutting FreeBSD divergences forever.

**Decision rule per fork:** prefer **Darwin-native > FreeBSD-default > Linux-mimic(temp)**.
Start from FreeBSD-default, migrate toward Darwin-native **layer-by-layer** (per the
risk-tiers + solidity gates below — "aim for Darwin" ≠ "do it now"), reach for Linux-mimic
only when forced and label it temporary.

**Worked example:** `swift-darwin-native-path.md` — the FreeBSD Swift papercuts (#81407
pointer-typedef pthreads, #85427 `__BSD_VISIBLE` visibility). FreeBSD-default *has* the
papercuts; Linux-mimic (#79261 API notes) is the temp cure; Darwin-native (3 layers, ending
at `os(macOS)`) is the long-term destination. This is the template for how we approach every
such decision.

## Risk-tiered sequencing (GOVERNING, Coordinator directive 2026-06-20)

We are pre-1.0 (NextBSD revival). Our CORE — Mach IPC + libdispatch servicing — is NOT
yet proven solid enough for deep Swift integration, and runtime validation just showed
why (dispatch MACH_RECV/TWQ servicing is dark; daemons run on FreeBSD-pthread fallback).
Deep integration IS the eventual goal (it's the path to true macOS-like Swift), but it
WAITS on a solidity signal from the explorer + gatekeeper track. Meanwhile we pursue the
LOW-RISK, LESS-INTRUSIVE parts that deliver real macOS-fidelity without touching the
unproven core.

**The dividing line: does the work ride the not-yet-proven core (Mach IPC + libdispatch
MACH_RECV/TWQ servicing)?** Maps onto the parity intrusiveness scale (config < userland-
lib < kernel).

### LANE A — LOW-RISK, pursue in design NOW (independent of the dark dispatch path)
The unifying property: build / install / link / distribution + POSIX-backed — no runtime
Mach-IPC or dispatch-servicing dependency. (Coordinator's example = A1; the rest are "find
similar things".)
- **A1 — Dynamic shared system Swift runtime (Pillar 1).** Swift runtime/stdlib/Foundation/
  Dispatch as SHARED system dylibs in /usr/lib/swift/<platform>, rtld-resolved, shared by
  all binaries — NOT Linux's static-per-binary embed. The macOS distribution model on ELF.
  Already de-risked: runtime validation proved shared-dylib load + cross-lib symbol
  resolution via rtld works on our stack. Loads, doesn't run-IPC → Lane A.
- **A2 — rpath / install-layout convention.** Settle the exact rmxOS convention
  ($ORIGIN/../lib/swift/<platform>, /usr/lib/swift/<platform>, ld-elf.so.conf vs rpath) as
  a published contract swift-rmxOS targets. Pure loader/filesystem config — lowest tier.
- **A3 — swiftc dynamic-link defaults.** Make the driver default to dynamic-link against
  the system runtime (macOS-shaped), not Linux static-stdlib. Build/driver config.
- **A4 — Published stable C-symbol-AVAILABILITY contract** (the non-behavioral half of the
  C-surface). We proved the libsys Mach-trap export recipe; formalize WHICH Mach/Darwin C
  symbols are the stable dynamically-resolvable surface Swift binds to. Header/symbol
  availability ≠ runtime servicing — the availability half is Lane A; the servicing half
  is Lane B.
- **A5 — POSIX-backed Foundation v1** (Q3, agreed). Reuse FreeBSD POSIX paths; explicitly
  do NOT go Mach-backed. By construction avoids the unproven core.
- **A6 — Foundation C-dep + link-boundary config.** ICU bundled (no dep); the
  Data.range/full-Foundation `--no-allow-shlib-undefined` boundary (link full Foundation or
  relax the flag); libcurl/FoundationNetworking = pkg, out-of-v1. All link/packaging config.

Strategic bonus: doing Lane A first ISOLATES the risky variable. When deep integration
opens, the loader/distribution/symbol-availability substrate is already nailed down, so
the only new unknown is the IPC binding — we don't debug two unknowns at once.

### LANE B — DEEP integration, GATED on explorer+gatekeeper solidity signal
Rides the unproven core; do NOT pursue until the parity/oracle track produces enough
evidence that Mach IPC + libdispatch servicing are solid (concretely: the dispatch TWQ +
MACH_RECV-source servicing fix lands AND parity confirms it tracks macOS under load).
- B1 — Swift concurrency executor join (P1: libswift_Concurrency on rmxOS libdispatch).
- B2 — Swift XPC (P3: XPCSession/XPCListener on libxpc) — needs the dispatch fix PLUS the
  libxpc cancel/error/lifecycle fill.
- B3 — Mach-backed Foundation fidelity (P4).
THE GATE = a solidity signal, not a calendar date: explorer (macOS-parity) + gatekeeper
(evidence) confirm the core under the load Swift will impose. The dispatch TWQ fix (debt
#19-21) is the first concrete milestone on that gate.

## Development process: macOS-parity-driven (GOVERNING, Coordinator directive 2026-06-20)

**Before implementing ANY Swift integration feature (Lane A or Lane B), the swift-rmxOS
Arranger REUSES our explorer + gatekeeper solution to test the correct behavior on real
macOS 27 (mm4 / mx-a64z, M4 Mac Mini), use that test as the SPEC and as a REGRESSION
test, and then incrementally make rmxOS's behavior match the macOS counterpart. This
parity loop IS the main Swift development process — not an afterthought QA step.**

Reuse, don't reinvent — same machinery as the foundation parity track (see
`explorer-parity-cycle-workflow.md`): the mach-oracle repo (GitHub-synced on both hosts),
the mx-a64z (macOS-27 reference) / rx (rmxOS guest) namespaces, the bhyve guest harness,
the JSON behavior-vector schema, the gatekeeper evidence discipline, and the mismatch
ledger (`findings/nx-r64z/`).

**The per-feature cycle, mapped to Swift:**
1. INPUT — a Swift behavior to pin (e.g. how a shared /usr/lib/swift dylib resolves; how
   dispatch global-queue execution orders work; how XPCSession reply/error/cancel
   behaves). Human or Arranger proposes it.
2. AUTHOR — a portable behavior test. For Swift features the probe is naturally **Swift
   source compiled on BOTH targets** (the Swift analogue of the dual-target Zig probe),
   emitting the structured behavior JSON; Elixir runner/comparator drives + diffs.
   Both toolchains now exist: stock swift on macOS 27, the swift-rmxOS toolchain on rmxOS.
3. macOS — run on mm4 → **the spec** (ground truth). HUMAN CHECKPOINT: validate the
   understanding of the macOS Swift behavior here, BEFORE judging rmxOS.
4. rmxOS — run the SAME probe on rx.
5. DECIDE — match = parity-confirmed (the test becomes a standing regression guard);
   no-match = mismatch ledger entry, target = the macOS behavior.
6. CLOSE — drive rmxOS to match incrementally, least-intrusive-first; re-run the test to
   confirm (regression guard) → the macOS-27 behavior test is the permanent acceptance
   criterion for that feature.

**Three test pillars — Zig + Elixir now, swift-testing later, ADDITIVE not replacing
(Coordinator directive 2026-06-20).** Grounds in the existing `test-plan.md` doctrine
(Elixir high-level / Zig low-level / keep C) and extends it with a 3rd pillar for the
Swift lane. All three stay — each has pros/cons; compose them, don't pick one:
- **Zig (now)** — low-level / ABI / dual-target substrate probes (does a shared
  /usr/lib/swift dylib resolve? are the Mach/C symbols available? loader behavior). One
  source, runs mechanically on BOTH macOS and the rmxOS guest, minimal deps, close to
  metal. **Substrate-INDEPENDENT** — does not need the Swift runtime to be solid.
- **Elixir (now)** — the high-level orchestrator/comparator SPINE: drives runs, captures
  env, normalizes, diffs vs the macOS-27 reference, classifies, maintains the
  findings/nx-r64z ledger. Stays the backbone across ALL probe types.
- **swift-testing (LATER, additive)** — native Swift-API behavior probes written in the
  modern `import Testing` framework (NOT legacy XCTest — matches our skip-ObjC/modern-
  Swift-native direction), with macOS-27's stock swift-testing as the reference. Best for
  high-level Swift semantics (concurrency ordering, Foundation APIs, XPCSession/XPCListener
  ergonomics) — tests Swift the way Swift developers test.

**Why the ordering is a DEPENDENCY, not a preference:** swift-testing runs ON the Swift
runtime it would be testing — you cannot trust it as a test vehicle until the substrate
it depends on (Swift runtime + Dispatch on rmxOS) is itself proven. Zig + Elixir depend
on NONE of that, so they validate the substrate Swift sits on FIRST. Promote to swift-
testing as the 3rd pillar only once swift-testing is solid on rmxOS. This maps onto the
lanes: Lane A (loader/ABI/distribution) probes are naturally Zig+Elixir; swift-testing
matures alongside the Lane B solidity gate (the Swift-API behavior it tests is exactly
Lane B). **How they compose:** Elixir is the comparator spine; Zig and swift-testing are
two probe front-ends at different abstraction levels (low-level substrate vs Swift-native
high-level), both emitting the JSON behavior vector Elixir diffs against macOS-27. Three
pillars, one ledger.

**Why this fits Swift especially well — greenfield advantage.** Unlike the foundation
(an existing NextBSD baseline where parity = catalog-then-fix a retrofit), Swift on our
side is NEW. So we build it **parity-first**: write the macOS-27 behavior test FIRST,
then implement rmxOS to pass it. The test precedes the implementation — spec, then code,
then regression guard, all one artifact. This is the natural reading of "before
implementing any feature."

**Interaction with the lanes:** parity-driven development applies WITHIN both lanes.
Lane A features get macOS-27 parity tests authored now (test-authoring is design-phase
work, allowed). Lane B features stay gated — but their macOS-27 spec tests can be authored
in advance, so when the solidity gate opens, the acceptance criterion already exists.
Authoring the spec tests is itself part of the explorer+gatekeeper solidity signal for
Lane B.

## Rough phasing (for discussion)

1. **Foundation-ready**: runtime-validate the Darwin userland (libdispatch/libxpc
   run); close/triage the Swift-exercised parity gaps. (rmxOS side.)
2. **Swift runtime on the foundation**: swift-rmxOS builds the Swift runtime +
   stdlib + Dispatch against rmxOS's libdispatch/libmach as **shared system
   dylibs** (Pillar 1 + Pillar 2 lower half).
3. **Foundation (Swift)**: port swift-corelibs-foundation onto the rmxOS Darwin
   services (Mach/launchd/ASL).
4. **Swift XPC API "as macOS"**: the modern Swift XPC surface on the C libxpc.
5. **Dynamic-distribution polish**: stable-ABI, system-lib install, swiftc
   dynamic-link defaults.

## Exchange round 1 — swift-rmxOS Arranger input + rmxOS answers (2026-06-19)

swift-rmxOS pacing: mid-Swift-6.4 bringup on FreeBSD 15, ~1 blocker from a
coherent toolchain (final SwiftPM swift-bootstrap link). FreeBSD15 = substrate;
rmxOS port = flip the build-time platform-provider seam (FreeBSD libs → rmxOS
Darwin stack). Their FreeBSD15 build walls = a live preview of the exact C-surface
Swift needs (concrete data, not guesses).

**C-surface, prioritized (their tiers):**
- Tier A (BUILD the toolchain): (1) **libdispatch full `dispatch/dispatch.h` C
  ABI** + the **Swift-cooperative-executor entry points** — THE #1 surface;
  (2) Foundation C deps (ICU=bundled `_FoundationICU`, libc/threads;
  FoundationNetworking→libcurl; FoundationXML→libxml2); (3) Mach C headers
  (mach/mach.h, bootstrap.h).
- Tier B (BEHAVE macOS-like): Mach-backed dispatch sources functional (not just
  headers); xpc/xpc.h canonical; launchd/liblaunch, ASL/os_log, audit_token peer
  identity (vs FreeBSD getpeereid).
- **Single most load-bearing for the build: libdispatch `dispatch.h` ABI + the
  Swift executor entry points.**

**rmxOS answers (Arranger, verified first-hand where noted):**
1. **libdispatch lineage + executor — REFINED (round 2, the gate dissolves for
   v1)** — rmxOS's libdispatch IS Apple/corelibs (Copyright 2008-2013) → classic
   dispatch.h ABI = trivial bind. swift-rmxOS confirmed their concurrency runtime
   on a non-Apple ELF platform links **only classic dispatch.h** (the fallback
   executor: dispatch_async_f to global queues) — NOT the modern cooperative-
   pool/swift-job path. And swift_task_enqueueGlobal*/*_hook are **runtime-
   exported override points, NOT libdispatch symbols** (I was chasing the wrong
   layer). **Verified: rmxOS's libdispatch exports the classic set Swift v1 needs**
   (dispatch_async_f/after_f/main/walltime, queue_create/set_width/attr_make_with_
   qos_class, _dispatch_main_q, source_create/set_event_handler_f/set_timer,
   activate/release/set_context/assert_queue — all present). So **the v1 Swift-
   concurrency libdispatch contract is ALREADY SATISFIED — no executor port for
   v1.** The cooperative-pool/swift-job hooks (absent) become a LATER macOS-
   FIDELITY enhancement (true cooperative pool, QoS/priority), a deliberate
   milestone, NOT a v1 gate. Open verify (when toolchain green): confirm rmxOS
   configures the classic-dispatch executor, not forcing the cooperative pool
   (should be — same toolchain).
   FOUNDATION LINK-BOUNDARY (shared concern): Data.range(of:) lives in FULL
   Foundation, not FoundationEssentials → linking only FoundationEssentials under
   --no-allow-shlib-undefined breaks; rmxOS's strict ELF linking hits the same
   boundary; fix = link full Foundation or relax the strict flag.
   /usr/lib/swift RPATH: swift-rmxOS block-014 (install-coherence) is rewriting
   installed RUNPATHs to resolve from the install prefix — literally building the
   ELF rpath → /usr/lib/swift distribution shape rmxOS's rtld expects; they'll
   hand over the rpath/install-layout convention as the reference. Full verified
   symbol/header set (libdispatch + Mach + Foundation C-deps) comes when their
   block-014 yields a coherent launchable toolchain.
2. **target triple** — for v1, the FreeBSD triple (rmxOS is ELF/FreeBSD-ABI with
   the Darwin userland on top); a custom `rmxos` triple is a later decision.
3. **xpc.h** — rmxOS libxpc is the canonical C surface (opaque xpc_object_t,
   xpc_dictionary_*/array_*, xpc_connection_*, xpc_connection_create_mach_service
   + bootstrap; Mach-native via bootstrap_check_in/MACH_RECV). Caveat: nvlist
   serialization (NOT Apple wire) — irrelevant to the C-API binding; and
   connection-lifecycle depth (reply/error/cancel) is an open verification item.
4. **loader / system-swift-lib path** — rmxOS uses FreeBSD **ELF/rtld** (NOT
   Mach-O/dyld). System Swift dylibs go in `/usr/lib/swift` (macOS-shaped),
   resolved via rtld (rpath / ld-elf.so.conf). A stable system path fixes their
   RUNPATH-leak (block-001) — installed binaries point at the system, not the
   build tree.
5. **stable-ABI scope** — NOT v1. Per their rec: ship a shared **dynamic** runtime
   first (macOS distribution model, per-toolchain bundled, not yet library-
   evolution ABI-stable); pursue stable-ABI (locked platform ABI + library-
   evolution) as a deliberate LATER milestone. **Pillar 1 is NOT gated on full
   ABI stability** (aligns with 1.0-baseline).

**Foundation choice (settled):** swift-foundation (modern FoundationEssentials +
Foundation), which 6.4 ships — not Apple-Foundation, not legacy swift-corelibs-
foundation. No decision needed.

**Planned first join (agreed, for WHEN implementation begins — NOT now):** take the
green 6.4 FreeBSD15 toolchain → flip the libdispatch provider seam to rmxOS's
libdispatch → **executor-hook probe** (does Swift Concurrency ride it?). The
identified rmxOS work item for this join = confirm + ADD the Swift-cooperative-
executor entry points (currently absent) — PLANNED, not to be built in this phase.
Parity synergy (also planned): Swift-exercised libdispatch behavior becomes a
priority slice of the macOS-27 parity catalog. This is the smallest real
integration test to run FIRST once the implementation phase opens.

## Runtime-validation update (2026-06-20) — what rmxOS block-078/079 changes for Swift

rmxOS reached its first RUNTIME-VALIDATION milestone (Arranger-verified first-hand):
the canonical-built Darwin userland now **loads as shared dylibs and runs real
daemons** in a guest (notifyd Mach IPC round-trip, launchd starts). Three concrete
effects on this plan — one clean advance, one de-risk, one sharpened caveat:

1. **Phasing step 1 advances (planned → in-progress).** "Runtime-validate the Darwin
   userland (libdispatch/libxpc run)" is now partially real: the userland loads + the
   Mach IPC foundation is live. Swift no longer waits on an unproven loading substrate.

2. **Pillar 1 (dynamic shared dylibs / rtld) MATERIALLY DE-RISKED.** The smoke proved
   canonical-built shared dylibs **load + resolve cross-library symbols via rtld** in
   the guest — the macOS-shaped distribution model Pillar 1 needs for /usr/lib/swift.
   Concrete reusable artifact: the **Mach-trap export recipe** — bare-name aliases
   (task_self_trap/mach_reply_port/mach_msg_trap/_kernelrpc_*) exported in
   `lib/libsys/syscalls.map` FBSDprivate_1.0, **vendored libmach kept byte-identical**
   (FreeBSD-15 split syscall stubs into libsys; bare-name Mach traps weren't exported
   for dynamic linking — now they are). Swift runtime + Dispatch + Foundation will need
   Mach primitives dynamically resolvable; the pattern + the current exported set are
   now a known reference. swift-rmxOS block-014 RUNPATH→/usr/lib/swift lands on a
   loading path we've exercised end-to-end.

3. **Pillar 2 / libdispatch executor contract — ABI-satisfied ≠ behavior-ready (the
   key caveat; v1 DESIGN unchanged).** The v1 contract ("classic dispatch.h symbols
   present → no executor port") holds AT THE LINK LEVEL. But runtime validation exposed
   a BEHAVIORAL gap one layer below the ABI: classic libdispatch's **workqueue
   servicing aborts** (smoke requires `LIBDISPATCH_DISABLE_KWQ=1`; pending-count
   underflow in src/queue.c) and the **MACH_RECV dispatch source stayed dark** (notifyd
   fell back to a raw FreeBSD pthread receive loop). This bites Swift specifically:
   Swift concurrency's fallback executor does `dispatch_async_f` to **global queues**,
   and global-queue execution is serviced by the libdispatch worker pool — the exact
   TWQ/KWQ boundary that aborted. So:
   - **ABI-satisfied** (symbols link): ✅ true, no executor port for v1.
   - **Behavior-ready** (Swift executor actually RUNS work on global queues): ❌ not
     yet — gated behind the dispatch TWQ + MACH_RECV-source servicing fix, which is
     rmxOS's own documented next foundation blocker (completion-debt #19–21).
   REFINEMENT to the "planned first join": the executor-hook probe (flip libdispatch
   provider seam → does Swift Concurrency ride it?) must NOT be the first integration
   attempt until the dispatch TWQ boundary fix lands — otherwise Swift's executor hits
   the same KWQ abort the daemons did. NEW PREREQUISITE on the join, not a design change.
   CONVERGENCE: this plan already earmarks "Swift-exercised libdispatch behavior" as a
   priority parity-catalog slice — the TWQ/MACH_RECV servicing gap IS that behavior AND
   is the foundation's next blocker. Both tracks point at one fix; sequence Swift
   concurrency bring-up AFTER it. (Precedent worth knowing: today Mach-IPC servicing
   works WITHOUT dispatch sources via the pthread fallback — Swift XPC later will want
   dispatch-driven servicing, so it inherits the same dependency.)

Still DESIGN/PLANNING ONLY — no implementation. This update only re-sequences the
planned join and de-risks Pillar 1; it opens no Blocks.

## Exchange round 2 — swift-rmxOS contract spec + rmxOS answers (2026-06-20)

swift-rmxOS delivered a LAUNCHABLE verified 6.4 FreeBSD15 toolchain (swiftc compiles/
runs/swift test passes) + the contract spec: ① C-surface (v1 substrate = FreeBSD base
+ donor libdispatch classic set [confirmed exported]; external libcurl for
FoundationNetworking; ICU bundled; Data.range-in-full-Foundation link boundary; Mach/
libxpc/launchd/ASL are the FORWARD macOS-fidelity add-ons the retarget binds Phase 3-4),
② rpath = $ORIGIN-relative ($ORIGIN/../lib/swift/<platform>), system dylibs in
/usr/lib/swift/<platform>, rtld-resolved (their RUNPATH-leak fix), ③ retarget phases:
P1 rebuild libswiftDispatch+libswift_Concurrency against rmxOS libdispatch → concurrency
smoke; P2 system-dylib distribution; P3 Swift XPC API (XPCSession/XPCListener thin-wrap
of C libxpc, ObjC skipped) = main swift-rmxOS deliverable; P4 Foundation Darwin-services
fidelity; later cooperative-pool + stable-ABI.

**rmxOS answers (Arranger, all verified first-hand against wip-rmxos/alpha):**

Q1 (libdispatch.so drops in as C backing, or ABI shim?): **Header/ABI = drops in, no
shim expected.** rmxOS libdispatch is Apple/corelibs-libdispatch lineage — full layout
(dispatch/, os/, private/, resolver/, src/), the same upstream libswiftDispatch overlays;
dispatch/dispatch.h present, classic set exported. So libswiftDispatch rebuilding against
it links clean. **BUT the runtime caveat governs: the dispatch worker-pool + MACH_RECV
servicing is NOT behavior-ready (KWQ abort) — see below. Open verify: exact dispatch.h
vintage delta (both Apple-derived; confirm no symbol-set drift) when you hand the overlay's
expected symbol list.**

Q2 (libcurl for FoundationNetworking?): **NOT in base** (verified: no lib/libcurl, no
contrib/curl; FreeBSD base never shipped curl). It's a pkg/ports dependency. Recommend
FoundationNetworking = OPTIONAL / out-of-v1 (matches Apple's separate-module shape); pull
libcurl from pkg when needed. Not a v1 base-system commitment.

Q3 (Foundation v1 POSIX vs Mach-backed?): **AGREE — POSIX for v1, Mach-backed as
fidelity.** Doctrine-aligned (least-intrusive, 1.0=current baseline) AND runtime-aligned:
Mach-backed paths route through dispatch MACH_RECV sources = exactly what's not behavior-
ready. POSIX-on-FreeBSD-base is proven; Mach-backed Foundation services become a later
fidelity milestone tied to the dispatch TWQ fix + parity catalog.

Q4 (xpc.h connection-lifecycle depth reply/error/cancel — Phase 3 gate): **VERIFIED
first-hand (lib/libxpc/xpc_connection.c, 468 lines) — MIXED: reply works, error + cancel
do NOT.**
  - reply ✅ — send_message_with_reply + _sync implemented (xc_pending id-correlation
    TAILQ; sync via dispatch_semaphore). Listener/peer dispatch + audit_token credentials
    (euid/guid/pid/asid) also real. Transport Mach-native (bootstrap_check_in/look_up).
  - error ❌ — NO XPC_ERROR_* delivery anywhere: send failure only debugf's (xpc_send
    :373), recv failure just returns (recv_message :411), no dead-name/no-senders/peer-
    death wiring → handler never gets CONNECTION_INTERRUPTED/INVALID/TERMINATION_IMMINENT.
  - cancel ❌ — xpc_connection_cancel() is an EMPTY no-op (:262-266): no source teardown,
    no CANCELLED error.
  - also stub/absent: set_finalizer_f (empty), xpc_endpoint_create (empty, no return),
    xpc_main (ignores handler, just dispatch_main), transaction_begin/end (empty),
    get_name ("unknown").
  - **So Phase 3 (XPCSession/XPCListener) is gated on FILLING three things on the C side:
    connection cancel + error/interruption delivery + finalizer/transaction lifecycle.**
    Concrete debt list, not a vague verify — confirms + sharpens the standing XPC open item.

**TWO CONVERGENCE POINTS on one fix (the strategic headline):** the dispatch TWQ +
MACH_RECV-source servicing fix (rmxOS foundation's next blocker, debt #19-21) is the
linchpin for BOTH Swift join phases:
  - P1 (Swift concurrency): the fallback executor's dispatch_async_f rides global-queue
    worker servicing = the TWQ boundary. Behavior-ready only after the fix.
  - P3 (Swift XPC): xpc_connection_resume creates DISPATCH_SOURCE_TYPE_MACH_RECV (:186) —
    libxpc connection servicing rides the SAME dark MACH_RECV source. Even libxpc's working
    reply path won't service at runtime until the fix.
One fix, three consumers (notifyd, Swift concurrency, libxpc). SEQUENCING: rmxOS lands the
dispatch TWQ fix → P1 concurrency smoke (now meaningful) → P3 needs that PLUS the libxpc
cancel/error/lifecycle fill. P2 (rpath/system-dylib) is independent and can ride alongside.

**rmxOS questions back (round 3):**
- Hand over the exact dispatch.h symbol set libswiftDispatch expects, so I diff it against
  rmxOS's vintage and pin any delta as a tracked C-surface item (Q1 open verify).
- For P3: do you want the C libxpc cancel/error/lifecycle fill as an rmxOS-side deliverable
  (fill xpc_connection.c against the donor/XNU semantics) before XPCSession binds, or a
  thinner v1 XPC surface (reply-only, no cancel/error) that XPCSession degrades to? The
  former is the robust path; the latter unblocks a P3 demo sooner on a known-partial base.
- Confirm: is the concurrency smoke (P1) acceptable to run in the same bhyve guest harness
  rmxOS uses for the runtime smoke (so the dispatch TWQ fix + Swift P1 share one validation
  loop)?
- (round 3, new criteria) Lane A first target: which Lane A item do you want the first
  macOS-27 parity test authored against — A1 (shared /usr/lib/swift dylib resolution) is
  the natural anchor; confirm or redirect.
- Probe-language boundary for Lane A: can a Zig probe linked against the Swift runtime emit
  the behavior vector for substrate tests (dylib resolution, symbol availability), or do
  even Lane A tests need a Swift probe? (Decides how soon swift-testing is on the critical
  path.)
- swift-testing promotion trigger: what is your concrete bar for "swift-testing solid
  enough on rmxOS" to become pillar 3 (so we have a falsifiable promotion criterion, not a
  vibe)?
- Lane B gate definition: what load characteristics does Swift actually impose on the core
  (concurrency worker-pool pressure, MACH_RECV under many live connections, queue depth)?
  You know Swift's load shape; we know how to probe the foundation — define "solid enough"
  by Swift's real needs so the explorer stresses the right things.

Still DESIGN/PLANNING ONLY — no Blocks opened. The xpc_connection.c read is read-only
classification (allowed); no source touched.

## Exchange round 3 — RESOLVED (2026-06-20, swift-rmxOS reply + rmxOS verification)

Convergence; settled decisions + two refinements I verified first-hand.

**Settled:**
- A1 (shared /usr/lib/swift dylib resolution) = confirmed FIRST Lane A target (substrate
  A2/A3/A4 all ride; pure loader behavior, no Swift semantics). swift-rmxOS authors the
  macOS-27 parity test in Zig+Elixir when their block-016 reproducibility is green + hands
  me the final /usr/lib/swift layout.
- A3 promoted to an EXPLICIT Lane A item: Swift defaults to STATIC stdlib on non-Apple;
  "swiftc dynamic-link default" is a deliberate config flip to the macOS shared-dylib
  model (default-link against /usr/lib/swift dylibs). Config tier.
- Probe-language boundary: **Zig+Elixir suffice for ALL of Lane A.** dylib resolution =
  dlopen + rtld-resolved-from-/usr/lib/swift; symbol availability = dlsym C-ABI + mangled-
  Swift symbols (both just ELF symbols — no Swift semantics); A3 = harness compiles a tiny
  Swift program with swiftc, runs it, captures the LOADER's resolution as the vector.
  swift-testing stays OFF the Lane A critical path entirely.
- XPC lifecycle = PHASED: full reply+error+cancel is the committed rmxOS fidelity
  deliverable, BUT XPCSession v1 binds **reply-only (degraded)** and grows as the
  error/cancel fill lands → unblocks Phase-3 start without the full surface. Matches my
  first-hand finding (reply works NOW, cancel/error are stubs) — reply-only v1 is buildable
  on current libxpc today; the cancel/error fill is the graduation gate.
- P1 concurrency smoke shares the rmxOS bhyve harness (Zig/Elixir-orchestrated Swift-binary
  run → behavior vector → vs macOS-27). Reuse confirmed.
- dispatch.h: ~80 classic symbols, swift-rmxOS extracted first-hand; **rmxOS-VERIFIED our
  libdispatch defines the classic span** (async/barrier/apply/group/semaphore/source/io/
  data/block/queue families across src/{io,queue,apply,semaphore,source,transform}.c). The
  mach source types ARE present too (init.c/source.c) — Swift v1 just doesn't link them.

**Refinement 1 — "one fix, three consumers" splits into TWO dispatch-servicing sub-fixes
(verified: gap is runtime servicing, NOT symbols — both classic set + mach source types
are present and link):**
- **Sub-fix #1 — worker-pool / TWQ servicing** (completion-debt #19, the KWQ abort):
  global concurrent-queue worker threads. Consumer = **Swift concurrency (B1)** — its
  fallback executor's dispatch_async_f to global queues rides this. (notifyd does NOT need
  it.)
- **Sub-fix #2 — MACH_RECV dispatch-source servicing** (completion-debt #21, the notifyd
  pthread fallback): the mach-backed source. Consumers = **notifyd + libxpc + Swift XPC
  (B2)**.
  So: #1 → 1 consumer (Swift concurrency); #2 → 3 consumers (notifyd, libxpc, Swift XPC).
  Two distinct foundation sub-targets, not one.

**Refinement 2 — Lane B gate defined by Swift's REAL load shape (swift-rmxOS domain input;
becomes the explorer STRESS SPEC + the dispatch sub-fix acceptance criteria):**
- (a) wide fan-out TaskGroup → worker-pool pressure (burst dispatch_async_f, workers scale
  ~#cores, park/unpark) → stresses sub-fix #1.
- (b) actor churn → serial-queue create/teardown + hop pressure (each actor ≈ a serial
  queue) → sub-fix #1.
- (c) deep async/await chain → queue depth (continuation-after-continuation enqueues) →
  sub-fix #1.
- (d) N concurrent Swift-XPC connections → MACH_RECV under many live sources → sub-fix #2
  (later).
  (a)(b)(c) gate B1 on sub-fix #1; (d) gates B2 on sub-fix #2. THE explorer/gatekeeper
  solidity signal = these stress patterns pass parity vs macOS-27 with no hang/deadlock.

**Two complementary test GATES (swift-rmxOS note, both wanted, different axes):**
- **Parity gate (ours):** "behaves like macOS-27" — the mach-oracle behavior-vector diff.
- **Regression gate (theirs):** "the toolchain didn't regress" — swift build-script -T vs
  baseline. Orthogonal; keep both.

**swift-testing promotion trigger (falsifiable, recursive):** swift-testing is itself
async-based → it runs on the very executor it would test. Bar = an async swift-testing
suite (Task/await/TaskGroup) runs to completion deterministically on rmxOS, parity-matches
the same suite on macOS-27, and survives a concurrency-stress run with no hang/deadlock.
Chain: sub-fix #1 → executor join solid → swift-testing's own async runs reliably →
PROMOTE to pillar 3.

## Questions for the swift-rmxOS Arranger (your domain)

- Swift 6.4 toolchain: build against rmxOS's libdispatch/libmach, or a vendored
  copy? How does the toolchain find rmxOS's Darwin headers/libs?
- Which Swift libs become "system" shared dylibs; install path; dyld/rpath shape.
- Stable Swift ABI feasibility on the rmxOS/Darwin ABI.
- swift-corelibs vs Apple-Foundation: which Foundation, and how much rides
  Mach/launchd vs portable.
- The Swift concurrency executor: does Swift 6 concurrency map cleanly onto
  rmxOS's Darwin libdispatch, or are there custom-executor needs?
- What C-surface gaps in rmxOS would block the Swift build (so I prioritize them)?
