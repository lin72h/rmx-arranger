---
id: op-568
state: draft
agent: advisor2
repo: rmx-advisor2
idq: id-052
expected: 3h
authority: none
updated: 2026-10-08T07:58Z
---
# op-568 — Advisor 2: finish the Mach review — host, task and VM server routines no review has read (id-052)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). This is a source-only correctness review of kernel code
we author and ship, so that the Implementer can fix it.

**Expected time: about 3 hours.**

Three reviews of the Mach integration (your op-389, advisor1's op-392
and op-393) read everything except these routines:
- the `host_priv` and `mach_host` routine bodies:
  `sys/compat/mach/host_priv_server.c`, `mach_host_server.c` and what
  they dispatch to (`mach_host.c`, `mach_host_priv.c`,
  `kern/ipc_host.c`);
- `task_info` and `task_threads` (`task_server.c`, `mach_task.c`,
  `kern/task.c`, and the port-to-task conversions in `mach_convert.c`);
- the `vm_map` server routines (`vm_map_server.c`, `mach_vm_server.c`,
  `mach_vm.c`) beyond what op-389 #8 and op-392 §3 covered.

These are reached by launchd and libxpc on the PID-1 path, and op-393
N5 showed the task-level routines were never really exercised (every
`task_*` call acted on the caller). Since then the code has changed a
lot (steps 1-4 of the fix plan: 21 files, about 1,900 lines), so read
the current head, not alpha2. One known item to confirm and trace:
`convert_port_to_task_name` returns `NULL` unconditionally
(`sys/compat/mach/mach_convert.c:72-75`), so `task_info` on a task
name port fails; say which callers in our libraries and launchd
depend on it and what the correct conversion is.

The question: in these routines, where does the code do something
wrong: a reference or right leaked or released twice, a lock held
across a sleep or in the wrong order, a use of a task, thread or map
after its process exits, a wrong `kern_return_t` or out-parameter, a
size or count copied out wrongly, or an operation applied to the
caller instead of the task named by the port?

Also settle **S1** (op-392, firmed up in op-393 §2): about 3 of 4,400
guest serial logs from late September showed a WITNESS lock-order
reversal, 1st `ETAP_IPC_RPC`, 2nd `ETAP_IPC_IS`. Those logs are no
longer on hand. Current evidence: both op-565 full-suite runs (RELEASE
and KASAN kernels, WITNESS enabled, `mach.ko` now built with the
kernel) show no lock-order reversal at all. From source at the
current head, say whether any path takes a space lock while holding a
port or port-set lock, and whether op-392's original S1 pair (space
rwlock, then the port-set knote sx) can still occur now that Mach
kevents only report readiness (`mach-fixes-6@ea254222`). Conclude
"cleared" or "live", with the path if live.

Same form as op-393: confirmed and suspected findings, ranked by
likelihood times impact, each with the rmxOS file:line (and XNU's or
NextBSD's where they differ), the concrete incorrect behavior, your
confidence, the smallest regression test or source trace that would
confirm it, and the fix direction. Add a "checked and cleared" list
and a list of what you did not reach. Do not re-propose items already
in op-389, op-392 or op-393, or the name-table redesign deferred to
step 5. Under about 250 lines, as a new document.

## Inputs

- rmxOS: `/Users/me/wip-mach/rmx-implementer/wip-rmxos` at
  `13628bbe681acb64308b5f8a7d584b86704d9914` (branch `mach-fixes-6`;
  read with `git show`, `git diff`, `git log` only). Areas above, plus
  `sys/compat/mach/defs/{host_priv,mach_host,task,vm_map,mach_vm}.defs`
  and `sys/sys/mach/`. Changes since your op-389 baseline:
  `git log 2884304b..13628bbe -- sys/compat/mach sys/sys/mach`.
- Callers in our userland, same tree: `lib/libmach`, `lib/libxpc`,
  `sbin/launchd`.
- Earlier reviews, to avoid repeats:
  `/Users/me/wip-mach/rmx-advisor2/op-389-mach-freebsd12-assumptions-alpha2.md`,
  `/Users/me/wip-mach/rmx-advisor1/op-392-mach-freebsd15-assumptions-findings.md`,
  `/Users/me/wip-mach/rmx-advisor1/op-393-mach-remaining-areas-findings.md`;
  the step-5 deferral:
  `/Users/me/wip-mach/rmx-arranger/mach-names-step5-deferred.md`.
- S1 evidence: `/Users/me/wip-mach/rmx-implementer/build/op565/runs/rmx-selfcheck-op565-release-r1-1791444650/tests/serial.txt`
  and `.../rmx-selfcheck-op565-kasan-r1-1791444924/tests/serial.txt`.
- XNU, read-only: `/Users/me/wip-mach/reference/xnu-xnu-12377.121.6/`
  (`osfmk/kern`, `osfmk/vm`); NextBSD, read-only:
  `/Users/me/wip-mach/nx/NextBSD-NextBSD-CURRENT/`.

Re-read OPS.md first: defaults and the reply block.
