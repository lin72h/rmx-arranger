---
id: op-559
state: closed
agent: implementer
repo: rmx-implementer
idq: id-061
authority: overlay builds only; no boots; no push
expected: 45m
issued-at: 2026-10-08T04:50Z
updated: 2026-10-08T04:51Z
---
# op-559 — Implementer: two overlays for op-547's corrected pair (no boots)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 45 minutes.** No boots.

First: OPS.md § Self-check has three new rules (`rmx-implementer@426073d`):
keep self-checks light (ATF counts and the serial path; tests assert
their own facts; no custom checkers, negative controls or provenance
ledgers), up to 2 extra boots for your own harness or setup failures,
and every new or changed case 10 times on fixed. Re-read it.

For gatekeeper1's proof of op-547, build two overlays in op-552's
format (`docs/overlay-disks.md`) for the base image
`build/op552/images/op552-overlay-base-r3.raw`, straight from the
corrected branches (no update layer, no checkpoints):
- base overlay: libmach and tests from `mach-fixes-6-op547-base@83a04d93`;
- fixed overlay: libmach and tests from `mach-fixes-6@d8437d85`.
Test files identical in both; only libmach's three files differ (show
from the two manifests). Put them under `build/op559/overlays/` and
write a short note `docs/op559-overlays.md` with both overlay hashes,
both manifest hashes, the base image hash, and the exact two-disk boot
route gatekeeper1 should use. No boots, no source change.

Evidence: commit; `docs/op559-overlays.md`.

## Limits

- No boots, no source or test change. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
