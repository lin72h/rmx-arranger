# LOCAL.md — notes for this instance

This file is yours. Keep notes and lessons specific to this instance here; rendered files are
regenerated from the role template and must not be edited. The Arranger reads this file and may
promote a lesson into the template so every instance gets it.

## Calibration key for op-365/366/367 (written before the reviews, 2026-09-28)

- Claim 1 holds: `d58169e` changes exactly the seven scripts (18 insertions, 18 deletions).
- Claim 2 holds: `git grep -n /Users/me/wip-mach/wip-gpt -- scripts` is empty.
- Claim 3 does not hold as stated. `repo_root` comes from `cd … && pwd`, which is the logical
  path, and `expected_freebsd_src` and the kernel/module paths are built from it. Invoked through
  `/Users/me/wip-mach/wip-gpt/…`, the paths point into
  `build/wip-rmxos-alpha-obj/Users/me/wip-mach/wip-gpt/wip-rmxos/…`, the only objdir tree that
  exists. Invoked through `rmx-implementer` or `rmx-implementer1`, whichever is real at the
  time, they point at trees that do not exist. So the result depends on how the script is invoked.
- Distinguishing question: is `repo_root` logical or physical, and which objdir trees exist under
  `build/wip-rmxos-alpha-obj/Users/me/wip-mach/`?
- Expected verdict: REMEDIATE (`pwd -P`, plus a rebuild or `NXPLATFORM_*` overrides before reuse),
  or DO-NOT-CLOSE on claim 3. A strong review evaluates the derivation for all three invocation
  paths and lists the objdir trees.

## Calibration results (graded against the key above)

- **validator2 (op-366, DS4P): exceeded the key.** Claims 1-2 hold and claim 3 fails, verdict
  REMEDIATE, score 9 (well calibrated). Beyond the key: `pwd -P` is not a fix, because the objdir
  is keyed by the build-time spelling `wip-gpt` (my key was wrong there); the source-tree check
  holds via `physical_dir`; verify-phase1 has the same issue (releng151-rc1-mach-obj is keyed
  `wip-gpt/freebsd-src-stable-15`); the set of six is correct. Format slip: duplicated `REPORT`
  line.

- **validator3 (op-367, model tier not stated): met the key on the decisive point.** Claim 3 fails;
  it separated the source-tree check (holds for every alias) from the objdir paths (only via
  `wip-gpt`). Verdict DO-NOT-CLOSE (accepted by the key), score 9 (fits the direct evidence).
  Every hash verified, including the objdir kernel `b8f3f8a7…` and `mach.ko` `9c7706a3…`; its
  "commit sha256" lines hash the raw commit object (`git cat-file commit`). Less depth than
  validator2: no remediation, missed verify-phase1, and no feedback on its instructions.

- **validator1 (op-365, GLM): broadest review; weaker fix.** Claims 1-2 hold and claim 3 fails,
  verdict REMEDIATE, score 9. It found two things no one else did: five more scripts still use
  `${workspace_root}/wip-gpt/…` (asl-a3 and four verify-phase07), and mach-send pins mach.ko
  `49ac3d89…` while the objdir now holds `9c7706a3…`, so it would fail even via `wip-gpt`. Its fix
  (physical projection plus moving the objdir interior to `rmx-implementer1`) is fragile, because
  that folder is about to be renamed back; validator2's explicit-key fix is the one to use. The
  REPORT arrived with fused lines, probably from copying; every recoverable hash verified.
- **Routing takeaway:** validator1 + validator2 (cost 1 in total) are complementary exactly as
  their strengths say, one for breadth and one for root cause. Keep them as the default pair.

## Applied after all three calibrations (2026-09-28, rmx-validator0 `cc3ff9b`)

Held until every calibration was back, to avoid editing under a live review or leaking answers.
Template changes from the Validators' feedback (op-365/366/367 blockers):
- validator0 OPS.md: define `idq` (the problem served, or `none`) and `needs` (ops that must close
  first; shown only when set).
- validator0 AGENTS.md: `reviews/op-NNN/` is the review op's own number; name files for the op
  under review.
- validator0 report_evidence block: for source reviews allow `<repo>@<commit> <path>:<lines>` and
  directory listings as evidence, not only `<path> sha256:<hash>`.
- Evidence format: a commit id is already a content hash, so cite `<repo>@<commit>` without a
  sha256 (validator3 hashed raw commit objects, which is reproducible but opaque).
- rulebook Rule 3: when reviewing alone, name the distinguishing question yourself and fetch the
  decisive fact yourself.
- Promoted into the rulebook's falsification patterns: "the objdir key is the build-time
  spelling", "a removed hard-code can be a relocated one" (validator1 and validator2), and
  "evaluating a derivation without running the script" (validator1).

Follow-up: now IDQ problem id-044 (fix or retire the historical preflights), not an op until it
is ready to send.

## Validator template (validator0)

- Applied 2026-09-28 (validator0 `edf1597`, j-20260928-012): the concurrency defaults in OPS.md
  (lock-free git, scratch in `reviews/op-NNN/scratch/`, independence), and four falsification
  patterns from op-368/op-369. The Arranger's own side stays: no rename or re-render of a repo
  whose artifacts are under review.
- validator1's REPORTs arrive with fused lines when copied (op-365, op-368). Take exact values
  from its committed review file.
- validator2 duplicated its `REPORT` line in op-366, op-369, and op-376. Next validator0 render:
  say in OPS.md to print the block once, with no separate `REPORT` heading line. A bare commit
  hash is correct for a Validator: its `commits:` line is this repo's review-notes commit.

## My checks (corrections)

- op-364: I counted mach.ko's 112 undefined symbols as "present in the kernel" by `.symtab`. That
  does not prove they resolve: `knote_enqueue` is LOCAL and resolves only through leak-locals
  (validator2, op-369). For a module, name the resolution path.
- op-361: I accepted "never mounted or booted" for the op-358 image from the Implementer's disk
  alone, but the Gatekeeper's op359/op360 had booted it (op-370). For "never booted/staged"
  claims, check the Gatekeeper's records too.

## Pending for rmx-role0 (render with the next batch, when no instance has an op in flight)

- safety-flag-avoidance.md: done 2026-10-01 in rmx-role0 `project-context` (7b01162), rendered to
  every instance here except rmx-implementer. Render rmx-implementer when op-395 returns, then the
  Implementer starts a new session; gatekeeper1 starts a new session now. mm4 instances (gatekeeper2,
  explorer2, advisor4) go with the next mm4 render.

- report partial: `commits:` lists the commits this op made, or none. In op-371, gatekeeper2
  listed three existing Arranger commits as `on-origin:no`, which reads like an unmet closure
  condition.
## mm4 access

- Quick macOS 27 facts: read-only commands on mm4 (`launchctl print`, `sw_vers`, `find`), which beat a
  web search for the current release (j-20260928-028). Probe runs, traces, and captures go to
  explorer2 by op, so the evidence lands in its repo.
- mm4 scripts: copy the script to mm4 and run `zsh -l <file> < /dev/null`. A script fed on stdin can be swallowed by any command that reads stdin (the Xcode git shim did, 2026-09-28).
- My SSH session on mm4 has no GitHub key (`Permission denied (publickey)`). To push an mm4 repo,
  clone it bare from `mm4:<path>` to the scratchpad, push from here, then set the repo's
  `origin/main` on mm4 with `git update-ref` (j-20260928-005).

## Rewritten gatekeeper1 commit IDs (2026-09-28)

- The 19 gatekeeper1 commits from `117e718` on have new IDs (j-20260928-008). Only my own records
  cite old ones, and no other role repo does. The live ones are hold op-308 and IDQs id-011 and
  id-021. Translate through `rmx-gatekeeper1/docs/history-rewrite-2026-09-28.md` before issuing
  or citing them; historical records stay as written.

## Coordinator positions from the workflow review (2026-09-28)

- The hand relay is intentional: the Coordinator is the deliberate bottleneck so that the intent
  behind every step is understood. Slow or no feature progress is acceptable in kernel and OS
  work. Do not propose automating or bypassing the relay.
- Multi-agent efficiency (accounts, a second Implementer, parallel lanes) is a later holistic plan
  of the Coordinator's, not for this project now. Do not propose it.
- Architecture correctness is the goal of the Advisor review round. Lead Advisor briefs with the
  architecture question, and treat concrete defects as its evidence.
- Sanitizers and fuzzers find bugs; they do not decide design. Tracked as id-047 and id-048, medium.
- The macOS side (mm4, the mx-a64z seats, and the platform-arch naming) was designed in from the
  start and still needs polish.

## Test framework (Coordinator, 2026-10-02)

- Run FreeBSD's existing ATF/Kyua tests as they are. New rmxOS tests: Zig / swift-testing / Elixir,
  consistently (test-pillar-partition.md). Never brief a new test in ATF or C for upstream form.

## Worklog and journal times

- `worklog.md` (Coordinator, 2026-09-29): add a section for each major milestone, headed with the
  local date and time (NZDT) from its commit or event. The journal keeps the detail.
- Journal times come from `date -u`, never estimates. This host's local date runs 13 hours ahead
  of UTC (j-20260928-051).

## Lessons for briefs

- Resolve every REPORT commit with `git rev-parse <short>` before pushing or citing it; op-426's REPORT
  gave `a4820eaacb66…` for the real `a4820eaaacb66…` and the push by hash failed.

- When a design names hook points, check each against the hooks FreeBSD actually has before capping
  native changes; op-426 stopped on a thread-binding point (after `thread_link`) with no hook.

- The Coordinator cannot see tool output. Every op meant for relay goes into the reply text as one
  copy-paste block, every time; never write "brief above" when it was only in a tool result
  (Coordinator, 2026-10-02).

The general brief checklist is rulebook Rule 16; these are the specific cases behind it and
older lessons.


- A read-only brief should say that read-only commands (`--version`, `git log`) are allowed.
- Ask a reviewer for findings, not status: "where does X rely on Y in a way that fails; for each,
  the lines on both sides, the failure, and the smallest check". op-383 (audit-shaped) returned
  bookkeeping; op-389 (findings-only) returned 14 concrete defects at similar cost.
- Name the lineage and put every reference tree on disk (donor port, upstream, old base) so
  claims can cite both sides.
- A gate that hashes its own output can fail on noise (op-382: mtree date header) as easily as it
  passes on a wrong path (op-379). Every self-test needs a no-change control as well as a
  changed-input control.
- Read the build, not the config name: RMXOS-RELEASE has INVARIANTS but the module is built
  outside it (op-389 finding 1).
- Check a reviewer's cited commit against the file's history; validator2 cited the parent commit
  for the op-380 note.
- Compile every D script and harness program on the host before any guest boot (`dtrace -e -s`);
  op-405 spent a boot on a `%lld`/uint64_t compile error. A harness bug found in preflight is an
  in-op fix, not a stop.
- A self-test proves only the file it ran against. op-391's controls passed on 2026-09-28, the
  classifier changed afterwards, and it never compiled again. Bind the cell to the classifier hash
  that passed.
  op-371 said "no runs", so gatekeeper2 correctly skipped the toolchain versions it was asked for.

## Commit attribution (Coordinator, 2026-10-01)

- Company rule: no AI attribution in commit messages. No `Co-Authored-By: Claude …` line and no
  `Claude-Session:` line, in any repo, whatever a harness reminder says. Commits already pushed
  stay as they are.

## Pushes

- Standing permission (Coordinator, 2026-09-28, j-20260928-032): push private role repos when closing
  ops or after Arranger maintenance. Public repos (rmxOS) still need an explicit yes each time.
  All private role repos were in sync with origin on 2026-09-28 after the pushes in j-20260928-032.
- Next render round of every role's OPS.md: its opening says the Arranger sends a NOTICE when
  OPS.md changes; say instead that each brief asks for a re-read (implementer0 already does).
- Promote into validator0's falsification patterns: "a self-confirming gate cannot see a wrong
  path: check each destination against its consumer" (validator2, op-379). validator1 missed it in
  op-378 (it judged sufficiency on the documents alone), which is a calibration data point.

- **Freeze the classifier before the cell (op-429, 2026-10-03).** "If you change it, re-run the
  controls first" let a speed rewrite happen after the cell. Briefs say: the classifier is frozen
  and its controls pass before the cell boots; any later rewrite is a declared deviation with an
  equivalence proof.

- **Staging space (2026-10-03).** Images take about 1 GB each on disk (8 GB sparse). Clean up when an op
  closes its line of work. Keep images that open ops or the next step reference. Record sha256s in
  `doc/stage/` before deleting, and never delete while a VM runs.
