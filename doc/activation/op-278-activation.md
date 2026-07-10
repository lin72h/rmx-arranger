# op-278 — Implementer: fix op-264 Finding B — compile out launchd's two Darwin-only `kev->data` exit-bit tests on FreeBSD (spurious fpfail/jettisoned)

op-278 | role: **Implementer** | EXU: **wip-gpt** | state: **[Awaiting — trivial mechanical fix resolving op-264 Finding B (Arranger-verified first-hand). ONE small guarded edit in `sbin/launchd/core.c`, no behavior change on the working path. Coordinator dispatches.]** | parent id: id-016 (bootstrap/launchd) | L1i: li-008 (launchd core service) | cost: implementer (trivial) | authored 2026-07-07 (Arranger seat, model Opus 4)

## CONTEXT (engineering framing)
Ordinary open-source OS engineering on our own service manager (launchd). rmxOS = Darwin/Mach userland on FreeBSD 15. This is a small correctness cleanup — not security work, no target.

## WHY (one line)
op-264's supervision consult found (Arranger-verified) that launchd tests two **Darwin-only** exit-note bits against `kev->data`, but on FreeBSD `kev->data` on `NOTE_EXIT` carries the **unmasked wait status** — so an ordinary exit code with bit 16/17 set spuriously flips job flags.

## THE DEFECT (verified first-hand in the release base `wip-gpt/wip-rmxos`)
- `Makefile:45` force-defines `NOTE_EXIT_DECRYPTFAIL=0x00010000` (bit 16) and `NOTE_EXIT_MEMORY=0x00020000` (bit 17) — Darwin constants FreeBSD's kernel does not deliver as `NOTE_*` hint bits (`filt_proc` only matches `NOTE_PCTRLMASK` 0xf0000000).
- `core.c:4203-4210` on `NOTE_EXIT` tests `kev->data & NOTE_EXIT_DECRYPTFAIL` (→ `j->fpfail=true`, :4204-4206) and `else if kev->data & NOTE_EXIT_MEMORY` (→ `j->jettisoned=true`, :4207-4209).
- On FreeBSD the kernel puts `KW_EXITCODE(p_xexit, p_xsig)` in `kn_data` and `sys_exit` does NOT mask `rval` — so a job that exits with a status carrying bit 16 or 17 (e.g. large `_exit` codes) sets `fpfail`/`jettisoned` spuriously → log noise ("FairPlay decryption failed" / "killed due to memory pressure") + wrong `LASTEXITSTATUS` export (:1107-1110) + a stale `jettisoned` flag for the run.
- Both flags are Darwin-only concepts (FairPlay decryption; jetsam memory pressure) that do not exist on FreeBSD, so neither should ever be set from `kev->data` here.
- Restart decision itself is UNAFFECTED (`job_keepalive` consumes the properly masked `WIFEXITED`/`WEXITSTATUS`) — this is a flag/logging correctness fix, not a supervision fix.

## SCOPE (the whole change)
1. Guard the two `kev->data` bit tests at `core.c:4203-4210` so they compile out on FreeBSD — wrap the `if (kev->data & NOTE_EXIT_DECRYPTFAIL) {…} else if (kev->data & NOTE_EXIT_MEMORY) {…}` block in `#if !defined(__FreeBSD__)` (leave `job_reap(j)` at :4212 and everything below unconditional). Preferred over deleting so the Darwin lineage stays legible; match the existing `__FreeBSD__` convention already used in this file (e.g. the `execvpe` branch at job_start_child).
2. Do NOT touch the `Makefile:44-45` force-defines (the other two — `NOTE_EXITSTATUS`/`NOTE_EXIT_DETAIL` — are inert per op-264, requested only in fflags; leave them).
3. Build launchd; confirm the guarded block is excluded on FreeBSD and the file still compiles + links. No functional soak needed for this op (that's op-279's separate scope).

## DELIVERABLE
The one-line-guarded diff + a built launchd confirming compile/link on the FreeBSD target. Report the exact edited span and the build result for first-hand Arranger verification (diff read at source).

## BOUNDARIES
- EXACTLY this guard — do NOT refactor the surrounding `job_callback_proc`, do NOT touch Finding A's `waitpid_loop` (that is op-279's runtime-check + a RESERVED separate fix op — pid-1 code, evidence-first).
- Implementer owns the edit + build; the runtime behavior confirmation is op-279 (Gatekeeper), not this op.
- Does not decide milestone placement.

## RELATIONS
op-264 (the supervision consult — this resolves its Finding B; Arranger-verified at `core.c:4203-4210` + `Makefile:45`) / op-279 (Gatekeeper runtime-check for op-264 Finding A — the sibling, higher-stakes resolution) / li-008 (launchd core service) / id-016. feedback: oss_engineering_framing, build_is_implementer, verify_signature_divergence_claims, agent_host_isolation, op_state_dispatch_boundary.
