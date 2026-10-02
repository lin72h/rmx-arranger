---
id: op-420
state: returned
agent: implementer
repo: rmx-implementer
idq: id-046
gate: validator
authority: build: kernel RMXOS-RELEASE, mach.ko, libmach and the Mach tests from the branch; stage base and fixed test images with rmx-stage-image; no guest runs; no push
updated: 2026-10-02T08:58Z
---
# op-420 — Implementer: Mach fix batch 2 — op-394 step 2: entry and reference handling on the fd backend

## Outcome

Context: ordinary bug fixing in our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source Mach IPC).

Implement step 2 of the decided Mach design: correct entry and reference handling while Mach port
names stay file descriptors. The design is advisor2's op-394 proposal (`rmx-advisor2@519ec47`,
`op-394-mach-names-lifecycle-receive-design-proposal.md`: § A, option A1, and "Decisions and booting
introduction", step 2). The rules that bind this work are in the 1.0 decision record, which you
have not seen, so here they are:
- **Rule 1:** entries carry their own references and user references (urefs). The fd is a proxy
  that holds one entry reference. Never derive urefs from `f_count`, and never edit `f_count` from
  Mach code.
- **Rule 2:** closing a Mach name revokes it under its space lock, through a descriptor-removal
  hook; final `fo_close` releases storage. `dup` and `dup2` of a Mach name are rejected
  (state the errno, and cite how other non-dupable FreeBSD descriptors behave). Batch-1 fileops
  stay.
- **Rule 4:** kernel objects hold references, never names; knotes pin the entry.
- All name handling goes through the new entry API; no new code outside the IPC entry layer
  assumes a name is an fd.

Target findings (id-046 ledger): op-389 #2; op-392 S2, S3 and S4's entry causes. Remove the forced
drops and stale knotes. Keep the current userland ABI.

Work on a new branch `mach-fixes-2` from `mach-fixes-1` (`903c8fc2`) in `wip-rmxos`. Commit in steps
that each build. Each target finding gets a regression test, written first, in the existing
`tests/sys/mach` style (expected result on `mach-fixes-1` and after). Tests check Mach behaviour, not
fd numbers. Build and stage two images as in op-416: `mach-fixes-1` + the new tests, and
`mach-fixes-2` + the new tests.

Evidence: the commits; a short note mapping each target finding to its commit and test, with
expected results; both image hashes and BOMs (by path).

## Limits

- Step 2 only: no task/thread lifetime work (step 3), no receive-model change (step 4), no name
  table. Stop and report if a target finding needs one of those.
- No push of `wip-rmxos`.

Re-read OPS.md first: defaults and the REPORT block.
