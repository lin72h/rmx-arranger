---
id: op-339
state: draft
agent: implementer wip-gpt
repo: wip-gpt
idq: none (workflow)
gate: self
authority: git commit of named paths only; no build, no guest
updated: 2026-09-27T22:56Z
---
# op-339 — Implementer: align role-governance doctrine and REPORT format with the 2026-09-28 workflow

## Outcome

wip-gpt/docs/role-governance.md agrees with rmx-arranger/roles.md, which is now canonical for roles, edges, and the review rule; where they differ, roles.md wins. The simplest compliant form is a short pointer to roles.md plus only the rules specific to the product repo. wip-gpt/AGENTS.md tells the Implementer to return the REPORT block.

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

- /Users/me/wip-mach/wip-gpt/docs/role-governance.md (canonical doctrine; marked stale on role evolution)
- /Users/me/wip-mach/wip-gpt/AGENTS.md
- Reference, read-only: /Users/me/wip-mach/rmx-arranger/roles.md (canonical), rob-mini-format.md, op-brief-forms.md

## Do / don't

- The repo has about 30 uncommitted paths. Stage by explicit path only (never `git add -A`) and commit just these two files. Push per your repo's normal rule and report on-origin.
- Edit only the files named here. Leave all other files, including existing uncommitted work, untouched.
- Keep your file short and outcome-focused. Do not add a new checklist or restate the whole workflow.
- No guest execution, host configuration, or product-source change.
- Stop and report BLOCKED if a file differs materially from this description.

## REPORT

Return exactly this block:

```text
REPORT op-339
agent:      <role / instance>
outcome:    DONE | PARTIAL | BLOCKED | FAILED — one line
evidence:   <path> sha256:<hash>   (one per line; raw artifacts, not summaries)
commits:    <repo> <hash> on-origin:<yes|no>   (or none)
untested:   <what was not covered, or none>
blockers:   <what stops further progress, or none>
next:       <single smallest next action>
```
