# roadmap — rmxOS (NextBSD revive) to a usable 1.0

- tier: **L1i** — the **most abstract** tier in the work hierarchy `L1i → IDQ → ROB` (see
  [terminology.md](terminology.md) §6). The roadmap is the L1 i-cache: each milestone is an
  instruction (`li-NNN`) naming *what usable 1.0 means and in what order we get there*. The **IDQ**
  ([idq/id-000.md](idq/id-000.md), `id-NNN`) holds decoded items queued for fetch; a **ROB** entry
  (`op-NNN`) is an in-flight work unit. **Promotion chain:** an L1i instruction (`li-NNN`) is
  *decoded* into IDQ item(s) (`id-NNN`); an IDQ item is *fetched* into ROB entr(ies) (`op-NNN`).
- status: living (Arranger-held; Coordinator owns the milestone/usability target).
- discipline: **truly-green, not paper-green.** An `li-NNN` **retires** only on first-hand evidence
  that its truly-green criterion holds — never on an agent's say-so (overclaim-strict). "Usable 1.0"
  = all `li-NNN` retired (li-001…li-008 as of 2026-06-24; li-007/li-008 added when libxpc + launchd
  were elevated to core preview services).

## What "usable 1.0" means (pin the consumer, or the bar is undefined)

| level | definition | 1.0? |
|---|---|---|
| developer-usable | build + run Darwin-style programs against Mach/dispatch/notify on FreeBSD 15, macOS-fidelity on the exercised surface | floor |
| **service-usable** | launchd boots real services (notifyd, asl, own daemons) over Mach/XPC; they stay up under soak; conformance-matched to macOS; gaps cataloged | **TARGET** |
| self-hosting / GPU | the 5-year memory_object → IOKit-style GPU arc | NOT 1.0 |

**Usable is a threshold, not a guarantee.** Retiring the `li-NNN` milestones means *no known blocking
defect on the target use-cases, with remaining gaps named and bounded* — NOT bug-free, NOT every
NextBSD subsystem. It is coverage-bounded: we certify the surface we exercise + instrument, for
the consumer we defined. "Usable" answers "can someone do the thing?", never "what fraction of
all code is correct?" (There is no global bug-rate metric and we do not claim one.)

### 1.0-preview — the near-term target (ship ASAP; conformance-after) (2026-06-23)

The **1.0-preview (developer-preview)** is a deliberately-narrower milestone we ship **ASAP**,
ahead of the full service-usable 1.0. Its floor is exactly the developer-usable row: *build + run
Darwin-style programs against **Mach / dispatch / notify**, on a bootable image.* That is a
**narrower critical path** than full 1.0:

- **In the preview floor:** Mach IPC (substrate — proven, id-009/op-108), libdispatch (9-case core
  — id-006), libnotify/notifyd (bring-up — id-010), a bootable image.
- **Preview image provenance (Arranger decision 2026-06-23, op-111-driven, Coordinator-overridable):**
  the preview ships on the **proven base+overlay+pre-staged-kernel staging model** (op-104 boots a
  launchd-managed guest), NOT the release pipeline. op-111 found the `buildworld→installworld→
  make-memstick` path has *never* completed for rmxOS (id-014 + likely deeper breakage), so holding
  the preview to a "real" reproducible build would drop an unexercised multi-fix path onto the
  critical path for no preview-level benefit. The reproducible release pipeline (**id-012 Tier 0/1**,
  gated on id-014) is **li-006 hardening run in parallel, post-preview** — not a preview milestone.
  Cutting scope, not quality: the staging-model image is a real booting artifact, verified first-hand.
- **Core service set (Coordinator decision 2026-06-24):** the preview-quality bar names FOUR
  non-optional core services — **{launchd, libnotify, asl, libxpc}** — riding the **{libdispatch,
  mach-ipc}** substrate. nvlist serialization is **LOCKED** (ravynos-mpack rejected; the design fork
  is CLOSED). So asl and libxpc are no longer "deferred to full 1.0" wholesale — they are core,
  brought to preview quality **depth-first** (notify → asl → libxpc/launchd) per the depth-first
  directive.
- **CALIBRATION CLOSED — EXPANDED GATE (Coordinator decision 2026-06-25):** the 1.0-preview ship gate
  **expands to all four core services truly-green + launchd driving them**. The narrow
  Mach/dispatch/notify floor is NOT a separate ship point — it is a waypoint inside the expanded gate.
  **1.0-preview = {launchd, libnotify, asl, libxpc} all truly-green over the {libdispatch, mach-ipc}
  substrate, launchd hosting them, holding under integration soak.**
- **Stance — get-it-right over speed; aim stable-usable, not just "preview" (Coordinator 2026-06-25):**
  "preview" is a *public label*, NOT a license to ship thin. The quality target is **stable + usable**.
  Take the necessary steps to make each core service as solid as we can; do not rush. This *strengthens*
  (does not relax) the overclaim-strict / truly-green discipline.
- **North star — dogfooding / self-host the dev workflow (Coordinator 2026-06-25):** the motivating
  goal is that **we develop ON rmxOS, off the current FreeBSD 15 host** — the Coordinator and this dev
  platform should benefit from it directly. This raises the *quality bar* (solidity must be real enough
  to live on), and orients the work toward day-to-day usability. NOTE the boundary vs the "self-hosting
  / GPU = NOT 1.0" line below: full self-hosting (buildworld-on-rmxOS, GPU) remains the long arc; the
  preview intent here is "solid enough to dogfood day-to-day dev tasks on," a usability/quality north
  star, not a commitment that the preview gate includes a reproducible self-hosted build (still li-006,
  post-preview). Confirm if you intend dogfooding to be a hard preview *gate* vs a guiding target.
- **Still deferred past the preview:** the reproducible release-image pipeline (id-012, li-006).

**Tempo + scope stance:** speed comes from **cutting scope, not quality**. macOS semantic
conformance is a **long-term arc, not a preview milestone** — a divergence is *cataloged as a known
gap* (li-005, "doesn't block use-case X") in preference to closing it with a complex/risky
implementation. The evidence bar is unchanged: whatever the preview ships is truly-green /
overclaim-strict, and the Mach foundation stays solid. A cataloged gap is honestly labeled, never
paper-greened. The "can afford to be slow" quality arc continues *after* the preview.

> **Numbering migrated 2026-06-25 → milestone-grouped 4-digit `li-MNNN`** (4 digits read cleanly
> against 3-digit `op-NNN`/`id-NNN`). The 1.0-preview is **milestone 1**, indexed by
> **[l1i/li-1000.md](l1i/li-1000.md)** (the `li-M000` index lists constituents li-1001…li-1008;
> filenames are number-only `li-NNNN.md`). The flat `li-001…li-008` below are the legacy ids; li-1000
> carries the old→new mapping. The reproducible-build item (old li-006) moves to milestone 9
> (post-preview). See [terminology.md](terminology.md) §6 for the scheme.

## The milestone ladder (li-001…li-008)

The milestones are the L1i instructions `li-001`…`li-008` (li-007/li-008 added 2026-06-24). Each **retires** when its
**truly-green** criterion holds (so "finished" can't mean paper-green). Each entry records: whether
it is a **runtime** test, its retirement criterion, and the IDQ item / ROB entry that carries it.

### li-001 — mach-ipc invariants green under load  *(runtime)*
Promote the op-099 fbt probe library from *tracers* to *assertions*: `mach_msg` send/receive
balanced, `ipc_port` alloc/dealloc balanced, no stuck enqueue, dead-name/no-senders delivered.
- truly-green: invariants hold over a sustained soak, asserted by DTrace predicates (the probe
  *is* the test), not exit-code 0.
- carries: op-099 (RETIRED — library exists) → invariant-oracle op (pending, see IDQ).

### li-002 — each layer working AND conformance-matched to macOS  *(runtime + one design sub-decision)*
Per layer: primitive/functional surface works *and* the same harness run on the macOS explorer
(truth) and the rmxOS explorer is semantics-diffed.
- libdispatch: primitive surface DONE (op-098); timer USDT enabled (op-101). Next: breadth +
  conformance + soak — the **runtime harness** (the first place we *define* truly-green; becomes
  the template for the layers above).
- notifyd / asl: next rung (no USDT → pid/fbt/cross-layer correlation).
- **libxpc — PROMOTED to its own milestone [li-007](l1i/li-007-libxpc-core-service.md)** (Coordinator
  2026-06-24, big enough for a dedicated instruction). No longer bundled here as just "a layer." The
  serialization fork is DECIDED: **nvlist locked** (ravynos-mpack rejected). See li-007 for the full
  two-plane analysis + get-it-right plan.
- truly-green: conformance diff vs a *current* macOS run, not exit-code-green standing in for
  behavior-matched.

### li-003 — launchd lifecycle driving real services  *(runtime)*
The load→start→observe→restart→remove→reload spine (closed at D23 on fixtures) driving *actual*
daemons (notifyd/asl + own), not test fixtures.
- truly-green: real services transition through the full lifecycle and survive restart/reload.
- **note:** this is the lifecycle sub-aspect of the broader launchd core-service milestone
  **[li-008](l1i/li-008-launchd-core-service.md)** (Coordinator 2026-06-24 elevation).

### li-004 — integration soak  *(runtime — the most runtime of all)*
All layers together under sustained load (launchd → libxpc → libdispatch → mach-ipc) with the
li-001 invariants watching for leaks/hangs/races over hours.
- truly-green: hours-long soak, zero invariant violations, no leak/hang — not a 5-minute run.

### li-005 — known gaps cataloged, not hidden  *(NOT runtime — adjudication/bookkeeping)*
1.0 ships *with* an IDQ (id-001 kevent64, id-002 QoS-attr, id-004 non-NORMAL-QoS timers,
id-005 semaphore poll, **id-023 launchd no self-scan of `/etc/launchd.d/` (rmxOS uses a generic boot-load
bridge; macOS-faithful self-scan is a li-008 get-it-right target — op-134 census)**, **id-021 libxpc out-of-preview gaps — Class-D modern `xpc_session_*`/
`xpc_listener_*`/`rich_error` generation + the `xpc_activity_*` scheduler subsystem + `xpc_shmem_*`
large-payload path (op-135 census; the C-side lifecycle Class-B/C items stay IN preview, these don't)**,
…), each scoped "doesn't block use-case X."
- truly-green: every known gap has an IDQ id + a non-blocking justification.

### li-006 — reproducible build / stage / boot  *(infrastructure — boot is runtime-ish)*
The donor-import → build → stage → guest-boot path is a button, not a ritual.
- truly-green: a clean checkout builds + boots the guest reproducibly by someone other than us.
- **status (2026-06-23, op-111): UNSUBSTANTIATED — further from done than the spine implied.** No
  clean `buildworld`+`buildkernel` has ever completed for rmxOS; the overlay has only been built
  piecemeal (modules + targeted userland via `stage-userland.sh`). The **test guests boot via a
  distinct model** — base FreeBSD image + overlay + a *pre-staged* kernel (`loader.conf
  kernel="MACHDEBUG"`), NOT the `buildworld→installworld→make-memstick` release path. So the
  release pipeline (id-012) is unexercised end-to-end; id-014/op-113 is its first blocker, with
  likely more breakage behind it. **This sits on the 1.0-preview critical path** (the preview floor
  includes a bootable image) — flagged to the Coordinator as a newly-surfaced risk.

### li-007 — libxpc as a core preview service  *(runtime + conformance)* → dedicated file
The C-side IPC service fabric (Mach-native transport + **nvlist serialization, LOCKED**). Promoted out of
the li-002 layer-bundle because it is big enough for its own milestone. Reply works; cancel/error/lifecycle
to fill (shares the MACH_RECV dispatch sub-fix with notifyd).
- truly-green: nvlist round-trip + Mach-transport send/reply/**cancel/error** match macOS behavior;
  pinned blob runs UNMODIFIED on both explorers; holds under li-004 soak.
- full instruction: **[l1i/li-007-libxpc-core-service.md](l1i/li-007-libxpc-core-service.md)**; carries id-021.

### li-008 — launchd as a core preview service  *(runtime)* → dedicated file
The service host: boots, hosts, supervises the core daemons; bootstrap anchor. Broader than the li-003
lifecycle-spine slice. **Two-plane:** control (launchctl→launchd) = liblaunch/Mach (works, diverges from
macOS XPC); service (`xpc_domain` hosting) = libxpc/nvlist = the open work.
- truly-green: launchd auto-starts + hosts real daemons (notifyd/asld/own), full li-003 spine against real
  services, xpc_domain plane live over nvlist, holds under li-004 soak.
- full instruction: **[l1i/li-008-launchd-core-service.md](l1i/li-008-launchd-core-service.md)**; carries
  li-003 spine + id-016 + op-134.

## Runtime vs not — at a glance

- **Runtime, real-world tests:** li-001, li-003, li-004, and the implementation/conformance half of
  li-002.
- **Not runtime:** li-005 (cataloging), li-006 (build pipeline; boot is runtime-ish). (The libxpc
  serialization decision is no longer pending — nvlist is locked as of 2026-06-24.)

## Critical path & the long pole

```
mach-ipc invariants (li-001) ──┐
libdispatch (li-002, basics done)─┼─► integration soak (li-004) ─► usable 1.0
notifyd/asl (li-002, next)      ──┤
libxpc (li-007, nvlist locked)  ──┘  ← LONG POLE (impl; serialization fork CLOSED 2026-06-24)
launchd core service (li-008) ──┘    ← service host; li-003 spine is its lifecycle sub-aspect
```
The DTrace instrumentation work is the *instrument* that lets us run li-001 and li-004 credibly — it
is necessary tooling, not the finish line. The finish line is the soak (li-004) retiring + libxpc
(li-002) resolved.

## Near-term move (the template)

Stand up the **libdispatch runtime conformance + soak harness**: functional matrix breadth
(async/sync/apply/once/barrier/group/semaphore/source-timer/source-MACH_RECV/data/io, block +
`_f`), run on both explorers and diffed vs macOS-as-truth, with op-099/op-101 probes promoted to
invariant oracles. This single piece exercises li-001 + li-002 + seeds li-004, and **defines
truly-green concretely** before we spend that pattern on the harder layers. Tracked as an IDQ
item (see [idq/id-000.md](idq/id-000.md)).

## Explicitly NOT 1.0

- kernel kevent64 substrate (id-001) — userland shim is deliberately lossy; real
  `kevent_qos`/workloops are the future substrate (Coordinator A-vs-B strategy decision).
- memory_object / GPU integration — the 5-year center.
- non-NORMAL-QoS timers (id-004), full QoS-attr Darwin parity (id-002), semaphore absolute-
  deadline (id-005) — hardening items.
