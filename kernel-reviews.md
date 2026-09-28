# Kernel reviews

Record of review rounds on the Mach kernel integration, and the plan for the next one. The
Coordinator decided this on 2026-09-28 (j-20260928-050). Tracked as id-051; the defects are in id-046.

## Round 1 (2026-09-28): two blind deep dives at alpha2 `2884304b`

| op | Advisor | Model | Result |
|---|---|---|---|
| op-389 | advisor2 | ChatGPT (astra max) | 14 confirmed, 1 suspected; 7 traced first-hand, all held |
| op-392 | advisor1 | Opus 5.5, max effort | 8 confirmed, 6 suspected, 5 design classes; 3 traced first-hand, all held |

Scope, both: `sys/compat/mach/`, its FreeBSD integration, the NextBSD original (FreeBSD 12.0) and
XNU. Findings only, ranked, each with lines on both sides and the smallest confirming check.
op-392 was blind to op-389, and additionally asked for design causes and a reading of the build.

**Overlap:** about 6 problems were found by both (task-port teardown, the missing file operations,
receive inside the kqueue readiness check, entry lifetime, the rfork shared table, and the
standalone `mach.ko` build). About 23 distinct problems were found in total.

**Estimate of what remains** (capture-recapture): 15 × 14 / 6 ≈ 35 problems, so about 12 are still
unfound. Bugs are not equally easy to find, so the true number is probably higher.

**Scores (Arranger):** advisor2 8/10 (accurate and broad; missed F1 and F6; no design synthesis,
which its brief did not ask for). advisor1 8.5/10 (found the most important defect, F1; answered
the 12→15 question directly; gave the design classes; fewer confirmed findings). The two reviews
complement each other. advisor1 shares the Arranger's model, so its important claims also go to a
Validator on a different model.

**op-393 (advisor1, 2026-09-29)** covered most of the unreached areas: 5 new main findings
(N1-N5, including launchd's 53x timebase and task calls acting on the caller), 3 firm-ups and 1
retraction. Still not reached: the host_priv and mach_host routine bodies, task_info/task_threads,
and the other vm_map server routines.

**Originally not reached by either:** `mach_clock.c` and `clock_server.c`, `mach_semaphore.c`,
`ipc_kobject.c` and the MIG dispatch, `ipc_space.c`, `ipc_notify.c`, and the trap argument path.

## Decision: another round after the fixes, shaped differently

1. **Design first, then fix.** Design classes A (port names as file descriptors) and B (Mach state
   bound to reusable proc and thread slots) may change how entries and tasks live. Decide them
   through an Advisor design consult and the Coordinator before point fixes land in those areas.
2. **Validators review each fix** as a diff. That is a different job from exploratory review.
3. **Round 2 after the fixes:** a blind round with two reviewers on different models, covering the
   new design and the unreached areas. Each reviewer also returns a "checked and cleared" list.
4. **Stop signal:** when most findings come from both reviewers, reading has reached diminishing
   returns.
5. **Then machines:** a KASAN run (id-047) and fuzzing (id-048) on the fixed code.

Optional before any fixing: one targeted review of only the unreached areas (a follow-up for
advisor1). It is not urgent.

## Brief form that worked

State the lineage, put every reference tree on disk, ask for findings only (assumption, the lines
on both sides, the failure, confidence, the smallest check), and ask for design causes. Forbid
reading the other reviewers' work. Audit-shaped briefs (op-383) returned bookkeeping.
