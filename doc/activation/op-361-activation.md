---
id: op-361
state: draft
agent: implementer
repo: rmx-implementer
idq: none (onboarding)
gate: self
authority: read-only: no edits, commits, builds, or guest runs
updated: 2026-09-27T23:21Z
---
# op-361 — Implementer: onboarding to the 2026-09-28 workflow

## Outcome

You are the Implementer, starting fresh under the workflow adopted on 2026-09-28. Your repo
was renamed from `wip-gpt` to `/Users/me/wip-mach/rmx-implementer` and its instructions were
rewritten. Earlier session context, handoff documents, and in-flight plans are superseded:
do not resume earlier work. This op succeeds when you have read the new instructions and
reported the product baseline below as facts read from disk.

Report, in `evidence` or `next` as fits:
1. Both repos: branch, HEAD, dirty paths, and commits not on origin, for this repo and for
   `wip-rmxos`.
2. `wip-rmxos` linked worktrees, and for the alpha2 candidate
   (`/Users/me/wip-mach/build/alpha2-stable15-sync-20260921`): HEAD and its dirty paths.
3. The newest build directory under `build/` (expected `op358-alpha2-20260925T000042Z`):
   what it built and its recorded result, if the directory records one.
4. Tracked scripts that still hard-code `/Users/me/wip-mach/wip-gpt`.
5. Anything in AGENTS.md that is unclear or conflicts with what you find, as a blocker.

## Inputs

- /Users/me/wip-mach/rmx-implementer/AGENTS.md (read first; CLAUDE.md imports it)
- /Users/me/wip-mach/rmx-implementer/build/
- /Users/me/wip-mach/build/alpha2-stable15-sync-20260921

## Do / don't

- Read-only. No file edits, commits, pushes, builds, staging, or guest runs.
- Report what is on disk; do not infer results a directory does not record.
- Stop and report BLOCKED if a path above is missing.

## REPORT

Return exactly this block:

```text
REPORT op-361
agent:      <role / instance>
outcome:    DONE | PARTIAL | BLOCKED | FAILED — one line
evidence:   <path> sha256:<hash>   (one per line; raw artifacts, not summaries)
commits:    <repo> <hash> on-origin:<yes|no>   (or none)
untested:   <what was not covered, or none>
blockers:   <what stops further progress, or none>
next:       <single smallest next action>
```
