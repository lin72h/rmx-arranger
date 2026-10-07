---
id: op-524
state: draft
agent: implementer
repo: rmx-implementer
idq: id-046
authority: kernel and mach.ko builds (no world); 2 ZFS images; 4 self-check boots; no push
expected: 4h
updated: 2026-10-07T01:43Z
---
# op-524 — Implementer: op-520 remediation (recovered receive right regains readiness) and op-521's launchd failures

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 4 hours** (diagnosis 45 min, test 45 min,
change 30 min, two images and self-checks 1.25 h, record 45 min).

op-515 and op-518 (readiness-only Mach kevents, `mach-fixes-6@0facf74b`)
came back from review and proof with one finding and one failed run.
Fix the finding, and establish whether it explains the run.

1. **Review finding (validator3, op-520).** Closing a receive-right
   name sets `ip_readiness_revoked` on the port
   (`sys/compat/mach/ipc/ipc_entry.c:296-311`). If the port has a
   port-destroyed request, `ipc_port_destroy` hands the live port to
   that backup owner (`ipc_port.c:831-856`), and copyout publishes it
   under a new name (`ipc_right.c:1927-1950`), but nothing clears
   `ip_readiness_revoked`. `ipc_pset_port_ready` (`ipc_pset.c:262-282`)
   then never reports it ready, and a set receive does not take its
   messages. Clear the flag when a valid receive right is published to
   its new owner, and confirm every other path that moves a receive
   right (message copyout, set join) treats a recovered port as live.
2. **Failed proof (gatekeeper1, op-521).** On the fixed image
   `launchd_consumer_test:close_unregistered`, `:late_dead_name` and
   `:setup_retry` failed with `launchd control reply missing`, right
   after `demand_removed` passed, and the guest did not power off
   within 60 s after "System shutdown time has arrived". Your own
   self-check passed all 87. Raw serial:
   `/Users/me/wip-mach/rmx-gatekeeper1/build/op521/runtime/rmx-op521-fixed-all-20261007T013528Z-2381/serial.raw`
   (lines 4576-4725 and the shutdown at the end); table and notes:
   `/Users/me/wip-mach/rmx-gatekeeper1/build/op521/results-r2.md`,
   `findings.md`. launchd gets a job's service receive rights back
   through port-destroyed requests when the job exits, so rule 1 is
   the likely cause; say from the source and the logs whether it is,
   and why your run passed. If it does not explain them, find what
   does before changing anything else.

Tests first (`tests/sys/mach`):
1. A receive right with a port-destroyed request is closed by its
   owner; the backup owner receives it, adds it to a port set, and a
   message sent to it is reported ready and received through the set
   with `mach_msg`.
2. If item 2's cause is something else, a bounded test for it.
Keep every existing case as it is.

Then two ZFS images (from `op417-alpha2-zfs-gpt.raw`, reusing the
existing world; rebuild only the kernel, `mach.ko` and the tests):
base = `0facf74b` + the tests (name its branch), fixed = the change +
the same tests (test files identical). Show the pair differs only in
the change from the METALOG/BOM diff. Self-check: the new case(s)
fail on base; on fixed, run all cases twice in two boots (the 87 and
the new ones), once in gatekeeper1's op-521 case order, all expected
to PASS, and the guest powers off normally after each run.

Evidence: the commits; your op record (`docs/op524-recovered-readiness.md`)
with the cause of op-521's failures, each change, test and base and
fixed results; both image hashes and BOMs (by path); the
`selfcheck:` line.

## Limits

- `sys/compat/mach` and `tests/sys/mach` only: no launchd,
  libdispatch or libxpc change unless item 2 shows the cause is
  there, and then stop and report before changing it. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
