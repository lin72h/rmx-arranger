---
id: op-552
state: draft
agent: implementer
repo: rmx-implementer
idq: id-000
authority: tool and image work; one new base image from op417; overlay images; 4 self-check boots; doas bhyve, vmm.ko; no push
expected: 4h
updated: 2026-10-08T02:11Z
---
# op-552 — Implementer: overlay disks for the test loop (kernel-testing.md § 4.1): one verified base image plus a small changing disk

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 4 hours.**

Every fix op currently composes two full 8 GB ZFS images (about 30-45
minutes plus cleanup), although only the kernel, `mach.ko`, one library
or a test changes. Design: `/Users/me/wip-mach/rmx-arranger/kernel-testing.md`
§ 3 principle 3 and § 4.1 (adopted by the Coordinator, 2026-10-03;
scheduled 2026-10-06, j-20261006-008). Build it:

1. **Base image, made once.** From `op417-alpha2-zfs-gpt.raw` with the
   world and libraries of `mach-fixes-6@e2fa6df9` (the current
   accepted build), plus whatever the overlay route below needs. Hash and BOM
   as now.
2. **Overlay disk.** A small image (`makefs`, seconds) holding only
   what an op changes (kernel, `mach.ko`, libraries, test binaries)
   and a manifest of their paths and hashes. Attach it as a second
   virtio disk; no shares, no network, nothing else from the host.
3. **How the guest uses it.** Settle one route from § 4.1, with a boot
   each if needed: (a) the loader reads the kernel and modules from
   the overlay disk; or (b) a one-time rc step in the base image
   installs the overlay's files over the base (checking each hash
   against the manifest) and reboots once. Do not use `bhyveload -h`
   (a host directory at boot). The serial log must print the overlay
   manifest's hash before any test runs.
4. **Pair from overlays.** Show a base/fixed pair as two overlays over
   the one base image: rebuild op-547's pair this way (base overlay =
   libmach at `cb664232` + tests; fixed overlay = libmach at
   `e2fa6df9` + the same tests), run its five `mig_reply_ports_test`
   modes on both, and compare with op-547's results.
5. **Runner.** Your `tools/selfcheck` gains the overlay route; write a
   short usage note (`docs/overlay-disks.md`) that gatekeeper1 can
   adopt in its runner unchanged (same base image, same overlay
   format, same manifest check).

Evidence: commits; `docs/overlay-disks.md`; the base image hash and
BOM; both overlays' hashes and manifests; the boots and their results;
the time an overlay pair takes compared with op-547's image pair; the
`selfcheck:` line.

## Limits

- Test-loop tooling and images only: no kernel, library, launchd or
  test source change. Containment unchanged (no shares or network).
  No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
