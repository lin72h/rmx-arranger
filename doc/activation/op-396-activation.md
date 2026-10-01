---
id: op-396
state: returned
agent: implementer
repo: rmx-implementer
idq: id-047
gate: validator
authority: build: kernels RMXOS-RELEASE, RMXOS-KASAN, RMXOS-KMSAN, RMXOS-KCSAN and RMXOS-KUBSAN (trial) with mach.ko, from the branch below; stage one test image per built profile with rmx-stage-image; no guest runs; no push
updated: 2026-10-01T07:33Z
---
# op-396 — Implementer: Testing 1.0 — mach.ko built with its kernel, and sanitizer kernel profiles

## Outcome

On a new branch `testing-1` off `origin/alpha2` (`2884304b67fc454ee60187ce4731fca01cbefe6a`) in
`wip-rmxos`, build `mach.ko` with its kernel and add sanitizer kernel configurations. Use
FreeBSD's own form, so later stable/15 merges and upstream submissions stay simple. Make two
commits, with FreeBSD-style subjects:

1. `mach: build mach.ko with the kernel`. Add `mach` to `sys/modules/Makefile`, gated on
   `COMPAT_MACH` in `KERN_OPTS` the way other modules are gated (for example
   `.if ${KERN_OPTS:MKDTRACE_HOOKS}`, line 452). `buildkernel` then builds it with `KERNBUILDDIR`
   set. Make only the changes that building with the kernel needs. One is known:
   - `mach_port.c:101` includes `opt_compat_mach.h`, which no options file defines, so a kernel
     build has no such header (`kmod.mk:409-418` links it from `KERNBUILDDIR`).
   - Remove that header from the module's `SRCS` and from `mach_port.c`. `COMPAT_MACH` already
     comes from `opt_global.h`.
   - Keep `-O0` and the module's other flags.
2. `amd64: add RMXOS-KASAN, RMXOS-KMSAN and RMXOS-KCSAN`. Write each in `GENERIC-KASAN`'s form:
   `include RMXOS-RELEASE`, `ident <name>`, and one `options` line.
   - Add `RMXOS-KUBSAN` (`options KUBSAN`) the same way, but only if it builds. If it does not,
     leave it out and report its first error. Do not repair FreeBSD's KUBSAN here.

**Build** `RMXOS-RELEASE` and each new configuration from the branch, each with its modules,
`mach.ko` among them, and debug files. For each built configuration, show from its build log that
mach's compile lines:
- include the kernel's `opt_global.h`, which defines INVARIANTS and WITNESS, not an empty one;
- carry the sanitizer's flags from `sys/conf/kern.mk:259-331`, for the sanitizer configurations.

For each built configuration, also check that every undefined symbol in its `mach.ko` resolves in
its kernel. Name how each one resolves: as a global symbol, or as a local one through leak-locals
(id-045). The kernel's symbols can differ between configurations.

**List** every place in `sys/compat/mach` and `sys/sys/mach` where the compiled code changes now that
the module gets the kernel's option headers instead of empty ones. That means INVARIANTS changing
behaviour instead of only checking it, and code under options from `opt_capsicum.h` or
`opt_ntp.h`. Two are known:
- `ipc_kmsg_alloc` adds `M_ZERO` only under INVARIANTS (`ipc_kmsg.c:386-390`);
- `kern_fdfree` writes `fde_seqc` only under `CAPABILITIES` (`ipc_entry.c:933-942`), so the
  standalone build skips the kernel's protocol (`kern_descrip.c:323-328`).

Give file:line and one sentence for each; make no fixes.

**Stage** one image per built configuration with
`/Users/me/wip-mach/rmx-implementer/scripts/bhyve/rmx-stage-image` (dd78a31). Each image is a copy
of the op-364 image `8f546a930859ce537d1cb8f462dbf391171fd02c2bd004d2d10b1c8b498c7140` and differs
from it only in the kernel:
- the configuration's kernel and all its modules, installed as `/boot/<config>/` the way op-364
  installed `/boot/RMXOS-RELEASE/`;
- its debug files under `/usr/lib/debug/boot/<config>/`;
- that kernel as the image's boot kernel.
Userland and libmach stay unchanged. Each image has a BOM, a host-before and host-after inventory,
and a final hash, as in op-388.

**Evidence:**
- the branch head and both commits;
- each configuration's build log, quoting one mach compile line;
- the symbol check for each configuration;
- the INVARIANTS list;
- each image with its BOM, inventories and hash.

## Inputs

- The op-364 build record: `/Users/me/wip-mach/rmx-implementer/build/op364-20260928T001637Z/`.
  It shows how the kernel, `mach.ko` and the image were built. Its
  `logs/build-mach-module.log` shows today's standalone build with an empty `opt_global.h`
  (line 14), and `evidence/check-module-symbols.exs` is its symbol check.
- The staging form: `docs/op388-pid1-premise.md`.
- The upstream forms in the tree: `sys/amd64/conf/GENERIC-KASAN`, `GENERIC-KMSAN` and
  `GENERIC-KCSAN`; `sys/conf/kmod.mk:129-134,429-432`; `sys/conf/config.mk:86`.

## Limits

- Change only `sys/modules/Makefile`, `sys/amd64/conf/`, and the option-header fix in commit 1.
  Leave the rest of `sys/compat/mach`, libmach and the tests as they are. The code stays alpha2's;
  only its build changes.
- Leave the `mach-fixes-1` branch and op-395's work alone.
- Leave op-388's premise image and everything under `/Users/me/wip-mach/stage/images/`
  untouched. Put the new images in new files there.
- If a configuration other than `RMXOS-KUBSAN` fails to build, stop and report. Configurations
  that are already finished stand.

Re-read OPS.md first: defaults and the REPORT block.
