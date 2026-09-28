---
id: op-363
state: closed
agent: implementer
repo: rmx-implementer
idq: none (rename cleanup)
gate: self
authority: none
updated: 2026-09-28T00:01Z
---
# op-363 — Implementer: remove hard-coded wip-gpt paths from tracked scripts

## Outcome

These seven tracked scripts no longer hard-code `/Users/me/wip-mach/wip-gpt`; each derives the
repo root from its own location, or where that is impractical uses
`/Users/me/wip-mach/rmx-implementer`:

- `scripts/verify-phase1-current-tree.sh`
- `scripts/dispatch/preflight-phase095a-notifyd-n2-mach-send.sh`
- `scripts/dispatch/preflight-phase095a-notifyd-n2-mach-raw-notify.sh`
- `scripts/dispatch/preflight-phase095a-notifyd-n2-mach-direct-kevent.sh`
- `scripts/dispatch/preflight-phase095a-notifyd-n2-dispatch-notify-trace.sh`
- `scripts/notifyd/preflight-phase095a-notifyd-n2-concurrency.sh`
- `scripts/notifyd/preflight-phase095b-notifyd-n2c2b-client-death.sh`

Done when `git grep -n /Users/me/wip-mach/wip-gpt -- scripts` prints nothing, `sh -n` passes on
each changed script, and the change is committed.

## Limits

- Syntax checks only. Do not run these scripts; they are guest preflights.

Defaults and the REPORT block: OPS.md in your repo.
