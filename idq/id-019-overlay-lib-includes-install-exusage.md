# id-019 — rmxOS overlay lib includes-install fails install EX_USAGE (clean-buildworld lib/ wall)

- id: id-019
- state: **RETIRED — op-118 (`172ed6bcbbc0`) VALIDATED by the op-111 re-re-retry clean buildworld
  (2026-06-23).** The Gatekeeper's clean build from `172ed6bcbbc0` cleared the **entire lib/ includes
  phase end-to-end first-hand** — zero `_INCSINS`/install-EX_USAGE across lib/libdispatch, lib/libxpc,
  and the overlay libs; op-118's `dispatch`/`private`/`xpc` mtree additions held — and the build then
  **crossed the includes→compile phase boundary** (real `cc` compile invocations on `.c` files, not
  just an installincludes pass = the defined gate). make rc=2 propagated first-hand from the *later*
  compile wall (exit-trap held; not a masked exit-0). **This is the first time any rmxOS build has ever
  reached the compile phase** — every prior wall (id-014/018/019) was an includes-install defect.
  **The next wall is a NEW class (compile) → id-020** (not folded). Includes-install arc COMPLETE.
  - **Root cause (Implementer `make -n` first-hand, Arranger-confirmed):** the EX_USAGE was install(1)
    targeting a **missing `/usr/include/dispatch` destination dir** (lib INCS install needs the dest dir
    pre-created in the WORLDTMP skeleton, like the include/ dirs in id-018). The `private.h` double-list
    (the id-019 lead) was a *real* secondary defect (real `private/private.h` shadowed by the
    `dispatch/private.h` 32 B stub) — fixed too, but not the primary EX_USAGE trigger.
  - **Fix (Arranger-verified at `172ed6bcbbc0`):** (1) mtree `BSD.include.dist` += `dispatch`, `private`,
    `xpc` (alphabetical, correct top-level nesting, inherit the `/set clibs-dev` tag); (2) libdispatch
    Makefile splits the real backing headers into `DISPATCHPRIVATEINCS` (`INCSGROUPS= INCS
    DISPATCHPRIVATEINCS`, `DISPATCHPRIVATEINCSDIR=${INCLUDEDIR}/private`) installing
    `${.CURDIR}/private/*.h` to `/usr/include/private/`; (3) removed the duplicate `private.h` from the
    dispatch `INCS+=` block so the stub no longer shadows the real header.
  - **Two-destination layout (verified correct + complete, first-hand):** `dispatch/*_private.h` are
    32-39 B **forwarding stubs** (`#include "../private/X"`); the real headers live in `private/`. So
    stubs install to `/usr/include/dispatch/`, backings to `/usr/include/private/`, and the `../private/`
    relative include resolves. **All 7 stubs** (data_private, io_private, layout_private, mach_private,
    private, queue_private, source_private) have a matching `DISPATCHPRIVATEINCS` backing → **no stub
    forwards to a missing header** (a gap installincludes can't catch — it copies, doesn't compile —
    so this was checked by hand). `voucher_*_private.h`/`benchmark.h` (no stub) install their real
    content directly to `dispatch/` via `.PATH` fallthrough; nothing forwards to them → fine.
  - **libxpc** covered by the new `xpc` mtree dir (same subdir-install class). **Audit (Implementer):**
    libnotify/libasl/liblaunch/libjansson = root-header installs (no subdir mtree needed);
    libmach/libosxsupport/libosxsupport_rmx install no headers.
- raised: 2026-06-23 — surfaced by the **op-111 re-retry** (build from `12330136`). op-115/id-018
  VALIDATED first-hand (entire `include/` subtree cleared, all 9 mtree dirs created, 0 `_INCSINS`
  Error 71) — the build then progressed into `lib/` and walled at **`lib/libdispatch` installincludes
  with install EX_USAGE (Error code 64)** — a malformed install invocation, NOT dir-not-found.
- roadmap parent: [roadmap.md](../roadmap.md) — **Gate F** (clean build → stage → boot). Build-path
  substantiation; the lib's headers are the libdispatch/libxpc public+private API surface.
- relations: **id-014/op-113** + **id-018/op-115** (the two *prior* includes walls — but a DIFFERENT
  class: those were missing `etc/mtree/BSD.include.dist` dir skeletons; this is a `lib/*/Makefile`
  INCS/install-invocation defect — deliberately NOT folded, don't-fold rule); **id-012/op-111** (the
  clean-build arc this unblocks); **id-006** (libdispatch — its *runtime* conformance is long-since
  green; this is purely a header-install build defect, no runtime/semantic impact).

## The wall (first-hand, Arranger-verified 2026-06-23 @ alpha 12330136)

`lib/libdispatch` installincludes exits **EX_USAGE (64)** — `install(1)` invoked with arguments it
can't parse (prints its usage banner, exits 64). The exact command is `@`-suppressed in
`bsd.incs.mk`; the Implementer reproduces it via `cd lib/libdispatch && make -n installincludes`.

**Concrete lead (Arranger-verified, likely the trigger):** `lib/libdispatch/Makefile` lists
**`private.h` TWICE** in INCS — line 79 (public block) and line 91 (`INCS+=` private block). The
Makefile has `.PATH: ${.CURDIR}/dispatch` and `.PATH: ${.CURDIR}/private`, and `private.h` exists
in **both**: `dispatch/private.h` (32 B, a stub/redirect) and `private/private.h` (6295 B, the real
private header). `bsd.incs.mk` generates a per-header install target keyed on the **basename**
(`_INCSINS_${header:T}` → `_INCSINS_private.h`) — so the two `private.h` entries collide on one
target, both targeting `${INCLUDEDIR}/dispatch/private.h`. A duplicate/colliding install target is
the prime suspect for the EX_USAGE; confirm with `make -n`.

## Scope (comprehensive — break the serial-wall pattern)

The arc so far has been serial includes walls: id-014 (apple dir) → id-018 (9 dirs) → now libdispatch.
Per the Gatekeeper's recommendation, do **one comprehensive overlay-includes audit** rather than
fixing libdispatch alone and walling at the next lib:

**In:**
1. **Fix `lib/libdispatch`** — resolve the `private.h` double-listing / dual-`.PATH` collision so
   both the public (`dispatch/private.h`) and the real private header install to their correct
   destinations without an EX_USAGE / duplicate-target collision. Confirm root cause via
   `make -n installincludes` first.
2. **Audit + proactively fix every overlay `lib/lib*` INCSDIR+INCS setup** — at minimum:
   - **libxpc** (`INCSDIR=${INCLUDEDIR}/xpc`, 2 INCS blocks — same multi-header pattern as
     libdispatch → Arranger-flagged likely-same-class; the build stopped before reaching it).
   - libnotify, libasl (single-header INCS → likely fine; confirm).
   - libmach, libosxsupport (no `^INCS` lines found → confirm they install no headers, or find the
     alternate mechanism).
3. Land it as **one commit** (op-113/op-115 style) so the next clean-build wall is a *new* class,
   not another lib in this same class.

**Out:** `etc/mtree` dir-skeleton work (that's id-014/id-018, DONE); product runtime/semantic
changes (these are header-install build fixes, zero runtime impact); whatever wall lies behind the
lib/ includes phase (its own catalog).

## Truly-green criterion

- a clean buildworld from the new HEAD clears the **entire `lib/` includes phase** (no install
  EX_USAGE / Error 64 for libdispatch, libxpc, or any overlay lib) and proceeds into the lib
  *compile* phase — proven by the Gatekeeper's op-111 re-re-retry, NOT by a targeted installincludes.
- NOTE: clears this class only; further walls (lib compile, link, kernel) may lie behind it — each
  its own catalog. id-019 retires when the lib/ includes phase clears end-to-end.
