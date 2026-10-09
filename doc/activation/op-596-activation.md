---
id: op-596
state: closed
agent: implementer
repo: rmx-implementer
idq: id-046
needs: op-590
authority: 4 self-check boots (install + test, + 2 spare) on op-590's KASAN overlay with the op-590 runner; test-only fixes under op-590's rule; no push
expected: 1h
issued-at: 2026-10-09T22:02Z
updated: 2026-10-09T22:02Z
---
# op-596 — Implementer: KASAN self-check of b61f0f91, the last profile of op-590

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 1 hour.**

op-590's RELEASE run is complete and verified: 723/723 cases pass, the
five MIG modes exit 0, normal power-off, no assertion or fatal trap.
Only KASAN remains.

1. Self-check the KASAN overlay you already built
   (`build/ci/b61f0f9164170ed9d9d2b3fd312e34eee2603f09/overlays/rmxos-kasan-op590/overlay.ufs`,
   sha256
   `9d865e0fb17f11ef70c86a103248ccf5f6df5df6c6f81b85c51cbb4b370f8259`;
   check it first) on the same base image `op552-overlay-base-r3.raw`
   (sha256
   `6f3b6e54606cecfbe3572cf5e2dee156c42499d113909351b811c41abe974059`),
   with the op-590 runner and settings: an install boot, then a test
   boot. Expected: 723/723 pass, the five MIG modes exit 0, normal
   power-off, no assertion, fatal trap or KASAN report from boot to
   power-off.
2. Two spare boots. op-590's rule still holds: a wrong new test may be
   fixed in a test-only commit, rebuilt and rerun within these boots;
   if the product is wrong or an earlier accepted test fails, stop and
   report.

Evidence: add the run (load, ATF counts, MIG modes, power-off line,
serial path and sha256) to `docs/op586-host-task-vm.md`, commit, and
update its `selfcheck:` line.

## Limits

- No product source change. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
