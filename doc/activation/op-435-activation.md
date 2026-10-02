---
id: op-435
state: draft
agent: advisor2
repo: rmx-advisor2
idq: id-046
gate: self
authority: none: read-only design note; commit in rmx-advisor2
updated: 2026-10-02T13:14Z
---
# op-435 — Advisor 2: step-4 plan for 1.0 — revise op-421's receive design without the EOF helper, plus the D2 subset, against mach-fixes-3

## Outcome

Context: ordinary design work on our own open-source OS (rmxOS: FreeBSD 15 with Apple's open-source
Mach IPC). This is a design note for the Implementer, not a review of attack scenarios.

Turn your op-421 note (`rmx-advisor2@5bfc3e1`, `op-421-c1-on-fd-backend.md`) into the plan the
Implementer will build as Mach step 4 for 1.0, on the code as it now is: `wip-rmxos` branch
`mach-fixes-3` at `db592723` (batches 1-3: entry and reference handling, task and thread
lifetimes; mapping in `/Users/me/wip-mach/rmx-implementer/docs/op430-mach-lifetimes.md`).

Decisions made since op-421, which the plan must follow
(`/Users/me/wip-mach/rmx-arranger/mach-names-step5-deferred.md` has the full record):
- **No native EOF retirement helper in 1.0.** `kern_event.c` and `kern_descrip.c` stay as FreeBSD
  has them: closing a Mach name silently removes its kqueue registrations, as for any fd.
  Consumers learn of port death the Mach way: dead-name notifications and `mach_msg` errors.
  libdispatch cancels a source before it destroys the port.
- **C1:** kqueue signals readiness only; receive happens in `mach_msg`. No direct-receive kevents.
- **No further FreeBSD-side changes** beyond the five already allowed (`fo_fdpostclose`,
  `DFLAG_NODUP`, exec committed, thread published, the thread-exit gate). If the plan needs one,
  name it as a separate question for the Coordinator, with the cost of doing without it.
- Step 5 (XNU name table, generations, C3) stays deferred; do not plan it.

The plan should cover:
1. **What changes without the EOF helper.** Your §3 routes EOF by `udata` cookie in libdispatch,
   launchd and libxpc. Replace each with the dead-name or `mach_msg`-error path. Name the cases
   where a consumer could now miss a death or act on a reused fd number, and the rule or test that
   closes each one.
2. **The kernel part of step 4:** queued MIG replies, waits and wakes under one interlock,
   membership pins and revalidation, readiness published outside Mach locks, and the `mach_msg`
   LARGE and trailer boundary. Check each against `mach-fixes-3`, not alpha2; drop or adjust
   anything batches 1-3 already did.
3. **The D2 subset for 1.0:** which cross-task MIG calls are enabled, given that the target task and its
   table are held and checked (step 3 now provides pinned task objects). Everything else stays
   disabled.
4. **Order:** commits the Implementer can land one at a time, each building, with the regression
   test to write first for each (in the `tests/sys/mach` style: Mach behaviour, not fd numbers),
   and the id-046 finding each retires (op-389 #6, #7, #15; op-392 F4, F5, S1, pset S2; op-393 N2;
   say which of N6 and the others are left).
5. **Open risks:** what you could not settle from source, and what a guest test must show.

Result: one note in your repo, short enough for an Implementer brief to cite by section.

Re-read OPS.md first: defaults and the REPORT block.
