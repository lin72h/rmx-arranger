# id-018 — BSD.include.dist missing 8 source include/ subdirs (clean-buildworld includes-install remainder)

- id: id-018
- state: **RETIRED — op-115 fix VALIDATED by the op-111 re-retry (2026-06-23).** The clean build
  from `12330136` cleared the **entire `include/` subtree first-hand** — all 9 mtree dirs created in
  `tmp/usr/include/` (gen, i386, libkern, mach, os, pthread, servers + op-113's apple/uuid,
  apple/sys), **0 `_INCSINS` Error 71** — the dir-not-found class is gone. The build progressed past
  includes into `lib/`. arm and libkern/i386 correctly omitted (Arranger-verified at fix time).
  **The next wall is a DIFFERENT class** — `lib/libdispatch` install EX_USAGE (Error 64), a lib
  Makefile INCS/install defect, NOT a missing mtree dir → **id-019** (not folded). Mechanism was
  exactly op-113's. Both prior includes walls (id-014 apple, id-018 the 9) now hold under the gate.
- raised: 2026-06-23 — surfaced by the **op-111 retry** (Gatekeeper, build from e317099). op-113's
  apple/uuid fix VALIDATED (cross-tools + `include/apple` cleared, 0 `_INCSINS` errors), but the
  stage-4.1 includes phase then walled at `include/gen` (`_INCSINS` Error code 71) — the same class
  as id-014, a different dir. Census found **8 source include/ subdirs absent from the mtree** that
  will each fail installincludes the same way.
- roadmap parent: [roadmap.md](../roadmap.md) — **Gate F** (clean build → stage → boot). Build-path
  substantiation; no product semantics, but see the mach/ note below.
- relations: **id-014/op-113** (the *first* dir of this same defect class — apple/uuid; this is the
  remainder, deliberately NOT folded in per the don't-fold rule); **id-012/op-111** (the clean-build
  arc this unblocks); **id-015** (distributable-image legs downstream of a clean world+kernel).

## The defect (first-hand, Arranger-verified 2026-06-23 @ alpha e317099)

FreeBSD's stage-4.1 includes phase builds the `${WORLDTMP}/usr/include` skeleton from
`etc/mtree/BSD.include.dist` *before* each `include/<dir>/Makefile` runs `installincludes`. A dir
whose `INCSDIR=${INCLUDEDIR}/<dir>` has **no matching mtree entry** fails `_INCSINS` (Error 71).

Census of `include/*/` dirs that install headers vs. their mtree presence:
- **present** (ok): apple (op-113), arpa, gssapi, protocols, rpc, rpcsvc, ssp, xlocale.
- **MISSING** (8): arm, gen, i386, libkern, mach, os, pthread, servers. `gen/` is the one the build
  hit first; the others are same-class — **but only the dirs the amd64 build actually traverses
  will wall** (see the arch-gate correction below).

### Arch-gate correction (Arranger first-hand, 2026-06-23) — required set is 9, not 11

`include/Makefile:7-15` gates the arch dirs: base `SUBDIR` is all-arch, **`i386` is added only on
amd64**, **`arm` only on aarch64**. The current build is **amd64** (KERNCONF MACHDEBUGDEBUG). So:
- **arm** is **NOT traversed on amd64** → it will not wall → **excluded** from this fix. (The
  Gatekeeper's "arm would serial-fail next" was a wrong presumption for amd64.) `include/arm` is
  base-FreeBSD aarch64 lib32-compat (commits `d5d97bed`/`63c9b018`), **not** a NextBSD/Mach addition;
  it becomes relevant only at the **future arm64 bringup** — deferred there, cataloged below.
- **i386** **IS traversed on amd64** — it's base-FreeBSD `-m32`/lib32 **compat** headers (commits
  `a09ea2bbc305`/`cca19272611d`), NOT "32-bit i386 as a target." Omitting it breaks the amd64 build;
  dropping 32-bit compat entirely would be `WITHOUT_LIB32`, a separate decision. **Included.**
- **`libkern/i386`** is **orphaned** — `libkern/Makefile` has no `SUBDIR`, so it is never traversed
  → **excluded**. (`mach/Makefile` DOES have `SUBDIR= device i386`, unconditional → both included.)

**Required mtree entries for the amd64 build = 9** (verified first-hand; a top-level-only fix would
wall again at `mach/device`):

| top-level (7) | INCSDIR | nested that ALSO install headers (traversed) |
|---|---|---|
| gen | `${INCLUDEDIR}/gen` (the wall) | — |
| i386 | `${INCLUDEDIR}/i386` (amd64 lib32 compat) | — |
| libkern | `${INCLUDEDIR}/libkern` | — (`libkern/i386` orphan, excluded) |
| **mach** | `${INCLUDEDIR}/mach` | `mach/device`, `mach/i386` |
| os | `${INCLUDEDIR}/os` | — |
| pthread | `${INCLUDEDIR}/pthread` | — |
| servers | `${INCLUDEDIR}/servers` | — |

→ **9 mtree directory entries** (7 top-level + `mach/device`, `mach/i386`), nested with `..` pops
like op-113's apple block, inheriting `/set type=dir mode=0755 tags=package=clibs-dev`.

**Deferred to arm64 bringup:** add `arm` (and any aarch64-only nested dirs) to the mtree when the
first aarch64 build is attempted — out of scope here (amd64-only per Coordinator: x86_64 now, arm64
future).

### Provenance (Arranger first-hand, 2026-06-23) — 6 of 7 are overlay, same class as id-014

This is **mostly the id-014/apple defect again** (overlay added include dirs without their mtree
entries), not a base-FreeBSD-mtree gap:
- **base FreeBSD 15/stable (inherited):** `i386` (`a09ea2bbc305 amd64: add an i386 include
  directory`, lib32 compat) and the deferred `arm` (`d5d97bed4ab6 arm64 lib32…`).
- **NextBSD/Darwin overlay (donor'd, NOT base):** `gen` (`0c1056b` libosxsupport — `assumes.h` is
  Apple's `__OSX_ASSUMES_H__`), `libkern` (`439f5e89` Mach+dispatch bringup — Apple `OSAtomic`/
  `OSByteOrder`), `mach` (`b069a16f` NextBSD Mach userland substrate — the Mach-IPC headers, overlay
  core), `os` (`439f5e89` — Apple `os/assumes.h`), `pthread` (`9fbf3e8` GCDX workqueue bridge),
  `servers` (`afe8b0bc` libxpc — Mach servers headers).
- **`i386` caveat:** being *base*, its dir may already be created by `include/Makefile`'s arch /
  machine-link machinery (lines 356-394) rather than needing a static mtree entry — so it may not
  wall like the overlay dirs. The mtree entry is harmless either way (redundant at worst); keep it,
  but if the re-retry behaves oddly around i386 this is why. The 6 overlay dirs definitely need it.

## Why mach/ makes this more than build plumbing

`include/mach/Makefile` installs the **rmxOS Mach-IPC headers** (`boolean.h` + many; `INCSDIR=
${INCLUDEDIR}/mach`, `SUBDIR= device i386`). So this isn't only an early-includes nitpick — without
it the Darwin-overlay world compile would fail to find the Mach headers once reached. The remainder
blocks the overlay core, not just the build's opening phase.

## Process lessons confirmed (from the op-111 retry)

- **Targeted test ≠ gate** (re-confirmed): op-113's verification (a targeted `-j56 installincludes`
  of `include/apple`) passed apple but could not surface gen//mach//etc. — only the full buildworld
  includes phase does. The Implementer's targeted installincludes is not the gate; the Gatekeeper's
  clean buildworld is.
- **Exit-code trap held**: the retry's `rc=$? → retry-make.rc → exit $rc` correctly propagated make
  rc=2 (no repeat of the first attempt's masked exit-0).

## Truly-green criterion

- a clean buildworld from a fresh checkout clears the **entire** stage-4.1 includes phase (no
  `_INCSINS` Error 71 for any of the 11 dirs) and proceeds into world compile — proven by the
  Gatekeeper's op-111 clean-build retry, not by a targeted installincludes.
- NOTE: this clears the includes wall; further walls may lie behind it (the build has never
  completed). id-018 retires when includes fully clears; the next wall (if any) is its own catalog.
