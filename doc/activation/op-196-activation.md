# op-196 — Implementer: wire aslmanager (binary + com.apple.aslmanager.plist + /etc/asl.conf) into a bootable image → unblock the asl leg-4 store-bound re-soak

op-196 | role: **Implementer** (cost-30) | EXU: **wip-gpt** | state: **[Done — artifacts staged on a published image; but the JOB IS NOT WIRED TO RUN (inert plist) — see CAVEAT]** (2026-06-29 Arranger adjudication, first-hand). Produced: image `vm/runs/op196-aslmanager-wired-v3.img` sha `5deefecb…`; binary `/usr/sbin/aslmanager` sha `42dc12e7…`; plist `/etc/launchd.d/com.apple.aslmanager.plist` (StartCalendarInterval Minute=0, no KeepAlive/MachServices); `/etc/asl.conf` store_ttl 7 + max_store_size 25600000. ABSENCE_ROOT benign = stale base image (op163-soak predated the installworld that ships aslmanager; the certified world HAS it). **CAVEAT (load-bearing, carried to the re-soak): the plist is INERT.** launchd does NOT auto-scan `/etc/launchd.d/` (proven first-hand op-145: "launchd -u doesn't auto-load /etc/launchd.d/ — asld never loaded"; siblings are started by EXPLICIT `launchctl load+start` in rc.local, see op150-rc.local). The Implementer mirrored the plist LOCATION but not the LOAD mechanism — no `launchctl load`/`start` was added to the harness rc.local. Booted as-is, aslmanager never schedules → repeats the op-163 null result. The image is a USABLE BASE (binary+config staged); the job-load wiring is the re-soak harness's job (Gatekeeper, harness_authoring_is_gatekeeper) — folded into the downstream soak brief, NOT a re-dispatch of op-196. | parent id: id-011 (li-1004 asl, leg-4) | L1i: li-1004 | cost: 30 | authored 2026-06-29 (Arranger seat, model Opus 4)

## WHY (one line)

op-170 proved the op-163 leg-4 soak's store-bound criterion went unmet because **aslmanager is absent from the image and unwired** — no binary, no plist, no asl.conf — so neither reclaim trigger could fire. Make aslmanager actually present + scheduled + configured on a bootable image so the re-soak can exercise the real reclaim path. This is the asl leg-4 (id-011) green path.

## SCOPE / SUBJECT

- Source (in-tree, rmxOS overlay — EDITABLE): `usr.sbin/aslmanager/` (PROG=aslmanager; already in `usr.sbin/Makefile` SUBDIR line 6 since 2026-06-19). Config parser: `aslmanager.c:576 _aslmanager_set_param` reads asl.conf keys `store_ttl` (days, c:612), `max_store_size` (bytes, c:622), `aslmanager_debug`; params arrive via the asl.conf store_dst options path (`aslmanager.c:1446-1461`) or CLI `-store_ttl`/`-ttl`.
- Sibling reference (proven-loaded daemons — READ for the staging mechanism): `usr.sbin/notifyd/com.apple.notifyd.plist`, `usr.sbin/asl/com.apple.syslogd.plist`. NOTE: neither sibling Makefile has a plist-install rule — these plists reach the image + get loaded by some OTHER staging step (image-assembly / launchd load dir). Identify that mechanism and mirror it; do NOT invent a new one.
- Image base: rebuild from the certified op-182 lineage (the same world the op-149 preview image / op-184 dtrace image were assembled from). Produce a NEW bootable image carrying aslmanager.
- Config format truth: `usr.sbin/asl/asl.conf.5` (man page in tree). Only `asl_sim.conf` exists in-tree — **there is NO /etc/asl.conf**; it must be authored.

## DELIVERABLES

**D1 — diagnose the absence root cause FIRST (verify-first; do NOT blindly add install rules).** aslmanager has been in the SUBDIR since 2026-06-19, BEFORE the op-182 cert (2026-06-28) — so a current build SHOULD contain it. Determine first-hand why the op-170 image lacked it: does it FAIL to build (the Makefile carries many `-Wno-error=` knobs → fragile; buildworld may skip-on-fail)? built-but-not-installed (no install target / wrong BINDIR)? image predates the wiring? Report the actual cause (`OP196_ABSENCE_ROOT`) before fixing — the fix differs per cause.

**D2 — aslmanager binary installed.** Drive it to build clean and install to `/usr/sbin/aslmanager` on the image. Verify first-hand on the BUILT image (mount/readelf), not from a build log (background_exit_code_hygiene: a `make` rc in a notification is a claim — confirm the artifact exists).

**D3 — com.apple.aslmanager.plist authored (macOS-faithful).** aslmanager is a PERIODIC job, NOT a persistent daemon: `StartCalendarInterval` (hourly), `ProgramArguments=[/usr/sbin/aslmanager]`, low priority — NO `KeepAlive`, NO `MachServices`, NO persistent run. Faithful to the macOS `com.apple.aslmanager.plist` on the load-bearing keys; catalog any exotic key rather than over-engineer (launchd_plist_macos_fidelity). Stage it via the SAME mechanism that gets com.apple.notifyd.plist loaded (per D1/SCOPE) so launchd actually loads it on boot.

**D4 — /etc/asl.conf authored + installed.** Production-faithful store_dst reclaim params: `store_ttl 7` (days) + `max_store_size 25600000` (bytes / 25 MB), in the asl.conf store_dst syntax per `asl.conf.5` + the `_aslmanager_set_param` parser. Confirm first-hand that aslmanager parses them (run it once on the image / trace the store_dst options path c:1446-1461 → params non-default).

**D5 — publish the wired image to the shared handoff.** Produce the bootable image with {binary installed, plist staged+loadable, asl.conf present} and PUBLISH it to the shared, Gatekeeper-reachable root `/Users/me/wip-mach/vm/runs/` (name it e.g. `op196-aslmanager-wired-v3.img`), recording its sha — mirroring how op-184 published to vm/runs/. Do NOT leave it in wip-gpt's private tree (agent_host_isolation; the op-193 handoff-gap lesson — name the shared path). Implementer PRODUCES the image; does NOT run the soak (soak_is_gatekeeper).

**VERDICT:** `aslmanager-wired-image-ready` (D1 root-caused + binary/plist/asl.conf all first-hand verified on a published bootable image) | `walled` (build won't complete / image won't assemble — report the wall, do not improvise around FB build infra).

## BOUNDARIES
- Userland overlay ONLY: `usr.sbin/aslmanager`, the new plist, `/etc/asl.conf` are rmxOS artifacts — do NOT touch FB15 build infra (Makefile.inc1 / share/mk / toolchain). If the absence root cause (D1) points at a base-infra knob, diff vs stock first and REPORT rather than patch base (userland_port_no_buildinfra_changes).
- Implementer produces the image; the re-soak is a SEPARATE downstream Gatekeeper op (soak_is_gatekeeper). Do NOT run the soak here.
- Verify every artifact first-hand on the built image (binary present, plist in load dir, asl.conf parses) — build-log rc is a claim, not evidence (background_exit_code_hygiene).
- Stage in wip-gpt's owned dir; publish only the final image to the shared vm/runs/ handoff (agent_host_isolation).

## MARKERS
```
OP196_ABSENCE_ROOT       # why aslmanager absent despite usr.sbin SUBDIR — diagnosed (build-fail / not-installed / stale-image) BEFORE fix
OP196_BINARY_INSTALLED   # /usr/sbin/aslmanager present on built image, first-hand verified (readelf/mount, not build log)
OP196_PLIST              # com.apple.aslmanager.plist authored (StartCalendarInterval hourly), macOS-faithful, staged via the proven load mechanism
OP196_ASLCONF            # /etc/asl.conf store_ttl=7 + max_store_size=25600000 authored, parsed non-default by aslmanager store_dst path
OP196_IMAGE_PUBLISHED    # bootable wired image published to shared vm/runs/, sha recorded
OP196_VERDICT            # aslmanager-wired-image-ready | walled
OP196_TERMINAL
```

## RELATIONS
- UPSTREAM: op-170 [Retired] (verdict aslmanager-not-wired; trigger semantics: store_ttl=days default 0=never, max_store_size=bytes default 0=unlimited; on-disk file-backed store, RSS = FILE* I/O buffering not retention).
- DOWNSTREAM (to author AFTER image ready): a **Gatekeeper re-soak** op instrumenting {fd, RSS, on-disk store} that ACTUALLY FIRES reclaim in-window. **Design caveat (carry to that op):** `store_ttl=7` will NOT expire within a same-day soak (op-170's exact finding — TTL removes files OLDER than N days). So the re-soak must exercise the **size trigger** (`max_store_size`): generate >25 MB of store data so aslmanager's hourly run reclaims by size — OR pre-age dated store files. A naive short soak repeats op-163's null result. This op closes asl leg-4 (id-011) once that soak is green.
- PEER/CONTEXT: op-188/op-185 integration-soak track (separate); op-194/op-195 libxpc+launchd census (rx1, separate).
- feedback: build_is_implementer (Implementer builds the image, not a procedure doc), soak_is_gatekeeper (re-soak is Gatekeeper's), launchd_plist_macos_fidelity (faithful load-bearing keys), userland_port_no_buildinfra_changes (overlay only, diff-vs-stock if infra implicated), agent_host_isolation (publish to shared vm/runs/), background_exit_code_hygiene (verify artifacts first-hand), no_conflate_gating_with_readiness (green = soak fires reclaim, not just binary present).
```
