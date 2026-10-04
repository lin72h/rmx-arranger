---
id: op-483
state: issued
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-046
authority: 5 boots max on copies of the op478 base and op481 pair, 5 min each; doas vmm.ko, bhyve; push rmx-gatekeeper1 main
expected: 1h
issued-at: 2026-10-04T20:25Z
updated: 2026-10-04T20:25Z
---
# op-483 — Gatekeeper 1: proof of op-478 and op-481 (partial receive, libmach mach_msg_destroy)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 1 hour.**

Your op-475 proved op-468 (`mach-fixes-5@015e7723`). Two more steps
followed on the same branch, and this op proves both, with the whole
suite on the final image:
- op-478 (`22334ca3`): libdispatch releases what a receive that
  returns `MACH_RCV_BODY_ERROR` already delivered; new cases
  `dispatch_mach_test:partial_receive_cleanup` (expected FAIL before,
  PASS after) and `:pending_request_cancel` (a control, PASS on
  both).
- op-481 (`b2d5f5b7`): libmach's `mach_msg_destroy` walks a complex
  message's own descriptors (before, it read stack memory), and
  libdispatch now calls it; new cases
  `mach_destroy_test:destroy_ports_first` and `:destroy_ool_first`
  (FAIL before, PASS after).
Expected results: `/Users/me/wip-mach/rmx-implementer/docs/op478-libdispatch.md`
and `/Users/me/wip-mach/rmx-implementer/docs/op481-libmach.md`.

Images (work on copies; check from the BOMs that each pair's test
files are byte-identical and that only libdispatch (op-478) or
libmach and libdispatch (op-481) differ):
- op-478 base = `015e7723` + its tests:
  `/Users/me/wip-mach/stage/images/op478-base-tests.raw`
  sha256 `000d7f99d96838298f4074c626d292b521413477b4a5211123745e5745c2e432`
  BOM `/Users/me/wip-mach/stage/artifacts/op478-base-tests-stage/bom.json`
- op-481 base = `22334ca3` + its tests:
  `/Users/me/wip-mach/stage/images/op481-base-tests.raw`
  sha256 `216f201198d7283305b54603173f045604234b65f0a732e614feec7a738b0060`
  BOM `/Users/me/wip-mach/stage/artifacts/op481-base-tests-stage/bom.json`
- final = `b2d5f5b7` + all tests:
  `/Users/me/wip-mach/stage/images/op481-fixed-tests.raw`
  sha256 `f5f0684e6122ed1c4e13c9fae78969dbd779087b061d258d6f8df25e9245b6c9`
  BOM `/Users/me/wip-mach/stage/artifacts/op481-fixed-tests-stage/bom.json`

Use your op-475 harness, extended to the four new cases; check every
command against the image first.
1. op-478 base: one boot with its two cases: `partial_receive_cleanup`
   FAILS with its recorded reason, `pending_request_cancel` PASSES.
2. op-481 base: one boot with its two cases, both FAIL with their
   recorded reason.
3. Final: one boot with all 65 cases (your 61 from op-475 and the
   four new ones), all expected to PASS; none should hang.

Result: one table, expected against observed, with the serial line
for each case, each FAIL's printed reason, and every mismatch listed.
The Implementer's self-checks: op-478 base 2/2 as expected; op-481
base 2/2 as expected, final 65/65.

Evidence by path; hash only each boot's raw serial log. Commits on
origin.

## Limits

- No product edits. If one case cannot run, record it and finish the
  others.

Re-read OPS.md first: defaults and the reply block.
