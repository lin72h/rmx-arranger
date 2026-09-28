---
id: op-373
state: draft
agent: explorer1
repo: rmx-explorer1
idq: none (onboarding)
gate: self
authority: none
updated: 2026-09-28T03:44Z
---
# op-373 — Explorer 1: onboarding and baseline from disk

## Outcome

You are Explorer 1 (`rmx-explorer-rx-x64z`), starting fresh under the workflow adopted on
2026-09-28. Your repo is now `/Users/me/wip-mach/rmx-explorer1`, renamed from `rmx-explorer`,
which stays as a temporary symlink. The Explorer's two seats no longer share a repo: you are the
rx seat and explorer2 on mm4 is the mx seat, each with its own private GitHub repo. The old shared
`lin72h/rmx-explorer` is history, reachable as your `shared` remote. AGENTS.md and OPS.md are now
rendered by the Arranger from the template at `/Users/me/wip-mach/rmx-explorer0`; never edit them,
and keep your notes in LOCAL.md. `ONBOARDING.md` moved to `docs/` as history, and earlier session
context is superseded. This op succeeds when you have read AGENTS.md, OPS.md, and LOCAL.md and
reported this baseline as facts read from disk:

1. Repo state: branch, HEAD, commits not on origin, and dirty paths.
2. Tooling: which probes, harnesses, and checkers here can run today, and which Zig, Elixir, and
   Erlang versions this host provides.
3. The newest Explorer work in this repo (findings, the mismatch ledger `findings/nx-r64z`, probe
   runs): what each checked, on which target and version, and its recorded result.
4. Anything in AGENTS.md or OPS.md that is unclear or conflicts with what you find, as a blocker.

## Limits

Read-only: no file edits, commits, probe runs, or guest runs. Read-only commands such as
`--version` and `git log` are fine.

Defaults and the REPORT block: OPS.md in your repo.
