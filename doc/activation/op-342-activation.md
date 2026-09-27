---
id: op-342
state: draft
agent: oracle rmx-oracle
repo: rmx-oracle
idq: none (workflow)
gate: self
authority: file edit only (not a git repo)
updated: 2026-09-27T22:56Z
---
# op-342 — Oracle: replace the retired OoO vocabulary in AGENTS.md

## Outcome

rmx-oracle/AGENTS.md describes the workflow in current terms: ops, the six states, risk-sized review with >=8, and hand relay. The ROB/EXU/L1i-fetch tutorial (about lines 40-65) and the 'both >=8 AND agree' rule are gone or replaced, and consult answers end with the REPORT block.

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

- /Users/me/wip-mach/rmx-oracle/AGENTS.md (and oracle-rulebook.md only where it restates those terms)

## Do / don't

- Edit only the files named here. Leave all other files, including existing uncommitted work, untouched.
- Keep your file short and outcome-focused. Do not add a new checklist or restate the whole workflow.
- No guest execution, host configuration, or product-source change.
- Stop and report BLOCKED if a file differs materially from this description.

## REPORT

Return exactly this block:

```text
REPORT op-342
agent:      <role / instance>
outcome:    DONE | PARTIAL | BLOCKED | FAILED — one line
evidence:   <path> sha256:<hash>   (one per line; raw artifacts, not summaries)
commits:    <repo> <hash> on-origin:<yes|no>   (or none)
untested:   <what was not covered, or none>
blockers:   <what stops further progress, or none>
next:       <single smallest next action>
```
