# Codex Implementation Review and Feedback

Date: 2026-04-17
Reviewer: Claude (wip-claude)

## What Codex Has Done Well

Credit where it's due. Codex has executed the following correctly:

1. **Branch topology.** `stable/15`, `main`, `snapshot/pre-review`,
   `donor/full-import`, and `milestone/g2-minimal` all exist with correct
   roles. This matches the doctrine exactly.

2. **Two-lane separation.** The supported lane (`milestone/g2-minimal`)
   and the preserved donor lane (`donor/full-import`) are physically
   separate. g2-minimal exposes only `mach_timebase_info` (20 files,
   607 insertions). `donor/full-import` has the full 413-file, 118K-line
   import. No cross-contamination.

3. **Harness infrastructure.** `stage-guest.sh` is well-engineered:
   objdir auto-detection with ambiguity rejection, build provenance in
   JSON, modular environment variables. `run-guest.sh` captures serial
   output via tee. `parse-characterize.py` separates measurement from
   supported-lane parsing. `collect-crash.sh` exists as a skeleton.

4. **Characterization probe quality.** `nxplatform-mach-probe.c` is
   well-structured: per-batch case tables, fflush after each line,
   wall-clock timing, classification logic, JSON structured output.
   Properly handles dependencies between probe steps (saved port names
   for lifecycle sequences).

5. **Documentation discipline.** Finding docs (r6a, r6b, r6c), runtime
   status tracking, trap classification, roadmap, doctrine, review
   checklist -- all maintained and cross-referenced.

6. **Incremental characterization.** R6A → R6B → R6C progression was
   methodical: unsupported traps first, then zero-object real
   implementations, then identity traps, then mutating port lifecycle.
   Correct ordering by risk.

## What Codex Is Missing

These are gaps between what we discussed extensively in design review
and what actually exists in wip-gpt.

### Critical Gap 1: The double-unlock bug is not identified

The R6C findings doc (`r6c-port-basics-findings.md`) correctly records
the panic and calls it a stop boundary, but does NOT identify the root
cause. It says:

> the preserved donor lane is not stable enough for broader mutating
> port sweeps without a stronger crash/debug lane

This is too conservative. The actual root cause is a **specific,
fixable double-unlock bug** in `ipc_right_destroy` (ipc_right.c lines
614, 660, 668). `ipc_entry_dealloc` already unlocks the IPC space,
but `ipc_right_destroy` unlocks it again. Every other caller of
`ipc_entry_dealloc` in the same file was correctly updated; only
`ipc_right_destroy` was missed.

**Action:** Fix the 3 double-unlock sites. Rebuild. Re-run R6C. This
should unblock the entire port lifecycle characterization path.

See `wip-claude/r6c-blocker-review.md` for the full analysis.

### Critical Gap 2: No FreeBSD 12→15 API delta analysis

We discussed this extensively in the previous session. The NextBSD code
was written for FreeBSD 12. FreeBSD 15 has changed:

- **Locking:** `PROC_SLOCK`/`PROC_SUNLOCK` removed (replaced by
  different synchronization). Used in `mach_thread.c:68,80`.
- **UMA zones:** API signature changes in `uma_zcreate`. The Mach code
  uses a `zinit` macro wrapper (std_types.h:138) that may need updating.
- **Process structures:** `p_fd` access patterns changed. The Mach
  `ipc_entry.c` uses `p->p_fd`, `fdp->fd_ofiles`, `fdlastfile_single`
  extensively for the file-descriptor integration.
- **VM map APIs:** `vm_map_lock`/`vm_map_unlock` semantics may have
  changed. Used in `mach_vm.c` (10 occurrences).
- **kmem_alloc/kmem_free:** Used in `mach_debug.c`, `mach_port.c`.
  FreeBSD 15 may have different signatures.
- **`msleep` with `p_mtx`:** Used in `mach_clock.c:90`.

Three research agents completed this analysis but the results were
never synthesized into a document. The draft belongs at
`wip-claude/freebsd-12-15-delta.md` or should be absorbed into
Codex's docs.

**Action:** The API delta needs to be a tracked document. When Codex
starts fixing code (beyond the double-unlock), it needs this map to
avoid silent runtime bugs from API changes that compile but behave
differently.

### Gap 3: No CLAUDE.md / agent instructions in wip-gpt

Codex has no `CLAUDE.md` in the wip-gpt repo. This means every new
Codex session starts with zero context about:

- The two-lane architecture
- The merge-not-rebase rule
- The `donor/full-import` is preserved, not supported
- The commit conventions (provenance footers)
- The bhyve harness workflow
- What not to touch (supported lane is g2-minimal only)

**Action:** Create a `CLAUDE.md` at the root of wip-gpt with the
essential rules. Keep it under 100 lines. It should cover:

1. Branch roles and which branch to work on
2. Merge-not-rebase rule for the FreeBSD repo
3. Two-lane separation (supported vs preserved)
4. Build commands for kernel and module
5. Stage/run/parse workflow for bhyve
6. Commit message conventions
7. What is currently blocked (R6C double-unlock)
8. Pointer to docs/ for detailed plans

### Gap 4: stage-guest.sh lacks fsck and dump plumbing

We identified two concrete issues:

1. **No fsck before mount.** After a guest panic, the root filesystem
   is dirty. `stage-guest.sh` mounts it rw without checking. Repeated
   panics accumulate corruption.

   Fix: add `doas fsck -p "$root_part" || true` before the mount.

2. **No crash dump configuration.** Guest `rc.conf` has no `dumpdev`,
   `dumpon_flags`, or `savecore_enable`. After a panic, no vmcore is
   saved. For mutating-port work, crash dumps are needed for diagnosis.

   Fix: append dump configuration to guest `rc.conf` during staging.

3. **No disposable image workflow.** The same `nxplatform-dev.img` is
   mutated in place for every run. This is acceptable short-term with
   fsck, but should eventually support per-run copies for crash-heavy
   characterization.

### Gap 5: R3 commit normalization not started

The `donor/full-import` branch has exactly ONE commit on top of
`stable/15`:

```
c703e4c32a41 mach: preserve pre-review broad import snapshot
```

That's 413 files in a single commit. The `full-import-commit-plan.md`
describes a 6-commit normalization series, but it hasn't been executed.
The plan doc itself says "recommended series" but has no execution
timeline.

This is not urgent (runtime evidence > git hygiene, as we agreed), but
it should stay on the backlog.

### Gap 6: collect-crash.sh is a skeleton

The script exists but is minimal:

```sh
doas mkdir -p "${crash_dest}"
doas cp -R "${crash_source}/." "${crash_dest}/"
```

It requires `NXPLATFORM_CRASH_SOURCE` to be set manually. It does not:
- Auto-detect guest crash path
- Mount the guest image to extract `/var/crash`
- Associate crash artifacts with the serial log or build provenance
- Run kgdb against the vmcore

This should be improved before the next round of mutating-port work.

### Gap 7: No awareness of wip-claude analysis

The wip-gpt workspace has no reference to the wip-claude deliverables:

- `repo-strategy.md` (wip-claude version is more detailed than Codex's)
- `commit-plan.md` (wip-claude has exact file lists, commit messages,
  and execution instructions; Codex's is a summary)
- `phase1-runtime-testing.md` (wip-claude has 35 test cases with
  JSON output format; Codex's `full-import-runtime-testing.md` is a
  high-level outline)
- `r6c-blocker-review.md` (root cause analysis Codex doesn't have)

**Action:** The key deliverable to push to Codex immediately is the
R6C root cause. Either copy `r6c-blocker-review.md` into wip-gpt/docs
or extract the essential fix instructions into a short note Codex can
act on.

### Gap 8: The `swtch` panic is uninvestigated

R6A found that `swtch` panics under trivial input. The finding is
recorded, and `swtch` is correctly excluded from later batches, but
there is no investigation of the root cause. The R6A doc says:

> the donor `swtch` path is not safe even under single-process,
> no-contention, trivial-input characterization

But doesn't dig into why. We confirmed in this session that the `swtch`
panic (user-mode page fault, process `sh`) is independent from the
`mach_port_destroy` panic (kernel-mode page fault, `__rw_wunlock_hard`).
They are separate bugs.

This is lower priority than the double-unlock fix, but should be
tracked.

## Prioritized Action List for Codex

In order of execution:

### Immediate (next session)

1. **Fix the double-unlock in `ipc_right_destroy`.** Delete
   `is_write_unlock(space);` at lines 614, 660, and 668 of
   `sys/compat/mach/ipc/ipc_right.c`. These are the three lines
   immediately following calls to `ipc_entry_dealloc`.

2. **Add fsck before mount in `stage-guest.sh`.** After `root_part`
   is discovered and before `mount -o rw`:
   ```sh
   doas fsck -p "$root_part" || true
   ```

3. **Rebuild kernel + module. Re-run R6C.** Expected: all 6 port
   operations pass.

4. **Update `r6c-port-basics-findings.md`** with the root cause and
   fix result.

### Short-term (next 2-3 sessions)

5. **Create `CLAUDE.md`** at wip-gpt root with essential agent
   instructions.

6. **Add guest dump plumbing** to `stage-guest.sh`:
   - `dumpdev="AUTO"`
   - `dumpon_flags="-z"`
   - `savecore_enable="YES"`

7. **Expand port lifecycle probes** now that destroy is unblocked:
   - 1C-1: allocate 1000 ports, deallocate all
   - 1C-2: fork + exit cleanup
   - 1C-3: send right transfer
   - 1C-4: concurrent stress

8. **Improve `collect-crash.sh`** to mount guest image and extract
   `/var/crash` automatically.

### Medium-term

9. **Add INVARIANTS/WITNESS lane** after basic port lifecycle passes.

10. **Synthesize FreeBSD 12→15 API delta** into a tracked document.
    Key areas: PROC_SLOCK removal, UMA zone API, p_fd access,
    kmem_alloc signatures.

11. **R3 commit normalization** of the donor/full-import branch.

12. **Investigate `swtch` panic** root cause (independent from port
    destroy).

## What Codex Should NOT Do

- Do not widen the supported lane (`milestone/g2-minimal`). It stays at
  `mach_timebase_info` only until the port lifecycle is proven.
- Do not attempt broader port/right sweeps before the double-unlock fix
  is confirmed.
- Do not rebase any published branch.
- Do not hand-resolve `syscalls.master` conflicts. Regenerate.
- Do not treat passing characterization results as supported-lane
  promotion. Promotion requires the full review-checklist gates.
- Do not merge donor/full-import into main. They are separate lanes.
