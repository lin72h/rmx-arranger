# op-278 — Implementer: compile out Darwin-only launchd exit-detail tests on FreeBSD

op-278 | role: **Implementer** (sole product writer) | EXU: **wip-gpt / wip-rmxos** | state: **[Retired — Arranger2 S-gate accepted commit `7291ad2a722b65661ff096ef09357b8756eb108f` first-hand; Coordinator-authorized fast-forward made it reachable from `origin/alpha` on 2026-07-11; no blockers remain, so it leaves the live ROB]** | parent: **id-016** (bootstrap/launchd) | L1i: **li-008** (launchd core service) | authored: **2026-07-07; normalized/retired 2026-07-11 by Arranger2**

## DISPATCH BOUNDARY

DISPATCHED to the Implementer only. Edit and build in
`/Users/me/wip-mach/wip-gpt/wip-rmxos/`. This op authorizes no Arranger, Gatekeeper, Oracle, or
Explorer repository write and no product push.

## OBJECTIVE

On FreeBSD, prevent launchd from interpreting bits in `kevent.data`'s wait status as Darwin-only
`NOTE_EXIT_DECRYPTFAIL` or `NOTE_EXIT_MEMORY` flags. Preserve Darwin behavior and leave the normal
`NOTE_EXIT` reap path unconditional.

## REQUIRED BASE CHECK

- Product repo: `/Users/me/wip-mach/wip-gpt/wip-rmxos/`
- Expected branch/base at dispatch: `alpha@778cb07442e61cdd8fb3e766b91676f2e9a261b8`
- Expected initial tree: clean, `alpha` one commit ahead of `origin/alpha`.
- Run full-repository `git status --short --branch` and verify HEAD before editing. If branch, HEAD,
  or cleanliness differs, stop and return the exact discrepancy; do not overwrite or absorb another
  op's work.

## VERIFIED DEFECT

At the required base, `sbin/launchd/core.c:4203-4212` has:

- an outer `if (fflags & NOTE_EXIT)`;
- unguarded tests of `kev->data & NOTE_EXIT_DECRYPTFAIL` and
  `kev->data & NOTE_EXIT_MEMORY`, setting `j->fpfail` or `j->jettisoned`; and
- unconditional `job_reap(j)` immediately afterward.

`sbin/launchd/Makefile:45` defines those Darwin constants as bits 16 and 17 for donor-source
compilation. FreeBSD supplies an unmasked wait status in `kevent.data` for `NOTE_EXIT`; those bits
are not Darwin exit-detail hints there. Large exit values can therefore produce false FairPlay or
memory-pressure state and logs. Restart selection remains outside this defect and is not part of
this op.

## EXACT EDIT

Edit only `sbin/launchd/core.c`:

1. Inside `if (fflags & NOTE_EXIT)`, wrap the complete
   `NOTE_EXIT_DECRYPTFAIL` / `NOTE_EXIT_MEMORY` `if`–`else if` block in:

   `#if !defined(__FreeBSD__)`

   `#endif`

2. Keep the outer `NOTE_EXIT` condition, `job_reap(j)`, and every line below the guarded block
   unconditional and otherwise unchanged.
3. Preserve the existing Darwin branch byte-for-byte except for the added guard.
4. Do not edit `sbin/launchd/Makefile`; its `NOTE_*` compatibility definitions are outside this
   fix.

Expected shape:

```c
if (fflags & NOTE_EXIT) {
#if !defined(__FreeBSD__)
        if (kev->data & NOTE_EXIT_DECRYPTFAIL) {
                ...existing body...
        } else if (kev->data & NOTE_EXIT_MEMORY) {
                ...existing body...
        }
#endif

        job_reap(j);
        ...existing path...
}
```

Follow the file's existing formatting; do not mechanically replace the illustrative indentation.

## BUILD AND SELF-CHECK

1. Run `git diff --check`.
2. Build the launchd target with the repository's existing FreeBSD build procedure. Report the
   exact command, environment/target, exit code, output binary path, size, and SHA-256.
3. Show the focused diff and confirm only `sbin/launchd/core.c` changed.
4. Confirm preprocessing on the FreeBSD target excludes both assignments while retaining the call
   to `job_reap(j)`. Source/preprocessor evidence is sufficient; no guest or soak is commissioned.
5. Re-run full-repository `git status --short --branch`.

## DELIVERABLE

After the edit and successful build, create one focused local product commit containing only
`sbin/launchd/core.c`. Do not push. Return:

- base and resulting commit SHA, parent SHA, and subject;
- exact changed span/diff;
- build command, target, exit code, binary path, size, and SHA-256;
- FreeBSD exclusion / unconditional-`job_reap` evidence;
- full final repository status; and
- the markers below.

## BOUNDARIES

- Exactly one source guard in `sbin/launchd/core.c`; no refactor or adjacent cleanup.
- Do not touch `Makefile`, `job_reap`, wait-status interpretation, KeepAlive/restart policy,
  `waitpid_loop`, or op-264 Finding A. Finding A belongs to op-279→op-280.
- Do not run or modify Gatekeeper harnesses, images, or runtime evidence.
- Do not push. A local product commit cannot retire until separately verified and made reachable
  from the relevant origin branch.
- Building proves compile/link only; it does not establish runtime or milestone readiness.

## VERDICT

- `DONE <commit>` — exact guard landed, launchd built successfully, focused local commit created.
- `BLOCKED <reason>` — base mismatch, unrelated dirt, build failure, or inability to prove the
  FreeBSD exclusion. Preserve all evidence and do not expand scope.

## MARKERS

`IMPL_OP278_BASE_IDENTITY`

`IMPL_OP278_GUARD`

`IMPL_OP278_BUILD`

`IMPL_OP278_COMMIT`

`IMPL_OP278_TERMINAL`

## RELATIONS

op-264 Finding B (source finding this resolves) / op-279 (separate Gatekeeper evidence gate for
Finding A) / op-280 (held Finding-A fix) / id-016 / li-008.

feedback: `oss_engineering_framing`, `build_is_implementer`,
`verify_signature_divergence_claims`, `no_conflate_gating_with_readiness`,
`agent_host_isolation`, `op_state_dispatch_boundary`.
