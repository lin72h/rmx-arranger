# op-151 — Explorer: confirm the op-150 fast-freeze repro + re-architect id-025 watchpoint for freeze-surviving capture

op-151 | role: Explorer — **rmx-explorer / `explorer-rx` (rx1)**, FREE | state: AWAITING dispatch (authorized) | parent id: id-025 | authored 2026-06-25 (Fable)
assignment rationale: rx1 owns the id-025 line + the op-148 watchpoint being re-architected; op-150's freeze-but-no-dump routed here.

PRECONDITION — RESOLVED 2026-06-26 (Fable-verified first-hand). The op-150 C churn probe is now FETCHABLE:
- The probe (authored by the Gatekeeper for op-150 — the metal churn workload) is committed at
  **`4b16fd1`** and PUSHED to the gatekeeper repo's `origin/main` (Fable pushed `b532ed4..4b16fd1` + verified
  `git ls-remote` tip = `4b16fd1b65e7…`). The 3 files: `findings/op150-notify-churn-probe.c` (54 lines —
  register_check→post→check→cancel), `findings/op150-churn-probe.plist`, `findings/op150-rc.local`.
- **CROSS-REPO FETCH (do this — agents are NOT a shared origin):** each agent has its OWN GitHub repo. rx1's
  `origin` is `git@github.com:lin72h/rmx-explorer.git` and does NOT carry the gatekeeper's commits. To get
  the probe, rx1 adds the gatekeeper repo as a remote and fetches:
  `git remote add gatekeeper git@github.com:lin72h/rmx-gatekeeper.git && git fetch gatekeeper` then read the
  3 files from `gatekeeper/main` @ `4b16fd1` (e.g. `git show 4b16fd1:findings/op150-notify-churn-probe.c`).
  Use the SAME probe — re-implementing risks a different probe that won't reproduce the SAME freeze.
- §A is now UNBLOCKED. §B (re-architect the freeze-surviving capture rig — host-side bhyve-gdb /
  kernel-serial / ring-buffer) never needed the probe and can run in parallel. §A is the higher-value
  "do FIRST" question (is the fast freeze a deterministic id-025 reproducer?) — prioritize it.

CONTEXT (op-150, Fable-verified first-hand @ rmx-gatekeeper 6697a4a): the leg-4 soak with a NEW compiled C
churn probe + op-148 watchpoint FROZE fast (0% CPU/IC, churn iter≈400 / ~6.7 min). The watchpoint captured
only 0-40s (healthy, balanced, `blocked_now=0`) then went SILENT for the ~360s up to the freeze → no stacks,
no onset fingerprint. Two problems to settle here. DO NOT assume the op-150 "kernel timer froze at 40s" or
"id-025 window is minutes" claims — both unproven (see §A confound + §B vantage).

§A — CONFIRM THE REPRO + RULE OUT THE PROBE CONFOUND (do this FIRST; it's the high-value question):
- Re-run the op-150 C churn probe N times (≥5) on a fresh throwaway clone of the golden
  `build/op123-leg4/leg4-soak.img`. Does it freeze in minutes EACH time? Record onset (iter + wall-clock)
  per run. A reliable minutes-scale freeze = a near-deterministic reproducer (id-025's missing piece).
- RULE OUT "the probe itself is buggy": does the C churn probe leak ports / self-deadlock independent of the
  kernel race? Sanity-check it — (i) run the identical probe against a KNOWN-GOOD baseline (e.g. shorter
  burst / stock notifyd path) and confirm it completes clean; (ii) audit the probe for its own resource
  exhaustion (unbounded registrations, un-cancelled tokens). If the freeze is a probe artifact, say so —
  that REFUTES the "minutes window" claim and the op-150 freeze is not id-025.
- CONFIRM IT'S THE id-025 DEADLOCK, not a new one: capture the op-123 fingerprint at/near freeze if at all
  possible — port slope (`alloc≈destroy`, `delta` snapshot), dead-name 0/0, last round-trip success, 0%CPU/IC.

§B — RE-ARCHITECT THE WATCHPOINT FOR FREEZE-SURVIVING CAPTURE (the design gap, not a bug):
- ROOT ISSUE: an in-guest userspace DTrace heartbeat/consumer STARVES when the guest fully deadlocks — it
  wedges with everything else, so it can never dump the freeze it's watching (op-150 proved this: silent
  from 40s). A louder in-guest `.d` will NOT fix it.
- Re-author capture from a vantage that survives a full-guest freeze. Options to evaluate (pick by feasibility):
  (a) HOST-SIDE introspection — bhyve gdb stub / `bhyvectl` to halt+inspect the wedged guest from the host,
      pull blocked-thread backtraces + lock state post-freeze (the host is NOT frozen);
  (b) KERNEL panic/DDB on deadlock-detect — a watchdog that, on flat-slope + blocked-threads, forces a
      panic/DDB with `bt`/lock dump captured to serial (serial survives the wedge);
  (c) in-kernel ring buffer dumped on the panic/NMI path.
- KEEP the op-148 healthy-slope heartbeat as a freeze DETECTOR (it works up to onset); ADD the surviving
  capture as the EVIDENCE layer. Method op-147m: Elixir orchestrates; the capture is host-side or
  kernel-serial; `.d` only where it can reach. NO big shell harness.

GATE / VERDICT:
- §A reliable minutes-repro CONFIRMED + same-fingerprint + probe NOT the culprit → BREAKTHROUGH: brief Fable
  → op-142 reshapes from race-hunt to **debugger-attach-to-on-demand-repro** (the governance blocker
  dissolves). This is the win condition — prioritize proving/refuting it.
- §A freeze is a PROBE ARTIFACT → refute the "minutes window"; op-150 freeze decoupled from id-025; id-025
  stays the rare-race-under-watchpoint; fix the probe before any further soak.
- §B delivers a freeze-surviving capture rig (host-side or kernel-serial) → next leg-4 soak can finally
  catch stacks/locks → THEN op-142 releases on captured evidence.
- op-142 stays [Held] throughout op-151 (still no captured stacks/locks).

MARKERS (Elixir-driven):
```
OP151_REPRO_RUNS count=<n> froze=<k>
OP151_REPRO_ONSET_MIN run=<i> min=<m>
OP151_PROBE_CONFOUND_RULED status=<0|1>   # 1 = probe is NOT the cause
OP151_FINGERPRINT_MATCH status=<0|1>      # matches op-123 leg-4 signature
OP151_SURVIVING_CAPTURE_AUTHORED status=0 # host-side or kernel-serial
OP151_SURVIVING_CAPTURE_PROVEN status=<0|1> # actually dumped across a real freeze
OP151_VERDICT repro_deterministic=<0|1> probe_artifact=<0|1>
OP151_TERMINAL status=0
```

PUSH: explorer branch (rx1); commit the repro ledger (per-run onsets), the probe-confound audit, the new
capture rig, any captured backtrace/lock dump. No multi-GB images/cores. Report SHA → Fable first-hand
verify → Coordinator. PUSH to origin (op-150 learned this: local-only commits aren't fetchable by peers).

CHAIN (id-025): op-148 (watchpoint, 23eb927) → op-150 (freeze recurred ~6-8min, no dump) → **op-151** (this:
confirm repro + freeze-surviving capture) → op-142 [Held] (releases on captured evidence OR reshapes to
debugger-attach if §A confirms a deterministic repro) → notify leg-4 / id-010 disposition.
