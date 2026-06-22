# bl-003 — Kernel `EVFILT_MACHPORT` filter (`filt_machport`): wire the Mach-port kqueue filter

- id: bl-003
- state: WAITING (not fetched) — a **parity blocker** for `dispatch_mach_recv_source`, surfaced
  by op-091. Waits on a Coordinator placement decision (standalone, or fold into bl-001).
- raised: 2026-06-22 (first-hand, during op-091 adjudication of the op-082 field-level sweep)
- lane (when promoted): evidence-lane, kernel-side (`freebsd-src` rmx worktree) + libdispatch
- relation to in-flight work: this is the kernel root cause of op-091's
  `dispatch_mach_recv_source` mismatch. Closing it (plus a re-run pass) is a precondition to
  closing the **op-082 field-level loop**.

## The finding (first-hand verified)

`DISPATCH_SOURCE_TYPE_MACH_RECV` does not fire on rmxOS at the dispatch_source API level:
- rx vector: `handler_fired_and_serviced: false` (true on mx), `mach_msg_receive_in_handler:
  KERN_FAILURE`.
- libdispatch is correct: it registers an `EVFILT_MACHPORT` kevent for the source
  (`_dispatch_kevent_machport_resume`, `_dispatch_kevent_mach_portset` in
  `lib/libdispatch/src/source.c`, all over `struct kevent64_s`).
- **Kernel root cause**: `sys/kern/kern_event.c:391` registers
  `[~EVFILT_MACHPORT] = { &null_filtops }` — a no-op stub. **No `filt_machport` /
  `machport_filtops` exists anywhere in `sys/`** (`grep` returns nothing). So a Mach message
  arriving on the watched port/portset never wakes the kqueue; the handler never runs.

Contrast (same table, `kern_event.c`): `EVFILT_TIMER = { &timer_filtops, 1 }` is a real,
active filter — which is why the *timer* substrate works and the dispatch_after gap (op-091's
second finding) is libdispatch/shim-level, **not** this kernel gap. Keep the two separate.

## Why it matters / why now

- op-081-R's MACH_RECV fix is validated at the **notifyd/TWQ** path (block-078 smoke) — it
  bypasses kqueue. The dispatch_source **API** path has no kernel filter under it, so the
  public `dispatch_source` MACH_RECV contract is unmet. This is the load-bearing gap of the
  op-082 sweep.
- macOS implements `filt_machport` (kqueue Mach-port filter) as the substrate for
  GCD's MACH_RECV sources. Darwin-parity requires the real filter, not the stub.

## Relation to bl-001 (the kevent64 revival)

Same kernel-kqueue-Mach territory, and entangled:
- libdispatch's internal kqueue struct is already `kevent64_s` (verified in `source.c`), so the
  MACH_RECV path and the kevent64 width question share a substrate.
- **But distinct**: `filt_machport` is the *filter behavior* (deliver on Mach-message arrival);
  kevent64 is the *struct/ABI width*. A real `filt_machport` is needed regardless of which
  bl-001 strategy (A donor-faithful vs B additive) is chosen.
- **Open placement decision (Coordinator-held)**: keep bl-003 standalone (filter first, ABI
  later) or fold into bl-001 as one kernel-kqueue-Mach foundation op-chain. The donor
  (`nx/NextBSD`) likely carries a `filt_machport` alongside its kevent64 work — an Explorer
  donor-vs-FreeBSD-15 probe (the same one bl-001 proposes) should quantify both together.

## Scope (when promoted)

**In:** implement `filt_machport` / `machport_filtops` in `sys/kern` (attach/detach/event on a
Mach port or portset), register it in the kqueue filter table at `~EVFILT_MACHPORT`; Explorer
macOS-parity vector + donor reference; re-run op-091's `dispatch_mach_recv_source` to a pass.

**Out:** the dispatch_after timer gap (libdispatch/shim-level — separate op, EVFILT_TIMER
already real); `kevent_qos`/`kevent_id` (bl-001's explicit out).

## Proposed pipeline (when promoted)

Explorer probe (donor `filt_machport` vs FreeBSD-15 kqueue; quantify with bl-001's A-vs-B
probe if folded) → Implementer kernel filter → Validators (correctness) → re-run op-091 rx
vector → Gatekeeper (macOS-parity, closes op-082 field-level loop).
