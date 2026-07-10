# li-008 — launchd as a CORE preview service (the service host)

- tier: **L1i** instruction (`li-008`). Dedicated file (launchd is big enough to warrant its own milestone,
  broader than the li-003 lifecycle-spine slice). Index entry: [roadmap.md](../roadmap.md) ladder.
- promotion chain: this `li-008` decodes into the existing launchd track (li-003 spine work + id-016
  bootstrap) plus new service-host ops (the xpc_domain hosting leg + op-134).
- raised: 2026-06-24 (Coordinator elevation, same directive as li-007: launchd + libxpc are non-optional
  core services brought to preview quality — "get it right both libxpc and launchd").

## What this instruction means

launchd is the **service host** of the Darwin userland — it boots, hosts, and supervises the core daemons
(notifyd, asld, and our own) and is the bootstrap anchor. It is a **core preview service**. This milestone
is the broader "launchd is a solid service host at preview quality," of which the **li-003 lifecycle spine**
(load→start→observe→restart→remove→reload) is one sub-aspect.

## Two-plane architecture (Arranger first-hand 2026-06-24 — the load-bearing fact)

launchd straddles two planes, and only ONE is the open work:

- **Control plane (launchctl → launchd): liblaunch = Mach/MIG, NOT XPC.** Verified: launchctl.c has ZERO
  `xpc_*` calls; it uses `launch_msg`/vproc/liblaunch (bootstrap.h, job.defs, mach_msg, MIG). This DIVERGES
  from macOS (where launchctl talks XPC) — and it already WORKS. This is *why* notify/asl/launchd-lifecycle
  function without a mature libxpc.
- **Service plane (launchd `xpc_domain` hosting): rides libxpc/nvlist (li-007) = the long pole.**
  `xpc_bootstrapper` / `_launchd_xpc_bootstrapper` / `_xpc_domain_import_service(s)` (core.c:912-940);
  `xpc_dictionary_*` (core.c:2359/2397/3775). This is the leg to "get right."

## Known state

- **lifecycle spine ✅** — li-003 closed the D23 spine on fixtures (load→start→observe→restart→remove→reload);
  now driving *real* daemons (notifyd hardened harness op-131; asld harness op-133) is in flight.
- **bootstrap gap (id-016):** launchd is NOT PID 1 on the staging-model image; a shell-launched client gets
  `bootstrap_port = 0` (FAIL). The working preview run-model is **launchd-job** (child inherits the port).
  Ambient-bootstrap (c) is proven; PID-1 launchd is the remaining hardening.
- **cold-boot auto-start ✅ (op-134 DONE, `d245948`, Arranger-verified):** notifyd now comes up on a clean
  boot of the staging image and notify round-trips green WITHOUT a notifyd-specific harness prop. Mechanism =
  a **generic boot-load** of `/etc/launchd.d/*.plist` (`KeepAlive:true`), shipped as an `rc.local`. This closed
  id-015's last retirement blocker.
- **launchd does NOT self-scan `/etc/launchd.d/` (id-023, NEW divergence):** op-134 proved that unlike macOS
  launchd (PID 1, auto-scans `LaunchDaemons`), rmxOS launchd (`-u`, non-PID-1 per id-016) loads nothing
  automatically — the staged plist alone left `launchctl list` empty. The generic boot-load is the rmxOS
  bridge. Making launchd self-scan (macOS-faithful) is part of this milestone's "get it right" (item 5 below);
  cataloged as a li-005 known gap, non-blocking for preview.

## Get-it-right plan (depth-first; rides li-007 for the service plane)

1. **Calibration probe (shared with li-007):** is the `xpc_domain` service path live end-to-end over nvlist?
2. **Cold-boot autostart** (op-134 ✅ for notifyd; asld, own daemons next): daemons start under launchd on
   clean boot via the generic boot-load.
5. **launchd self-scan** (id-023, depth-first HELD): make launchd enumerate+load `/etc/launchd.d/*.plist` on
   `-u` startup (macOS-faithful), retiring the `rc.local` bridge — opened after notify/asl soak legs close.
3. **Real-service lifecycle** (li-003 → real daemons): notifyd/asld transition the full spine + survive
   restart/reload as launchd-managed jobs, not fixtures.
4. **Service-plane hosting:** `xpc_domain` import/host path solid over libxpc/nvlist (gated on li-007 fill +
   the MACH_RECV dispatch sub-fix).

## op-264 seeds — KeepAlive/restart supervision (Oracle consult, Arranger-verified first-hand 2026-07-07)

Consult read the supervise-and-respawn cluster in `core.c`/`runtime.c`; verified at source in the release
base `wip-gpt/wip-rmxos`. The path a hosted daemon rides (NOTE_EXIT → reap → keepalive → throttled restart;
unload → stop → pended remove) is **well-built and safe to keep relying on** — Q1 reap-attribution +
double-reap, Q2 policy order (useless→active→keepalive), Q3 per-job throttle (`job_start:4477-4486`, 10s
default), Q4 remove/cancel/free with in-batch event pruning all SOLID. Seeds:

1. **[PRIMARY seed — Finding A — small/med effort, HIGH blast radius] The `waitpid_loop` cross-thread reaper.**
   `runtime.c:646-657` runs a detached free-running `for(;;)` thread (created :260-261) that reaps via
   `jobmgr_reap_pid` (`core.c:7230-7238`) — walking the job tables (`jobmgr_find_by_pid_deep` :7233) and
   `waitpid` :7236 with NO serialization against the main thread's LIST_INSERT/REMOVE/free. Three hazards:
   (a) torn traversal/read-after-free → **launchd(pid-1) abort = system down** (low prob, but fires on EVERY
   child exit); (b) transient miss consumes a MANAGED job's zombie → main-thread wait4 ECHILD → job_reap
   synthesizes SIGSEGV status → spurious crash + garbage LASTEXITSTATUS; (c) `WNOWAIT` **busy-spin** (managed
   zombie stays waitable / no-children ECHILD → ~100% of one core at idle-boot). Purpose is legit (pid-1
   FreeBSD orphan reaping). PROPOSAL: route unknown-pid reaping through the main runloop (EVFILT_SIGNAL SIGCHLD
   on mainkq → main-thread WNOHANG drain skipping pids present in the hashes), or minimally serialize
   `jobmgr_reap_pid`. **PREVIEW-RELEVANT** (unlike op-263's post-preview seeds): notifyd/asld ride this exact
   path (KeepAlive:true, op-134 cold-boot), so this is the one structural item worth an op BEFORE heavy soak
   reliance. NEEDS-RUNTIME-CHECK to set severity: idle-boot CPU watch + kill-storm soak on a KeepAlive job
   (watch for "Reap failed" / spurious "appears to have crashed"). **Gating decision = Coordinator, NOT
   auto-gated** (finding is a hypothesis; runtime evidence sizes it first).
2. **[trivial seed — Finding B] `#ifdef` out the two `kev->data` bit tests on `__FreeBSD__`.** `Makefile:45`
   force-defines NOTE_EXIT_DECRYPTFAIL=0x10000 / NOTE_EXIT_MEMORY=0x20000; `core.c:4204/4207` test them vs
   `kev->data`, which on FreeBSD holds the UNMASKED exit code → `_exit` with bit 16/17 set spuriously flips
   fpfail/jettisoned (log noise + wrong LASTEXITSTATUS export). Restart decision unaffected. Compile the two
   tests out on FreeBSD.
3. **[test-notes] `-u` dev mode voids on-demand semantics.** The `|| uflag` at `core.c:4058` force-starts every
   dispatched inactive job under `-u`, so on-demand / KeepAlive-false semantics don't exist there — any
   KeepAlive-policy soak run under `-u` is VACUOUS; don't misread such evidence.
4. **[donor gaps to log — roadmap, not path correctness]** NetworkState is boot-frozen (PF_SYSTEM event socket
   fails on FreeBSD, `launchd.c:666-685`) and PathState is unhandled in `semaphoreitem_setup` ("Unrecognized
   KeepAlive attribute"). No current daemon uses these shapes (notifyd/asld are KeepAlive:true) — log against
   li-008 for the day a job needs NETWORK_/PATH_ keepalive.
5. **[cheap runtime checks]** throttle cadence probe (/usr/bin/false KeepAlive:true → ~10s steady cadence,
   others unaffected); crashed-machservice respawn under the donor `job_active` change (`core.c:6337-6346`
   returns NULL where Apple blocked respawn while a machservice port lingered) — crash a checked-in mach job,
   verify the respawn re-checks-in cleanly.

## Truly-green criterion

- launchd boots and hosts the core daemons (notifyd, asld, own) — they auto-start on clean boot;
- the full li-003 lifecycle spine runs against those **real services** (not fixtures) and they survive
  restart/reload;
- the `xpc_domain` service plane is live end-to-end over nvlist (not stubbed);
- holds under the li-004 integration soak (launchd → libxpc → libdispatch → mach-ipc) with li-001 invariants.

## Relations

- **li-007** (libxpc) — the service plane rides it; the two are the paired "get it right" core-service work.
- **li-003** (launchd lifecycle spine) — the lifecycle sub-aspect of this broader service-host milestone.
- **li-004** (integration soak) — launchd is the top of that stack.
- **id-016** (ambient/PID-1 bootstrap) + **op-134** (cold-boot autostart) — the carriers of the gaps above.
- foundation deps: libdispatch (servicing) + Mach IPC (li-001) + bootstrap (id-016).
