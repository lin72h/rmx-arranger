# op-283 — Implementer: three localized libxpc array/deserialize/output fixes

op-283 | role: **Implementer** (sole product writer) | EXU: **wip-gpt / wip-rmxos** | state: **[Flushed — returned BLOCKED 2026-07-11; Arranger2 S-sized first-hand gate confirmed the commissioned replacement microcheck fails and no primary commit was delivered. The strict brief excluded replacement edits, so this op was mis-scoped and is closed rather than marked Done. Existing authorized three-file dirt is preserved for fresh follow-on op-292. Gate correction: reversing the `TAILQ_INSERT_AFTER` operands is necessary but not sufficient—the public XPC contract also requires a balanced release of the displaced value, and self-replacement must not relink one node onto itself.]** | parent: **id-021** (libxpc conformance) | L1i: **li-007** (libxpc) | authored: **2026-07-10; normalized/source-corrected and dispatched 2026-07-11; flushed by Arranger2 2026-07-11**

## ARRANGER ADJUDICATION — 2026-07-11

The Implementer stopped at the exact scope boundary and created no commit. First-hand verification
confirmed:

- product `alpha@7291ad2`, `origin/alpha@dd6e7a8`, exactly the three named modified paths, and the
  reported 8-insertion/2-deletion diff;
- worktree blobs `ad5288fd4b9e…` (array), `bf6ca5ef1963…` (dictionary), and
  `0100332316ae…` (misc), with `git diff --check` clean;
- built `libxpc.so.5` size 200192 and SHA-256 `8cb0a9621e1c3e47b23087f5623e0f0ab829a2782166bbf70a6d3c06460ff827`;
- the final host/static microcheck embeds the `xpc_array_*` symbols and reproduces exit 1 with
  `empty=1 append=1 replace=0 count=2 index0=11 index1=22 index2_null=1`;
- FreeBSD's macro contract is `TAILQ_INSERT_AFTER(head, listelm, elm, field)`, while source passes
  the new value as `listelm` and the existing element as `elm`; and
- all three null guards precede dereference and the stray format string is absent from source and
  the built library.

The returned one-line suggestion is incomplete. `xpc/xpc.h:1160-1162` says the array retains the
new object and **releases** the displaced object. Current `free(xotmp)` bypasses refcount semantics
and can invalidate a caller-held reference. Inserting the same object at its own position would
also corrupt the intrusive link. Fresh op-292 carries the smallest complete replacement contract,
the existing authorized dirt, rebuild, strengthened microcheck, and focused commit.

## DISPATCH BOUNDARY

DISPATCHED to the Implementer only. Edit/build in
`/Users/me/wip-mach/wip-gpt/wip-rmxos/` and use `/Users/me/wip-mach/wip-gpt/build/op283-libxpc/`
for temporary self-check artifacts. No other EXU may write product source. No push is authorized.

## REQUIRED BASE CHECK

- Expected branch/HEAD: `alpha@7291ad2a722b65661ff096ef09357b8756eb108f`
- Expected full status: clean, with `alpha` **two commits ahead** of `origin/alpha` at dispatch
  authoring.
- Run full-repository `git status --short --branch`, record HEAD and `origin/alpha`, and stop on any
  mismatch or unrelated dirt. Do not absorb another op's changes.

## OBJECTIVE

Land three independent, source-confirmed libxpc corrections in one focused commit:

1. maintain array count and enforce the correct indexed-read bound;
2. reject failed nvlist deserialization before any caller dereferences the null result; and
3. remove an unconditional dictionary-serialization debug `printf`.

## FIX A — ARRAY COUNT AND BOUND

File: `lib/libxpc/xpc_array.c`

Current source facts:

- `xpc_array_create(..., count)` starts with `_xpc_prim_create(..., size=0)` and appends each item.
- `xpc_array_append_value` inserts/retains the item but never increments `xo->xo_size`.
- `xpc_array_get_count` returns `xo_size` and `xpc_array_set_value` rejects
  `index >= xo_size`; both are therefore wrong after appends.
- `xpc_array_get_value` currently rejects only `index > xo_size`; valid indices end at
  `xo_size - 1`.
- There is no array-element removal path in this file. `xpc_array_set_value` replaces one element
  in place and must not change the count; `xpc_array_apply` walks the TAILQ and is already correct.

Exact edit:

1. Increment `xo->xo_size` exactly once in `xpc_array_append_value` after the successful
   insert/retain sequence.
2. Change the `xpc_array_get_value` guard from `index > xo->xo_size` to
   `index >= xo->xo_size`.
3. Do not add a decrement or change replacement/apply/destructor behavior.

## FIX B — FAILED DESERIALIZATION MUST REACH CALLERS SAFELY

File: `lib/libxpc/xpc_misc.c`

Current source facts:

- `xpc_unpack` passes `nvlist_unpack` directly to `nv2xpc`; malformed/truncated input may yield
  `nv == NULL`, and `nv2xpc` immediately calls `nvlist_type(nv)`.
- The legacy brief proposed only `if (nv == NULL) return NULL`. That is insufficient: both
  `xpc_pipe_receive` and `xpc_pipe_try_receive` immediately dereference
  `xo->xo_flags` after calling `xpc_unpack`.
- `xpc_pipe_receive` already has an integer error contract and its connection caller returns on
  nonzero. `xpc_pipe_try_receive` returns an `int`; launchd logs non-1 results and processes an XPC
  request only when the result is 0 and the request object is non-null.

Exact edit:

1. In `xpc_unpack`, immediately return `NULL` when `nvlist_unpack` returns `NULL`, before
   `nv2xpc`.
2. In both `xpc_pipe_receive` and `xpc_pipe_try_receive`, immediately test the returned `xo` before
   the first dereference; if it is `NULL`, return `EINVAL`.
3. Do not add `nvlist_destroy`: successful xpc objects currently alias nvlist-owned key/string/data
   storage, so a local destroy would create use-after-free. That lifetime correction remains one
   separate coordinated design seed.
4. Do not alter Mach-port ownership, message framing, audit-token handling, or the callers' wider
   receive behavior in this op.

## FIX C — REMOVE STRAY OUTPUT

File: `lib/libxpc/xpc_dictionary.c`

Delete only the unconditional `printf("nv = %p\n", nv);` in the dictionary branch of `xpc2nv`.
Do not change nvlist creation, dictionary traversal, packing, or error policy.

## BUILD AND SELF-CHECK

1. Run `git diff --check` and prove only these paths changed:
   - `lib/libxpc/xpc_array.c`
   - `lib/libxpc/xpc_misc.c`
   - `lib/libxpc/xpc_dictionary.c`
2. Build libxpc with the repository's existing FreeBSD build procedure. Report exact command,
   target, exit code, output library path, size, and SHA-256.
3. In the Implementer-owned build directory, run a focused array microcheck against the built
   library:
   - empty array count is 0 and index 0 returns NULL;
   - append two distinguishable values, count is 2, indices 0 and 1 return the expected objects,
     and index 2 returns NULL;
   - replace index 1, verify the replacement and count remains 2.
4. Source-check both deserialize callers: each `xo == NULL` guard must precede its first
   dereference and return `EINVAL`. Build success plus this source proof is the commissioned bar;
   no crafted Mach-message guest run is requested.
5. Confirm the built library contains no `nv = %p` format string.
6. Re-run full-repository status.

## DELIVERABLE

After all checks pass, create one focused local product commit containing exactly the three source
files above. Do not push. Return:

- base SHA, resulting commit SHA, parent, subject, and exact changed paths;
- focused diff and `git diff --check` result;
- build command/target/exit code and library path/size/SHA-256;
- array microcheck source path, command, and exact result;
- source coordinates for all three null guards and proof they precede dereference;
- absence check for the debug format string;
- full final repository status; and
- the markers below.

## BOUNDARIES

- No changes outside the three named product files; temporary tests stay under
  `/Users/me/wip-mach/wip-gpt/build/op283-libxpc/` and are not committed to product.
- Do not touch nvlist/xpc lifetime or add `nvlist_destroy`.
- Do not change silent-drop policy for unsupported XPC types, zero-length data behavior,
  reply-correlation, Mach transport framing, connection lifecycle, or op-285 code.
- Do not edit or run Gatekeeper/Explorer harnesses and do not boot a guest.
- Do not push. A local commit remains non-retirable until separately verified and reachable from
  the relevant origin branch.
- Build/self-check success is not runtime acceptance or release readiness.

## VERDICT

- `DONE <commit>` — exact three-file fixes landed, build and focused self-check passed, local commit
  created.
- `BLOCKED <reason>` — base mismatch, unrelated dirt, build/self-check failure, or a required fix
  cannot remain within the named boundary. Preserve evidence and stop.

## MARKERS

`IMPL_OP283_BASE_IDENTITY`

`IMPL_OP283_ARRAY`

`IMPL_OP283_UNPACK_GUARDS`

`IMPL_OP283_STDOUT`

`IMPL_OP283_BUILD`

`IMPL_OP283_COMMIT`

`IMPL_OP283_TERMINAL`

## RELATIONS

op-271 (consult source) / op-263 (reply-correlation sibling, excluded) / op-285 (connection
lifecycle sibling already in the base, excluded) / id-021 / li-007.

feedback: `oss_engineering_framing`, `build_is_implementer`,
`code_reasoned_verdict_is_hypothesis`, `verify_signature_divergence_claims`,
`no_conflate_gating_with_readiness`, `agent_host_isolation`, `op_state_dispatch_boundary`.
