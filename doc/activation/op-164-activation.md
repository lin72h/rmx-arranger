# op-164 — Gatekeeper: id-025 cond-3 close — identify the `thr_acts` (parked-receiver) offset, re-interpret op-159 fire=1, upgrade necessary-condition → full A.4 precondition FROM DATA ALREADY CAPTURED (no re-soak)

op-164 | role: **Gatekeeper** (FREE) | EXU: **rmx-gatekeeper-rx-x64z** | state: [Ready] dispatch (authorized) | parent id: id-025 | authored 2026-06-26 (Arranger seat, model Opus 4)
purpose: op-159 retired having proven the id-025 bug's NECESSARY condition reachable on live notifyd (2 fires on `ipc_pset_move`'s no-set→set branch, pid 968), but only 2-of-3 — cond-3 (a direct receiver PARKED at the transition = what makes the freeze specifically the A.4 lost-wakeup) was unconfirmed because the `thr_acts` offset wasn't identified. THIS op closes cond-3. Critically: **no new soak is needed** — op-159's fire=1 already captured the candidate field (`off98 = fffff80003c9f200`, NON-NULL). If `off98` is confirmed = `thr_acts`, fire=1 retroactively IS the full 3-condition A.4 precondition. This is an offset-identification + re-interpretation op on EXISTING data.

STATE OF THE WORLD (verified first-hand, do NOT re-derive):
- op-159 evidence @ `rmx-gatekeeper dfb3b04`: `findings/op159-reachability-proven.txt` + `op159-precondition-watchpoint.d`. Two fires, both port `0xfffff80003447340`, nset `0xfffff80003f5f958`, curproc=notifyd pid=968, via `mach_port_move_member`. `ip_pset@0x80` was disassembly-confirmed (`movq 0x80(%rax)` vs nset in `ipc_pset_move`).
- Port-struct dump per fire: fire=1 `off98 = fffff80003c9f200` (**NON-NULL**), fire=2 `off98 = 0` (NULL). (NOTE: op-159's prose summary garbled this as "NULL across fires" — the RAW dump shows non-NULL at fire=1. Trust the raw dump.)
- The bug's cond-3 = a parked act on the port's OWN thread pool: a thread enqueued via `thread_pool_put_act` (ipc_mqueue.c:813) into `rcd_thread_pool.thr_acts`, i.e. a non-NULL `thr_acts` head = a direct receiver parked RIGHT NOW.

DELIVER:
1. **IDENTIFY the `thr_acts` offset** in `struct ipc_port` / the embedded `rpc_common_data.rcd_thread_pool`, by the SAME method that nailed `ip_pset@0x80`: disassemble `thread_pool_put_act` (and/or `ipc_mqueue_receive` / the `thr_acts` head load) in mach.ko, read the offset off `%rax`/the port base. Cross-check against `off98` (0x98) — the op-159 candidate. Cite the disassembly (instruction + offset), do NOT assert.
2. **CONFIRM the semantics**: a non-NULL value at that offset == a parked act on the port's own pool (not some unrelated field). State the basis (struct layout / the enqueue path writing it).
3. **RE-INTERPRET op-159 fire=1**: if `thr_acts` == `off98` and fire=1's `off98` is non-NULL → fire=1 satisfied ALL THREE conditions (entering a set + no-set→set + parked receiver) = the **full A.4 precondition, OBSERVED on the live workload**. If `thr_acts` ≠ `off98` (offset is some other slot that was NULL/garbage at the fires) → cond-3 is NOT evidenced by the captured dumps → say so plainly (then a targeted re-capture with the correct offset in the predicate is a SEPARATE new op — do NOT silently re-soak here).

GATES (id-011 / overclaim discipline — Arranger will check first-hand):
- Offset is DISASSEMBLY-CITED, not guessed. A wrong offset reads garbage and the cond-3 claim is void.
- The verdict states EXACTLY one of: (a) full-precondition OBSERVED at fire=1 (cite offset + value), or (b) cond-3 NOT evidenced by captured data (offset identified but was NULL at the fires / offset ≠ off98). No third "probably" — this op exists to remove the ambiguity, not restate it.
- This is a CODE/DISASSEMBLY-reasoned close on captured data — no live repro, no re-soak (feedback: a code-reasoned dive needs no live repro).

MARKERS:
```
OP164_THRACTS_OFFSET status=0     # thr_acts offset identified from mach.ko disasm (cite instr+offset); off98 confirm/deny
OP164_SEMANTICS status=0          # non-NULL @ offset == parked act on port's own pool; basis cited
OP164_FIRE1_REINTERP status=0     # (a) full A.4 precondition OBSERVED @ fire=1 (offset+value) | (b) cond-3 NOT evidenced by captured data
OP164_VERDICT status=0           # FULL-PRECONDITION-PROVEN | NECESSARY-ONLY-CONFIRMED(cond-3 needs targeted re-capture = new op)
OP164_TERMINAL status=0
```

PUSH: gatekeeper branch (the disasm cite + the fire=1 re-interpretation + verdict). Report → **Arranger-seat first-hand verify** the offset derivation (disassembly, not assertion) + the fire=1 value before it upgrades the merge bar (op-159 already had one garbled-summary; verify the raw). → resolves op-156's merge:
- If **FULL-PRECONDITION-PROVEN**: id-025 reachability is airtight (necessary + sufficient observed) → op-156 eligible to MERGE clean → id-025 closes → notify leg-4 / id-010 unblocks.
- If **NECESSARY-ONLY-CONFIRMED**: the Coordinator's merge call falls back to (A) merge-on-necessary-condition (op-159 retired result + historical freeze + sound/covered/falsified fix), OR a targeted re-capture op with the now-known offset in the predicate.
Do NOT merge from this op (offset/re-interpretation artifact only). op-164 itself resolves [Done]→[Retired] on the verdict; do not park it.

CHAIN (id-025): op-156 (fix sound) + op-157 (coverage) + op-158 (falsify) [inspection CLOSED] + op-159 (necessary-condition reachability, [Retired]) → **op-164 (cond-3 close, this)** → op-156 merge decision → id-025 closes → notify leg-4 / id-010 unblocks.
