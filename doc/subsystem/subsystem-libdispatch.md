# subsystem-libdispatch — base/lineage decision (classic-Apple-Mach, NOT upstream)

- subsystem: libdispatch
- base (owned): NextBSD **classic-Apple-Mach** libdispatch — `lib/libdispatch` (rmxOS `alpha`)
- decision: **ACCEPTED (Coordinator, 2026-06-22)** — stay on this base; do NOT adopt
  swift-corelibs-libdispatch or apple-oss-distributions/libdispatch.
- index: [subsystem.md](subsystem.md). Deep first-hand evidence also in
  [libdispatch-assessment.md](../../libdispatch-assessment.md).
  Verify file:line against the tree before acting (source moves).

## Why this exists

libdispatch sits directly atop our Mach IPC + kqueue foundation and underneath libxpc,
notifyd, launchd, and the Swift concurrency track — so the *base* choice is load-bearing for
the whole userland. This records the accepted base + the evidence, so "should we switch to an
upstream?" is not re-litigated every time a port bug surfaces.

## Lineage verdict — classic Apple Mach-native, not the modern event-subsystem fork

First-hand markers (`lib/libdispatch/src/`, 2026-06-22):
- **Mach-native machinery present:** `protocol.defs` (MIG), `mach-notify-decode.h`,
  `voucher.c`/`voucher_internal.h`; `mach_msg`/`mach_port` throughout `source.c`, `queue.c`,
  `voucher.c`, `init.c`, `once.c`.
- **Monolithic `source.c`** with the classic manager thread (`_dispatch_mgr_thread`),
  `_dispatch_kevent_timeout[]`, `_dispatch_kevent_machport_resume`, `_dispatch_kq_update`
  over `struct kevent64_s`.
- **No `event/` subsystem** — no `event_kevent.c` / `event_epoll.c` / `dispatch_unote_t` /
  firehose. This is the pre-refactor Apple lineage whose Mach `dispatch_source`/`dispatch_mach`
  semantics track Darwin closely.

The architecturally hard choice — a Mach-native dispatch riding our own Mach IPC + kqueue — is
**already made correctly**. Port defects in it are localized bugs, not a wrong foundation.

## Why NOT swift-corelibs-libdispatch (the Swift.org cross-platform fork)

- Its portable build runs on the **event subsystem** (epoll on Linux, generic kqueue) and has
  **no Mach transport off Darwin** — it would not use Mach for `dispatch_source` MACH_RECV /
  `dispatch_mach` on our base.
- Adopting it throws away the Mach-native machinery this project exists to preserve — the
  opposite of "Mach primitives outward, not Linux inward". You'd then have to *add* a Mach
  backend from scratch: more work, higher blast radius, regresses what already works.

## Why NOT apple-oss-distributions/libdispatch (the modern macOS drop)

- It **hard-depends on XNU-only kernel features**: `kevent_qos`/`kevent_id` workloops,
  `pthread_workqueue` kqworkq/kqworkloop, `_dispatch_kevent_workqueue`, `__OS_EXPOSE_INTERNALS__`.
- Those are exactly the kernel pieces parked as future — `bl-001` (kevent64/kevent_qos) and
  `bl-003` (kernel `filt_machport`). Adopting it *forces* the deferred kernel track up front —
  **more** intrusive (kernel-side), not less.

## The sweet spot (why the current base is right)

Classic NextBSD libdispatch gives **Darwin Mach fidelity WITHOUT requiring the full XNU
kevent_qos/workloop kernel substrate.** Swapping bases breaks one of the two: swift-corelibs
loses Mach; apple-oss forces the parked kernel work. For "basic working first," fixing
localized port defects in the base we have is the least-intrusive path (consistent with
`donor > XNU-ref > local`).

## Known gaps in the base (localized port defects — tracked, not base failures)

- **`dispatch_after` non-firing** (op-091/op-092 → op-093, in flight): localized to the
  manager timer path *above* the kevent (`source.c` `_dispatch_kq_update` arming, flags=0;
  kernel `EVFILT_TIMER` = `timer_filtops` confirmed working in-guest). Root cause (a): the
  `_dispatch_source_set_timer2` → `_dispatch_barrier_async_detached_f(&_dispatch_mgr_q,…)`
  handoff during manager bootstrap. Surgical fix in progress.
- **`dispatch_source` MACH_RECV non-firing** (op-091, parked → `bl-003`): kernel
  `EVFILT_MACHPORT = { &null_filtops }` (`sys/kern/kern_event.c:391`; no `filt_machport` in
  `sys/`). A *kernel* foundation gap, not a libdispatch defect — libdispatch already registers
  the kevent over `kevent64_s` correctly.
- **kevent64 substrate** (`bl-001`): libdispatch's internal kqueue struct is already
  `kevent64_s`; the userland `freebsd_kevent64.c` shim is deliberately lossy
  (`flags != 0 → ENOTSUP`). Real kernel kevent64 is the future substrate.
- **QoS `UNSPECIFIED` round-trip** (`bl-002`): pthread-attr-side accept-and-normalize vs Darwin
  EINVAL — a parity-hardening catalog item.
- **Latent (non-NORMAL QoS timers):** CRITICAL/BACKGROUND timers carry XNU
  `NOTE_CRITICAL`/`NOTE_BACKGROUND` fflags the kernel `filt_timervalidate` would reject;
  NORMAL-QoS `dispatch_after` is unaffected. Not yet cataloged (offered as bl-004).

## Fit with the roadmap

- **Now (basic-working-first):** keep the base; close `dispatch_after` (op-093), reach
  `dispatch_primitives` full parity. The MACH_RECV leg waits on the parked kernel track.
- **Future kernel track:** `bl-001` (kevent64) + `bl-003` (`filt_machport`) are the substrate
  that closes `dispatch_source` MACH_RECV parity and unlocks `kevent_qos`/workloops later.
  Coordinator-held strategy gates (A-vs-B, placement) before promotion.
- libdispatch is the consumer that integration-tests Mach IPC + kqueue and the layer
  libxpc/notifyd/launchd/Swift-concurrency bind to — its C/ABI surface must stay STABLE.

## Recommendation

Treat the NextBSD classic-Apple-Mach libdispatch as the **owned base** — harden in place.
Upstreams are a non-fit in both directions and are not revisited absent a new reason. Fix
localized port defects against op-092-style layer-exoneration discipline (exonerate each layer
first-hand before touching code), keep fixes surgical, and route kernel-substrate gaps to the
backlog, not into libdispatch edits.
