# id-003 — Kernel `EVFILT_MACHPORT` filter (`filt_machport`): wire the Mach-port kqueue filter

- id: id-003
- state: **DROPPED (premise false) 2026-06-22 — superseded by op-098.** Never needed promotion:
  the "no kernel `filt_machport`" premise was a scoping error. Kept for history; see below.
- raised: 2026-06-22 (first-hand, during op-091 adjudication of the op-082 field-level sweep)
- lane (when promoted): evidence-lane, kernel-side (`freebsd-src` rmx worktree) + libdispatch
- relation to in-flight work: this is the kernel root cause of op-091's
  `dispatch_mach_recv_source` mismatch. Closing it (plus a re-run pass) is a precondition to
  closing the **op-082 field-level loop**.

## DROP rationale (op-098, first-hand verified by Fable)

The founding premise — *"No `filt_machport` / `machport_filtops` exists anywhere in `sys/`"* —
is **false**. It came from an op-091 grep scoped to `sys/kern/` only, which missed the Mach
compat module. First-hand at the current tree:
- `sys/compat/mach/ipc/ipc_pset.c:504` — real `struct filterops machport_filtops`
  (`f_attach=filt_machportattach`, `f_detach=filt_machportdetach`, `f_event=filt_machport`).
- `sys/compat/mach/mach_module.c:270` — `kqueue_add_filteropts(EVFILT_MACHPORT, &machport_filtops)`
  registers the real filter at module load. `kern_event.c:391`'s `null_filtops` is only the
  **static default**; `mach.ko` overrides it at boot.
- op-098 runtime DTrace (genuine round-trip probe) traced the **standard kqueue path**:
  `mach_msg_send → filt_machportattach → filt_machport×3 → dmrs_handler → mach_msg_receive →
  filt_machportdetach` (filt_machport entries=5, handler=1). Neither (a) non-kqueue drain nor
  (b) shallow probe — the ordinary EVFILT_MACHPORT filter works end-to-end.

**Process note (own-error):** the op-097 adjudication REJECTED the close-claim on an *incomplete*
first-hand read (static `kern_event.c` table only, never checked dynamic module registration).
That rejection was wrong. Lesson carried forward: a static `null_filtops` in `kern_event.c` is
NOT proof of absence — Mach filters are registered dynamically by `mach.ko` via
`kqueue_add_filteropts`. Always check module-load registration before declaring a kernel
filter/handler missing on this base.

## ORIGINAL FRAMING BELOW IS SUPERSEDED — retained for history only

> ⚠️ The premise in the next section ("grep returns nothing") was a scoping error. See DROP
> rationale above.

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

## The GREEN paradox (op-097 → op-098 sub-question)

op-097's probe shows `dispatch_mach_recv_source` GREEN while the kernel filter is provably
`null_filtops`. Both cannot be load-bearing at once, so one of two things is true — op-098
must disambiguate first-hand before id-003 can be re-scoped or closed:

- **(a) non-kqueue delivery path.** The message is serviced by the classic manager thread
  draining the port/portset directly via `mach_msg` (`_dispatch_mgr_thread` machport drain),
  so the EVFILT_MACHPORT kevent registration is effectively dead weight and the probe never
  depends on `filt_machport`. → id-003 narrows to "the kernel filter is unused, not missing":
  decide between removing/conditioning the dead registration vs implementing the real filter
  for strict Darwin parity.
- **(b) shallow probe.** The probe constructs/cancels the source (and maybe a notifyd/TWQ
  bypass leg) without round-tripping a real Mach message *through the kqueue filter*, so it
  passes without exercising the gap at all. → id-003 is unchanged in substance; the probe
  needs hardening before any MACH_RECV parity claim stands.

Disambiguation method (op-098): DTrace-first — correlate `fbt::filt_machport*` (expected:
never entered, since null_filtops), the manager-thread `mach_msg`/portset drain path, and the
userland `dispatch:::` USDT, while an actual message is sent to the watched port. Whichever
path the message actually traverses settles (a) vs (b).

## Why it matters / why now

- op-081-R's MACH_RECV fix is validated at the **notifyd/TWQ** path (block-078 smoke) — it
  bypasses kqueue. The dispatch_source **API** path has no kernel filter under it, so the
  public `dispatch_source` MACH_RECV contract is unmet. This is the load-bearing gap of the
  op-082 sweep.
- macOS implements `filt_machport` (kqueue Mach-port filter) as the substrate for
  GCD's MACH_RECV sources. Darwin-parity requires the real filter, not the stub.

## Relation to id-001 (the kevent64 revival)

Same kernel-kqueue-Mach territory, and entangled:
- libdispatch's internal kqueue struct is already `kevent64_s` (verified in `source.c`), so the
  MACH_RECV path and the kevent64 width question share a substrate.
- **But distinct**: `filt_machport` is the *filter behavior* (deliver on Mach-message arrival);
  kevent64 is the *struct/ABI width*. A real `filt_machport` is needed regardless of which
  id-001 strategy (A donor-faithful vs B additive) is chosen.
- **Open placement decision (Coordinator-held)**: keep id-003 standalone (filter first, ABI
  later) or fold into id-001 as one kernel-kqueue-Mach foundation op-chain. The donor
  (`nx/NextBSD`) likely carries a `filt_machport` alongside its kevent64 work — an Explorer
  donor-vs-FreeBSD-15 probe (the same one id-001 proposes) should quantify both together.

## Scope (when promoted)

**In:** implement `filt_machport` / `machport_filtops` in `sys/kern` (attach/detach/event on a
Mach port or portset), register it in the kqueue filter table at `~EVFILT_MACHPORT`; Explorer
macOS-parity vector + donor reference; re-run op-091's `dispatch_mach_recv_source` to a pass.

**Out:** the dispatch_after timer gap (libdispatch/shim-level — separate op, EVFILT_TIMER
already real); `kevent_qos`/`kevent_id` (id-001's explicit out).

## Proposed pipeline (when promoted)

Explorer probe (donor `filt_machport` vs FreeBSD-15 kqueue; quantify with id-001's A-vs-B
probe if folded) → Implementer kernel filter → Validators (correctness) → re-run op-091 rx
vector → Gatekeeper (macOS-parity, closes op-082 field-level loop).
