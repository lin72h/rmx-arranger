---
id: op-367
state: draft
agent: validator3
repo: rmx-validator3
idq: none (onboarding)
gate: self
authority: none
updated: 2026-09-28T00:46Z
---
# op-367 — Validator 3: onboarding with a calibration review of op-363

## Outcome

You are Validator 3, starting fresh under the workflow adopted on 2026-09-28. Your repo is
`/Users/me/wip-mach/rmx-validator3`. Its instructions (AGENTS.md, OPS.md, validator-rulebook.md)
are rendered from the validator template: never edit them, and keep your own notes and new lessons
in LOCAL.md. Earlier session context is superseded. This op succeeds when you have read those four
files and returned a calibration review in the REPORT format from your OPS.md.

The review is practice. op-363 is already closed, three Validators review it independently, and
your verdict changes nothing. Name your own distinguishing question. op-363 asked the Implementer
to stop seven tracked scripts from hard-coding `/Users/me/wip-mach/wip-gpt`. Check these claims:

1. Commit `d58169e0972e1cbd1d09c0e0c5b3035f183ff8cd` in `/Users/me/wip-mach/rmx-implementer`
   changes exactly the seven scripts under `scripts/` and nothing else.
2. `git grep -n /Users/me/wip-mach/wip-gpt -- scripts` in that repo prints nothing.
3. Each of the six `preflight-*` scripts still resolves its source tree and kernel objdir paths
   correctly, however it is invoked. Existing objdirs are under
   `/Users/me/wip-mach/build/wip-rmxos-alpha-obj/`. The Implementer repo is reachable under
   three names, `/Users/me/wip-mach/rmx-implementer`, `rmx-implementer1`, and `wip-gpt`: one
   real folder and two symlinks to it.

Report anything in AGENTS.md, OPS.md, or the rulebook that is unclear or conflicts, under
`blockers`.

## Limits

- Do not run the scripts. Reading them, `sh -n`, and evaluating their path-derivation lines on
  their own are fine.

Defaults and the REPORT block: OPS.md in your repo.
