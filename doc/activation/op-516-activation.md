---
id: op-516
state: draft
agent: implementer
repo: rmx-implementer
idq: id-046
needs: op-533,op-534
authority: kernel and mach.ko builds (no world); 2 ZFS images; 4 self-check boots; no push
expected: 5h
updated: 2026-10-07T05:40Z
---
# op-516 — Implementer: id-046 launchd's two task setters on a child task (op-435 § 4 item 6)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 5 hours** (tests 1.5 h, kernel changes 2 h,
two images and self-checks 1 h, record 30 min).

The last kernel part of id-046's step 4 (op-393 N5; op-392 S5's
caller substitution, for two calls). When launchd starts a job, the
child sends its task port (`lib/liblaunch/libvproc.c:487`) and launchd
calls `task_set_special_port(child_task, ...)`
(`sbin/launchd/core.c:8642`) and `task_set_exception_ports(target_task,
...)` (`core.c:6556`). In our kernel `convert_port_to_task`
(`sys/compat/mach/kern/ipc_tt.c:902-915`) ignores the port and returns
the caller, so both calls change launchd's own task instead of the
child's. Plan: advisor2's
`/Users/me/wip-mach/rmx-advisor2/op-435-mach-step4-c1-d2-plan.md`
§ 3 and § 4 item 6. Decided scope (Arranger, 2026-10-03): only these
two setters work on another task; every other call on another task
stays refused. Continue on `mach-fixes-6` (now `ea254222`, on origin).

Rules (confirm or correct each from the source):
1. **Typed routing.** At the MIG dispatch (`ipc/ipc_kobject.c:280-347`,
   global by message ID today), match the routine family to the
   destination's kobject type before any converter runs. Wrong family:
   `MIG_BAD_ID`.
2. **Truthful task conversion.** `convert_port_to_task` returns the
   task the port names (`ref_task_port_locked`, `:922-945`), pinned
   under the port lock, never the caller. A call naming the caller's
   own task keeps working as today.
3. **Two calls on another task, nothing else.**
   `task_set_special_port` (`:695-740`) for `TASK_SEATBELT_PORT`,
   `TASK_ACCESS_PORT` and `TASK_DEBUG_CONTROL_PORT` (seatbelt and
   access stay set-once), and `task_set_exception_ports`
   (`:1221-1260`). Any other routine on another live task:
   `KERN_NOT_SUPPORTED`; a task that is exiting or dead:
   `KERN_INVALID_TASK`; a bad selector or option:
   `KERN_INVALID_ARGUMENT`. Getters, `mach_port_*` on another space,
   task and thread control and info, and VM on another task stay
   refused, and are never applied to the caller instead.
   `convert_port_to_map` must not hand out an unheld map pointer for
   another task (`:1011-1020`).
4. **Locked update.** Carry the original request destination into the
   two setters. Check the space under its own lock first, then under
   the binding and task IPC locks recheck alive, space identity and
   that the destination is still the task's current control port (an
   old control port fails after a credential-changing exec). Never
   take the space lock inside the task IPC lock. Release old and input
   rights and send notifications only after unlocking. Keep the MIG
   stubs' success and error ownership; wire IDs and layouts unchanged.
5. **launchd's exception configuration is stored.** launchd passes
   `EXC_MASK_CRASH | EXC_MASK_GUARD | EXC_MASK_RESOURCE` and
   `EXCEPTION_STATE_IDENTITY | MACH_EXCEPTION_CODES` with
   `x86_THREAD_STATE`. Today the mask check (`exception_mask &
   ~EXC_MASK_ALL`) and the behavior switch reject it. Accept and store
   exactly this supported configuration, reject unknown bits and
   flavors, keep `EXC_MASK_ALL`'s meaning. Decided: stored, not
   delivered; exception delivery is not part of this op.
6. A refused request with port rights releases its input rights once
   and still gets its error reply.

Tests first (`tests/sys/mach`, Zig, on the `mach_lifetime.zig` fork
pattern):
1. The child sends its own task port to the parent, as a launchd job
   does at startup; the parent sets each of the three special ports on
   it: the child sees them through its own getters (or a fixture
   projection), and the parent's own ports are unchanged.
2. The parent sets launchd's exact exception configuration on a child:
   accepted and stored on the child, the parent unchanged. Unknown
   mask bits or flavors are refused.
3. Refusals: another routine family on a task port (`MIG_BAD_ID`); a
   getter, `mach_port_*` and a VM call on the child's task port
   (`KERN_NOT_SUPPORTED`), with nothing applied to the parent; seatbelt
   set twice (`KERN_NO_ACCESS`).
4. The child's old task port after the child exits, and after a
   credential-changing exec: the setters fail and nothing changes.
5. Input rights are balanced on every refusal (send-right counts
   before and after).
Keep batch 3's exec, bootstrap and shared-space cases unchanged.

Then two ZFS images (from `op417-alpha2-zfs-gpt.raw`, reusing the
existing world; rebuild only the kernel, `mach.ko` and the tests):
base = `ea254222` + the tests (name its branch), fixed = the
changes + the same tests (test files identical). Show the pair
differs only in the change from the METALOG/BOM diff (OPS.md
§ Self-check). Self-check: the new cases fail on base as expected
(say which cannot be shown on base and why), all pass on fixed, and
every earlier case passes on fixed, including the launchd consumer
cases. A `launchd control reply missing` in a launchd consumer case is
the known id-061 problem: record it, do not count it against the
pair.

Evidence: the commits; your op record (`docs/op516-child-task-setters.md`)
with each rule's change, test and base and fixed results; both image
hashes and BOMs (by path); the `selfcheck:` line.

## Limits

- Kernel (`sys/compat/mach`), its MIG definitions and outputs where
  rule 4 needs them, and `tests/sys/mach` only: no launchd, libmach
  or FreeBSD native change. No other call on another task. No
  exception delivery. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
