# id-012 — release / distribution image: bootable rmxOS USB + ISO (li-006 logistics)

- id: id-012
- state (2026-06-24 update): **next-wall discovery DEFERRED — Coordinator-held pending build-config
  decisions.** The includes-install arc AND the test-includes self-containment walls are now ALL cleared:
  id-020 (`__int8_t` under `-ansi`, op-125) + id-022 (`thrworkq __packed`, op-126) both RETIRED, validated
  by op-111 r4/r5. The build last stopped *at* test-includes; it has never been observed past that stage.
  An Explorer op to run the next full clean buildworld and surface the wall behind test-includes was
  drafted (op-132) **but the Coordinator deferred it back to IDQ (2026-06-24)** — does NOT want a vanilla
  full build yet, intends to first fold in build-configuration changes. **Coordinator's build-config ideas
  to land BEFORE the next-wall run (capture, not yet decided):** (1) default the build baseline to
  **x86_64-v3** microarch (AVX2-class ISA floor — a CFLAGS/`CPUTYPE`/`MACHINE_ARCH` baseline change,
  changes the codegen target for the whole world+kernel); (2) **kernel configuration changes** (KERNCONF —
  scope TBD by Coordinator). When un-deferred, the next-wall buildworld op MUST carry these as inputs (and
  still NO llvm-bootstrap skip — id-017 stays Coordinator-deferred during substantiation). Until then the
  next-wall item is **HELD** (no id opened yet, per don't-fold — wait to see the wall).
  (Prior, 2026-06-23:) Tier 0 op-111 build CROSSED INTO COMPILE (first time ever); the entire
  includes-install arc is COMPLETE+validated: id-014/op-113 (apple) +
  id-018/op-115 (9 dirs) + id-019/op-118 (lib dispatch/private/xpc) all retired by clean-build gates.
  The op-111 re-re-retry from `172ed6b` cleared the lib/ includes phase and **entered the world COMPILE
  phase** — the first non-includes wall: `__int8_t…__intmax_t` "unknown type name" under `-ansi`
  (→ **id-020/op-120**, a NEW compile class). Arc down the build: cross-tools → include/ → lib/ includes
  (ALL done) → **world compile (current wall)** → buildkernel → installworld+kernel → make-memstick →
  boot. Each remaining wall its own op. The full-release
  tier (Tier 1) still waits on the usability milestones li-001…li-005. The dev-preview Tier 0 was fetched into op-111
  and hit a hard wall — see "op-111 first-attempt finding" below: **no clean buildworld+buildkernel
  has ever completed for rmxOS**, so step 1 cannot produce a world+kernel to stage. Parked until
  op-113 fixes id-014 (and any further build-path breakage behind it).
  **NB (Arranger decision 2026-06-23, roadmap §1.0-preview, Coordinator-overridable):** this whole
  item — the *reproducible release pipeline* — is **NOT a 1.0-preview milestone**. The preview ships on
  the proven base+overlay+pre-staged-kernel staging model (op-104). id-012 is **li-006 hardening run
  in parallel, post-preview.** So op-111 is no longer preview-critical; it's the start of the
  build-pipeline-substantiation arc.
- raised: 2026-06-23 (Coordinator: distribution logistics — a FreeBSD-release-style USB image for
  developer-preview / 1.0)
- roadmap parent: [roadmap.md](../roadmap.md) — **li-006** (reproducible build → stage → boot:
  "a clean checkout builds + boots the guest reproducibly by *someone other than us*"). This is
  that gate's productization.
- relations: **id-007 / op-104** (provides the *test-guest* boot oracle — but NOT the release
  build/stage path; the test guests use base-image + overlay + pre-staged kernel, a distinct model
  from buildworld→installworld→make-memstick — see the op-111 finding); **id-014/op-113** (the
  first build-path blocker this item is gated on); **id-006/010/011** (the
  subsystems that must be staged into the image and boot); **li-003 / Phase 0.8 launchd** (the
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

So the risk is **not** writing a pipeline (the scripts are inherited). It is: *does the rmxOS
overlay survive the standard release build + boot* — the Darwin userland
(libdispatch/libnotify/libasl/launchd) **and the custom kernel modules (`mach.ko` et al)** must be
built into world+kernel, staged into the image, and boot to a usable launchd userland —
**reproducibly, by a third party.** **op-111 (2026-06-23) showed this is the dominant risk after
all:** the clean `buildworld` has never completed (fails at id-014, includes phase) and the overlay
has only ever been built piecemeal — so "survives the standard release build" is an *open
question*, not a near-given. See the op-111 finding above.

## op-111 first-attempt finding (2026-06-23) — the release pipeline is unexercised

Tier 0 was fetched into **op-111** (Gatekeeper). Recon + a clean-build attempt established (build
log first-hand on the Gatekeeper host; id-014 Makefiles Arranger-verified; obj-tree census
Gatekeeper-reported-first-hand):

- **No full `buildworld`+`buildkernel` has ever completed for rmxOS.** The clean attempt failed
  at the *includes phase* (id-014, `include/apple/uuid` install order) — very early, long before
  world/kernel compile. So there is likely **more breakage behind id-014**; op-113 fixing it is
  necessary but may not be sufficient for a clean build.
- **The overlay has only ever been built piecemeal** — kernel modules + targeted userland via the
  build tooling's `stage-userland.sh` (not in product source). Every obj tree is overlay/module-
  only (`bin/`=launchctl, `sbin/`=launchd, `lib/`=the ~21 Darwin libs); **none contains a kernel.**
- **The test guests boot via a DISTINCT model**, not the release pipeline: a base FreeBSD image +
  the rmxOS overlay + a **pre-staged kernel** (`loader.conf kernel="MACHDEBUG"` from
  `/boot/MACHDEBUG/`), assembled at image-creation time. This is why id-007/op-104 guests boot
  despite no buildworld — **they share the source tree but NOT the build/stage path** this item
  must productize. (Correction to the id-007 relation below, which over-claimed reuse.)

**Consequence:** li-006 is **unsubstantiated** — the `buildworld → installworld → make-memstick →
boot` release path has never run end-to-end. `make-memstick.sh` itself is inherited FreeBSD
machinery (low risk); the real risk is producing a clean world+kernel to feed it. A make-memstick-
machinery smoke on a guest-image tree was offered + **declined** (near-zero li-006 signal; risks a
misleading "memstick works" artifact). op-111 resumes only after a clean build actually succeeds.

## Why raise it now (even pre-1.0)

A **developer-preview USB image** is the first artifact an outside developer can actually run —
it converts "we have a guest we boot in bhyve" into "someone else can `dd` it to a stick and
boot rmxOS." That is the floor consumer in the roadmap (developer-usable: "build + run
Darwin-style programs against Mach/dispatch/notify on FreeBSD 15"). Standing the pipeline up early
also de-risks li-006: reproducibility/boot bugs surface on a real image long before 1.0, not at
the finish line.

## Scope (when promoted) — two tiers

**Tier 0 — developer-preview image (fetchable early, before full 1.0):**
1. `make buildworld buildkernel` with the rmxOS config produces a world+kernel containing the
   Darwin userland + custom kernel modules — clean, from a fresh checkout.
2. `make-memstick.sh` (and/or `mkisoimages.sh`) produces a **bootable amd64 USB/ISO** carrying
   that world+kernel.
3. The image **boots on the bhyve guest to a launchd-managed multi-user userland** (reuse the
   id-007/op-104 guest-boot path as the boot oracle) — not just single-user/console.
4. Smoke: a Darwin-style sample (a `dispatch_async` + `notify_post` program) builds + runs on the
   booted image. Proves "developer-usable floor" end-to-end.

**Tier 1 — 1.0 release (gated on li-001…li-005):**
1. Full `release.sh` run: memstick + ISO + VM images, **installable via `bsdinstall`** to a disk.
2. Subsystems staged + verified through the **li-003 lifecycle on first boot** (launchd brings up
   notifyd/asl/own daemons; they survive restart/reload on real hardware/VM, not a fixture).
3. **Reproducible-by-a-third-party** (li-006 truly-green): a documented clean-checkout →
   build → image → boot path that someone *other than us* can run and get a byte-comparable (or
   behavior-comparable) bootable image. Capture the non-reproducible points (timestamps, build
   host state) and pin them — mirrors the op-108 "kernel builds aren't byte-reproducible" lesson:
   define what "reproducible" means concretely (bit-identical vs boot-behavior-identical).
4. Release notes + the li-005 known-gaps backlog shipped *with* the image (1.0 ships with its
   cataloged gaps).

**Out:** the subsystem conformance work itself (id-006/010/011 — this *consumes* their green,
doesn't do it); non-amd64 arches (arm64 etc. — FreeBSD confs exist but rmxOS targets amd64 first);
package repo / pkg(8) distribution (separate logistics item if wanted).

## Truly-green criterion (what "li-006 passed" must mean)

- a clean checkout builds world+kernel (Darwin userland + `mach.ko`) with no manual fixups;
- `make-memstick.sh`/`release.sh` produces a bootable amd64 image carrying it;
- the image boots to a launchd-managed userland on the guest (build→stage→boot is a button, the
  id-007 boot oracle confirms it);
- **a third party reproduces it** from the documented path — the defining li-006 bar, not us
  re-running our own script.

## Open decisions (Coordinator-held, at fetch)
- target: cut a **developer-preview USB now** (Tier 0, de-risks li-006 early), or hold all of it
  for 1.0?
- reproducibility bar: **bit-identical** image (hard — timestamps, build-host state) vs
  **boot-behavior-identical** (pragmatic — same artifacts, same boot result). Lean
  behavior-identical for the preview, revisit bit-identical for 1.0.
- installer scope: full `bsdinstall` install-to-disk for the preview, or live/memstick-only boot
  first (cheaper) with install-to-disk deferred to Tier 1?
- arch: amd64-only for 1.0 (matches the explorer/gatekeeper guests) — confirm arm64 is post-1.0.
