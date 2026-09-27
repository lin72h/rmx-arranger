# op-brief-forms — the three forms of an op activation brief

A presentation convention for the Arranger, paired with [rob-mini-format.md](rob-mini-format.md).
An op activation brief exists in **three forms** (named by the Coordinator 2026-06-25). Same op,
different audience — pick the form by who is reading.

## The three forms

- **short-form** — one op's chat bullet (`op-NNN [STATUS] (role) — desc`) or a couple of
  sentences. This is the same per-op syntax used by ROB **list form**, but it is not the default
  whole-ROB rendering. Human quick-scan only; **never** the dispatch artifact.
- **normal-form** — *the agent-facing dispatch artifact*. Every binding constraint / path /
  signature / marker / verdict-route kept; explanatory prose and human framing stripped; a terse
  "why" retained ONLY where it guides an edge-case judgement. Directive and scannable. **This is
  the DEFAULT for issuing ops** — by default its complete content is rendered directly in the
  reply as one terminal/copy-paste-ready block. If the Coordinator explicitly requests Markdown
  file delivery instead, that file's complete content is the normal-form artifact.
- **long-form** — the full prose record (§0–§7 style). Good for a *human* deep-read; NOT what
  agents receive.

## normal-form content is the dispatch artifact

The complete content—not a filename, link, synopsis, or terminal REPORT stub—is what the
Coordinator dispatches. By default, generate or show it in the reply and do not create or update an
activation Markdown file. Only an explicit Coordinator request to write/save the op as Markdown
authorizes that persistence. Keep all load-bearing content: state header, gates, objective, exact
signatures/paths, do/don't constraints, verdict routing, markers, relations/carrier chain. Cut only
narrative repetition and readability padding. If an on-disk `doc/activation/op-NNN-activation.md`
(or explicitly labeled meta-control `op-NNNm-activation.md`) already exists as authoritative state,
it still does not replace showing the full brief in the reply.

**Name the concrete EXU instance.** A normal-form brief MUST bind a named execution unit in the
header (e.g. `EXU: rmx-gatekeeper-rx-x64z`), never a bare `role: Explorer (FREE)` / "Coordinator
assigns". When a role has more than one instance, pin which one and a one-line assignment rationale
(owns that line / guest / prior op). Binding ≠ dispatch — the Arranger binds + releases, the
Coordinator dispatches.

## Full terminal output is the default

Whenever the Coordinator asks to generate, show, prepare, or provide an op—or the Arranger
identifies one as the next dispatch—output the brief's **complete raw normal-form content as clean,
copy-pasteable text in the reply**: one contiguous fenced block or plain-text block, with no
line-number prefixes and no Read-tool numbered dump. This applies even if the op already has an
activation file. A path, link, short normal form, summary, or REPORT-only block may accompany the
brief but never replace it.

The only exception is an explicit Coordinator instruction to write/save the op to a Markdown file
instead. Do not infer that exception merely because an activation path exists or internal state was
recorded. A terminal-only generated brief is a draft dispatch payload, not authoritative live op
state, until the Coordinator separately authorizes its activation and Rule-15 journal transition.

## Rendering rules

- Generate / show / prepare / issue an op, or identify the next dispatch → **full normal-form
  content in the terminal reply**.
- Coordinator explicitly requests Markdown-file delivery instead → write the complete normal-form
  file; terminal reproduction may then be omitted.
- Report the complete live ROB in a reply → grouped **compact ROB live board** by default.
- Coordinator asks for **list form**, or exact per-op role/description mapping is load-bearing →
  detailed one-op-per-line **ROB list form**.
- Mention op status only inside a compact ROB/status inventory → **short-form**; identifying an
  actionable next dispatch triggers the full-content rule above.
- Human wants to deep-read the rationale → render **long-form** on request.
- Lean plain-text throughout — no box-drawing rules, no decorative tables (paste-unfriendly,
  token-wasteful).

## References

- [rob-mini-format.md](rob-mini-format.md) — the companion ROB summary convention.
- [arranger-rulebook.md](arranger-rulebook.md) — Arranger craft (Rule 4: lean plain-text issue block).
- [terminology.md](terminology.md) §6 — the OoO model these ops flow through.
