---
id: op-439
state: draft
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-016
gate: self
authority: guest boots: up to 7 on copies of op436-boot-zfs.raw, 5-minute cap each; doas: load vmm.ko if absent, and the runner's bhyve calls; push rmx-gatekeeper1 main
updated: 2026-10-03T01:33Z
---
# op-439 — Gatekeeper 1: accept op-436 — launchd PID 1 by default on the ZFS-root image (op-438's checks plus op-436's list)

## Outcome

Context: ordinary engineering on our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source Mach IPC and launchd). Everything runs in disposable bhyve guests with no network.

Accept op-436: launchd is PID 1 by default (branch `pid1-boot-1` at `969f2151`). Its record,
with the boot checks it asks for, is `/Users/me/wip-mach/rmx-implementer/docs/op436-default-pid1.md`
§ "Causes, changes, and Gatekeeper acceptance" and § "Native shutdown tools".

Image (work on copies): ZFS root is rmxOS's default, so only the ZFS image is accepted here
(the UFS image is not tested).
- ZFS: `/Users/me/wip-mach/stage/images/op436-boot-zfs.raw` sha256 `caddd3b35664ed553ee60de0865975953141213cc041d6897e3d2f711eaceb81`

Use your op-438 checks (`build/op438/workload/checks.sh`, `check-list.md`). Their final console
collector has run only on the host: check it against an image before the first boot, and fix your
own harness within this op if it fails.

One normal boot:
1. op-438 checks 1-6: PID 1 without `-u`; rc once (one `cron`, one logger, one `devd`, no
   "Device busy" or duplicate routes; no `/etc/bootstrap` error); root read-write before services,
   with create and remove on `/` and in `/var/run`; `login:` on the serial console; notifyd running;
   `shutdown -p now` powers off.
2. From op-436's list: native `syslogd` is the only logger (no `asld` or `aslmanager`), and a
   `logger` message reaches the configured log; log in on the console, log out, and one getty
   comes back.

Then one boot for each terminal request:
- `kill -USR1 1` halts; `kill -USR2 1` powers off; `kill -INT 1` reboots (the runner sees a
  reboot); `kill -TERM 1` reaches single-user mode;
- a job with `StartCalendarInterval` whose time has passed (for example after stepping the clock
  forward) does not halt PID 1;
- `reboot -r` reroots and comes back up with launchd as PID 1.
You may combine requests in one boot when the earlier one leaves the guest running.

Result: one table (check, expected, observed, serial line), every mismatch listed,
and the boots used.

Evidence by path; hash only each boot's raw serial log. Commits on origin.

## Limits

- No product or image edits; overlays on copies only for check helpers.
- If one check cannot run, record it and finish the others.

Re-read OPS.md first: defaults and the REPORT block.
