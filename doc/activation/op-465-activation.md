---
id: op-465
state: draft
agent: validator3
repo: rmx-validator3
idq: id-046
gate: self
authority: none beyond the defaults: read-only; no guests
expected: 90m
updated: 2026-10-04T01:32Z
---
# op-465 — Validator 3: re-review after op-461 (entry check, reply identity)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Review the source.

Re-review step 4 part 1 after the fixes for your op-458 findings: five
commits on `mach-fixes-4`, from `b1ef1670` to `wip-rmxos@0924690c`.
Source: `/Users/me/wip-mach/rmx-implementer/build/op426/source`. The
Implementer's record:
`/Users/me/wip-mach/rmx-implementer/docs/op461-mach-remediation.md`.

Check:
1. **F1, admitted entry** (test `2d978369`, fix `60099afc`): the
   receive path now holds the space read lock across the decision and
   the message claim, and rechecks the exact admitted entry (not
   revoked, still published, same object and receive type) before
   object activity and epoch. `mach_port_fdclose` revokes under the
   space write lock, then locks the receive object and wakes it.
   Confirm the ordering against revocation, the space-before-object
   and port-before-set lock order, that no space lock is taken while
   the object mutex is held, and the deadline and signal paths.
2. **F2, kernel reply identity** (test `8ebcce09`, fix `b9aeeb28`):
   `ipc_kmsg_init_kernel_trailer` zeroes the whole maximum trailer and
   sets `KERNEL_SECURITY_TOKEN` and `KERNEL_AUDIT_TOKEN`; it is called
   by `ipc_kobject_server`, `ipc_kmsg_get_from_kernel` and the five
   direct producers in `ipc_notify.c`. Confirm no direct kernel
   producer is left out, and that user send-time identity is kept.
3. **Tests:** `revoked_port`, `revoked_set` and `kernel_reply_audit`
   would detect each defect at `b1ef1670`; the audit test's control
   fills the reply storage with a known non-zero pattern, so zeroed
   allocation cannot make it pass. The test-only fix `0924690c` adds
   the queued message's destination reference to the expected port
   count: confirm it is correct and does not weaken the check.
4. **Scope:** only Mach code, Mach headers and Mach tests changed.

Distinguishing question: is there an ordering in which a receive still
claims a message through an entry revoked before postclose, or a
kernel-produced message that reaches a receiver without its identity
set?

Re-read OPS.md first: defaults and the reply block.
