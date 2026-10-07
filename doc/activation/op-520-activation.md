---
id: op-520
state: closed
agent: validator3
repo: rmx-validator3
idq: id-046
authority: none beyond the defaults: read-only; no guests
expected: 2h30m
issued-at: 2026-10-07T01:43Z
updated: 2026-10-07T01:44Z
---
# op-520 — Validator 3: review of op-515 + op-518 (id-046 readiness-only Mach kevents)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Review the source.

**Expected time: about 2.5 hours.**

id-046's readiness-only Mach kevents (op-389 #6, op-392 F4 and S1): a
port-set kevent (`EVFILT_MACHPORT`) only reports that a message is
ready, and the program receives it with `mach_msg`. op-515 and op-518
together are 4 commits on a new branch `mach-fixes-6`, from
`2de5f1d4` (on origin) to `wip-rmxos@0facf74b`: tests `b77d97b5`,
change `051c59a5`, test correction `af37956e`, worker start
`0facf74b` (op-518). Source (clean at that commit):
`/Users/me/wip-mach/rmx-implementer/build/op468/source`. Record:
`/Users/me/wip-mach/rmx-implementer/docs/op515-mach-readiness.md`
(op-518 is its last section). Plan: advisor2's
`/Users/me/wip-mach/rmx-advisor2/op-435-mach-step4-c1-d2-plan.md`
§ 2 "Readiness" and "Filter", § 4 item 5. Self-check: fixed 87/87;
base 5 FAIL and 2 PASS as recorded.

Check (`sys/compat/mach/ipc/ipc_pset.c` unless named):
1. **The filter never receives.** The new `f_event` only reads the
   set's published readiness and member hint: no current-thread
   state, no Mach locks, no receive, no user buffer, no copyout, zero
   result `fflags`/`ext`.
2. **Readiness bookkeeping.** Every path that changes whether a member
   has messages updates it under port-then-set lock order: enqueue,
   dequeue, join, leave, member death or revocation, set destruction.
   The hint moves on when its member drains or leaves, and selection
   rotates so one busy member cannot hide another.
3. **Deferred public `KNOTE`.** The private `knote_enqueue` walker is
   gone; notification runs from the module's taskqueue with no Mach
   object, space or task lock held. Submission allocates nothing and
   never runs the filter inline. Trace the dirty/pending handoff: a
   change made while the worker runs is not lost, and the last set
   reference is never dropped while work for it is pending. Work is
   drained before a set is reclaimed.
4. **Worker start (op-518).** The queue is created in module init and
   its thread starts from a `SYSINIT` at `SI_SUB_TASKQ`; mach.ko stays
   boot-time only and unload stays `EBUSY` (`mach_module.c`). Is
   anything notified before the thread runs, and is the `panic` on a
   failed start acceptable for a boot-time module?
5. **Attach and update.** A buffered initial attach fails with
   `ENOTSUP`; updates ignore receive `fflags`/`ext` and never receive;
   `.f_isfd`, the `kn_fp` check and the attach/detach pins are kept.
6. **No EOF.** Set destruction publishes not-ready instead of
   `EV_EOF` (`ipc_right.c`); native close removes the note silently.
   Native `EV_DISPATCH`/`EV_ONESHOT`/`EV_CLEAR` accounting is
   FreeBSD's, and re-enabling re-checks readiness.
7. **Tests and scope:** would each case in `mach_readiness_test` and
   the revised `mach_short_kevent_test:short_buffer` detect its defect
   at `2de5f1d4`; are `scans` and `silent_close` useful controls; is
   every wait bounded? Only `sys/compat/mach` and `tests/sys/mach`
   changed.

Distinguishing question: is there a path where a ready message is
never reported (a lost notification), where the kevent path consumes
or changes a message, or where notification work outlives its set?

Re-read OPS.md first: defaults and the reply block.
