---
id: op-532
state: closed
agent: implementer
repo: rmx-implementer
idq: id-046
authority: test builds only, kernel/mach.ko reused; 2 ZFS images; 2 self-check boots; no push
expected: 1h30m
issued-at: 2026-10-07T05:12Z
updated: 2026-10-07T05:30Z
---
# op-532 — Implementer: clean image pair for mach-fixes-6@ea254222 (no diagnostic fixture)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 1.5 hours.**

`mach-fixes-6` is now `ea254222` (readiness-only Mach kevents, the
recovered-receive fix `ab26bbed`, and the `dup2` test fix). op-526's
images also carry test fixture code that now lives only on
`diag-launchd-reply`, so they do not match the branch. Stage a clean
pair for the proof:
1. Base branch: create `mach-fixes-6-op532-base` at `9478be33` (the
   `dup2` test on the `0facf74b` base, without `b6a0ec3f`).
2. Build the tests and test fixture from `9478be33` and from
   `ea254222`; they must be byte-identical. Reuse the kernel and
   `mach.ko` builds: base from `0facf74b`, fixed from `ab26bbed`
   (`ea254222` changes only tests).
3. Two ZFS images from `op417-alpha2-zfs-gpt.raw` as before; show from
   the METALOG/BOM diff that they differ only in the kernel and
   `mach.ko`, and that their test files match the op-526 images except
   the launchd test fixture library.
4. Self-check: base, `mach_recovered_readiness_test:recovered_receive`
   FAIL with its readiness reason; fixed, all 88 cases. A
   `launchd control reply missing` in a launchd consumer case is the
   known id-061 problem: record it, do not count it against the pair.

Evidence: the branch, both image hashes and BOMs (by path), a short
record (`docs/op532-clean-pair.md`), the `selfcheck:` line.

## Limits

- No source change. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
