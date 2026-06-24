# id-005 — `_dispatch_posix_sem_timedwait` polling → proper absolute-deadline primitive

- id: id-005
- state: WAITING (not fetched) — production-hardening item, not a blocker. Cataloged from the
  op-095V Validator reserve point, not yet scheduled.
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
