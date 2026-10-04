---
id: op-481
state: issued
agent: implementer
repo: rmx-implementer
idq: id-046
gate: self
authority: libmach and libdispatch builds (no world); 2 images; 3 self-check boots; no push
expected: 3h
issued-at: 2026-10-04T19:39Z
updated: 2026-10-04T19:39Z
---
# op-481 — Implementer: fix libmach mach_msg_destroy for received complex messages

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 3 hours** (tests 1 h, fix 45 min, two images
and self-checks 45 min, record 30 min).

Your op-478 record found it: `lib/libmach/mach/mach_msg.c:247-262`
(from the NextBSD import, `b069a16f`) starts the descriptor walk of
`mach_msg_destroy` at `basep + 1`, past a stack copy of
`mach_msg_base_t`, so it reads stack memory instead of the message;
and it steps by `sizeof(mach_msg_descriptor_t)`, while a received
user port descriptor is 12 bytes and an LP64 out-of-line descriptor
16. Its callers include libmach's own `mach_msg_server` paths
(`mach_msg.c:380-553`), `sbin/launchd/core.c`,
`usr.sbin/notifyd/notifyd.c`, `lib/libnotify/libnotify.c`,
`usr.sbin/asl/dbserver.c` and `lib/libosxsupport/si_module.c`.
Fix it once in libmach, then let libdispatch use it. Continue on
`mach-fixes-5` (now `22334ca3`) in `build/op468/source`.

1. **Tests first** (Zig, a new `tests/lib/libmach`, registered like
   `tests/lib/libdispatch`): receive a real complex message carrying
   a port descriptor (send and receive rights), an out-of-line
   region and an out-of-line ports array, in that order and in a
   second order; call `mach_msg_destroy` on the receive buffer;
   check every right is released (urefs back to the expected count;
   a released receive right's name no longer exists), the
   out-of-line regions are unmapped, and nothing else in the space
   changed (an unrelated right with a known name keeps its urefs).
   Fill the caller's stack with a known non-zero pattern first, so
   that reading stack memory cannot pass by chance.
2. **Fix `mach_msg_destroy`:** walk the descriptors in the message
   itself, advancing by each descriptor's received user size, with
   reads that tolerate 4-byte alignment; keep its handling of the
   header rights and of every disposition unchanged.
3. **libdispatch:** replace op-478's local walker
   (`_dispatch_mach_partial_receive_destroy`,
   `_dispatch_mach_received_right_destroy`) with a call to
   `mach_msg_destroy` on the buffer, keeping the `MACH_RCV_BODY_ERROR`
   branch and its test. Upstream libdispatch uses
   `mach_msg_destroy` the same way.

Then two images, reusing the existing world: base = `22334ca3` +
the new tests, fixed = the changes + the same tests (test files
byte-identical). Self-check: the new libmach cases fail on base and
pass on fixed; all 63 earlier cases pass on fixed (the
`MACH_RCV_BODY_ERROR` case now goes through libmach).

Evidence: the commits; your op record with the fix, the tests and
their base and fixed results; both image hashes and BOMs (by path);
the `selfcheck:` line.

## Limits

- libmach, libdispatch and their tests only: no kernel, launchd,
  notifyd or libxpc change (they gain the fix through libmach).
  No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
