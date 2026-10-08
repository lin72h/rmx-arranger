---
id: op-562
state: draft
agent: implementer
repo: rmx-implementer
idq: id-047
authority: kernel, mach.ko and test builds (no world); overlays on op552-overlay-base-r3; 4 self-check boots; no push
expected: 4h
updated: 2026-10-08T04:52Z
---
# op-562 — Implementer: CI build stage (id-047): candidate commit to RMXOS-RELEASE and KASAN overlays, mach.ko built with its kernel

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 4 hours.**

CI (id-047, now.md step 2): every candidate built, booted and run
through the Mach suite, with the kernel's own assertions compiled into
`mach.ko` and a KASAN profile. Two facts: `mach.ko` has so far been
built standalone with empty option headers, so its INVARIANTS
assertions are compiled out (id-047); and your op-396 branch
`testing-1` (`42d1fdbf` builds `mach.ko` with the kernel through
`sys/modules/Makefile`; `7ccf16fa` adds `RMXOS-KASAN`, `-KMSAN`,
`-KCSAN`, `-KUBSAN`; on origin) is not in `mach-fixes-6`. This op builds
the build half of CI on the overlay route; gatekeeper1 will run it.

1. **Bring `testing-1` onto `mach-fixes-6`** (local head `d8437d85`):
   merge or cherry-pick `42d1fdbf` and `7ccf16fa`, resolving against
   step 4 (`mach_port.c` and `sys/modules/mach/Makefile` changed since).
   Nothing else.
2. **One CI build command** (`tools/ci/build`, documented in
   `docs/ci-build.md`): given a `wip-rmxos` commit and a profile
   (`RMXOS-RELEASE` or `RMXOS-KASAN`), build that kernel with
   `mach.ko` through `sys/modules`, the changed libraries and all
   tests incrementally (no world), and produce an overlay for
   `op552-overlay-base-r3.raw` with its manifest. Kernel and `mach.ko`
   replacement through the overlay was not tested in op-552; make it
   work (the loader must boot the overlay's kernel after the install
   reboot; the serial log must show the kernel ident and the overlay
   manifest hash).
3. **Self-check** on overlays from `mach-fixes-6` after item 1:
   `RMXOS-RELEASE` with the kernel-built `mach.ko`, all cases once;
   `RMXOS-KASAN`, all cases once. These are the first runs with
   `mach.ko`'s assertions enabled: an assertion or KASAN report is a
   finding, not a harness fault — keep the serial log, record the
   report and its file:line, and do not fix it in this op.

Evidence: commits; `docs/ci-build.md`; both overlays' hashes and
manifests; each boot's result (ATF counts, any assertion or KASAN
report with its serial lines); the `selfcheck:` line.

## Limits

- Build files, kernel configs, the CI script and overlays only; no
  Mach, library or test source change (findings are reported). No
  push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
