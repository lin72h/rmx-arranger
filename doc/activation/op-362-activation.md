---
id: op-362
state: closed
agent: implementer
repo: rmx-implementer
idq: id-042
gate: self
authority: none
updated: 2026-09-27T23:54Z
---
# op-362 — Implementer: index the alpha2 build chain from disk

## Outcome

`docs/alpha2-build-chain.md` exists and is committed, so the Coordinator can review the alpha2
build evidence by hand without opening each build directory. It contains:

1. One row per op-numbered directory under `build/` from op-335 through op-358, plus the
   workspace-level `/Users/me/wip-mach/build/rmxos-alpha2-full-*` and
   `alpha2-stable15-sync-20260921-evidence` directories: what the op did, its input (candidate
   path, HEAD, tree), its outputs with SHA-256, the recorded result (return codes, verdict), and
   whether a later op superseded it. Write "not recorded" where a directory records nothing.
2. The current deliverable: the op-358 image and UFS with hashes, the kernel and mach.ko hashes
   and where each was built, and the loader.conf change.
3. Open caveats as the evidence states them: static-only mach.ko compatibility, the clang 19.1.7
   vs clang/LLD 21.1.8 toolchain difference, the uncommitted profile paths in the candidate, and
   that nothing has been mounted or booted.
4. The effective NFS/Kerberos policy after op-340, in two or three lines.

## Limits

- Do not modify, move, or delete anything under `build/`, `../build/`, or the candidate worktree.
- Quote evidence paths as recorded (many use the old `wip-gpt` path); write any new path as
  `/Users/me/wip-mach/rmx-implementer/...`.

Defaults and the REPORT block: OPS.md in your repo.
