# op-195 — Explorer: launchd standing-exclusion RUNTIME calibration (live vs partial vs dark on our stack) → the live/dark ledger driving li-008 fill + xpc_domain sequencing

op-195 | role: **Explorer** (FREE) | EXU: **rx-x64z** (rmx-explorer / rx1) | state: **[Retired — calibration-complete; li-008 ledger 4 LIVE / 4 DARK pushed to main d4a9946, Arranger-verified first-hand]** (verified: xpc_domain DARK is correctly "present≠live" — flag-set points core.c:7064/:10375 exist but ride the xpc_service-checkin path no rmxOS job triggers, dormant not missing; launchctl unload DARK confirmed real — cmd table launchctl.c:92-93 has load+remove but NO unload entry → falls through to EX_USAGE rc=64; MachServices/Sockets/load/start/list/remove LIVE accepted). Decode: op-199 (unload fill, independent) authored; xpc_domain HELD behind op-185; bootout/spawnattr catalog-only. | parent id: id (li-008 IDQ — confirm/seed) | L1i: li-008 | cost: free | authored 2026-06-29 (Arranger seat, model Opus 4)

## WHY (one line)

launchd's lifecycle spine is GREEN (D14-D23), but the standing exclusions (xpc_domain service plane, MachServices, sockets, launchctl verbs, bootout) are the rest of the NextBSD surface the preview now commits to. The code is INHERITED + present (core.c) but its RUNTIME status on our FB15 Mach-compat stack is UNKNOWN (present ≠ live). Measure live-vs-dark ONCE so the fill program is scoped from evidence, and so xpc_domain is sequenced correctly (it rides the un-soaked libxpc plane).

## SCOPE / SUBJECT

- launchd source (READ to understand): `/Users/me/wip-mach/wip-gpt/wip-rmxos/sbin/launchd` + `bin/launchctl` @ `op-171-x86-64-v3-alpha` (record HEAD). Key entry points already located (Arranger 2026-06-29, take as given): `xpc_domain_load_services` core.c:10454, `xpc_domain_check_in` core.c:10502, `xpc_domain_get_service_name` core.c:10542 — REAL impls, not stubs; full domain machinery (system/per-user/per-session, singletons, xpc_service jobs, xpc_bootstrapper, xpc_event_* channels).
- RUNTIME target: a bootable image (op-149 preview image `vm/runs/op149-preview-uefi-v3.img`, or op-184 dtrace image `vm/runs/op184-soak-dtrace-v3.img` if probes need DTrace). This is a DISCOVERY calibration (Explorer's), NOT a fixed-bar regression soak (that stays Gatekeeper).

## STANDING EXCLUSIONS TO CALIBRATE (each: LIVE end-to-end / PARTIAL-wired / DARK)

1. **xpc_domain service plane (FLAGSHIP — the join with libxpc).** Does a real `xpc_service` job get spawned by launchd, check in via `xpc_domain_check_in` (core.c:10502), receive its bootstrap/exception/audit ports, and serve a request over the live nvlist plane? This is THE highest-value unknown across both services. If LIVE → solidify; if DARK → it's a large validate-and-fix riding the un-soaked libxpc plane → sequences after op-185.
2. **MachServices** (launchd advertising + bootstrap_look_up round-trip to a job-hosted service).
3. **Sockets** (launchd socket-activation: create, pass to job on demand).
4. **launchctl verbs** start / stop / list / unload (currently un-gated per Phase 0.8 ceilings) — wired or stubbed?
5. **bootout-domain** + spawnattr fidelity residuals (catalog, lower priority).

## DELIVERABLES

**D1 — per-feature runtime probe.** For each exclusion above, determine on a booted image: LIVE end-to-end / PARTIAL / DARK, with the evidence (the trace/log/marker that proves the branch fired and served, not merely that code exists — evaluated-decline discipline). Probe in the harness pillars (Elixir orchestration + Zig/ELF + DTrace `.d`; NO shell `.rc`/`.sh` harness; load `.d` individually).

**D2 — the live/dark ledger** under li-008: {feature → status → evidence → rides-libxpc? → est. fill size}. Flag which features RIDE libxpc connection servicing (→ gated behind op-185 soak) vs which are launchd-internal (fillable independently).

**D3 — sequencing recommendation** for the li-008 fill program: depth-first order, with the xpc_domain join explicitly sequenced after the libxpc soak. (Recommendation only — Arranger decodes into fill ops; do NOT author fills.)

**VERDICT:** `calibration-complete` (all 5 classed live/dark + ledger + sequencing) | `walled` (image won't boot / probe can't run — report it, do not improvise).

## BOUNDARIES
- Explorer DISCOVERY — probe + classify + recommend ONLY; author NO fix, edit NO product. Verify branch-fired (not just code-present) before calling a feature LIVE (verify_signature_divergence_claims).
- Harness = Elixir+Zig+`.d` only (dtrace_first_debugging); for any userspace-crash bar use sigexit/proc signal-clear on the PID, NOT an fbt:: userspace bar (fbt_traces_kernel_only).
- Stage strictly in rx-x64z's owned dir; consume images from the shared `vm/runs/` handoff (agent_host_isolation).

## MARKERS
```
OP195_XPC_DOMAIN      # flagship: real xpc_service spawn→check_in→ports→serve over nvlist — LIVE/PARTIAL/DARK + evidence
OP195_EXCLUSIONS      # MachServices/sockets/launchctl-verbs/bootout each classed live/dark with branch-fired evidence
OP195_LEDGER          # li-008 live/dark ledger emitted, rides-libxpc flagged
OP195_SEQUENCING      # depth-first fill order recommended; xpc_domain sequenced AFTER op-185 libxpc soak
OP195_VERDICT         # calibration-complete | walled
OP195_TERMINAL
```

## RELATIONS
- UPSTREAM: Phase 0.8 D14-D23 (lifecycle spine green); the Arranger source-locate of the xpc_domain entry points (2026-06-29).
- DOWNSTREAM: the li-008 fill ops (decode from this ledger); the xpc_domain join gated behind op-185 (libxpc soak).
- PEER: op-194 (libxpc-side census) — same measure-first step for li-007.
- feedback: no_conflate_gating_with_readiness (present≠live; measure first), depth_first_conformance, dtrace_first_debugging, fbt_traces_kernel_only, verify_signature_divergence_claims (branch-fired evidence), soak_is_gatekeeper (this is DISCOVERY calibration not regression soak), role_costs (free Explorer), agent_host_isolation.
```
