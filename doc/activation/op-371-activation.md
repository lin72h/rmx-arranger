---
id: op-371
state: draft
agent: gatekeeper2
repo: rmx-gatekeeper2 (on mm4)
idq: none (onboarding)
gate: self
authority: none
updated: 2026-09-28T02:07Z
---
# op-371 — Gatekeeper 2: onboarding and baseline from disk

## Outcome

You are Gatekeeper 2 (`rmx-gatekeeper-mx-a64z`) on the M4 Mac mini, starting fresh under the
workflow adopted on 2026-09-28. Your repo, `/Users/linz/Local/wip-mach/rmx-gatekeeper2`, was the
legacy unified Oracle (`mach-oracle`); its documents from that era are history. AGENTS.md and
OPS.md are now rendered by the Arranger and copied here (never edit them; your notes go in
LOCAL.md). Earlier session context is superseded. This op succeeds when you have read AGENTS.md,
OPS.md, and LOCAL.md and reported this baseline as facts read from disk:

1. Repo state: branch, HEAD, commits not on origin, and dirty paths.
2. The macOS reference tooling here: what `macos-validation/` and `lib/` can run today, and
   which Elixir, Erlang, and Zig versions a login shell provides.
3. The most recent macOS evidence in this repo (`artifacts/`, `mx-a64z/`): what each run
   checked, on which macOS version, and its recorded result.
4. Anything in AGENTS.md or OPS.md that is unclear or conflicts with what you find, as a blocker.

## Limits

Read-only: no file edits, commits, or runs.

Defaults and the REPORT block: OPS.md in your repo.
