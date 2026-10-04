# Op briefs, replies and casts

Every op is one file, `doc/activation/op-NNN-activation.md`, created with `tools/rob new`. Its
front matter is the op's state; its body is the brief. The Coordinator relays every brief and every
reply by hand. (Rewritten 2026-09-28; supersedes the short/normal/long-form convention.)

## Where each part lives

- **Each role repo's `OPS.md`** is that role's standing op contract: what a brief contains, the
  defaults that apply unless a brief says otherwise, and the reply block. It is rendered from the
  role's template (roles.md § Templates and instances), and the role's `AGENTS.md` links it.
- **The brief** carries only what is specific to its op. Never repeat the defaults or the reply
  block in it.
- Until a role repo has an `OPS.md`, add that role's defaults and the reply block to the brief.
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

## Reply (source: `rmx-role0/partials/report.md`; this copy is for reference)

A call is answered by a **reply**, a unicast cast from the agent headed `reply to op-NNN`. Record
it with `tools/rob reply op-NNN <file>`: it becomes the next `op-NNNu` with `answers: op-NNN`, closed
on arrival, and the call becomes `returned` (meta-012; the reply is retired).

```text
reply to op-NNN
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

## Casts: ops without a reply (op-NNNu, op-NNNb) — replaces the NOTICE (meta-008)

An op is a **call** (a brief answered by a reply cast) or a **cast** (a message that expects no reply,
after Erlang's `gen_server:cast`). Casts take the next op number with a suffix: **op-NNNu** unicast
to one agent (`tools/rob new "<title>" agent=<id> repo=<repo> cast=u`); **op-NNNb** broadcast to all
direct subagents (`agent=all repo=all cast=b`). Send one when an Arranger change could affect what an
agent knows or is working on (a change to `OPS.md` alone needs none). A cast retires when sent:
`tools/rob set op-NNNu closed`. Body:

```text
## Message

changed:  <repo-relative paths, with commits>
meaning:  <what is different for the reader, one to three lines>
action:   none | re-read <files> before your next step | <specific instruction>

This is a cast: no reply is expected.
```
