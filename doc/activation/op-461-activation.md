---
id: op-461
state: closed
agent: implementer
repo: rmx-implementer
idq: id-046
gate: self
authority: Mach builds (no world); stage 2 images; 4 self-check boots; no push
expected: 3h
issued-at: 2026-10-04T00:40Z
updated: 2026-10-04T01:48Z
---
# op-461 — Implementer: op-447 remediation (entry revalidation, reply audit)

## Outcome

Context: ordinary bug fixing in our own open-source OS (rmxOS: FreeBSD
15 with Apple's open-source Mach IPC). Everything runs on the host or
in disposable bhyve guests with no network.

Step 4 part 1 (`mach-fixes-4` at `b1ef1670`, your op-447) passed the
Gatekeeper's proof (fixed 52/52) but not review. Continue on that
branch and fix validator3's two findings:
`/Users/me/wip-mach/rmx-validator3/reviews/op-458/op447-review.md`
(`65eded4`), § F1 and § F2. Both were confirmed in the source.

1. **F1: the admitted entry is not revalidated before dequeue.**
   `ipc_mqueue_receive` (`ipc_mqueue.c:693-777`) rechecks only object
   activity and epoch; `mach_msg_receive` keeps `admitted_entry` only
   to release it (`mach_msg.c:342-395`). `mach_port_fdclose`
   (`ipc_entry.c:276-302`) revokes the entry without touching the
   object, and the object dies only at postclose. Between the two, a
   woken receiver can dequeue through a revoked name. Revalidate the
   admitted entry (not revoked, same object and type) at the dequeue
   decision, ordered against revocation, and wake an admitted empty
   receive when its entry is revoked. Keep space-before-object and
   port-before-set lock order. Regression: a controlled case that
   holds the revocation-to-postclose interval open, then delivers:
   no dequeue through the revoked entry, no lost message or right,
   balanced references; for a port and for a set.
2. **F2: kernel MIG replies carry an uninitialized audit token.**
   `ipc_kobject_server` (`ipc_kobject.c:300-442`) sets only the
   format-0 trailer; `ipc_kmsg_alloc` zeroes only under INVARIANTS.
   Initialize the full kernel identity (`KERNEL_AUDIT_TOKEN`, as
   `ipc_kmsg_get_from_kernel` does) where the reply is produced, and
   check the other direct kernel producers for the same gap.
   Regression: an AUDIT receive of a real queued MIG reply checks the
   kernel token, with a control that zeroed allocation cannot hide
   (for example poisoned storage).

Write each test first. Then two images, reusing existing builds where
their inputs are unchanged: base = `b1ef1670` + the new tests, fixed =
the remediation + the same tests (test files byte-identical in both).
Self-check: base, the new cases fail as expected; fixed, all cases
(the 52 and the new ones) pass.

Evidence: the commits; your op record with each finding's cause, fix,
test and expected result on base and fixed; both image hashes and BOMs
(by path); the `selfcheck:` line.

## Limits

- Mach code, Mach headers and Mach tests only. FreeBSD files: the five
  existing hooks as they are; any other change, stop and report.
- No step 4 part 2 (consumers), no pure C1, no D2. No push.
- The three stress cases stay as they are.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
