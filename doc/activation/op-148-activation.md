# op-148 — Explorer: id-025 race-candidate analysis + standing `.d` watchpoint

op-148 | role: Explorer — **rmx-explorer / `explorer-rx` (rx1)**, FREE | state: **DONE 2026-06-25 (Arranger-verified)** | parent id: id-025 | authored 2026-06-25 (Fable)
OUTCOME: delivered §A (4 candidates) + §B watchpoint (exists/sane). Arranger first-hand verify: A.1
(`thread_pool_wakeup` no-op) is a REAL but DORMANT bug — all `thread_pool_get_act` callers use `block=0`,
so it's unreachable on the soak path → NOT the id-025 cause. Cataloged as **id-028** (code-quality,
decoupled). **op-142 does NOT release** (reported `candidate_for_op142=1` was overturned — concrete code
bug ≠ confirmed id-025 cause). A.2/A.3/A.4 stay weak/uninvestigated. id-025 cause remains UNFOUND; the
standing watchpoint rides Gatekeeper's overnight leg-4 re-run. op-142 [Held].
INSTANCE NOTE: dispatched to rx1 (not rx2 — the id-025 line's usual home). Consequences: (1) §C must use
rx1's OWN guest name + OWN staging dir cloned from the shared RO golden `build/op123-leg4/leg4-soak.img`
— do NOT touch rx2's `nxplatform-rx2` guest or `build/op140/` (host-isolation). (2) §B: op-140's leg-4
fbt oracle is LOCAL on rx2's unpushed `explorer-rx2` branch and NOT available to rx1 — reconstruct the
freeze-catcher from the providers listed in §B (`mach_msg_*` / `ipc_port_*` / `ipc_mqueue_*`).
method: op-147m — Elixir spine + Zig probe + DTrace `.d`; NO big shell harness; emit OP147M acks (§MARKERS).
gates: **op-142** (Implementer, cost-30, [Held]) releases as fix-on-inspection ONLY if §A yields a concrete
candidate; else op-142 stays Held (no cost-30 chasing a ghost).

OBJECTIVE: by source inspection, find the lock-order-inversion / lost-wakeup behind the id-025 deadlock,
and author a passive standing `.d` watchpoint to catch any recurrence. **Do NOT reproduce** — op-140
proved the freeze stochastic; no on-demand repro exists, so no guest soak.

FREEZE SIGNATURE (verified first-hand — this is what you must explain):
- bhyve 0.0% CPU, guest state IC → deadlock-on-wait, not spin.
- slope flat byte-identical at onset: `alloc=35004 destroy=35002 delta=2 | dn req=0 fire=0 | s=193530 r=196197`.
- `delta=2` = snapshot of 2 in-flight ports, NOT a leak (alloc==destroy through ~63m churn before onset).
- dead-name 0/0 every op-140 run ⇒ no-senders/dead-name path NOT the trigger — deprioritize it.
- 0% CPU + blocked ⇒ lost wakeup OR lock-order inversion; analyze BOTH.

§A — STATIC ANALYSIS (no guest). Locate the wait path by grep across `sys/` incl `sys/compat/mach`
(don't assume paths). Targets:
- `ipc_mqueue_receive` — empty-check → enqueue-waitq → `thread_block`; lost-wakeup window = between test and block.
- `ipc_mqueue_pset_receive` — STRONGEST lead; same fn family as the op-107 UAF (id-009), different mode;
  re-read op-107's surroundings for a wakeup/lock path it did NOT touch.
- waitq pairing: `waitq_assert_wait`/`thread_block` vs `waitq_wakeup`/`thread_wakeup` — every wait matched
  under the correct lock? pset↔port waitq linkage (set-membership wakeup = usual lost-wakeup culprit).
- `ipc_kmsg` enqueue/dequeue + `ipc_port`↔`imq` lock ordering — one consistent order send-vs-recv? flag inversions.
- send side: `mach_msg_send`/`ipc_mqueue_send` wakeup of the blocked receiver.
DELIVERABLE: writeup = fns found + lock/waitq pairing + **0/1/N candidates**, each =
(fn, exact window/ordering, hypothesis [lost-wakeup | lock-order], op-142 fix shape).
A reasoned "no single candidate" is a valid result.

§B — WATCHPOINT (Elixir spine + `.d`; base = op-140 leg-4 fbt oracle `mach_msg_*`/`ipc_port_*`/`ipc_mqueue_*`):
- add freeze-catcher: on flat slope (no `mach_msg_*` progress for K ticks) + blocked threads →
  dump blocked-thread `stack()`/`ustack()` + held-lock state (the evidence op-142 lacks today).
- providers loaded individually (`opensolaris dtrace fbt fasttrap systrace`), NOT `dtraceall`.
- Elixir owns drive/arm/heartbeat/flat-clock/ledger; Zig only if metal state the `.d` can't reach.
- PASSIVE: do NOT alter runner/transport (keep `run-as-launchd-job.sh`→`bs_probe` port-inheritance path);
  negligible overhead (must not perturb the race it watches).
- no big shell `.rc`/`.sh` harness as the evidence artifact; ad-hoc CLI fine.

§C — ARM-SMOKE (optional, FREE, ≤ few min — NOT a soak). Reuse op-140 setup: RO golden
`build/op123-leg4/leg4-soak.img`, throwaway copy, guest `nxplatform-rx2`, base-sanity check
(launchd/launchctl/notifyd/6 libs/bs_probe present — the nxplatform-dev trap). Confirm: providers load
individually, `.d` arms, Elixir heartbeat ticks, flat-detector fires. Then
`doas bhyvectl --destroy --vm=nxplatform-rx2`. Do NOT chase the freeze (stochastic; absence proves nothing).

VERDICT:
- candidate ≥1 → brief Fable → op-142 releases (fix-on-inspection; next overnight leg-4 soak = weak corroboration only).
- no candidate → id-025 cataloged under the watchpoint; op-142 stays Held; watchpoint rides next overnight leg-4 batch.

MARKERS (Elixir-driven, `.d`-asserted):
```
OP148_WAITPATH_ENUMERATED count=<n>
OP148_CANDIDATE_FOUND count=<0..n>
OP148_WATCHPOINT_AUTHORED status=0
OP148_WATCHPOINT_ARMS status=0
OP148_VERDICT candidate_for_op142=<0|1>
OP147M_METHOD_ACK · OP147M_DTRACE_D_OK · OP147M_ELIXIR_SPINE_OK · OP147M_NO_SHELL_HARNESS
OP148_TERMINAL status=0
```

PUSH: explorer branch; commit §A writeup + `.d` + Elixir runner (+ smoke log). No cores/large blobs.
No push to main. Report SHA in REPORT block → Fable first-hand verify → Coordinator merge.

CHAIN (id-025): op-140 (CLOSED negative, stochastic) → **op-148** (this) → op-142 [Held] →
Gatekeeper leg-4 re-run (overnight; weak-evidence caveat) → notify leg-4 / id-010.
