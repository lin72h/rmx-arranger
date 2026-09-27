# op-270 — Oracle2: notifyd shared-memory slot bounds and counter reset-on-reuse

op-270 | role: **Oracle** (consult-only; no product or control-state write) | EXU: **Oracle2 / rmx-oracle2** | state: **[Retired — Oracle note returned and Arranger2 verified both source questions first-hand on 2026-07-11; Q1 logical bounds SOLID with a separately banked extreme-size allocation caveat, Q2 reset semantics SOLID; no live preview consumer drives the caveat]** | parent: **id-010** (libnotify/notifyd) | L1i: **li-1003** (notify) | re-issued: **2026-07-11 by Arranger2**

## ARRANGER ADJUDICATION — 2026-07-11

**Verdict: VERIFIED / Q1 SOLID-WITH-PHYSICAL-SIZE-CAVEAT / Q2 SOLID / BANKED-NON-PREVIEW.**

This M-sized Oracle consult was verified directly at the cited source. Deliverable:
`/Users/me/wip-mach/rmx-oracle2/op-270-notifyd-shared-memory-slot-lifecycle.md`, 15,410 bytes /
327 lines / SHA-256
`7b4c6c6da35e1b81901ea6ba3340c8f12cd67aad14ddd34a9972a58ae53bdc97`. Oracle2 has no Git
repository, so that identity is local-only.

The original pin `778cb07442e61cdd8fb3e766b91676f2e9a261b8` and accepted review pin
`0ccd56212c172c27877eb613a7dc9f75ebcc0630` carry the same `notify_proc.c` blob
`853dffd816bd3dd56f0167a0932e1413801d71fb`; `git diff` shows no notifyd change between them.
Arranger inspection used committed source at `0ccd5621`, not the later local product tip.

First-hand findings:

- `nslots == 0` returns through plain registration before either shared-memory array is indexed.
- For initialized `nslots >= 2`, the scan and exhaustion paths keep `x` in
  `[1, nslots - 1]`; `slot_id` starts at zero and every later assignment remains bounded. The
  two-slot case uses only cell 1. A hypothetical one-slot table selects invalid cell 1, but the
  page-derived current initializer cannot produce one on the 4 KiB targets.
- The physical-size caveat is real: `global.nslots` and `open_shared_memory()`'s byte `size` are
  `uint32_t`. At 4 KiB pages, `-shm_pages 1048577` produces `nslots=1073742848`
  (`0x40000400`), mathematical bytes `4294971392`, but narrowed size `4096` (1024 cells).
  After cells 1…1023 are occupied, the next scan can first read `shared_memory_refcount[1024]`
  outside the allocation. This is a physical-allocation mismatch, not a refutation of the logical
  interval proof.
- Every newly selected cell, whether free or deliberately reused while live, executes
  `shared_memory_base[x] = 1` before the refcount increment, returned slot, and registration
  helper. A successful new name cannot inherit the prior numeric count. Deliberate reuse resets
  the incumbent's cell and aliases both names; same-name registration intentionally preserves
  the existing count.
- The pre-existing helper-failure no-rollback issue remains outside this op and is not promoted as
  a new finding.

The exposure census found exactly one product parser/manpage pair for `-shm_pages`, no override in
the shipped `com.apple.notifyd.plist`, and no override in the product, Arranger, Gatekeeper, or
Explorer configuration trees. The shipped invocation therefore uses one 4 KiB page / 1024 cells.
No live 1.0-preview consumer reaches the one-slot or extreme-size premises. Runtime behavior was
not exercised and is not claimed.

The bounded hardening is banked as **id-041**: checked page/count/byte derivation and fail-closed
invalid/extreme argument handling, with default-path and negative-control acceptance if the
Coordinator later fetches it. It does not reopen retired id-010 or block li-1003/1.0-preview.
This supplies the required explicit consumer-census closure; no product op is issued. op-270
retires and leaves the live ROB.

## DISPATCH BOUNDARY

DISPATCHED to Oracle2 only. One op, one EXU. Oracle2 may read the product source and write only the
named note in `/Users/me/wip-mach/rmx-oracle2/`. Do not edit the product tree or the Arranger tree.

## OBJECTIVE

Determine two residual correctness properties of notifyd's `NOTIFY_TYPE_MEMORY` shared-counter
slot lifecycle: allocation-index bounds and counter-cell reset when a slot is reused. Return
source-cited hypotheses for Arranger verification; do not propose or perform a product edit.

## SOURCE BASE

- Product repo, read-only: `/Users/me/wip-mach/wip-gpt/wip-rmxos/`
- Release branch/artifact: `alpha@778cb07442e61cdd8fb3e766b91676f2e9a261b8`
- Load-bearing source: `usr.sbin/notifyd/notify_proc.c`
- Read the complete surrounding bodies for `cancel_subscription` and
  `__notify_server_register_check`, including the slot search, exhaustion/reuse, counter update,
  register-failure, cancel, and process-death paths.

## ESTABLISHED SCOPE FENCE

A prior review already covered same-name slot selection, ordinary registration/cancel refcount
pairing, and process-death delivery into `cancel_subscription`. It also identified the increment at
`notify_proc.c:679` preceding `_notify_lib_register_plain` and the no-rollback failure return at
`:686-690`. Treat those as context; do not re-run that wider review. This op owns only Q1 and Q2.

## QUESTIONS

1. **Slot-index bounds.** Prove or refute that every reachable allocation/reuse path keeps `x`
   within `[1, global.nslots - 1]` before indexing `global.shared_memory_base[x]` and
   `global.shared_memory_refcount[x]`. Include edge cases for `global.nslots` 0, 1, and 2; wrap of
   `global.slot_id`; the free-slot scan at `notify_proc.c:647-654`; and the exhaustion/reuse path at
   `:657-670`. Identify the initialization source of `global.nslots` if it is load-bearing.
2. **Counter-cell reset on reuse.** Prove or refute that a slot assigned to a new name receives the
   intended initial counter value before exposure, for both a refcount-zero free-slot selection and
   deliberate in-use-slot reuse on exhaustion. Trace the `new_slot` condition and
   `global.shared_memory_base[x]` write at `notify_proc.c:678`; state whether the new registration
   can inherit a prior name's observable count.

## DELIVERABLE

Write exactly:

`/Users/me/wip-mach/rmx-oracle2/op-270-notifyd-shared-memory-slot-lifecycle.md`

The note must contain:

- source branch, commit, and exact file read;
- one section per question, labeled `SOLID`, `UNCERTAIN`, or `NEEDS-RUNTIME-CHECK`;
- the complete control-flow argument with current file:line citations, including the surrounding
  function body rather than isolated lines;
- for any defect hypothesis: triggering preconditions, affected index/cell, and the smallest
  read-only runtime premise that would distinguish it;
- a concise conclusion separating source fact, inference, and unverified runtime behavior; and
- the markers below.

## BOUNDARIES

- Read and advise only. No writes outside the Oracle2 repository.
- Do not edit, build, boot, run a guest, allocate IDs, issue follow-ons, adjudicate, or decide
  release/milestone status.
- Do not expand into the notify name-table balance, client API matrix, post/delivery walk, launchd
  lifecycle, interface comparison, or unrelated `__notify_server_regenerate` behavior.
- A code-reasoned Oracle verdict is a hypothesis. Cite evidence; the Arranger verifies and routes it.
- If current source differs from the cited base, stop and report the exact divergence instead of
  silently reviewing another artifact.

## MARKERS

`O2_OP270_SOURCE_IDENTITY`

`O2_OP270_Q1_SLOT_BOUNDS`

`O2_OP270_Q2_COUNTER_RESET`

`O2_OP270_TERMINAL`

## RELATIONS

id-010 (libnotify/notifyd) / li-1003 (notify) / prior name-table register-cancel review (settled
scope, not repeated) / op-243 (separate notify runtime-soak lane; not part of this consult).

feedback: `oss_engineering_framing`, `code_reasoned_verdict_is_hypothesis`,
`verify_signature_divergence_claims`, `no_conflate_gating_with_readiness`,
`agent_host_isolation`, `op_state_dispatch_boundary`.
