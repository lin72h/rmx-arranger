# Worklog

Major milestones only, newest last. Each header is the local date and time (NZDT, UTC+13) from
the commit or event. Detail lives in the journal (`arranger-swap.md`), op files and the IDQ.

## 2026-09-28 13:25 — Validators onboarded on the template model

`rmx-validator0` plus three instances (GLM, DS4P, validator3), then calibrated by reviewing a
known op (op-365 to op-367) against a key written beforehand.

## 2026-09-28 16:56 — Gatekeepers and Explorers split into two instances each

gatekeeper1 and explorer1 on this host (rx-x64z); gatekeeper2 and explorer2 only on mm4 (mx-a64z),
each with its own private repo. All four onboarded (op-370, op-371, op-373, op-374).
gatekeeper1's history was rewritten to drop a 6.5 GB image.

## 2026-09-28 17:05 — Oracle becomes Advisor; four seats

The role was renamed. advisor1–3 are on this host, and advisor4 is on mm4 for macOS work. The
template is on GitHub (`lin72h/rmx-advisor0`). Advisors run one seat at a time, with no fan-out.

## 2026-09-28 18:08 — alpha2 regression milestone complete

op-364 rebuilt `mach.ko` and composed the image; op-372 booted it contained (Mach 4/4, dispatch 4/4,
clean power-off). Both Validators closed it. Loose end: the leak-locals dependency (id-045).

## 2026-09-28 18:21 — PID-1 launchd is the milestone; service plane decided

The Coordinator chose PID-1 launchd as the next milestone. The preview uses MachServices plus
nvlist; `xpc_domain` is deferred.

## 2026-09-28 18:54 — PID-1 contract accepted on alpha2

op-377 rebased the contract. The Validators split (op-378, op-379), and the Arbiter sent it back
for fixes: wrong install paths in the BOM. op-380 corrected them and added the consumer-check
rule.

## 2026-09-28 20:54 — Staging helper and PID-1 premise image accepted

After two correct stops (no separate filesystem, fixed with the ZFS staging dataset; a false host
alarm from mtree timestamps), op-388 staged image `031885…` and op-390 reviewed it at 9/10. The
reaper test op-391 was drafted and sent.

## 2026-09-28 21:04 — First Mach deep dive: 14 confirmed defects (id-046)

advisor2's op-389 was findings-only, after op-383's audit-style consult gave little. Among the
findings: a user-triggerable panic via poll(2). `mach.ko` is built outside its kernel's
configuration.

## 2026-09-28 22:11 — Workflow review; the Coordinator's positions

The hand relay is intentional, and slow is fine for kernel work. Architecture correctness is the
goal of the reviews. Sanitizers (id-047) and fuzzing (id-048) were added at medium; macOS-side
polish at low (id-049, id-050).

## 2026-09-28 23:27 — Independent second Mach review; review plan recorded

advisor1's blind op-392 added the caller-identity defect (F1), the `swtch_pri` panic (F6) and five
design classes. The two reviews overlapped on only about 6 of 23 problems. `kernel-reviews.md`
and id-051 record round 1 and the plan for round 2.

## 2026-09-29 00:11 — Mach review completed; every finding in one ledger

advisor1's op-393 covered the areas not yet reached (N1: launchd's timebase is about 53× off;
N5: task calls act on the caller). id-046 now lists all 38 findings; the remainder is id-052
(high).

## 2026-09-29 00:22 — Mach foundation first

Plan: fix the Mach bugs test-first, then CI (the Gatekeeper runs it, the Validators read it),
then review round 2, then the upper components. op-391 continues as the pre-fix baseline.

## 2026-09-29 00:31 — First full day on the new harness

The new Claude Code version (with yesterday's freeze fixed) ran the whole day without a problem.
Every role was restructured onto templates, and each agent took its first spin under the new
rules.
