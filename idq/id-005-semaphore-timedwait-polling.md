# id-005 — `_dispatch_posix_sem_timedwait` polling → proper absolute-deadline primitive

- id: id-005
- state: **DEFERRED POST-1.0-PREVIEW — Coordinator scope ruling 2026-07-11.** The current
  polling implementation is correctness-accepted; replacing it is efficiency/production hardening,
  not a preview blocker. Retained and not fetched.
- raised: 2026-06-22 (op-095V Validator review of the `dispatch_after` fix, commit `129ee3c`)
- lane (when promoted): evidence-lane (behavioral claim), libdispatch userland (`semaphore.c`)
- relation to in-flight work: none blocking. The op-096 `dispatch_after` fix retired with this
  as a noted, accepted trade-off (GLM 9/10 + DS4P 9/10; the reserved point on both).

## The trade-off (first-hand verified by both Validators)

`_dispatch_posix_sem_timedwait` (semaphore.c) replaced the broken `sem_timedwait`
(relative-vs-absolute deadline bug) with a **poll loop**: `sem_trywait` + capped `nanosleep`
(1ms), driven by `_dispatch_timeout(timeout)` as the single source of truth, returning
`ETIMEDOUT` when the timeout expires.

- **Correctness: right.** The relative-vs-absolute mismatch is eliminated; `_dispatch_timeout`
  is the sole timeout authority; EINTR handled; the 1ms cap prevents busy-spin.
- **Efficiency: a milestone compromise.** 1ms polling granularity = up to ~10,000 iterations
  for a 10s wait. Fine for basic-working; not ideal for production.

## Why it's parked, not fixed now

- It is a *performance* trade-off, not a correctness defect — both Validators scored it 9/10
  and explicitly retired `dispatch_after` with this known.
- "Basic working first": the wait returns correctly; the wakeup latency/efficiency is a
  later-tier polish.

## Scope (when promoted)

**In:** replace the poll loop with a proper absolute-deadline primitive — `sem_clockwait(sem,
CLOCK_MONOTONIC, &abs_deadline)` if available, or a correct absolute-deadline conversion fed to
`sem_timedwait` (CLOCK_REALTIME), so the wait blocks to the deadline instead of polling.
Preserve `_dispatch_timeout` semantics and the EINTR handling.

**Out:** the semaphore signal/wait fast path (already correct); the `dispatch_after` timer path
(closed, separate mechanism).

## Open decision (Coordinator-held)

`sem_clockwait(CLOCK_MONOTONIC)` (preferred if the FreeBSD-15 libc/guest provides it — verify
first-hand) vs absolute-deadline `sem_timedwait(CLOCK_REALTIME)`. Pick when scheduled.

## Precise coordinates + interim disposition (op-223 LEG A, Arranger-verified first-hand 2026-07-02)

- **Located precisely:** the poll loop is `semaphore.c:58-81` (`_dispatch_timeout`→`sem_trywait`→
  capped `nanosleep`, 1ms cap at `:73-75`); call sites `:373`/`:381` and `:596`/`:604`. Enabled
  because `USE_POSIX_SEM=1` / `USE_MACH_SEM` undefined (`config/config.h:175,:178`).
- **This id is the POSIX-side axis only.** It improves the *POSIX* emulation (poll → non-polling
  primitive). It is NOT about native Mach semaphores.
- **Why POSIX at all:** the kernel Mach-semaphore trap family is a wired-but-hollow shell —
  `semaphore_create` is a MIG shell (`task_server.c:3583`) but wait/signal are `UNSUPPORTED`
  (`mach_traps.c:142-158`) and timedwait is `ENOSYS` (`mach_misc.c:90-107`). Building the *real*
  Mach-semaphore primitive is the **orthogonal** future feature, cataloged at **li-9003 Item 3**.
- **Interim disposition (user, 2026-07-02):** accept the POSIX-sem solution as the near-term
  "simple solution that works now" (it does — correctness already Validator-confirmed above). The
  non-polling polish here stays a later-tier item; native Mach semaphores are li-9003 Item 3.
  Don't conflate the two axes.
