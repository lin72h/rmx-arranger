---
id: op-395
state: draft
agent: implementer
repo: rmx-implementer
idq: id-046
gate: both
authority: build: kernel RMXOS-RELEASE, mach.ko and the Mach tests from the fix branch; extend rmx-stage-image with a schema for these test images and stage two test images with it; no guest runs; no push
updated: 2026-09-29T04:03Z
---
# op-395 — Implementer: Mach fix batch 1 — local fixes, each with an in-tree regression test

## Outcome

Fix the local Mach defects below on a new branch `mach-fixes-1` off `origin/alpha2`
(`2884304b67fc454ee60187ce4731fca01cbefe6a`) in `wip-rmxos`. Each fix is one commit, and each
comes with its own regression test. Design-level defects are out of scope: an Advisor proposal
(op-394) decides them first.

**Tests.** Add ATF tests under `tests/sys/mach/`, hooked into `tests/sys/Makefile`, that run in a
guest under Kyua. Write each test before its fix, so it exercises the defect on alpha2. For every
test, record its expected result on alpha2 (FAIL, or PANIC for tests that crash the kernel) and
after the fix (PASS). You do not run guests: gatekeeper1's CI runs the suite on both images below
and proves each test fails first and passes after.

**The fixes, in this order** (IDs are the reviews'; detail is in the documents under Inputs):
1. op-389 #3 + op-392 F3: Mach fileops lack poll, ioctl, chmod, chown and the kevent read/write
   filters. Give every fileop a defined error result.
2. op-392 F6: remove the `thread_unlock` after `mi_switch` in `_swtch_pri`.
3. op-389 #5: pass the saved kmsg to the receive error path instead of rereading `ith_kmsg`.
4. op-393 N3: check the entry type before referencing its object in `ipc_mqueue_copyin`.
5. op-389 #13: initialize the port set's list, sx lock and knlist in `ipc_pset_alloc_name`.
6. op-393 N4: remove `ipc_object_translate`'s reliance on uninitialized caller variables.
7. op-389 #12: drop the wrapper's file reference after a successful `kern_finstall`, and remove the
   double destroy on failure.
8. op-392 F7: reject files without `DFLAG_PASSABLE` in Mach transfer, as `unp_internalize` does.
9. op-392 F8: check `p_fd` for NULL in `proc_pidbsdinfo`.
10. op-389 #9: carry the source descriptor's Capsicum rights through Mach transfer.
11. op-389 #10: convert Mach millisecond timeouts to the right sleep units.
12. op-393 N8: `clock_sleep_trap`'s duration, clock and result codes.
13. op-393 N1: return a 1/1 timebase, and make libmach's `mach_absolute_time` monotonic
    (`CLOCK_UPTIME`). This changes launchd's respawn throttle to its intended 10 s.

**Build and stage** (authority below): the kernel `RMXOS-RELEASE`, `mach.ko` built the same way
as op-364, libmach and the tests. Stage two images with
`/Users/me/wip-mach/rmx-implementer/scripts/bhyve/rmx-stage-image`, building on `9d718966`
(op-396's kernel-profile schema, under review in op-397). Its `rmx-stage-image/v1` schema
accepts only alpha2's PID-1 premise. Add a schema for these test images the way `9d718966`
added `rmx-stage-kernel/v1`:
- installs go only to the paths these images need: the kernel, `mach.ko`, libmach and the
  tests;
- the behaviour of both existing schemas stays unchanged;
- the self-test covers the new schema.

Each image is a copy of the op-364 image
`8f546a930859ce537d1cb8f462dbf391171fd02c2bd004d2d10b1c8b498c7140`:
- **base + tests:** alpha2 unchanged plus the tests only;
- **fixed + tests:** the fixed kernel, `mach.ko` and libmach, plus the tests.
Each has a BOM, a host-before/host-after inventory and a final hash, as in op-388.

Stop and report after any fix you cannot complete cleanly; finished commits stand. Evidence: the
branch head and one commit per fix; the test list with expected results; the build logs; both
images with BOMs, inventories and hashes.

## Inputs

- The reviews: `/Users/me/wip-mach/rmx-advisor2/op-389-mach-freebsd12-assumptions-alpha2.md`,
  `/Users/me/wip-mach/rmx-advisor1/op-392-mach-freebsd15-assumptions-findings.md`,
  `/Users/me/wip-mach/rmx-advisor1/op-393-mach-remaining-areas-findings.md`.
- The op-364 build record `/Users/me/wip-mach/rmx-implementer/build/op364-20260928T001637Z/`
  (how `mach.ko` and the image were built) and `docs/op388-pid1-premise.md` (the staging form).

## Limits

- Do not change the module's build configuration here. Building `mach.ko` with its kernel is
  op-396 (id-047).
- The standalone build gives `mach.ko` empty option headers, so `CAPABILITIES` and INVARIANTS are
  undefined in it even though the kernel has both. Code under `#ifdef CAPABILITIES` or
  `#ifdef INVARIANTS` compiles to nothing here; for example, `kern_fdfree` (`ipc_entry.c:933-942`)
  skips the kernel's `fde_seqc` writes. Fix 10, and every other fix, must not rely on such code
  and must work in this build.
- Leave op-388's premise image and everything under `/Users/me/wip-mach/stage/images/` untouched;
  put the two new images in new files there.

Re-read OPS.md first: defaults and the REPORT block.
