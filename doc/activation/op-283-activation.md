# op-283 — Implementer: land the three trivial/low-risk libxpc serialization fixes from op-271 — array count bookkeeping + xpc_unpack null-check + stray printf removal

op-283 | role: **Implementer** | EXU: **wip-gpt** | state: **[Awaiting dispatch — three independently-safe, low-risk edits carved from the op-271 consult (Arranger-verified first-hand at source 2026-07-10). Each is self-contained and does NOT touch the pack/unpack memory-lifetime (the leak+aliasing coupling is EXPLICITLY OUT — banked to li-007 as a must-be-one-coordinated-change seed, because a naive nvlist_destroy = use-after-free). Coordinator dispatches.]** | parent id: id-021 (libxpc conformance bring-up) | L1i: li-007 (libxpc core service) | cost: implementer (small — three localized libxpc edits) | authored 2026-07-10 (Arranger seat, model Opus 4)

## CONTEXT (engineering framing)
Ordinary open-source OS engineering on our own IPC library. rmxOS = Darwin/Mach userland on FreeBSD 15. libxpc is one of the four core services. Three localized code-quality fixes on our own source, each surfaced by a maintainer consult and verified at source. No target, no adversary.

## WHY (one line)
The op-271 value-serialization consult (Arranger-verified first-hand) found three trivial, independently-safe defects on the xpc array + pack/unpack path — a count-bookkeeping bug that makes rebuilt arrays unusable by index, a missing null-check that crashes on malformed peer bytes, and a stray debug `printf` that pollutes child stdout.

## THE THREE FIXES (each verified at source in the release base `wip-gpt/wip-rmxos/lib/libxpc/`)

### Fix A — array count bookkeeping (`xpc_array.c`)
`xpc_array_append_value` (`:78-88`) inserts the value into the TAILQ (`TAILQ_INSERT_TAIL` + `xpc_retain`) but NEVER increments `xo->xo_size`. Consequences, all confirmed at source:
- `xpc_array_get_count` (`:113-120`) returns `xo_size` → always 0.
- `xpc_array_set_value` (`:62`) guards `if (index >= (size_t)xo->xo_size) return;` → refuses every index (nothing can be set).
- `xpc_array_get_value` (`:102`) guards `if (index > xo->xo_size) return NULL;` → off-by-one: index 0 works only by accident, index ≥1 returns NULL.

**Edit:** increment `xo->xo_size` on append (and decrement on any remove/reset path in the same file, if present — check `xpc_array_set_value`'s free-and-replace at `:71` does not double-count). Change the `xpc_array_get_value` guard from `index > xo->xo_size` to `index >= xo->xo_size` so it is a correct bounds test against the now-maintained count. Do NOT change `xpc_array_apply` (`:319-322`) — it iterates the TAILQ directly and is already correct (this is why the PACK side was unaffected and the bug only bites indexed consumers of a rebuilt array).

### Fix B — `xpc_unpack` null-check (`xpc_misc.c`)
`xpc_unpack` (`:128-137`) calls `nv = nvlist_unpack(buf, size)` and passes `nv` straight into `nv2xpc` — the `:134` path dereferences it with NO null-check. Malformed or truncated bytes from a peer make `nvlist_unpack` return NULL → crash.

**Edit:** after `nvlist_unpack`, if `nv == NULL` return NULL (clean definite-failure return, matching the wrapper's existing failure contract). Do NOT add an `nvlist_destroy` here — the returned xpc tree aliases the nvlist backing memory (the leak is load-bearing; the coordinated lifetime fix is the li-007 banked seed, out of scope for this op).

### Fix C — stray debug printf (`xpc_dictionary.c:251`)
`xpc2nv` (`:243-256`) contains `printf("nv = %p\n", nv);` at `:251`, inside the dictionary-pack branch — it fires on every dictionary serialization and pollutes the stdout of any process that packs xpc (including launchd children).

**Edit:** delete the line.

## SCOPE
- Exactly the three edits above, each independently safe and localized.
- Build libxpc; confirm compile/link on the FreeBSD target.
- A quick local sanity exercise of an array roundtrip (append N, assert `get_count == N`, `get_value(i)` returns each) is welcome as a self-check but the formal roundtrip/conformance run is a follow-on, not this op.

## BOUNDARIES
- Do NOT touch the pack/unpack nvlist lifetime (the leak + aliasing coupling) — that is a must-be-ONE-coordinated-change seed banked to li-007; a naive `nvlist_destroy` here = use-after-free on aliased keys/strings/data.
- Do NOT decide the silent-drop policy for null/connection/endpoint/shmem/error/FD or the zero-length-data poison — those are wire-semantics decisions banked to li-007, not code reflexes.
- Do NOT expand into the reply-correlation path (op-263), the Mach transport loop, or the connection lifecycle.
- Does not decide milestone placement or release timing.

## RELATIONS
op-271 (the consult these fixes resolve — Arranger-verified at `xpc_array.c:40/62/71/78-88/102/113-120/319-322`, `xpc_misc.c:108-137`, `xpc_dictionary.c:251`) / the leak+aliasing + silent-drop-policy seeds banked in li-007 (op-271 seeds section — deliberately NOT in this op) / op-263 (the reply-correlation sibling consult on the same library, fenced out) / id-021 (libxpc conformance bring-up) / li-007 (libxpc core service). feedback: oss_engineering_framing, build_is_implementer, code_reasoned_verdict_is_hypothesis, verify_signature_divergence_claims, no_conflate_gating_with_readiness, agent_host_isolation, op_state_dispatch_boundary.
