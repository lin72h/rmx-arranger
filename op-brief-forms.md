# Op briefs and REPORTs

Every op is one file, `doc/activation/op-NNN-activation.md`, created with `tools/rob new`. Its
front matter is the op's state; its body is the brief. The Coordinator relays every brief and every
REPORT by hand. (Rewritten 2026-09-28; supersedes the short/normal/long-form convention.)

## Where each part lives

- **Each role repo's `OPS.md`** is that role's standing op contract: what a brief contains, the
  defaults that apply unless a brief says otherwise, and the REPORT block. It is rendered from the
  role's template (roles.md § Templates and instances), and the role's `AGENTS.md` links it.
- **The brief** carries only what is specific to its op. Never repeat the defaults or the REPORT
  block in it.
- Until a role repo has an `OPS.md`, add that role's defaults and the REPORT block to the brief.
- The Arranger maintains every role repo's `AGENTS.md` and `OPS.md` directly (one-way access,
  `roles.md` § Edges). Briefs never point agents at this repo.

## Front matter

```yaml
id: op-NNN
state: draft
agent: <instance id: implementer for a singleton, validator2 for a numbered instance>
repo: <the exact repo the deliverable lands in, e.g. rmx-implementer, or host:/path on another host; the agent must own it>
idq: <id-NNN this op serves>
needs: [<op-NNN>, ...]        # optional
gate: self | validator | both  # expected review size; S/M self, L one, XL/critical-path both
authority: <everything allowed beyond the role's defaults: e.g. build-only; guest attempts: 1>
expected: <upper bound of the brief's Expected time, e.g. 2h or 45m; `rob board` flags the op overdue past it>
```

## Brief body

`tools/rob show op-NNN` prints the title, a header line built from the front matter, then:

1. **Outcome** — the observable result and the evidence that proves it.
2. **Inputs** or **Limits** — only when the op needs paths or limits beyond the role's defaults.
3. One closing line pointing to the role's `OPS.md` (the `rob new` template adds it).

Word briefs that touch crashes, panics, fuzzing or sanitizers by [safety-flag-avoidance.md](safety-flag-avoidance.md).
Written for the agent, not for a human deep-read: keep every binding path, pin, signature,
marker, limit, and stop condition; cut narration. When the Coordinator asks for a brief, show the
`tools/rob show` output as one clean copy-paste block with no line numbers and no box-drawing.
Showing a brief does not send it.

## REPORT (source: `rmx-role0/partials/report.md`; this copy is for reference)

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

Validators add four lines after `outcome`: `question:` (the distinguishing question), `access:`
(primary | indirect | none, and what was read first-hand), `score: <n>/10 — because …`, and
`verdict: CLOSE | DO-NOT-CLOSE | REMEDIATE`. Their `OPS.md` holds the exact block.

## NOTICE (Arranger → agent, relayed by the Coordinator)

Send one when an Arranger change in an agent's repo could affect what the agent knows or is
working on; skip it otherwise. A change to a role's `OPS.md` alone needs none, because every brief
ends with "Re-read OPS.md first: defaults and the REPORT block." A notice is not an op: no REPORT
and no state. If the agent has an op in flight, relay the notice before that op's REPORT is due.

```text
NOTICE from the Arranger — <YYYY-MM-DD>
changed:  <repo-relative paths>
meaning:  <what is different for you, one to three lines>
action:   none | re-read <files> before your next step | <specific instruction>
```
