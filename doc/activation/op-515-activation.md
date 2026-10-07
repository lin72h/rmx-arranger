---
id: op-515
state: closed
agent: implementer
repo: rmx-implementer
idq: id-046
authority: kernel and mach.ko builds (no world); 2 ZFS images; 4 self-check boots; no push
expected: 5h
issued-at: 2026-10-07T00:16Z
updated: 2026-10-07T05:40Z
---
# op-515 — Implementer: id-046 readiness-only Mach kevents with public KNOTE (op-435 § 4 item 5)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 5 hours** (tests 1.5 h, kernel changes 2 h,
two images and self-checks 1 h, record 30 min).

The kernel part of id-046 that remains before launchd's child-task
setters: a port-set kevent (`EVFILT_MACHPORT`) only reports that a
message is ready, and the program receives it with `mach_msg`. Today
the filter callback runs the Mach receive path itself, under the
kqueue's locks, and with a receive buffer in `ext[0]`/`ext[1]` it
consumes the message (op-389 #6, op-392 F4 and S1). libdispatch,
launchd and libxpc no longer need that (step 4 part 2, accepted on
`mach-fixes-5@2de5f1d4`). Plan: advisor2's
`/Users/me/wip-mach/rmx-advisor2/op-435-mach-step4-c1-d2-plan.md`
§ 2 "Readiness" and "Filter", § 4 item 5. Start a new branch
`mach-fixes-6` from `2de5f1d4` (on origin) in `build/op468/source`.

Rules (confirm or correct each from the source,
`sys/compat/mach/ipc/ipc_pset.c` unless named):
1. **The filter never receives.** `filt_machport` (`:627-713`) calls
   `ipc_mqueue_pset_receive` with an immediate timeout, and
   `filt_machport_direct_receive` (`:150-160`) selects a consuming
   receive into the user buffer. Replace it: `f_event` reads a
   published readiness snapshot for the set (ready or not, plus the
   name of one ready member as a hint, not a reservation) and returns
   it with zero `fflags`/`ext`. No current-thread state, no Mach
   locks, no receive, no user buffer, no copyout.
2. **Readiness is kept by the set.** Maintain which members have
   messages under the existing port-then-set lock order: on enqueue
   (`ipc_mqueue.c:425-443`), dequeue, join and leave
   (`ipc_pset.c:400-417`), and member death or revocation. When the
   hinted member drains or leaves, pick another ready member; rotate
   so a busy member cannot hide another one.
3. **Publication uses public `KNOTE`.** Remove the private
   `knote_enqueue` walker in `ipc_pset_signal` (`:527-565`). Notify
   through public `KNOTE_UNLOCKED` with no Mach object, space or task
   lock held. If any caller can hold such a lock, defer the
   notification to a module-owned taskqueue with preallocated work and
   work-owned set references (plan § 2); submission allocates nothing
   and never runs the filter inline. Drain that work before a set is
   reclaimed and before module unload.
4. **Attach and update.** An initial `EV_ADD` that carries a receive
   buffer (`MACH_RCV_MSG` with non-zero `ext[0]` and `ext[1]`) fails
   with `ENOTSUP`. Updates to an existing note ignore receive
   `fflags`/`ext` and only report readiness; they never receive. Keep
   `.f_isfd`, the `kn_fp` check and the attach/detach pins
   (`:584-624`).
5. **Set destruction reports not-ready, no EOF.** `ipc_right.c:531`
   raises `EV_EOF` on the set's notes, and `filt_machport` sets
   `EV_EOF | EV_ONESHOT`. Under the 1.0 contract no EOF is
   synthesized: destruction publishes not-ready, and native close
   removes the note silently. Keep `mach_entry_knote_test:destroy_detaches`.
6. Native `EV_DISPATCH`, `EV_ONESHOT` and `EV_CLEAR` accounting stays
   as FreeBSD does it; re-enabling a dispatched note re-checks
   readiness.

Tests first (`tests/sys/mach`, Zig, registered in Makefile, Kyuafile
and EXPECTATIONS.md):
1. `EV_ADD`, `EV_ENABLE`, an update and repeated kevent scans never
   consume or change queued messages: two messages queued, readiness
   reported, then `mach_msg` receives both, in order.
2. `EV_DISPATCH` re-enable, `EV_ONESHOT` and rearm, `EV_CLEAR` with a
   draining consumer: readiness is reported again exactly while a
   message remains.
3. Two members A and B: while A keeps receiving messages, B's message
   is still reported and received.
4. Attach while a message is being enqueued: readiness is reported
   (no lost wakeup).
5. Initial attach with a receive buffer fails with `ENOTSUP`; an
   update with a buffer on a readiness note is harmless.
6. Closing the set's descriptor removes the note silently; destroying
   the set reports no `EV_EOF`.
Revise the existing direct-receive kevent cases in
`mach_short_kevent.zig` (for example `short_buffer` at line 54):
their attach now fails with `ENOTSUP`, and the receive checks they
make move to `mach_msg`. List each revised case and why in your
record.

Then two ZFS images (from `op417-alpha2-zfs-gpt.raw`, reusing the
existing world and the adapted libraries at `2de5f1d4`; rebuild only
the kernel, `mach.ko` and the tests): base = `2de5f1d4` + the tests
(name its branch, as before), fixed = the changes + the same tests
(test files identical). Show the pair differs only in the change
from the METALOG/BOM diff (OPS.md § Self-check). Self-check: the new
cases fail on base as expected (say which cannot be shown on base and
why), all pass on fixed, and the 81 earlier cases pass on fixed,
including the libdispatch, launchd and libxpc consumer cases.

Evidence: the commits; your op record (`docs/op515-mach-readiness.md`)
with each rule's change, test and base and fixed results; both image
hashes and BOMs (by path); the `selfcheck:` line.

## Limits

- Kernel (`sys/compat/mach`) and `tests/sys/mach` only: no libdispatch,
  launchd, libxpc or FreeBSD native kqueue change. launchd's
  child-task setters (op-435 § 4 item 6) are the next op, not this
  one. N7 (dead-name allocation failure) stays a known limitation.
  No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
