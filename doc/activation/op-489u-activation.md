---
id: op-489u
state: draft
cast: unicast
agent: implementer
repo: rmx-implementer
idq: id-046
updated: 2026-10-05T00:00Z
---
# op-489u — Implementer: op-484 resume in a new session

## Message

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

Resume op-484: four small fixes to launchd's Mach service handling,
tests first. Read `AGENTS.md` and `OPS.md` first.

Where it stands (your own records):
- Source `build/op468/source`, branch `mach-fixes-5`. Base for the
  images is `b2d5f5b7`. Already committed on top: `caa8f867` (the
  Zig tests in `tests/lib/launchd`), `b4870d84` and `7d4aa71b`
  (changes 1 and 2 below). Uncommitted edits in `sbin/launchd/Makefile`
  and `tests/lib/launchd/` (README, `coordination.c`, `fixture.zig`,
  `launchd_consumer.zig`): review them, finish or drop them, commit.
- Your notes: `docs/op484-launchd.md`, `tools/selfcheck/op484*`
  (uncommitted).

The four changes (launchd and its tests only):
1. `sbin/launchd/runtime.c` `mportset_callback`: check the result of
   `job_find_by_service_port()`; skip a member with no current job.
   (Done in `b4870d84`; confirm.)
2. `sbin/launchd/core.c` `machservice_drain_port`: use the allocated
   buffers and their real sizes, free them, end the loop on any
   receive result other than success. (Done; confirm.)
3. Before a receive right is closed (`launchd_mport_close_recv`,
   `runtime.c:862`, and its callers), take it out of its port set
   first, for registered and unregistered names alike; also check the
   callback-table index in `runtime_remove_mport` (`runtime.c:834`)
   before using it.
4. `do_mach_notify_dead_name` (`runtime.c:1014-1031`): no change;
   the test shows it releases the extra uref when the job is gone.

Tests: as in your `caa8f867`. For the drain cases, the job ends with
`SIGABRT` (`raise(SIGABRT)`), the condition launchd already uses at
`core.c:3810-3840`; keep that rule unchanged.

Then two images reusing the existing world: base = `b2d5f5b7` + the
tests, fixed = the changes + the same tests (test files identical).
Self-check: the new cases fail on base as recorded (say which cannot
be shown on base and why), all pass on fixed, the 65 earlier cases
pass on fixed. Up to 4 boots; no push. Then the op record (each
change, its test, base and fixed results, both image hashes and BOMs
by path, the `selfcheck:` line) and the reply to op-484.
