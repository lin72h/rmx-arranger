---
id: op-388
state: draft
agent: implementer
repo: rmx-implementer
idq: id-016
gate: validator
authority: doas only for mdconfig, gpart, fsck, mount, install, umount on image files in /Users/me/wip-mach/stage; no guest runs; push rmx-implementer main
updated: 2026-09-28T06:46Z
---
# op-388 — Implementer: fix the helper's host inventory, then stage the PID-1 premise image (re-issue of op-382)

## Outcome

op-382 stopped correctly at the host-inventory hard stop, but the delta was a harness defect, not a
host change. The Arranger verified: `rmx-stage-image.exs:123` hashes the full `mtree -c` output,
whose `#` header (user, machine, tree, date) differs on every run; the content lines are stable,
and nothing under `/etc/rc.d`, `/boot/modules`, `rc.conf`, `rc.local`, or `loader.conf` changed.
First: hash only mtree's content lines (drop `#` lines), and add to the self-test a no-change
stability check (two inventories with nothing changed must be equal) alongside the existing
fixture-delta check. Then stage a fresh copy; the op-382 image is not accepted. Everything else
is as in op-382:

Chain step 1 of the reviewed PID-1 contract: the containment helper `rmx-stage-image` and one
disposable PID-1 premise image on alpha2, delivered as content-pinned artifacts that the
Gatekeeper will run read-only. The contract is four notes in
`/Users/me/wip-mach/rmx-explorer1/findings/nx-r64z/` (repo at `be1a3fb`): op-318 (the base: Q2 BOM,
Q4 helper contract, and "Disposable premise vs production candidate"), op-322 (C1 host-safe
self-test, C2 artifact identity, and the ownership split), op-377 (the alpha2 amendments), and
op-380 (the corrected BOM paths and the consumer-check rule). Where they differ, the later note
wins.

1. Helper: `rmx-stage-image` per op-318 Q4 as corrected by op-322. That means the pre-privilege
   rejection chain; host inventory before and after; explicit `doas <cmd> <argv>` only, with no
   `sh -c`, heredoc, `tee`, or `make install` under doas; the gpart index taken from the BOM; an
   in-image sha256 for every row; and the `.rmx-staged` marker. Include op-322 C1's self-test: the
   unprivileged rejection tier, the fixture-mode host-delta test, and a privileged tier that runs
   only against a fixture image in your workspace. Put the helper in this repo beside
   `scripts/bhyve/`, not in `wip-rmxos`: it is harness, not product source. The cell runner is the
   Gatekeeper's.
2. Image: copy the op-364 image into your workspace and stage onto the copy, never the original.
   `boot/loader.conf` gains `init_path="/sbin/launchd"` with no `-u` and keeps its existing alpha2
   keys. `/etc/launchd.d/` gets `com.apple.notifyd.plist`, `com.apple.syslogd.plist`, and
   `com.rmxos.aslmanager.once.plist` from source at `2884304b`, plus a new
   `com.rmxos.rc-chainload.plist` whose `ProgramArguments` are exactly `/bin/sh` and `/etc/rc`.
3. Identity: under op-322 C2 rule 5, the Arranger accepts the alpha2 `/sbin/launchd` already in
   the op-364 image (sha256 `3ac3d0ec07441661de5891ef5f9645a2ed6d9a2cbfbb8226531a9f3d9efe1e61`)
   as launchd's content identity. It was built in op-343's pinned release-profile buildworld from
   sources byte-identical at `2884304b`, both Validators verified the staged tree (op-368, op-369),
   and it booted in op-372. Do not rebuild it. Prove source artifact = BOM = in-image for it and
   for every other BOM row, and check every destination against its consumer (op-380).
4. Evidence: the BOM JSON, `host-before.json` and `host-after.json` (which must be equal), the
   in-image hashes, the final image's sha256, and the helper's self-test results with real and
   synthetic runs reported separately; commits in this repo, pushed to origin.

## Inputs

- Workspace: `/Users/me/wip-mach/stage`, ZFS dataset `zroot/wip-mach-stage` (a device distinct
  from `/`, 64 GB quota, owned by you). Use it as the helper's `--workspace`: the image copy,
  `vm/runs/`, `artifacts/`, and `build/` all go there.
- Base image `/Users/me/wip-mach/rmx-implementer/build/op364-20260928T001637Z/images/op364-alpha2-gpt.raw`,
  sha256 `8f546a930859ce537d1cb8f462dbf391171fd02c2bd004d2d10b1c8b498c7140`, and its staged tree
  `…/op364-20260928T001637Z/staging/destdir` as the source of the artifacts already in the image.
- Product source `/Users/me/wip-mach/rmx-implementer/wip-rmxos` at
  `2884304b67fc454ee60187ce4731fca01cbefe6a`, read-only: this op changes no product source.
- The four contract notes above. The old helpers `scripts/bhyve/stage-guest.sh`,
  `image-staging-guard.sh`, and `run-guest.sh` are the defects the new helper replaces; op-322
  cites the lines.

## Limits

- No guest boot or cell run; that is the Gatekeeper's next op.
- Privilege only as the authority states, and only on image files inside `/Users/me/wip-mach/stage`. Any
  difference between `host-before.json` and `host-after.json` is a hard stop: report it; do not
  repair it.
- Do not modify the op-364 image, its staging tree, or any other role's repo.

Re-read OPS.md first: defaults and the REPORT block.
