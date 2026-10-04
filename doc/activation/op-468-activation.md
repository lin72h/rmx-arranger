---
id: op-468
state: draft
agent: implementer
repo: rmx-implementer
idq: id-046
gate: self
authority: libdispatch builds (no world); 2 images; 4 self-check boots; no push
expected: 4h
updated: 2026-10-04T04:56Z
---
# op-468 — Implementer: step 4 part 2a, libdispatch (op-435 § 4 item 4)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 4 hours** (tests 1.5 h, changes 1 h, two
images and self-checks 1 h, record 30 min).

Step 4 part 1 is accepted (`mach-fixes-4@0924690c`, on origin): every
kernel reply is queued, receives revalidate their entry, and LARGE
keeps an oversize message queued. This op adapts libdispatch to that
contract, the libdispatch half of advisor2's plan item 4
(`/Users/me/wip-mach/rmx-advisor2/op-435-mach-step4-c1-d2-plan.md`
§ 1 "libdispatch" and § 4 item 4). The kernel and launchd/libxpc stay
as they are; their part follows in a later op. Branch `mach-fixes-5`
from `0924690c`.

Rules (decided, `mach-names-step5-deferred.md` § Step 4 decisions 4):
- A source keeps its borrowed receive name and its set membership
  until cancellation completes, including the manager's unregister,
  event batches already copied and queued callbacks. Records and
  cookies stay valid across copied events; a cancelled record is
  dropped before any numeric member lookup or set move
  (`lib/libdispatch/src/source.c:512-529,2547-2591,2653-2669`).
  This needs a manager batch fence.
- Send-death: register before the source is published; an invalid or
  dead name at registration, or a send error, ends the source or
  channel cleanly (`source.c:2894-2904` currently ignores them). Keep
  notification decoding and the one extra dead-name uref release
  (`3014-3027`).
- Watched send and dead names: unregister, then release only owned
  urefs with `mach_port_deallocate`; never close or destroy the name.
- Receive: zero wire buffers and options in the registrations
  (`source.c:2429-2469`); keep both sets and DIRECT/DIRECT_ONCE
  routing. Replace the direct drain (`2674-2760`) with a bounded
  manager `mach_msg` on the aggregate set, timeout zero, keeping
  LARGE on growth plus the supported trailer options. Route the
  received local port through `2763-2797`, keep buffer and right
  cleanup (`2801-2808,3310-3339`), then re-enable once. These
  registrations also work with today's filter.

Tests first (Zig, `tests/lib/libdispatch`, registered like
`tests/sys/mach`):
1. A channel receives two messages, each exactly once.
2. An oversize message on a set: retry with LARGE, delivered once.
3. Readiness with no message left does not block the manager.
4. Cancel a source while a readiness record for it is already
   copied, then create an unrelated source on a reused name: the old
   record neither moves the new port nor runs its handler.
5. Send-death before and during registration, and a late death
   notification against cancellation: exactly one final callback
   and one reference release.
6. A late death notification cannot affect a newer unrelated object;
   urefs balance.

Then two images, reusing the existing world: base = today's
libdispatch + the tests, fixed = the changes + the same tests (test
files byte-identical). Self-check: new cases fail on base as recorded
(say which cannot be shown on base and why), all pass on fixed, and
the 55 Mach cases still pass on fixed.

Evidence: the commits; your op record with each rule's change, test
and expected result on base and fixed; both image hashes and BOMs (by
path); the `selfcheck:` line.

## Limits

- libdispatch and its tests only: no kernel, launchd or libxpc change.
- No pure C1 or public KNOTE work, no D2. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
