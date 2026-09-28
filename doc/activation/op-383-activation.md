---
id: op-383
state: draft
agent: advisor2
repo: rmx-advisor2
idq: id-042
gate: self
authority: none
updated: 2026-09-28T06:14Z
---
# op-383 — Advisor 2: foundation review at alpha2 — Mach IPC and libdispatch

## Outcome

This is open-source OS engineering: an internal architecture and code-quality review of rmxOS
code we author and ship. It is also your first consult under the workflow adopted on 2026-09-28:
read AGENTS.md, OPS.md, and LOCAL.md first. The Oracle-era consults in your repo are history.

The question: at alpha2 `2884304b`, how solid is the Mach IPC and libdispatch foundation for the
1.0 preview?

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

Known since July (facts, not claims to re-derive): op-372 booted the alpha2 image contained, with
`mach.ko` loaded and the Mach probe (4 cases) and dispatch probe (4 cases) passing; workqueue (TWQ)
attribution was untested. `mach.ko` needs the kernel's LOCAL `knote_enqueue`, resolved only
through `debug.link_elf_leak_locals` (default 1). libdispatch conformance and soak retired green on
an earlier kernel.

Problem entries: id-042 (the 1.0-preview tracker), id-045 (the leak-locals dependency), id-016
(ambient Mach bootstrap and PID-1 launchd).

## Inputs

- Product source `/Users/me/wip-mach/rmx-implementer/wip-rmxos` at `2884304b67fc454ee60187ce4731fca01cbefe6a`, read with `git show` and `git diff` only:
  `sys/compat/mach/`, `lib/libmach/`, the MIG definitions, `lib/libdispatch/`, and
  `sys/kern/kern_thrworkq.c`. Diff against base `26655e67872cd55cff0a272b32b7895f55368033`.
- Your own July baseline, sha256: `/Users/me/wip-mach/rmx-advisor2/foundation-mach-ipc-libdispatch-9of10-checklist.md`
  `cbbcdd288fde099cdb8cb7a7e9964090fe3e10f97dfab9cc06d0b8909a84c2cb` and its round-2 review
  `/Users/me/wip-mach/rmx-advisor3/op-319-mach-ipc-libdispatch-foundation-review-round2.md`
  `0f2ed556adfcbee6c542cb6d38810bda3ec1c68ecad2c6434b5ed3dc12b62d53`.

Re-read OPS.md first: defaults and the REPORT block.
