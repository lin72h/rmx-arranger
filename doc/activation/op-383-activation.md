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
# op-383 — Advisor 2: Mach kernel review at alpha2 — Mach IPC and its FreeBSD integration

## Outcome

This is open-source OS engineering: an internal architecture and code-quality review of rmxOS
code we author and ship. It is also your first consult under the workflow adopted on 2026-09-28:
read AGENTS.md, OPS.md, and LOCAL.md first. The Oracle-era consults in your repo are history.

The question: at alpha2 `2884304b`, how solid is the Mach kernel side for the 1.0 preview: Mach
IPC in `mach.ko` and every point where it integrates with FreeBSD? libdispatch is the next consult,
not this one.

Answer in one consult document:
1. Which Mach-side items of your July foundation checklist (and its round-2 review) now hold at
   alpha2 (with source lines), which are still provisional, and which moved or regressed with the
   stable/15 merge.
2. The FreeBSD integration surface, traced from both sides: the Mach traps in `syscalls.master`
   and the generated `init_sysent.c`, `syscalls.c`, and `systrace_args.c`; `EVFILT_MACHPORT` and
   `knote_enqueue` in `kern_event.c` and `sys/event.h`; `sys/file.h`; the headers and MIG
   definitions under `sys/sys/mach/`; the module build in `sys/modules/mach/`; and every hook the
   module registers itself (process exit and fork, event handlers, initialization order, module
   load and unload). For each: is it stable against the stable/15 merge, and what breaks if FreeBSD
   changes underneath it?
3. The top risks for the preview, ranked by impact, each with source lines, why it matters, and
   what would retire it.
4. Proposals, each labeled as a proposal and tied to one of the problem entries named here or to
   a new one you justify.

Architecture and risk only: correctness review of specific ops belongs to the Validators.
alpha2 `2884304b` is the preview candidate: alpha `26655e67` plus the upstream FreeBSD stable/15
merge and a release profile.

Known since July (facts, not claims to re-derive): op-372 booted the alpha2 image contained, with
`mach.ko` loaded and the Mach probe passing all 4 cases. `mach.ko` needs the kernel's LOCAL
`knote_enqueue`, resolved only through `debug.link_elf_leak_locals` (default 1). alpha2's
`kern_exit.c` gained stable/15's zombie-reference changes.

Problem entries: id-042 (the 1.0-preview tracker), id-045 (the leak-locals dependency), id-016
(ambient Mach bootstrap and PID-1 launchd).

## Inputs

- Product source `/Users/me/wip-mach/rmx-implementer/wip-rmxos` at
  `2884304b67fc454ee60187ce4731fca01cbefe6a`, read with `git show` and `git diff` only:
  `sys/compat/mach/`, `sys/sys/mach/`, `sys/modules/mach/`, `lib/libmach/` (the user side of the
  traps), and the FreeBSD files named above. Diff against base
  `26655e67872cd55cff0a272b32b7895f55368033`.
- Your own July baseline, sha256: `/Users/me/wip-mach/rmx-advisor2/foundation-mach-ipc-libdispatch-9of10-checklist.md`
  `cbbcdd288fde099cdb8cb7a7e9964090fe3e10f97dfab9cc06d0b8909a84c2cb` (its Mach items), and its
  round-2 review `/Users/me/wip-mach/rmx-advisor3/op-319-mach-ipc-libdispatch-foundation-review-round2.md`
  `0f2ed556adfcbee6c542cb6d38810bda3ec1c68ecad2c6434b5ed3dc12b62d53`.

Re-read OPS.md first: defaults and the REPORT block.
