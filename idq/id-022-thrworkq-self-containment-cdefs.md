# id-022 — overlay `sys/sys/thrworkq.h` uses `__packed` without `#include <sys/cdefs.h>` → test-includes standalone compile fails at thrworkq.h:93

- id: id-022
- state: **RETIRED (op-126 fix `15a6acc1398f`, validated by op-111 r5, 2026-06-24).** op-126 added
  `#include <sys/cdefs.h>` at thrworkq.h:10 (ahead of `_types`/`_stdint`); 5 `__packed` usages
  (lines 86/94/103/111/118) covered; full-header self-containedness audit clean in one pass.
  **Retirement evidence (Validator-GLM op-111 r5, Arranger-verified first-hand against
  `/Users/me/wip-mach/build/op111-release-image/`):** `r5-test-includes.rc` = `0`; log line 2 =
  `cc … -ansi … -Werror … -c sys_thrworkq.c -o sys_thrworkq.o` (clean standalone compile); log line 85 =
  `ar -crsD libtest-includes.a … sys_thrworkq.o …` (object present in archive); `grep -cE 'error:'` = 0,
  no thrworkq.h diagnostics. The real buildworld `test-includes` stage clears thrworkq.h end-to-end —
  id-022's exact truly-green criterion. Surfaced + pinned first-hand by **op-111 r4** once op-125's
  `__int8_t` fix (id-020) unmasked it.
- **next-wall note:** op-111 r5's full buildworld stopped at the test-includes stage (10-min Validator
  timeout) — id-022 retires regardless (its criterion is the thrworkq.h test-includes wall, which cleared).
  No world-compile/link/buildkernel wall has surfaced; per the don't-fold rule **no new id is opened** —
  if a later stage wall appears it gets its own catalog id at that point.
- raised: 2026-06-24 — by op-111 r4. Second self-containedness defect in the same overlay header,
  previously masked by the id-020 `__int8_t` error (the standalone compile died before reaching :93).
- roadmap parent: [roadmap.md](../roadmap.md) — **li-006** (clean build → stage → boot). Same
  build-path arc as id-020; the next `test-includes` wall.
- relations: **id-020** (the prior thrworkq.h self-containedness defect, RETIRED — `_types.h`-before-
  `_stdint.h`; this is a DISTINCT defect by the don't-fold rule: different line, different missing
  include); **id-012/op-111** (the clean-build arc this unblocks — op-111 re-runs after the fix).

## The wall (Gatekeeper op-111 r4, first-hand; Arranger-verified)

`test-includes` (base `tools/build/test-includes`, compiles each installed header **standalone under
`-ansi`**) now fails at **`thrworkq.h:93`**:
`error: redefinition of '__packed' with a different type: 'struct twq_reqthreads_args' vs 'struct twq_init_args'`.

**Root cause (verified first-hand):**
- `thrworkq.h` uses `__packed` on **5 structs** — lines **85 / 93 / 102 / 110 / 117** (`} __packed;` on
  `twq_init_args`, `twq_reqthreads_args`, `twq_thread_transfer_args`, `twq_should_narrow_args`,
  `twq_dispatch_config`).
- `__packed` is defined at **`sys/sys/cdefs.h:153`** — `#define __packed __attribute__((__packed__))`,
  **unconditional** (no `-ansi`/`__STRICT_ANSI__`/`__GNUC__` guard around that block, :145-160).
- `thrworkq.h` includes only `<sys/_types.h>` + `<sys/_stdint.h>` (lines 10-11) and **does NOT include
  `<sys/cdefs.h>`**; `_types.h` doesn't pull it in either. So standalone, `__packed` is an undefined
  identifier → `} __packed;` parses as a variable declarator → the 5 trailing `__packed` collide as
  redefinitions. (`cc -E` confirmed `__packed` appears literally, unexpanded.)
- The full-tree compile (`kern_thrworkq.c`) preprocesses clean because it reaches `cdefs.h` via the
  normal `<sys/types.h>` chain — only the standalone test-includes path breaks, same shape as id-020.

## op-126 — fix + one-pass self-containedness audit (Implementer)

Single Implementer op (30/100) — do the **whole header in one pass**, not serial one-liners, to stop
the per-retry churn the Gatekeeper flagged:
1. **Add `#include <sys/cdefs.h>`** to `thrworkq.h` (for `__packed`), placed with the other `<sys/...>`
   includes (e.g. before `<sys/_types.h>`).
2. **Audit thrworkq.h for ALL standalone-compile dependencies** so the next test-includes run clears
   the header outright rather than surfacing one missing include per retry. (Arranger pre-scan: the
   only macro used is `__packed`; every other token is `uintN_t` — covered by `<sys/_stdint.h>` — or a
   `_KERNEL`-guarded forward decl. So `<sys/cdefs.h>` is very likely the *last* missing include, but the
   Implementer confirms in one pass rather than assuming.)
3. DO NOT edit base `cdefs.h`/`_types.h`/`_stdint.h`; DO NOT remove `-ansi` (the test-includes tool is
   working as designed — masking it hides real non-self-containedness).

## Truly-green criterion

- a clean buildworld from the fix HEAD clears the **`test-includes` stage on thrworkq.h** (no
  `__packed` redefinition, no further thrworkq.h self-containedness error) and proceeds — proven by the
  **Validator's** op-111 re-run (5th run; Change→Retired validation, NOT Gatekeeper — a targeted
  single-fix build check, not a soak/integration run), NOT by a targeted single-header compile.
- NOTE: clears the thrworkq.h test-includes wall only; the next wall (further test-includes headers, then
  world compile / link / buildkernel) may lie behind it — each its own catalog. id-022 retires when
  test-includes clears thrworkq.h end-to-end.
