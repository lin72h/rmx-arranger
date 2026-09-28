---
id: op-380
state: closed
agent: explorer1
repo: rmx-explorer1
idq: id-016
gate: self
authority: none
updated: 2026-09-28T05:53Z
---
# op-380 — Explorer 1: correct the PID-1 contract's image paths (Arbiter: REMEDIATE)

## Outcome

Both Validators reviewed the layered PID-1 contract (op-318 as corrected by op-322 and amended by
your op-377). validator1 returned CLOSE at 9.5 (op-378). validator2 returned REMEDIATE at 9
(op-379) on op-318's Q2 BOM, and the Arranger, as Arbiter, rules REMEDIATE: the defect is verified
first-hand. Commit one amendment note, `findings/nx-r64z/20260928-op380-bom-paths.md` (a new record;
op-318 stays as written), that corrects these rows of op-318's BOM (lines 119–133) for alpha2
`2884304b`:

1. launchctl (line 123): the source is `bin/launchctl/` and the destination is `/bin/launchctl`.
   launchd runs `/bin/launchctl bootstrap -S <session>` for every session
   (`sbin/launchd/core.c:7145`), and `sbin/launchctl` does not exist.
2. BlocksRuntime (line 126): the source is `lib/libblocksruntime/` (lowercase).
3. Kernel, module, and loader config (lines 131 and 133): alpha2 boots
   `/boot/RMXOS-RELEASE/kernel` with `/boot/RMXOS-RELEASE/mach.ko`, and its `loader.conf` has
   `kernel="RMXOS-RELEASE/kernel"` and `mach_load="YES"`. Replace the pre-alpha2
   `/boot/kernel/kernel` and `/boot/modules/mach.ko` rows with exact alpha2 values.
4. Add to C2 the rule that closes this class of error: check every BOM destination against its
   consumer (launchd's compiled-in paths, `loader.conf`, rc scripts, and plist `Program` and
   `ProgramArguments`), because host-built = BOM = in-image confirms only the destination it is
   given.

Apply rule 4 to every other BOM row, and list each row with its consumer and the result. End with
one verdict: BOM-CORRECTED, or NEEDS-MORE listing what is left.

## Inputs

- In your repo at `5c51fc0`: the op-318, op-322, and op-377 notes.
- Product source `/Users/me/wip-mach/rmx-implementer/wip-rmxos` at
  `2884304b67fc454ee60187ce4731fca01cbefe6a`, read with `git show` only.
- A real alpha2 layout to compare against, read-only:
  `/Users/me/wip-mach/rmx-implementer/build/op364-20260928T001637Z/staging/destdir` (for example
  `bin/launchctl`, `boot/loader.conf`, and `boot/RMXOS-RELEASE/`).
- validator2's review: `/Users/me/wip-mach/rmx-validator2/reviews/op-379/op-318-op-322-op-377-pid1-contract-review.md` (commit `4e1ecc4`).

## Limits

Read-only apart from the note and its one commit: no builds, runs, guests, or traces, and no push.
Read-only commands are fine.

Re-read OPS.md first: defaults and the REPORT block.
