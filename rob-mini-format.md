# rob-mini-format — the ROB live-board convention

A presentation convention for the Arranger: end every op-adjudication / dispatch reply with a **ROB**
section containing every op currently in play. The grouped **compact live board** is the default;
the former detailed one-op-per-line rendering is retained as **list form**.

## Why "ROB"

The workflow runs on a CPU out-of-order (OoO) execution model: **`L1i (li-NNN) → IDQ (id-NNN) → ROB (op-NNN)`**
(see [terminology.md](terminology.md) §6). An L1i gate is *decoded* into IDQ items; an IDQ item is *fetched*
into ROB entr(ies). An `op-NNN` is in flight in the **ROB** until it retires ([id-000](idq/id-000.md)). The
**ROB (Reorder Buffer)** is exactly the set of in-flight ops — so the live op-summary *is* the ROB.
(Supersedes the earlier ad-hoc "State now" / "Ledger" heading.)

## Presentation forms

### Compact ROB live board — DEFAULT

Group op ids by canonical status and put comma-separated ids on one line:

The following is an **illustrative shape**, not a durable state record; activation headers are live
truth.

```text
Live ROB:
- [Exe]: op-270, op-286, op-287, op-292
- [Ready]: op-272, op-276, op-289, op-291
- [Hold]: op-279, op-280, op-281, op-282, op-288, op-290
- [Done]: op-278, op-284, op-285
- [Flushed]: op-283
- [Draft] / [Queued]: none
```

This is the normal ending for Arranger adjudication/dispatch replies (Coordinator ruling,
2026-07-11).

- The board is **complete**: every live op appears exactly once. Activation headers remain the
  authoritative per-op source; the board is a presentation derived from them.
- Sort ids numerically inside each group. Prefer active-first group order: `[Exe]`, `[Ready]`,
  `[Queued]`, `[Hold]`, `[Done]`, `[Flushed]`, `[Draft]`.
- Omit an empty status group when obvious. When showing completeness matters, combine empty groups
  compactly at the end (for example, `[Draft] / [Queued]: none`).
- Do not repeat roles or descriptions by default. Add a short parenthetical only when an immediate
  Coordinator action or blocker would otherwise be ambiguous; the activation file carries detail.
- Never show `[Retired]`: retirement removes the op from the live ROB.
- Use plain Markdown bullets—no tables, box drawing, or decorative banners.

### ROB list form — detailed alternate

**List form** is the former one-op-per-line rendering:

```
op-NNN [STATUS] (role) — short description
```

Use it when the Coordinator says **“list form”**, or when a handoff/audit/discrepancy needs the
role, target, description, or blocker mapped separately for each op. It is not the default live
board and is not an activation brief.

- **op-NNN** — the op id (sequential, never reused).
- **[STATUS]** — an explicit bracketed tag (below), placed right after the id so state reads first.
- **(role)** — the executing role (Explorer / Gatekeeper / Implementer / Validator-GLM / Validator-DS4P),
  with the target pipeline if it matters (e.g. `Explorer rx-x64z`).
- **short description** — brief it carries + the one-line task.

Keep the **op-NNN** slot clean—just the id. Re-run/retry counts go in the description (e.g.
"4th run"), never glued onto the id ("op-111 re-re-re-retry" reads badly and the id never changes
across retries).

## Status vocabulary

Title-case, not ALL-CAPS, for clarity (`[Done]`, not `[DONE]`).

- `[Draft]` — **WIP**: the op brief is still being authored / refined — **NOT finalized, NOT unblocked**,
  not yet dispatchable. The pre-`[Ready]` state. (Added 2026-06-26.) Distinct from `[Hold]` (brief *is*
  finalized but deliberately gated/reserved) — `[Draft]` means the brief itself isn't done.
- `[Ready]` — finalized + unblocked; awaiting Coordinator dispatch. (Renamed from `[Awaiting]` 2026-06-26.)
- `[Exe]` — dispatched; executing / awaiting report (the op is in execution). (Renamed `[In-flight]` → `[Air]` → `[Exe]` 2026-06-26.)
- `[Queued]` — issued, queued behind another op (name it, e.g. *after op-123*).
- `[Hold]` — reserved + held; the op number is assigned but not dispatched and not reused. (Renamed from `[Held]` 2026-06-26.)
- `[Done]` — the bound EXU has **returned** the op's primary deliverable/report. This is the return
  boundary only: `[Done]` does **not** by itself mean Arranger-verified, Validator-validated,
  accepted, green, or retired. Advance `[Exe] → [Done]` when the return arrives, then keep the op in
  the ROB while the Arranger sizes and validates the gate directly or issues a Validator op. Any
  downstream validation, consumption, or origin-reachability blocker also keeps it `[Done]`.
- `[Retired]` — fully closed: the returned work has been validated by the Arranger or through a
  delegated Validator op, the Arranger has adjudicated/consumed that gate, and every required
  downstream and origin-reachability condition is clear. **Once retired, an op DROPS OFF the ROB —
  do not list `[Retired]` ops** (retirement lives in the activation/ID record). A `[Done]` op stays
  listed until the Arranger records retirement.
- `[Flushed]` — the op **did NOT work out** (failed, dead-ended, or was mis-scoped). Mark it `[Flushed]`
  and **re-issue the work under a brand-new `op-NNN`** — the flushed id is closed, never continued or
  decorated (no `op-NNN-cont`; the only legal suffix is `m`, see [terminology.md](terminology.md) §6). An op
  that DID deliver its primary objective is `[Done]`, not `[Flushed]`, even when a follow-on is needed — the
  follow-on is its own new op number. (Coordinator 2026-06-26; CPU analogy: a mis-speculated uop is *flushed*
  from the pipeline and the re-fetch gets a fresh slot.)

## Role division (who carries an op)

- **Gatekeeper** — larger / longer runs: **integration + soak-testing** (sustained lifecycle, hours-scale
  soak, multi-layer). Not the default for everything.
- **Validator** (GLM free / DS4P) — **single or few-op** targeted validation of returned `[Done]`
  work. Its verdict informs retirement; the Arranger records the final `[Done] → [Retired]`
  transition after consuming the gate.
- **Explorer** — discovery + harness authoring (free). **Implementer** — source edits. **Arranger** —
  may directly validate returned work when doctrine permits (including S/M gates and
  discovery/docs), then retire it once all blockers are clear.

Add one line after either form only if a sequencing call is open (e.g. host contention).

## List-form example

ROB — list form:
- op-128 **[Ready]** (Gatekeeper) — id-015: package + standalone-boot + smoke the preview image
- op-130 **[Draft]** (Explorer) — id-016 ambient bootstrap-port probe (brief still being authored)
- op-111 **[Ready]** (Validator-GLM) — id-022 Change→Retired: clean buildworld from `15a6acc` clears test-includes (5th run)
- op-123 **[Exe]** (Gatekeeper) — id-010 notify: full li-003 lifecycle + leg-4 soak
- op-124 **[Queued]** (Gatekeeper, after op-123) — id-011 asl: full li-003 lifecycle + high-volume soak
- op-122 **[Hold]** (Explorer ×2) — id-021 libxpc leg 2, lockstep run (until id-010/011 solid)
- op-129 **[Done]** (Explorer) — id-010 notify legs 1+4 harnesses authored (pending op-123 run)

(`[Retired]` ops are not listed in either form—they have dropped off the ROB; retirement lives in
the activation/ID record.)
