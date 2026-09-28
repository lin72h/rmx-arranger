---
id: op-379
state: issued
agent: validator2
repo: rmx-validator2
idq: id-016
gate: self
authority: none
updated: 2026-09-28T05:28Z
---
# op-379 — Validator 2: review the PID-1 launchd contract on alpha2 (op-318, op-322, op-377)

## Outcome

Review the PID-1 launchd contract on alpha2 before anything is built from it. It is layered:
op-318 (Explorer, 2026-07-12) is the base. op-322 (2026-07-17) corrected it after an earlier
review (validator3, 7/10, not accepted as a runtime contract, for an unsafe host-mutating
self-test, an overclaimed binary identity, invalid process-identity and reaper probes, a raw-status
error, a fake known-bad control, and a colliding verdict grammar); op-322's table maps each to its
fix, C1–C8. op-377 (2026-09-28) re-based it from `alpha@26655e67` onto alpha2 `2884304b` and added
three amendments. You are one of two reviewers (validator1 and validator2). Return CLOSE,
DO-NOT-CLOSE, or REMEDIATE on these claims:

1. Staging and containment (C1–C3, with op-377 amendments 1 and 3): the helper self-test never
   writes real host configuration; artifact identity requires fresh alpha2 build inputs and
   host-built = BOM = in-image equality; the process-identity commands are valid on FreeBSD 15;
   and the new `/etc/rc` gate (`/dev/null` must be a character device) is proven before the
   rc-chain job starts, with the rc chain's raw exit status captured.
2. Reaper observation (C4–C7, with amendment 2): the three observation tiers are realizable on
   FreeBSD 15 (the userspace `pid` provider, `syscall::wait4`, the source-log fallback) behind a
   fail-closed preflight; the raw wait-status table matches `sys/sys/wait.h` and launchd's export;
   the controls actually fail closed; the verdict grammar is non-colliding and never hides a
   product failure as infrastructure; and on alpha2 an `ECHILD` or a surviving zombie counts only
   when correlated by pid with the consuming wait and launchd's raw status.
3. Consistency: op-318's preserved parts, op-322's scope corrections (C8), and op-377's rc-row
   amendments agree with each other and with the source at `2884304b`.
4. Sufficiency: from this contract alone, without guessing at an unstated requirement, the
   Implementer could build the containment helper and a disposable alpha2 PID-1 image, and the
   Gatekeeper could run the corrected reaper premise.

Suggested distinguishing question (sharpen it if you find a better one): run on alpha2, would every
failure this contract names be caught by its own controls rather than pass silently?

Known and already accepted: op-377 cites `svcj_all_enable="NO"` at `rc.conf:762-763`; it is at
line 764. Do not report that again.

## Inputs

- The contract, in `/Users/me/wip-mach/rmx-explorer1/findings/nx-r64z/` (repo at `5c51fc0`), sha256:
  `20260712-op318-pid1-preview-activation-contract.md` `180361ecdc772e2a63ca6ba05c76797524729314feb9ad7cb26056e834b73dfe`,
  `20260717-op322-pid1-contract-correction.md` `b6a08dc33f4416dc102c6e2675e5584c8a1fd4bd0c5bc574ddb6adbbfc9c8158`,
  `20260928-op377-alpha2-rebase.md` `39a4d30148a10963adac31a29971802fbb81b22ed8b3eac8ac5794786bd1e267`.
- Product source `/Users/me/wip-mach/rmx-implementer/wip-rmxos` at
  `2884304b67fc454ee60187ce4731fca01cbefe6a` (branch alpha2; base
  `26655e67872cd55cff0a272b32b7895f55368033`), read with `git show` and `git diff`; `sys/sys/wait.h`
  there has sha256 `ebf42612a46e702876c7395efd5140e58f4ac5c4a9b34868e07cd94c98a0a0b9`.
- The staging scripts `stage-guest.sh`, `image-staging-guard.sh`, and `run-guest.sh` in
  `/Users/me/wip-mach/rmx-implementer/scripts/bhyve/`, pinned in op-322 and op-377.

Before you start, re-read OPS.md in your repo: it holds the defaults and the REPORT block.
