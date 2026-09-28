---
id: op-391
state: draft
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-016
needs: op-388
gate: both
authority: stage: one workload overlay onto a copy of the op-388 image with rmx-stage-image at dd78a31 (its own doas allowlist); guest attempts: 1 on that overlay image; doas: load vmm.ko if absent, and the runner's bhyve calls; push rmx-gatekeeper1 main
updated: 2026-09-28T07:53Z
---
# op-391 — Gatekeeper 1: corrected reaper premise — one PID-1 cell on the op-388 image

## Outcome

One contained guest cell that answers op-264 Finding A on alpha2: does PID-1 launchd's detached
`waitpid_loop` reaper (a) abort launchd, (b) steal a managed job's zombie so launchd records the
synthesized `W_EXITCODE(-1, SIGSEGV)`, or (c) spin a core during managed-child exits? Return
exactly one aggregate verdict (PREMISE-CONFIRMED, PREMISE-NOT-OBSERVED, HARNESS-NOT-ACCEPTED,
INFRASTRUCTURE-NOT-ACCEPTED) with a per-axis OBSERVED / NOT-OBSERVED / INCONCLUSIVE for a, b and c,
under the contract below. A product panic or launchd death under a valid workload is product
evidence (OBSERVED), never infrastructure.

Three parts, in order; each gates the next:

1. **Harness, host-only.** In rmx-gatekeeper1: the cell runner (your op360 runner, parameterized as
   for op-372: 2 vCPUs, 4 GiB, one virtio disk, serial console, no network, shares or
   passthrough); the in-guest workload; and the offline classifier that turns a cell's raw
   records into the verdicts. Run the classifier against op-322's Tier-2 mutation controls: it
   must accept the known-good record, accept the -245 mutation as OBSERVED (b), and reject every
   other mutation. Any other result stops the op before staging.
2. **Overlay image.** Copy the op-388 image to a new file under `/Users/me/wip-mach/stage/images/`,
   check the copy's hash, then stage the workload onto the copy with `rmx-stage-image`. Its BOM
   names the copy as base, keeps all 28 op-388 rows as `verify`, and adds one `install` row per
   workload file, each with its real consumer. The op-388 image must still hash `031885…`
   afterwards, and host-before must equal host-after.
3. **One cell** on the overlay image, executing the reaper plan. Stop before the attempt if any
   preflight fails.

Evidence: the Tier-2 results; the overlay BOM, host inventories and image hashes; the cell's raw
serial log, per-command outputs, DTrace outputs, and a manifest hashing them; the classifier's
output on that manifest; commits on origin.

## Inputs

- Contract, read in this order, later notes winning: `/Users/me/wip-mach/rmx-explorer1/findings/nx-r64z/`
  `20260712-op318-pid1-preview-activation-contract.md` (§ REAPER_PLAN: waves W1–W5, per-exit
  observations, evidence binding, terminal grammar), `20260717-op322-pid1-contract-correction.md`
  (process identity, Tier U/K/F probes, wait-status table, Tier-1/Tier-2 controls, verdict
  grammar), `20260928-op377-alpha2-rebase.md` (amendments 1 and 2), and
  `20260928-op380-bom-paths.md` (the consumer rule for your install rows). All four at
  rmx-explorer1 `be1a3fb`.
- Premise image: `/Users/me/wip-mach/stage/images/op388-alpha2-pid1-premise.raw` sha256
  `031885595536603d0312bfd351d37847d6694ef592dc709a699fcfd112a8f1e5`, read-only. Its BOM
  `/Users/me/wip-mach/stage/artifacts/op388-premise/bom.json` sha256 `658937223d46…3881` and
  record `/Users/me/wip-mach/rmx-implementer/docs/op388-pid1-premise.md` (dd78a31).
- Identity pins: `/sbin/launchd` `3ac3d0ec07441661de5891ef5f9645a2ed6d9a2cbfbb8226531a9f3d9efe1e61`
  (unstripped: `jobmgr_reap_pid`, `job_reap`, `waitpid_loop` present), kernel ident
  `RMXOS-RELEASE`, `init_path="/sbin/launchd"`, no `-u`. The image carries `dtrace`, and
  `dtraceall`, `fasttrap` and `systrace` modules under `/boot/RMXOS-RELEASE/`.
- Helper: `/Users/me/wip-mach/rmx-implementer/scripts/bhyve/rmx-stage-image` at dd78a31, run
  as-is from that repo; do not edit or copy it.
- Staging dataset: `/Users/me/wip-mach/stage` (ZFS, distinct from `/`). Put your run directories
  there or in rmx-gatekeeper1.

## Limits

- Premise corrections that bind this cell:
  - Identity by op-322's table, not op-318's (comm is `launchd`; hash the executable file,
    never `procstat` text).
  - Tier U and Tier K preflights must show every required probe before the waves. A missing
    probe or an empty trace is HARNESS-NOT-ACCEPTED; never `-Z`.
  - Before any wave, record whether `/dev/null` is a character device, and the rc-chain job's
    raw LastExitStatus. A failed rc chain is recorded as such; the reaper waves may still run.
  - An ECHILD count or a visible zombie alone is diagnostic (op-377 amendment 2). Asserting (b)
    needs the same pid's wait4 result, launchd's raw LASTEXITSTATUS and the `Reap failed` path.
    Missing correlation makes (b) INCONCLUSIVE.
  - Decode every status with the W* macros. Never use shell 128+signal.
- Waves run after boot settles, launched by your in-guest driver in bounded windows, not by
  RunAtLoad plists that fire during boot. W4 and W5 must reparent to PID 1.
- Workload files go only where their consumer reads them. The overlay changes nothing in the
  28 premise rows.
- One attempt, no retry. The guest window is capped at 30 minutes wall-clock; after
  `OP279_DONE` the guest powers off. A hang at the cap consumes the attempt.
- No product edits and no launchd fix: op-280 owns the fix and waits on this verdict.

Re-read OPS.md first: defaults and the REPORT block.
