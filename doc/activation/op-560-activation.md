---
id: op-560
state: closed
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-061
needs: op-559
authority: 5 boots max on copies of op552-overlay-base-r3 with the op-559 overlays, 5 min each; doas vmm.ko, bhyve; push rmx-gatekeeper1 main
expected: 2h
issued-at: 2026-10-08T04:52Z
updated: 2026-10-08T05:14Z
---
# op-560 — Gatekeeper 1: adopt the overlay route and prove op-547 with the corrected peer_pending test

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 2 hours.**

Your op-550 proof of op-547 (per-thread MIG reply ports) passed except
`xpc_receive_test:peer_pending` fact 13. The Implementer found that it
reads 2 about once in 50 runs on both libmach versions: a real but
temporary dead-name notification reference (added at
`sys/compat/mach/ipc/ipc_right.c:479`, released by libdispatch at
`lib/libdispatch/src/source.c:3071-3075`) counted before it clears.
The test now waits up to 3 s for exactly that count to fall to 1
(`d8437d85`, identical `83a04d93` on the base branch).
Record: `/Users/me/wip-mach/rmx-implementer/docs/op555-peer-pending.md`.

**Adopt the overlay route.** From now on images for proofs are one
verified base image plus a small read-only overlay disk with the op's
changed files and a hashed manifest; the base image installs it once
early in boot and reboots. Route and format:
`/Users/me/wip-mach/rmx-implementer/docs/overlay-disks.md`. Add it to
your maintained runner (two virtio disks: a copy of the base image and
the overlay; no shares or network), checking the manifest hash printed
on the serial log against the one you were given. Overlays and the
exact boot route: `/Users/me/wip-mach/rmx-implementer/docs/op559-overlays.md`:
- base image `/Users/me/wip-mach/rmx-implementer/build/op552/images/op552-overlay-base-r3.raw`
  sha256 `6f3b6e54606cecfbe3572cf5e2dee156c42499d113909351b811c41abe974059`
- base overlay `/Users/me/wip-mach/rmx-implementer/build/op559/overlays/op547-base/overlay.ufs`
  sha256 `65163a61939c02ad7e049d5219f2818c5e6385210ce41c26c326894b0e96a285`
- fixed overlay `/Users/me/wip-mach/rmx-implementer/build/op559/overlays/op547-fixed/overlay.ufs`
  sha256 `cf48be91c8438f736ab6a1c69baf4418945bdd26380328760d1b2140e7f18a75`
The two manifests (`manifest.tsv` beside each) differ only in libmach's
three files.
Each run is an install boot then a test boot.

Proof:
1. Base overlay (`83a04d93`): the five `mig_reply_ports_test` modes
   (expected as in your op-550 base: one shared name; `concurrent`
   ends with `MIG_REPLY_MISMATCH` -301; the exiting thread's right
   stays; `fork` works) and `xpc_receive_test:peer_pending` 20 times
   (expected PASS each time with the corrected test).
2. Fixed overlay (`d8437d85`): all 93 earlier cases, the five modes
   (all PASS), `peer_pending` 20 times (PASS), then the paced launchd
   repeat (`/usr/tests/lib/launchd/op526_repeat 100`, 400 cases, no
   `launchd control reply missing`) and a normal shutdown.
One spare boot, only for a boot that fails before its commands run.

Result: one table, expected against observed, with the serial line
for each case or mode, the repeat counts, the power-off line, every
mismatch listed; and a short note on how your runner now handles
overlays.

Evidence by path; hash only each boot's raw serial log. Commits on
origin.

## Limits

- No product edits. If one case cannot run, record it and finish the
  others.

Re-read OPS.md first: defaults and the reply block.
