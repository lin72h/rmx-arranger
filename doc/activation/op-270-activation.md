<!-- ROB tracking (not part of the paste): op-270 | role: Oracle (consult-only) | EXU: oracle2 | state: [Awaiting — RE-ISSUED to the oracle2 seat 2026-07-10 after oracle1 did NOT return this consult (7 of 10 oracle1 ops returned; op-270/272/276 still out — re-dispatched to oracle2 rather than left dangling if oracle1 goes offline). Content unchanged from the 2026-07-04 narrow re-scope that fenced it off op-262's already-resolved selection/refcount/death-drop findings; scope is the TWO residual sub-questions op-262 did NOT check (slot-index bounds, counter-cell reset-on-reuse). Fixed a stale "4 questions" typo in DELIVERABLE (only 2). Coordinator dispatches on oracle2 ack.] | parent id-010 (libnotify/notifyd) | L1i li-1003 (notify) | cost oracle-tier | authored 2026-07-04, re-issued 2026-07-10 (Arranger seat, model Opus 4). Paste from the "#" title line down. -->

# Confirm the correctness of notifyd's shared-memory slot allocation + refcount lifecycle — one feature, one daemon core

## PREAMBLE — what this project is
rmxOS is an **open-source operating system** — a Darwin/Mach userland ported onto stock FreeBSD 15, developed in the open like FreeBSD or illumos. This is a **maintainer's own code-quality check of ONE feature of our notification service** — how notifyd hands a client a shared-memory counter slot and reclaims it. Ordinary pre-release code-quality engineering on our own source. No target, no adversary, nothing to exploit — the goal is to confirm this one path is well-built for our own users.

## THE ONE FEATURE (this is the whole scope)
notifyd's **shared-memory slot lifecycle** — the `NOTIFY_TYPE_MEMORY` registration path in `usr.sbin/notifyd/notify_proc.c` (the `shared_memory_base` / `shared_memory_refcount` slot arithmetic, `nslots = getpagesize()/sizeof(uint32_t)`): notifyd allocates a slot in the shared counter page, refcounts it across multiple registrations on the same name, and frees/reclaims it on cancel or client death. A prior review of the name-table register/cancel balance read the same-name→same-slot mapping and the register/cancel refcount pairing, and flagged one specific slot-refcount gap (a pre-increment at `notify_proc.c:679` with no rollback on register failure at `:686-690`). This consult reads the whole slot lifecycle around that flag. Confirm this one path keeps its slot bookkeeping balanced — nothing wider.

## CONTEXT
Shared-memory notifications hand the client a slot in a counter page so a post is a cheap memory bump instead of a message. Correctness rests on the slot arithmetic staying in bounds and the refcount pairing exactly across register / cancel / death — a prior soak showed name-table balance at runtime, but the shared-memory slot refcount was not separately proven. Plain software-engineering framing: slot allocation + bounds, refcount balance, reclaim-on-death, and counter reset on reuse.

## THE QUESTIONS (the two a prior name-table review did NOT cover — do NOT re-ask selection / refcount-pairing / death-drop, those are already settled)
1. **Slot-index bounds.** Does slot-index selection stay within `nslots` (page / `sizeof(uint32_t)`) on every allocation path — no off-by-one or bug-reachable out-of-range index into `shared_memory_base` / `shared_memory_refcount`? (The prior review confirmed WHICH slot a name maps to and that the refcount pairs; it did NOT bounds-check the index arithmetic.)
2. **Counter-cell reset on reuse.** When a slot is freed and later reallocated to a new name — including the deliberate in-use-slot steal on exhaustion (`notify_proc.c:657-670`) — is the counter-page cell reset so the new client does not inherit a stale count from the prior owner? (The prior review noted reuse causes "spurious wakeups" but did NOT check whether the cell value is zeroed.)

Context already settled by that prior name-table review (state as given, do not re-derive): one slot per name (`:632-633`); `shared_memory_refcount` inc/cancel-dec pairs (`:171-174`); the `:679` pre-increment with no rollback on register failure (`:686-690`); memory slots ARE dropped on client death via `cancel_subscription`.

## DELIVERABLE
A short staged note in your own consult dir: for each of the 2 questions, a finding characterized **solid / uncertain / needs-runtime-check**, each a hypothesis with a `notify_proc.c` file:line citation. Anything uncertain, bucket by effort/risk. Every finding is a hypothesis the maintainers route to verification or a milestone seed — not a product edit, not a release decision.

## BOUNDARIES
- Read + advise only; propose, do not edit. Stage the note in your own dir.
- Scope is EXACTLY the shared-memory slot allocation / refcount / reclaim path in `notify_proc.c` — do NOT expand into the name-table register/cancel balance (already covered), the client API matrix, the delivery/post walk, or the launchd lifecycle. No interface-shape / cross-platform comparison work.
- Treat every observation as a hypothesis to confirm at source before it drives an edit. Read the actual struct/function body before flagging a bounds or refcount issue (notify path is `usr.sbin/notifyd/notify_proc.c`, not `lib/libnotify/`).
- Does not decide release timing or milestone placement.

## RELATIONS
The prior notifyd name-table register/cancel balance review (this extends its verified pre-increment/no-rollback flag into the full slot lifecycle) / the same narrow single-feature consult style as our recent asl-store and launchd-supervision reviews / the notify subsystem milestone (li-1003). Every finding is a hypothesis the maintainers verify at source before it drives any edit.
