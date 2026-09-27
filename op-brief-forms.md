# Op briefs and REPORTs

Every op is one file, `doc/activation/op-NNN-activation.md`, created with `tools/rob new`. Its
front matter is the op's state; its body is the brief. The Coordinator relays every brief and every
REPORT by hand. (Rewritten 2026-09-28; supersedes the short/normal/long-form convention.)

## Front matter

```yaml
id: op-NNN
state: draft
agent: <role and named instance, e.g. gatekeeper rmx-gatekeeper-rx-x64z>
repo: <the exact repo the deliverable lands in; the agent must own it>
idq: <id-NNN this op serves>
needs: [<op-NNN>, ...]        # optional
gate: self | validator | both  # expected review size; S/M self, L one, XL/critical-path both
authority: <what is allowed: e.g. build-only, no guest; or guest attempts: 1>
```

## Brief body

Written for the agent, not for a human deep-read. Keep every binding path, pin, signature,
marker, limit, and stop condition; cut narration. Sections:

1. **Outcome** — the observable result and what evidence proves it.
2. **Inputs** — exact paths, commits, hashes.
3. **Do / don't** — scope, authority, attempt budget, stop conditions.
4. **REPORT** — the block below, verbatim.

When the Coordinator asks for a brief, show it with `tools/rob show op-NNN` as one clean
copy-paste block: no line numbers, no box-drawing. Showing a brief does not send it.

## REPORT (every agent returns this)

```text
REPORT op-NNN
agent:      <role / instance>
outcome:    DONE | PARTIAL | BLOCKED | FAILED — one line
evidence:   <path> sha256:<hash>   (one per line; raw artifacts, not summaries)
commits:    <repo> <hash> on-origin:<yes|no>   (or none)
untested:   <what was not covered, or none>
blockers:   <what stops further progress, or none>
next:       <single smallest next action>
```

Validators add two lines: `score: <n>/10` and `verdict: CLOSE | DO-NOT-CLOSE | REMEDIATE`.
