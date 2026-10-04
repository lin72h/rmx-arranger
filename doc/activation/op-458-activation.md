---
id: op-458
state: draft
agent: validator3
repo: rmx-validator3
idq: id-046
gate: self
authority: none beyond the defaults: read-only; no guests
expected: 2h
updated: 2026-10-04T00:23Z
---
# op-458 — Validator 3: review op-447 (Mach step 4 part 1)

## Outcome

Context: ordinary bug fixing in our own open-source OS (rmxOS: FreeBSD
15 with Apple's open-source Mach IPC). Review the source.

Review Mach step 4 part 1: 19 commits on `mach-fixes-4`, from
`844112f4` (batch 3, your op-440) to `wip-rmxos@b1ef1670`. Source:
`/Users/me/wip-mach/rmx-implementer/build/op426/source`. The
Implementer's record: `/Users/me/wip-mach/rmx-implementer/docs/
op447-mach-step4-part1.md`. The plan it implements: advisor2's
`/Users/me/wip-mach/rmx-advisor2/op-435-mach-step4-c1-d2-plan.md`
§ 2 and § 4 (items 1-3), plus N6 (`idq` id-046 in the record).

Check:
1. **Pins and revalidation** (#7, #15, pset S2; `99b336b7`): the set
   stays pinned while it is notified after the member unlock
   (`ipc_mqueue.c`, `ipc_pset.c`); a retiring member is pinned across
   the set-lock drop and rechecked once both locks are held.
2. **LARGE and trailer boundary** (`94ac128a`, `e562ff97`,
   `fdb82781`): LARGE keeps the message and reports the size; capacity
   arithmetic cannot overflow; trailers keep send-time audit identity;
   context and sequence are read under the port lock.
3. **Queued replies and receive waits** (N2, F5; `36d0b76d`,
   `9167b444`, `0a0f3061`): every kernel reply is queued at its real
   destination; a waiting receive revalidates its entry, object and
   binding epoch before a locked dequeue, keeps one deadline across
   wakeups, and is woken by destruction, binding change or a member
   joining a set.
4. **N6** (`8d2c2778`): reverse lookup is repeated under the
   reacquired space lock and the unused candidate is rolled back.
5. **Tests:** each new case would detect its defect at `844112f4`.
   `first_copyout`, `wait_large` and `queued_member` are stress, not
   controlled interleavings: say whether that coverage is adequate.
   The two context-trailer test fixes (`6ffe30d2`, `b1ef1670`) follow
   the packed ABI in `sys/sys/mach/message.h`.
6. **Scope:** only Mach code, Mach headers and Mach tests changed; the
   kevent ABI, native FreeBSD files, C1 and D2 are untouched.

Distinguishing question: could any new case pass on the fixed image
while the defect it names is still present, or could a fix introduce
a lock-order or reference leak that no case exercises?

Re-read OPS.md first: defaults and the reply block.
