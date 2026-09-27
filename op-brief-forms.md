# Op briefs and REPORTs

Every op is one file, `doc/activation/op-NNN-activation.md`, created with `tools/rob new`. Its
front matter is the op's state; its body is the brief. The Coordinator relays every brief and every
REPORT by hand. (Rewritten 2026-09-28; supersedes the short/normal/long-form convention.)

## Where each part lives

- **Each role repo's `OPS.md`** is that role's standing op contract: what a brief contains, the
  defaults that apply unless a brief says otherwise, and the REPORT block (copied from below). The
  role's `AGENTS.md` links it. First: `rmx-implementer/OPS.md`.
- **The brief** carries only what is specific to its op. Never repeat the defaults or the REPORT
  block in it.
- Until a role repo has an `OPS.md`, add that role's defaults and the REPORT block to the brief.

## Front matter

```yaml
id: op-NNN
state: draft
agent: <role and named instance, e.g. gatekeeper rmx-gatekeeper-rx-x64z>
repo: <the exact repo the deliverable lands in; the agent must own it>
idq: <id-NNN this op serves>
needs: [<op-NNN>, ...]        # optional
gate: self | validator | both  # expected review size; S/M self, L one, XL/critical-path both
authority: <everything allowed beyond the role's defaults: e.g. build-only; guest attempts: 1>
```

## Brief body

`tools/rob show op-NNN` prints the title, a header line built from the front matter, then:

1. **Outcome** — the observable result and the evidence that proves it.
2. **Inputs** or **Limits** — only when the op needs paths or limits beyond the role's defaults.
3. One closing line pointing to the role's `OPS.md` (the `rob new` template adds it).

Written for the agent, not for a human deep-read: keep every binding path, pin, signature,
marker, limit, and stop condition; cut narration. When the Coordinator asks for a brief, show the
`tools/rob show` output as one clean copy-paste block with no line numbers and no box-drawing.
Showing a brief does not send it.

## REPORT (canonical; each OPS.md copies it)

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
