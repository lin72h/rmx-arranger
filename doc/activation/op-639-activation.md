---
id: op-639
state: draft
agent: validator1
repo: rmx-validator1
idq: id-063
authority: none beyond the defaults: read-only; no guests
expected: 2h
updated: 2026-10-11T09:33Z
---
# op-639 — Validator 1: finish the op-636 review — our migcom against Apple's bootstrap_cmds, and a rescore after two findings were refuted

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). This is a source-only correctness review of code we
author and ship, so that the Implementer can fix it.

**Expected time: about 2 hours.**

Thank you for op-636. Two of its findings do not hold against XNU,
and its first priority, the generator, could not be compared with
Apple's source because the tree was not on disk. That was my brief's
gap; the tree is now on disk.

1. **Findings 1 and 2 are refuted; please confirm or contest:**
   - Finding 1: XNU arms a send-possible request at registration only
     when sync is set. `osfmk/ipc/mach_port.c:1615-1620` sets
     `IPR_SOR_SPREQ_MASK` always and `IPR_SOR_SPARM_MASK` only with
     `sync`, and `ipc_port.c:334-337` sets `ip_sprequests` only for
     both. A non-sync request is armed later by a send with
     `MACH_SEND_NOTIFY`. Our `ipr_sparm = immediate` matches this.
   - Finding 2: XNU arms with `MACH_SEND_NOTIFY` only when the
     destination entry already has a request (`ipc_kmsg.c:2117-2128`,
     `st.dest_request != IE_REQ_NONE`, then `ipc_port_request_sparm`,
     `ipc_port.c:523-545`); it never creates one. `MACH_SEND_WILL_NOTIFY`
     appears nowhere in the XNU or libdispatch reference trees. Our
     libdispatch registers the request first
     (`_dispatch_mach_kevent_register`, `lib/libdispatch/src/source.c:3489`)
     and treats `MACH_SEND_TIMED_OUT` with `MACH_SEND_NOTIFY` as armed
     (`:3531-3535`).
2. **The generator, file by file:** compare our `usr.bin/migcom` at
   `93b3735d` with Apple's `migcom.tproj` (path below) for every code
   path that differs for simple requests and replies: `rtCheckSimple`
   and its callers in `routine.c`, request and reply size checks,
   variable-length and counted arguments, RetCode, reply construction,
   on the user (`user.c`) and server (`server.c`) sides, and
   `itWordAlign` and `machine_alignment`. List each remaining
   difference that changes generated code for an interface we build,
   and say whether it is correct. Then spot-check one regenerated
   server with variable-length arguments (`vm_map_server.c` or
   `task_server.c`) against what Apple's generator would emit.
3. If time remains: the coverage of `mach_send_possible.zig` against
   the registration and arming cases above.

Add an `## op-639` section to `reviews/op-636/review.md` (about 80
lines): the outcome on findings 1 and 2, the generator differences
(`file:line` in both trees, effect on generated code, correct or not,
fix direction), what you did not reach. In the reply, `verdict`: `CLOSE`
with a confidence score (1-10) for `1cad29b5..93b3735d` as a whole if
nothing must be fixed before it is pushed, `REMEDIATE` with the
findings that must.

## Inputs

- rmxOS: `/Users/me/wip-mach/rmx-implementer/wip-rmxos` at
  `93b3735d1d8bef1f15e013599d0a56bab3968b61` (read with `git show`,
  `git diff 1cad29b5 93b3735d`, `git log`, `git grep` only).
- Apple's MIG, read-only: `/Users/me/wip-mach/reference/bootstrap_cmds/migcom.tproj/`
  (bootstrap_cmds-138, `c71d2d7`).
- XNU, read-only: `/Users/me/wip-mach/reference/xnu-xnu-12377.121.6/`;
  libdispatch, read-only: `/Users/me/wip-mach/reference/libdispatch-442.1.4/`.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
