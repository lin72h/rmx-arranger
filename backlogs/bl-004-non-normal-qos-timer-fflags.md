# bl-004 — non-NORMAL QoS dispatch timers: XNU `NOTE_CRITICAL`/`NOTE_BACKGROUND` fflags

- id: bl-004
- state: WAITING (not fetched) — latent parity-hardening item, not a blocker. Cataloged for
  overclaim-strict honesty, not yet scheduled.
- raised: 2026-06-22 (surfaced while closing `dispatch_after`, op-093/op-094/op-096)
- lane (when promoted): evidence-lane (behavioral/parity claim), libdispatch userland +
  kernel `filt_timer` validate path
- relation to in-flight work: none blocking. `dispatch_after` (NORMAL QoS) is CLOSED at
  `129ee3c` and is unaffected by this.

## The gap (first-hand basis)

libdispatch timer sources at **non-NORMAL QoS** (CRITICAL / BACKGROUND) carry XNU timer
`fflags` — `NOTE_CRITICAL` / `NOTE_BACKGROUND` — that the FreeBSD kernel `filt_timervalidate`
path would reject. The NORMAL-QoS timer path (the one `dispatch_after` rides) does not set
these fflags, so it is unaffected — which is why op-094 saw a clean
submit→accept→fire→deliver chain for NORMAL QoS.

## Why it's parked, not fixed now

- Non-gating for basic-working dispatch: NORMAL-QoS `dispatch_after` / `dispatch_source` timers
  work (op-094 proved the kevent path end-to-end).
- It only matters once we make a *strict* QoS-timer macOS-parity claim across CRITICAL /
  BACKGROUND classes.
- Consistent with "basic working first" — the non-NORMAL QoS classes are a later parity tier.

## Scope (when promoted)

**In:** decide how the non-NORMAL QoS timer fflags are handled — either teach the kernel
`filt_timervalidate` to accept/ignore the XNU timer fflags (kernel-side, RESTRICTED-adjacent),
or normalize/strip them userland-side in libdispatch before the kevent (least-intrusive,
`donor > XNU-ref > local`). Explorer macOS reference vector for the CRITICAL/BACKGROUND timer
behavior.

**Out:** NORMAL-QoS timers (done); the MACH_RECV / `filt_machport` kernel gap (that's bl-003).

## Open decision (Coordinator-held)

Userland-normalize the fflags (least-intrusive, likely first choice) vs kernel-side accept in
`filt_timervalidate` (more faithful but kernel-side). Pick when QoS-timer parity is scheduled.
