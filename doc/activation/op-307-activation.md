# op-307 — Implementer: make libxpc public type tokens pairwise distinct

op-307 | role: **Implementer** (sole product writer) | EXU: **wip-gpt / wip-rmxos** | state:
**[Retired — commit `40c8a93d4b3fec707b2e6ecd7762a1b20948e6e3` passed its M-sized
local correctness gate and S-sized publication gate; it is clean, origin-reachable, and the live
`alpha` tip]** |
parent: **op-306 / op-291 / id-021** | L1i:
**li-1005 / li-007** | gates: **op-308** | authored: **2026-07-11 by Arranger2**

## ARRANGER RETIREMENT — 2026-07-11

Publication gate size: **S**; the substantive source/static-ABI correction had already passed its
M-sized first-hand gate. Arranger2 reproduced in the full product repository:

- branch, `HEAD`, `origin/alpha`, and fresh `ls-remote refs/heads/alpha` all equal
  `40c8a93d4b3fec707b2e6ecd7762a1b20948e6e3`;
- clean full worktree and ahead/behind `0/0`;
- parent `a52a2ef51560943f7af4fe0b38e27f83508fd9b6` and successful result-to-origin ancestry;
- exactly one changed path, `lib/libxpc/xpc_type.c`, `+17/-16`;
- unchanged result blob `f37cacc1acd7935f9dec62a558bb44dc8d40833d` and SHA-256
  `825d4f6dcca3b00688929ecb97b056b6aa5c3c40bcedaaede7b9b47a7e96a5bb`; and
- clean `git diff --check` and `git show --check`, with no publication-time source change, new
  commit, force, image, guest, or runtime action.

**Verdict: RETIRED.** op-307 leaves the live ROB. This closes the type-token source/ABI and origin
gate only; it does not establish connection lifecycle, resource conservation, managed aslmanager,
or guest runtime acceptance. Those remain in op-311→Validator→held op-308.

## ARRANGER LOCAL CORRECTNESS GATE — 2026-07-11

Gate size: **M**. Arranger2 verified first-hand in the full product repository:

- clean `alpha@40c8a93d4b3fec707b2e6ecd7762a1b20948e6e3`, exactly one commit ahead of
  `origin/alpha` and fresh live remote `a52a2ef51560943f7af4fe0b38e27f83508fd9b6`;
- parent `a52a2ef51560943f7af4fe0b38e27f83508fd9b6`, one changed path
  `lib/libxpc/xpc_type.c`, `+17/-16`, clean `git diff --check` and `git show --check`;
- result source blob `f37cacc1acd7935f9dec62a558bb44dc8d40833d`, SHA-256
  `825d4f6dcca3b00688929ecb97b056b6aa5c3c40bcedaaede7b9b47a7e96a5bb`;
- all sixteen exported tokens are one-byte objects at distinct shared-library addresses
  `0xc440..0xc44f`, with payload bytes matching the sixteen existing internal type codes;
- the exact sixteen typemap relocations bind the correct public token at every internal type-code
  slot;
- the PIE consumer is DYN, has sixteen named `R_X86_64_64` plus sixteen `GLOB_DAT` bindings and no
  COPY relocation; the non-PIE consumer is EXEC with sixteen named, distinct one-byte COPY objects;
- the three library artifact hashes, both consumer hashes, commit-show hash, and command-record hash
  reproduce; the static Elixir checker reruns successfully; and
- no target-linked consumer execution, `dlopen`, preload, guest, image, or runtime acceptance is
  present or inferred.

Minor report correction: the before/after `nm -D` files each contain 501 total rows, but one is the
undefined weak `__cxa_finalize`; the defined name/type set is **500**, not “501 defined pairs.” The
before/after sets are byte-identical, so this wording error is non-blocking.

**Verdict: LOCAL-CORRECTNESS-ACCEPTED / ORIGIN-BLOCKED.** Runtime lifecycle, connection-header, and
managed-service acceptance remain exclusively in held op-308 after op-311 and its independent
Validator gate. `[Done]` is the return boundary; publication/origin reachability is still required
before op-307 can retire.

## PUBLICATION RETURN INTAKE — WRONG-STAGE DUPLICATE, NOT ACCEPTED — 2026-07-11

The returned text is the original `DONE 40c8a93d...` implementation report, not the commissioned
publication response. It explicitly records `push=0`, final status `ahead 1`, and no
`IMPL_OP307_PUBLICATION_*` markers.

Arranger2 rechecked the full repository and live remote first-hand:

- clean local `alpha@40c8a93d4b3fec707b2e6ecd7762a1b20948e6e3`;
- `origin/alpha` and fresh `ls-remote refs/heads/alpha` both still
  `a52a2ef51560943f7af4fe0b38e27f83508fd9b6`;
- local status remains exactly one ahead; and
- `git merge-base --is-ancestor 40c8a93d... origin/alpha` returns `1`.

**Verdict: PUBLICATION-NOT-ACCEPTED / WRONG-STAGE-DUPLICATE.** The product correction remains
locally accepted and unchanged. Re-relay the exact publication block below under the existing
op-307; consume no new ROB number.

## PUBLICATION RE-RELAY — CONSUMED 2026-07-11

The Coordinator re-relayed this no-change stage to **wip-gpt / wip-rmxos** under the same op number.
It returned `PUBLISHED 40c8a93d4b3fec707b2e6ecd7762a1b20948e6e3`; the retirement record above
contains the first-hand post-push proof.

### Required preflight

In `/Users/me/wip-mach/wip-gpt/wip-rmxos/`, require all of:

- branch `alpha`, clean full-repository worktree;
- local `HEAD=40c8a93d4b3fec707b2e6ecd7762a1b20948e6e3`;
- parent, `origin/alpha`, and fresh `git ls-remote origin refs/heads/alpha` all equal
  `a52a2ef51560943f7af4fe0b38e27f83508fd9b6`;
- direct fast-forward ancestry from the remote tip to the result; and
- the commit still changes only `lib/libxpc/xpc_type.c` with no amended source or evidence.

Stop `PUBLICATION-BLOCKED <drift>` on any mismatch. Do not pull, merge, rebase, amend, clean, create
a commit, alter build evidence, or force.

### Authorized publication when dispatched

Push only the accepted commit as a non-force fast-forward:

    git push origin 40c8a93d4b3fec707b2e6ecd7762a1b20948e6e3:refs/heads/alpha

No tag, other branch, submodule, artifact, image, guest, or control repository is in scope.

### Post-push proof / return

Refresh the ordinary remote-tracking observation, run a fresh `ls-remote`, and require local HEAD,
`origin/alpha`, and live remote all equal the accepted commit; require clean status, ahead/behind
`0/0`, and a successful ancestry check. Return exactly
`PUBLISHED 40c8a93d4b3fec707b2e6ecd7762a1b20948e6e3` or
`PUBLICATION-BLOCKED <reason>`, with pre/post tips, push output/rc, live-remote output, full status,
`source_changes=0`, `commits_created=0`, `force=0`, and `guest=0`.

Publication does not itself release op-308; the Arranger first verifies origin reachability and
retires op-307.

## PREMISE RELEASE / INCIDENT-SAFETY ANNOTATION — 2026-07-11

op-310's split is adjudicated: static ELF/nm plus `xpc_type.c` source decisively prove the sixteen
zero-sized public type tokens alias and make `xpc_get_type` public pointer discrimination invalid.
The physical-host dlopen/dlsym output is quarantined and is not needed for this release.

When this op is released, **do not dlopen the rebuilt libxpc, run a target-linked consumer/probe,
preload Mach stubs, or otherwise execute rmxOS constructors on the physical host**. Host checks are
limited to build, static ELF/relocation inspection, hashing, and compile/link without execution.
Runtime equality and lifecycle checks move to the later contained guest gate.

## RELEASE BASE ANNOTATION — DISPATCHED 2026-07-11

Arranger2 verified first-hand:

- repository `/Users/me/wip-mach/wip-gpt/wip-rmxos/`, branch `alpha`;
- clean full worktree; `HEAD`, `origin/alpha`, and fresh live remote all equal
  `a52a2ef51560943f7af4fe0b38e27f83508fd9b6`, with ahead/behind `0/0`;
- base parent `ceb46edc5f910660d4fa7ecd9e90501ebd86b1ba`; the intervening commit changes only four
  unrelated ASL paths and `lib/libxpc` is unchanged;
- `lib/libxpc/xpc_type.c`: blob `2a566593387f04856e194cfa823f8c8fea401eef`, 10,575 bytes /
  543 lines, SHA-256 `e7f19baf9a7b99d815286d95437474a082eaed706502223d01e8bd3919f34362`;
  the empty type-token storage premise remains present; and
- no project op is executing on the Implementer EXU.

Stop `BLOCKED BASE-DRIFT` without editing if any branch, commit, worktree, remote, or source identity
differs. Do not pull, merge, rebase, clean, or absorb unrelated work.

## DISPATCH BOUNDARY

DISPATCHED by the Coordinator on 2026-07-11 to **wip-gpt / wip-rmxos**.

When dispatched, write only `/Users/me/wip-mach/wip-gpt/wip-rmxos/`. All other repositories are
read-only. One focused local product commit; no push, image, guest, or runtime acceptance.

## OBJECTIVE / EDIT CEILING

Edit only `lib/libxpc/xpc_type.c` so every exported `_xpc_type_*` object has nonzero storage and a
pairwise-distinct stable address, while preserving every public symbol name and the pointer-identity
contract `XPC_TYPE_FOO == &_xpc_type_foo`.

The opaque payload representation is an Implementer choice, but it must be deterministic and must
not expose a new public structure or change `xpc_object_t` layout. If a correct solution needs a
header, build-system, consumer, or second source-file edit, return `BLOCKED SCOPE-EXPANSION` rather
than widening the commit.

## REQUIRED CORRECTNESS

- all sixteen exported type objects have nonzero ELF symbol size and pairwise-distinct addresses;
- `xpc_get_type` returns the corresponding public token for dictionary, array, bool, connection,
  endpoint, null, int64, uint64, date, data, string, uuid, fd, shmem, error, and double;
- cross-type comparisons are false, especially dictionary/array/error versus connection;
- connection header type=4/refcount=1 behavior from op-285 remains unchanged; and
- no export is removed/renamed, no ABI-visible function signature changes, and no unrelated object,
  serialization, transport, or lifecycle behavior changes.

## BUILD / MICROCHECK

Build libxpc with the established clean FreeBSD target environment. Against the freshly built
shared library:

1. capture `readelf -Ws`/`nm -D -n` for all type tokens and assert nonzero sizes plus 16 distinct
   addresses;
2. inspect the dynamic symbol table/relocations statically and prove the public token addresses are
   pairwise distinct; do not load the library on the physical host;
3. build—but do not execute on the physical host—linked public-macro consumers in both the normal
   supported PIE regime and the known `-fno-PIE`/non-PIE copy-relocation regime. Record ELF
   type/relocations and require each public macro to bind to its named distinct token object without
   relocation-induced coalescing; neither regime may be silently skipped;
4. inspect those consumers' symbol bindings/copy relocations and statically require that no build
   regime collapses distinct token objects; and
5. defer all object creation, `xpc_get_type` execution, connection-header runtime, and cross-type
   runtime comparison to held op-308 in a disposable guest without weakening the static
   symbol/storage gate.

Record exact commands, rcs, source/library/test hashes, outputs, `git diff --check`,
`git show --check`, and full-repository status.

## EXCLUSIONS

No op-291/306 harness edit, connection lifecycle fix, public-header redesign, modern XPC surface,
serialization/transport change, ASL work, guest, image, push, or green/release claim.

The adjacent `XPC_BOOL_TRUE`/`XPC_BOOL_FALSE` singleton contract is explicitly excluded and banked
under id-021: the current singleton exports also alias, and `xpc_bool_create` does not return them.
That requires a wider bool-object semantic decision, not a storage-only type-token edit.

## RETURN / VERDICT

Return exactly `DONE <commit>`, `BLOCKED <reason>`, or `NO-CHANGE <proof>`. A return is `[Done]`
only and receives a correctness gate plus origin-reachability check before op-308 can release.

## MARKERS

`IMPL_OP307_BASE_IDENTITY`

`IMPL_OP307_TYPE_STORAGE`

`IMPL_OP307_CROSS_TYPE_NEGATIVE`

`IMPL_OP307_BUILD`

`IMPL_OP307_MICROCHECK`

`IMPL_OP307_COMMIT`

`IMPL_OP307_TERMINAL`

## RELATIONS

op-306 / op-291 / op-285 / op-308 / id-021 / li-1005 / li-007.

feedback: `evidence_first`, `build_is_implementer`, `agent_host_isolation`,
`no_conflate_gating_with_readiness`, `op_state_dispatch_boundary`.
