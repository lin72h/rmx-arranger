# bl-012 — release / distribution image: bootable rmxOS USB + ISO (Gate F logistics)

- id: bl-012
- state: **WAITING** — the full-release tier waits on the usability gates (A–E) so there is a
  *usable* thing to ship; the **dev-preview tier is fetchable much earlier** (it needs only a
  bootable image with the rmxOS userland present, not conformance-green). Awaiting Coordinator
  fetch + a target call (dev-preview now vs hold for 1.0).
- raised: 2026-06-23 (Coordinator: distribution logistics — a FreeBSD-release-style USB image for
  developer-preview / 1.0)
- roadmap parent: [roadmap.md](../roadmap.md) — **Gate F** (reproducible build → stage → boot:
  "a clean checkout builds + boots the guest reproducibly by *someone other than us*"). This is
  that gate's productization.
- relations: **bl-007 / op-104** (the build→stage→boot path already exists for the *test* guests —
  this turns that path into a distributable, installable artifact); **bl-006/010/011** (the
  subsystems that must be staged into the image and boot); **Gate C / Phase 0.8 launchd** (the
  image must boot to a launchd-managed userland, not just single-user).
- lane (when promoted): infrastructure / release-engineering. Not observation-only — produces
  artifacts + a reproducible pipeline; no product *source* semantics change.

## What exists in the tree (first-hand, 2026-06-23)

The **full FreeBSD release machinery is inherited and present** — this is not greenfield:

- `release/release.sh` + `release/Makefile` + `release/Makefile.inc1` — the release driver.
- `release/amd64/make-memstick.sh` — the **USB memstick image** builder (the FreeBSD-RELEASE-style
  USB the Coordinator named); `release/amd64/mkisoimages.sh` — bootable **ISO**;
  `release/Makefile.vm` — VM/cloud images; `release/amd64/amd64.conf` — the amd64 release config.
- `usr.bin/mkimg/` — the partitioned-image builder underneath; `bsdinstall` (installer) packaged
  via `release/packages/ucl/bsdinstall.ucl`.
- top-level `Makefile` / `Makefile.inc1` — `buildworld`/`buildkernel`/`make release` entry points.

So the risk is **not** writing a pipeline. It is: *does the rmxOS overlay survive the standard
release build + boot* — the Darwin userland (libdispatch/libnotify/libasl/launchd) **and the
custom kernel modules (`mach.ko` et al)** must be built into world+kernel, staged into the image,
and boot to a usable launchd userland — **reproducibly, by a third party.**

## Why raise it now (even pre-1.0)

A **developer-preview USB image** is the first artifact an outside developer can actually run —
it converts "we have a guest we boot in bhyve" into "someone else can `dd` it to a stick and
boot rmxOS." That is the floor consumer in the roadmap (developer-usable: "build + run
Darwin-style programs against Mach/dispatch/notify on FreeBSD 15"). Standing the pipeline up early
also de-risks Gate F: reproducibility/boot bugs surface on a real image long before 1.0, not at
the finish line.

## Scope (when promoted) — two tiers

**Tier 0 — developer-preview image (fetchable early, before full 1.0):**
1. `make buildworld buildkernel` with the rmxOS config produces a world+kernel containing the
   Darwin userland + custom kernel modules — clean, from a fresh checkout.
2. `make-memstick.sh` (and/or `mkisoimages.sh`) produces a **bootable amd64 USB/ISO** carrying
   that world+kernel.
3. The image **boots on the bhyve guest to a launchd-managed multi-user userland** (reuse the
   bl-007/op-104 guest-boot path as the boot oracle) — not just single-user/console.
4. Smoke: a Darwin-style sample (a `dispatch_async` + `notify_post` program) builds + runs on the
   booted image. Proves "developer-usable floor" end-to-end.

**Tier 1 — 1.0 release (gated on Gates A–E):**
1. Full `release.sh` run: memstick + ISO + VM images, **installable via `bsdinstall`** to a disk.
2. Subsystems staged + verified through the **Gate C lifecycle on first boot** (launchd brings up
   notifyd/asl/own daemons; they survive restart/reload on real hardware/VM, not a fixture).
3. **Reproducible-by-a-third-party** (Gate F truly-green): a documented clean-checkout →
   build → image → boot path that someone *other than us* can run and get a byte-comparable (or
   behavior-comparable) bootable image. Capture the non-reproducible points (timestamps, build
   host state) and pin them — mirrors the op-108 "kernel builds aren't byte-reproducible" lesson:
   define what "reproducible" means concretely (bit-identical vs boot-behavior-identical).
4. Release notes + the Gate E known-gaps backlog shipped *with* the image (1.0 ships with its
   cataloged gaps).

**Out:** the subsystem conformance work itself (bl-006/010/011 — this *consumes* their green,
doesn't do it); non-amd64 arches (arm64 etc. — FreeBSD confs exist but rmxOS targets amd64 first);
package repo / pkg(8) distribution (separate logistics item if wanted).

## Truly-green criterion (what "Gate F passed" must mean)

- a clean checkout builds world+kernel (Darwin userland + `mach.ko`) with no manual fixups;
- `make-memstick.sh`/`release.sh` produces a bootable amd64 image carrying it;
- the image boots to a launchd-managed userland on the guest (build→stage→boot is a button, the
  bl-007 boot oracle confirms it);
- **a third party reproduces it** from the documented path — the defining Gate F bar, not us
  re-running our own script.

## Open decisions (Coordinator-held, at fetch)
- target: cut a **developer-preview USB now** (Tier 0, de-risks Gate F early), or hold all of it
  for 1.0?
- reproducibility bar: **bit-identical** image (hard — timestamps, build-host state) vs
  **boot-behavior-identical** (pragmatic — same artifacts, same boot result). Lean
  behavior-identical for the preview, revisit bit-identical for 1.0.
- installer scope: full `bsdinstall` install-to-disk for the preview, or live/memstick-only boot
  first (cheaper) with install-to-disk deferred to Tier 1?
- arch: amd64-only for 1.0 (matches the explorer/gatekeeper guests) — confirm arm64 is post-1.0.
