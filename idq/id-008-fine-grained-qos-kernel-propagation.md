# id-008 — fine-grained QoS: kernel-propagated QoS (kevent_qos / workloops / voucher-carried QoS)

- id: id-008
- state: **WAITING (pending)** — the big-ticket half depends on the kernel substrate (id-001
  kevent64 + a QoS policy engine), which is behind a Coordinator A-vs-B strategy gate. A
  cheaper userland-only sub-item (per-QoS `rtprio_thread` ordering, see Scope) is fetchable
  independently.
- research note (2026-06-23): this file folds a first-hand QoS investigation (provenance of the
  workqueue, what the active path actually enforces, the FreeBSD priority substrate, and the
  cheap `rtprio_thread` route). It corrects a prior "4-band **priority**" assumption — see
  **Provenance** + **Correction** below. Captured as research; not fetched.
- raised: 2026-06-23 (from the QoS first-hand audit + swift-corelibs Linux comparison)
- roadmap parent: [roadmap.md](../roadmap.md) — Layer-3 QoS fidelity; relates to Gate B
  (Darwin parity) and the "explicitly NOT 1.0 / future kernel track" arc.
- relations: **id-001** (kevent64 — the unlock for `kevent_qos`/workloops), **id-002**
  (QoS-attr `UNSPECIFIED` Darwin parity, userland), **id-004** (non-NORMAL-QoS timer fflags).

## The three QoS layers on our base (first-hand, 2026-06-23)

1. **QoS API/taxonomy — PRESENT.** `<pthread/qos.h>`, `qos_class_t`, the 6 dispatch QoS
   classes (`queue.c` root-queue table maps each root queue to a `dgq_qos`), `pthread_priority_t`,
   `pthread_attr_get/set_qos_class_np` (the active `NXPLATFORM_DISPATCH_TWQ_WORKQUEUE` path).
2. **QoS → concurrency lane, NOT CPU priority — PRESENT (weaker than first assumed).**
   `HAVE_PTHREAD_WORKQUEUES=1` (config.h:103); libdispatch submits via
   `pthread_workqueue_addthreads_np(dgq_wq_priority, …)` (`queue.c:3364`). **First-hand
   correction (2026-06-23):** the active TWQ path maps QoS to a *lane* and controls **per-lane
   concurrency/admission** (`twq_parallelism_limit`, `twq_lane_target_locked`, scheduled/admitted
   counts, overcommit) — it does **NOT** set the worker thread's ULE scheduling priority.
   Grepped both the libthr bridge (`thr_workq.c`) and the kernel module (`kern_thrworkq.c`) for
   `sched_prio`/`rtprio`/`setpriority`/`td_pri`/sched-class: **zero hits**. Workers run at
   default priority. So QoS shapes *how many* threads per class run concurrently, not *which*
   gets the CPU. (Earlier "4-band priority" / "band-deterministic CPU ordering" framing was an
   overclaim — see **Provenance** + **Correction** below.)
3. **Fine-grained kernel QoS — ABSENT.** `WORKQ_FEATURE_FINEPRIO/KEVENT/WORKLOOP` are defined in
   the header but not the active path. No `kevent_qos`/`kevent_id`, no kqworkq/kqworkloop, no
   kernel QoS scheduling, no voucher-carried QoS over Mach IPC enforcement. (`voucher.c` Mach
   voucher *machinery* is present but not kernel-enforced for scheduling.)

## Comparison: our base vs Apple swift-corelibs-libdispatch on Linux (first-hand)

Source read: `/Users/me/wip-gcd-tbb-fx/nx/swift-corelibs-libdispatch` (the modern
event-subsystem fork — has `src/event/{event_epoll.c,workqueue.c}`; ours is the classic
pre-refactor monolithic `source.c`).

| aspect | rmxOS (classic Mach / FreeBSD) | swift-corelibs (Linux) |
|---|---|---|
| lineage | classic Apple Mach, pre-refactor | modern event-subsystem fork |
| QoS taxonomy | full 6 classes (present) | full QoS buckets (`DISPATCH_QOS_NBUCKETS`) |
| QoS granularity *applied* | **per-class concurrency lane** (no CPU-priority applied) | **per-QoS `nice`** (finer, but advisory) |
| enforcement mechanism | **admission/concurrency per QoS lane** (`kern_thrworkq.c`); no per-thread sched-priority on active path | `setpriority(PRIO_PROCESS, 0, nice)` per thread (`queue.c:7947`) |
| worker pool | kernel thr-workqueue (`HAVE_PTHREAD_WORKQUEUES=1`) | userland monitored thread pool (`event/workqueue.c`, `_dispatch_workq_monitors[NBUCKETS]`) |
| QoS-over-IPC (vouchers) | Mach voucher machinery PRESENT (not kernel-enforced) | ABSENT — no Mach; firehose activity-ids only |
| `kevent_qos`/kqworkloops | no (id-001) | no (epoll; N/A) |
| fine-grained kernel QoS policy engine | no | no — **Linux has none** (explicit comment, `queue.c:7929`) |

**The key, slightly counterintuitive, finding:**
- **Neither has XNU's fine-grained kernel QoS policy engine.** swift-corelibs *says so in a
  comment*: "The Linux kernel does not have a direct analogue to the QoS-based thread policy
  engine found in XNU" — SCHED_OTHER threads share priority (CFS/EEVDF `sched_get_priority_*`
  return 0), so it falls back to per-thread `nice`.
- swift-corelibs maps QoS to a **CPU-priority knob at the userland→OS boundary** (per-QoS nice;
  our active path applies *no* CPU priority, only concurrency lanes — see Correction) — but its
  nice is **advisory** (best-effort under CFS, not a QoS guarantee), and it **threw away Mach**
  entirely on Linux.
- Our base applies QoS as **concurrency-only** today (no CPU ordering), but **retains the Mach
  QoS structure** (vouchers,
  Mach-aware dispatch) that swift-corelibs discarded — which, per "Mach primitives outward", is
  the actual route to *real* QoS-over-IPC propagation once the kernel substrate lands. This is
  another reason swift-corelibs was rejected as a base (it would need a Mach QoS backend built
  from scratch).

Net: both are **QoS-aware, not QoS-enforcing**. swift-corelibs = finer-but-advisory + no Mach;
ours = coarser-but-Mach-structurally-ready.

## Provenance: the QoS workqueue is NextBSD-added, not ULE-native (first-hand 2026-06-23)

The QoS/workqueue machinery is **not** a pre-existing FreeBSD ULE feature that NextBSD plugs
into — FreeBSD ULE has no QoS and no workqueue concept. NextBSD **ported the XNU-style pthread
workqueue** wholesale, a three-layer stack (none stock FreeBSD):

1. **Userland** — `lib/libthr/thread/thr_workq.c`. Git-explicit import: `9fbf3e8` "libthr:
   import GCDX workqueue bridge", `c1d3b90` "libthr: normalize TWQ QoS priorities". Apple-modeled
   bridge added to FreeBSD's libthr (stock libthr has no `qos_class_t`/buckets). Does QoS-token →
   bucket/lane *classification* in userland (`twq_bucket_from_priority`); no priority enforcement.
2. **Kernel** — `sys/kern/kern_thrworkq.c` + `sys/sys/thrworkq.h`, a NextBSD-added syscall
   (`TWQ_SYS_KERNRETURN`) wired into `syscalls.master` / `init_sysent.c` / `syscall.h`. The
   workqueue *manager* lives in the kernel but is NextBSD's own code. Does **admission/concurrency
   per lane**, not priority.
3. **FreeBSD ULE** — provides only generic threads + the scheduler. Contributes zero QoS
   semantics; it is the substrate the import sits on top of.

Layering: **NextBSD QoS workqueue (userland bridge + kernel module) → FreeBSD generic threads.**
Not "ULE QoS that NextBSD calls."

## Correction to prior assumption (supersedes the "4-band priority" framing)

Prior docs (an earlier rev of this file + op-era notes) described our QoS as a "4-band
**priority** mapping" with "band-deterministic CPU ordering vs Linux's hint." First-hand grep of
`thr_workq.c` + `kern_thrworkq.c` found **no** `sched_prio`/`rtprio`/`setpriority`/`td_pri`/
sched-class call anywhere. The active TWQ path enforces **concurrency/admission per QoS lane**,
not scheduler priority. Corrected three-way behavioral model:

- **Linux nice** = CPU **weight** (advisory proportional share under contention).
- **macOS QoS** = CPU **priority + inheritance** (enforced ordering + bounded inversion + IPC propagation).
- **ours, today** = **per-class concurrency / pool-sizing** (how many workers per class), **no CPU
  ordering at all** on the active path.

Confidence: solid for the active QoS-token TWQ path (the one `queue.c:3364` feeds). NOT yet
chased: whether the legacy `_np` band path applies priority via a different route. Definitive
settle = DTrace `sched_*` / `td_priority` on-guest under mixed-QoS load and watch whether worker
priority varies by class (DTrace-first discipline).

## Scope (when promoted) — two tiers

**Cheap, userland-only (no kernel substrate needed) — fetchable independently:**

Add **per-QoS CPU ordering via `rtprio_thread`** *on top of* the existing admission/concurrency
lanes — giving concurrency-shaping (have) **+** per-thread ordering (add), strictly richer than
both Linux (nice-only) and our-today (concurrency-only). Spec:

- **Use `rtprio_thread(2)` (per-thread), NOT `nice`/`setpriority`.** Trap: on FreeBSD
  `setpriority(PRIO_PROCESS)` / `nice` is **per-process** (`sys/sys/priority.h`: `pri_user`
  derives from `p_nice`) — the literal swift-corelibs `setpriority(PRIO_PROCESS,0,nice)` would
  move the *whole dispatch process*, not one QoS worker. Linux gets away with it only because
  tasks == threads. FreeBSD's per-thread knob is `rtprio_thread` (`sys/sys/rtprio.h`,
  `kern_resource.c`; syscall confirmed present).
- **Substrate is ample** (`sys/sys/priority.h`, first-hand): range 0–255 (effective ~64 runqueues
  — header: "diffs <4 insignificant"); classes realtime 8–39, timeshare 56–223, idle 224–255.
  Mapping 4–6 QoS classes fits easily — resolution is **not** the constraint.
- **We can beat Linux nice:** `RTP_PRIO_IDLE` is a *strict* "only when nothing else runnable"
  (stronger BACKGROUND than nice+20's proportional slice); `RTP_PRIO_REALTIME` genuinely preempts
  timeshare for USER_INTERACTIVE; middle classes = timeshare. Suggested map:
  BACKGROUND/MAINTENANCE → IDLE, UTILITY/DEFAULT → timeshare, USER_INITIATED/INTERACTIVE →
  REALTIME(low).
- **Open implementation Qs (settle first-hand in `kern_thrworkq.c` before fetch):**
  - *lane-affine vs floating workers* — if a worker is bound to one lane for life, set rtprio
    once on join (cheap); if workers float across lanes, must re-apply rtprio on every work-item
    dequeue (XNU-style re-assert), more cost/care.
  - *userland vs kernel apply point* — userland (worker self-`rtprio_thread` once it knows its
    lane; zero kernel change; cheapest) vs kernel (`kern_thrworkq.c` sets `td` priority at
    admission; atomic with lane logic; needs kernel edits).
- **Inversion caveat:** strict `RTP_PRIO_IDLE` for BACKGROUND + a shared lock = potential stall
  (HIGH waiter blocked on an IDLE holder that never runs); no priority-inheritance on this path
  to rescue it. Mitigate (avoid strict IDLE for lock-holding classes) or accept as a known-gap
  until the big-ticket inheritance path lands.

**Big-ticket (needs the kernel track) — gated on id-001 + Coordinator A-vs-B:**
- Kernel `kevent_qos`/workloops; voucher-carried QoS propagation over Mach IPC with scheduler
  enforcement; the XNU QoS-override path. This is the genuine Darwin-fidelity QoS and is the
  5-year-adjacent kernel work, not 1.0.

## Open decisions (Coordinator-held)
- fetch the cheap userland `rtprio_thread` QoS-ordering sub-item now (concurrency + ordering,
  strictly-richer-than-Linux Layer-2 win), or hold the whole item behind id-001?
- is QoS scheduling fidelity even a 1.0 requirement for the service-usable target, or a
  post-1.0 hardening arc? (Current roadmap puts fine-grained QoS in "explicitly NOT 1.0".)
