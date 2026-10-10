---
id: op-622
state: draft
agent: implementer
repo: rmx-implementer
idq: id-063
authority: product and test commits on mach-fixes-6 in wip-rmxos and the libdispatch rebuild; rebuild the RELEASE and KASAN overlays; 6 self-check boots (4 + 2 spare) with the op-617 runner; test-only fixes under op-590's rule; no push
expected: 5h
updated: 2026-10-10T07:31Z
---
# op-622 — Implementer: send-possible notifications (MACH_SEND_NOTIFY, MACH_NOTIFY_SEND_POSSIBLE) on mach-fixes-6, from your op-617 design

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 5 hours** (your op-617 estimate: request
lifecycle and lock order about 2 h, delivery about 1 h, tests and
builds 1-2 h).

Your op-617 items 1-3 and 5 are accepted (`mach-fixes-6@1cad29b5`,
833/833 on both profiles). This op is item 4, implemented to the
design in your `docs/op617-round3.md` § Item 4. In short: libdispatch
sends with `MACH_SEND_TIMEOUT | MACH_SEND_NOTIFY`, arms its channel on
`MACH_SEND_TIMED_OUT` and waits for a send-possible notification; our
headers have no `MACH_NOTIFY_SEND_POSSIBLE` (XNU selector 66,
`osfmk/mach/notify.h:79`), so libdispatch falls back to a dead-name
request that never reports queue space, and
`mach_port_request_notification` accepts only port-destroyed,
no-senders and dead-name. Start from `1cad29b55719`.

1. **Selector and request state:** the public selector 66 and its
   notification message; per-name registered and armed state in the
   request table, kept apart as XNU's `ipc_port_request_sparm` keeps
   them (`osfmk/ipc/ipc_port.c` around 513-578). Combined dead-name
   behaviour, replacement and cancellation results, and release of the
   notification right on entry removal, port death and space teardown
   stay as they are.
2. **Arming:** on a full-queue timeout with `MACH_SEND_NOTIFY`, arm the
   sending entry's registered request while its name, entry and port
   are still the ones registered; recheck queue space under the
   existing port-then-queue lock order, so a receiver that drains
   before the request is armed still produces a notification.
3. **Delivery:** when a receive, a queue-limit change or waiter
   admission frees space, take each armed request once and send its
   notification after the queue locks are released (XNU around
   1000-1080); recheck the port and table after every unlock. Ordinary
   sender wake-ups stay. A later full-queue timeout needs a new arming.
4. **libdispatch:** rebuild against the public selector, so the
   dead-name substitute in `src/internal.h:570-573` is no longer used;
   its receive port set and notification routing stay.
5. **Tests (Zig):** full queue, an armed send that times out, one
   receive, exactly one notification with the right selector and name;
   space freed before arming; arming again after delivery;
   cancellation; peer death; reference counts back to their start.
   One libdispatch test: a channel fills its peer's queue, the peer
   drains it, and the pending send completes.

Then rebuild the RELEASE and KASAN overlays on the same base image
`op552-overlay-base-r3.raw` (sha256
`6f3b6e54606cecfbe3572cf5e2dee156c42499d113909351b811c41abe974059`),
recording each overlay's and manifest's sha256, and self-check both
profiles with the op-617 runner and settings. Expected on both: every
earlier and new case passes, the five MIG modes exit 0, the 400-case
repeat passes, normal power-off, no assertion or fatal trap; on KASAN,
no KASAN report. Two spare boots; a wrong new test may be fixed and
rerun within the boots (op-590's rule); a product failure or an
earlier accepted test failing stops the op.

Evidence: add the implementation, tests and both runs (load, ATF
counts, MIG modes, power-off line, serial paths and sha256) to
`docs/op617-round3.md` § Item 4, commit, and update its `selfcheck:`
line.

## Limits

- Commits on `mach-fixes-6` in `wip-rmxos`, only for this item. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
