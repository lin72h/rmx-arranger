# testing-dtrace-enablement — DTrace proven on-guest + standing decision

- tier: **shared baseline** (all roles)
- state: **ACTIVE** (decided 2026-06-22, after op-094/op-096)
- companion to: [testing-dtrace.md](testing-dtrace.md) (the doctrine — *why* DTrace over printf).
  This doc records *that it works on our guest, how to enable it, and the decision to keep it.*
- index: [testing.md](testing.md). Verify guest state before acting (modules can be unstaged
  on a fresh image).

## The decision

**Continue DTrace-first as the ACTIVE shared baseline, and enforce it per-op** — do not leave
it as doctrine an agent might not re-read. Concretely:

1. **Every implementing op states it** (the op-096 addendum becomes the default): "DTrace-first,
   no committed prints, individual-provider loads." Agents follow the dispatch.
2. **Gatekeeper retirement criterion:** "debugging done DTrace-first; zero committed
   `printf`/`dprintf` in the diff." Turns the rule from remembered into enforced-at-retire.
3. **Individual-provider loads is the accepted recipe** — do NOT burn an op chasing the
   `dtraceall` meta-module (see Open below). It already works; that's the standard.

The legitimate-print exceptions in [testing-dtrace.md](testing-dtrace.md) still hold:
DTrace-first ≠ DTrace-only. The rule is "don't *commit* throwaway prints" and "don't edit the
code under investigation to observe it" — not "never print."

## Proven on-guest (op-094, first-hand)

DTrace settled the dispatch_after (a)/(b) question — "is the `EVFILT_TIMER` kevent
submitted+delivered, or never armed?" — in **one correlated script** (`pid` +
`syscall::kevent*` + `fbt::filt_timer*`), with op-093's poll disabled. The full chain traced:

- SUBMITTED: `SYSCALL kevent ENTRY kq=4 nchanges=1` → `RETURN rc=0`
- KERNEL ACCEPT: `FBT filt_timerattach ENTRY` + `filt_timervalidate ENTRY`
- KERNEL FIRE: `FBT filt_timerexpire ENTRY` (then `filt_timerdetach`, EV_ONESHOT consumed)
- DELIVERED: `SYSCALL kevent RETURN rc=1` (manager receives the fire)

Result: branch (a) — dispatch_after fires purely through the kevent; op-093's "FreeBSD may not
report the `EVFILT_TIMER` event" premise was **falsified first-hand**. op-096 then removed the
redundant poll and re-confirmed the same chain on the poll-free build (commit `129ee3c`,
origin-reachable).

This is the proof case: a **kernel-boundary** question that `printf` structurally cannot
answer (prints in libdispatch see only userland, never the kernel-side `filt_timerexpire` /
`kevent` return), settled cleanly and without perturbing a timing/race path.

## Guest enablement recipe (verified 2026-06-22)

- **Hooks: present.** `KDTRACE_HOOKS` + `KDTRACE_FRAME` compiled in (MACHDEBUGDEBUG →
  MACHDEBUG → GENERIC), confirmed in the built kernel binary.
- **Build the modules once.** `make` under `sys/modules/dtrace/*` against the rmxOS kernel obj;
  stage the `.ko`s into `/boot/kernel`. Staging + load + run need root → `doas`
  (Coordinator-authorized for test-guest observation infra; reversible; no kernel/product
  source edits).
- **Load the providers individually** (all `rc=0`): `opensolaris`, `dtrace`, `fbt`,
  `fasttrap`, `systrace`. The correlated `pid` + `syscall::kevent*` + `fbt::filt_*` script runs
  on these.
- **`kldload dtraceall` FAILS** — the meta-module also pulls `kinst` + `systrace_freebsd32`,
  which aren't built. Not a blocker: load providers individually.

## Why it helped (honest ROI — attribute precisely)

- **The win is op-094, not op-096's 8-minute wall-clock.** op-096 was a *delete* op (cheap
  regardless of tooling); reading the 2h→8m gap as "DTrace = 15× faster" overstates it. The
  real value: op-094 answered a question `printf` couldn't, and *that* turned op-096 from a
  nervous "dare we pull the poll?" into a confident, verified removal.
- **Reusable harness.** The op-094 script + loaded providers carried into op-096 at ~no cost.
  `printf` loops have zero carryover — each iteration re-pays recompile→redeploy→strip.
- **No Heisenberg on race/timing bugs.** Synchronous `dprintf(2,…)` can shift the very race;
  DTrace probe overhead is far lower (the op-093 bug was a manager-bootstrap race).
- **One-time cost, now paid.** Building/staging the modules wasn't free; from here, observation
  is cheap and non-perturbing for every future op.
- **The bigger payoff is ahead** — the next *discovery-class* bug, where DTrace replaces a
  from-scratch `printf` hunt. op-094/op-096 prove the harness on an already-localized problem.

## Open (decided: accept, do not spend an op)

- **`dtraceall` meta-module deps unbuilt** (`kinst` + `systrace_freebsd32`). Accepted standard
  is **individual-provider loads**. Only revisit if a future script needs a provider that only
  the meta-module pulls — then a small one-time build op, not before.
