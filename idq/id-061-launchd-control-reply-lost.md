# id-061 — launchd intermittently does not answer a control request; shutdown then does not finish

- priority: high (proposed; Coordinator sets) — PID-1 launchd is the preview path (id-016)
- state: OPEN — reproduced; cause unknown
- raised: 2026-10-07, from op-521, op-526, op-529

## What is wrong

Under repeated runs of `launchd_consumer_test` (`demand_removed`, `close_unregistered`,
`late_dead_name`, `setup_retry`), a control request to launchd (PID 1) occasionally gets no reply
within 8 s ("launchd control reply missing"); after that the guest does not power off within 60 s
of "System shutdown time has arrived".

- op-521 (gatekeeper1, `mach-fixes-6@0facf74b`): three cases in one run.
- op-526 (Implementer, `ab26bbed` kernel): `setup_retry` after 71 passing cases; launchd's main
  thread in `ipc_mqueue_receive`; the demand set had no members and nothing ready.
- op-529 (Implementer, the op-511-proven `mach-fixes-5@2de5f1d4` kernel and `mach.ko`, all other
  files identical): `close_unregistered` in iteration 24 (about 100 cases); shutdown timeout.
  Serial `/Users/me/wip-mach/stage/vm/runs/op529-selfcheck/rmx-selfcheck-op529-old-1791348061/serial.txt`,
  sha256 `fb26e6109a535a3088defaee9d47fab7b847c26e1342c99963bb0fdaa0befc61`.

So it predates `mach-fixes-6` (readiness-only kevents). Earlier single-run proofs (op-498, op-505,
op-511) passed these cases; none repeated them.

## Why it matters

A PID-1 launchd that occasionally drops a control request and then cannot shut down blocks the
preview (id-016, id-042).

## What would close it

The cause named with file:line, a fix, and a bounded repeat test (hundreds of launchd cases)
passing with normal power-off, on the candidate kernel.

## Notes for the next op

Record state from launchd's own test build (logging in its receive loop under its existing
`LAUNCHD_CONSUMER_TESTING` blocks) or from the kernel side; do not wrap or intercept launchd's calls
from a preloaded library (safety-flag-avoidance.md rule 8; op-529's session was stopped while
building that).
