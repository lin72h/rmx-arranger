---
id: op-384
state: hold
agent: advisor2
repo: rmx-advisor2
idq: id-042
needs: op-387
gate: self
authority: none
updated: 2026-09-28T06:18Z
---
# op-384 — Advisor 2: libnotify and notifyd review at alpha2

## Outcome

This is open-source OS engineering: an internal architecture and code-quality review of rmxOS
code we author and ship. It is the second (or third) of three consults you run in sequence; keep
each in its own document.

The question: at alpha2 `2884304b`, how solid are libnotify and notifyd for the 1.0 preview?

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

Known since July (facts, not claims to re-derive): libnotify and notifyd retired green on all four
conformance legs (op-165), on an earlier kernel with `mach.ko` `9c7706a3…`. alpha2 ships a rebuilt
`mach.ko` (`53e5a8cf…`) on a kernel with the stable/15 merge. A notifyd shared-memory sizing guard
(page, count, and byte limits) was banked as post-preview hardening after op-270.

Problem entries: id-042 (the 1.0-preview tracker), id-010 (libnotify and notifyd conformance,
retired green), id-041 (the shared-memory sizing guard).

## Inputs

- Product source `/Users/me/wip-mach/rmx-implementer/wip-rmxos` at `2884304b67fc454ee60187ce4731fca01cbefe6a`, read with `git show` and `git diff` only:
  `lib/libnotify/` and `usr.sbin/notifyd/`, plus the Mach and libdispatch interfaces they use.
  Diff against base `26655e67872cd55cff0a272b32b7895f55368033`.
- Earlier findings, sha256: `/Users/me/wip-mach/rmx-advisor1/op-262-notifyd-name-table-findings.md`
  `1aefd784f29409e02f34ebb704146ed0c74c81d308955e3fd7bb5f18a9f80c93` and your own
  `op-270-notifyd-shared-memory-slot-lifecycle.md`
  `7b4c6c6da35e1b81901ea6ba3340c8f12cd67aad14ddd34a9972a58ae53bdc97`.

Re-read OPS.md first: defaults and the REPORT block.
