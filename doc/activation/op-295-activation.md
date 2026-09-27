# op-295 — Implementer: remove two verified stale libxpc public declarations

op-295 | role: **Implementer** (sole product writer) | EXU: **wip-gpt / wip-rmxos** |
state: **[Retired — Arranger2 M-sized first-hand gate accepted commit
`ceb46edc5f910660d4fa7ecd9e90501ebd86b1ba`; exact truth/diff/build/consumer checks pass;
Coordinator-authorized fast-forward is reachable from `origin/alpha` as of 2026-07-11; no blockers
remain, so it leaves the live ROB]** | parent:
**id-031** | L1i: **li-1005 / li-007; governed by li-1011 bucket 2** | authored:
**2026-07-11 by Arranger2**

## ARRANGER ADJUDICATION — 2026-07-11

**Verdict at the local gate: LOCAL-ACCEPTED / ORIGIN-BLOCKED.** No Validator delegation was
required for this M-sized, two-header, no-runtime change. At that gate op-295 remained `[Done]`
until its commit became reachable from `origin/alpha`; it did not become a preview-green claim.

First-hand verification:

- product is clean `alpha@ceb46edc5f910660d4fa7ecd9e90501ebd86b1ba`, exactly one commit ahead
  of `origin/alpha@0ccd56212c172c27877eb613a7dc9f75ebcc0630`; parent/base is exact and the
  result is not origin-reachable;
- `git show` changes only `lib/libxpc/xpc/debug.h` and `lib/libxpc/xpc/xpc.h`, 29 deletions;
  `git diff --check` and `git show --check` return 0;
- parent census finds the two public declarations only in the commissioned header blocks; current
  full-product census finds neither. `debug.h` and its include guard/install/umbrella references,
  adjacent `xpc_main`, Transactions, `XPC_HOSTING_OLD_MAIN`, `_xpc_object_validate`, and
  `_xpc_unreachable` remain;
- pinned macOS export list hashes to
  `5537e7bd1658a7c094b0515ef95accb9f98ad50cf464d4b8d8b424e057882d99` and contains neither
  exact public name;
- build log is 104,643 bytes / SHA `5e1eaefc...`; build rc is 0. Rebuilt shared/static identities
  reproduce as 200,208 / `b896e586...` and 414,198 / `16d62c38...`; both exact-name `nm`
  searches are absent;
- Arranger independently recompiled the consumers with the final flags: positive includes both
  headers and passes, producing object SHA `d8f4d8ac...`; debugger and service-main negatives exit
  1 solely on the commissioned undeclared names/types and produce no object.

The edit fulfilled id-031 locally. No guest/push occurred during implementation. Retirement still
required Coordinator-authorized publication followed by a fresh origin-ancestor check; the later
sections record those completed gates.

## PUBLICATION RELEASE — 2026-07-11

The Coordinator delegated the publication call to Arranger2. **Decision: RELEASE EXACT NON-FORCE
PUSH.** Arranger2 rechecked first-hand immediately before release:

- product worktree is clean on `alpha@ceb46edc5f910660d4fa7ecd9e90501ebd86b1ba`;
- local and remote-observed `origin/alpha` both equal
  `0ccd56212c172c27877eb613a7dc9f75ebcc0630`;
- the accepted commit is the single fast-forward child of that origin tip and changes only the two
  commissioned headers; and
- no remote branch currently contains the accepted commit.

The Implementer may now publish only this fast-forward:

`git push origin ceb46edc5f910660d4fa7ecd9e90501ebd86b1ba:refs/heads/alpha`

Immediately before pushing, repeat full `git status`, HEAD, remote `refs/heads/alpha`, and
fast-forward ancestry checks. Stop `BLOCKED publication-drift` on any mismatch, dirt,
non-fast-forward, hook failure, or remote movement; do not fetch-and-merge, rebase, amend, force,
or edit product files. After a successful push, return the exact command/result and fresh
`git ls-remote origin refs/heads/alpha`. No guest or new build is required. Arranger retirement
still waits on its own first-hand origin-ancestor check.

## RETIREMENT — 2026-07-11

**Verdict: RETIRED / ORIGIN-REACHABLE.** After the Implementer reported successful publication,
Arranger2 reproduced first-hand:

- full product status is clean: `## alpha...origin/alpha`;
- local `HEAD`, local `origin/alpha`, and live `git ls-remote origin refs/heads/alpha` all equal
  `ceb46edc5f910660d4fa7ecd9e90501ebd86b1ba`;
- `git merge-base --is-ancestor ceb46edc5f910660d4fa7ecd9e90501ebd86b1ba origin/alpha`
  returns 0; and
- the published commit still changes only `lib/libxpc/xpc/debug.h` and
  `lib/libxpc/xpc/xpc.h`, 29 deletions.

The accepted artifact is now origin-reachable. id-031 is complete, op-295 retires, and both leave
the pending-work path. This optional header cleanup does not itself assert libxpc runtime green.

## DISPATCH BOUNDARY

DISPATCHED by the Coordinator to the Implementer only on 2026-07-11. Product work lands only in
`/Users/me/wip-mach/wip-gpt/wip-rmxos/`; temporary build/check artifacts land under
`/Users/me/wip-mach/wip-gpt/build/op295-libxpc/`. Do not write the Arranger, Explorer,
Gatekeeper, Oracle, Swift, or Zig repositories. The initial implementation dispatch authorized no
push; the later **PUBLICATION RELEASE** above supersedes that restriction only for the exact
non-force fast-forward named there. No guest activation is authorized.

## OBJECTIVE

Create one focused local product commit that removes exactly two public declarations which are
present in rmxOS headers but have no implementation, no in-tree caller, and no matching macOS
export:

1. `xpc_debugger_api_misuse_info` from `lib/libxpc/xpc/debug.h`;
2. `xpc_service_main` and its now-unused, compatibility-block-local
   `xpc_service_event_handler_t` typedef from `lib/libxpc/xpc/xpc.h`.

This is optional low-risk header-surface fidelity under li-1011 bucket 2. It is not a preview-green
claim and does not alter libxpc runtime behavior or ABI exports.

## REQUIRED BASE IDENTITY

Before editing, verify first-hand:

- repository: `/Users/me/wip-mach/wip-gpt/wip-rmxos/`;
- branch/HEAD: `alpha@0ccd56212c172c27877eb613a7dc9f75ebcc0630`;
- `origin/alpha`: `0ccd56212c172c27877eb613a7dc9f75ebcc0630`;
- full worktree status: clean;
- `lib/libxpc/xpc/debug.h` still declares `xpc_debugger_api_misuse_info`;
- the `#if XPC_HOSTING_OLD_MAIN` block in `lib/libxpc/xpc/xpc.h` still contains only
  `xpc_service_event_handler_t` and `xpc_service_main`;
- neither public symbol has a definition or caller elsewhere in the full product tree.

Stop and return `BLOCKED identity-drift` on any mismatch or unrelated dirt. Do not reset, discard,
or absorb another worker's changes.

## PINNED TRUTH INPUTS

Read before editing:

- `/Users/me/wip-mach/rmx-arranger/idq/id-031-libxpc-header-surface-truth-alignment.md`;
- `/Users/me/wip-mach/rmx-explorer/findings/nx-r64z/20260626-op167-libxpc-bucket2-verify.md`;
- `/Users/me/wip-mach/rmx-explorer/findings/mx-a64z/dtrace/xpc-conformance/libxpc-macos-exports.txt`.

Expected export-list SHA-256:
`5537e7bd1658a7c094b0515ef95accb9f98ad50cf464d4b8d8b424e057882d99`.
Reproduce the hash and absence of both exact public symbol names. The historical “four symbols”
census was corrected: `_xpc_object_validate` and `_xpc_unreachable` are legitimate internal
helpers and are strictly excluded.

## EXACT EDIT

### `lib/libxpc/xpc/debug.h`

- Remove the complete documentation comment and declaration for
  `xpc_debugger_api_misuse_info`.
- Retain the installed `debug.h` path and its include guard even if the header becomes otherwise
  empty; do not remove it from the header install list or the umbrella include.

### `lib/libxpc/xpc/xpc.h`

- Remove the complete `#if XPC_HOSTING_OLD_MAIN` … `#endif` block containing
  `xpc_service_event_handler_t` and `xpc_service_main`.
- Preserve the adjacent working `xpc_main` declaration and the Transactions section unchanged.

No other source, header, build, export-map, install-list, macro, comment, or formatting cleanup is
part of this op. In particular, leave `XPC_HOSTING_OLD_MAIN` in `xpc/base.h` untouched; removing an
unused compatibility macro requires its own census.

## VERIFICATION

1. Run `git diff --check` and prove the diff contains exactly the two named header paths.
2. Re-run the full-product symbol census. Both public names must be absent; underscore helpers
   remain present and unchanged.
3. Recompute the pinned macOS export-list hash and reconfirm both names absent.
4. Build libxpc with the established FreeBSD procedure into the op-295 build directory. Report the
   exact command, target, exit status, output library paths, sizes, and SHA-256 values.
5. Compile a positive C header consumer that includes both `<xpc/xpc.h>` and `<xpc/debug.h>`.
6. Compile fail-closed negative consumers under C11 with implicit declarations treated as errors:
   - referencing/calling `xpc_debugger_api_misuse_info` must fail as undeclared;
   - with `XPC_SERVICE_MAIN_IN_LIBXPC=1`, referencing/calling `xpc_service_main` and naming
     `xpc_service_event_handler_t` must fail as undeclared/unknown.
   Record commands, diagnostics, and expected nonzero exits. A failure caused by missing unrelated
   headers/libraries does not count.
7. Confirm `nm` still exports neither public symbol from the rebuilt shared/static libraries.
8. Run full-repository `git status --short --branch` before committing and after committing.

Passing markers must distinguish expected negative-compile exits from task failure.

## DELIVERABLE

Only after every check passes, create one focused local product commit containing exactly:

- `lib/libxpc/xpc/debug.h`;
- `lib/libxpc/xpc/xpc.h`.

Suggested subject: `libxpc: align public header surface with macOS`

Do not push. Return:

- base/origin/result commit SHAs and final full status;
- complete diff and `git diff --check` result;
- product/source/export-list census commands and results;
- build command, target, exit, artifact paths/sizes/hashes;
- positive and negative header-consumer sources, commands, diagnostics, and exits;
- rebuilt-library `nm` results; and
- the markers below.

## BOUNDARIES

- Header-surface cleanup only; no runtime implementation or behavior change.
- Do not implement either removed function, delete `debug.h`, remove its install/umbrella include,
  alter `XPC_HOSTING_OLD_MAIN`, or edit export maps/build infrastructure.
- Do not touch `xpc_main`, connection/reply/lifecycle code, id-029, op-285/op-291, container
  ownership, serialization, `dispatch_activate`, Swift, or Zig.
- Do not boot a guest, run Gatekeeper/Explorer harnesses, or claim libxpc/preview readiness.
- Do not push. A local commit cannot retire until independently gated and origin-reachable.

## VERDICT

- `DONE <commit>` — exact two-header change committed and every commissioned check passed.
- `BLOCKED <reason>` — identity drift, extra dirt, truth mismatch, build/check failure, or required
  work outside the boundary. Preserve evidence and stop.

## MARKERS

`IMPL_OP295_BASE_IDENTITY`

`IMPL_OP295_TRUTH_INPUTS`

`IMPL_OP295_HEADER_DIFF`

`IMPL_OP295_POSITIVE_CONSUMER`

`IMPL_OP295_NEGATIVE_CONSUMERS`

`IMPL_OP295_BUILD`

`IMPL_OP295_COMMIT`

`IMPL_OP295_TERMINAL`

## RELATIONS

id-031 / op-167 / op-135 / li-1005 / li-007 / li-1011 bucket 2 / li-1008.

feedback: `verify_signature_divergence_claims`, `agent_host_isolation`,
`build_is_implementer`, `artifact_identity_needs_content_check`,
`no_conflate_gating_with_readiness`, `op_state_dispatch_boundary`.
