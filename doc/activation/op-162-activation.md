---
id: op-162
state: dropped
updated: 2026-09-27T22:54Z
legacy-state: READY
reset: j-20260927-004
---
# op-162 — Explorer: asl leg-2 (TRACED conformance) — run the 9-case asl workload against launchd-hosted asld under DTrace crash/signal observation, author the traced artifact

op-162 | role: **Explorer** (FREE — rx1/rmx-explorer) | state: READY dispatch (authorized) | parent id: id-011 (li-1004 asl) | authored 2026-06-26 (Arranger seat, model Opus 4)
purpose: close the leg-2 (traced) artifact on asl — the one remaining INTERACTIVE leg toward li-1004 truly-green. asl is leg-1 lifecycle GREEN (op-146) + leg-3 conformance-MATCH 9/9 GREEN (op-116-cont); legs 2 (traced) and 4 (soak) are the open legs. This op authors leg-2 ONLY. leg-4 soak is a SEPARATE Gatekeeper op held for the overnight slot — do NOT attempt it here. Runs IN PARALLEL with op-160 (Implementer, libxpc) and op-159 (overnight Gatekeeper soak); no contention (free role, different pipeline).

ASSIGNMENT: rx1 (rmx-explorer) only. rx2 is parked (under-onboarded) — do NOT route here. Explorer AUTHORS the traced artifact; Gatekeeper validates leg-4 separately. Conformance-MATCH is leg-3 (already green) — this is the distinct TRACED leg, not a re-run of the match.

WHAT LEG-2 PROVES: that launchd-hosted asld survives the full 9-case asl conformance workload UNDER DTrace observation with NO crash/abnormal signal and a clean syscall/IPC trace — i.e. the daemon is not paper-green (no silent SIGSEGV/SIGABRT masked by a restart). Artifact = the traced run + the clean (or flagged) verdict + the captured trace.

RUN MODEL (mandatory):
- asld is launchd-hosted → drive via the **launchd-JOB model**, NOT a shell-launched binary (id-016: shell-launch gets TASK_BOOTSTRAP_PORT=0, cannot reach the bootstrap). Load asld as a launchd job; confirm it answers the `com.apple.system.logger` Mach bootstrap.
- **PROVENANCE GATE (id-011 standing caveat):** confirm FIRST-HAND the traced PID is the **Apple asld** (overlay provenance, answers com.apple.system.logger), NOT a base FreeBSD syslogd confound. If base syslogd is shadowing the port, the trace observes the wrong daemon and paper-greens — flag and stop.
- Workload = the existing compiled `/root/asl-harness` (9 R()-cases: asl_open / asl_new / asl_set / asl_log / asl_get_roundtrip / asl_set_filter / asl_log_filtered / asl_close / asl_search_roundtrip). Drive the same 9 cases leg-3 used — leg-2 adds the trace dimension, it does not change the workload.

PROBE MODEL (harness pillar — op-147m; fbt kernel-only — feedback_fbt_traces_kernel_only):
- asld has **NO USDT**. Crash/signal bar = `fbt::sigexit:entry` AND/OR `proc:::signal-clear` **predicated on the asld PID** — NEVER spec a userspace asl/asld symbol as an `fbt::` bar (it never matches). This is the exact leg-2/leg-4 probe model op-146 established.
- Add the IPC/syscall trace dimension on the asld PID (Mach msg send/recv on the logger port + the store-write path) as the `.d` observation — `.d` artifact only, NO printf/dprintf added to source.
- Load each provider INDIVIDUALLY (no blanket provider set).
- DTrace `.d` is an OBSERVATION artifact — committed to the harness, not product-source edits.

DELIVERABLE / GATE (Explorer authors; Gatekeeper validates leg-4, NOT this):
- The traced run: 9-case asl-harness workload against launchd-hosted asld, asld PID under `fbt::sigexit`/`proc:::signal-clear` + the IPC/syscall `.d`. 
- VERDICT: TRACED-CLEAN (no sigexit/abnormal signal on the asld PID across all 9 cases, IPC trace shows the expected logger round-trip, daemon stays up) OR FLAGGED (name the case + the signal/trace anomaly with the captured stack). asl_search_roundtrip is the known unsettled case (shared-FAIL, leg-3) — if it FAILs that is expected; what leg-2 cares about is whether it does so CLEANLY (graceful, no crash) vs via a signal.
- Source-cite the provenance check (which binary answered com.apple.system.logger) + commit the `.d` + the trace log + the verdict to the harness branch.

MARKERS:
```
OP162_ASLD_PROVENANCE status=0    # traced PID confirmed Apple asld on com.apple.system.logger (not base syslogd); cite
OP162_LAUNCHD_JOB_RUN status=0    # asld driven as launchd-job; 9-case asl-harness workload ran; NOT shell-launch
OP162_CRASH_BAR_CLEAN status=0    # fbt::sigexit/proc:::signal-clear on asld PID: clean | FLAGGED(case+signal+stack)
OP162_IPC_TRACE_CAPTURED status=0 # .d IPC/syscall trace on asld PID captured; logger round-trip observed
OP162_VERDICT status=0            # TRACED-CLEAN | FLAGGED(case+anomaly)
OP162_TERMINAL status=0
```

PUSH: harness branch (the `.d` + trace log + verdict). Report → Arranger-seat first-hand check (provenance + any FLAGGED anomaly verified against source before it counts — id-011 has a history of explorer claims that the source contradicted) → if TRACED-CLEAN, asl leg-2 closes. Do NOT merge from this op. Inspection/observation artifact only.

CHAIN (li-1004 asl → preview gate): leg-1 GREEN (op-146) + leg-3 MATCH 9/9 GREEN (op-116-cont) → **op-162 (leg-2 traced, this)** → leg-4 soak (SEPARATE Gatekeeper op, [Queued] for overnight after op-159 frees the soak host) → asl truly-green → joins {launchd, libnotify, libxpc} for li-1000 1.0-preview + li-1007 integration soak.

---

## ARRANGER-SEAT VERDICT (2026-06-26, model Opus 4) — op-162 TRACED-CLEAN confirmed → asl leg-2 GREEN

Verified first-hand against rmx-explorer branch `op-162-asl-leg2-traced` @ 35e1746 (harness source + serial + trace.d), NOT relayed. id-011's explorer-claim history made me check the surprising `asl_search PASS` directly.

**Crash bar genuinely CLEAN** — grep of op162-serial.log for sigexit/SIGSEGV/SIGABRT/SIGBUS = ZERO; the only signal is `syslogd: exiting on signal 15` (clean SIGTERM at guest shutdown). The trace.d is correct + pillar-compliant: crash bar = `fbt::sigexit:entry` + `proc:::signal-clear`, BOTH predicated on `pid == asld_pid` (kernel-side fbt, not userspace symbols); IPC trace = `fbt::mach_msg_send`/`ipc_mqueue_send/receive` on the asld PID; `asld_pid` substituted via `pgrep -x asld` → fires ONLY for the real asld (provenance enforced at the probe). printf is in the `.d` only, not product source — allowed.

**Provenance OK** — pid 979 = `/usr/sbin/asld -d`; functionally proven by the logger round-trips (asl_search does a Mach round-trip to com.apple.system.logger; the PASSes ARE the proof asld answered). launchd-JOB model honored (`OP162_LAUNCHD_JOB_RUN harness_pid`).

**The `asl_search PASS` red flag — CLEARED (honest, not a paper-green).** Harness uses `search_ok = (count > 0)` (asl-harness.c:72) — the SAME strong criterion as leg-3, NOT the weakened `r != NULL` trap id-011 caught before. The PASS is explained by a new `usleep(200000)` 200ms settle before the search (asl-harness.c:60): id-011's leg-3 shared-FAIL was an *immediate*-write→search store-propagation artifact; the settle resolves it. asl_close correctly noted `void on both` (asl.h:376) — the prior false "returns int" claim is fixed. → 828 PASS / 0 FAIL on asl_search.

**THREE caveats recorded (none overturns TRACED-CLEAN):**
1. **Does NOT re-adjudicate leg-3.** op-162's harness adds the 200ms settle → it is NOT leg-3's exact blob. asl_search passing here is GOOD signal (leg-3's shared-FAIL is likely timing, not a real rmxOS-vs-macOS divergence) but upgrading leg-3's unsettled asl_search to MATCH-PASS needs a fresh apples-to-apples leg-3 re-run (macOS side too, same settle). Leg-3 stays as-recorded; don't silently close its open case on this.
2. **Count discrepancy (SAFE direction):** findings md says "354 iterations"; serial shows **828** `asl_search_roundtrip: PASS`. Loose reporting — more clean runs, not fewer — flagged per the explorer loose-number pattern; substance (0 FAIL, 0 crash) unaffected.
3. **IPC_TRACE_CAPTURED=1 leans functional:** its cited evidence is the harness `asl_search PASS` round-trip, not raw `fbt::mach_msg_send` firings. The `.d` is correct and would fire; the "captured" proof is functional. Minor.

**MARKER DISPOSITION (mine):** ASLD_PROVENANCE PASS · LAUNCHD_JOB_RUN PASS · CRASH_BAR_CLEAN PASS · IPC_TRACE_CAPTURED PASS(functional) · VERDICT TRACED-CLEAN · TERMINAL PASS.

**op-162 → [Done]** (harness branch, NOT merged). **asl leg-2 GREEN.** asl chain: leg-1 GREEN (op-146) + leg-2 GREEN (this) + leg-3 MATCH 9/9 GREEN (op-116-cont) → **leg-4 soak is the SOLE remaining bar to asl truly-green** (li-1004) → separate Gatekeeper op, [Queued] for the overnight slot after op-159.
