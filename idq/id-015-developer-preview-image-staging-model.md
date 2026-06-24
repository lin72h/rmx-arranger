# id-015 — developer-preview image via the staging model (1.0-preview's bootable-image leg)

- id: id-015
- state: **leg 1 DONE (op-114 `7951ebc`, Arranger-verified 2026-06-23) → legs 2-4 READY, pending
  the Gatekeeper freeing from op-111.** Fetch gate met: preview floor subsystems all green — Mach
  proven, libdispatch op-102 MATCH 9/9, **notify op-110 cont. MATCH 10/10**. op-114 = Explorer recon:
  audited the staging tooling first-hand, documented the snapshot+overlay pipeline end-to-end, pinned
  all three inputs (deliverable `findings/nx-r64z/20260623-op114-staging-model-audit.md`):
  (1) base = pre-staged rmxOS image (FreeBSD 15.0 userland + MACHDEBUGDEBUG kernel + mach.ko;
  non-reproducible, no content SHA); (2) overlay = alpha @ `e317099` (stage-userland.sh copies ~15
  libs + 3 bins + mach.ko from obj_root); (3) kernel = freebsd-src-official-stable-15 @ `f71260cf`,
  KERNCONF=MACHDEBUGDEBUG + `mach-stable15-port.patch`, installed by **stage-guest.sh via targeted
  `make installkernel … NO_MODULES=yes DESTDIR=…`** (Arranger-confirmed first-hand) — a targeted
  buildkernel/installkernel, **NOT buildworld**. Legs 2-4 (produce distributable image + boot
  standalone + smoke) = follow-on **Gatekeeper** op, executing against the op-114 audit as the spec.

  **Scoping correction (Arranger, against the op-114 gap table):** the audit's "distributable
  artifact" column lists `buildworld + installworld` — that conflates *distributable* (dd-able USB,
  id-015's floor) with *reproducible-from-source* (id-012's arc). id-015's actual path is **package
  the staged output (snapshot base + targeted-installkernel + overlay lib-copy) into USB/ISO via
  `mkimg`/`make-memstick`** — no buildworld. The non-reproducible base is acceptable here because
  id-015 ships honestly-labeled staging-model provenance; from-source reproducibility is id-012/
  op-111's separate arc. Legs 2-4 must package the staged image, NOT build from source.
- raised: 2026-06-23 — split out of id-012 after the op-111 finding revealed two distinct image
  paths. This is the **preview-critical** one.
- roadmap parent: [roadmap.md](../roadmap.md) §"1.0-preview" — the "bootable image" floor item.
  Per the **Arranger decision (2026-06-23, Coordinator-overridable)**, the preview ships on the
  proven staging model, NOT the reproducible release pipeline.
- relations: **id-012** (the *other* image path — the reproducible `buildworld→make-memstick`
  release pipeline, now post-preview Gate-F hardening; id-015 is the cheaper preview-now path);
  **id-007/op-104** (the staging-model boot oracle this rides); **id-006/010** (the subsystems that
  must be present + green in the image).

## Why this is distinct from id-012 (the op-111 finding)

op-111 established that rmxOS has two *different* image/boot paths that share the source tree but
not the build/stage path:

- **id-012 path (release pipeline):** `buildworld → installworld → make-memstick` — has **never
  completed** (id-014 + likely deeper breakage). Third-party-reproducible. Gate F / post-preview.
- **id-015 path (staging model):** base FreeBSD image + the rmxOS overlay + a **pre-staged kernel**
  (`loader.conf kernel="MACHDEBUG"` from `/boot/MACHDEBUG/`), assembled at image-creation time —
  the path op-104 guests **already boot** (launchd multi-user, BLOCK078 green). Proven today.

The preview only needs "a developer can boot rmxOS and run Darwin programs against
Mach/dispatch/notify" — the staging model already does this for the test guests. id-015 is turning
that proven guest-staging into a **distributable** dev-preview artifact (USB/ISO image), not
inventing a new build.

## Scope (when promoted)

**In:**
1. Audit the existing staging tooling first-hand (`stage-userland.sh` + the guest-image assembly —
   build tooling, not in product source; on the build host) — document what it does, pin the inputs
   (base image rev, overlay commit, pre-staged kernel provenance).
2. Produce a **distributable** amd64 dev-preview image (USB and/or ISO) from the staging model —
   carrying the rmxOS overlay (libdispatch/libnotify + `mach.ko`) + the pre-staged kernel.
3. Boot it standalone (not just in-place guest) to launchd multi-user — reuse the op-104
   block078-probe oracle.
4. Smoke: a Darwin-style sample (`dispatch_async` + `notify_post`) builds + runs on the booted
   image. Proves the developer-usable floor end-to-end.

**Out:** reproducible/third-party build (id-012 Tier 1, Gate F); `bsdinstall` install-to-disk
(id-012); asl/libxpc/Gate-C real-service lifecycle (deferred past preview); non-amd64.

## Truly-green criterion

- a distributable image built from the staging model boots standalone to a launchd-managed
  userland (op-104 oracle confirms), and a `dispatch_async`+`notify_post` sample builds + runs on
  it — first-hand, image-provenance honestly labeled (staging-model, NOT reproducible-release).

## Open decisions (Coordinator-held, at fetch)
- USB-only vs USB+ISO for the first preview cut.
- pre-staged kernel: keep `MACHDEBUG` for the preview (proven), or wait for a non-DEBUG kernel
  (cf. the op-111 KERNCONF note) — lean keep-MACHDEBUG for preview-ASAP, lighter kernel post-preview.
- whether to wait for the full notify conformance MATCH (op-110) or ship the preview image once
  notify *runs* (developer-usable floor = runs; conformance is the Gate-B arc).
