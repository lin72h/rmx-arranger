# op-155 — Explorer: capture the REAL freeze — fix the detector (HB-silence, iter≈400 gate), then allproc-walk WITH per-blocked-thread backtraces to settle id-025

op-155 | role: Explorer — **rmx-explorer / `explorer-rx` (rx1)**, FREE | state: READY dispatch (authorized) | parent id: id-025 | authored 2026-06-26 (Fable)
assignment rationale: rx1 owns the id-025 line + authored the op-153/op-154 rig this reuses directly. Free role, critical path. NOT "op-154-cont" — op-154 is [Done]; this is the next free op number.

PRECONDITION — op-154 left a PROVEN rig but the WRONG MOMENT (Fable-verified first-hand @ rmx-explorer f2f2d76):
- The host-side complete-capture RIG WORKS end-to-end: kgdb via the bhyve `-G` stub + `allproc` manual walk
  + mach.ko symbol resolution (sysroot/add-kld fixed). `scripts/op151/op154-capture-gdb.py` — REUSE it, do
  NOT re-author. mach.ko symbols resolve (`ipc_mqueue_receive`/`pset_receive`/`thread_block`/
  `thread_pool_wakeup`/`ipc_pset_signal` → real addrs).
- **WHY op-154 captured nothing (do NOT repeat):** its freeze detector fired on RAW SERIAL-SILENCE > 90s. But
  rc.local routes watchpoint+churn output to FILES in the guest, then runs `sleep 960` — so serial goes quiet
  BY DESIGN, not because of a wedge. The `allproc` walk PROVED the system was HEALTHY at "freeze" time:
  `pid=982 sleep` in `nanslp` (rc.local's own `sleep 960`) AND `pid=980 notify-churn-probe` in `nanslp`
  ACTIVELY ITERATING. op-151's "fast-freeze" was therefore a FALSE POSITIVE — retired. The real id-025
  candidate (op-150's iter≈400 / ~6.7-min freeze) was never reached.

OBJECTIVE: catch the ACTUAL freeze (not the by-design quiet), then run the op-154 rig PLUS per-blocked-thread
backtrace reconstruction, and from real stacks settle id-025: is any blocked thread in `ipc_mqueue_receive` /
`ipc_mqueue_pset_receive` / mach IPC (→ id-025 stack CAPTURED), or is the churn genuinely wedged with all
threads in benign waits (→ re-scope, PROVEN by stacks)?

DETECTOR FIX (the core of this op — make "freeze" mean a real wedge):
- (1) Route the watchpoint + churn **heartbeat (HB)** to `/dev/console` (serial), NOT to in-guest files, so
  the host detector sees genuine liveness. The churn iteration counter must reach the serial.
- (2) Trigger on **HB-SILENCE** (the liveness beat stopped), NOT raw serial-silence — rc.local's `sleep 960`
  must NOT look like a freeze. A live system beats; a wedged one stops beating.
- (3) Gate the freeze declaration on **churn iter ≈ 400** (op-150's observed onset, ~6.7 min) — do not declare
  a freeze before the churn has run far enough to plausibly hit the race. An early quiet is not the freeze.
- (4) kgdb-attach ONLY AFTER a real freeze is confirmed by (2)+(3).

CAPTURE — reuse op-154's rig, ADD per-blocked-thread backtraces:
- Run the op-154 sequence: sysroot set → `add-kld mach` → verify `info address ipc_mqueue_receive` is a real
  addr → `allproc` manual walk (enumerate every proc + thread, `p_state`/`wchan`/`wmesg`).
- **NEW — mandatory:** for each non-running blocked thread, reconstruct its **backtrace** from `td_pcb`
  (`pcb_rip`/`pcb_rbp`), not just `wchan`/`wmesg`. **WHY:** op-154 captured `wmesg` only, and `wmesg=thread_block`
  is AMBIGUOUS — a normal Mach msg-wait AND a wedged `ipc_mqueue_receive` BOTH block via `thread_block`. Only a
  real stack frame (`…ipc_mqueue_receive` / `…ipc_mqueue_pset_receive` in the bt) distinguishes the id-025
  wedge from a benign idle wait. `wmesg` alone cannot confirm id-025.
- CROSS-CHECK (cheap): on a confirmed freeze, also try NMI→DDB `ps`/`alltrace` (op-154's DDB leg ran but on a
  healthy guest); on a genuinely wedged guest it may add a second vantage.

DELIVERABLE / GATE:
- A freeze caught by the FIXED detector (HB-silence after iter≈400) — i.e. the churn counter on serial STOPPED
  advancing, distinct from rc.local's `sleep 960` quiet — verified by the `allproc` walk showing the churn
  probe (`pid` notify-churn-probe) NO LONGER in `nanslp`/advancing but BLOCKED.
- `allproc` walk (>2 threads) + mach.ko symbols resolved + **per-blocked-thread backtraces** captured.
- **Any blocked thread with `ipc_mqueue_receive` / `ipc_mqueue_pset_receive` / mach IPC in its bt** → the
  id-025 stack is CAPTURED → BREAKTHROUGH → op-142 releases to fix-and-prove against THIS stack.
- **Churn genuinely wedged but all stacks benign** (no mach-IPC frame) → id-025 is a DIFFERENT wedge, now
  PROVEN by real stacks → re-scope as its own id; op-142 stays [Hold].
- Detector never catches a real freeze across the budgeted runs (churn keeps advancing to completion, no wedge)
  → the freeze is rarer than op-150 implied → report; id-025 stays cataloged under the standing watchpoint.

METHOD (op-147m): Elixir orchestrates (extend the op-153/op-154 driver: HB-to-console wiring / iter-gate /
HB-silence detector / freeze→attach); kgdb + the `allproc`+bt walk = the host-side EVIDENCE layer (survives
the wedge); reuse the op-154 Python capture one-shot (observation only). No big shell harness. `.d` HB = the
liveness beat / detector only.

MARKERS (Elixir-driven):
```
OP155_HB_ON_CONSOLE status=0         # watchpoint+churn HB reaches /dev/console (serial), not files
OP155_REAL_FREEZE_CAUGHT status=0    # HB-silence after iter>=~400 — churn counter STOPPED, not rc.local sleep
OP155_BLOCKED_BT_CAPTURED count=0    # per-blocked-thread backtraces reconstructed (td_pcb), not just wmesg
OP155_THREAD_IN_MACH_IPC status=0    # a blocked thread with ipc_mqueue_receive/pset_receive in its bt
OP155_IDENTITY_VERDICT id025=0 different_wedge=0
OP155_TERMINAL status=0
```

PUSH: explorer branch (rx1); commit the detector-fix driver, the REAL-freeze capture (the `allproc` walk +
per-blocked-thread backtraces TEXT — NOT a multi-GB vmcore), the identity analysis. Report SHA → Fable
first-hand verify → Coordinator. PUSH to origin.

CHAIN (id-025): op-148 (watchpoint) → op-150 (fast freeze, no dump) → op-151 ("is id-025" over-claimed) →
op-153 (rig proven, "not id-025" refuted — saw only idle vCPUs) → op-154 ([Done]: complete capture; fast-freeze
= detection artifact, rig PROVEN, id-025 still uncaptured) → **op-155** (this: fix the detector + capture the
REAL iter≈400 freeze with per-thread backtraces) → op-142 [Hold] (releases on a real mach-IPC blocked stack;
else re-scope) → notify leg-4 / id-010 disposition.
