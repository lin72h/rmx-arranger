# op-182 — Implementer: the li-1012 DO-IT-ONCE clobbered build from c14e0904 — clean-obj world + MACHDEBUGDEBUG kernel + mach.ko, the certified artifact source for the 1.0-preview image

op-182 | role: **Implementer** (cost-30) | EXU: **wip-gpt** | state: **[Queued]** — overnight batch (long clobbered build; build EXU only) | parent id: id-026 | L1i: **li-1012 P0 (the cert itself)** | authored 2026-06-28 (Arranger seat, model Opus 4)

## WHY (one line)

op-178/180/181 proved the full artifact set (world + MACHDEBUGDEBUG kernel + mach.ko) builds GREEN — but on a
RESUMED/warm prefix with mid-flight patches, so its provenance is provisional. li-1012 demands ONE clobbered
clean-obj pass from final source as the certificate. Coordinator chose the **DEBUG (MACHDEBUGDEBUG) KERNCONF**
for 1.0-preview, and the Arranger folded the cert + the preview-image SOURCE into this single do-it-once build
(no throwaway warm image). Every wall is already cleared in source → this is a low-risk, pre-flighted pass.

## CONTEXT (take as given — all walls cleared in committed source)

- Source HEAD: `c14e0904` on `op-171-x86-64-v3-alpha`. All fixes are IN the tree: config.h Mach-guard
  (`547038c`, keeps `HAVE_MACH_MACH_H` off on `__FreeBSD__`), `nooptions COMPAT_FREEBSD32` (`c14e0904`), op-171
  toolchain revert (`1ccac5bd`). The `.so`/EFI elf_begin wall + the llvm-ar Mach wall + the systrace_freebsd32
  wall are ALL resolved. No expected new walls.
- The ONLY non-source precondition is ENV HYGIENE (op-176): the build shell MUST be scrubbed of the `/usr/local`
  leak — `C_INCLUDE_PATH CPATH CPLUS_INCLUDE_PATH OBJC_INCLUDE_PATH LIBRARY_PATH LD_LIBRARY_PATH` all unset.
  This is the single thing that, if missed, re-breaks the staged elfcopy `.so` strip.
- mach.ko recipe is PROVEN (op-181): standalone `make -C sys/modules/mach`, **MAKEOBJDIRPREFIX only, NO
  KERNBUILDDIR** (KERNBUILDDIR dangles the `opt_compat_mach.h` symlink; without it `bsd.kmod.mk` synthesizes the
  empty opt file — correct, since `-DCOMPAT_MACH` is on CFLAGS and `mach_port.c` is the lone consumer).
- This build's artifacts (NOT the warm op-178/180/181 prefix) are the SOURCE for op-149's preview image. Use a
  FRESH obj prefix so provenance is unambiguous — do not reuse `op177-clean-env-v3/obj`.

## DELIVERABLES (verify rc first-hand per stage — rc-file + log marker, not "exit 0")

**D1 — clobbered (clean-obj) buildworld from c14e0904, scrubbed env.** Fresh/empty obj prefix (clobber or new
dir). Confirm tree is clean at `c14e0904` before starting. rc=0 + `World build completed` marker.

**D2 — buildkernel KERNCONF=MACHDEBUGDEBUG** against the same fresh prefix. rc=0 + `Kernel build for
MACHDEBUGDEBUG completed` marker. (Kernel proper; modules-with-kernel is fine but mach.ko is built in D3.)

**D3 — mach.ko via the op-181 standalone recipe** against the D2 obj prefix: `env MAKEOBJDIRPREFIX=<fresh>
make -C <src>/sys/modules/mach obj all`, NO KERNBUILDDIR. Confirm `opt_compat_mach.h` is an EMPTY REGULAR file
(not a symlink). rc=0.

**D4 — certify the set, first-hand.** For world+kernel+mach.ko: record path + size + sha256 + `file` line. mach.ko
`nm` spot-check shows the Mach surface (`_Xmach_port_*`, `mach_mod_init`, `_mod_metadata_md_mach`). State plainly:
single clobbered pass from c14e0904, scrubbed env, fresh prefix, ZERO mid-flight source edits → **li-1012
clean-provenance SATISFIED**. If ANY stage needed a source edit to pass, that BREAKS do-it-once → STOP, report
the edit, do NOT silently patch (the cert is void if the source diverged mid-build).

**VERDICT:**
- `li1012-certified` → all three stages rc=0 in one clobbered pass from c14e0904, no mid-flight edits → artifacts
  are the certified source for op-149.
- `cert-broke` → a stage required a source change or hit an unexpected wall → report it; the warm greens stand but
  the clean cert is deferred pending the named fix (which becomes its own op on a new HEAD).

## BOUNDARIES
- Build EXU only. Source byte-identical to c14e0904 throughout — **no mid-flight edits** (that is the cert's whole
  meaning). If a wall appears, STOP and report; do not freelance.
- Scrubbed/hermetic env mandatory (op-176). Fresh obj prefix (provenance clarity) — not the warm op-177 prefix.
- No KERNBUILDDIR for mach.ko. Do NOT reopen FreeBSD32. Stage in wip-gpt's owned dir only.
- Long build → overnight batch; do not run interactively.

## MARKERS
```
OP182_WORLD_RC     # clobbered buildworld rc + marker; scrubbed-env + fresh-prefix confirmed; HEAD=c14e0904 clean
OP182_KERNEL_RC    # buildkernel MACHDEBUGDEBUG rc + marker
OP182_MACHKO_RC    # mach.ko rc; opt_compat_mach.h empty-regular (not symlink); no KERNBUILDDIR
OP182_CERT         # world+kernel+mach.ko path/size/sha256/file; mach.ko nm Mach-surface; zero mid-flight edits y/n
OP182_VERDICT      # li1012-certified | cert-broke
OP182_TERMINAL
```

## RELATIONS
- **li-1012 P0** — this op IS the certificate. On `li1012-certified`, the standing "all core-service greens
  provisional pending clean-v3-image" caveat lifts for artifacts built from this set.
- UPSTREAM (de-risk, already done): op-178 (world recipe), op-180 (kernel recipe), op-181 (mach.ko recipe) — every
  wall pre-cleared, so this clobbered pass is expected to pass in one shot (complete-once pre-flight).
- DOWNSTREAM (RESERVED): op-149 assembles the 1.0-preview bootable image from THESE certified artifacts
  (MACHDEBUGDEBUG kernel + mach.ko staged to /boot/modules per stage-guest.sh); op-168 Gatekeeper soak on that
  certified image — its green is clean-provenance, no re-confirm owed.
- feedback: complete_once_not_iterative (whole fix surface mapped up front → one pass), build_is_implementer,
  background_exit_code_hygiene, long_ops_batch_mode (overnight), userland_port_no_buildinfra_changes (no
  mid-flight edits), clean_provenance_baseline (the do-it-once initiative this closes).
```
