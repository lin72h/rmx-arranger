# Handoff — read this first in a new session (written 2026-10-04)

The previous session ended at 92% context. Read this file, then follow AGENTS.md § Start of a session
(now.md, LOCAL.md, the journal tail from j-20261004-001, `tools/rob board`, `tools/roles check`).
Delete or rewrite this file once its open items are done.

## Board at handoff

```
- [issued]: op-447 (overdue: its session stopped)
- [draft]: op-452b (meta)
- [hold]: op-152, op-209, op-251, op-280, op-305, op-308, op-384, op-385, op-386, op-449
```

- **op-447** (Implementer, Mach step 4 part 1, `expected: 2h`): the Implementer's session stopped on
  2026-10-03 at about 20:28 and has not been restarted (the Coordinator said "no hurry"). State:
  - `wip-rmxos` branch `mach-fixes-4`: 16+ commits through `b1ef1670`, on `mach-fixes-3@844112f4`;
    rmx-implementer at `bef5ebd`; record `docs/op447-mach-step4-part1.md`; work in `build/op447/`;
  - round-5 images staged: `/Users/me/wip-mach/stage/images/op447-base-tests-r5.raw` and
    `op447-fixed-tests-r5.raw`;
  - base self-check r5 passed (11/11 new cases fail as recorded,
    `build/op447/selfcheck-r5/selfcheck-base-7.json`); the fixed-image r5 run never happened
    (`build/op447/logs/selfcheck-fixed-r5.log` is empty); 7 of 8 self-check boots used.
  The restart prompt is below; give it in a **fresh** Implementer session.
- **op-452b** (broadcast cast: "NOTICEs are now casts"): delivered by asking the rmxOS agents to
  reload their instructions. Retire it (`tools/rob set op-452b closed`) once the Coordinator says
  the reloads are done.
- **op-449** (Implementer, held): launchd as PID 1 keeps every log message in memory when asld is not
  running (`sbin/launchd/log.c:237-238`, drained only by asld; op-436 disabled asld). Fix: bound the
  queue and log via syslog(3) when no drainer; 15-minute before and after RSS self-check. Send it
  after op-447 returns (the Implementer is one agent). Expected time 1.5-2 h.

### op-447 restart prompt (positive wording; carries the work inline)

```
Context: ordinary debugging and testing of our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source Mach, launchd and libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

You are resuming op-447 in a new session (Mach step 4 part 1: kernel bug fixes with regression
tests, on branch `mach-fixes-4` of `wip-rmxos`). Re-read AGENTS.md and OPS.md. Your earlier session's
work stands:
- commits on `mach-fixes-4` through `b1ef1670`, and in this repo through `bef5ebd`;
- your op record `docs/op447-mach-step4-part1.md`, and scripts and logs in `build/op447/`;
- staged images `/Users/me/wip-mach/stage/images/op447-base-tests-r5.raw` and
  `/Users/me/wip-mach/stage/images/op447-fixed-tests-r5.raw`;
- the base self-check of round 5 passed: 11/11 new cases fail as recorded
  (`build/op447/selfcheck-r5/selfcheck-base-7.json`).

Remaining work, all of it:
1. Run the fixed-image self-check on `op447-fixed-tests-r5.raw` with your `tools/selfcheck` runner:
   every case, the 41 earlier ones and the new ones, all expected to pass. Its log
   `build/op447/logs/selfcheck-fixed-r5.log` is empty, so that run did not happen. You have used 7
   self-check boots; this op allows up to 3 more.
2. If a case fails for a test or setup reason, fix it, re-stage only what changed and run it again.
   If it fails because of the kernel change, record the cause at file:line and report it.
3. Finish `docs/op447-mach-step4-part1.md`: each item (pins and revalidation, the LARGE and trailer
   boundary, queued replies and receive waits, N6) with its commits, tests and expected results,
   plus the self-check counts.
4. Clean up superseded images and scratch disks from earlier rounds, keeping the round-5 pair, and
   say what you freed.
5. Return the REPORT with the `selfcheck:` line, both image hashes and BOMs (by path), and the commits.
```

## The main task: Mach foundation, then PID-1 launchd

- **Mach batches 1-3 are accepted and on origin:** `mach-fixes-1@903c8fc2`, `mach-fixes-2@ee883a74`,
  `mach-fixes-3@844112f4` (status per finding: `idq/id-046` § Status by finding).
- **After op-447 returns:** verify first-hand (commits, the native-file scope: only the five allowed
  FreeBSD hooks, the selfcheck counts). Then one Gatekeeper proof of step 4 part 1 that also re-runs
  all 41 batch-3 cases, and a Validator review (L: validator3 was the default for the week of
  2026-10-03; ask the Coordinator whether that still holds). Ask before pushing `mach-fixes-4`.
- **Then step 4 part 2:** the consumer changes (libdispatch, launchd, libxpc), pure C1 with public
  KNOTE, and the D2 setters. Plan: advisor2's op-435 note (`rmx-advisor2@42dc8247`,
  `op-435-mach-step4-c1-d2-plan.md`); decisions: `mach-names-step5-deferred.md` § Step 4 decisions.
- **Then:** the leftover batch (#8, N9, N10, #14; decide S6 and the §3 VM items), a KASAN run of the
  Mach suite, then review round 2 (`kernel-reviews.md`, readiness note).
- **PID-1 launchd:** op-436 (`pid1-boot-1@969f2151`, on origin) is accepted on ZFS by op-439 (16/16).
  op-445's soak found the RSS growth that op-449 fixes. `id-060`: calendar jobs run late after a
  clock step (low). New images are ZFS-root only.
- **Swift on rmxOS** (`swift-real-libdispatch.md`, id-058): not started. Swift toolchain problems go
  to the Coordinator as relay-ready findings for the toolchain's own agent; no local workarounds.

## The workflow and the other project (done this session; details in the journal)

- **`~/wip-workflow`** is the shared workflow (base templates, `tools/rob` and `tools/roles`, the
  method in `docs/method.md`, the scaffold, `CHANGELOG.md`, `projects.md`). This Arranger maintains
  it as the root of the Arranger tree. Versions are **`meta-NNN`** Git tags (meta-001..meta-010);
  each change is a meta entry served by ops (`idq: meta-NNN`). rmxOS pins **meta-010**
  (`workflow.lock`); its `tools/` are wrappers. rmxOS's own templates are not on the bases yet
  (a planned, careful step).
- **Vocabulary:** ops are `op-NNN` (calls, answered by a REPORT) or casts without a reply (`op-NNNu`
  unicast, `op-NNNb` broadcast; a cast retires when sent: draft → closed). Problems `id-NNN`
  (default id-000), milestones `li-NNN` (default li-000 = roadmap.md), non-project work `meta-NNN`
  (default meta-000). No other id series. Every op carries `expected:`; `rob board` flags overdue.
- **zenoh-swift** (`/Users/me/wip-rbzq/agent-arranger`) is this Arranger's child: read and change
  only its Arranger repo, log each change in its `parent-log.md` (p-20261004-001..006), never touch
  its agents' repos, and leave its decisions to it and the Coordinator. It has adopted the shared
  tools and the lock (meta-004); its op-004 plans the rest.
- **mm4 instances** (gatekeeper2, explorer2, advisor4) were not re-rendered: still pending on mm4.

## How the Coordinator works with this seat (keep doing)

- Show every op in full as one copy-paste block, lines under 80 characters, with an Expected time.
- Record `issued` only when the Coordinator names the op; a REPORT that comes back proves it was
  sent. The relay is manual, on the terminal.
- Cheapest step first; read the source before commissioning a run. Self-check before any proof;
  after two failed rounds on one item, simplify. Check overdue ops first.
- Positive wording in anything an agent reads; never list words to avoid. Restart a stopped agent
  in a fresh session with the work inline; never point an agent at this repo.
- No AI attribution in any commit. Commit re-renders by naming the files. Ask before any push.
- The Coordinator delegates design calls under "match macOS, keep 1.0 stable": decide, record, and
  say so.
