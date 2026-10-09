---
id: op-577
state: closed
agent: implementer
repo: rmx-implementer
idq: id-046
authority: self-check runner changes in rmx-implementer; 5 self-check boots (4 + 1 spare) on op-569's a35ce232 overlays; no source change; no push
expected: 2h
issued-at: 2026-10-09T00:00Z
updated: 2026-10-09T00:16Z
---
# op-577 — Implementer: finish op-569's self-check — wider install window, both fixed profiles of a35ce232

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 2 hours.**

This finishes op-569's self-check of the four id-046 corrections
(`mach-fixes-6` at `a35ce232`, record `docs/op569-leftovers.md`). The
code and the overlays are done; two install-and-test runs remain.

Your boot 5 stopped with `install_timeout` before any test ran. The
cause is the collector's window, not the candidate: the install phase
waits 100 s in total (`tools/selfcheck/console-op562.expect:54`), your
earlier installs needed about 41-50 s of guest uptime plus loader time,
and during boot 5 the host load average was about 340 on 56 CPUs. The
guest's last line, `Starting file system checks:`, is the slow part
under that load.

1. **Runner:** raise the install-phase window to 240 s, keeping the
   300 s cap per boot, and before each boot wait until the host's
   1-minute load average is below 40 (`sysctl -n vm.loadavg`), up to
   30 minutes; record the load at each boot start. Preflight the
   change on the host as before, then commit it.
2. **Fixed RELEASE** (`a35ce232` overlay, sha256 `77ca1ee7…`): install,
   then tests. Expected: the 93 earlier cases and all 50 new cases
   pass (including `mach_trap_returns_test:errors` with the corrected
   input), the five MIG modes exit 0, normal power-off, no assertion or
   fatal trap.
3. **Fixed KASAN** (`a35ce232` overlay, sha256 `e5d206e2…`): the same,
   plus no KASAN report from boot to power-off.
4. One spare boot, only for a boot that stops before its commands run.
   If an install stops again at low host load, record it and stop.

Evidence: add the runs to `docs/op569-leftovers.md` (load at each boot
start, ATF counts per profile, MIG modes, power-off line, serial
paths), commit, and update the `selfcheck:` line.

## Limits

- No product or test source change. No other overlay rebuild. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
