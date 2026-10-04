# Handoff — read this first in a new session (written 2026-10-04, 17:15 NZDT)

The previous session was cleared to drop side-task context. Read this file, then follow AGENTS.md
§ Start of a session (now.md, LOCAL.md, the journal tail from j-20261004-022, `tools/rob board`,
`tools/roles check`). Run the tools from the real path (`cd -P`), not from the `rmx-arranger1`
alias. Rewrite or delete this file once its open items are done.

## Board at handoff

```
- [issued]: op-449 (overdue 2h27m > 2h; still running, see below)
- [hold]: op-152, op-209, op-251, op-280, op-305, op-308, op-384, op-385, op-386, op-468
```

`tools/roles check`: 10 instances, 0 need attention (all at meta-012). Workflow pin meta-012, the
newest tag. `rob check` has one known item: op-384 needs the dropped op-387.

## In flight

- **op-449** (Implementer, `pid1-boot-1`): launchd as PID 1 keeps every log message in memory when
  asld is not running (`sbin/launchd/log.c:237-238`). The fix bounds the queue and logs through
  `syslog(3)` when nothing drains it, with a 15-minute RSS self-check on old and new images. At
  17:14 its round-4 fixed-image self-check was running (`bhyve: rmx-selfcheck-op449-fixed-…`); the
  last commits are tools commits up to `59c79e5` (16:44). Overdue only by time: not stopped. When
  the reply arrives: `tools/rob reply op-449 <file>`, verify the RSS tables, the image hash and BOM,
  and that only launchd changed; then decide its review (S/M yourself, or a Gatekeeper soak re-run).
  Its commits after `bafabbe` are local only (the op-461 push stopped there).

## Next on the Mach path

- **Step 4 part 1 is accepted** (2026-10-04): `mach-fixes-4@0924690c` on origin (op-447, op-461;
  proofs op-457 52/52 and op-464 55/55; reviews op-458 REMEDIATE then op-465 CLOSE 9/10). id-046
  § Step 4 part 1 accepted, now.md and the IDQ index are updated.
- **Step 4 part 2** is advisor2's plan items 4-6 (`/Users/me/wip-mach/rmx-advisor2/
  op-435-mach-step4-c1-d2-plan.md` § 1 and § 4; decisions in `mach-names-step5-deferred.md` § Step 4
  decisions): consumer adaptation, pure C1 with public KNOTE, D2's two setters. Item 4 is split by
  consumer. **op-468** (libdispatch, branch `mach-fixes-5` from `0924690c`, six tests first, two
  images, `expected: 4h`) is drafted on hold with `needs: op-449`: set it to draft and show it in
  full when op-449 returns. Then launchd, then libxpc, then items 5 and 6; those are not drafted
  (they stay in id-046).
- Review pattern for each Mach return: gatekeeper1 before/after proof plus validator3 review
  (validator3 remains the default Validator).
- Staging space: the op461 r1 pair and older pairs (op430-op444) in `stage/images` can be cleaned up
  (record their sha256s in `doc/stage/` first, never while a VM runs).

## Today's decisions to keep (also in LOCAL.md and the journal)

- **Replies are casts (meta-012).** An agent answers a call with `reply to op-NNN`; record it with
  `tools/rob reply op-NNN <file>` (next free number, `answers:`, call → returned). The REPORT is
  retired.
- **Generate ops without asking** when the next step is an op; show it in full.
- **Brief wording:** before showing any brief, cast or continuation, re-read
  safety-flag-avoidance.md and check the draft line by line. Every agent runs on a frontier model
  (Arranger Opus 5.5 medium; all others GPT-Sol-6.1 medium; the guide's § Seats). Carry review
  findings inline in engineering words; do not point agents at review files whose wording may trip
  the filter. After a filter stop: a follow-up cast in the same session first (op-462u was the
  example); restart in a fresh session only if that fails.
- **Before rendering an agent's repo or calling it stopped,** check for a live process there
  (`procstat -f <pid>` cwd), not only file times.
- **Case-insensitivity (id-027):** userspace case-insensitive from day one (fail fast); the FreeBSD
  kernel and base move incrementally, each phase prepared.
- Pushes: `mach-fixes-*` (public rmxOS) only with the Coordinator's yes; private role repos and this
  repo under the standing permission. No AI attribution in any commit.

## Other projects (side tasks, now handed off)

- **zenoh-swift** (`/Users/me/wip-rbzq/agent-arranger`): this Arranger's child. Read and change only
  its Arranger repo, logging each change in its `parent-log.md`; messages go as casts through the
  Coordinator (op-456u, its last, was sent).
- **depthai** (`/Users/me/wip-depthai`), **fstack** (`/Users/me/wip-fstack`) and **swift-sdk**
  (`/Users/me/wip-swift-sdk`, dataset `zroot/wip-swift-sdk`, insensitive formD): independent roots,
  set up today from the scaffold; each has its own Arranger now. Do not read or change them.
  swift-sdk's old tree `/Users/me/wip-rnx` stays (the old agent session is closed; its folder is kept
  for questions) until its rebuild at the new path passes.
- **The shared workflow** (`~/wip-workflow`): meta-011 (roles resolves folder aliases) and meta-012
  (reply casts) made today. For meta-013: `rob new`'s closing line does not fit an Arranger's own op
  (no OPS.md); the base op-brief-forms still names rmxOS's mm4 series.
- mm4 instances (gatekeeper2, explorer2, advisor4) are still not re-rendered.

## How the Coordinator works with this seat (keep doing)

- Show every op in full as one copy-paste block, lines under 80 characters, with an Expected time.
- Record `issued` only when the Coordinator says it was sent; a reply that comes back proves it.
- Cheapest step first; read the source before commissioning a run; self-check before any proof;
  after two failed rounds on one item, simplify. Check overdue ops first.
- Restart prompts carry the work inline; never point an agent at this repo.
- Design calls under "match macOS, keep 1.0 stable" are delegated: decide, record, say so.
