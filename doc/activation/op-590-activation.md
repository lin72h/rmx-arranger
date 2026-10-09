---
id: op-590
state: closed
agent: implementer
repo: rmx-implementer
idq: id-046
needs: op-586
authority: test-only commits on mach-fixes-6 in wip-rmxos (tests added by op-569, op-583 or op-586); rebuild the RELEASE and KASAN overlays; 6 self-check boots (4 + 2 spare) with the op-583 runner; no push
expected: 3h
issued-at: 2026-10-09T21:46Z
updated: 2026-10-09T21:51Z
---
# op-590 — Implementer: finish the op-583/op-586 self-check — correct the foreign-target fixture, rerun both profiles

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 3 hours.**

Your op-586 diagnosis is right. `mach_vm_contract:foreign_target`'s
child sends its own task port with `file_message.sendFile`, whose
header disposition is 20, `MACH_MSG_TYPE_MAKE_SEND`
(`tests/sys/mach/file_message.zig:24-26`). The child holds only a send
right to its bootstrap port, and `ipc_right.c:1376-1382` correctly
refuses `MAKE_SEND` without a receive right. The product behaved as
it should; the test was wrong. `mach_child_setters.zig:86` makes the
same transfer with `MACH_MSG_TYPE_COPY_SEND`.

1. **Fixture.** Give `mach_vm_contract`'s child transfer a
   `COPY_SEND` destination, as `mach_child_setters.zig:86` does,
   without changing what `file_message.sendFile`'s other callers send.
   One test-only commit on `mach-fixes-6`, parent `8cbd3abf`.
2. **Rebuild** the RELEASE and KASAN overlays from that commit, on the
   same base image `op552-overlay-base-r3.raw` (sha256
   `6f3b6e54606cecfbe3572cf5e2dee156c42499d113909351b811c41abe974059`),
   with your op-586 runner settings (RACCT enabled at the loader).
   Record each overlay's and manifest's sha256.
3. **Self-check both profiles**, RELEASE then KASAN: the full 723-case
   plan and the five MIG modes. Expected on both: every case passes,
   including op-583's and op-586's new cases, the 400-case repeat,
   the five MIG modes exit 0, normal power-off, no assertion or fatal
   trap; on KASAN, no KASAN report.
4. **When a new test is wrong.** If a case added by op-569, op-583,
   op-586 or this op fails because the test itself is wrong (its
   input, setup or expected value contradicts the product behaviour
   those briefs asked for, as in step 1), fix the test in a new
   test-only commit, rebuild, record the failure and the fix, and
   rerun that profile from its install boot, within the six boots.
   If the product is wrong, or an earlier accepted test fails, stop
   and report. Two of the six boots are spares for this and for boots
   that stop before their commands run.

Evidence: add the fixture fix, any further test fixes, the overlay
hashes and both runs (load, ATF counts, MIG modes, power-off line,
serial paths) to `docs/op586-host-task-vm.md`, commit, and update its
`selfcheck:` line.

## Limits

- Test-only commits on `mach-fixes-6` in `wip-rmxos`; no product
  source change. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
