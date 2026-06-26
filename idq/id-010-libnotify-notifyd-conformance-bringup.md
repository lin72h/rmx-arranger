# id-010 — libnotify + notifyd: conformance bring-up (li-002 next rung, li-003 real-service)

- id: id-010
- state: **3 OF 4 LEGS GREEN — LEG 4 (hours-scale soak) FAILED the no-hang bar (op-123 leg-4, 2026-06-25,
  Arranger-verified first-hand). Notify NOT truly-green.** Leg 4 ran clean+balanced for ~63 min
  (port alloc==destroy every sample, no FAILs) then HARD-HUNG at ~t=64m and stayed frozen ~48 min
  through t=112m (bhyve 0.0% CPU / IC blocked-idle = deadlock-on-wait, not spin, not leak). The leak
  bars HELD; the no-hang bar was VIOLATED. Kernel Mach IPC deadlock split out to **[id-025](id-025-
  kernel-mach-ipc-deadlock-notifyd-soak.md)** (carrier op-140 Explorer repro-accelerate → Implementer
  kernel-debugger). NOTE: the leg-4 report's "~99m active / hang 99-100m / frozen 8m" framing is wrong
  per the slope log (sha256=88ab17f7…) — actual onset ~t=64m, ~35 min earlier. Legs 1-3 remain green:
  Leg 1 (lifecycle) GREEN at `43d505a`; Leg 2 (traced matrix) GREEN at `b74ddff`; Leg 3 (conformance
  MATCH 10/10) GREEN.
- prior-state: **LEGS 1+2+3 GREEN, Arranger-verified first-hand (op-123, 2026-06-24).** Leg 1 (lifecycle) GREEN at `43d505a`: marker file shows PREFLIGHT `bs_probe=present`
  → LOAD/START/OBSERVE/RESTART/REMOVE/RELOAD all `status=0`, `lifecycle_rc=0`; all 3 round-trips
  (OBSERVE/RESTART/RELOAD) hit `port=19` → `notify_check rc=0 check=1`; RESTART `reason=launchd_auto_restart`
  (KeepAlive, macOS-faithful). Both flagged closures met first-hand (bs_probe hard-precondition; post-restart
  round-trip real). Leg 2 (traced matrix) GREEN at `b74ddff`: 10/10 PASS `op110_matrix_fails=0` + fbt trace
  `ipc_port_dnrequest (dead-name arm)` → `ipc_port_dnnotify (FIRE)`, notify.d unmodified. Leg 3 (conformance
  MATCH 10/10) GREEN (prior). **op-131 DONE/RETIRED (`56664fe`, Arranger-verified first-hand):** hardened
  op-129's CANONICAL harnesses (`notifyd-lifecycle-harness.sh` + `notifyd-soak-driver.sh`) on all 3 holes —
  (1) round-trips now route through `/root/run-as-launchd-job.sh` (launchd child → bootstrap_port=19), no
  bare shell bs_probe (port=0) survives; (2) harness runs from the SHELL (header-documented + enforced) so a
  restart-rung notifyd kill can't cascade-kill the driver; (3) `grep [n]otifyd` self-match → `pgrep -x notifyd`
  (6 sites). DTrace oracle `notifyd-soak-oracle.d` correctly untouched (pure fbt). **Leg 4 (hours-scale
  invariant-oracle soak) now DISPATCHABLE — last leg of notify truly-green; awaits Gatekeeper dispatch.**
  (History below from the leg-1/2/3 bring-up.)
  - **op-129 DONE (`6c8e0ca`, 3 files under `rmx-explorer/scripts/notifyd/`, Arranger-verified first-hand):**
    `notifyd-lifecycle-harness.sh` (6 rungs load→start→observe→restart→remove→reload, round-trip at
    observe+reload), `notifyd-soak-oracle.d` (fbt invariant oracle: mach_msg s/r, ipc_port alloc/destroy
    + port-slope tick-60s, ipc_kmsg, ipc_mqueue, dead-name req/fire), `notifyd-soak-driver.sh`
    (register/post/check/cancel churn, `SOAK_DURATION` env). Structurally sound — absorbed every prior soak
    lesson (global-ints not aggregations, self-tick, no `-D` macros, `date +%s`, port-slope for slow leaks,
    fbt-only). **Good authoring — DONE.**
  - **op-123 checkpoint (2026-06-24): 2 of 4 legs green.** Leg 3 (conformance MATCH) Arranger-verified
    first-hand. Leg 2 (traced matrix) reported GREEN — matrix 10/10 under notify.d + trace of dead-name
    arm (`ipc_port_dnrequest`) → `ipc_port_dnnotify` FIRE, `LEG2_TRACE_LINES=9` (non-zero, fail-loud).
    **NOT yet Arranger-verifiable** — the leg-2 trace artifact is not pushed to rmx-gatekeeper (latest there
    is `80dd4d4`/op-108; the notify-trace runs are the 2026-06-12 n2 work). Standing requirement: push the
    leg-2 trace capture for first-hand verification before it counts toward retirement.
  - **Leg order (Gatekeeper-proposed, Arranger-approved): 2 (done) → 1 → 4.** Leg 1 (~minutes) shares all
    of leg 4's preconditions, so it runs as a cheap precondition-smoke before the hours-scale soak.
    Precondition union to verify present on whatever base wins (op-127 image, or op-108 base if op-127
    lacks dtrace modules like op-110 did): `{dtrace.ko + providers, /root/bs_probe, launchd-child notifyd
    plist, op-129 harnesses}` — a base swap that drops bs_probe re-opens the paper-green hole.
  - **op-123 closures (Gatekeeper must close before legs 1/4 truly-green — verification-grade, not
    re-authoring):**
    - *bs_probe-absent paper-green (all 3 files):* harness L67-68/L120 skip-PASS the round-trip; driver
      L44-48 degrades to null churn (just echoes); driver L55 prints `terminal status=0` unconditionally.
      → bs_probe presence is a HARD precondition (absent = setup FAIL); the terminal marker is a claim, not
      evidence (check `notifyd_soak_fails` + oracle deltas first-hand).
    - *leg 1:* make round-trip mandatory; add a round-trip AFTER the restart rung (currently only
      observe+reload verify the name-table); confirm the notifyd plist has KeepAlive (harness accepts
      manual_restart as pass — macOS-faithful is launchd auto-restart; note divergence if manual-only).
    - *leg 4:* oracle TRACES but does not ASSERT (final tick prints deltas then `exit(0)` unconditionally) —
      Gatekeeper owns + enforces the FIXED BAR (Explorer authored the series; bar is Gatekeeper's). Bar:
      port-slope FLATNESS (bounded delta, no monotonic growth) + kmsg/mqueue balance at quiescence +
      dead-name balance — NOT send/recv equality (notifyd has legit asymmetry). Sync oracle `tick-Ns` to
      `SOAK_DURATION` for the hours-scale run (committed `tick-120s` is the proof version; hours-scale =
      leg-4 truly-green, else oracle exits at 120s and the soak runs unwatched).
  op-123 verified leg-3 conformance-MATCH first-hand to the false-divergence bar: both sides ran
  `notify-harness.c @ 2da90e7` UNMODIFIED (header-verified), matrix payload **byte-identical** (10/10 PASS,
  `op110_matrix_fails=0` both sides); the 830B-vs-1097B size delta is header-metadata only (rmxOS carries
  kernel/libnotify/run provenance) — a real MATCH, not a trusted "10/10". **Leg 3 = 1 of 4.**
  - **Scoping correction (Arranger, first-hand 2026-06-24):** op-123 was mis-scoped as pure Gatekeeper
    validation assuming all 4 legs' artifacts existed — conformance-MATCH (op-110/112) is leg-3 only. First-
    hand repo search found: **leg-1 lifecycle MACHINERY exists** (`wip-gpt/scripts/launchd/verify-phase08-
    launchd-dispatch-lifecycle.exs` + `-launchctl-reload/-remove/-keepalive-restart/-runatload/-running-
    remove/-restart` — the D23 spine) but drives a **dispatch fixture job, NOT notifyd**; **leg-2 artifacts
    both exist** (matrix `notify-harness.c` + a notify.d probe) → a Gatekeeper *run*, not authoring;
    **leg-4 notify soak does NOT exist** (only the dispatch soak op-104/108).
  - **op-129 (Explorer, free) — author the missing notify artifacts:** (1) **adapt** the D23 launchd
    lifecycle suite to drive **real notifyd** (notifyd plist + load→start→observe→restart→remove→reload),
    accounting for name-table state across restart/reload; (2) author a **notify invariant-oracle soak**
    on the op-104/108 dispatch-soak template — invariants: name-table balance (register/cancel), Mach-port
    alloc/dealloc balance, msg send/recv balance under sustained post/register churn, no stuck enqueue;
    fbt/pid (no USDT on notifyd → pid/fbt + op-099 mach-ipc cross-layer anchor).
  - **op-123 (Gatekeeper) — resumes after op-129 for legs 1+4 + does leg 2 NOW:** validate the adapted
    lifecycle (leg 1) + run the authored soak as the fixed-bar regression (leg 4); meanwhile run the
    EXISTING matrix under the EXISTING notify.d probe to capture the fbt/pid-traced matrix (leg 2 — both
    artifacts already exist). Soak = Gatekeeper per the ownership rule (Explorer authors the oracle).
  - Coordinator depth-first directive unchanged: make notify + asl *solid* (all 4 criteria) before the
    libxpc long-pole (id-021 leg 2 held). Bootstrap hinge (id-016 (c)) is NOT a leg-1 precondition — a
    notifyd lifecycle is launchd OWNING notifyd (the launchd-child path op-127 proved works: port=19, full
    round-trip); the (c) gap only affects non-launchd-child shell processes.
  Legs 1-3 DONE: op-110 (rx-x64z) ran `notify-harness.c` (2da90e7,
  UNMODIFIED) as a launchd child of the nxplatform-probe session (bootstrap inherited), 10/10 PASS
  `op110_matrix_fails=0` (commit `8d398c6`, serial SHA `46bcd751…`); op-112 (mx-a64z) carried the
  macOS-truth half — same source UNMODIFIED against Apple's `notify(3)` on mm4/macOS-27, 10/10 PASS
  (commit `f88e6f8`, SHA256 `e7cef1f6…8124a732`). **Conformance diff = MATCH 10/10, zero semantic
  mismatch** — both `rmxos-actual.out` and `macos-truth.out` case lines byte-identical, **verified
  first-hand by the Arranger**. Apples-to-apples (identical harness source both sides). li-002
  notify-conformance leg (protocol axis) GREEN. **Bootstrap-ambient gap is id-016, a separate axis**
  — op-110 reached notifyd via the probe-child launch context, not ambient bootstrap. The **soak
  leg (4) is a separate future Gatekeeper op** (soak = Gatekeeper, per the soak ownership rule).
  First op on the **1.0-preview critical path** — developer-usable floor's notify leg now satisfied
  (notify *runs* + conforms).
- raised: 2026-06-23 (roadmap li-002 "notifyd/asl — next rung")
- roadmap parent: [roadmap.md](../roadmap.md) — **li-002** (layer working + conformance-matched
  to macOS) and a named **li-003** real service (launchd driving notifyd, not a fixture).
- relations: **id-006** (the harness template this copies); **id-009/op-107** (shares the
  mach-ipc substrate — the UAF fix benefits any port-churning layer, notifyd included);
  **li-003 / Phase 0.8 launchd** (notifyd is one of the real daemons the lifecycle spine drives).
- lane (when promoted): evidence-lane + parity-lane (dual-explorer conformance), userland;
  observation-only (no product source edits at first — bring-up + conformance before any fix).

## What exists in the tree (first-hand, 2026-06-23)

This is **not greenfield** — a classic-Apple libnotify + notifyd is already imported (Apple-
licensed):

- **client:** `lib/libnotify/{libnotify.c (1551 lines), notify_client.c, libnotify.h, notify.3,
  APPLE_LICENSE}`. Uses `mach_port_*` + `dispatch_*` first-hand — it rides exactly on the
  libdispatch + mach-ipc substrate (so it exercises the same `filt_machport`/MACH_RECV path the
  id-009 soak hammers).
- **daemon:** `usr.sbin/notifyd/{notifyd.c, notify_proc.c, notify_ipc.h, com.apple.notifyd.plist,
  notify.conf.MacOSX, notify.conf.iPhone, n2_markers.c/h, notifyd.8}`. Has a launchd plist
  (`com.apple.notifyd`) → it is a real launchd service, li-003-shaped. `n2_markers.*` is a
  NextBSD-added artifact (N2-concurrency markers from the rebase — not yet read first-hand;
  audit at fetch).

## Why this is a next rung (after libdispatch)

libnotify/notifyd is the **first real Darwin daemon** to put through the libdispatch harness
template — it has a client API surface (`notify_post`/`notify_register_*`/`notify_check`/
`notify_cancel`, name registration, coalescing, state/int64 values) *and* a launchd-managed
daemon, so it exercises li-002 (conformance) and li-003 (real-service lifecycle) at once. It is
the cheapest non-libdispatch layer because the substrate (Mach ports + dispatch sources) is
already proven; the new surface is the notify protocol + daemon state machine.

## Instrumentation note — no USDT (roadmap.md:44)

Unlike libdispatch (timer USDT live, op-101), notifyd has **no USDT probes**. Conformance/soak
observation must use **pid/fbt + cross-layer correlation** (notify client ↔ Mach IPC ↔ daemon),
reusing the op-099 mach-ipc fbt probe library as the cross-layer anchor. This is the first layer
where the harness leans on fbt rather than USDT — a template-extension this item proves out.

## Scope (when promoted) — copies the id-006 template

**In:**
1. **Bring-up:** notifyd loads + stays up under launchd on the rmxOS guest (li-003 lifecycle:
   load→start→observe→restart→remove→reload, the D23 spine driving an *actual* daemon).
2. **Functional matrix:** the notify client surface — post/register(check,signal,mach_port,
   file_descriptor,dispatch)/check/cancel, name coalescing, state + int64 values, multi-client
   broadcast. Block + `_f`/handler variants where they exist.
3. **Dual-explorer conformance:** same harness on mx-a64z (macOS truth) and rx-x64z (rmxOS),
   semantics-diffed via `macos-oracle.v1`. Move from "runs" to "behavior-matched-to-Darwin".
4. **Invariant oracle over soak:** notify name table balance (register/cancel), no leaked Mach
   ports, msg send/recv balance under sustained post/register churn — fbt assertions over an
   hours-scale run. Inherits the id-006 soak-leg definition.

**Out:** product source edits (observation-first; any defect found ladders to its own fix op);
asl (id-011, sibling); libxpc (the long-pole last task, not yet raised).

## Truly-green criterion (what "notifyd li-002 passed" must mean)

- notifyd loads + survives the full launchd lifecycle on the guest (li-003);
- functional matrix green + traced (fbt, not exit-code-only);
- conformance diff vs a *current* macOS notifyd shows no semantic mismatch (or each is laddered);
- the notify-table + Mach-port invariants hold over an hours-scale soak — zero leaks/violations.

## Open decisions (Coordinator-held, at fetch)
- fetch now (matrix + conformance legs, soak inherited later) or hold until id-006 fully retires?
- fetch order vs id-011 (asl) — siblings; notifyd is the simpler protocol, asl the higher-volume
  log path. Suggest notifyd first as the smaller template-extension proof.
- audit `n2_markers.*` first — is it instrumentation we can reuse, or rebase scaffolding to route
  around?
