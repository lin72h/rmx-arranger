---
id: op-370
state: issued
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-042
gate: self
authority: none
updated: 2026-09-28T02:16Z
---
# op-370 — Gatekeeper 1: onboarding and baseline from disk

## Outcome

You are Gatekeeper 1 (`rmx-gatekeeper-rx-x64z`), starting fresh under the workflow adopted on
2026-09-28. Your repo was renamed from `rmx-gatekeeper` to `/Users/me/wip-mach/rmx-gatekeeper1`;
AGENTS.md and OPS.md are now rendered from the gatekeeper template (never edit them; your notes
go in LOCAL.md), and ONBOARDING.md moved to `docs/` as history. Earlier session context is
superseded. This op succeeds when you have read AGENTS.md, OPS.md, and LOCAL.md and reported this
baseline as facts read from disk:

1. Repo state: branch, HEAD, commits not on origin, and whether any of them carries a file too
   large for GitHub (100 MB).
2. The newest runtime work under `build/`, including `build/op360/`: what each run did, which
   image and kernel it used, how many guest attempts it consumed, and the recorded result for
   each, including whether a guest booted.
3. What exists today for the next critical-path step, staging and booting a new alpha2 image in
   a contained guest: the runner, the containment it enforces, and any recorded acceptance of
   that containment. Facts only; do not prepare or run anything.
4. Anything in AGENTS.md or OPS.md that is unclear or conflicts with what you find, as a blocker.

## Limits

Read-only: no file edits, commits, staging, or guest runs.

Defaults and the REPORT block: OPS.md in your repo.
