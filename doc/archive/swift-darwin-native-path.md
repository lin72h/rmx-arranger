# Swift on rmxOS — the Darwin-native path vs the Linux-mimic path

Status: Arranger research (workspace, living). Companion to `swift-rmxos-integration-plan.md`
and `test-pillar-partition.md`. Captures the analysis behind a strategic choice for the
Swift port: when a Swift/FreeBSD papercut appears, do we follow upstream's "import like
Linux" cure, or take the **native macOS/Darwin path** — which rmxOS can, because it carries
a Darwin userland. Design-phase only; no implementation.

**This doc is the WORKED EXAMPLE of the governing Platform-Path Strategy** (see
`swift-rmxos-integration-plan.md` → "Platform-Path Strategy — the both-DNA principle"):
FreeBSD-default = start; Darwin-native = long-term aim; Linux-mimic = temp/last-resort.
rmxOS is NextBSD — both FreeBSD and macOS DNA — so we start FreeBSD, trend to Darwin.

## Framing

swift-rx (the swift-rmxOS arranger) is building Swift's full dependency tree (SwiftNIO,
AsyncHTTPClient, swift-log, swift-http-types, swift-subprocess, swift-crypto, …) and keeps
hitting FreeBSD Swift papercuts. Upstream's fix for these is to make **FreeBSD import like
Linux**. rmxOS has a better option available *because it is a Darwin userland*: take the
**os(macOS)/Darwin path**, inheriting macOS's optimized lock/concurrency/source paths
instead of mimicking Linux. "Behave like macOS" at the *source-compatibility and C-module*
level, not just at runtime.

This doc records: the two upstream papercuts + root causes, and the **rmx-side** verified
feasibility (the part that's ours to decide).

## The two upstream papercuts

### #81407 — pthread pointer-typedef nullability
<https://github.com/swiftlang/swift/issues/81407>

- **Root cause:** on FreeBSD, `pthread_mutex_t` / `pthread_cond_t` / `pthread_rwlock_t` are
  **pointer typedefs** (`typedef struct pthread_mutex *pthread_mutex_t`), and the pthread
  APIs carry **no nullability annotations**. So `pthread_mutex_init(pthread_mutex_t *, …)`
  imports as `UnsafeMutablePointer<pthread_mutex_t?>` (inner optional), which doesn't match
  the `UnsafeMutablePointer<pthread_mutex_t>` portable lock code expects.
- **Downstream cost (swift-rx data point, FreeBSD 15.1/AArch64, swift-6.3.2):** every
  package doing raw pthread work needs an `#if os(FreeBSD)` branch — a typealias to the
  `?`-wrapped primitive + `pthread_mutexattr_t(bitPattern: 0)` — mirroring the existing
  `os(OpenBSD)` branch. Added to swift-log, swift-distributed-tracing, swift-http-types,
  swift-subprocess, swift-nio (NIOConcurrencyHelpers).
- **Upstream cure (#79261, API notes):** annotate nullability so FreeBSD's pointer types
  import non-optional like Linux → packages can *delete* their FreeBSD/OpenBSD branches
  (net fewer platform branches). This is the **mimic-Linux** path.
- **The macOS contrast:** on Darwin, `pthread_mutex_t` is an **inline struct**
  (`_opaque_pthread_mutex_t`), so the import is non-optional already — AND Swift's lock code
  uses **`os_unfair_lock`**, not `pthread_mutex`, taking a faster path entirely. The macOS
  path sidesteps the nullability issue at the root.

### #85427 — SwiftGlibc selective symbol visibility
<https://github.com/swiftlang/swift/issues/85427>

- **Root cause:** on FreeBSD, `SwiftGlibc.h` *does* `#include` the headers, yet some symbols
  never surface in the `Glibc` Swift module — selectively, not wholesale. Confirmed missing
  (native 6.3.2, aarch64): `inet_ntop`/`inet_pton` (`<arpa/inet.h>`), `UIO_MAXIOV`
  (`<sys/uio.h>`). For contrast, `sockaddr_in.sin_addr` (`<netinet/in.h>`) *is* visible. The
  signature of **`__BSD_VISIBLE` / `_POSIX_C_SOURCE` visibility gating**: symbols guarded
  behind a visibility level the Glibc module's compile context doesn't enable.
- **Downstream cost:** every package doing raw `inet_*` needs a C shim.
- **The macOS contrast:** Darwin defaults to `__DARWIN_C_LEVEL=FULL` — no `_POSIX_C_SOURCE`
  gating — so these symbols surface without shims.

### Common cure
Both papercuts share one root: Swift on FreeBSD takes the **Glibc/os(FreeBSD)** path and
inherits FreeBSD's divergences (pointer pthreads, visibility gating). Making Swift take the
**Darwin/os(macOS)** path cures the whole class at once (struct pthread + `os_unfair_lock`
for #81407; full header visibility for #85427).

## The strategic choice

- **Mimic-Linux** (upstream path): lower risk, incremental, but rmxOS keeps papercutting
  FreeBSD divergences forever and never inherits macOS's optimized paths.
- **Be-macOS** (Darwin path): higher leverage — inherit macOS's lock/concurrency/source
  paths — and it *is* the project thesis (Darwin userland, Mach-primitives-outward, "as
  macOS"). The right **destination**. But it's all-or-nothing and surface-dependent (below).

## rmx-side: verified tree state (2026-06-20, Arranger first-hand in wip-rmxos)

rmxOS is a **hybrid** — a partial Darwin C surface *staged* over a still-active FreeBSD base:
- **Active base pthread = FreeBSD pointer typedef** — `sys/sys/_pthreadtypes.h:69:
  typedef struct pthread_mutex *pthread_mutex_t`. This is the #81407 root, live today.
- **Darwin struct-pthread types ARE staged** — `include/apple/System/sys/_pthread/
  _pthread_mutex_t.h`, `_pthread_types.h` (the `_opaque_pthread_mutex_t` inline-struct form),
  plus Darwin's visibility machinery (`_posix_availability.h`, `_symbol_aliasing.h`,
  `__DARWIN_C_LEVEL` in `include/apple/sys/resource.h`). A whole partial Darwin surface
  lives under `include/apple/`.
- **`os_unfair_lock` / `os/lock.h` = ABSENT** (only FreeBSD/openzfs `lock.h` exist). The
  lock fast-path gate is closed; it'd need implementing (a libplatform primitive on Darwin).
- **`lib/libthr` (FreeBSD) is the pthread impl** — no Darwin libpthread. The implementation
  underneath is FreeBSD pointer-based.
- **No system-level Darwin `module.modulemap`** (only toolchain/contrib ones).

Net: the Darwin types exist but aren't *wired* as the default; Swift sees `os(FreeBSD)` +
FreeBSD pointer pthreads today.

## The decomposition — three layers, do NOT flip one switch

| Layer | What | Intrusiveness | rmx state | Lane |
|---|---|---|---|---|
| **A — header visibility** | `__DARWIN_C_LEVEL=FULL`, no `_POSIX_C_SOURCE` gating (#85427 cure) | LOW (header gating/search-path) | machinery staged in `include/apple/` | Lane-A-adjacent; near-term |
| **B — pthread/lock ABI** | Darwin struct pthread + `os_unfair_lock` (#81407 cure) | DEEP (threading ABI + impl) | types staged, but active impl = FreeBSD libthr; `os_unfair_lock` absent | **Lane B — rides Mach/THRWORKQ → shares the dispatch TWQ solidity gate with the executor** |
| **C — `os(macOS)` identity** | Darwin module + triple; Swift reports `os(macOS)` | BIG-BANG | partial surface, no module map, FreeBSD triple | Lane B endgame — only after full surface real + solid |

Layer B is one milestone with the executor join: **lock + executor both ride the same
Mach/workqueue substrate**, so they pass or fail the TWQ solidity gate together.

## The critical risk

**Flipping `os(macOS)` while the surface is incomplete is WORSE than the FreeBSD
papercuts.** Reporting `os(macOS)` activates every package's Darwin code paths — expecting
full Darwin APIs that aren't there → broad breakage, not a papercut. `os(macOS)` is
**all-or-nothing**: you cannot claim the identity until the surface genuinely backs it.

## Recommendation

1. Target **Darwin-identity as the destination**, reached by completing the `include/apple/`
   surface **layer-by-layer** — never by flipping the `os()` bit early.
2. **Near-term:** Layer A (header visibility) is the cheapest real "more macOS" win and
   doesn't touch the core; pursue it in design. Until the surface is complete, stay on the
   v1 FreeBSD triple and fix papercuts on the FreeBSD path (the upstream cure is fine as a
   stopgap — it's net-negative branches downstream).
3. **Layer B** (pthread/lock ABI) is gated on the **same dispatch TWQ solidity** that gates
   the executor — schedule them as one foundation milestone.
4. **Layer C** (`os(macOS)`) is post-foundation-solidity, once A+B make the surface real.

## Parity-ruler angle

"How Darwin can we present?" should be **measured, not guessed.** Once the rulers run, a
parity probe can catalog the macOS pthread/lock/header ABI (struct layouts, `os_unfair_lock`
surface, `__DARWIN_C_LEVEL` symbol visibility) vs. what `include/apple/` already provides →
a concrete delta that scopes Layers A/B and tracks convergence as a regression-guarded
ledger.

## Open questions (for scoping)

- How complete is `include/apple/` vs. the full Darwin C surface a Swift toolchain needs?
- Are the `apple/` headers wired into any build's default search path, or staging-only?
- Can FreeBSD `libthr` present the Darwin struct-mutex ABI, or is a Darwin libpthread over
  Mach/THRWORKQ required?
- Can `os_unfair_lock` ride the same substrate cleanly (shared with the executor)?
- Is there a partial-Darwin-identity option (Darwin C-module + headers) short of the full
  `os(macOS)` triple flip, that gets Layer A/B wins without the all-or-nothing identity bit?

## Sources
- swift #81407 (pthread nullability): <https://github.com/swiftlang/swift/issues/81407>
- swift #85427 (SwiftGlibc visibility): <https://github.com/swiftlang/swift/issues/85427>
- swift #79261 (API notes overlay, the upstream mimic-Linux cure) — referenced from #81407.
- swift-rx downstream data: FreeBSD 15.1/AArch64, swift-6.3.2-RELEASE native toolchain.
