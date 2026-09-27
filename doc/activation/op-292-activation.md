# op-292 — Implementer: complete the op-283 libxpc fixes with correct array replacement semantics

op-292 | role: **Implementer** (sole product writer) | EXU: **wip-gpt / wip-rmxos** | state:
**[Retired — Arranger2 M-gate accepted commit `0ccd56212c172c27877eb613a7dc9f75ebcc0630`
first-hand; exact source/build/static-microcheck scope passed; Coordinator-authorized fast-forward
made it reachable from `origin/alpha` on 2026-07-11; no blockers remain, so it leaves the live ROB]** |
parent: **id-021**
(libxpc conformance) | L1i: **li-007**
(libxpc core service) | authored: **2026-07-11 by Arranger2**

## DISPATCH BOUNDARY

DISPATCHED by the Coordinator to the **Implementer only** on 2026-07-11.
Continue product work only in `/Users/me/wip-mach/wip-gpt/wip-rmxos/`; use
`/Users/me/wip-mach/wip-gpt/build/op292-libxpc/` for new temporary self-check artifacts. Preserve
the frozen op-283 build/evidence directory. No other EXU may write product source, and no push or
guest activation is authorized.

## WHY THIS IS A NEW OP

op-283 returned BLOCKED without its primary commit because its required replacement microcheck
exposed a pre-existing `xpc_array_set_value` defect that its strict scope explicitly excluded.
Arranger2 verified the blocker first-hand and flushed op-283 under the no-continuation rule. This
fresh op carries the already-correct authorized edits plus the smallest **complete** replacement
correction; it is not an amendment suffix or silent scope expansion.

## REQUIRED DIRTY-HANDOFF IDENTITY

This op intentionally begins from a dirty worktree. Before editing, verify all of the following:

- branch/HEAD: `alpha@7291ad2a722b65661ff096ef09357b8756eb108f`;
- `origin/alpha`: `dd6e7a804ebfee330d40903dc4b9acb3e18863b9`;
- full status is exactly:

  ```text
  ## alpha...origin/alpha [ahead 2]
   M lib/libxpc/xpc_array.c
   M lib/libxpc/xpc_dictionary.c
   M lib/libxpc/xpc_misc.c
  ```

- the carried diff is exactly op-283's 8 insertions / 2 deletions: array append count increment and
  `>=` bound, three deserialize null guards, and removal of only `printf("nv = %p\n", nv);`;
- carried worktree blobs are:
  - `lib/libxpc/xpc_array.c` — `ad5288fd4b9e54adc85355bbc7d06b2a0a1c1650`;
  - `lib/libxpc/xpc_dictionary.c` — `bf6ca5ef1963fe35f7bce439169e31fea33b18dd`;
  - `lib/libxpc/xpc_misc.c` — `0100332316ae3f4461177188df1024ca5e906b65`.

Stop and report any extra dirt, changed blob, branch/HEAD/origin mismatch, or missing carried edit.
Do not reset, discard, restage from another tree, or absorb concurrent work.

## OBJECTIVE

Complete one focused local commit that:

1. preserves all six already-correct op-283 source changes;
2. makes `xpc_array_set_value` replace the requested node without corrupting its TAILQ;
3. honors the documented retain-new/release-old contract and same-object replacement; and
4. rebuilds libxpc and passes a strengthened host/static array microcheck.

## EXACT REPLACEMENT CONTRACT

File: `lib/libxpc/xpc_array.c`, inside `xpc_array_set_value` only.

Verified premises:

- FreeBSD declares `TAILQ_INSERT_AFTER(head, listelm, elm, field)`; current source reverses
  `listelm` and `elm`.
- `xpc/xpc.h:1160-1162` requires the array to retain the new value and release the displaced one.
- current `free(xotmp)` bypasses `xpc_release`, invalidating another caller's live reference.
- inserting `value == xotmp` would attempt to link one intrusive node after itself.

Implement this sequence, with equivalent formatting allowed but no semantic substitution:

1. When the indexed `xotmp` is the same object as `value`, leave the array unchanged and return.
2. Retain `value` before changing the list.
3. Insert `value` **after existing `xotmp`** using `xotmp` as `listelm` and `value` as `elm`.
4. Remove `xotmp` from the array.
5. Drop the array's ownership of the displaced object with `xpc_release(xotmp)`, never raw
   `free`/`xpc_object_destroy`.
6. Leave `xo_size` unchanged for replacement.

The intended body shape is:

```c
if (xotmp == (struct xpc_object *)value)
        return;
xpc_retain(value);
TAILQ_INSERT_AFTER(arr, xotmp, (struct xpc_object *)value, xo_link);
TAILQ_REMOVE(arr, xotmp, xo_link);
xpc_release(xotmp);
```

Keep the existing loop/index behavior unless compilation requires only a mechanical adjustment.

## PRESERVE THE CARRIED op-283 EDITS

The final diff must still include, unchanged in semantics:

- `xpc_array_append_value`: exactly one `xo->xo_size++` after insert/retain;
- `xpc_array_get_value`: reject `index >= xo->xo_size`;
- `xpc_unpack`: return `NULL` immediately when `nvlist_unpack` returns NULL;
- `xpc_pipe_receive` and `xpc_pipe_try_receive`: return `EINVAL` before first `xo` dereference;
- `xpc2nv` dictionary branch: no unconditional `nv = %p` print.

## BUILD AND STRENGTHENED MICROCHECK

1. Run `git diff --check` and prove only the same three product paths changed.
2. Build libxpc with the established FreeBSD procedure. Report exact command, target, exit code,
   output shared/static library paths, sizes, and SHA-256 values.
3. Create a fresh host/static check under the op-292 build directory, explicitly link the newly
   built `libxpc.a` with the established host-only Mach/dispatch stubs, and prove with `ldd`/`nm`
   that it does not resolve `libxpc.so` dynamically and embeds the tested `xpc_array_*` symbols.
4. Preserve the existing cases:
   - empty count 0 and index 0 NULL;
   - append distinct 11/22 values, count 2, indices 0/1 exact, index 2 NULL;
   - replace index 1 with 33, count remains 2, index 0 stays 11, index 1 is the replacement.
5. Add lifetime/alias cases:
   - the displaced value's creator-held reference remains valid after replacement, then one
     `xpc_release` of that creator reference completes without crash/double-free;
   - setting index 1 to the exact object already at index 1 is a no-op: pointer/value/count/order
     remain unchanged;
   - release the caller's references to the retained array elements and prove the array's borrowed
     getters remain valid before final array cleanup.
6. Run with allocator junk/diagnostic behavior enabled where supported, report the exact setting,
   and retain exact stdout/stderr/exit status. No core file is a passing result.
7. Re-prove the deserialize-guard ordering and format-string absence in source and built library.
8. Re-run full-repository status.

The passing marker must include at least:

```text
IMPL_OP292_ARRAY_MICROCHECK status=0 empty=1 append=1 replace=1 displaced_ref=1 self_replace=1 retained_after_caller_release=1 bounds=1 count=2
```

## DELIVERABLE

Only after every check passes, create one focused local product commit containing exactly:

- `lib/libxpc/xpc_array.c`;
- `lib/libxpc/xpc_misc.c`;
- `lib/libxpc/xpc_dictionary.c`.

Do not push. Return:

- base/parent/result commit SHAs, subject, exact paths, and final full status;
- complete focused diff plus `git diff --check`;
- build command/target/results and shared/static library identities;
- microcheck source/binary/output paths, static-link proof, allocator setting, and exact marker;
- source coordinates for replacement ordering, retain/release, same-object guard, deserialize null
  guards, and debug-string removal; and
- the markers below.

## BOUNDARIES

- Only the three named product files; temporary artifacts remain under the op-292 build directory.
- Do not alter the op-283 evidence directory.
- Do not redesign the intrusive array representation, multi-container membership, array/dictionary
  destructor policy, broader container refcounting, nvlist alias/lifetime, serialization policy,
  Mach transport, connection lifecycle, or op-285 code. Those are separate li-007 seeds.
- Do not edit/run Gatekeeper or Explorer harnesses; do not boot a guest.
- Do not push. A local commit remains non-retirable until separately validated and reachable from
  the relevant origin branch.
- Build/microcheck success is not release readiness.

## VERDICT

- `DONE <commit>` — exact scope landed, build and strengthened microcheck passed, focused local
  commit created.
- `BLOCKED <reason>` — identity drift, extra dirt, build/check failure, or another required change
  cannot remain inside the boundary. Preserve all work/evidence and stop.

## MARKERS

`IMPL_OP292_BASE_IDENTITY`

`IMPL_OP292_ARRAY_REPLACEMENT`

`IMPL_OP292_ARRAY_MICROCHECK`

`IMPL_OP292_UNPACK_GUARDS`

`IMPL_OP292_STDOUT`

`IMPL_OP292_BUILD`

`IMPL_OP292_COMMIT`

`IMPL_OP292_TERMINAL`

## RELATIONS

op-283 (verified/flushed predecessor; dirty handoff) / op-271 (consult source) / op-285 and op-291
(connection-lifecycle sibling and its runtime gate, excluded) / id-021 / li-007.

feedback: `oss_engineering_framing`, `build_is_implementer`,
`code_reasoned_verdict_is_hypothesis`, `verify_signature_divergence_claims`,
`no_conflate_gating_with_readiness`, `agent_host_isolation`, `op_state_dispatch_boundary`,
`artifact_identity_needs_content_check`.

## ARRANGER ADJUDICATION — 2026-07-11

Gate size: **M**, gated directly first-hand by Arranger2. Verdict: **ACCEPTED within the exact
op-292 scope**; state remains `[Done]` until origin reachability permits retirement.

Verified:

- product repo is clean at `alpha@0ccd56212c172c27877eb613a7dc9f75ebcc0630`; parent is the
  required `7291ad2a722b65661ff096ef09357b8756eb108f`; commit contains exactly the three named
  libxpc files and `git show --check` passes;
- committed and worktree blobs reproduce as `f553901d...` / `bf6ca5ef...` / `01003323...`;
- full `xpc_array_set_value` body implements same-object no-op, retain-before-mutation, correct
  `TAILQ_INSERT_AFTER(arr, xotmp, value, xo_link)` operands, removal of the displaced node, and
  `xpc_release` of its array ownership while preserving count;
- append increments count once; indexed get rejects `index >= xo_size`; each unpack caller checks
  NULL before first dereference; the unconditional dictionary printf is absent;
- reported shared/static identities reproduce: 200208-byte `libxpc.so.5`
  `b896e586...` and 414198-byte `libxpc.a` `16d62c38...`;
- microcheck source/binary hashes reproduce as `aaec9b25...` / `eda47de2...`; `ldd` has no dynamic
  libxpc and `nm` defines all tested `xpc_array_*` symbols. Arranger rerun with
  `MALLOC_CONF=junk:true,abort:true,abort_conf:true` exits 0 with every commissioned marker equal
  to 1 and count 2;
- no core exists in the op-292 build scope, and the op-283 evidence directory was not changed.

The broader single-intrusive-link and array/dictionary destructor/refcount defects remain the
already-banked li-007 container-ownership seed and were intentionally not folded into this op.
No guest run was commissioned or required for this localized, non-preview-gating bundle.

Retirement cleared 2026-07-11: Coordinator directive “for 4. do it” authorized a case-specific
one-way-door for the Arranger to fast-forward the product ref without changing source or commits.
Live `origin/alpha` and local alpha now both resolve to `0ccd5621`; `git merge-base --is-ancestor`
passes for `778cb07`, `7291ad2`, and `0ccd5621`. No Arranger product build, source edit, commit,
force-push, or cleanup was performed.
