---
id: op-385
state: hold
agent: advisor2
repo: rmx-advisor2
idq: id-042
needs: op-384
gate: self
authority: none
updated: 2026-09-28T06:14Z
---
# op-385 — Advisor 2: launchd service hosting review at alpha2

## Outcome

This is open-source OS engineering: an internal architecture and code-quality review of rmxOS
code we author and ship. It is the second (or third) of three consults you run in sequence; keep
each in its own document.

The question: at alpha2 `2884304b`, how solid is launchd's service hosting for the 1.0 preview:
launchd, liblaunch, and launchctl, hosting services through MachServices and nvlist?

Answer in one consult document:
1. Which items of the baseline below now hold at alpha2 (with source lines), which are still
   provisional, and which moved or regressed with the stable/15 merge.
2. The top risks for the preview, ranked by impact, each with its source lines, why it matters,
   and what would retire it.
3. Proposals, each labeled as a proposal and tied to one of the problem entries named here or to
   a new one you justify.

Architecture and risk only: correctness review of specific ops belongs to the Validators.
alpha2 `2884304b` is the preview candidate: alpha `26655e67` plus the upstream FreeBSD stable/15
merge and a release profile.

Out of scope: the PID-1 activation contract (op-318, corrected by op-322 and amended by op-377 and
op-380), which is being executed now. Name it where it touches your findings; do not re-review it.

Known since July (facts, not claims to re-derive): the Coordinator ruled on 2026-09-28 that
MachServices plus nvlist is the preview service plane, and that literal `xpc_domain` hosting is
deferred past the preview. On alpha2, launchd bootstraps each session by running
`/bin/launchctl bootstrap -S`, which loads plists from `/etc/launchd.d`.

Problem entries: id-042 (the 1.0-preview tracker), id-016 (PID-1 launchd and ambient bootstrap),
id-030 (launchd plist fidelity), id-040 (aslmanager's managed-server versus periodic reclaim).

## Inputs

- Product source `/Users/me/wip-mach/rmx-implementer/wip-rmxos` at `2884304b67fc454ee60187ce4731fca01cbefe6a`, read with `git show` and `git diff` only:
  `sbin/launchd/`, `lib/liblaunch/`, and `bin/launchctl/`. Diff against base
  `26655e67872cd55cff0a272b32b7895f55368033`.
- Your own July baseline, sha256: `/Users/me/wip-mach/rmx-advisor2/launchd-9of10-checklist.md`
  `94a34e9ce26ee0fa6ad0193e1a6599eb81c276523ec4386fb9de617249019f5d`.

Re-read OPS.md first: defaults and the REPORT block.
