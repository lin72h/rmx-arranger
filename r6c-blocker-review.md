# R6C Blocker Review: Port Destroy Panic and Next-Step Strategy

Date: 2026-04-17

Reviewer: Claude (wip-claude)

Scope: narrow review of the current blocker, VM/debug workflow, and
immediate next steps. Not a broad project restatement.

## 1. Overall Verdict

The R6C panic has a specific, identifiable root cause. It is not a
mysterious corruption or a deep architectural problem. It is a
**double-unlock bug in `ipc_right_destroy`** introduced during the
NextBSD file-descriptor integration of Mach IPC entries.

This changes the tactical picture significantly. The previous advice
to run isolation experiments was sound given the information available
at that time, but the code analysis now provides a stronger signal than
black-box probing would. The isolation experiments would have confirmed
the diagnosis (allocate → destroy would also crash, because the bug is
in the destroy path itself, independent of port sets), but the code
tells us this directly.

The VM/debug workflow concerns you raised are real but are **not the
current blocker**. The current blocker is a known code bug.

## 2. What the Strongest Signal Actually Is

### The double-unlock in `ipc_right_destroy`

`ipc_entry_dealloc` in this codebase **already unlocks the IPC space
write lock** before returning. Its own comment says so:

```
ipc_entry.c:655-656:
 *  Conditions:
 *      The space must be write-locked.
 *      The space is unlocked on return.
```

The implementation confirms it. In `ipc_entry_dealloc` (ipc_entry.c:660-683):

```c
void
ipc_entry_dealloc(ipc_space_t space, mach_port_name_t name,
    ipc_entry_t entry)
{
    ...
    if (space != entry->ie_space) {
        is_write_unlock(entry->ie_space);
    } else {
        is_write_unlock(space);       // ← unlocks space
    }
    ...
    ipc_entry_close(space, name);     // ← closes file descriptor
}
```

But `ipc_right_destroy` (ipc_right.c:597-713) calls `ipc_entry_dealloc`
and then **immediately unlocks the space again**:

```c
// DEAD_NAME case (line 613-614):
ipc_entry_dealloc(space, name, entry);
is_write_unlock(space);                   // DOUBLE UNLOCK

// inactive port case (line 659-660):
ipc_entry_dealloc(space, name, entry);
is_write_unlock(space);                   // DOUBLE UNLOCK

// active port case (line 667-668):
ipc_entry_dealloc(space, name, entry);
is_write_unlock(space);                   // DOUBLE UNLOCK
```

There are **exactly 3 double-unlock sites**, all in `ipc_right_destroy`.

### Cross-check: every other caller is correct

Every other caller of `ipc_entry_dealloc` in ipc_right.c does NOT
follow it with `is_write_unlock`:

- Line 752: correct (no unlock after dealloc)
- Line 779: correct
- Line 833: correct
- Line 1024: correct
- Line 1071: correct
- Line 1108: correct
- Line 1179: correct
- Line 2083: correct

Only `ipc_right_destroy` has the bug. The other callers were correctly
updated when `ipc_entry_dealloc` was changed to unlock internally. The
`ipc_right_destroy` function was missed.

### Why this causes the observed panic

The crash signature is:

```
Fatal trap 12: page fault while in kernel mode
fault virtual address = 0x30
backtrace:
  __rw_wunlock_hard+0x87
  ipc_right_destroy+0x2ae
  mach_port_destroy+0x55
  sys__kernelrpc_mach_port_destroy_trap+0x2d
```

The `struct ipc_space` layout on amd64:

| Offset | Field | Type |
| --- | --- | --- |
| 0x00 | `is_ref_lock_data` | `struct mtx` (24 bytes) |
| 0x18 | `is_references` | `uint32_t` (4 bytes + 4 pad) |
| 0x20 | `is_entry_list` | `LIST_HEAD` (8 bytes) |
| 0x28 | `is_lock_data` | `struct rwlock` |

Inside `struct rwlock`:

| Offset from rwlock | Field |
| --- | --- |
| 0x00 | `lock_object.lo_name` (8 bytes) |
| 0x08 | `lock_object.lo_flags` (4 bytes) |
| ... | ... |

When `is_write_unlock(space)` expands to `rw_wunlock(&space->is_lock_data)`,
the lock argument is at `space + 0x28`. The `lo_flags` field within that
lock is at `space + 0x28 + 0x08 = space + 0x30`.

The sequence:

1. First `is_write_unlock` (inside `ipc_entry_dealloc`): succeeds,
   releases the write lock normally.
2. `ipc_entry_close` runs, closes the file descriptor, may trigger
   further cleanup.
3. Second `is_write_unlock` (in `ipc_right_destroy`): the rwlock is
   already in `RW_UNLOCKED` state. The inline fast path in `rw_wunlock`
   fails (the lock word doesn't match the expected write-held pattern).
   FreeBSD calls `__rw_wunlock_hard`.
4. Inside `__rw_wunlock_hard`, the code attempts to manipulate the
   lock's internal state. With the lock in an unexpected state (already
   unlocked, possibly with the lock word corrupted by a concurrent
   re-acquisition between the two unlocks), it dereferences through
   a pointer that resolves to virtual address 0x30.
5. Page fault. Kernel panic.

### The PORT_SET path is NOT affected

The `MACH_PORT_TYPE_PORT_SET` case in `ipc_right_destroy` (line 617-633)
does NOT call `ipc_entry_dealloc`. It calls `is_write_unlock(space)`
directly, then calls `ipc_entry_close` separately. No double-unlock.

This means the crash is on step 5 of the probe (destroying the receive
right), not step 6 (destroying the port set). The port set is a red
herring for diagnosis purposes.

### Why earlier probes succeeded

- Identity traps (`task_self_trap`, etc.): these return port names but
  never call `ipc_entry_dealloc`. No double-unlock.
- Port allocation: creates entries, never deallocs. No double-unlock.
- Insert/extract member: manipulates port sets, does not dealloc entries.
  No double-unlock.
- Only port/right **destruction** hits `ipc_entry_dealloc` through
  `ipc_right_destroy`.

### How this was introduced

In classic OSF/CMU Mach, `ipc_entry_dealloc` just freed the entry from
the table. It did NOT unlock the space. Callers were responsible for
unlocking.

In the NextBSD port, Matthew Macy integrated Mach IPC entries with
FreeBSD's file descriptor table. This required changing the locking
discipline: `ipc_entry_dealloc` now needs to unlock the space before
calling into the file descriptor layer (because `kern_close` /
`fdrop` have their own locking requirements that conflict with holding
the space write lock).

Most callers were correctly updated to stop unlocking after
`ipc_entry_dealloc`. `ipc_right_destroy` was not. This is a
straightforward porting oversight.

## 3. Biggest Risk of Misdiagnosis

**Treating this as a corruption mystery when it is a mechanical bug.**

Without the code analysis, the isolation experiments would have
shown "allocate → destroy crashes" and "port sets don't matter." That's
useful but doesn't identify the fix. With the code analysis, the root
cause is specific and the fix is mechanical.

The second risk is **confusing the `swtch` panic with this one.** They
are independent faults:

- `swtch` (R6A): user-mode page fault, current process `sh`, different
  crash signature entirely. This is a separate bug, likely in the
  `swtch` trap's interaction with the FreeBSD scheduler or a stale
  thread-pointer dereference.
- `mach_port_destroy` (R6C): kernel-mode page fault in the IPC locking
  path. Caused by double-unlock. Completely independent.

Do not assume they share a root cause.

## 4. Best Next-Step Sequence

Ranked in the order I recommend executing them:

### Tier 1: Fix the known bug (1 session)

1. **Remove the 3 double-unlock sites in `ipc_right_destroy`.**

   Delete the `is_write_unlock(space);` at lines 614, 660, and 668 of
   `ipc_right.c`. These are the lines immediately after calls to
   `ipc_entry_dealloc`.

   Do NOT change the PORT_SET path (line 624) or any other unlock site
   in the function - those are correct.

2. **Audit all other callers of `ipc_entry_dealloc` in the tree.**

   Verify no other file has the same double-unlock pattern. Grep for
   `ipc_entry_dealloc` followed by `is_write_unlock` in:
   - `ipc_right.c` (confirmed: only `ipc_right_destroy` has the bug)
   - `mach_port.c`
   - `ipc_object.c`
   - Any other file that calls `ipc_entry_dealloc`

3. **Rebuild the donor-lane kernel and module.**

4. **Re-run R6C batch3 (port basics).** The exact same probe sequence
   should now complete without panic.

### Tier 2: VM workflow hardening (1 session)

5. **Add `fsck -p` before host-side mount in `stage-guest.sh`.**

   After `mdconfig` and partition discovery, before `mount -o rw`:

   ```sh
   doas fsck -p "$root_part" || true
   ```

   This is a 2-line fix. It prevents dirty-image accumulation from
   repeated panic runs.

6. **Add guest dump configuration to `stage-guest.sh`.**

   Append to `rc.conf`:
   ```
   dumpdev="AUTO"
   dumpon_flags="-z"
   savecore_enable="YES"
   ```

   This enables compressed minidumps. With `-z` compression, a 2G
   minidump typically compresses to 200-400MB, well within 1G swap for
   most cases. If swap proves too small, lower guest RAM to 4G (not 2G -
   you still want realistic kernel behavior).

7. **Add crash collection to the run cycle.**

   After `run-guest.sh` exits with a panic, mount the image and copy
   `/var/crash` contents. This could be a post-run step in
   `collect-crash.sh` or a wrapper script.

### Tier 3: Expand characterization (2-3 sessions)

8. **Re-run R6C with the fix applied.** Confirm allocate, insert, extract,
   destroy all pass.

9. **Run the broader port lifecycle tests from phase1-runtime-testing.md:**
   - Allocate 1000 receive rights, deallocate all
   - Fork+exit cleanup
   - Send right transfer
   - Concurrent allocation stress

10. **Add INVARIANTS/WITNESS lane** after the basic port lifecycle passes.
    Not before.

### Tier 4: Deferred

11. Per-run disposable images (not needed yet; fsck is sufficient)
12. R3 commit normalization
13. `swtch` investigation (independent bug, lower priority)
14. Non-mutating characterization of remaining trap classes

## 5. Minimum Crash-Debug Infrastructure

For the immediate next step (fixing the double-unlock and re-running
R6C), you need:

| Item | Required? | Why |
| --- | --- | --- |
| `fsck -p` before mount | Yes | Prevents dirty accumulation from panics |
| `dumpdev="AUTO"` | Not yet | Fix first; dumps needed for harder bugs |
| `dumpon_flags="-z"` | Not yet | Same |
| Lower guest RAM | No | 8G is fine with compressed dumps |
| Larger swap | No | `-z` compression makes 1G sufficient |
| Dedicated debug image | No | Current image is fine with fsck |
| Disposable per-run images | No | Overkill for this stage |
| `savecore` collection | Not yet | Add in Tier 2 |

If the fix works and R6C passes, add dump plumbing in Tier 2 before
doing the broader lifecycle tests. You will need crash dumps for the
harder bugs that lifecycle testing will surface.

## 6. What to Defer

- **Broader port/right sweeps.** Do not run wider characterization until
  the double-unlock fix is confirmed.
- **INVARIANTS/WITNESS.** Do not add debug kernel options until the basic
  port lifecycle passes clean. WITNESS will find lock-order issues, but
  you first need the lock operations to be correct at all.
- **Disposable per-run images.** fsck before mount is sufficient for now.
  Disposable images add workflow complexity without proportional benefit
  at this stage.
- **R3 commit normalization.** Still lower priority than runtime evidence.
  The double-unlock fix should be committed on `donor/full-import` (it is
  a characterization fix, not a supported-lane change).
- **`swtch` investigation.** Independent bug, different crash signature,
  lower priority than the port lifecycle path.
- **Non-mutating characterization of other trap classes.** Reasonable to
  do in parallel, but the port destroy fix is the dominant priority.

## 7. Open Assumptions

1. **The struct layout analysis assumes no WITNESS.** The current
   `MACHDEBUG` kernel does not include WITNESS. If WITNESS is enabled,
   `struct lock_object` grows (adds a `lo_witness` pointer), shifting
   all offsets. This doesn't affect the double-unlock diagnosis but
   would change the offset math for future crash analysis under a
   WITNESS kernel.

2. **The probe lost its output due to serial timing.** The serial log
   shows no characterize records between provenance and the panic. I
   believe the earlier syscalls (allocate, insert, extract) succeeded
   and produced output, but the serial UART hadn't finished transmitting
   those lines before the kernel panic overwrote the console. This is
   consistent with the backtrace showing `mach_port_destroy` (not
   `mach_port_allocate`). The fix-and-rerun will confirm whether the
   earlier operations actually work.

3. **`ipc_entry_dealloc` correctly unlocks in all code paths.** I
   verified the normal path where `space == entry->ie_space`. If there
   are edge cases where `space != entry->ie_space` (the "redirect"
   path at line 670-673), the locking behavior is different (unlock
   space, lock entry->ie_space, unlock entry->ie_space). The
   double-unlock bug exists in both cases, because `ipc_right_destroy`
   always does `is_write_unlock(space)` after `ipc_entry_dealloc`,
   regardless of which internal path `ipc_entry_dealloc` took.

4. **The fix is removal, not addition.** The correct fix is deleting
   three lines. No new locking logic is needed. The space was already
   unlocked by `ipc_entry_dealloc`; the callers just need to stop
   unlocking it again.

5. **The PORT_SET destroy path has separate issues we haven't tested.**
   The PORT_SET path (line 617-633) unlocks the space, then calls
   `ipc_entry_close` with the space unlocked. This is probably correct,
   but it hasn't been tested in isolation because the R6C probe panicked
   before reaching step 6 (destroy pset). After the double-unlock fix,
   re-running R6C will test this path.

## Answers to Your Specific Questions

### Q1: Does the VM/debug workflow change previous advice?

Partly. The code analysis supersedes the need for the isolation
experiments as a diagnostic tool. The isolation experiments would have
confirmed what the code already tells us. Fix the code first, then
harden the VM workflow.

### Q2: Ranked next steps

1. Fix the 3 double-unlock sites in `ipc_right_destroy`
2. Rebuild kernel/module
3. fsck before mount in `stage-guest.sh`
4. Re-run R6C batch3
5. Add guest dump plumbing (`dumpdev`, `savecore`)
6. Run broader port lifecycle tests
7. Add INVARIANTS/WITNESS lane
8. Inspect remaining code paths after lifecycle evidence

### Q3: Minimum crash-debug baseline

For the immediate re-run: just fsck before mount. No dumps needed.

For the broader lifecycle tests (Tier 2 onward):
- `dumpdev="AUTO"` in guest `rc.conf`
- `dumpon_flags="-z"` for compressed minidumps
- `savecore_enable="YES"`
- Guest RAM at 8G (current default) is fine with compression
- 1G swap is fine with `-z`
- Automatic `collect-crash.sh` integration after panic runs

### Q4: Do dirty-rootfs warnings weaken R6C trust?

No. The backtrace through `ipc_right_destroy → __rw_wunlock_hard` is
deterministic kernel state captured at the instant of the fault. It
does not depend on filesystem cleanliness. The dirty-rootfs warnings
affect guest boot behavior (deferred fsck, growfs refusal) but cannot
cause or influence a kernel lock operation.

The R6C finding stands cleanly.

### Q5: Disposable images vs fsck?

fsck before mount is sufficient for the next several rounds. Switch to
disposable images only if you start doing high-frequency crash runs
(10+ per session) where cumulative image mutation becomes a workflow
concern.

### Q6: Still recommend isolation experiments?

No longer necessary. The code analysis identifies the root cause more
precisely than isolation experiments would. The "fix and re-run" approach
is now the right next step.

If you want to be cautious, you could run the simplest isolation
(allocate → destroy only) BEFORE applying the fix, to confirm the crash
reproduces without port sets. But this is optional confirmation, not a
required diagnostic step.

### Q7: Granularity for future mutating-port probes?

After the fix: return to small batches. The R6C batch (6 operations) is
a reasonable size. One-trap-per-boot is unnecessarily slow now that the
double-unlock is identified and fixed.

### Q8: INVARIANTS/WITNESS before or after isolation?

After. Fix the double-unlock first, confirm the basic port lifecycle
passes, then add INVARIANTS/WITNESS. Running WITNESS on known-broken
code produces noise that obscures the real lock-order findings you want.

### Q9: Required evidence for next mutating-port panic

If the fix works and R6C passes, the next panic (from lifecycle tests)
should capture:
- Serial log with trap-start markers (existing harness provides this)
- `savecore` vmcore from guest `/var/crash`
- `info.N` crash metadata
- kgdb backtrace from the vmcore against the MACHDEBUG kernel with debug symbols
- Build provenance (existing harness provides this)
- Guest image fsck status before staging

### Q10: What to avoid

- **Do not run broader port/right sweeps** until the fix is confirmed.
- **Do not fix `swtch` at the same time.** It is independent. One bug
  at a time.
- **Do not add WITNESS before the fix.** It will just add noise.
- **Do not use the shared image without fsck.** Add the fsck line now.
- **Do not treat the double-unlock as a "characterization finding."**
  It is a known bug with a known fix. Apply the fix on `donor/full-import`.
  This is characterization infrastructure, not a supported-lane change.
- **Do not jump to broader R7 lifecycle work** until R6C re-passes.

### Q11: Does this change the roadmap?

No. The roadmap is unchanged:
- Preserved donor-lane characterization first (R6 continues)
- Stronger crash/debug lane for harder lifecycle work (Tier 2)
- Supported lane unchanged (milestone/g2-minimal is separate)

The double-unlock fix is a donor-lane correction, not a roadmap event.
It moves R6C from "stop boundary" to "re-testable," which is exactly
the expected characterization workflow: find bug, fix bug, advance.

### Q12: Exact sequence for next 1-2 sessions

**Session 1:**

1. Apply the 3-line fix to `ipc_right.c` on `donor/full-import`
2. Audit all other callers of `ipc_entry_dealloc` in the tree (I
   expect no other instances, but verify)
3. Add `fsck -p` before mount in `stage-guest.sh`
4. Rebuild kernel + module in `donor-full-import-obj`
5. Stage and boot guest
6. Re-run R6C batch3 (port basics)
7. Expected result: all 6 operations pass, no panic
8. Commit the fix on `donor/full-import`
9. Update `r6c-port-basics-findings.md` with the fix and new result
10. Update `full-import-runtime-status.md`

**Session 2:**

1. Add guest dump plumbing to `stage-guest.sh` (dumpdev, savecore)
2. Write broader port lifecycle probes (from phase1-runtime-testing.md
   Stage 1C tests: 1C-1 through 1C-5)
3. Run them one at a time on the fixed donor lane
4. Record results
5. If all pass: plan the INVARIANTS/WITNESS lane for Session 3

## Appendix: The Fix

In `sys/compat/mach/ipc/ipc_right.c`, delete 3 lines:

```diff
     case MACH_PORT_TYPE_DEAD_NAME:
         assert(entry->ie_request == 0);
         assert(entry->ie_object == IO_NULL);

         ipc_entry_dealloc(space, name, entry);
-        is_write_unlock(space);
         break;
```

```diff
         ip_unlock(port);
         ip_release(port);

         entry->ie_request = 0;
         OBJECT_CLEAR(entry, name);
         ipc_entry_dealloc(space, name, entry);
-        is_write_unlock(space);
         break;
```

```diff
     dnrequest = ipc_right_dncancel_macro(space, port, name, entry);

     OBJECT_CLEAR(entry, name);
     ipc_entry_dealloc(space, name, entry);
-    is_write_unlock(space);
```

No other changes needed. The space is already unlocked by
`ipc_entry_dealloc`.
