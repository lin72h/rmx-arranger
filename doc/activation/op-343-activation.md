---
id: op-343
state: draft
agent: validator glm
repo: wip-glm
idq: none (workflow)
gate: self
authority: file edit only (not a git repo)
updated: 2026-09-27T22:56Z
---
# op-343 — Validator GLM: output contract and single-reviewer mode

## Outcome

wip-glm/AGENTS.md states the REPORT output with score and verdict, and one line on single-reviewer mode: at an L gate your score alone closes the op at >=8, so your confidence ceilings carry full weight. validator-rulebook.md changes only where it contradicts the new review rule.

The Arranger workflow was simplified on 2026-09-28. What changes for you:
- Every brief now ends with a REPORT template. Return exactly that block (format below).
- Op states are now draft / issued / returned / hold / closed / dropped, and the Arranger sets them;
  you never do. The old tags and terms ([Exe], [Done], [Retired], [Flushed], ROB, EXU, DISPATCH
  line, op-NNNm) are retired. Remove them from your instructions rather than translating them.
- Review is sized by risk: S/M the Arranger checks itself; L goes to one Validator; XL or
  release-critical-path goes to both. An op closes at >=8/10, with agreement when two review.
- Briefs and REPORTs are still relayed by hand through the Coordinator. Your authority, repo, and
  safety rules do not change.

REPORT format to adopt (Validators add `score: <n>/10` and `verdict: CLOSE | DO-NOT-CLOSE | REMEDIATE`):

    REPORT op-NNN
    agent:      <role / instance>
    outcome:    DONE | PARTIAL | BLOCKED | FAILED - one line
    evidence:   <path> sha256:<hash>   (one per line; raw artifacts, not summaries)
    commits:    <repo> <hash> on-origin:<yes|no>   (or none)
    untested:   <what was not covered, or none>
    blockers:   <what stops further progress, or none>
    next:       <single smallest next action>


## Inputs

- /Users/me/wip-mach/wip-glm/AGENTS.md
- /Users/me/wip-mach/wip-glm/validator-rulebook.md (shared text; DS4P copies your final version in op-344)

## Do / don't

- Edit only the files named here. Leave all other files, including existing uncommitted work, untouched.
- Keep your file short and outcome-focused. Do not add a new checklist or restate the whole workflow.
- No guest execution, host configuration, or product-source change.
- Stop and report BLOCKED if a file differs materially from this description.

## REPORT

Return exactly this block:

```text
REPORT op-343
agent:      <role / instance>
outcome:    DONE | PARTIAL | BLOCKED | FAILED — one line
evidence:   <path> sha256:<hash>   (one per line; raw artifacts, not summaries)
commits:    <repo> <hash> on-origin:<yes|no>   (or none)
untested:   <what was not covered, or none>
blockers:   <what stops further progress, or none>
next:       <single smallest next action>
```
