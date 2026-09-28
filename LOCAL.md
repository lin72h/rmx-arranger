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

- report partial: `commits:` lists the commits this op made, or none. In op-371, gatekeeper2
  listed three existing Arranger commits as `on-origin:no`, which reads like an unmet closure
  condition.
## mm4 access

- mm4 scripts: copy the script to mm4 and run `zsh -l <file> < /dev/null`. A script fed on stdin can be swallowed by any command that reads stdin (the Xcode git shim did, 2026-09-28).
- My SSH session on mm4 has no GitHub key (`Permission denied (publickey)`). To push an mm4 repo,
  clone it bare from `mm4:<path>` to the scratchpad, push from here, then set the repo's
  `origin/main` on mm4 with `git update-ref` (j-20260928-005).

## Rewritten gatekeeper1 commit IDs (2026-09-28)

- The 19 gatekeeper1 commits from `117e718` on have new IDs (j-20260928-008). Only my own records
  cite old ones, and no other role repo does. The live ones are hold op-308 and IDQs id-011 and
  id-021. Translate through `rmx-gatekeeper1/docs/history-rewrite-2026-09-28.md` before issuing
  or citing them; historical records stay as written.

## Lessons for briefs

- A read-only brief should say that read-only commands (`--version`, `git log`) are allowed.
  op-371 said "no runs", so gatekeeper2 correctly skipped the toolchain versions it was asked for.

## Unpushed Arranger commits in role repos

- explorer1 `f6277a4`, `7affb09`; explorer2 `90d5344`, `241284e`; gatekeeper1 `c17f2bd`;
  gatekeeper2 `0cb46e6`; rmx-implementer `f57003b` (README pointers, OPS.md re-renders, the
  Implementer's conversion; 2026-09-28). They go out with the next push of those repos.
- Next render round of every role's OPS.md: its opening says the Arranger sends a NOTICE when
  OPS.md changes; say instead that each brief asks for a re-read (implementer0 already does).
