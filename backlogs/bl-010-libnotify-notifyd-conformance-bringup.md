# bl-010 — libnotify + notifyd: conformance bring-up (Gate B next rung, Gate C real-service)

- id: bl-010
- state: **FETCHED → op-110** (Arranger-issued 2026-06-23, Coordinator-delegated "you decide").
  Preconditions met: bl-006 template retired (op-102/op-108), mach-ipc substrate proven (bl-009),
  notifyd source in tree. op-110 = Explorer bring-up + functional matrix + conformance diff (legs
  1-3); the **soak leg (4) is a separate future Gatekeeper op** (soak = Gatekeeper, per the soak
  ownership rule), gated on op-110 retiring. First op on the **1.0-preview critical path**.
- raised: 2026-06-23 (roadmap Gate B "notifyd/asl — next rung")
- roadmap parent: [roadmap.md](../roadmap.md) — **Gate B** (layer working + conformance-matched
  to macOS) and a named **Gate C** real service (launchd driving notifyd, not a fixture).
- relations: **bl-006** (the harness template this copies); **bl-009/op-107** (shares the
  mach-ipc substrate — the UAF fix benefits any port-churning layer, notifyd included);
  **Gate C / Phase 0.8 launchd** (notifyd is one of the real daemons the lifecycle spine drives).
- lane (when promoted): evidence-lane + parity-lane (dual-explorer conformance), userland;
  observation-only (no product source edits at first — bring-up + conformance before any fix).

## What exists in the tree (first-hand, 2026-06-23)

This is **not greenfield** — a classic-Apple libnotify + notifyd is already imported (Apple-
licensed):

- **client:** `lib/libnotify/{libnotify.c (1551 lines), notify_client.c, libnotify.h, notify.3,
  APPLE_LICENSE}`. Uses `mach_port_*` + `dispatch_*` first-hand — it rides exactly on the
  libdispatch + mach-ipc substrate (so it exercises the same `filt_machport`/MACH_RECV path the
  bl-009 soak hammers).
- **daemon:** `usr.sbin/notifyd/{notifyd.c, notify_proc.c, notify_ipc.h, com.apple.notifyd.plist,
  notify.conf.MacOSX, notify.conf.iPhone, n2_markers.c/h, notifyd.8}`. Has a launchd plist
  (`com.apple.notifyd`) → it is a real launchd service, Gate-C-shaped. `n2_markers.*` is a
  NextBSD-added artifact (N2-concurrency markers from the rebase — not yet read first-hand;
  audit at fetch).

## Why this is a next rung (after libdispatch)

libnotify/notifyd is the **first real Darwin daemon** to put through the libdispatch harness
template — it has a client API surface (`notify_post`/`notify_register_*`/`notify_check`/
`notify_cancel`, name registration, coalescing, state/int64 values) *and* a launchd-managed
daemon, so it exercises Gate B (conformance) and Gate C (real-service lifecycle) at once. It is
the cheapest non-libdispatch layer because the substrate (Mach ports + dispatch sources) is
already proven; the new surface is the notify protocol + daemon state machine.

## Instrumentation note — no USDT (roadmap.md:44)

Unlike libdispatch (timer USDT live, op-101), notifyd has **no USDT probes**. Conformance/soak
observation must use **pid/fbt + cross-layer correlation** (notify client ↔ Mach IPC ↔ daemon),
reusing the op-099 mach-ipc fbt probe library as the cross-layer anchor. This is the first layer
where the harness leans on fbt rather than USDT — a template-extension this item proves out.

## Scope (when promoted) — copies the bl-006 template

**In:**
1. **Bring-up:** notifyd loads + stays up under launchd on the rmxOS guest (Gate C lifecycle:
   load→start→observe→restart→remove→reload, the D23 spine driving an *actual* daemon).
2. **Functional matrix:** the notify client surface — post/register(check,signal,mach_port,
   file_descriptor,dispatch)/check/cancel, name coalescing, state + int64 values, multi-client
   broadcast. Block + `_f`/handler variants where they exist.
3. **Dual-explorer conformance:** same harness on mx-a64z (macOS truth) and rx-x64z (rmxOS),
   semantics-diffed via `macos-oracle.v1`. Move from "runs" to "behavior-matched-to-Darwin".
4. **Invariant oracle over soak:** notify name table balance (register/cancel), no leaked Mach
   ports, msg send/recv balance under sustained post/register churn — fbt assertions over an
   hours-scale run. Inherits the bl-006 soak-leg definition.

**Out:** product source edits (observation-first; any defect found ladders to its own fix op);
asl (bl-011, sibling); libxpc (the long-pole last task, not yet raised).

## Truly-green criterion (what "notifyd Gate B passed" must mean)

- notifyd loads + survives the full launchd lifecycle on the guest (Gate C);
- functional matrix green + traced (fbt, not exit-code-only);
- conformance diff vs a *current* macOS notifyd shows no semantic mismatch (or each is laddered);
- the notify-table + Mach-port invariants hold over an hours-scale soak — zero leaks/violations.

## Open decisions (Coordinator-held, at fetch)
- fetch now (matrix + conformance legs, soak inherited later) or hold until bl-006 fully retires?
- fetch order vs bl-011 (asl) — siblings; notifyd is the simpler protocol, asl the higher-volume
  log path. Suggest notifyd first as the smaller template-extension proof.
- audit `n2_markers.*` first — is it instrumentation we can reuse, or rebase scaffolding to route
  around?
