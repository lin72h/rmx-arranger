---
id: op-404
state: draft
agent: explorer1
repo: rmx-explorer1
idq: id-016
gate: self
authority: none beyond the defaults: documentation only; no guests; push rmx-explorer1 main
updated: 2026-10-01T09:27Z
---
# op-404 — Explorer 1: add six Tier-2 controls to the op-401 kernel-side amendment (remediation from op-402 and op-403)

## Outcome

Context: ordinary debugging of our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source launchd as PID 1), in a disposable VM with no network.

Both reviewers of your op-401 note (`findings/nx-r64z/20261001-op401-tier-u-kernel-side.md` at
`f1df370`) confirmed the observation design and every citation. Both found that some of the
note's own rules have no Tier-2 control (validator1 `669b877`, validator2 `07ac8fd`).

Add these six controls to the note's Tier-2 table, in its own style. Each is one difference from
the known-good record, with the required classifier result:
1. An OBSERVED axis plus one required record deleted elsewhere: HARNESS-NOT-ACCEPTED. Missing
   data is not excused by an OBSERVED axis.
2. One still-blocked final `wait4` entry recorded as an explicit open entry: accepted, not
   rejected as a missing return.
3. The sustained (c) series attributed to the main thread instead of the detached thread: (c) is
   not OBSERVED.
4. Two candidate threads matching the detached-thread pattern: the thread-specific axes are
   INCONCLUSIVE and the cell HARNESS-NOT-ACCEPTED.
5. Kernel-derived and copied status disagree on one W1 exit: the note's disagreement rule
   applies, with the result it names.
6. A NULL-pointer return carrying a status labelled as a userspace copy: rejected
   (`status_source` integrity).

Commit the change as an addendum section. Keep the rest of the note as it is.

## Limits

- Documentation only. If a control cannot be stated as a single difference, say why.

Re-read OPS.md first: defaults and the REPORT block.
