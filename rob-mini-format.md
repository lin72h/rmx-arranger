# rob-mini-format — the ROB op-summary convention

A presentation convention for the Arranger: end every op-adjudication / dispatch reply with a **ROB**
section — a compact, at-a-glance ledger of every op currently in play.

## Why "ROB"

The workflow runs on a CPU out-of-order (OoO) execution model: **`L1i (li-NNN) → IDQ (id-NNN) → ROB (op-NNN)`**
(see [terminology.md](terminology.md) §6). An L1i gate is *decoded* into IDQ items; an IDQ item is *fetched*
into ROB entr(ies). An `op-NNN` is in flight in the **ROB** until it retires ([id-000](idq/id-000.md)). The
**ROB (Reorder Buffer)** is exactly the set of in-flight ops — so the live op-summary *is* the ROB.
(Supersedes the earlier ad-hoc "State now" / "Ledger" heading.)

## Format

A simple flat list — one line per op, no tables, no box-drawing (lean plain text; paste-friendly):

```
op-NNN [STATUS] (role) — short description
```

- **op-NNN** — the op id (sequential, never reused).
- **[STATUS]** — an explicit bracketed tag (below), placed right after the id so state reads first.
- **(role)** — the executing role (Explorer / Gatekeeper / Implementer / Validator-GLM / Validator-DS4P),
  with the target pipeline if it matters (e.g. `Explorer rx-x64z`).
- **short description** — bl it carries + the one-line task.

Keep the **op-NNN** slot clean — just the id. Re-run / retry counts go in the description (e.g.
"4th run"), never glued onto the id ("op-111 re-re-re-retry" reads badly and the id never changes
across retries).

## Status vocabulary

- `[AWAITING]` — issued, awaiting Coordinator dispatch.
- `[IN-FLIGHT]` — dispatched; executing / awaiting report.
- `[QUEUED]` — issued, queued behind another op (name it, e.g. *after op-123*).
- `[HELD]` — reserved + held; the op number is assigned but not dispatched and not reused.
- `[DONE]` — retired (kept briefly for context, then drops off).

Add one line after the list only if a sequencing call is open (e.g. host contention).

## Example

ROB:
- op-111 **[AWAITING]** (Gatekeeper) — id-020 validation: clean buildworld from `efc8cb1f` (4th run; critical path)
- op-119 **[AWAITING]** (Explorer rx-x64z) — id-016 bootstrap characterize-first
- op-123 **[QUEUED]** (Gatekeeper) — id-010 notify: full Gate-C lifecycle + leg-4 soak
- op-124 **[QUEUED]** (Gatekeeper, after op-123) — id-011 asl: full Gate-C lifecycle + high-volume soak
- op-122 **[HELD]** (Explorer ×2) — id-021 libxpc leg 2, lockstep run (until id-010/011 solid)
