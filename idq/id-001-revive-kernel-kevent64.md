# id-001 — Revive kernel `kevent64` (NextBSD #370), retire the userland shim

- id: id-001
- state: WAITING (not fetched into the IDQ/ROB; pre-issue) — waits on the two
  Coordinator decisions below (strategy gate A-vs-B; placement). Recommended fetch
  *after* op-091 closes. See index: `id-000.md`.
- raised: 2026-06-22 (Coordinator: "it's part of NextBSD, we will revive that")
- lane (when promoted): evidence-lane, kernel-side (`freebsd-src` rmx worktree)
- relation to in-flight work: independent of the *pthread-attr* QoS thread (op-090V → op-091
  QoS-symbol leg). BUT op-091 (retired mismatch-found, 2026-06-22) reclassifies this from a
  foundation milestone to a **parity blocker** for `dispatch_mach_recv_source`. First-hand
  finding: the dispatch_source MACH_RECV firing gap (`handler_fired_and_serviced: false`,
  `mach_msg_receive_in_handler: KERN_FAILURE` on rx) roots in **kernel
  `EVFILT_MACHPORT = { &null_filtops }`** (`sys/kern/kern_event.c:391`; no `filt_machport`
  anywhere in `sys/`). libdispatch already uses `struct kevent64_s` internally throughout
  `source.c`, so the kevent64 substrate + a real Mach-port filter underneath it is what the
  dispatch layer is waiting on. See id-003 (the EVFILT_MACHPORT filter — distinct finding,
  candidate to fold here).

## Why this exists (the finding)

Asked whether our NextBSD-based code implements the macOS `kevent64` / `kevent_qos`
extensions. First-hand source check of both trees:

**`kevent64`**
- **NextBSD donor** carries a *real kernel* implementation:
  - syscall #370 — `nx/NextBSD/sys/kern/syscalls.master:676`
  - `struct kevent64_s` — `nx/NextBSD/sys/sys/event.h:81`
    = `uint64 ident / int16 filter / uint16 flags / uint32 fflags / int64 data /
       uint64 udata / uint64 ext[2]` — **matches macOS `kevent64_s` exactly** (wide
       udata/data, ext[2]).
  - **Crucially**: the donor made `kevent64_s` the *canonical internal kqueue struct*,
    not just an add-on syscall. In `nx/NextBSD/sys/kern/kern_event.c`:
    - `kqueue_register(struct kevent64_s *)` (1313), `knote.kn_kevent` is `kevent64_s`,
      `filt_usertouch`/`f_touch` take `kevent64_s` (769, 194, 1519).
    - Two ABI front-ends over one core: `kevent` (#363, native struct) +
      `kevent64` (#370, wide struct), each with its own `kevent{,64}_copyin/copyout`
      translating to/from the internal `kevent64_s`, sharing `kern_kevent64()`
      (890–1069).
- **Our alpha/rmxOS tree did NOT adopt it.** `wip-rmxos@alpha sys/kern/syscalls.master`
  has only `kevent` / `freebsd11_kevent` — no #370. Instead a **userland compat shim**:
  - `wip-rmxos/lib/libdispatch/src/freebsd_kevent64.c` (+ `freebsd_compat.h:52,74`)
  - functions named `phase07_*` → Phase-0.7-era libdispatch plumbing.
  - **Deliberately lossy**: `flags != 0 → ENOTSUP` (no `KEVENT_FLAG_*` semantics —
    immediate / dispatch / workloop / qos); only `ext[0]`/`ext[1]` preserved, `ext[2..3]`
    zeroed.

**`kevent_qos`** — **not implemented anywhere** (no syscall, no shim, no
`struct kevent_qos_s`) in either donor or alpha. `\bkevent_qos\b` matches nothing in
either source tree (only stray hits inside `contrib/llvm-project`). Same for `kevent_id`
(the macOS dispatch-workloop variant) — absent. These are a *later* layer; kevent64 is
their prerequisite.

## Scope (when promoted to an op-chain)

**In:**
- kernel syscall #370 + the internal-struct decision (below)
- libc symbol/header (`kevent64` in libc `Symbol.map` + public header)
- retire the userland shim `lib/libdispatch/src/freebsd_kevent64.c`
- Explorer macOS-parity vectors (mx-a64z `kevent64`)

**Out (explicitly — do not let creep in):**
- `kevent_qos` (ext[4] + xflags) and `kevent_id`/workloops. Neither exists in donor or
  alpha today; both are a later layer for which kevent64 is the prerequisite.

## The design fork to decide (the real question)

FreeBSD-15's native kqueue has evolved past the donor's base, so a straight donor port
will conflict. Two strategies:

- **(A) Donor-faithful** — adopt `kevent64_s` as the canonical internal struct (donor's
  design). Most Darwin-faithful (wide udata/data/ext native all the way down — the
  substrate for future `kevent_qos`/`KEVENT_FLAG_*`). **But** high blast radius: touches
  every filter's `f_touch`/knote consumer and collides hardest with FreeBSD-15 kqueue
  evolution (a rebase/merge problem of the same family as the broader Mach rebase).
- **(B) Additive front-end** — keep FreeBSD-15's native internal `struct kevent`; add
  `kevent64` (#370) as a kernel-boundary translating syscall (a real-syscall version of
  today's shim). Low blast radius, preserves FreeBSD kqueue improvements. Cost: internal
  representation not natively widened → `ext[2..3]`/wide-udata fidelity is a translation
  layer, not native; defers the "QoS all the way down" payoff.

**Arranger lean:** entry point should be an **Explorer least-intrusive-strategy probe**
(per `donor > XNU-ref > local`): diff donor `kern_event.c` vs FreeBSD-15's, quantify the
(A) blast radius, recommend A-vs-B with evidence — before any Implementer kernel work.
Keeps us from committing to a kqueue-core refactor blind.

## Proposed pipeline (when promoted)

Explorer strategy probe (A-vs-B, evidence-backed) → Implementer kernel port → Validators
(correctness) → Gatekeeper (macOS-parity guard) → retire shim.

## Open decisions (Coordinator-held, before promotion to op)

1. **Strategy gate** — Explorer A-vs-B probe as entry point, or donor-faithful (A) already
   chosen?
2. **Placement** — relative to (a) finishing the dispatch-solidity thread (op-091 + its
   Gatekeeper close) and (b) the Swift integration track. Arranger recommendation: queue
   *after* op-091 closes, as its own foundation milestone, ahead of Lane B Swift
   concurrency (dispatch-source QoS semantics ultimately want real kevent64 underneath).
