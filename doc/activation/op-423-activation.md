---
id: op-423
state: closed
agent: validator2
repo: rmx-validator2
idq: id-046
gate: self
authority: none beyond the defaults: read-only; no guests
updated: 2026-10-02T09:07Z
---
# op-423 — Validator 2: review op-420 — Mach batch 2 (entry and reference handling on the fd backend, plus two FreeBSD hooks)

## Outcome

Context: ordinary bug fixing in our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source Mach IPC). Review the code, not attack scenarios.

Review op-420 (Implementer). You are the only reviewer. It implements step 2 of the decided Mach
design: entry and reference handling while Mach port names stay file descriptors. Branch
`mach-fixes-2`, 7 commits from `mach-fixes-1` (`903c8fc2`) to `wip-rmxos@ee883a74a2b2`. The design is
advisor2's op-394 proposal (`rmx-advisor2@519ec47`, § A option A1, step 2). The binding rules were:
- entries keep their own references and urefs, the fd is a proxy holding one entry reference, and
  Mach code never derives urefs from or edits `f_count`;
- closing a Mach name revokes it under its space lock, through a descriptor-removal hook, and
  `dup`/`dup2` of a Mach name are refused;
- kernel objects hold references, never names, and knotes pin the entry;
- only two FreeBSD-side changes are allowed: `fo_fdpostclose` in a spare `struct fileops` slot, and
  `DFLAG_NODUP` (commits `bc8852bd`, `0df2b329`).

Targets: op-389 #2; op-392 S2, S3 and S4's entry causes. The Implementer's mapping:
`/Users/me/wip-mach/rmx-implementer/docs/op420-mach-entry-handling.md`.

Check:
1. Each target is fixed at its cause, and each new test would detect it on `mach-fixes-1`.
2. **Lock order and lifetime:** the descriptor-table lock, the space lock and object locks are
   never taken in conflicting orders; the post-close hook does its work after the descriptor lock is
   released; no entry or object is used after its last reference.
3. **Every descriptor-removal path** calls the hook exactly once: close, close_range, dup2
   replacement, close-on-exec, `fdclose`, and exit (`fdescfree_fds`).
4. **The FreeBSD-side commits** change only what they say, keep `struct fileops`' size, and leave
   every other file type's behaviour unchanged.
5. Batch-1 fixes are not reverted.

Distinguishing question: does any path still let a Mach name, entry or right outlive its owner, or
be freed while still reachable?

Re-read OPS.md first: defaults and the REPORT block.
