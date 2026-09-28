# id-044 — Historical preflights resolve kernel objdirs only through the legacy `wip-gpt` name

- id: **id-044**
- state: **WAITING — not on the preview critical path; fix or retire is a Coordinator choice; no op
  until it is ready to send**
- raised: **2026-09-28 by the Arranger, from the op-363 calibration reviews (op-365, op-366, op-367)**
- parent: none (tooling hygiene after the Implementer repo rename)

## Problem

op-363 replaced the hard-coded `/Users/me/wip-mach/wip-gpt/wip-rmxos` in seven Implementer scripts
with `${repo_root}/wip-rmxos`, where `repo_root` follows the spelling the script was invoked with.
Kernel objdir trees are keyed by the source path as spelled at build time, and the only key that
exists is `…/Users/me/wip-mach/wip-gpt/…` (in `build/wip-rmxos-alpha-obj` and, for
`verify-phase1-current-tree.sh`, `build/releng151-rc1-mach-obj`). So:

- the six `preflight-phase095*` scripts find their kernel and `mach.ko` only when invoked through
  the `wip-gpt` symlink; through `rmx-implementer` or `rmx-implementer1` they fail closed at the
  required-input guard (validator1, validator2, validator3);
- `verify-phase1-current-tree.sh` has the same objdir concatenation (validator2);
- five more scripts still name `${workspace_root}/wip-gpt/…`: `scripts/asl/preflight-phase09-asl-a3.sh`
  and four `scripts/dispatch/verify-phase07-*.sh` (validator1);
- `preflight-phase095a-notifyd-n2-mach-send.sh` pins mach.ko `49ac3d89…` (line 61) while the objdir
  now holds `9c7706a3…`, so it fails even through `wip-gpt` (validator1).

The root cause is the op-363 brief, which asked for location-derived paths; the Arranger's S gate
accepted the result. `pwd -P` is not a fix, because it changes the key too (validator2).

## Intended outcome (if fixed rather than retired)

The objdir component gets an explicit key with an environment override that defaults to the
historical spelling, in the six preflights and verify-phase1; the five other scripts stop naming
`wip-gpt`; the mach-send pin mismatch is reported, not changed, because pins are evidence
authority. Verified by evaluating the path derivations under all three repo names. These are
historical phase-0.95 preflights, so retiring them is a valid alternative.

## Blocks

Removing the transitional `wip-gpt` symlink.
