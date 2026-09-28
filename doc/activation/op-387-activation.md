---
id: op-387
state: hold
agent: advisor2
repo: rmx-advisor2
idq: id-042
needs: op-389
gate: self
authority: none
updated: 2026-09-28T07:21Z
---
# op-387 — Advisor 2: libdispatch review at alpha2

## Outcome

This is open-source OS engineering: an internal architecture and code-quality review of rmxOS
code we author and ship. It follows your op-383 Mach kernel consult; keep it in its own document.

The question: at alpha2 `2884304b`, how solid is libdispatch for the 1.0 preview, including the
kernel workqueue it runs on?

Answer in one consult document:
1. Which libdispatch items of your July foundation checklist (and its round-2 review) now hold at
   alpha2 (with source lines), which are still provisional, and which moved or regressed with the
   stable/15 merge.
2. The top risks for the preview, ranked by impact, each with source lines, why it matters, and
   what would retire it; build on your op-383 findings where libdispatch rides on Mach.
3. Proposals, each labeled as a proposal and tied to one of the problem entries named here or to
   a new one you justify.

Architecture and risk only: correctness review of specific ops belongs to the Validators.

Known since July (facts, not claims to re-derive): op-372 passed the dispatch probe's 4 cases on
the alpha2 image, but workqueue (TWQ) attribution was untested. libdispatch conformance and soak
(id-006) retired green on an earlier kernel.

Problem entries: id-042 (the 1.0-preview tracker), id-006 (libdispatch conformance and soak,
retired green).

## Inputs

- Product source `/Users/me/wip-mach/rmx-implementer/wip-rmxos` at
  `2884304b67fc454ee60187ce4731fca01cbefe6a`, read with `git show` and `git diff` only:
  `lib/libdispatch/` and `sys/kern/kern_thrworkq.c`. Diff against base
  `26655e67872cd55cff0a272b32b7895f55368033`.
- Your own July baseline `/Users/me/wip-mach/rmx-advisor2/foundation-mach-ipc-libdispatch-9of10-checklist.md`
  `cbbcdd288fde099cdb8cb7a7e9964090fe3e10f97dfab9cc06d0b8909a84c2cb` (its libdispatch items), and
  `/Users/me/wip-mach/rmx-advisor3/op-319-mach-ipc-libdispatch-foundation-review-round2.md`
  `0f2ed556adfcbee6c542cb6d38810bda3ec1c68ecad2c6434b5ed3dc12b62d53`.

Re-read OPS.md first: defaults and the REPORT block.
