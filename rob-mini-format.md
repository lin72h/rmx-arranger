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

Title-case, not ALL-CAPS, for clarity (`[Done]`, not `[DONE]`).

- `[Draft]` — **WIP**: the op brief is still being authored / refined — **NOT finalized, NOT unblocked**,
  not yet dispatchable. The pre-`[Ready]` state. (Added 2026-06-26.) Distinct from `[Hold]` (brief *is*
  finalized but deliberately gated/reserved) — `[Draft]` means the brief itself isn't done.
- `[Ready]` — finalized + unblocked; awaiting Coordinator dispatch. (Renamed from `[Awaiting]` 2026-06-26.)
- `[Exe]` — dispatched; executing / awaiting report (the op is in execution). (Renamed `[In-flight]` → `[Air]` → `[Exe]` 2026-06-26.)
- `[Queued]` — issued, queued behind another op (name it, e.g. *after op-123*).
- `[Hold]` — reserved + held; the op number is assigned but not dispatched and not reused. (Renamed from `[Held]` 2026-06-26.)
- `[Done]` — the op's deliverable is produced + Arranger-verified first-hand, but a downstream
  validation or consumption is still pending (e.g. a fix awaiting its build/soak validation, a harness
  awaiting the run that uses it).
- `[Retired]` — fully closed: validated (a Validator carries the Change `[Done] → [Retired]` step, or a
  Gatekeeper closes a soak/integration run) **or** self-retired by the Arranger when no validation is
  needed (verified-first-hand discovery / characterization / docs). **Once retired, an op DROPS OFF the
  ROB — do not list `[Retired]` ops** (the ROB shows only in-flight/pending work; retirement lives in the
  id-NNN record). A `[Done]` op stays listed until its downstream validation retires it.
- `[Flushed]` — the op **did NOT work out** (failed, dead-ended, or was mis-scoped). Mark it `[Flushed]`
  and **re-issue the work under a brand-new `op-NNN`** — the flushed id is closed, never continued or
  decorated (no `op-NNN-cont`; the only legal suffix is `m`, see [terminology.md](terminology.md) §6). An op
  that DID deliver its primary objective is `[Done]`, not `[Flushed]`, even when a follow-on is needed — the
  follow-on is its own new op number. (Coordinator 2026-06-26; CPU analogy: a mis-speculated uop is *flushed*
  from the pipeline and the re-fetch gets a fresh slot.)

## Role division (who carries an op)

- **Gatekeeper** — larger / longer runs: **integration + soak-testing** (sustained lifecycle, hours-scale
  soak, multi-layer). Not the default for everything.
- **Validator** (GLM free / DS4P) — **single or few-op** targeted validation; carries `[Done] → [Retired]`
  for a specific Change (e.g. confirm a fix cleared its wall).
- **Explorer** — discovery + harness authoring (free). **Implementer** — source edits. **Arranger** —
  may self-retire verified-first-hand discovery/docs without a validator.

Add one line after the list only if a sequencing call is open (e.g. host contention).

## Example

ROB:
- op-128 **[Ready]** (Gatekeeper) — id-015: package + standalone-boot + smoke the preview image
- op-130 **[Draft]** (Explorer) — id-016 ambient bootstrap-port probe (brief still being authored)
- op-111 **[Ready]** (Validator-GLM) — id-022 Change→Retired: clean buildworld from `15a6acc` clears test-includes (5th run)
- op-123 **[Exe]** (Gatekeeper) — id-010 notify: full li-003 lifecycle + leg-4 soak
- op-124 **[Queued]** (Gatekeeper, after op-123) — id-011 asl: full li-003 lifecycle + high-volume soak
- op-122 **[Hold]** (Explorer ×2) — id-021 libxpc leg 2, lockstep run (until id-010/011 solid)
- op-129 **[Done]** (Explorer) — id-010 notify legs 1+4 harnesses authored (pending op-123 run)

(`[Retired]` ops are not listed — they've dropped off the ROB; the retirement lives in the id-NNN record.)
