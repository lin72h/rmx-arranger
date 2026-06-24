# subsystem-mach-ipc — Mach IPC (the foundation) — RESTRICTED change-control

> ## ⚠ SPECIAL SUBSYSTEM — PER-LINE EXPLICIT APPROVAL REQUIRED
>
> **Mach IPC is the load-bearing foundation of the entire userland.** Every other
> subsystem (libdispatch, libxpc, notifyd, ASL, launchd, the Swift track) rides on it.
>
> **Every single line of code change to Mach IPC requires explicit Coordinator approval
> before it is written.** No exceptions, no "obvious" fixes, no in-passing edits, no
> Implementer discretion. This is NOT the normal op flow where an Implementer is issued a
> scoped task and works it — here, the *specific diff* is approved line-by-line first.
>
> **Why this gate exists:** Mach IPC changes have **unpredictable interaction with other
> kernel features** (kqueue/kevent, scheduler/thread, VM, ports/rights, signals,
> bootstrap). A change that looks locally correct can silently break a distant subsystem or
> a kernel invariant that only surfaces under runtime load. The blast radius is the whole
> system; the cost of a wrong line is days of cross-subsystem debugging. Caution here is
> cheap; a bad merge into the IPC core is not.
>
> **The protocol:** propose the exact diff → Coordinator reviews and approves *that diff* →
> only then is it written/committed. Treat any Mach IPC touch as irreversible-by-default
> until explicitly cleared (Rule 9: preserve a pre-spend checkpoint).

- subsystem: Mach IPC (mach_msg, ports/rights, port-sets, bootstrap, MIG, MACH_SEND/RECV)
- base (owned): NextBSD Mach IPC ported onto **FreeBSD-15** (`lin72h/rmxOS`)
- decision: **ACCEPTED base — RESTRICTED change-control** (per-line explicit approval)
- index: [subsystem.md](subsystem.md). Live phase-ladder state: memory `project_mach_rebase.md`.
  Verify file:line against the tree before acting.

## Why this exists (its role)

Mach IPC is the substrate every Darwin userland layer is built on. libdispatch's
`dispatch_source`/`dispatch_mach` ride Mach ports; libxpc rides Mach + bootstrap + libdispatch
MACH_RECV; notifyd/ASL/launchd all transact over Mach messages and bootstrap handoff. A defect
or regression in the IPC core is not a local bug — it is a whole-system fault. Hence the
strategy is conservatism + approval, not velocity.

## Base / lineage doctrine

- **Baseline (corrected 2026-06-12):** product upstream = `lin72h/rmxOS` branch **stable/15**,
  periodically synced from FreeBSD **stable/15**; runtime evidence branch
  `rmx/official-stable15-mach` (the stable15-active profile); `releng/15.1` demoted to a
  historical RC1 anchor. One git repo, two worktrees, parallel rebase-twin patch stacks (work
  lands on donor/full-import; runtime branch is the rebased snapshot).
- **Merge-based, NOT rebase, of the live shared history; NEVER force-push** — force-push
  destroys history and breaks the multi-agent/multi-clone model (propagation Rule 7:
  multi-clone repos sync only through origin).
- **Least-intrusive precedence: `donor > XNU-ref > local`** — prefer the NextBSD donor source,
  then an XNU reference vector, and only then a local edit. Local divergence from the donor is
  the last resort and itself wants approval.
- **Mach primitives OUTWARD, not Linux inward** — preserve Apple/Mach semantics and shapes;
  do not paper Mach over with Linux-isms. Think like Apple kernel engineers. Quality > speed.

## Current state (phase ladder — see project_mach_rebase.md for live detail)

- **Accepted:** Phase 0.5 / 0.5o Mach IPC core; Phase 0.7 dispatch smokes (launchd-minimum over
  GCDX TWQ); Phase 0.8 D1–D23 launchd lifecycle; ASL A1/A2/A3; notifyd N1.
- **N2 concurrency:** narrowed-accepted (N2C-1 / N2C-2a / N2C-3); **N2C-2b deferred**.
  (MACH_SEND replacement smoke activated; MACH_RECV dispatch-source servicing fix landed —
  op-081-R commit 5675145df333.)
- **Phase 0.85 handoff-extraction:** active (the bootstrap-port / launchd handoff spine).
- **Baseline:** rmxOS **stable/15**, stable.

## Interaction hazards (the reason for the gate, concretely)

A Mach IPC change can perturb, often non-locally:
- **kqueue/kevent** — MACH_RECV sources, `EVFILT_MACHPORT` (kernel filter is currently
  `null_filtops`; id-003), port-set wakeups.
- **ports & rights** — send/receive-right accounting, no-senders notifications, dead-name,
  port-set membership; a leaked/over-released right corrupts unrelated services.
- **scheduler / threads** — TWQ worker servicing, QoS/priority tokens, blocking `mach_msg`
  semantics.
- **bootstrap / launchd** — service check-in/look-up, handoff nonce identity.
- **VM** — OOL/complex message descriptors, memory entry handling.

Because these couplings are not all statically visible, a change validated only against its
local call site can still regress a distant consumer at runtime. The per-line approval gate
exists precisely to force a whole-system review before any IPC-core line moves.

## Change-control protocol (restating the header, operationally)

1. **No Mach IPC edit without an approved diff.** Implementer proposes the *exact* lines;
   Coordinator approves that specific diff; only then is it written.
2. **Layer-exoneration discipline first** (op-092 style): prove the defect is in the IPC core
   first-hand before proposing a change there — exonerate the consumer/shim/kernel-filter
   layers, since the bug is often above or below the IPC core, not in it.
3. **Pre-spend checkpoint** before any IPC-core commit (Rule 9). Treat as irreversible until
   cleared.
4. **Validators + first-hand Arbiter verification** at full strictness; an IPC-core retire is
   never waved through.
5. **Push-after-commit to origin** (Rule 7) — an IPC-core commit that isn't origin-reachable is
   not retired; downstream subsystems must build against the same origin hash.

## Recommendation

Own the NextBSD-on-FreeBSD-15 Mach IPC base; harden it with maximum conservatism. Default to
"do not touch the IPC core" — push fixes outward into the consuming subsystem or downward into
the kernel filter/substrate (cataloged in the IDQ) whenever the defect can be correctly fixed
there instead. When the IPC core genuinely must change, go line-by-line through the approval
gate above.
