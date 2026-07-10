# op-184 — Implementer: build the DTrace-enabled soak-variant image (provenance-preserving augment of the certified op-149 image) — unblocks every oracle-based soak downstream

op-184 | role: **Implementer** (cost-30) | EXU: **wip-gpt** | state: **[Done]** — `dtrace-image-ready`, adjudicated 2026-06-29 (Arranger, VERIFIED first-hand via builder artifacts). D0 gate found modules ABSENT (third + definitive confirmation) → took the COPY route (no recompile). Installed the certified op-182 dtrace set + opensolaris.ko into a distinct copy. PROVENANCE INTACT verified first-hand from `op184-provenance-sha256.txt` + `op184-final-mounted-verification.txt`: kernel sha `c526a91d…` AND mach.ko sha `30d23616…` BYTE-IDENTICAL to the cert (augment perturbed neither). DTrace live (kldload dtrace+fbt OK, `dtrace -l` lists). Published `/Users/me/wip-mach/vm/runs/op184-soak-dtrace-v3.img` sha `cd71126e…` (re-confirmed on the landed file). CONSUME: `NXPLATFORM_VM_IMAGE=/Users/me/wip-mach/vm/runs/op184-soak-dtrace-v3.img`. → UNBLOCKS li-1012 P2 (li-1001 oracle re-confirm) + li-1007 + op-188 D3 dry-run. (Arranger could not independently re-mount — mdconfig needs privilege — accepted on the builder's content-check artifact trail, which is the discipline-required check, produced first-hand.) PREMISE CORROBORATED (2026-06-28, post-op-168). op-168's li-1001 leg DEFERRED precisely because dtrace modules were absent (oracle could not run) — second independent inference of absence (first was assemble-op149.log's no-installkernel). NOT yet kldload-proven, but the op-168 soak guest has powered off, so the GATE is now runnable without perturbing anything: kldload-check (re-boot the image + `kldload dtrace && kldload fbt && dtrace -l | head`) OR mount-check `/boot/kernel/dtrace.ko`. Outcome: present → RETIRE (kldload at soak time); absent (expected) → op-184 shrinks to a MODULE COPY from the op-182 obj (NOT a recompile). Do NOT retire op-184 outright — it's load-bearing for li-1012 P2 (li-1001 oracle re-confirm) + li-1007 either way. (Arranger could not mount the image — mdconfig needs host privilege; deferred to this gate.) The "op-149 image LACKS dtrace modules" claim was an assumption, never mount-verified. First-hand check of `assemble-op149.log`: the image was assembled by a CUSTOM process with NO stock `installkernel` — only `mach.ko` was hand-installed into `/boot/modules` (line 45469); the stock module set (which on FB15 GENERIC includes `sys/modules/dtrace/*` by default, no MODULES_OVERRIDE/WITHOUT_CDDL in the v3 make.conf) was never invoked here. So whether `/boot/kernel/dtrace.ko` is present is UNKNOWN from logs. **GATE before any build:** run `kldload dtrace && kldload fbt && dtrace -l | head` inside op-168's already-booted soak guest (free, non-perturbing). If it loads → modules present → **RETIRE op-184 (just kldload at soak time).** If "module not found" → modules absent → this op shrinks to a module COPY (install prebuilt `.ko`s from op-182 obj, or kldload by path), NOT a recompile. Do NOT mount the image while op-168 soaks on it. | parent id: id-026 | L1i: li-1007 (integration soak) / li-1012 (P2 re-confirm) | authored 2026-06-28 (Arranger seat, model Opus 4)

## WHY (one line)

Every oracle-based soak downstream — li-1012 P2 (mach-IPC li-1001 oracle re-confirm on clean provenance) AND
li-1007 (the complete all-services integration soak) — needs the DTrace pillar. The certified op-149 image
LACKS the dtrace `.ko` modules (that's exactly why op-168 had to defer `OP168_INVARIANTS`). This op closes that
gap the LIGHT way — no rebuild, no provenance fork.

## CONTEXT (Arranger-verified first-hand 2026-06-28 — take as given)

- The MACHDEBUGDEBUG kernel ALREADY supports DTrace: config chain MACHDEBUGDEBUG → MACHDEBUG → GENERIC, and
  GENERIC carries `options KDTRACE_FRAME` + `options KDTRACE_HOOKS` + `makeoptions WITH_CTF=1`
  (`sys/amd64/conf/GENERIC:88-89,24`). So NO kernel rebuild is needed — kernel support is compiled in; only the
  loadable dtrace modules were never installed into the image.
- The dtrace kmods are ALREADY BUILT in the op-182 certified obj tree (same MACHDEBUGDEBUG build, same
  provenance): `dtrace.ko`, `fbt.ko`, `systrace.ko`, `profile.ko`, `dtraceall.ko` (+ the rest of
  `sys/modules/dtrace/*`) present under
  `build/op182-li1012-clean-cert/obj/.../amd64.amd64/sys/MACHDEBUGDEBUG/modules/.../sys/modules/dtrace/`.
- Base image (build-host, builder owns it): `build/op149-preview-image/op149-preview-uefi-v3.img`, sha256
  `707936a615fd8ad0b63682fd5cdf2129d5097e68f47645969d79b343e6ffba8a` (kernel `c526a91d…`, mach.ko `30d23616…`,
  HEAD c14e0904).

## DELIVERABLES (verify identity first-hand — sha, never filename/size)

**D1 — work on a COPY.** Make a fresh working copy of the certified image. Do NOT mutate the published
`vm/runs/op149-preview-uefi-v3.img` (op-168 is consuming it) and do NOT mutate the build-host certified original.

**D2 — install the dtrace module set from the op-182 obj** into the copy's `/boot/kernel` (the standard module
location), using the op-182 `MAKEOBJDIRPREFIX` so linker-hints/CTF/module deps are produced correctly
(`make -C sys/modules/dtrace install DESTDIR=<mounted-copy>` against the op-182 obj — modules come from THAT obj
ONLY, same provenance; not a fresh build, not host modules). Include CTF data (WITH_CTF) so fbt/sdt symbol
resolution works.

**D3 — prove provenance preserved.** On the variant: kernel sha MUST still equal `c526a91d…` and mach.ko sha
MUST still equal `30d23616…` (the augment touches ONLY added modules; the kernel + mach.ko are byte-identical to
the cert). If either changed, STOP and report — the augment must not perturb the certified artifacts.

**D4 — prove DTrace is live + publish.** Boot-smoke the variant: `kldload dtrace`, `kldload fbt`, then
`dtrace -l | head` lists probes (fbt + syscall providers resolve). Publish the variant to the shared handoff
path under a DISTINCT name: `/Users/me/wip-mach/vm/runs/op184-soak-dtrace-v3.img`. Report final absolute path +
sha + size, and the exact `NXPLATFORM_VM_IMAGE` for the downstream oracle soaks.

**VERDICT:** `dtrace-image-ready` (variant boots, kernel+mach.ko sha UNCHANGED, dtrace probes list, published →
li-1012 P2 + li-1007 unblock) | `walled` (mount/install/space/CTF failure → report it, do not improvise).

## BOUNDARIES
- COPY, don't mutate — neither the published soak image nor the build-host certified original may change.
- NO world/kernel rebuild. Kernel + mach.ko stay byte-identical (sha `c526a91d…` / `30d23616…`). Modules are
  INSTALLED from the existing op-182 obj, not rebuilt.
- Modules from the op-182 obj ONLY (same-provenance), never host `/boot/kernel` dtrace kmods (would break
  single-source provenance).
- Publish only to the shared `vm/runs/` handoff path (agent_host_isolation) — distinct name, do not overwrite
  `op149-preview-uefi-v3.img`.

## MARKERS
```
OP184_IMG_COPIED          # fresh working copy of the certified image (not the published/original)
OP184_DTRACE_INSTALLED    # dtrace module set installed from op-182 obj into copy's /boot/kernel (+CTF)
OP184_PROVENANCE_INTACT   # kernel sha==c526a91d AND mach.ko sha==30d23616 UNCHANGED on the variant (y/n)
OP184_DTRACE_LIVE         # boot: kldload dtrace+fbt OK, `dtrace -l` lists probes
OP184_PUBLISHED           # final absolute path + sha + size of the variant at vm/runs/
OP184_CONSUME_PATH        # NXPLATFORM_VM_IMAGE for the downstream oracle soaks
OP184_VERDICT             # dtrace-image-ready | walled
OP184_TERMINAL
```

## RELATIONS
- UNBLOCKS li-1012 P2 (the li-1001 mach-IPC oracle re-confirm needs DTrace) AND li-1007 (the complete
  integration soak — op-123 notify + op-146 asl + dispatch + mach-IPC oracle + dtrace).
- UPSTREAM: op-182 (the obj that supplies the modules), op-149/op-183 (the base image being augmented).
- DOWNSTREAM: the held li-1007 integration soak; the li-1012 P2 re-confirm legs.
- Independent of op-168's verdict — this is build hygiene that serves the downstream soaks either way; run it
  parallel on the build host, don't wait on the adoption gate.
- feedback: build_is_implementer (builder installs from its own obj + delivers the variant), agent_host_isolation
  (publish to vm/runs only), artifact_identity_needs_content_check (sha kernel+mach.ko on the variant),
  dtrace harness (load providers individually at soak time), no improvise-under-walled.
```
