# id-049 — Historical `nx-v64z` names remain after the arch-letter change to `nx-r64z`

- id: **id-049**
- state: **WAITING — priority low (Coordinator, 2026-09-28)**
- raised: **2026-09-28 by the Coordinator, from the Arranger's workflow review**
- parent: none (naming hygiene); related: `terminology.md` (arch-letter rule), id-033

## Problem

`terminology.md` retired `v` as an arch letter (`r64` is the union of x64 and a64). It says `v`
survives only in historical `nx-v64z` filenames "pending their migration to `nx-r64z`", and that
migration never happened. As of 2026-09-28:

- rmx-explorer1 and rmx-gatekeeper1 each carry `findings/nx-v64z/`,
  `macos-validation/findings/nx-v64z/` and `archive/comprehensive-nx-v64z-macos-oracle-plan.md`,
  inherited from the shared mach-oracle history (last touched 2026-06-19). explorer1's current
  PID-1 notes use `findings/nx-r64z/`, so both names are in use side by side in one repo.
- About 119 files in each of those two repos mention `nx-v64z`, as do 11 in rmx-implementer and
  4 here.
- The old mach-oracle clones `wip-gpt-oracle` and `wip-gpt-oracle-ui-core` (origin
  `lin72h/mach-oracle`, last commits June 2026) carry the same names.

## Constraint

Raw evidence is never changed. A rename leaves the bytes intact but moves paths that manifests,
hashes and REPORTs cite.

## Options

1. **Migrate:** each repo's owner runs `git mv` with a recorded old-to-new path map and updates
   live references; content bytes stay unchanged.
2. **Freeze:** declare the existing `nx-v64z` paths permanent history, drop "pending their
   migration" from `terminology.md`, and require `nx-r64z` for every new record.

Either way, the old mach-oracle clones are history to archive, not to migrate.
The Arranger's proposal: 2, because it keeps every cited path valid.

## Done when

One option is decided and applied, and no new `nx-v64z` path appears.
