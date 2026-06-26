# id-025 — kernel Mach IPC deadlock-on-wait under sustained notifyd register/post/check/cancel churn

- id: id-025
- state: **STOCHASTIC RACE — op-140 closed with a DEFINITIVE NEGATIVE finding (2026-06-25,
  Arranger-verified first-hand against rmx-explorer-2 `explorer-rx2` @ ddb5e3d + the leg-4-exact oracle
  log). The op-123 leg-4 deadlock (sha 88ab17f7…) did NOT reproduce across 3 faithful re-runs: act-1
  (N=4, 30m clean), act-2 (N=1, 70m clean), act-3 (N=1, leg-4's OWN exact harness, ran to 87m / alloc
  49036 — PAST leg-4's 64m/35004 onset on both axes, delta=-1 flat throughout, no port-leak, no freeze).
  Conclusion: onset is NEITHER count- nor time-triggered — it is a non-deterministic RACE; the original
  freeze was a one-off race win, not a deterministic threshold. Frequency UNQUANTIFIED (1-in-4 observed,
  small sample). Consequence: the acceleration goal is MOOT (no reproducing baseline to accelerate;
  COUNT-vs-TIME cannot be separated). This reshapes op-142 from "attach debugger to an on-demand repro"
  to "race-hunt the Mach-IPC wait path" (see Fix shape) — and there is NO deterministic reproducer for
  the Implementer to fix-and-prove against (governance problem flagged below).**

  Prior (RAISED 2026-06-25): hard hang (deadlock-on-wait, bhyve 0.0% CPU / IC blocked-idle, NOT spin)
  after ~63 min of clean balanced churn in the op-123 leg-4 soak. Blocks notify truly-green (leg-4
  no-hang bar). Originally hypothesized as a count/time threshold — REFUTED by op-140.
- raised: 2026-06-25.
- roadmap parent: foundation/kernel Mach IPC track. Blocks notify conformance leg-4 (id-010/op-123) →
  the last of notify's 4 legs; legs 1-3 (lifecycle, traced matrix, conformance MATCH) are green.

## The bug (slope-log source-verified; mechanism to confirm)

Under the notifyd hours-scale soak (register/post/check/cancel loop, oracle slope sampled every 1m),
the guest runs **clean and balanced for ~63 minutes** then **hard-hangs**:

- **t=1m → t=63m:** port `alloc`==`destroy` every sample (`delta=0`); msg send/recv climb steadily
  (~3000 msg/min, ~550 port alloc+destroy/min). At t=63m: `alloc=34822 destroy=34822 delta=0`,
  `msg s=192541 r=195191`. Leak bars HOLD throughout active churn (the lone t=12m `delta=2` is
  transient — recovered to 0 at t=13m).
- **hang onset t=63m→t=64m:** t=64m is a *partial* tick (alloc +182 vs steady ~550; msg s +989 vs
  steady ~3000) then freezes: `alloc=35004 destroy=35002 delta=2 | dn: req=0 fire=0 | s=193530 r=196197`.
- **t=64m → t=112m (~48 min):** every sample byte-identical to the t=64m freeze line. No further
  progress, no FAIL lines, last round-trip SUCCESS (check=1). bhyve at kill: **0.0% CPU, state IC
  (blocked/idle) → deadlock-on-wait, not a spin**.

The `delta=2` at freeze = 2 ports in-flight at the hang instant (a snapshot), NOT a growing leak.

**Correcting the op-123 leg-4 report:** the report (and its summary.txt artifact) framed this as "~99 min
active churn / hang at 99-100m / frozen ~8m (t=100-107m)". The slope log contradicts that: active churn
is **~63m**, hang onset **~t=64m**, frozen **~48m through t=112m**. The qualitative verdict is unchanged
(leak bars held during active churn; no-hang bar VIOLATED; deadlock not leak) but the hang reproduces
**~35 min earlier** than reported — which is BETTER for the Implementer (faster repro).

## Relation to bl-009/id-009 (the fixed UAF)

Same broad area — Mach IPC port receive under pset churn (bl-009/id-009 = `ipc_mqueue_pset_receive`
UAF, fixed by the op-107 landing). **Different failure mode:** that was a use-after-free; this is a
deadlock-on-wait (0% CPU, blocked) with no corruption signature and balanced alloc/destroy right up to
the freeze. Likely a lock-ordering / wait-queue wakeup-miss exposed only after long sustained churn —
needs kernel-debugger diagnosis (lock state + blocked-thread backtraces at the hang).

## Fix shape (REVISED after op-140 stochastic verdict)
- ~~**Explorer (op-140):** accelerate the repro.~~ **DONE — no reproducing baseline exists; closed
  negative.** The deadlock is a race, not a threshold.
- **op-142 reshaped (Implementer, cost-30) — race-hunt, NOT debugger-on-demand:** there is no
  on-demand repro to attach to. Treat as a race in the Mach-IPC wait path: statically/dynamically
  instrument `mach_msg_receive` / `ipc_mqueue_receive` / `ipc_kmsg`; freeze signature = 0% CPU / thread
  state IC (blocked-idle); dead-name count stayed 0/0 across all runs (likely NOT the trigger). Do NOT
  gate the debugger on a count/time trigger. Use op-140's `.d` fbt oracle as always-on watchpointing to
  catch the freeze if/when it recurs. **GOVERNANCE PROBLEM:** without a deterministic reproducer the
  Implementer cannot fix-and-PROVE in the normal way — op-142 is therefore a *diagnosis/instrument*
  op (find the lock-order/lost-wakeup candidate by inspection + standing watchpoint), not a
  fix-and-validate op. A true fix-proof requires either (a) catching a recurrence under the standing
  oracle, or (b) a code-reasoned lock-order fix accepted on inspection. Decide the bar before dispatch.
- **Gatekeeper (after any fix):** re-run leg-4 hours-scale soak → but note a clean soak no longer
  *proves* the bug fixed (it never reliably reproduced) — it only fails to disprove. Absence-of-freeze
  over a long soak is weak evidence given a rare race.

## 1.0-preview implication — SCOPED 2026-06-25 (Arranger; NOT a readiness claim)
**Narrow scope of this decision:** id-025 (a soak-*survival* defect) does NOT by itself gate the
1.0-preview — it is cataloged as a KNOWN RARE RACE under a standing `.d` watchpoint, because a
non-deterministic race that can't be deterministically fix-and-proven is a poor release gate. That is
the *only* thing decided here.

**What this does NOT mean — correction (Arranger over-reached, Coordinator flagged 2026-06-25):** this
is NOT "ship the preview now." Preview readiness is a SEPARATE, currently-UNMET bar. Even the narrow
Mach/dispatch/notify floor is not clean — notify leg-4 (the no-hang soak) lives in that floor and is
only contingently green. And the roadmap's **OPEN CALIBRATION (roadmap.md:50-54)** — does the ship gate
*expand* to all four core services {launchd, libnotify, asl, libxpc} truly-green, or ship the narrow
floor first — **remains a Coordinator call, not closed here.** The Coordinator leans toward the
expanded gate ("libnotify + asl solid first"). Outstanding for either interpretation: notify leg-4
disposition, asl legs 2-4 (asl is at leg-1, op-146-pending), libxpc (long pole), launchd-real.

## op-142 proof-bar — DECIDED 2026-06-25 (Arranger): FREE gate before the cost-30 dive
op-142 (cost-30) is NOT released yet. Lead with **op-148 (Explorer, FREE):** static race-candidate
analysis of the Mach-IPC wait path (hunt the lock-order inversion / lost-wakeup by inspection) + author
the always-on `.d` watchpoint (Elixir+Zig+`.d` per op-147m — first retooled op, emits the deferred ACK
markers). Only if op-148 surfaces a concrete candidate does op-142 release as a **fix-on-inspection**
dive (code-reasoned fix, validated by inspection + surviving the next overnight leg-4 soak as weak
corroboration). If op-148 finds nothing actionable, id-025 stays cataloged under the watchpoint — no
cost-30 spent chasing a ghost.

## op-148 outcome — DELIVERED 2026-06-25 (Arranger-verified first-hand); op-142 STAYS HELD
op-148 (rx1) ran the static analysis + authored the standing `.d` watchpoint. It surfaced 4 candidates and
reported `candidate_for_op142=1` recommending op-142 release for A.1. **Arranger adjudication: op-142 does
NOT release.** Verified first-hand:
- **A.1 (`thread_pool_wakeup` no-op, `thread_wakeup` `#if 0`'d)** — REAL code defect, but **verified NOT the
  id-025 cause**: `waiting=1` is set only on the `block!=0` path of `thread_pool_get_act`, and all 4 callers
  use `block=0` (zero `block=1` callers tree-wide) → the bug is DORMANT/unreachable on the live soak path.
  Concrete *code* bug ≠ confirmed *id-025* root cause. Cataloged as **id-028** (latent, code-quality, cheap
  disposition, decoupled from id-025). Fixing it would NOT fix id-025 and a clean post-fix soak proves nothing.
- **A.2/A.3/A.4** (sx-race in `ipc_pset_signal`; unlock-mid-event in `filt_machport` hint==0; missing-
  interlock in `thread_block` callers) — WEAK, need DYNAMIC confirmation. Stay uninvestigated pending the
  watchpoint. No cost-30 chase.
- **Real op-148 value = the standing watchpoint** (`op148-freeze-watchpoint.d` + `watchpoint_conductor.ex`,
  Arranger-verified to exist/be sane) + the rejected-candidate analysis (PORT↔PSET order, oset↔nset).

**Net: the id-025 root cause remains UNFOUND.** op-142 stays [Held] — there is still no confirmed,
reachable defect to fix-and-prove. Next move is the watchpoint riding Gatekeeper's overnight leg-4 re-run
to catch a recurrence and pin A.2/A.3/A.4 (or none).

## op-150 RAN — FREEZE RECURRED ~6-8min, but NO freeze-window evidence captured (2026-06-25, Fable-verified first-hand @ rmx-gatekeeper 6697a4a)
op-150 ran the leg-4 soak with a NEW compiled C churn probe + the op-148 watchpoint. A freeze recurred
(bhyve 0% CPU / IC, serial frozen, churn stopped iter≈400 / ~6.7 min, fails=0). **The watchpoint captured
only 0-40s (4 HBs, counters balanced + linear, `blocked_now=0`), then went silent for the ~360s up to the
freeze → NO stacks/locks, NO slope fingerprint at onset.** Verdict: freeze-but-no-dump → op-142 STAYS Held
(nothing to fix-and-prove); routed to rx1 (op-151).

**Fable adjudication — what is vs isn't established (Rule-1, first-hand):**
- ESTABLISHED: a 0%CPU/IC deadlock-on-wait recurred on this harness, fast (~6-8 min).
- NOT established (confounded) — "id-025 window is minutes not hours": (a) the C churn probe is BRAND-NEW
  and never validated — a first-run freeze could be the probe's own defect (resource exhaustion / self-
  deadlock), not id-025 reached faster; (b) the op-123 distinguishing fingerprint (`alloc≈destroy`,
  `delta=2`, dead-name 0/0) was NOT captured, so "same id-025 deadlock" is inference from 0%CPU/IC alone,
  not a fingerprint match. Do NOT rewrite id-025 onset to "minutes" until both are ruled out.
- REJECTED as finding (hypothesis only): "profile-tick stopping = kernel-timer-path froze at 40s." More
  likely the in-guest userspace dtrace consumer/conductor STARVED as the guest wedged (observer died, not
  the kernel clock). No evidence of a kernel timer freeze.
- DOWNGRADED: "blocked_now=0 → thread_block isn't where it starts" — drawn from the healthy 0-40s window;
  the freeze developed in the UNOBSERVED 40-400s gap. Says nothing about onset.

**Two real takeaways:**
1. WATCHPOINT DESIGN GAP (not a mere bug): an in-guest userspace dtrace heartbeat CANNOT observe a deadlock
   that starves the whole guest — the consumer wedges too. Capture must come from a FREEZE-SURVIVING vantage:
   host-side (bhyve gdb stub / external introspection) OR kernel panic/DDB backtrace-on-deadlock.
2. POTENTIAL BREAKTHROUGH: if the fast freeze REPRODUCES reliably (minutes-scale), it dissolves id-025's
   governance problem (the "no deterministic reproducer" that blocked op-142 fix-and-prove) — IF it's the
   same deadlock and NOT a probe artifact. Highest-value follow-up. → op-151 (rx1).

## op-150 authored (Gatekeeper leg-4 re-run + watchpoint) — HELD, needs op-148 watchpoint committed (2026-06-25)
The leg-4 re-run is carried by **op-150** (Gatekeeper/rmx-gatekeeper). It is **Held, not Queued**, because
the op-148 watchpoint artifacts are present-but-**uncommitted**: Fable-verified first-hand that
`rmx-explorer` @ cf880c6 carries both as untracked (`??`) files —
`findings/nx-r64z/dtrace/id025-watchpoint/op148-freeze-watchpoint.d` (4792 B) +
`lib/rmx_os_oracle/id025/watchpoint_conductor.ex` (7511 B), in NO commit (`git log --all`). The Gatekeeper
pulls from a SHA, so they must be committed+pushed first. The golden image `build/op123-leg4/leg4-soak.img`
IS present; the only other reachable oracle is the original op-123 shell slope that already froze in op-140
and explained nothing → a re-run WITHOUT the watchpoint is not worth an overnight slot. **Unblock = commit
+push the two artifacts from the rmx-explorer working tree → SHA → Fable verifies blobs → op-150 → Queued.
(Earlier "stranded on rx1's env / not on host" was a Fable error — `git ls-files` hides untracked files and
a `head -40` truncated the find; the files were here all along, just never committed.)**

## Relations
- **id-010 / op-123** (notify conformance) — leg-4 no-hang bar: the freeze is non-deterministic, so
  leg-4 "green" is now a judgment call (see Gatekeeper note); notify is 3/4 firm + leg-4 contingent.
- **id-028** (latent lost-wakeup in `thread_pool_wakeup`) — surfaced by op-148 §A.1; verified NOT the
  id-025 cause (dormant). Separate code-quality item.
- **id-009 / bl-009** (`ipc_mqueue_pset_receive` UAF, FIXED) — same area, different mode (deadlock vs UAF).
- carrier ops: op-140 (Explorer repro-accelerate, FREE) → **CLOSED negative, stochastic verdict** →
  **op-148** (Explorer/rx1, FREE — static analysis + standing `.d` watchpoint) → **DELIVERED; surfaced
  id-028 (not the cause) + watchpoint** → **op-142** (Implementer, cost-30) **STAYS [Held]** (no confirmed
  reachable cause) → standing watchpoint attaches to Gatekeeper leg-4 re-run (overnight) to catch recurrence.
