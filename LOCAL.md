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

Follow-up op (after op-364 closes and the Implementer is converted): give the objdir component an
explicit key with an environment override (default: the historical `wip-gpt` spelling) in the six
preflights and verify-phase1; replace `${workspace_root}/wip-gpt/…` in the five other scripts
(asl-a3, four verify-phase07); report the mach-send mach.ko pin mismatch (`49ac3d89…` pinned,
`9c7706a3…` on disk) without changing the pin, since pins are evidence authority. Check by
evaluating the derivations under all three names. Cause: my op-363 brief asked for
location-derived paths, and my own S gate accepted the result. These are historical phase-0.95
preflights, so the Coordinator may prefer to retire them instead.
