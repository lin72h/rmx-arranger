# id-028 — latent lost-wakeup in thread_pool_wakeup (commented-out thread_wakeup)

- id: id-028
- state: OPEN — **latent/dormant defect** (NOT currently reachable). Decoupled from id-025 (see below).
  Cheap disposition; verify the `#if 0` rationale BEFORE blind-restoring.
- raised: 2026-06-25 (op-148 §A.1; Arranger-verified first-hand).
- roadmap parent: foundation/kernel Mach IPC (code-quality), NOT a notify leg-4 blocker.

## The defect (Arranger-verified first-hand)
`sys/compat/mach/kern/thread_pool.c` — `thread_pool_wakeup()`:
```c
if (thread_pool->waiting) {
#if 0
    thread_wakeup((event_t)thread_pool);   /* DISABLED */
#endif
    thread_pool->waiting = 0;
}
```
The wakeup is commented out, so a thread blocked in `thread_pool_get_act(block!=0)`
(`waiting=1; assert_wait((event_t)thread_pool); thread_block();`) would NEVER be woken by
`thread_pool_put_act` → permanent sleep at 0% CPU (textbook lost-wakeup).

## Why it is DORMANT, not the id-025 cause (verified)
`waiting` is set to 1 ONLY in the `block != 0` branch. **All four callers of `thread_pool_get_act` pass
`block=0`** (`ipc_mqueue.c:450/453`, `ipc_port.c:602`, `ipc_pset.c:406`) — verified by tree-wide grep,
zero `block=1` callers. So `waiting` is never 1, and the no-op `thread_pool_wakeup` never matters in the
running system. The bug is real but **unreachable on the current notifyd soak path** → it does NOT explain
the id-025 deadlock. (op-148 reported A.1 as the "concrete candidate" releasing op-142; Arranger corrected:
concrete *code* bug ≠ confirmed *id-025* cause. op-142 stays Held — see id-025.)

## Disposition (cheap, code-quality — NOT a cost-30 id-025 dive)
1. First determine WHY `thread_wakeup` was `#if 0`'d (port/debug iteration leftover? primitive mismatch?).
   The explorer's "disabled and never restored" is a hypothesis, not verified.
2. Then either (a) restore `thread_wakeup` matching the `assert_wait((event_t)thread_pool, FALSE)` pairing
   (thread_pool.c ~136) — verify it's the correct event_t/primitive convention; or (b) if `block=1` is
   confirmed permanently-unused dead code, treat the whole blocking path as dead and document it.
3. Small, contained change — does NOT need the cost-30 Implementer id-025 dive; size it as a minor fix.

## Relations
- id-025 (notifyd deadlock) — SAME subsystem, but id-028 is verified NOT its cause (dormant). Keep separate.
- bl-009/id-009 (`ipc_mqueue_pset_receive` UAF, fixed op-107) — same area lineage.
