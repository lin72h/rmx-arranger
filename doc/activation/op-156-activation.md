# op-156 — Implementer: code-reasoned id-025 dive — map the Mach-IPC wait-path lock discipline, NAME the inversion/lost-wakeup, propose the fix (fix-on-inspection, NO live repro required)

op-156 | role: **Implementer** (cost-30) | state: READY dispatch (authorized) | parent id: id-025 | authored 2026-06-26 (Fable)
assignment rationale: source-edit + build work = Implementer-exclusive. This RELEASES the cost-30 dive that was wrongly held behind a live capture for ~2 days. Supersedes op-142 ([Flushed] — its "wait for a captured stack" gate was the error; re-issued here as the inspection dive). Runs IN PARALLEL with op-155 (Explorer capture), not behind it.

PREMISE — the dive does NOT need a live reproducer (the correction that releases this op):
- id-025 is a non-deterministic deadlock-on-wait (0% CPU / IC blocked-idle) under sustained notifyd
  register/post/check/cancel churn; ~63 min onset in op-123 leg-4, rarer/faster elsewhere. No deterministic
  repro exists and capture has not yet landed a blocked-thread stack (op-150→155).
- A kernel deadlock is diagnosable by CODE REASONING — read the lock-acquisition order + wakeup discipline of
  the Mach-IPC wait path and find the inversion or the lost-wakeup BY INSPECTION. That is not guessing; it is
  the normal way a skilled kernel engineer roots a race without a live hang. Think like an Apple Mach engineer:
  reason about the primitive's invariants, not Linux-style band-aids.
- op-148 already narrowed the field (Fable-verified). This op confirms/refutes those candidates by reasoning
  and produces a named root cause + fix.

PRIOR ART TO READ FIRST (do not re-derive):
- op-148 static analysis (rmx-explorer) — the 4 candidates + the REJECTED orderings (PORT↔PSET, oset↔nset).
- id-025 record (idq/id-025) — the freeze signature (balanced alloc/destroy to the instant; delta=2 snapshot,
  not a leak; dead-name 0/0 across all runs → likely NOT the trigger).
- bl-009/id-009 (op-107 landing) — the FIXED `ipc_mqueue_pset_receive` UAF, same area, different mode (UAF vs
  deadlock). Read it for the pset-receive locking shape; the deadlock likely lives adjacent.

OBJECTIVE: map the lock + wakeup discipline across the Mach-IPC wait path and NAME the defect with file:line —
a lock-order inversion OR a lost-wakeup window — then propose the minimal fix, with a reasoned argument for why
it closes the deadlock that the Validators can check on inspection (NOT by a soak the Implementer runs itself).

WAIT-PATH TO MAP (the lock-acquisition order + who wakes whom):
- `ipc_mqueue_receive` / `ipc_mqueue_pset_receive` — the blocking receive; what locks held when it calls into
  `thread_block`, and what wakeup it waits for.
- `ipc_pset_signal` — the signaller side; lock order vs the receive side (op-148 A.2: sx-race / port↔pset).
- `filt_machport` — the kqueue filter path; op-148 A.3: does it unlock mid-event when `hint==0`, dropping a
  wakeup?
- `thread_block` callers + `thread_pool_wakeup` — op-148 A.4: is there a window where `waiting` is set / a
  wakeup is delivered without the interlock, so a concurrent block misses it (classic lost-wakeup)? (Note:
  A.1 `thread_pool_wakeup` no-op is DORMANT/unreachable — id-028 — do NOT spend on it; confirm it stays out of
  the live path while you're in there.)

CANDIDATE DISPOSITIONS (confirm or refute EACH by reasoning, with file:line evidence):
- A.2 sx-race in `ipc_pset_signal` — is the port-lock / pset-lock / sx acquisition order consistent with the
  receive side, or is there an inversion under concurrent signal+receive?
- A.3 unlock-mid-event in `filt_machport` (`hint==0`) — can a wakeup be dropped between the unlock and the
  re-check, leaving a receiver blocked with a message queued?
- A.4 missing-interlock in `thread_block` callers — is the wait-flag-set / wakeup-deliver pair properly
  interlocked, or is there a check-then-block gap where the wakeup races ahead and is lost?

DELIVERABLE / GATE (Implementer produces; Validators gate on inspection — NOT a self-run soak):
- **Wait-path lock/wakeup map** committed (the acquisition order + wakeup contract, file:line).
- **A NAMED root cause** (one of A.2/A.3/A.4, or a new one found while mapping) — the exact inversion or
  lost-wakeup window, with file:line and the interleaving that deadlocks.
- **The minimal fix** as a concrete diff on the Implementer branch + a clear argument for why it closes the
  race (the invariant it restores), expressed so it can be checked by reading, not only by running.
- **Clean `buildworld` + `buildkernel`** with the fix (Implementer owns builds; report the built kernel/mach.ko
  path + SHA, exit codes verified first-hand — tail the log, check artifacts; a task "exit 0" is a claim).
- DO NOT self-prove by soak. Proof = (a) Validators GLM (enumerate every caller/lock-holder of the touched
  path; verify the order claim exhaustively) + DS4P (falsify: can the fix deadlock differently / regress UAF
  bl-009?) on inspection, THEN (b) corroboration — op-155's capture confirming the named stack, and/or the
  standing `.d` watchpoint surviving the next overnight leg-4 soak (Gatekeeper, weak corroboration). The fix
  merges to mainline only after Validators pass; until then it lives on the Implementer branch.
- If reasoning REFUTES all of A.2/A.3/A.4 and surfaces no new named cause → report that (a real negative), and
  the dive informs op-155's capture (now the primary path) rather than landing a speculative fix. Quality >
  speed: do NOT land a fix you cannot argue for.

OPTIONAL (high value, within scope): express the restored invariant as a `.d` assertion (op-147m observation
leg) so the lock-order / no-lost-wakeup property becomes a standing watchpoint — turning the fix's correctness
argument into a runtime check the Gatekeeper soak can falsify.

MARKERS:
```
OP156_WAITPATH_MAPPED status=0                 # lock-order + wakeup contract across the path documented (file:line)
OP156_CANDIDATE_DISPOSITION a2=0 a3=0 a4=0     # each confirmed|refuted by reasoning, with evidence
OP156_ROOTCAUSE_NAMED status=0                 # a specific inversion or lost-wakeup window, file:line + interleaving
OP156_FIX_PROPOSED status=0                    # concrete diff + invariant-restored argument
OP156_BUILD_CLEAN status=0                     # buildworld + buildkernel green; artifact path + SHA
OP156_TERMINAL status=0
```

PUSH: Implementer branch; commit the wait-path map, the candidate dispositions, the named root cause, the fix
diff, the build evidence. Report SHA + built-artifact path → Fable first-hand verify → Validators (GLM+DS4P,
inspection) → Coordinator. Do NOT merge to mainline pre-Validator-pass. PUSH to origin.

CHAIN (id-025): op-148 (static candidates) → [op-142 Flushed — held wrongly behind capture] → **op-156** (this:
code-reasoned dive, fix-on-inspection) ∥ op-155 (Explorer capture, now corroborator) → Validators gate the fix
on inspection → Gatekeeper leg-4 soak + op-155 stack = corroboration → merge → notify leg-4 / id-010 green.

---

## FABLE FIRST-HAND VERDICT (2026-06-26) — branch op-156-id025-waitpath @ 180d30b, verified against base ipc_pset.c/ipc_mqueue.c/thread_pool.c

**A.4 lost-wakeup: CONFIRMED REAL by code, end-to-end.**
- Direct receiver enqueues into the *port's own* thread pool: `ipc_mqueue_receive` → `thread_pool_put_act(self)` with `self->ith_object = port` (ipc_mqueue.c:811-816). Then `thread_block()`.
- Delivery routes **solely on `port->ip_pset`**: `ipc_mqueue_deliver` looks in the pset pool iff `port->ip_pset != NULL`, else the port pool (ipc_mqueue.c:443-454). So the instant a port joins a set, every send skips the port pool.
- The defect branch: `ipc_pset_move` `oset==IPS_NULL → nset` (ipc_pset.c:333-343) set `port->ip_pset = nset` via `ipc_pset_add` but **never woke the port-pool waiters** → a thread parked in the bare-port direct receive sleeps forever = the id-025 0%-CPU blocked-idle signature.

**The fix: CORRECT, low-risk, symmetric.** `ipc_pset_port_changed(port, MACH_RCV_PORT_CHANGED)` drains the port pool via `thread_pool_get_act(port,0)` + `thread_go` — identical machinery to the pre-existing `ipc_pset_changed` (PORT_DIED, ipc_pset.c:399) and the `ipc_port.c:602` waker. `MACH_RCV_PORT_CHANGED` is an already-handled wakeup reason: `ipc_mqueue_receive_error` returns it cleanly at ipc_mqueue.c:556-559 (NO `thread_pool_remove` double-pop — that only runs on the IN_PROGRESS spurious case). Woken receiver re-issues, now sees `ip_pset=nset`, routes via the set. Lock discipline sound: call site holds `ip_lock(port)` (323→381) + `ips_lock(nset)`; `thread_pool_get_act(port,0)` needs port io_lock — held. No new lock order. Placement correct (only the no-set→set branch can have direct port-pool waiters; the both-non-null branch was already pset-routed).

**block=0 / A.1 ghost: DOES NOT APPLY.** This is the receiver-pool *drain* (pop `thr_acts`) — the same proven path `ipc_mqueue_deliver` uses to find receivers — NOT the dormant `thread_pool_wakeup` `waiting`-flag manager mechanism that made A.1 inert.

**RESIDUAL GAP — reachability (the one thing code reasoning cannot close):** the MECHANISM is proven; whether notifyd's register/post/check/cancel churn actually parks a thread in a DIRECT receive on a bare port AND then moves *that* port into a set is NOT proven by inspection. → **op-155 capture is the corroborator** (must show a thread blocked in `ipc_mqueue_receive` on a port whose `ip_pset != NULL`). A real bug, very plausibly THE bug — but "closes id-025" stays UNPROVEN until corroborated. id-025 stays OPEN; fix lives on the branch, NOT merged.

**BUILD_CLEAN over-claim: CORRECTED.** OP156_BUILD_CLEAN status=1 is over-claimed — only the touched mach module (mach.ko / ipc_pset.o, SHAs in the op note) built clean; full `buildworld`/`buildkernel` hit three walls (libc_nonshared `__iconv_bool`; kpilite `thread_lite`; dtrace `systrace_freebsd32`). Fix correctness is independent of them, but Implementer owns a clean `buildkernel` → walls must be cleared OR shown pre-existing on base before merge.

**DISPOSITION:** route to Validators **GLM** (exhaustive: enumerate every direct-receiver→port-pool enqueue site; confirm the wake-loop + lock order covers all; confirm no other `ipc_pset_move` branch needs it) + **DS4P** (falsify: woken-then-re-block race; bl-009 UAF regression; build-wall provenance). Merge ONLY after Validators pass AND (op-155 corroborates OR reachability otherwise demonstrated). op-156 → **[Done]** (Fable-verified: root cause + fix sound on inspection); id-025 stays OPEN pending corroboration.
