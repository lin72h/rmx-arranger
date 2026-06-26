# id-014 — rmxOS overlay `include/apple/uuid` includes-install order breakage (li-006 clean-build blocker)

- id: id-014
- state: **RETIRED — op-113 fix VALIDATED by the op-111 retry (2026-06-23).** The clean build from
  `e317099` cleared cross-tools (stages 1.1→3.1, incl the LLVM bootstrap) AND `include/apple` with
  **0 `_INCSINS` errors** — e317099's mtree fix held exactly as intended. The apple/uuid dir this
  item names is fixed and proven by the gate (full buildworld includes phase, not a targeted test).
  Root cause was a systematic missing include-dir skeleton (NOT a -j56 race): `bsd.incs.mk` installs
  into INCSDIR but doesn't create it; fix added `apple`, `apple/uuid`, `apple/sys`,
  `apple/sys/_pthread`, `apple/sys/_types` to `etc/mtree/BSD.include.dist` (Arranger-verified).
  **The build then walled at the NEXT dir (`include/gen`) — same defect class, different dirs.**
  That remainder (8 missing dirs) is **id-018**, deliberately NOT folded here (don't-fold rule):
  id-014 = the apple/uuid dir (closed); id-018 = arm/gen/i386/libkern/mach/os/pthread/servers.
- raised: 2026-06-23 — discovered by op-111 (id-012 Tier 0 clean-build de-risk); first-hand
  verified by the Arranger in product source at e101f9c (the two Makefiles below).
- roadmap parent: [roadmap.md](../roadmap.md) — **li-006** (reproducible build / stage / boot).
  A clean checkout currently does **not** build → directly blocks "boot is a button, not a ritual."
- relations: surfaced by **id-012/op-111** (the image/boot de-risk); blocks op-111 steps 2-4
  (memstick → boot → repro) on a *clean* e101f9c build.

## The breakage (first-hand, 2026-06-23, product repo `alpha` @ e101f9c)

Clean `buildworld` (`-j56`, `KERNCONF=MACHDEBUGDEBUG`, fresh obj dir) **fails at the includes
phase** — nothing downstream gets built (no kernel, no `mach.ko`, no Darwin overlay):

```
_INCSINS … install: No such file or directory  →  Error code 71  →  buildworld stops
```
(op-111 log `build/op111-release-image/buildworld-buildkernel.log:66955-67087`, on the
Gatekeeper host — not mirrored to the Arranger fs.)

**Verified structural cause** (the two Makefiles, read first-hand):

- `include/apple/uuid/Makefile`: `INCS=uuid.h`, `INCSDIR=${INCLUDEDIR}/apple/uuid`.
- `include/apple/Makefile`: `INCSDIR=${INCLUDEDIR}/apple` **and** `SUBDIR=uuid sys`.

So `apple/` is simultaneously (a) an INCS-installing dir and (b) the SUBDIR parent of `uuid`,
whose child installs `uuid.h` into a path nested under the parent's own INCSDIR. At `-j56` the
`uuid` recursion can run its install before the `apple/` dir tree is created → target dir absent
→ Error 71. `include/apple/uuid` came in with the broad import (`8c6a1c15b394`); the prior
*successful* build simply never installed it into its tmp tree either, so this is newly exercised
by the clean-from-e101f9c attempt.

**Bigger context (op-111 follow-up):** this is **the first failure of a clean-build path that has
never completed for rmxOS**. The overlay has only ever been built piecemeal (modules + targeted
userland); no full `buildworld`+`buildkernel` has ever succeeded. The includes phase is *very
early* — so fixing this Makefile likely **uncovers further breakage** further into world/kernel
compile. Treat op-113 as "advance the clean build past its first wall," not "the clean build now
works": the Gatekeeper retry (op-111) is what establishes how far the clean build actually gets.

**Open root-cause question (for the fix op to characterize):** race (parallel `-j56` ordering)
vs systematic missing dir-creation. op-111 did not retry-to-characterize, per the catalog-don't-
workaround mandate. Also check the sibling `apple/sys` SUBDIR for the same pattern.

## Scope (when fixed — op-113)

**In:** make a clean `buildworld` from e101f9c complete the includes phase at `-j56`. Minimal,
correct fix (Mach-outward; no `-j1` workaround, no hack) — ensure the `apple/uuid` (and
`apple/sys`) includes-install target-dir exists before the child install fires. Characterize
race-vs-systematic. Verify by re-running the includes phase (or a clean buildworld) green.

**Out:** memstick/boot (op-111 steps 2-4 — resume after fix); any unrelated overlay cleanup.

## Truly-green criterion

- a clean checkout at e101f9c runs `buildworld` (`-j56`) through the includes phase and onward —
  kernel + `mach.ko` + Darwin overlay produced — reproducibly, not on a one-off retry.

## Process note inherited from op-111

op-111 initially mis-reported "build exit 0 — clean" because its `make …; echo "BUILD EXIT
rc=$?"` wrapper let the `echo` propagate rc=0 and mask `make`'s real rc=2; caught within one step
by first-hand log + artifact check. Reinforces: never trust a background-task exit-code
notification — verify the build rc first-hand.
