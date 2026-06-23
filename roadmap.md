# roadmap — rmxOS (NextBSD revive) to a usable 1.0

- tier: **most abstract** in the work hierarchy `roadmap → backlog → op-NNN` (see
  [terminology.md](terminology.md) §6). The roadmap names *what usable 1.0 means and in what
  order we get there*; the backlog ([backlogs/bl-000.md](backlogs/bl-000.md)) holds pending
  items; an `op-NNN` is an in-flight work unit. **Promotion chain:** a roadmap gate spawns
  backlog items; a backlog item is *fetched* into op(s).
- status: living (Arranger-held; Coordinator owns the milestone/usability target).
- discipline: **truly-green, not paper-green.** A gate is passed only on first-hand evidence,
  never on an agent's say-so (overclaim-strict).

## What "usable 1.0" means (pin the consumer, or the bar is undefined)

| level | definition | 1.0? |
|---|---|---|
| developer-usable | build + run Darwin-style programs against Mach/dispatch/notify on FreeBSD 15, macOS-fidelity on the exercised surface | floor |
| **service-usable** | launchd boots real services (notifyd, asl, own daemons) over Mach/XPC; they stay up under soak; conformance-matched to macOS; gaps cataloged | **TARGET** |
| self-hosting / GPU | the 5-year memory_object → IOKit-style GPU arc | NOT 1.0 |

**Usable is a threshold, not a guarantee.** Passing the gates means *no known blocking defect
on the target use-cases, with remaining gaps named and bounded* — NOT bug-free, NOT every
NextBSD subsystem. It is coverage-bounded: we certify the surface we exercise + instrument, for
the consumer we defined. "Usable" answers "can someone do the thing?", never "what fraction of
all code is correct?" (There is no global bug-rate metric and we do not claim one.)

### 1.0-preview — the near-term target (ship ASAP; conformance-after) (2026-06-23)

The **1.0-preview (developer-preview)** is a deliberately-narrower milestone we ship **ASAP**,
ahead of the full service-usable 1.0. Its floor is exactly the developer-usable row: *build + run
Darwin-style programs against **Mach / dispatch / notify**, on a bootable image.* That is a
**narrower critical path** than full 1.0:

- **In the preview floor:** Mach IPC (substrate — proven, bl-009/op-108), libdispatch (9-case core
  — bl-006), libnotify/notifyd (bring-up — bl-010), a bootable USB/ISO (bl-012 Tier 0).
- **Deferred past the preview to full 1.0:** asl (bl-011), **libxpc** (the long pole + its
  nvlist-vs-mpack design fork — NOT on the preview path: a preview runs against Mach/dispatch/notify,
  not XPC), and launchd-driving-real-services (Gate C).

**Tempo + scope stance:** speed comes from **cutting scope, not quality**. macOS semantic
conformance is a **long-term arc, not a preview gate** — a divergence is *cataloged as a known gap*
(Gate E, "doesn't block use-case X") in preference to closing it with a complex/risky
implementation. The evidence bar is unchanged: whatever the preview ships is truly-green /
overclaim-strict, and the Mach foundation stays solid. A cataloged gap is honestly labeled, never
paper-greened. The "can afford to be slow" quality arc continues *after* the preview.

## The gate ladder (A–F)

Each gate carries: whether it is a **runtime** test, its **truly-green** criterion (so
"finished" can't mean paper-green), and the backlog/op that carries it.

### Gate A — mach-ipc invariants green under load  *(runtime)*
Promote the op-099 fbt probe library from *tracers* to *assertions*: `mach_msg` send/receive
balanced, `ipc_port` alloc/dealloc balanced, no stuck enqueue, dead-name/no-senders delivered.
- truly-green: invariants hold over a sustained soak, asserted by DTrace predicates (the probe
  *is* the test), not exit-code 0.
- carries: op-099 (RETIRED — library exists) → invariant-oracle op (pending, see backlog).

### Gate B — each layer working AND conformance-matched to macOS  *(runtime + one design sub-gate)*
Per layer: primitive/functional surface works *and* the same harness run on the macOS explorer
(truth) and the rmxOS explorer is semantics-diffed.
- libdispatch: primitive surface DONE (op-098); timer USDT enabled (op-101). Next: breadth +
  conformance + soak — the **runtime harness** (the first place we *define* truly-green; becomes
  the template for the layers above).
- notifyd / asl: next rung (no USDT → pid/fbt/cross-layer correlation).
- **libxpc — the long pole.** Includes a **design sub-gate (NOT runtime):** the serialization
  fork (nvlist vs ravynos-mpack) must be decided before XPC can be "usable", because launchd +
  services ride it.
- truly-green: conformance diff vs a *current* macOS run, not exit-code-green standing in for
  behavior-matched.

### Gate C — launchd lifecycle driving real services  *(runtime)*
The load→start→observe→restart→remove→reload spine (closed at D23 on fixtures) driving *actual*
daemons (notifyd/asl + own), not test fixtures.
- truly-green: real services transition through the full lifecycle and survive restart/reload.

### Gate D — integration soak  *(runtime — the most runtime of all)*
All layers together under sustained load (launchd → libxpc → libdispatch → mach-ipc) with the
Gate A invariants watching for leaks/hangs/races over hours.
- truly-green: hours-long soak, zero invariant violations, no leak/hang — not a 5-minute run.

### Gate E — known gaps cataloged, not hidden  *(NOT runtime — adjudication/bookkeeping)*
1.0 ships *with* a backlog (bl-001 kevent64, bl-002 QoS-attr, bl-004 non-NORMAL-QoS timers,
bl-005 semaphore poll, …), each scoped "doesn't block use-case X."
- truly-green: every known gap has a backlog id + a non-blocking justification.

### Gate F — reproducible build / stage / boot  *(infrastructure — boot is runtime-ish)*
The donor-import → build → stage → guest-boot path is a button, not a ritual.
- truly-green: a clean checkout builds + boots the guest reproducibly by someone other than us.

## Runtime vs not — at a glance

- **Runtime, real-world tests:** A, C, D, and the implementation/conformance half of B.
- **Not runtime:** the libxpc *serialization decision* (design), Gate E (cataloging), Gate F
  (build pipeline; boot is runtime-ish).

## Critical path & the long pole

```
mach-ipc invariants (A) ──┐
libdispatch (B, basics done)─┼─► integration soak (D) ─► usable 1.0
notifyd/asl (B, next)      ──┤
libxpc decision + impl (B) ──┘   ← LONG POLE (design fork + implementation)
launchd spine (C, mostly done)
```
The DTrace instrumentation work is the *instrument* that lets us run A and D credibly — it is
necessary tooling, not the finish line. The finish line is the soak (D) passing + libxpc (B)
resolved.

## Near-term move (the template)

Stand up the **libdispatch runtime conformance + soak harness**: functional matrix breadth
(async/sync/apply/once/barrier/group/semaphore/source-timer/source-MACH_RECV/data/io, block +
`_f`), run on both explorers and diffed vs macOS-as-truth, with op-099/op-101 probes promoted to
invariant oracles. This single piece exercises Gate A + Gate B + seeds Gate D, and **defines
truly-green concretely** before we spend that pattern on the harder layers. Tracked as a backlog
item (see [backlogs/bl-000.md](backlogs/bl-000.md)).

## Explicitly NOT 1.0

- kernel kevent64 substrate (bl-001) — userland shim is deliberately lossy; real
  `kevent_qos`/workloops are the future substrate (Coordinator A-vs-B strategy gate).
- memory_object / GPU integration — the 5-year center.
- non-NORMAL-QoS timers (bl-004), full QoS-attr Darwin parity (bl-002), semaphore absolute-
  deadline (bl-005) — hardening items.
