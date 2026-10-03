---
id: op-440
state: closed
agent: validator3
repo: rmx-validator3
idq: id-046
gate: self
authority: none beyond the defaults: read-only; no guests
updated: 2026-10-03T05:30Z
---
# op-440 — Validator 3: re-review Mach batch 3 after op-437 — two teardown fixes and the corrected lifetime fixtures

## Outcome

Context: ordinary bug fixing in our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source Mach IPC). Review the code, not attack scenarios.

Re-review Mach batch 3 after the remediation of your op-433 findings. The delta is 5 commits on
`mach-fixes-3`, from `db592723` to `wip-rmxos@cf398822f0ae`. The Implementer's record:
`/Users/me/wip-mach/rmx-implementer/docs/op437-mach-lifetime-remediation.md`. Your earlier
review: `reviews/op-433/op430-review.md` in your repo.

Check:
1. **Your two findings are fixed at their cause:**
   - `mach_task_exit` with no native thread (`893b65ab`);
   - parked `ith_kmsg` reply released in common thread IPC retirement (`fb7a6df3`), with no lock
     held and no double release, including exec.
2. **The new regressions** (`failed_creation`, `parked_reply`) would detect each defect at
   `db592723`. Both use fixtures rather than a live allocation failure or MIG round trip; say
   whether that coverage is adequate.
3. **Fixture corrections** (`cf398822`) to `task_control_death`, `thread_control_death`,
   `rfork_unshare` and `rfork_clean_table`. The Implementer says these were fixture faults:
   `ip_active` read as a Boolean although it is a mask; a stale lookup loop; a native `fget` on a
   Mach name. Confirm each was a real fixture fault, and that no correction weakens what its case
   checks.
4. Nothing else changed: native hooks, receive model, D2, batches 1-2.

Distinguishing question: could any of the six cases now pass on the fixed image while the defect it names is still present?

Re-read OPS.md first: defaults and the REPORT block.
