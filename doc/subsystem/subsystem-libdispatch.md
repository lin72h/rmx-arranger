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

- **`dispatch_after` non-firing** — **CLOSED** (op-091/092/093 → op-096, commit `129ee3c`,
  origin-reachable; retired 2026-06-22 by GLM 9/10 + DS4P 9/10). Real fix = the
  `freebsd_kevent64.c` stack-backed shim + the `semaphore.c` relative-vs-absolute `sem_timedwait`
  fix (`_dispatch_posix_sem_timedwait`, `_dispatch_timeout` as single source of truth). op-094
  **disproved** the earlier `_dispatch_source_set_timer2` → `_dispatch_mgr_q` handoff hypothesis:
  a correlated DTrace `pid` + `syscall::kevent*` + `fbt::filt_timer*` trace showed the
  `EVFILT_TIMER` kevent is submitted, accepted, fired, and delivered. op-093's manager poll
  fallback (premise "FreeBSD may not report `EVFILT_TIMER`") was therefore redundant and was
  removed in op-096. Follow-up (non-blocking): `semaphore.c` uses 1ms polling — a
  production-hardening item (`sem_clockwait`/absolute deadline), cataloged in the backlog.
- **`dispatch_source` MACH_RECV** — **WORKS (op-098, bl-003 DROPPED 2026-06-22).** The earlier
  "kernel gap" framing was a scoping error: `kern_event.c:391`'s `null_filtops` is only the
  static default; **`mach.ko` registers a real `filt_machport`** at module load
  (`sys/compat/mach/ipc/ipc_pset.c:504` + `sys/compat/mach/mach_module.c:270`
  `kqueue_add_filteropts`). op-098 runtime DTrace on a genuine round-trip traced the standard
  kqueue path end-to-end (`filt_machportattach → filt_machport×3 → handler → mach_msg_receive →
  filt_machportdetach`). libdispatch registers the kevent over `kevent64_s` correctly and the
  kernel filter services it. (op-091's "no `filt_machport` in `sys/`" came from a `sys/kern/`-only
  grep that missed `sys/compat/mach/`.)
- **kevent64 substrate** (`bl-001`): libdispatch's internal kqueue struct is already
  `kevent64_s`; the userland `freebsd_kevent64.c` shim is deliberately lossy
  (`flags != 0 → ENOTSUP`). Real kernel kevent64 is the future substrate.
- **QoS `UNSPECIFIED` round-trip** (`bl-002`): pthread-attr-side accept-and-normalize vs Darwin
  EINVAL — a parity-hardening catalog item.
- **Latent (non-NORMAL QoS timers)** (`bl-004`): CRITICAL/BACKGROUND timers carry XNU
  `NOTE_CRITICAL`/`NOTE_BACKGROUND` fflags the kernel `filt_timervalidate` would reject;
  NORMAL-QoS `dispatch_after` is unaffected.
- **Semaphore timedwait polling** (`bl-005`): the `dispatch_after` fix's
  `_dispatch_posix_sem_timedwait` (semaphore.c) uses a 1ms poll loop — correct but a
  production-hardening item (move to `sem_clockwait`/absolute deadline).

## Fit with the roadmap

- **Now (basic-working-first): DONE for the primitive surface (op-098 RETIRED, GLM+DS4P both
  RETIRE, 2026-06-22).** `dispatch_after` closed (op-096); `dispatch_source` MACH_RECV works via
  `mach.ko`'s real `filt_machport` (op-098 T1 — runtime DTrace traced the kernel filter
  end-to-end); primitive surface async/sync/apply/once/barrier (block + `_f`) + NORMAL-QoS timer
  all GREEN at 129ee3c (op-098 T2 serial: `op098_t2_fails=0`). The `_f` variants (Zig/CoRT
  Tier-1 binding surface) are at parity with the block variants. Caveat (honest scope): basic
  parity is **exit-code-proven** on top of independently DTrace-traced machinery (kqueue/
  EVFILT_TIMER/EVFILT_MACHPORT/TWQ), not per-primitive USDT (libdispatch built
  `-DDISPATCH_USE_DTRACE=0`). Residual non-blockers: bl-004 (non-NORMAL-QoS timer fflags, latent),
  bl-005 (semaphore 1ms poll, hardening).
- **Future kernel track:** `bl-001` (kevent64) is the remaining substrate that unlocks
  `kevent_qos`/workloops later. (bl-003 `filt_machport` is no longer part of this track — the
  filter already exists via `mach.ko`.) Coordinator-held strategy gates (A-vs-B) before promotion.
- libdispatch is the consumer that integration-tests Mach IPC + kqueue and the layer
  libxpc/notifyd/launchd/Swift-concurrency bind to — its C/ABI surface must stay STABLE.

## Recommendation

Treat the NextBSD classic-Apple-Mach libdispatch as the **owned base** — harden in place.
Upstreams are a non-fit in both directions and are not revisited absent a new reason. Fix
localized port defects against op-092-style layer-exoneration discipline (exonerate each layer
first-hand before touching code), keep fixes surgical, and route kernel-substrate gaps to the
backlog, not into libdispatch edits.
