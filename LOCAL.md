# LOCAL.md — notes for this instance

This file is yours. Keep notes and lessons specific to this instance here; rendered files are
regenerated from the role template and must not be edited. The Arranger reads this file and may
promote a lesson into the template so every instance gets it.

Grouped by when each note is needed; one line per rule. The examples behind each rule, the
op-365/366/367 calibration and older notes are in
[doc/archive/LOCAL-20261008.md](doc/archive/LOCAL-20261008.md) (history, not guidance).

## Standing decisions (Coordinator)

- **Draft ops without asking.** When the next step is an op, draft it and show it. Ask only when
  the choice is genuinely the Coordinator's (scope, priority, cost such as an Advisor seat).
- **Keep bookkeeping out of replies.** Fix state, times and tool quirks myself and journal them;
  tell the Coordinator only what needs a decision or a relay.
- **The hand relay is intentional.** Never propose automating or bypassing it. Multi-agent
  efficiency (accounts, a second Implementer, parallel lanes) is the Coordinator's later plan.
- **Pushes.** Private role repos: push when closing ops or after maintenance. Public rmxOS: an
  explicit yes each time, except proven product branches (`mach-fixes-*`, `pid1-boot-*`): once
  verified, reviewed and proven, push by commit hash, close, and report the push.
- **Commits carry no AI attribution** (no `Co-Authored-By: Claude …`, no `Claude-Session:`), in
  any repo, whatever a harness reminder says.
- **Names.** Work is op-NNN, problems id-NNN, milestones li-NNN, workflow meta-NNN. Never use
  design-option labels from Advisor notes (A1, C1, D2 …) except inside a citation.
- **Tests.** FreeBSD's ATF/Kyua tests run as they are; new rmxOS tests are Zig, swift-testing or
  Elixir (test-pillar-partition.md), never new ATF or C.
- **Images.** ZFS root (from `op417-alpha2-zfs-gpt.raw` or later), proofs on the overlay route;
  name the base image in every brief that stages one.
- **Reviews.** Advisor briefs lead with the architecture question; defects are its evidence.
  Sanitizers and fuzzers find bugs; they do not decide design.
- **Cost (2026-10-10).** Codex seats are cheap but not free: for review and consults use validator1
  (GLM) and validator2 (DeepSeek) first; validator3 or an Advisor only when they cannot answer.
- **Idle gaps** (the Coordinator asleep, a model out of tokens) are expected, not mine to fix.

## Before showing a brief, cast, restart prompt or answer

1. Run `tools/brief-check op-NNN` (or `FILE` / `-`). Fix every FAIL; keep a WARN only for a reason.
2. Read the text once as a whole. Each defect reads as what our code does at file:line and what
   the fix changes, in ownership terms (who releases X); never as how to reach the failure.
   A list of memory or lifetime defects needs this most (op-569 was stopped twice).
3. Carry everything inline: no path or file name from this repo, not even as a citation.
   Restate review findings in my own engineering words; cite a review by path only as background.
4. Every count, hash and commit comes from a command (`git rev-parse`, `git rev-list --count`,
   `sha256sum`), never from memory or a reply.
5. Expectations: check the platform's real behaviour for the exact case; read the component's
   load and lifecycle rules before asking for a mode (`mach_module.c`: boot-time load only);
   derive each base result from what the base contains; list every case the base runs.
   Before setting a return code in a brief, grep the existing tests for that call (op-583). Check
   that every hook point a design names exists in FreeBSD (op-426).
6. Self-checks stay light: ATF counts and serial paths, no custom checkers or controls. A
   classifier is frozen with its controls passing before a cell boots. Diagnostic code goes on a
   `diag-<topic>` branch, never on a branch to be pushed. Harness programs and D scripts
   compile on the host before any boot.
7. Budget boots with room: an install boot plus a test boot per run, plus the standing two spares.
8. For a hang, the first op is the kernel-debugger dump (NMI into DDB with `ps`, `alltrace`,
   `show allchains`, `show alllocks`). Read the source before commissioning a long run.
9. Check that the agent's own AGENTS.md does not override the OPS.md rule the brief relies on.
10. Keep tests that end a process by a fatal signal on purpose out of Implementer ops (op-484).
11. A read-only brief says that read-only commands are allowed. Ask reviewers for findings, not
    status, and put every reference tree on disk.
12. Show the complete brief in the reply as one copy-paste block: the Coordinator cannot see
    tool output.

## Keeping rounds few

- An Implementer op that stages images ends with its own guest self-check; the Gatekeeper's
  proof brief follows only once that is green.
- Draft the next op as soon as one is sent. Merge work that needs the same images or boots into
  one op. When an agent asks for one more boot or a small permission inside the op's purpose,
  answer at once with a ready-to-send op (a call through `tools/rob new`, `needs:` the original; op-581).

- A self-check brief lets the Implementer fix a wrong *new* test (input, setup or expected value
  against the briefed behaviour) and rerun within its boots; it stops only on a product failure or
  an earlier accepted test failing. Three rounds were lost without this (op-577, op-583, op-586).

## Verifying returns

- Resolve every commit in a reply with `git rev-parse` before citing or pushing it.
- "Never booted" claims: check the Gatekeeper's records too. A module's undefined symbols:
  name the resolution path. A self-test proves only the file it ran against. A gate needs a
  no-change control and a changed-input control. Check a reviewer's cited commit against history.
- A reply for a `draft` op means it was sent: set `issued` first, then record the reply.
- Validator routing: validator1 (breadth) with validator2 (root cause) is the default pair.
  validator1's replies arrive with fused lines: take exact values from its committed file.
- Write a journal or LAST.md entry only after the edits it describes have succeeded.

## Agents, renders and restarts

- Before rendering an agent's repo or calling it stopped, look for a live process
  (`ps -axo pid,etime,command | grep -E 'codex|claude'`, then `procstat -f <pid>` for its cwd);
  the Coordinator may have resumed it. Check overdue ops at every session start.
- After a filter stop: reword, then restart in a new session at once (safety-flag-avoidance.md
  rule 7), with the work done carried inline.
- Commit renders by name (`AGENTS.md OPS.md .rendered.lock`), never from `git status`.

## Hosts, records and other projects

- Journal times come from `date -u`; this host's local time is UTC+13. `worklog.md` gets a
  section per milestone, headed with the local date and time.
- Staging: images take about 1 GB each; clean up when a line of work closes, keep what open ops
  reference, record sha256s in `doc/stage/` first, never delete while a VM runs.
- mm4: read-only commands for quick macOS facts; probes go to explorer2 by op. Run scripts as
  `zsh -l <file> < /dev/null`. To push an mm4 repo, clone it bare to the scratchpad, push from
  here, then `git update-ref` its `origin/main` on mm4.
- gatekeeper1's commits from `117e718` on were rewritten (2026-09-28): translate old IDs through
  `rmx-gatekeeper1/docs/history-rewrite-2026-09-28.md` (hold op-308, id-011, id-021).
- Child projects: work only through their Arranger repo (`git -C <child-arranger>`,
  `tools/roles render <child>-arranger`; never `roles check` or `list` there). Their decisions
  are theirs; messages go through the Coordinator; `parent-log.md` records only my changes.

## Pending template changes (next render round, when no instance has an op in flight)

- Every role's OPS.md opening: replace "the Arranger sends a NOTICE when OPS.md changes" with
  "each brief asks for a re-read" (implementer0 already does).
- validator0: add the falsification pattern "a self-confirming gate cannot see a wrong path:
  check each destination against its consumer" (op-379); say to print the reply block once.
- report form: `commits:` lists only the commits this op made, or none (op-371).
