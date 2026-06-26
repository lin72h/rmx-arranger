# op-166 — Implementer: stage the op-156-patched leg-4 soak image (graft patched `mach.ko` onto the op-123 leg-4 base) — the build that unblocks op-165 (notify leg-4)

op-166 | role: **Implementer** | EXU: **wip-gpt (Implementer seat)** | state: **[Awaiting]** — released, runs on the BUILD host PARALLEL to op-163's soak (different host; no soak-host contention) | parent id: id-010 (notify leg-4) + id-025 (op-156 fix carrier) | authored 2026-06-27 (Arranger seat, model Opus 4)

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
