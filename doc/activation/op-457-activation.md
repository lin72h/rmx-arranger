---
id: op-457
state: closed
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-046
gate: self
authority: 4 boots max on copies of the r5 pair, 5 min each; doas vmm.ko, bhyve
expected: 2h
issued-at: 2026-10-04T00:25Z
updated: 2026-10-04T00:38Z
---
# op-457 — Gatekeeper 1: proof of op-447 (Mach step 4 part 1)

## Outcome

Context: ordinary bug fixing in our own open-source OS (rmxOS: FreeBSD 15
with Apple's open-source Mach IPC). Everything runs in disposable bhyve
guests with no network.

Prove Mach step 4 part 1 (`mach-fixes-4` at `b1ef1670`, op-447) before
and after, with the batch-1 to batch-3 suite on the fixed image.
Expected results: `tests/sys/mach/EXPECTATIONS.md` § "op-447 step 4
part 1" on that branch, and
`/Users/me/wip-mach/rmx-implementer/docs/op447-mach-step4-part1.md`.

Images (work on copies; the tests are byte-identical in both, and only
the kernel and `mach.ko` differ):
- base = batch 3 + the tests:
  `/Users/me/wip-mach/stage/images/op447-base-tests-r5.raw`
  sha256 `ded8c324f26e60b08d4fbd7030e4dbe0aff144ba760b9f53bc95299752a107e3`
- fixed = step 4 part 1 + the tests:
  `/Users/me/wip-mach/stage/images/op447-fixed-tests-r5.raw`
  sha256 `526843ee01c51ffdb3e1820e35b61471bed41b7d003dccab35fd854cd4db2f74`

Use your op-441 harness, extended to the 11 new cases (check every
command against the image first):
1. Base: one boot with the 11 new cases. Expected: all FAIL with their
   recorded reason. `first_copyout` and the scheduling cases
   (`wait_large`, `queued_member`) are stress: a base PASS there is
   recorded as "not triggered", not as a product mismatch.
2. Fixed: one boot with all 52 cases (41 earlier + 11 new), all
   expected to PASS. Every case must reach its named check; none
   should hang.

Result: one table, expected against observed, with the serial line for
each case, each FAIL's printed reason, and every mismatch listed. The
Implementer's own self-check was fixed 52/52, base 11/11; this proof is
the independent run.

Evidence by path; hash only each boot's raw serial log. Commits on
origin.

## Limits

- No product edits. If one case cannot run, record it and finish the
  others.

Re-read OPS.md first: defaults and the reply block.
