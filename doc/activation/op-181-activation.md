---
id: op-181
state: dropped
updated: 2026-09-27T22:54Z
legacy-state: Awaiting
reset: j-20260927-004
---
# op-181 — Implementer: build `mach.ko` in the clean-env world via the PROVEN standalone recipe (no KERNBUILDDIR opt-symlink) — completes the cold-build artifact set (world + kernel + mach.ko)

op-181 | role: **Implementer** (cost-30) | EXU: **wip-gpt** | state: **[Awaiting]** — released for dispatch (build EXU only; overnight batch ok) | parent id: id-026 | L1i: li-1012 P0 | authored 2026-06-28 (Arranger seat, model Opus 4 — root cause VERIFIED first-hand from the op-180 mach-module log)

## WHY (one line)

op-178 (buildworld) + op-180 (buildkernel MACHDEBUGDEBUG) are GREEN rc=0 in the clean-env world, but the rmxOS
Mach module `mach.ko` is NOT staged — and rmxOS without Mach isn't rmxOS. op-180's mach-module attempt failed
with exactly ONE error; this op clears it with the established recipe, no source/infra edits.

## CONTEXT (Arranger-verified first-hand 2026-06-28 — take as given)

- `mach.ko` is a **loadable module, built STANDALONE** — it is deliberately NOT part of buildkernel. Confirmed:
  `mach` is absent from `sys/modules/Makefile` SUBDIR (grep: no match); `sys/conf/files` has zero compat/mach
  entries; GENERIC has no `COMPAT_MACH` → Mach is module-only, not in-kernel. The canonical historical build is
  `scripts/bhyve/stage-guest.sh:315`: `env MAKEOBJDIRPREFIX=<prefix> make -C <src>/sys/modules/mach install`
  (MAKEOBJDIRPREFIX only — **no KERNBUILDDIR**). Staging scripts expect the artifact at
  `<kernel_objdirprefix><freebsd_src>/amd64.amd64/sys/modules/mach/mach.ko`.
- The MIG servers are PRE-GENERATED + committed on disk (`sys/compat/mach/{host_priv,mach_host,mach_port,
  mach_vm,task,vm_map,clock}_server.c`; `.defs` in `sys/compat/mach/defs/`). No MIG generation needed at build
  time. `bus_if.h`/`device_if.h`/`vnode_if.h` self-generate in a standalone kmod build (op-180 log confirms the
  awk steps fired). So the module is self-sufficient standalone.
- **THE op-180 FAILURE, root-caused (log `build/op177-clean-env-v3/logs/buildkernel-op180-mach-module.rc`=2):**
  exactly ONE compile error — `compat/mach/ipc/mach_port.c:101: fatal error: 'opt_compat_mach.h' file not found`.
  Cause: the op-180 invocation resolved opt headers by **symlinking from the MACHDEBUGDEBUG kernel obj dir**
  (log: `ln -sf .../sys/MACHDEBUGDEBUG/opt_compat_mach.h opt_compat_mach.h`) — i.e. KERNBUILDDIR-style wiring.
  That symlink is **dangling**: config(8) never emits `opt_compat_mach.h`, because `sys/conf/options:103` maps
  `COMPAT_MACH → opt_global.h`, NOT a standalone `opt_compat_mach.h`. So the kernel dir has no such file →
  "file not found". (`opt_ntp.h`/`opt_capsicum.h` symlinks resolved because those ARE registered options.)
- **Why the empty-file fix is correct + sufficient:** `mach_port.c` is the ONLY file in the whole module that
  `#include`s `opt_compat_mach.h` (grep: 1 hit). The actual `COMPAT_MACH` define is supplied by `-DCOMPAT_MACH`
  on the module CFLAGS (`sys/modules/mach/Makefile:30`). So an EMPTY `opt_compat_mach.h` fully satisfies the
  include — its only job is to exist. The proven standalone recipe (no KERNBUILDDIR) makes `bsd.kmod.mk`
  synthesize that empty opt file locally instead of symlinking a non-existent one from the kernel dir.

## DELIVERABLES (verify bg exit codes first-hand — rc-file + log marker, not "exit 0")

**Q1 — build `mach.ko` via the proven standalone recipe, in the SAME clean/scrubbed env as op-178/180.**
- Use the op-180 obj prefix (`build/op177-clean-env-v3/obj` → `MAKEOBJDIRPREFIX`) so the artifact lands at the
  staging-expected path `<prefix><src>/amd64.amd64/sys/modules/mach/mach.ko`.
- Invoke `env MAKEOBJDIRPREFIX=<prefix> make -C <src>/sys/modules/mach obj all` — **do NOT pass KERNBUILDDIR**
  (that is what triggered the dangling opt_compat_mach.h symlink). Let `bsd.kmod.mk` create the empty opt files.
- **Env hygiene is load-bearing** (op-176 lesson): the build shell must be SCRUBBED of the `/usr/local` leak
  (`C_INCLUDE_PATH`/`CPATH`/`CPLUS_INCLUDE_PATH`/`OBJC_INCLUDE_PATH`/`LIBRARY_PATH`/`LD_LIBRARY_PATH`). The
  module's debug-split (`mach.ko` → `mach.ko.debug`) runs objcopy/strip; a clean env lets the in-tree stripper
  work (op-177 proved stock elfcopy strips rc=0 once the env is clean). Capture rc to a `.rc` file + a log.

**Q2 — confirm the artifact, first-hand.**
- `mach.ko` exists at the expected path; `file mach.ko` = `ELF 64-bit LSB relocatable` (kld); rc=0 + a build
  marker in the log (not just "exit 0"). Report the path + size + `file` line.
- Sanity: `nm mach.ko` shows the Mach surface (e.g. `mach_msg`, `ipc_*`, `task_*`) and the module init. This
  proves it's the real Mach module, not an empty/degenerate object (artifact-identity discipline — don't infer
  from filename/size).

**Q3 — provenance note (do NOT over-engineer; one line each).**
- State plainly whether this mach.ko was built on the SAME source HEAD as the op-178/180 world+kernel (it must
  be, for li-1012 clean-provenance). If the obj prefix was reused warm from op-180, say so — that's expected
  here (the module is a separate standalone target), but flag it for the li-1012 cert pass.
- Confirm ZERO FreeBSD-file edits were needed (the fix is invocation-only: drop KERNBUILDDIR). If you find you
  CANNOT avoid an edit, STOP and report — do not freelance an `sys/conf/options` change (that would relocate
  `COMPAT_MACH` off `opt_global.h` and is out of scope).

**VERDICT (one of):**
- `mach-ko-staged` → mach.ko built rc=0 at the expected path, `file`+`nm` confirm a real kld → artifact set
  (world + kernel + mach.ko) complete in the clean-env world → unblocks op-149 image assembly.
- `recipe-insufficient` → the standalone recipe did NOT clear it (a DIFFERENT error than the opt_compat_mach.h
  symlink) → report the new error + log cite, do not patch around it.

## BOUNDARIES
- Build EXU only. **Invocation-only fix — keep every FreeBSD file byte-identical** (the failure is build wiring,
  not source). Do NOT add `mach` to `sys/modules/Makefile`, do NOT touch `sys/conf/options`, do NOT pass
  KERNBUILDDIR. (Wiring mach into buildkernel is a SEPARATE design question — out of scope here; the proven path
  is the standalone module build.)
- Stage strictly in wip-gpt's own owned dir + the existing `op177-clean-env-v3` obj prefix; no host-global paths.
- Scrubbed/hermetic env mandatory (op-176). Verify rc first-hand (rc-file + log marker), not a task "exit 0".

## MARKERS
```
OP181_BUILD_RC        # mach.ko build rc (rc-file path) + log marker; scrubbed-env confirmed
OP181_ARTIFACT        # mach.ko path + size + `file` line (ELF kld) + nm Mach-symbol spot-check
OP181_FBEDITS         # FreeBSD-file edits required: expect NONE (invocation-only: dropped KERNBUILDDIR)
OP181_PROVENANCE      # same-HEAD as op-178/180 world+kernel? warm-prefix reuse noted for li-1012
OP181_VERDICT         # mach-ko-staged | recipe-insufficient
OP181_TERMINAL
```

## RELATIONS
- li-1012 P0 — completes the clean-env artifact set (op-178 world + op-180 kernel + this mach.ko). NB: current
  greens were mid-flight-patched on a resumed prefix; a single clobbered world+kernel+mach.ko pass from final
  source is still owed for the actual li-1012 cert (separate op).
- UPSTREAM: op-178 (buildworld GREEN), op-180 (buildkernel MACHDEBUGDEBUG GREEN; flagged this mach.ko gap).
- DOWNSTREAM (RESERVED): op-149 v3 image assembly consumes mach.ko (staged to `/boot/modules/mach.ko` per
  stage-guest.sh) — with the PRODUCTION v3 KERNCONF, not MACHDEBUGDEBUG; op-168 Gatekeeper soak on that image.
- feedback: build_is_implementer (build EXU only), background_exit_code_hygiene (rc-file + marker, not "exit 0"),
  userland_port_no_buildinfra_changes (invocation-only, FB files byte-identical), artifact_identity_needs_
  content_check (file+nm, not filename/size), agent_host_isolation. project_64bit_only_no_lib32 (do NOT reopen
  the FreeBSD32 path while building the module).
```
