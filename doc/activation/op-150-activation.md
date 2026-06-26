# op-150 — Gatekeeper: notify leg-4 re-run with the op-148 id-025 watchpoint attached

op-150 | role: Gatekeeper — **rmx-gatekeeper**, FREE | state: **DONE-RAN / OBJECTIVE-MISSED 2026-06-25 (Arranger-verified first-hand @ rmx-gatekeeper 6697a4a)** — the OP ran to verdict; it did NOT meet its goal (capture freeze stacks). DONE = op lifecycle terminal, NOT "system OK": id-025 freeze is OPEN/unexplained, watchpoint capture FAILED. Work continues in op-151. | parent id: id-025 (relates id-010 leg-4) | authored 2026-06-25 (Fable)
OUTCOME (freeze-but-no-dump): a 0%CPU/IC freeze RECURRED fast (~6.7 min, churn iter≈400, fails=0) but the
in-guest watchpoint captured only 0-40s (healthy, balanced, blocked_now=0) then STARVED silent → no stacks,
no onset fingerprint. op-142 STAYS Held. Routed to rx1 (op-151). Fable downgrades the report's "kernel timer
froze" (unproven — observer starvation more likely) and "minutes window" (confounded — brand-new C churn
probe unvalidated + no fingerprint match) to hypotheses. Real takeaways: (1) in-guest dtrace can't observe a
guest-starving deadlock → need host-side/kernel-serial capture; (2) IF the fast freeze reproduces it's a
near-deterministic repro = id-025 breakthrough, pending probe-confound ruling. Full analysis: id-025.
WATCHPOINT NOW FETCHABLE (Fable-verified first-hand 2026-06-25): `23eb927` pushed to `origin/main`
(fast-forward `2bead3f..23eb927`; `git ls-remote origin` confirms tip=`23eb927b55ba`). The Gatekeeper's
clone can now fetch `op148-freeze-watchpoint.d` + `watchpoint_conductor.ex`. If it already fetched origin
BEFORE the push and early-aborted on `OP150_WATCHPOINT_ARMED`, re-poke it to re-fetch.
assignment rationale: fixed-bar overnight soak = Gatekeeper's; the watchpoint is an Explorer-authored artifact (op-148/rx1) that the Gatekeeper only *runs*, not authors.

PRECONDITION (why this is Held, not Queued):
- op-148's standing watchpoint **exists on the host but is UNCOMMITTED** (Fable-verified first-hand
  2026-06-25): `rmx-explorer` @ cf880c6 working tree carries both as untracked (`??`) files —
  `findings/nx-r64z/dtrace/id025-watchpoint/op148-freeze-watchpoint.d` (4792 B) +
  `lib/rmx_os_oracle/id025/watchpoint_conductor.ex` (7511 B); `git log --all` finds them in NO commit.
  The Gatekeeper pulls from a SHA, so they must be committed first.
- UNBLOCK STATUS: committed LOCALLY at **rmx-explorer `23eb927`** (2026-06-25, 3 files: the .d + the .ex +
  the §A writeup, 636 insertions). REMAINING step = **push `23eb927` to origin** so the Gatekeeper can fetch
  it; then op-150 references `23eb927` and flips Held→Queued. (Push is Coordinator-gated — not yet done.)
- A leg-4 re-run WITHOUT the watchpoint is explicitly NOT worth an overnight slot: the only other reachable
  oracle is the original op-123 `notifyd-soak-oracle.d` shell slope, which already froze in op-140 and
  explained nothing (0% CPU, flat slope, no blocked-thread stacks). No watchpoint ⇒ no new evidence ⇒ do
  not dispatch.

BASE + STAGING (proven substrate — never infer from size):
- image `build/op123-leg4/leg4-soak.img` (present on host; the op-123 leg-4 golden). Mandatory base sanity
  (BLOCKING pre-boot): `/sbin/launchd`, `/bin/launchctl`, notifyd + libnotify present on the mounted image.
- watchpoint pulled from the op-148 SHA above (the freeze-catcher: on flat `mach_msg_*` slope for K ticks +
  blocked threads → dump blocked-thread `stack()`/`ustack()` + held-lock state). Providers loaded
  individually (`opensolaris dtrace fbt fasttrap systrace`), NOT `dtraceall`.

OBJECTIVE: re-run the notify id-010 leg-4 hours-scale soak (register/post/check/cancel churn) on the golden
image with the op-148 watchpoint armed, to (a) catch an id-025 freeze recurrence WITH stacks/held-locks
this time (the evidence op-140/op-142 lack), and (b) pin or kill candidates A.2/A.3/A.4. PASSIVE: do NOT
alter the runner/transport (`run-as-launchd-job.sh`→`bs_probe` port-inheritance path); negligible overhead.

METHOD (op-147m): Elixir spine drives the soak + flat-clock + ledger; the watchpoint `.d` observes; Zig only
if metal state the `.d` can't reach. NO big shell `.rc`/`.sh` harness as the evidence artifact.

METHOD CLARIFICATION (Fable, 2026-06-25 — re Gatekeeper readiness report):
- The op-123 `notifyd-soak-driver.sh` (70-line shell churn loop) is BANNED — replace it with a compiled
  C/Zig churn probe (~50 lines: register_check→post→check→cancel at the original ops+rate) as the metal
  workload. Elixir orchestrates; compiled probe drives churn; op-148 `.d` observes. APPROVED.
- BINDING (PASSIVE): keep the `run-as-launchd-job.sh`→`bs_probe` launchd-child port-inheritance transport —
  the race may live on that path; do NOT alter it. Thin `rc.local` glue (boot + per-provider kldload +
  launchctl the probe + arm the `.d`) is acceptable thin glue, NOT the banned evidence harness.
- STOCHASTIC RECALIBRATION (correct the readiness report's "freeze at ~99m"): per id-025, onset was ~63m
  (not 99m), and op-140 proved the freeze STOCHASTIC (re-runs to 87m, no freeze). DO NOT expect a freeze;
  one 2h soak is a single sample of a rare race. Clean run = WEAK NEGATIVE, not a fix-proof. Run long
  (≥2h, longer = more exposure); value = catching a recurrence if it fires.
- PRECONDITION RESOLVED: `23eb927` IS on `origin/main` (Fable-verified `git ls-remote`); Gatekeeper just
  needs `git fetch origin`. No hold.

VERDICT (overclaim-strict — this is a RARE RACE; absence proves little):
- FREEZE RECURS + watchpoint dumps stacks/locks → the id-025 cause is finally evidenced → brief Fable →
  op-142 (Implementer, cost-30) releases as a fix-on-evidence dive against the captured backtrace.
- FREEZE RECURS but watchpoint fails to fire/dump → watchpoint defect; route back to Explorer (rx1).
- NO FREEZE over the soak → WEAK negative only (op-140 proved it stochastic); id-025 stays cataloged under
  the standing watchpoint; op-142 stays Held. A clean soak does NOT prove id-025 fixed.

MARKERS (Elixir-driven, `.d`-asserted):
```
OP150_BASE_SANITY status=0
OP150_WATCHPOINT_ARMED status=0
OP150_SOAK_RUNTIME_MIN=<n>
OP150_FREEZE_DETECTED=<0|1>
OP150_BLOCKED_STACKS_CAPTURED=<0|1>   # the evidence op-142 needs
OP150_VERDICT cause_evidenced=<0|1>
OP150_TERMINAL status=0
```

PUSH: gatekeeper branch; commit the run ledger + any captured stacks/lock-state (NO multi-GB image/core).
Report SHA → Fable first-hand verify → Coordinator.

CHAIN (id-025): op-148 (watchpoint authored, rx1, NEEDS PUSH) → **op-150** (this, Held until pushed) →
op-142 [Held] (releases only on a stack-evidenced freeze) → notify leg-4 / id-010 disposition.
