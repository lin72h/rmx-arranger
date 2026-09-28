---
id: op-390
state: draft
agent: validator2
repo: rmx-validator2
idq: id-016
gate: self
authority: none
updated: 2026-09-28T07:26Z
---
# op-390 — Validator 2: review op-388 staging helper, BOM, and PID-1 premise image

## Outcome

Review op-388 (Implementer, returned 2026-09-28): the containment helper `rmx-stage-image` and the
disposable PID-1 premise image it staged on alpha2. You are the only reviewer (op-318 chain step
2). Return CLOSE, DO-NOT-CLOSE, or REMEDIATE on these claims:

1. Helper: every op-318 Q4 pre-privilege rejection path (as corrected by op-322 C1) is
   implemented and exercised by its self-test, including the fixture host-delta test and the
   no-change stability test; privileged steps use explicit argv only (no `sh -c`, heredoc, `tee`,
   or `make install` under doas); the privileged self-test ran only against a fixture image.
2. Host safety: `host-before.json` equals `host-after.json`, and the inventory now hashes mtree
   content only (op-382's false delta came from mtree's `#` header lines).
3. Image and BOM: all 28 rows satisfy source artifact = BOM = in-image; `/sbin/launchd` is the
   accepted `3ac3d0ec…`; every destination matches its consumer (op-380 rule), including
   `/bin/launchctl`, the four `/etc/launchd.d` plists (rc-chainload runs exactly `/bin/sh /etc/rc`),
   and `loader.conf` with `init_path="/sbin/launchd"`, no `-u`, and the alpha2 boot keys.
4. The base was an unmodified copy of the op-364 image, and nothing outside the workspace changed.

Suggested distinguishing question: could a wrong-but-consistent image or a real host change pass
this helper's own gates?

## Inputs

- Helper and index: `/Users/me/wip-mach/rmx-implementer` at `dd78a31cbfe2de51e1a580f922bca96c1ded1d71`
  (`scripts/bhyve/rmx-stage-image.exs`, `rmx-stage-image`, `rmx-prepare-pid1-premise.exs`,
  `docs/op388-pid1-premise.md`).
- Image `/Users/me/wip-mach/stage/images/op388-alpha2-pid1-premise.raw`, sha256
  `031885595536603d0312bfd351d37847d6694ef592dc709a699fcfd112a8f1e5` (you may mount it read-only
  only if you have authority; otherwise use the recorded in-image evidence).
- Artifacts in `/Users/me/wip-mach/stage/artifacts/`, sha256: `op388-premise/bom.json` `658937223d468e7d3f02c87849dbddff065a9b415aeb57215199c726e5ed3881`,
  `host-before.json` and `host-after.json` `9bb2e817ce28267e9417b1ebd381348a9e122e3f9e16be4d68e10179fc5fef71`,
  `in-image.json` `1b13083250a8be49e0e4bb0f91a8577cf918613df16667663f01f3af902a7bc5`,
  `consumer-checks.json` `bc1388d7bac5b569259875157c435b50e7ced5bbdf134e2fab575e568d859250`,
  `op388-self-test/synthetic-self-test.json` `40e461104b4fbf4f3368ceec304d277f4f9c2ddfd4e5451e43a0bb21658b1999`,
  `op388-self-test/privileged-self-test.json` `dbd2b692a3cbec6ca595438b411d034f94bcbd8119401160b7e57db96ce92cf3`.
- The contract: `/Users/me/wip-mach/rmx-explorer1/findings/nx-r64z/` op-318, op-322, op-377, op-380 notes.
- Base image `/Users/me/wip-mach/rmx-implementer/build/op364-20260928T001637Z/images/op364-alpha2-gpt.raw`
  `8f546a930859ce537d1cb8f462dbf391171fd02c2bd004d2d10b1c8b498c7140`.

Re-read OPS.md first: defaults and the REPORT block.
