---
id: op-421
state: draft
agent: advisor2
repo: rmx-advisor2
idq: id-046
gate: self
authority: none: read-only design note
updated: 2026-10-02T06:47Z
---
# op-421 — Advisor 2: design note — receive in mach_msg with kqueue signalling readiness only (C1), on the fd backend (A1)

## Outcome

Context: open-source OS engineering: a design note for rmxOS kernel code we author and ship.

Your op-394 proposal (`rmx-advisor2@519ec47`) recommends C3 and ties the receive-model change to
step 5 (the Mach-owned name table). The Coordinator decided that 1.0 keeps port names as file
descriptors (A1) and defers step 5 (decision record, summarised here because it lives outside your
repo):
- 1.0 does steps 2-4 on the fd backend;
- the receive model for 1.0 is C1: kqueue reports readiness only, and messages are received in
  `mach_msg`;
- C3 and the name table wait until after 1.0.

That leaves the receive defects (op-389 #6, op-392 F4 and S1) without a 1.0 design. Write a short
note, `op-421-c1-on-fd-backend.md`, under about 120 lines:
1. **The filter:** how `EVFILT_MACHPORT` works as a readiness-only filter while port sets are still
   fd-backed. Cover attach, detach and event, which pins it holds, and how name revocation (step 2's
   descriptor-removal hook) ends it with one EOF event.
2. **The receive path:** how `mach_msg` receive and the queue and wakeup rules from your proposal
   (enqueue MIG replies, no direct waiter handoff) fit this, including LARGE and trailer handling.
3. **libdispatch:** the smallest change to rmxOS's libdispatch so its Mach receive sources work on
   readiness plus `mach_msg` (cite `lib/libdispatch/src/source.c`). launchd and libxpc keep their
   plain `mach_msg` receives.
4. **What it fixes and what it leaves:** the ledger findings it retires, and anything that only C3
   or step 5 could fix, marked "needs step 5".
5. **Steps:** introduction steps that keep the system booting, ordered against steps 2-4.

Read-only: `wip-rmxos` at `mach-fixes-1` (`903c8fc2`), your proposal, and the three reviews.

Re-read OPS.md first: defaults and the REPORT block.
