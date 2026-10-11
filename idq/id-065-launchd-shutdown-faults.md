# id-065 — PID-1 launchd faults repeatedly at shutdown after the forced unmount

- priority: medium (PID-1 launchd milestone; shutdown on real hardware)
- state: **OPEN — traced by op-637; no op yet**
- raised: 2026-10-11 (op-637, j-20261011-022)
- related: id-042 (PID-1 launchd), id-064 (real-machine image)

## Finding

With `machdep.uprintf_signal=1`, every shutdown after `All buffers synced.` prints hundreds to
thousands of `pid 1 comm launchd: signal 11` lines (op-637: 850 on the installation boot, 3374 on
the KASAN test boot); the guest still powers off normally. The faulting PCs are in
`waitpid_loop` (`sbin/launchd/runtime.c:654`) and `fatal_signal_handler` (`launchd.c:450`), and
their instruction bytes read as zero at run time. Supported hypothesis (Implementer, not yet
confirmed by a captured stack): launchd's detached helper threads (`runtime.c:260-264`) keep running
after `reboot` (`core.c:1408-1416`); the kernel's forced unmount after sync detaches the executable's
vnode pager (`vnode_pager.c:208-243`), so later text faults zero-fill; PID 1 ignores default signal
actions (`kern_sig.c:3261-3272`), so it keeps faulting. Code from the NextBSD import
(`845887675b08`); unchanged over `1cad29b5..93b3735d`. Earlier runs did not print user signal
faults, so their count is unknown.

## Open

- Confirm the mechanism, then fix direction: quiesce or join launchd's helper threads before the
  `reboot` call, or the FreeBSD shutdown integration that keeps PID-1 helpers from returning to
  user code after the forced unmount.
- op-633's one shutdown WITNESS warning (process lock at `kern_sig.c:2145`, then the btag lock at
  `subr_vmem.c:758`) is plausibly these faults' signal queueing under KASAN, where UMA uses the
  boundary-tag allocator; it did not recur in op-637, and its deadlock classification is open.
