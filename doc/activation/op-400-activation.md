---
id: op-400
state: closed
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-016
gate: self
authority: stage: one diagnostic overlay onto a copy of the op-388 image with the verbatim dd78a31 helper copy in build/op391/helper-dd78a31; guest boots: 1 (diagnostic, no reaper waves); doas: load vmm.ko if absent, and the runner's bhyve calls; push rmx-gatekeeper1 main
updated: 2026-10-01T09:08Z
---
# op-400 — Gatekeeper 1: why DTrace's pid provider cannot attach to PID 1 — one diagnostic boot

## Outcome

Context: ordinary debugging of our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source launchd as PID 1). Everything runs in one disposable bhyve guest with no network.

op-399's cell stopped before its first wave because DTrace's `pid` provider could not attach to
launchd as PID 1: `dtrace: invalid probe specifier pid1::jobmgr_reap_pid:entry,…: failed to grab
process 1` (rmx-gatekeeper1 `936edbb`, `build/op399/runtime/rmx-op399-alpha2-20261001T083056Z-15648/serial.raw`
line 505). Find out why, with one diagnostic boot. Run no reaper waves.

From source at alpha2 `2884304b`: the kernel refuses to trace init only when securelevel is above 0
(`sys/kern/kern_prot.c:2393-2395`) or the process has `P2_NOTRACE` set. libproc's `proc_attach`
(`lib/libproc/proc_create.c:125-170`) has no PID-1 special case, and its debug messages are
compiled out. So record each step directly.

In the guest, as root, after boot has settled, record:
1. `sysctl kern.securelevel security.bsd.unprivileged_proc_debug`, and `procctl -m trace -p 1`
   if available (the trace-control state of PID 1).
2. launchd's executable path as the kernel reports it: `procstat binary 1`.
3. A small C program, built on the host and staged, that calls `ptrace(PT_ATTACH, 1)`, then
   `waitpid(1, &status, WUNTRACED)`, then `ptrace(PT_DETACH, 1)`. It prints each call's return
   value, `errno` and the decoded status.
4. The same `dtrace -n` command as op-399's Tier U, exactly, with its exit code and output.
5. Controls on an ordinary process the script starts (`sleep 600`): steps 3 and 4 against it,
   with `pid<that pid>::nanosleep:entry` as the DTrace probe.

Stop the guest when done (30-minute cap). The result names the failing step, with its exact
errno or message, and whether the control succeeds. If the evidence points to a fix, state the
smallest one (a guest setting, a probe change, or a product change for the Implementer) and stop
there; do not apply it.

Evidence: the overlay BOM, the image hashes (the op-388 image must still hash `031885…`), the
host inventories, the raw serial log, the probe program's source and binary hashes, and commits
on origin.

## Limits

- One guest boot. If it fails for infrastructure reasons, report that and stop.
- No product edits. op-399's evidence stays as recorded.

Re-read OPS.md first: defaults and the REPORT block.
