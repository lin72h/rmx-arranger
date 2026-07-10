# op-brief-forms — the three forms of an op activation brief

A presentation convention for the Arranger, paired with [rob-mini-format.md](rob-mini-format.md).
An op activation brief exists in **three forms** (named by the Coordinator 2026-06-25). Same op,
different audience — pick the form by who is reading.

## The three forms

- **short-form** — the chat bullet: one ROB-style line (`op-NNN [STATUS] (role) — desc`) or a
  couple of sentences. Human quick-scan only; **never** the dispatch artifact.
- **normal-form** — *the agent-facing dispatch artifact*. Every binding constraint / path /
  signature / marker / verdict-route kept; explanatory prose and human framing stripped; a terse
  "why" retained ONLY where it guides an edge-case judgement. Directive and scannable. **This is
  the DEFAULT for issuing ops** — the activation `.md` file that the agent reads (and that I paste
  for dispatch) IS normal-form.
- **long-form** — the full prose record (§0–§7 style). Good for a *human* deep-read; NOT what
  agents receive.

## normal-form is the dispatch artifact

The on-disk `doc/activation/op-NNN-activation.md` is authored in normal-form by default. Keep all
load-bearing content — state header, gates, objective, exact signatures/paths, do/don't
constraints, verdict routing, markers, relations/carrier chain — and cut only narrative repetition
and readability padding.

**Name the concrete EXU instance.** A normal-form brief MUST bind a named execution unit in the
header (e.g. `EXU: rmx-gatekeeper-rx-x64z`), never a bare `role: Explorer (FREE)` / "Coordinator
assigns". When a role has more than one instance, pin which one and a one-line assignment rationale
(owns that line / guest / prior op). Binding ≠ dispatch — the Arranger binds + releases, the
Coordinator dispatches.

## "show me op-NNN in normal-form" (the human command)

When the Coordinator asks to *see* an op in normal-form, output the brief's **raw content as clean,
copy-pasteable text in the reply** — a fenced block or plain text, no line-number prefixes, no
Read-tool numbered dump. The Coordinator copies the shown content and pastes it onward, so it must
be paste-ready. Reading the file first to get exact content is fine; just reproduce it clean.

## Rendering rules

- Issue / author an op → **normal-form** (the `.md` file).
- Report live ops in a reply → **short-form** (the ROB list, [rob-mini-format.md](rob-mini-format.md)).
- Human wants to deep-read the rationale → render **long-form** on request.
- Lean plain-text throughout — no box-drawing rules, no decorative tables (paste-unfriendly,
  token-wasteful).

## References

- [rob-mini-format.md](rob-mini-format.md) — the companion ROB summary convention.
- [arranger-rulebook.md](arranger-rulebook.md) — Arranger craft (Rule 4: lean plain-text issue block).
- [terminology.md](terminology.md) §6 — the OoO model these ops flow through.
