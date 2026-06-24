# id-006 — libdispatch runtime conformance + soak harness (the truly-green template)

- id: id-006
- state: **RETIRED 2026-06-23 — all 3 truly-green legs done for the 9-case core.** (1) functional
  matrix green+traced — op-102; (2) conformance diff no-mismatch vs current macOS — op-102 (MATCH
  9/9); (3) invariant oracles hold over an hours-scale soak — **op-108** (the id-009 proving soak,
  inherited: dispatch-conformance harness driving MACH_RECV churn under `soak-oracle-2h.d`, 27293
  iters / 2h / 0 violations, msg+queue+port balance flat — Arbiter-verified first-hand). `data`/`io`
  remain cataloged as not-yet-covered (consistent across all 3 legs) → pass-2 op, not a id-006 gap.
  This file is now the **template** the id-010/id-011 (notifyd/asl) harnesses copy.
- raised: 2026-06-23
- roadmap parent: [roadmap.md](../roadmap.md) — exercises **Gate A** (invariants) + **Gate B**
  (libdispatch conformance) and **seeds Gate D** (soak). It is the first place we *define*
  truly-green concretely, then reuse the pattern for notifyd/asl/libxpc.
- lane (when promoted): evidence-lane + parity-lane (dual-explorer conformance), libdispatch
  userland; observation-only (no product source edits).

## Why this is the next move

libdispatch is the furthest-along layer (primitive surface DONE, USDT live), so it is the
cheapest place to stand up the *first real runtime-test program* — and that harness becomes the
**template** for the layers above. Current libdispatch runtime evidence is short, single-shot,
exit-code-proven on a primitive surface (op-098 `op098_t2_fails=0`; op-101 `dispatch_after_fired`
+ USDT fire). That is a toehold, not a test program.

## Scope (when promoted)

**In:**
1. **Functional matrix breadth** — async/sync/apply/once/barrier/group/semaphore/source-timer/
   source-MACH_RECV/data/io, **block + `_f` variants**. Not just primitives.
2. **Dual-explorer conformance** — the *same* harness on the macOS explorer (`mx-a64z`, truth)
   and the rmxOS explorer (`rx-x64z`), semantics-diffed via the `macos-oracle.v1` schema. Move
   the claim from "exit-code-proven" to "behavior-matched-to-Darwin".
3. **Invariant oracles over a soak** — promote op-099 (mach-ipc) + op-101 (dispatch timer)
   probes to DTrace *assertions* watching a sustained run: port-balance, msg send/recv balance,
   no stuck enqueue, no leak. The probe *is* the test.

**Out:** product source edits (observation-only); the SDT typed-arg probes (separate RESTRICTED
IDQ item); notifyd/asl/libxpc harnesses (this is the template they copy, fetched separately).

## Truly-green criterion (what "Gate B/libdispatch passed" must mean)

- functional matrix runs green on the rmxOS guest (not exit-code-only — traced);
- conformance diff vs a *current* macOS run shows no semantic mismatch on the matrix (or each
  mismatch is laddered to an IDQ item);
- the invariant oracles hold over an hours-scale soak — zero violations, no leak/hang.

## Conformance DONE for the 9-case core (op-102 RETIRED, 2026-06-23)

**op-102 RETIRED (Arbiter-gated, first-hand verified).** The rmxOS-vs-Darwin diff is in:
`findings/.../20260623-op102-conformance-diff-result.md` (explorer commit `b0af223`) records
**MATCH 9/9, zero semantic mismatch** — rx-x64z (serial `a1b4e7c0…`) vs op-103 mx truth `6d02846`,
both `op102_matrix_fails=0`, nothing laddered. Both op-103 findings closed: (F1) `once_f` type
defect **fixed** — `cb_once(void*)` split from 2-arg `cb_add`, no `-Wno-error` paper (commit
`afb7fc3`); (F2) `data`/`io` **cataloged** as not-yet-covered (absent both sides), truth scoped
to the 9-case core — a pass-2 op adds data/io. Single-shot MACH_RECV green here (the id-009 UAF is
the *sustained-churn* race; op-108 is its proof, not this). Branch divergence resolved — `30f102c`
merged origin/main (op-103) with the op-105 line cleanly, now fast-forward-able (push held for
Coordinator).

**Truly-green status: 2 of 3 legs done.** (1) functional matrix green+traced — DONE (op-102);
(2) conformance diff no-mismatch vs current macOS — DONE for the 9-case core (op-102);
(3) invariant oracles hold over an hours-scale soak — **pending op-108** (in-flight). id-006
retires when op-108 lands green.

## Conformance progress (op-103 RETIRED, 2026-06-23)

The macOS-as-truth side is in hand. op-103 ran the op-102 `harness.c` **unmodified** on mx-a64z
(macOS 27.0 / Apple M4 / clang 17), emitting a schema-valid `macos-oracle.v1` truth record
(`findings/nx-r64z/dtrace/dispatch-conformance/macos-truth-op102-matrix.json`, commit `6d02846`).
Matrix **9/9 PASS** (`op102_matrix_fails=0`) — behavioral parity with rx-x64z ALL GREEN. The diff
itself is op-102's to run + adjudicate (rmxOS-vs-Darwin); the truth artifact it consumes exists.

Two findings op-103 raised, **both op-102's call** (logged so they aren't lost):
1. **`once_f` harness type defect (fix, don't paper).** `dispatch_once_f` is passed `cb_add`
   (`void(*)(void*,size_t)`) where `dispatch_function_t` = `void(*)(void*)` is required. macOS
   clang 17 **rejects** it (`-Werror=incompatible-function-pointer-types`); rmxOS clang only
   warned. op-103 built with `-Wno-error=...` (flag only, source unmodified) and `once_f` still
   PASSed — but that pass is incidental (the calling convention ignores the extra register arg);
   the code is type-incorrect / UB. Steer: **fix the harness** (split `cb_add` into a 1-arg
   `cb_once`), not paper it with `-Wno-error` — a truly-green conformance harness must not carry
   a type error. macOS clang is correct here; this is a harness bug, not rmxOS strictness.
2. **`data`/`io` not exercised (matrix-breadth gap).** The op-102 core harness covers 9 cases
   (async/sync/apply/once/barrier/group/semaphore block+`_f`, source-timer NORMAL,
   source-MACH_RECV) — `dispatch_data`/`dispatch_io` (listed In-scope above) are **absent on both
   sides**. So the conformance truth is bounded to the **9-case core**; `data`/`io` must be
   cataloged as not-yet-covered, not implied green. op-102's truly-green claim scopes accordingly.

## Open decisions (Coordinator-held, at fetch)

- soak duration / pass bar (what "hours-scale, zero violations" means in numbers);
- matrix scope cut for the first pass (full surface vs a core subset first).
