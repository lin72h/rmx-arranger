---
id: op-365
state: draft
agent: validator1
repo: rmx-validator1
idq: none (onboarding)
gate: self
authority: none
updated: 2026-09-28T00:46Z
---
# op-365 — Validator 1: onboarding with a calibration review of op-363

## Outcome

You are Validator 1 (GLM), starting fresh under the workflow adopted on 2026-09-28. Your repo was
renamed from `wip-glm` to `/Users/me/wip-mach/rmx-validator1`, and its instructions are now
rendered from the validator template. Earlier session context is superseded. This op succeeds when
you have read AGENTS.md, OPS.md, validator-rulebook.md, and LOCAL.md, and returned a calibration
review in the REPORT format from your OPS.md.

The review is practice. op-363 is already closed, three Validators review it independently, and
your verdict changes nothing. Name your own distinguishing question. op-363 asked the Implementer
to stop seven tracked scripts from hard-coding `/Users/me/wip-mach/wip-gpt`. Check these claims:

1. Commit `d58169e0972e1cbd1d09c0e0c5b3035f183ff8cd` in `/Users/me/wip-mach/rmx-implementer1`
   changes exactly the seven scripts under `scripts/` and nothing else.
2. `git grep -n /Users/me/wip-mach/wip-gpt -- scripts` in that repo prints nothing.
3. Each of the six `preflight-*` scripts still resolves its source tree and kernel objdir paths
   correctly, however it is invoked. Existing objdirs are under
   `/Users/me/wip-mach/build/wip-rmxos-alpha-obj/`, and the repo can also be reached through
   the symlinks `/Users/me/wip-mach/rmx-implementer` and `/Users/me/wip-mach/wip-gpt`.

Report anything in AGENTS.md, OPS.md, or the rulebook that is unclear or conflicts, under
`blockers`.

## Limits

- Do not run the scripts. Reading them, `sh -n`, and evaluating their path-derivation lines on
  their own are fine.

Defaults and the REPORT block: OPS.md in your repo.
