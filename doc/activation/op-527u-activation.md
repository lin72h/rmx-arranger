---
id: op-527u
state: draft
cast: unicast
agent: implementer
repo: rmx-implementer
idq: id-000
updated: 2026-10-07T02:41Z
---
# op-527u — Implementer: AGENTS.md attempt accounting, self-check boots fix and rerun

## Message

changed:  AGENTS.md § Attempt accounting (implementer0 template,
          rmx-implementer@081ac22; rendered into AGENTS.md when you
          receive this)
meaning:  The "stop and do not rerun without a new op" rule is for
          evidence runs. Your own self-check boots are not evidence:
          when one fails because of a test, fixture, harness or setup
          mistake, or a defect in the change your op makes, fix it in
          the op and boot again within the op's boot budget. Keep every
          boot's serial log and record each boot and correction. Stop
          and report only when the fix needs authority or scope the op
          does not grant, the cause is not understood, or the budget is
          used up. This applies to op-526 now (its scope still excludes
          kernel changes).
action:   re-read AGENTS.md § Attempt accounting before your next boot

This is a cast: no reply is expected.
