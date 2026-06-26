# id-020 — clean-buildworld COMPILE phase fails: `__int8_t…__intmax_t` "unknown type name" under `-ansi`

- id: id-020
- state: **RETIRED 2026-06-24 (scoped defect resolved + validated first-hand).** op-120 DONE (root
  cause PINNED) → op-125 DONE (fix applied, commit `efc8cb1f7c0b`) → op-111 r4 (Gatekeeper clean build
  from `efc8cb1f`) **VALIDATED the fix first-hand: zero `__int8_t`/`_stdint.h:34` occurrences** — the
  `_types.h`-before-`_stdint.h` insertion worked exactly as designed. id-020's specific defect (the
  `__int8_t` "unknown type name" under `-ansi`) is closed.
  - **test-includes does NOT yet fully clear thrworkq.h** — op-111 r4 surfaced a *second, distinct*
    self-containedness defect at **thrworkq.h:93** (`__packed` redefinition; the header uses `__packed`
    from `cdefs.h:153` without `#include <sys/cdefs.h>`). It was masked by the `__int8_t` error in all
    prior runs. Per the **don't-fold rule** (different line, different missing include) this is a new
    item → **[id-022](id-022-thrworkq-self-containment-cdefs.md)**, NOT a re-open of id-020. The Gatekeeper
    validated the rc=2 first-hand (r4retry-make.rc, log tailed before reporting — op-111 lesson honored).
  - op-125 verified first-hand: exactly one insertion (`#include <sys/_types.h>` before `<sys/_stdint.h>`
    at thrworkq.h:10, after the include guard); base `_types.h`/`_stdint.h` + `-ansi` untouched — matches
    the op-120 spec. op-120 (Gatekeeper, free) cleanly pinned the defect; my correction held and BOTH
    Gatekeeper hypotheses were disproven first-hand.
  - **NOT a compile-class "world COMPILE" wall after all — it is a `test-includes` self-containment
    failure** (an earlier stage than world compile). The base `tools/build/test-includes` tool compiles
    each installed header *standalone under `-ansi`* (Makefile:27, C89-cleanliness check, base FreeBSD,
    INTENTIONAL — verified, NOT overlay-injected). It caught that the **overlay header
    `sys/sys/thrworkq.h`** (`Copyright (c) 2026` + SPDX → overlay-authored, NOT base) is **not
    self-contained**: `thrworkq.h:10` does `#include <sys/_stdint.h>` with no `<sys/_types.h>` before it,
    so `_stdint.h:34 typedef __int8_t int8_t;` sees `__int8_t` undefined. (`kern_thrworkq.c` preprocesses
    clean because it reaches `_stdint.h` via the proper `<sys/types.h>` chain — only the standalone path
    breaks.) Base `_types.h`/`_stdint.h` confirmed unmodified, `__int8_t` unconditional — my correction
    was right; the defect is the overlay header's missing prerequisite, NOT `-ansi`, NOT base `_types.h`.
  - **op-125 (Implementer) fix:** add `#include <sys/_types.h>` before `<sys/_stdint.h>` at
    `sys/sys/thrworkq.h:10` (one line; makes the overlay header self-contained). DO NOT edit
    `sys/_types.h`; DO NOT remove `-ansi` (removing it masks the real defect — the tool is working as
    designed). Validated by the next op-111 re-re-re-retry clearing the test-includes stage.
  - Gatekeeper self-corrected its op-111 imprecision: the netlink/netsmb/net80211/netinet `.o` markers
    were concurrent `-j56` compiles, not failures; the sole failing TU is the generated `sys_thrworkq.c`.
- raised: 2026-06-23 — surfaced by the **op-111 re-re-retry** (Gatekeeper clean build from
  `172ed6bcbbc0`). id-019 VALIDATED (lib/ includes cleared), the build **crossed into the compile
  phase for the first time ever**, and walled at a compile error.
- roadmap parent: [roadmap.md](../roadmap.md) — **li-006** (clean build → stage → boot). Build-path
  substantiation; the first non-includes wall.
- relations: **id-014/op-113 + id-018/op-115 + id-019/op-118** (the three *prior* includes-install
  walls — all RETIRED; this is a DIFFERENT class: world COMPILE, not header-install — not folded,
  don't-fold rule); **id-012/op-111** (the clean-build arc this unblocks); **id-017** (LLVM/clang
  bootstrap — the toolchain doing this compile; if the `-ansi` is toolchain-version-sensitive it
  intersects here).

## The wall (Gatekeeper first-hand, op-111 re-re-retry, 2026-06-23)

Clean buildworld @ `172ed6bcbbc0`: stage-4.1 includes COMPLETED → entered the compile phase →
`cc` failed on **`sys/sys/_stdint.h:34…`** with `__int8_t / __int16_t / __int32_t / __int64_t /
__uint8_t / … / __intmax_t / __uintptr_t` reported as **"unknown type name."** The failing compile
lines carry **`-ansi`** (strict ANSI / `__STRICT_ANSI__`). Components mid-compile at failure:
netlink, netsmb, net80211, netinet (`netinet_tcp_accounting`), `sys_thrworkq`. make rc=2 (first-hand).

## Arranger correction — the Gatekeeper's proposed root cause is WRONG (don't fix `_types.h`)

The Gatekeeper hypothesized "a `_types.h`/`_stdint.h` visibility-macro regression in the overlay —
`-ansi` hides the `__intN_t` typedefs." **Verified first-hand, this is not the mechanism:**

- **`__int8_t` is defined UNCONDITIONALLY** at `sys/sys/_types.h:41` (`typedef signed char __int8_t;`
  — and the rest at :42-46), with **no `#if`/visibility guard** that `-ansi`/`__STRICT_ANSI__` could
  alter. There is nothing for `-ansi` to "hide."
- **The headers are unmodified base FreeBSD** (git log on `sys/sys/_stdint.h`, `sys/sys/_types.h`,
  `sys/x86/include/_types.h` shows only base cleanup commits — `$FreeBSD$`/SPDX/SCCS removal — no
  NextBSD/overlay authorship). So the typedef chain is not corrupted by the overlay.
- Most failing components (**netlink, net80211, netinet**) are **base FreeBSD** sources too. Base
  sources + base headers failing on `__int8_t` ⇒ the defect is in the **build invocation / include
  ordering**, not in the typedefs.

**So `_stdint.h:34` does `typedef __int8_t int8_t;` while `__int8_t` is not yet defined** — i.e.
`<sys/_stdint.h>` is being reached **before** `<sys/_types.h>` (→ `<machine/_types.h>` →
`<x86/_types.h>`) defines `__int8_t`, OR these compiles are getting `-ansi` where base FreeBSD would
not, breaking the normal header chain. **The lead is the `-ansi` ORIGIN + include order, not a header
patch.**

## op-120 — diagnostic capture (Gatekeeper, free; owns the failing tree)

Discovery-only, no source edits. Pin the root cause so the Implementer fix is precise:
1. **Capture the exact failing `cc` command** (full argv) for one failing TU (e.g. the netlink or
   `sys_thrworkq` compile) — confirm `-ansi` and the full `-I` include path + `-D` macros.
2. **Find where `-ansi` comes from** — which Makefile / `bsd.*.mk` / `CFLAGS`/`CSTD` sets it. Is it
   **overlay-introduced** (grep the overlay for `-ansi`/`CSTD=ansi`) or base? base world does NOT
   normally compile these with `-ansi`, so an overlay CFLAGS injection is the prime suspect.
3. **Preprocess the failing TU** (`cc -E` with the same flags) and show **where the `__int8_t`
   chain breaks** — is `<sys/_types.h>` included at all? Is it skipped/empty under `-ansi`? Is
   `<sys/_stdint.h>` pulled in first via some overlay header?
4. Report: overlay-introduced `-ansi` vs base; the precise file/line that injects it; the broken
   include edge. → hand to Implementer for a targeted fix (drop/scope the stray `-ansi`, or fix the
   include order — NOT edit `sys/_types.h`).

## Truly-green criterion

- a clean buildworld from the fix HEAD clears the **world compile phase** past `_stdint.h` (no
  `__intN_t` "unknown type name") and proceeds — proven by the Gatekeeper's next op-111 re-retry,
  NOT by a targeted single-TU compile.
- NOTE: clears this wall only; further walls (more compile, link, then buildkernel) may lie behind it
  — each its own catalog. id-020 retires when the world compile phase clears end-to-end (or reaches
  buildkernel).
