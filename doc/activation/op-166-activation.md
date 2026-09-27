---
id: op-166
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-166 — Implementer: stage the op-156-patched leg-4 soak image (graft patched `mach.ko` onto the op-123 leg-4 base) — the build that unblocks op-165 (notify leg-4)

op-166 | role: **Implementer** | EXU: **wip-gpt (Implementer seat)** | state: **[Done] → [Retired]** (2026-06-27) — patched leg-4 image staged + Arranger-verified first-hand (`leg4-soak-op156.img` SHA `6aa7d184…`, mach.ko `9c7706a3…` carries `ipc_pset_port_changed`, no static pre-empt, harness intact); ran on the BUILD host parallel to op-163's soak. Deliverable produced, no residual in stage scope (running-load KBI = op-165's gate) | parent id: id-010 (notify leg-4) + id-025 (op-156 fix carrier) | authored 2026-06-27 (Arranger seat, model Opus 4)

purpose: op-165 (notify leg-4 hours-scale soak) is BLOCKED on a single missing artifact — a bootable soak image whose running `mach.ko` carries the op-156 fix (`ipc_pset_port_changed`). No such image is staged (`build/op123-leg4/leg4-soak.img` is the OLD **pre-fix** op-123 image). This op produces it. PASS here → op-165 is dispatchable for the next overnight batch; a soak on a stale pre-fix `mach.ko` would prove nothing about the fix (op-165 IMAGE_PROVENANCE gate).

ROLE BOUNDARY: build+stage = **Implementer-exclusive** (feedback_build_is_implementer). Deliver the BUILT, bootable image (+ provenance evidence) to the soak host — NOT a build-procedure doc. Do NOT run the soak (that is op-165, Gatekeeper). Do NOT prove the fix yourself (regression confirmation is Gatekeeper's at op-165).

STATE OF THE WORLD (verified first-hand — do NOT re-derive):
- op-156 fix **MERGED** on `origin/alpha` (merge `3c2dd7f`; fix commit `180d30bdb8c1`); the change is in `sys/compat/mach/ipc/ipc_pset.c` (no-set→set branch calls `ipc_pset_port_changed(port, MACH_RCV_PORT_CHANGED)` after `ipc_pset_add(nset,port)`; helper drains the port's own thread pool = the `thr_acts@0x20` head). Present in the alpha tip.
- op-156 verified: **`sys/modules/mach` builds CLEAN against the alpha object prefix** (`build/wip-rmxos-alpha-obj`) → the patched `mach.ko` ships as a MODULE **without a full `buildkernel`**. The pre-existing DTRACE `systrace_freebsd32` wall (id-017/018/020 buildworld track) does NOT block this module build.
- The leg-4 base image `build/op123-leg4/leg4-soak.img` already carries the full op-131-hardened notifyd soak harness: `bs_probe`, `notifyd-soak-driver.sh`, `notifyd-soak-oracle.d`, `run-as-launchd-job.plist.template`, `rc.local`. This op grafts a MODULE onto it — it does NOT rebuild the harness or the world.

DELIVER:
1. **Build the patched `mach.ko`** from `origin/alpha` @ `3c2dd7f` (confirm the checkout carries `ipc_pset_port_changed` in `sys/compat/mach/ipc/ipc_pset.c` first) via `sys/modules/mach` against the alpha object prefix `build/wip-rmxos-alpha-obj`. Report the built `mach.ko` SHA256.
2. **Graft it into a bootable soak image** — copy `build/op123-leg4/leg4-soak.img` to a new `build/op166-leg4-patched/leg4-soak-op156.img`, replace the `mach.ko` at its kernel-module load path with the patched module, leave the harness + notifyd untouched.
3. **Confirm the image LOADS the patched module at boot, not a stale/static one** — cite the boot config (`loader.conf`/`kld_list`/`rc`) that loads `mach.ko` from the grafted path; confirm the on-disk grafted module is the one the loader will pick up (no shadow copy under a different module dir, no statically-linked mach in the kernel that would pre-empt the .ko).
4. **Provenance evidence (so op-165's IMAGE_PROVENANCE gate is satisfiable first-hand):** the grafted on-disk `mach.ko` SHA256 + a symbol-presence check (`nm`/`readelf -s` showing `ipc_pset_port_changed`). This is the on-disk artifact proof; op-165 does the running-kernel confirmation at boot.

GATES (id-011 / build hygiene — Arranger will check first-hand):
- **Source provenance:** the `mach.ko` MUST be built from the alpha tip carrying `180d30bdb8c1` — cite the commit the build tree is at + the `ipc_pset_port_changed` symbol present in the BUILT module. A module built from a pre-fix tree silently defeats op-165.
- **Module-load reality (feedback_artifact_identity_needs_content_check):** do NOT claim the image is patched from the graft alone — prove the grafted `.ko` is on the actual load path AND that mach is loaded as a module (not statically built into the boot kernel, which would make the graft a no-op). If mach is static in this image's kernel, FLAG it — the graft model fails and a kernel re-stage is needed instead.
- **Exit-code hygiene (feedback_background_exit_code_hygiene):** the module build's real rc — tail the build log + confirm `mach.ko` mtime/SHA changed; a task-notification "exit 0" is a claim, not evidence.
- Harness MUST survive the graft untouched: re-confirm `bs_probe` + `notifyd-soak-driver.sh` + `notifyd-soak-oracle.d` still present in the new image (a graft that corrupts the harness = setup FAIL).

MARKERS:
```
OP166_MACHKO_BUILT status=0       # patched mach.ko built from alpha @ 3c2dd7f via sys/modules/mach; SHA256 + ipc_pset_port_changed present
OP166_IMAGE_GRAFTED status=0      # leg4-soak-op156.img created from op-123 base; mach.ko replaced at the module load path
OP166_LOAD_PATH_PROVEN status=0   # boot config loads the grafted mach.ko (cite loader.conf/kld); mach is module-loaded not static | FLAGGED
OP166_PROVENANCE status=0         # on-disk grafted mach.ko SHA256 + nm/readelf shows ipc_pset_port_changed (op-165 gate input)
OP166_HARNESS_INTACT status=0     # bs_probe + soak-driver + oracle.d still present in the new image
OP166_TERMINAL status=0
```

PUSH: build artifacts under `build/op166-leg4-patched/` (the image + the build log + the mach.ko SHA/symbol evidence); no product-tree commit (build/stage op). Report → **Arranger-seat first-hand verify** the built `mach.ko` carries `ipc_pset_port_changed` (symbol check, not the relayed marker) + the module is on the real load path (not a shadow/static defeat) + harness intact → then op-165 flips **[Queued] → [Awaiting]** (its image dependency satisfied) for the next overnight batch on the soak host.

CHAIN: op-156 merged (`3c2dd7f`) → **op-166 (stage patched leg-4 image, this — build host, parallel to op-163 soak)** → op-165 unblocked (notify leg-4 soak) → notify truly-green (id-010 retires) + id-025 regression-confirmed. Sequencing note: single soak host — op-163 (asl leg-4) holds it this batch; op-166 stages op-165's image in parallel so op-165 runs the NEXT batch without idling the host.

---

## ARRANGER-SEAT VERIFY (2026-06-27, Fable seat, model Opus 4, FIRST-HAND per Rule 1)

Verified the wip-gpt report against the raw artifacts in `build/op166-leg4-patched/` (not the relayed markers):

- **MACHKO_BUILT ✓** — `mach-module-build-3c2dd7f.rc` = `0`; build log shows the `ld … -o mach.ko.full … ipc_pset.o …` link from `sys/modules/mach` against the alpha object prefix. Manifest: `source_head=origin_alpha=3c2dd7f2bb7c`, `fix_commit=180d30bdb8c1`. Built `mach.ko` SHA256 `9c7706a3f187…`; `nm` shows `ipc_pset_port_changed` @ `0x1e800`.
- **IMAGE_GRAFTED ✓** — `leg4-soak-op156.img` from op-123 base (`base_image` SHA `277b41a7…`). `/boot/modules/mach.ko` replaced: pre-graft `7c8a710d…` (old base module) → post-graft `9c7706a3…` = **byte-identical to the built module**. Graft is exact.
- **LOAD_PATH_PROVEN ✓ (on-disk) — `static-vs-module-proof.txt`:** `ipc_pset_port_changed` is **absent from ALL FOUR image kernels** (`/boot/kernel/kernel`, `/boot/TWQDEBUG/kernel`, `/boot/MACHDEBUG/kernel`, `/boot/MACHDEBUGDEBUG/kernel`) and **present only in `/boot/modules/mach.ko`** → no static mach pre-empts the graft. `loader.conf`: `mach_load="YES"` + `module_path` includes `/boot/modules`; `rc.local` also `kldload mach`.
- **PROVENANCE ✓** — final image SHA256 `6aa7d1845da5…` (matches report); on-image module symbol re-confirmed.
- **HARNESS_INTACT ✓** — `bs_probe` (`cac3d9a3…`), `notifyd-soak-driver.sh` (`c80514c1…`), `notifyd-soak-oracle.d` (`1891ef40…`), `run-as-launchd-job.plist.template` (`af01662f…`), `rc.local` (`93fb8516…`) all present with hashes. Cleanup confirmed (no stray mdconfig/mount).

**op-166 is a CLEAN stage — all 6 markers verified first-hand.** The artifacts are honest (real SHAs, real symbol check, real static-vs-module disproof) — no id-011 manufacture.

### CAVEATS for op-165 (NOT op-166 defects — correctly deferred to op-165's gate)

1. **Running-load / boot-KBI is NOT proven by op-166 (by design).** `loader.conf` has multiple `kernel=` lines → **last-wins boots `MACHDEBUGDEBUG`**; the module was built against the alpha object prefix. op-166 proves on-disk presence + no static pre-empt, but NOT that the module successfully `kldload`s against the booted `MACHDEBUGDEBUG` kernel (KBI match). **op-165's IMAGE_PROVENANCE gate MUST do the RUNNING-kernel check** (`kldstat` mach loaded + `ipc_pset_port_changed` in the live kernel), not trust the on-disk graft. Safety net (bounded, no false-green): if `kldload mach` fails at boot, notifyd cannot come up → `rc.local` halts at `OP123_LEG4_FIRST_BLOCKER rung=notifyd_up` — a KBI mismatch surfaces as a hard setup-FAIL, never a silent unpatched soak. (Mitigating signal: module size `345456 → 345552`, +96B = just the added function; same alpha source tree the old base module loaded from → KBI match is likely but op-165 proves it.)
2. **`SOAK_DURATION` baked to 7200s (2h) in `rc.local`.** Clears the id-025 freeze window (~64min) but op-165 wants hours-scale overnight — op-165 must override `SOAK_DURATION` (env/rc.local) for a longer run AND sync the oracle `tick-Ns` to it (the op-165 brief's 120s-oracle warning).
3. **cond-3 `thr_acts@0x20` rider `.d` is NOT in this image** — only the base `notifyd-soak-oracle.d`. op-165 authors/adds the non-blocking 3-condition rider at run time (op-166 was image-staging only).
4. **Minor:** `rc.local` precondition also checks `/root/run-as-launchd-job.sh` (`-x`); the inventory listed the `.plist.template` + runner but did not re-hash `run-as-launchd-job.sh` explicitly. Carried from the untouched op-123 base (graft only touched `mach.ko`); `rc.local` self-halts if absent → no false-green. op-165 boot will confirm.

## TERMINAL RESOLUTION (Fable seat, 2026-06-27)

op-166 **→ [Done] → [Retired].** The deliverable — a bootable leg-4 soak image (`leg4-soak-op156.img`, SHA `6aa7d184…`) whose `/boot/modules/mach.ko` carries the op-156 fix `ipc_pset_port_changed`, with no static-mach pre-empt and the harness intact — is produced + Arranger-verified first-hand. No residual within op-166's stage scope; the running-load KBI confirmation is op-165's gate (caveat 1), not an op-166 reopen. **op-165's image dependency is SATISFIED** → op-165 flips [Queued]-on-image to image-ready (now blocked ONLY on the soak-host slot held by op-163 → next overnight batch).
