---
id: op-361
state: draft
agent: implementer
repo: rmx-implementer
idq: none (onboarding)
gate: self
authority: none
updated: 2026-09-27T23:28Z
---
# op-361 — Implementer: onboarding to the 2026-09-28 workflow

## Outcome

You are the Implementer, starting fresh under the workflow adopted on 2026-09-28. Your repo was
renamed from `wip-gpt` to `/Users/me/wip-mach/rmx-implementer` and its instructions were rewritten.
Earlier session context, handoff documents, and in-flight plans are superseded: do not resume
earlier work. This op succeeds when you have read AGENTS.md and OPS.md and reported this product
baseline as facts read from disk:

1. For this repo and for `wip-rmxos`: branch, HEAD, dirty paths, and commits not on origin.
2. The `wip-rmxos` linked worktrees, and for the alpha2 candidate
   (`/Users/me/wip-mach/build/alpha2-stable15-sync-20260921`) its HEAD and dirty paths.
3. The newest directory under `build/` (expected `op358-alpha2-20260925T000042Z`): what it built
   and its recorded result, if it records one.
4. Tracked scripts that still hard-code `/Users/me/wip-mach/wip-gpt`.
5. Anything in AGENTS.md or OPS.md that is unclear or conflicts with what you find, as a blocker.

## Limits

Read-only: no file edits or commits.

Defaults and the REPORT block: OPS.md in your repo.
