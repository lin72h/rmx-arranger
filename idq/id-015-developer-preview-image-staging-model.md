# id-015 — developer-preview image via the staging model (1.0-preview's bootable-image leg)

- id: id-015
- state: **op-128 COMPLETE 4/4 — RETIRED (Arranger-verified first-hand 2026-06-24); bootable-image
  floor of the 1.0-preview PROVEN end-to-end.** Both step-3 samples GREEN first-hand (markers
  `rmx-gatekeeper/findings/op128-step3-smoke-markers.txt` @ `0e50287`): sample 1 dispatch (Path B
  host-built binary, shell-run) `OP130_DISPATCH status=0` + `OP130_TERMINAL status=0` +
  `OP128_STEP3B_RUN_RC=0` (serial `op128-step3b-dispatch-serial.log` L136-137); sample 2 notify
  (launchd-job via shipped runner) `NOTIFY_SMOKE_TERMINAL status=0`, full round-trip. Path B reframe
  validated: dispatch proven host-built/image-run like every other artifact (libs/mach.ko/bs_probe).
  **NEW GAP surfaced (op-128, load-bearing — NOT cosmetic): notifyd is not a launchd system job on the
  image** — `/etc/launchd.d/` ships `com.apple.syslogd.plist` but NOT a notifyd entry, so on a COLD boot
  notify is unreachable until a developer manually `launchctl load+start com.apple.notifyd`. The smoke's
  notify round-trip went green ONLY because the Gatekeeper's rc.local loaded+started notifyd — i.e. the
  truly-green criterion was met **with a test-harness prop**, not the shipped image's own cold-boot
  behavior. **Arranger decision (you-decide): FIX, not catalog-around** — the fix is a one-file plist
  mirroring the already-shipped syslogd entry; an absent notifyd auto-start is an oversight, and "preview
  where notify is dead on boot" undercuts the developer-usable RUN floor. → **op-134 (Explorer authoring,
  free):** author `com.apple.notifyd.plist` (+ `.json`) mirroring shipped `com.apple.syslogd.plist` +
  patch staging tooling to install into `/etc/launchd.d/`; cold-boot re-validation (notifyd auto-starts
  WITHOUT rc.local + notify round-trip green on clean boot) folds into the next Gatekeeper image touch.
  Interim: PREVIEW-README must document the manual-load workaround (honest until op-134 lands).
  **id-015 does NOT retire as developer-usable-truly-green until cold-boot notify reachability is proven
  without rc.local injection (op-134).** (Prior, same op-128:)
  Sample 2 (notify)
  GREEN: serial L183 `NOTIFY_SMOKE_TERMINAL
  status=0` — full round-trip on the booted standalone image (port=19 → `bootstrap_look_up kr=0` →
  register/post rc=0 → check=1), shipped-artifacts check passed. Sample 1 (dispatch **in-guest compile**)
  BLOCKED: serial L152 `mach/clock_types.h:1 → #include <sys/mach/clock_types.h>` file not found — the
  staging image ships a PARTIAL overlay dev-header set (`/usr/include/dispatch/`, `/usr/include/mach/`
  present) but NOT the full closure. **Architectural finding (the op-114 audit predicted this): the
  staging-model image is a RUN target, NOT a BUILD target** — it copies libs/bins (selective lib-copy),
  it does NOT install the coherent overlay dev-header tree. In-guest compilation of overlay programs is a
  **buildworld includes-phase** property = the id-012 / li-006 arc (post-preview, deferred). Piecemeal
  header staging is whack-a-mole (closure descends mach ↔ sys/mach ↔ apple ↔ os ↔ dispatch). **NB the
  Gatekeeper's path-A premise is STALE:** it named "op-111 blocked at thrworkq.h `__packed`" but id-022
  (`thrworkq __packed`) is RETIRED (op-126 + op-111 r5); the real path-A wait is the *entire deferred
  buildworld arc* (next wall past test-includes undiscovered, Coordinator-deferred pending x86_64-v3/KERNCONF).
  **PATH B DECIDED (Arranger, Coordinator-delegated):** host
  cross-compile `op130-dispatch-async-f.c` against the full source-tree header closure + obj libs → stage
  the BINARY (not headers) → re-boot → run in-guest → `OP130_DISPATCH status=0`. Rationale: every other
  image artifact (libs, mach.ko, **bs_probe**) is host-built-then-staged; sample 2's own "green" ran a
  host-built shipped bs_probe (compiled nothing in-guest), so B proves both samples on equal footing
  (host-built, image-run). Reframe the truly-green criterion to "developer can RUN Darwin dispatch+notify
  programs on the booted image (built via the normal cross-compile workflow)"; in-guest compile becomes an
  explicit li-006/post-preview property, NOT a preview-floor bar. Path C (broad one-shot header staging)
  rejected by both Gatekeeper + Arranger (base-header mismatch / incoherence risk). My op-128 step-3 spec
  erred in saying "compile in-guest" — wrong for a staging (lib-copy) image. (Prior: 3/4 GREEN/DONE.)
  Step 1 package DONE (`dev-preview-memstick.img`, 3.1GB MBR+ESP+UFS, make-memstick rc=0,
  staging-model provenance). **Step 2 boot-standalone GREEN** — memstick boots to launchd multi-user;
  Arranger-verified the 199-line serial (`/Users/me/wip-mach/build/op128-dev-preview/memstick-serial.log`):
  boot.rc=0, `BLOCK078_NOTIFYD_ROUNDTRIP status=0` @L162, 0 panic/fatal, clean shutdown. The marker is
  backed by a live PATH-1/PATH-2 split that reproduces the id-016 decision **on the booted image**:
  shell `bootstrap_look_up(notify) kr=268435459 port=0` → FAIL (L164-168); launchd-child
  `port=19`→`bootstrap_look_up(notify) kr=0 port=21`→register/post/check all rc=0 (L176-181) → full
  round-trip. **Two caveats (verified):** (a) only 3/5 op-104 markers fired (LINK_LOAD/NOTIFYD_ROUNDTRIP/
  TERMINAL; not TWQ_TRACE/LAUNCHD_CHECKIN) — variant probe, core launchd+notify signal present so step-2
  holds but it is NOT the full op-104 oracle; (b) persistent non-fatal `ipc_entry_lookup failed on 0
  ipc_kmsg.c:1318` spam through boot (did NOT block the round-trip) — characterization candidate, NOT
  folded. Step 4 ship-runner DONE (`/root/run-as-launchd-job.sh` + `.plist.template` + `PREVIEW-README.md`
  li-005 gap doc baked in). **Step 3 smoke PENDING (dispatchable, no longer blocked) — both samples
  AUTHORED + ACCEPTED.** op-130 authored two artifacts, both Arranger-verified first-hand and RETIRED:
  (Sample 1) `op130-dispatch-async-f.c` `f9e1a52` — shell-launch, `OP130_DISPATCH status=0`→`OP130_TERMINAL
  status=0`; (Sample 2) `op130-notify-smoke-recipe.sh` `60f5066` — REWORKED (the original `f9e1a52` cut
  carried a false "image ships nothing" premise from a wrong-slice mount: it used GPT detection on an
  MBR/BSD-slice-s2a image → empty `/root` misread, contradicted by step-2). The reworked recipe DETECTS
  shipped artifacts (`NOTIFY_SMOKE_SHIPPED_CHECK`, stages NOTHING) → invokes the SHIPPED
  `/root/run-as-launchd-job.sh /root/bs_probe` → gates `NOTIFY_SMOKE_TERMINAL` on the five parsed values
  (`bootstrap_port≠0`, `bootstrap_look_up kr=0`, `notify_register_check rc=0`, `notify_post rc=0`,
  `notify_check check=1`); status=1 if any wrong, no paper-green terminal. **Step 3 now just RUNS these two
  accepted artifacts on the booted image** (Gatekeeper) — no re-authoring. No staging.
  (Prior: leg 1 DONE op-114 `7951ebc`, Arranger-verified 2026-06-23.)
  **Launch-model decided (id-016 (c), op-127):** leg-4 smoke runs the **notify** sample as a **launchd
  job** (shell-launch gets `bootstrap_port=0` → FAIL, proven by op-127); the **dispatch** sample runs
  from a shell (no bootstrap needed). op-128 also ships the launchd-job runner (plist template + one-line
  `launchctl load` helper) + documents the shell-launch li-005 gap in the preview README. Fetch gate met: preview floor subsystems all green — Mach
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
  release pipeline, now post-preview li-006 hardening; id-015 is the cheaper preview-now path);
  **id-007/op-104** (the staging-model boot oracle this rides); **id-006/010** (the subsystems that
  must be present + green in the image).

## Why this is distinct from id-012 (the op-111 finding)

op-111 established that rmxOS has two *different* image/boot paths that share the source tree but
not the build/stage path:

- **id-012 path (release pipeline):** `buildworld → installworld → make-memstick` — has **never
  completed** (id-014 + likely deeper breakage). Third-party-reproducible. li-006 / post-preview.
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
4. Smoke: a Darwin-style sample (`dispatch_async` + `notify_post`) **runs on the booted image**,
   built via the normal cross-compile workflow (host-built → staged binary → image-run). Proves the
   developer-usable floor end-to-end. **(REFRAME 2026-06-24, Path B):** "build" means host
   cross-compile, NOT in-guest compile — the staging-model image is a RUN target (selective lib-copy,
   no coherent dev-header tree). **In-guest compilation is explicitly OUT** (a buildworld includes-phase
   property = id-012/li-006, post-preview). This matches how every image artifact is produced
   (libs/mach.ko/bs_probe all host-built-then-staged; sample 2's notify proof itself ran a host-built
   shipped bs_probe).

**Out:** reproducible/third-party build (id-012 Tier 1, li-006); **in-guest compilation of overlay
programs** (needs the coherent overlay dev-header install = buildworld includes phase, id-012/li-006 —
the staging image ships libs, not the dev-header closure); `bsdinstall` install-to-disk (id-012);
asl/libxpc/li-003 real-service lifecycle (deferred past preview); non-amd64.

## Truly-green criterion

- a distributable image built from the staging model boots standalone to a launchd-managed
  userland (op-104 oracle confirms), and a `dispatch_async`+`notify_post` sample **runs on it**
  (host cross-compiled → staged binary → image-run; NOT in-guest compile — see the Path B reframe,
  2026-06-24) — first-hand, image-provenance honestly labeled (staging-model, NOT reproducible-release).
- progress 2026-06-24: both legs GREEN first-hand (op-128 4/4) — `dispatch_async` (Path B host-built,
  `OP130_DISPATCH/TERMINAL status=0`) + `notify_post` (round-trip `NOTIFY_SMOKE_TERMINAL status=0`).
  **cold-boot notify reachability — CLEARED 2026-06-25 (op-134 DONE `d245948`, Arranger-verified):** notifyd
  comes up on a clean boot and a notify round-trip is green WITHOUT any notifyd-specific harness prop, via a
  GENERIC boot-load of `/etc/launchd.d/*.plist` (`com.apple.notifyd.plist` staged, `KeepAlive:true`). op-134
  also surfaced **id-023** (rmxOS launchd does not self-scan `/etc/launchd.d/` — the generic boot-load is the
  bridge; macOS-faithful self-scan is a li-008 target, non-blocking). This blocker is closed; id-015's
  remaining open items are the Coordinator-held decisions below (USB-vs-ISO, MACHDEBUG kernel, conformance-wait).

## Open decisions (Coordinator-held, at fetch)
- USB-only vs USB+ISO for the first preview cut.
- pre-staged kernel: keep `MACHDEBUG` for the preview (proven), or wait for a non-DEBUG kernel
  (cf. the op-111 KERNCONF note) — lean keep-MACHDEBUG for preview-ASAP, lighter kernel post-preview.
- whether to wait for the full notify conformance MATCH (op-110) or ship the preview image once
  notify *runs* (developer-usable floor = runs; conformance is the li-002 arc).
