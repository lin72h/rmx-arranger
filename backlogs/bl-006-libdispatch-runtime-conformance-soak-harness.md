# bl-006 — libdispatch runtime conformance + soak harness (the truly-green template)

- id: bl-006
- state: READY (fetchable now) — preconditions met: primitive surface proven (op-098), timer
  USDT enabled (op-101), mach-ipc fbt probe library exists (op-099). Awaiting Coordinator
  fetch (issue into op).
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
backlog); notifyd/asl/libxpc harnesses (this is the template they copy, fetched separately).

## Truly-green criterion (what "Gate B/libdispatch passed" must mean)

- functional matrix runs green on the rmxOS guest (not exit-code-only — traced);
- conformance diff vs a *current* macOS run shows no semantic mismatch on the matrix (or each
  mismatch is laddered to a backlog item);
- the invariant oracles hold over an hours-scale soak — zero violations, no leak/hang.

## Open decisions (Coordinator-held, at fetch)

- soak duration / pass bar (what "hours-scale, zero violations" means in numbers);
- matrix scope cut for the first pass (full surface vs a core subset first).
