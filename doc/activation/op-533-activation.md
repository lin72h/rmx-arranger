---
id: op-533
state: draft
agent: validator3
repo: rmx-validator3
idq: id-046
authority: none beyond the defaults: read-only; no guests
expected: 1h30m
updated: 2026-10-07T05:10Z
---
# op-533 — Validator 3: re-review of mach-fixes-6@ea254222 (op-520 finding fixed; readiness-only Mach kevents)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Review the source.

**Expected time: about 1.5 hours.**

Your op-520 review of readiness-only Mach kevents (REMEDIATE 9/10,
F1: a recovered receive right stays excluded from readiness) went to
the Implementer. `mach-fixes-6` is now `ea254222`, from `2de5f1d4` (on
origin): your reviewed commits `b77d97b5`, `051c59a5`, `af37956e`,
`0facf74b`, then test `f031e457`, fix `ab26bbed`, test fix `ea254222`.
Source: `/Users/me/wip-mach/rmx-implementer/build/op468/source`
(check out `ea254222`). Record:
`/Users/me/wip-mach/rmx-implementer/docs/op524-recovered-readiness.md`.

Check:
1. **F1 fix** (`ab26bbed`, `ipc_right_copyout`,
   `MACH_MSG_TYPE_PORT_RECEIVE`): `ip_readiness_revoked` is cleared
   when a valid receive right is published to its new owner, under the
   space and port locks; not while the port is in limbo; old-entry
   revocation and receive-epoch checks unchanged. Is every path that
   gives a receive right a new owner (port-destroyed delivery, message
   copyout) covered, and none that should not be?
2. **The test** (`mach_recovered_readiness_test:recovered_receive`,
   with `ea254222`): would it detect F1 at `0facf74b`, and is every wait
   bounded?
3. **id-061:** a launchd control request sometimes gets no reply, and
   shutdown then does not finish; reproduced on the older
   `2de5f1d4` kernel too (`docs/op529-launchd-reply.md`), so it is
   tracked separately. Say if anything in `mach-fixes-6` could make it
   more likely.
4. Your op-520 checks 1-7 still hold for the unchanged commits.

Re-read OPS.md first: defaults and the reply block.
