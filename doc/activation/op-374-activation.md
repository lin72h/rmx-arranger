---
id: op-374
state: draft
agent: explorer2
repo: mm4:/Users/linz/Local/wip-mach/rmx-explorer2
idq: none (onboarding)
gate: self
authority: none
updated: 2026-09-28T03:44Z
---
# op-374 — Explorer 2: onboarding and baseline from disk

## Outcome

You are Explorer 2 (`rmx-explorer-mx-a64z`) on the M4 Mac mini, starting fresh under the workflow
adopted on 2026-09-28. Your repo is now `/Users/linz/Local/wip-mach/rmx-explorer2`, renamed from
`rmx-explorer`, which stays as a temporary symlink. The Explorer's two seats no longer share a
repo: you are the mx seat and explorer1 on the FreeBSD host is the rx seat, each with its own
private GitHub repo. The old shared `lin72h/rmx-explorer` is history, reachable as your `shared`
remote. AGENTS.md and OPS.md are now rendered by the Arranger from the template copied beside your
repo at `/Users/linz/Local/wip-mach/rmx-explorer0` (read-only); never edit them, and keep your
notes in LOCAL.md. `ONBOARDING.md` moved to `docs/` as history, and earlier session context is
superseded. This op succeeds when you have read AGENTS.md, OPS.md, and LOCAL.md and reported this
baseline as facts read from disk:

1. Repo state: branch, HEAD, commits not on origin, and dirty paths.
2. Tooling: which probes and truth-capture tools here can run today, and which Xcode, Swift, Zig,
   Elixir, and Erlang versions a login shell provides. Xcode was reinstalled on 2026-09-28.
3. The newest macOS truth in this repo (`findings/mx-a64z`, `mx-a64z/`, `macos-validation/`): what
   each capture checked, on which macOS version and build, and its recorded result.
4. Anything in AGENTS.md or OPS.md that is unclear or conflicts with what you find, as a blocker.

## Limits

Read-only: no file edits, commits, probe runs, or traces. Read-only commands such as `--version`
and `git log` are fine.

Defaults and the REPORT block: OPS.md in your repo.
