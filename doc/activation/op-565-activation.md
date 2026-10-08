---
id: op-565
state: draft
agent: implementer
repo: rmx-implementer
idq: id-047
authority: sys/compat/mach assertion fixes and tests; kernel, mach.ko and test builds via tools/ci/build; overlays; 6 self-check boots; no push
expected: 4h
updated: 2026-10-08T05:36Z
---
# op-565 — Implementer: fix assertion-only defects found with mach.ko's INVARIANTS enabled (first: ipc_right.c:278), then RELEASE and KASAN full suites

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 4 hours.**

op-562 built CI's build stage and ran the first suites with `mach.ko`
built with its kernel, so its INVARIANTS assertions now run. Both
RELEASE and KASAN stopped in `xpc_receive_test:suspended_barrier`
(case 7) at `sys/compat/mach/ipc/ipc_right.c:278`: in
`ipc_right_dnrequest`, `port` starts as `NULL` (`:270`) and
`ip_unlock_assert(port)` runs on the first loop pass, reading
`&port->ip_object` (`sys/sys/mach/ipc/ipc_port.h:287`). Without
INVARIANTS that line compiled to nothing. More assertion-only defects
may follow; handle them in this op. Continue on `mach-fixes-6` (local
head `ff8a4d60`, which carries `testing-1`'s build changes).

Rules:
1. **Assertion-only defects:** where an assertion itself is wrong (it
   reads a pointer that may be `NULL`, checks a lock state the code
   does not promise at that point, or similar) and the code it guards
   is correct, fix the assertion. First: check `port` before
   `ip_unlock_assert(port)` at `:278`. Each fix is its own commit with
   the reason in file:line.
2. **Real defects:** where an assertion or a KASAN report shows the
   code itself is wrong (a lock not held, a use after release, a
   double release), do not fix it here: record it with the serial
   lines, the stack and file:line, skip that case for the rest of the
   op if needed, and continue the suite.
3. **Runs:** after each fix, rebuild with `tools/ci/build` and run the
   full suite (all 93 earlier cases and the five MIG modes) on both
   RELEASE and KASAN overlays, until both finish or the boots run
   out. A case that stops the guest gets one re-run after its fix.

No pair needed in this op: these are assertion corrections; the
proof will compare against op-562's overlays.

Evidence: commits; your op record (`docs/op565-invariants.md`): each
assertion-only fix with its reason, each real defect recorded, the
final results per profile (ATF counts, any report with its serial
lines); final overlay hashes; the `selfcheck:` line.

## Limits

- Assertion corrections in `sys/compat/mach` only; real defects are
  recorded, not fixed. No library, launchd or test change. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
