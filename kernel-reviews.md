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
and the other vm_map server routines. Tracked, with S1's open check, as id-052 (high).

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

## Design decision (Coordinator, 2026-10-02)

1.0 keeps NextBSD's fd-backed port names and does op-394's steps 2-4; the XNU name table (step 5)
is deferred: [mach-names-step5-deferred.md](mach-names-step5-deferred.md) (id-056).

## Road to round 2 (Arranger, 2026-10-02)

Round 2 starts when the code it reviews is the 1.0 design, built and tested:
1. **Batch 1 closed:** op-395 plus op-412, proven by op-411, with `mach-fixes-1` on origin.
2. **Step 2:** entry, uref and reference APIs on the fd backend, closing with descriptor
   removal revoking the name (op-389 #2; op-392 S2, S3, S4).
3. **Step 3:** one task and thread object per lifetime, with full teardown (op-389 #4; op-392 F1
   and F2; op-393 N5's prerequisite).
4. **Step 4 plus C1 under A1:** queued MIG replies, safe wakeups, and receive in `mach_msg` with
   kqueue signalling readiness only, plus the libdispatch adapter (op-392 F5; op-393 N2; op-389
   #6, #7, #15; op-392 F4). Design: advisor2's op-421 note (`5bfc3e1`), without its native EOF
   retirement helper (the Coordinator chose native close semantics, 2026-10-02).
5. **D2 subset:** child-task setters after step 3; foreign name-space calls stay off.
6. **Checking in place:** the Mach regression suite and a KASAN survey run on the fixed branch.
7. **Leftovers decided:** the findings no batch covers (id-046 § Status by finding: #8, N9, N10,
   #14, S6, the §3 VM and audit items, #1, A1) are either fixed or recorded as known 1.0 gaps.

**Readiness (2026-10-03):** 1-2 done; 3 in re-review (op-440, op-441); 4-5 planned (op-435);
6 and 7 open. Round 2 is not ready. Why it is still worth running: round 1's estimate leaves about
12 problems unfound, and id-052's areas (host_priv and mach_host bodies, task_info/task_threads,
most of vm_map) have never been reviewed.

### Guardrail for round 2

The reviewers' brief states the decided design and links
[mach-names-step5-deferred.md](mach-names-step5-deferred.md). Port names stay fds in 1.0. Reviewers
check the code against that record's nine rules and do not re-propose the name table or C3.
A finding that only step 5 could fix is tagged "needs step 5" and filed under id-056, not as a
1.0 defect. Round 2 also covers the areas no review has reached (id-052).
