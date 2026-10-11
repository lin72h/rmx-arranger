---
id: op-636
state: issued
agent: validator1
repo: rmx-validator1
idq: id-063
authority: none beyond the defaults: read-only; no guests
expected: 3h
issued-at: 2026-10-11T09:23Z
updated: 2026-10-11T09:23Z
---
# op-636 — Validator 1: review of mach-fixes-6 1cad29b5..93b3735d (send-possible notifications and the MIG generator changes)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). This is a source-only correctness review of code we
author and ship, so that the Implementer can fix it.

**Expected time: about 3 hours.**

`mach-fixes-6` moved from `1cad29b5` (proven, pushed) to `93b3735d`
in six local commits. They add send-possible notifications and change
the MIG generator in two ways that alter the wire format of generated
messages. The Implementer's runs pass 1042/1042 on RELEASE and KASAN;
tests show what was exercised, not that the rest is right. Your lens is
falsification: find what is wrong in this diff.

What to read, most effort first:
1. `usr.bin/migcom`: `3ba1f28d` re-enables `rtCheckSimple` for
   requests in `rtCheckRoutine` (`routine.c` around 1757), removing an
   `#ifdef notyet` whose comment said it "causes MIG to generate
   incorrect code"; `a4e79df4` fixes one consequence (a simple
   request's RetCode argument). Find any other code path the generator
   emits for simple requests or replies that is still wrong (size
   checks, variable-length arguments, RetCode, reply construction,
   user and server sides), against Apple's migcom
   (`https://github.com/apple-oss-distributions/bootstrap_cmds`,
   `migcom.tproj`). `e27b4b6c` changes alignment to four bytes
   (`mig_machine.h`, `type.h`): check it against the same source.
2. Send-possible request state, arming and delivery:
   `sys/compat/mach/ipc/ipc_port.c`, `ipc_right.c`, `ipc_notify.c`,
   `ipc_mqueue.c`, `mach_msg.c` (commits `43819bf1`, `bf1658fe`,
   `3745c74b`): reference counts on every path, the port-then-queue
   lock order, rechecks after each unlock, one notification per
   arming, and the dead-name cases.
3. The regenerated sources (`sys/compat/mach/*_server.c`) only where
   items 1 and 2 point you.

The Implementer's record of the design and its checks is
`/Users/me/wip-mach/rmx-implementer/docs/op617-round3.md` § op-622 to
§ op-633; read it after forming your own view.

Write `reviews/op-636/review.md`, under about 200 lines: findings
ranked by likelihood times impact, each with `file:line`, what the
code does, which Mach or MIG contract it does not meet (Apple's lines
where they differ), your confidence, the smallest check that would
confirm it, and the fix direction; a "checked and cleared" list; what
you did not reach. In the reply, `verdict`: `CLOSE` with a confidence
score (1-10) if nothing must be fixed before this is pushed,
`REMEDIATE` with the findings that must.

## Inputs

- rmxOS: `/Users/me/wip-mach/rmx-implementer/wip-rmxos` at
  `93b3735d1d8bef1f15e013599d0a56bab3968b61` (read with `git show`,
  `git diff 1cad29b5 93b3735d`, `git log`, `git grep` only).
- XNU, read-only: `/Users/me/wip-mach/reference/xnu-xnu-12377.121.6/`;
  libdispatch, read-only: `/Users/me/wip-mach/reference/libdispatch-442.1.4/`.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
