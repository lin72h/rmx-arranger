# id-051 — Kernel review rounds: the Mach integration needs a second blind round after the fixes

- id: **id-051**
- state: **WAITING — after id-046's design decisions and fixes; priority medium (Coordinator, 2026-09-28)**
- raised: **2026-09-28 by the Coordinator**
- parent: id-042 (1.0-preview); related: id-046, id-047, id-048
- record: [kernel-reviews.md](../kernel-reviews.md)

## Problem

Two blind deep dives (op-389, op-392) found about 23 distinct Mach defects, and only about 6
were found by both. Capture-recapture estimates about 12 more are unfound, and several areas were
never reviewed. A single review round is not enough.

## Plan

This entry tracks the plan in kernel-reviews.md: design first (classes A and B), then Validator
review of each fix, then a second blind round with two reviewers on different models covering the
new design and the unreached areas, stopping when the overlap is high. After that, sanitizers
(id-047) and fuzzing (id-048).

## Readiness and guardrail (2026-10-02)

See kernel-reviews.md § Road to round 2: batch 1 closed, steps 2-4 with C1 on the fd backend,
the D2 subset, and checking on the fixed branch. The round-2 brief carries the step-5 deferral
(id-056), so reviewers do not re-propose the name table, and it includes id-052's areas.

## Done when

Round 2 has returned, its findings are bound to the IDQ, and the overlap between its reviewers is
high enough to stop reading reviews.
