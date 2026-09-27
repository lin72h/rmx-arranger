---
id: op-199
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-199 — Implementer: implement `launchctl unload` (currently absent → rc=64) → first li-008 launchd fill off the op-195 calibration

op-199 | role: **Implementer** (cost-30) | EXU: **wip-gpt** | state: **[Done — unload-live, Arranger source+runtime verified first-hand @ 647a26e6aaa5]** (2026-06-29). cmd_unload registered in the command table (launchctl.c) next to load/remove; composes a refactored-shared `read_job_file` (load's plist/JSON parse) + `launchd_job_command` issuing LAUNCH_KEY_STOPJOB then LAUNCH_KEY_REMOVEJOB over launch_msg — pure liblaunch control plane, NO libxpc servicing pulled in (correctly tranched). Faithful to macOS unload(plist)=stop+unregister; EX_USAGE only on bad args. Runtime DARK→LIVE proven on a booted image (serial sha 86612dc8…, matches report): OP199_LIST_BEFORE label=com.apple.notifyd → OP199_UNLOAD rc=0 → OP199_LIST_AFTER label_absent=com.apple.notifyd + OP199_NOTIFYD_STOPPED. Honest base-record (real pre-change HEAD 501a1ef, not the stale brief d4a9946). li-008 ledger: unload moves DARK→LIVE (was 1 of 4 DARK). | parent id: id-016 (launchd bootstrap) | L1i: li-008 | cost: 30 | authored 2026-06-29 (Arranger seat, model Opus 4)

## WHY (one line)

op-195 calibrated `launchctl unload` as DARK (rc=64): the launchctl command table (launchctl.c:92-93) ships `load` + `remove` but has NO `unload` entry, so `unload` falls through to the usage error (EX_USAGE). It's a standing launchctl verb the full-NextBSD-launchd commitment requires. unload is launchd-INTERNAL (does not ride libxpc connection servicing) → it's fillable NOW, independent of the op-185 libxpc soak.

## SCOPE / SUBJECT (EDITABLE — rmxOS overlay)

- `bin/launchctl/launchctl.c` @ HEAD `d4a9946` (record the HEAD you build). Command table ~launchctl.c:92-93 (`{ "load", cmd_load, ... }`, `{ "remove", cmd_remove, ... }`). Existing `cmd_load` (launchctl.c:862) + `cmd_remove` (the unregister verb) are the two halves to compose.
- macOS-27 truth: `launchctl unload <plist>` = the inverse of `load` — it reads the plist(s), derives the job Label(s), and stops+unregisters those jobs (legacy domain). Semantically unload(plist) ≈ remove(label-from-plist). Match that contract (launchd_plist_macos_fidelity).

## DELIVERABLES

**D1 — implement `cmd_unload`** and register it in the command table next to `load`/`remove`. It must: parse the plist arg(s) (reuse cmd_load's plist→launch_data path), extract the job Label, and stop+unregister that job (reuse the cmd_remove mechanism against the derived Label) — NOT error out. Return rc=0 on success; faithful usage/err handling mirroring cmd_load (EX_USAGE only on genuinely bad args). → `OP199_CMD_UNLOAD`

**D2 — prove it green on a booted image** (this is the runtime DARK op-195 found, so a compile is not enough): load a job (e.g. com.apple.notifyd via launchctl load+start), then `launchctl unload <plist>` → the daemon STOPS and disappears from `launchctl list`, rc=0 — first-hand serial evidence. Mirror op-195's calibration method (golden image, launchctl load/start/list). Confirm the op-195 DARK is now LIVE. → `OP199_UNLOAD_LIVE`

**VERDICT:** `unload-live` (cmd_unload implemented + a loaded daemon stops via unload on a booted image, rc=0, first-hand) | `walled` (unload needs more than load+remove compose — report the actual blocker). → `OP199_VERDICT` / `OP199_TERMINAL`

## BOUNDARIES
- launchd-INTERNAL fill — must NOT pull in libxpc connection servicing (if it does, it's mis-tranched → report; but unload is the load/remove inverse, it should not).
- Compose the EXISTING cmd_load + cmd_remove halves; do NOT re-architect the launchctl dispatch or the liblaunch job-removal path. Faithful to the macOS unload(plist)→stop+unregister contract; do not invent new semantics.
- Userland overlay only (`bin/launchctl`); no FB15 build-infra edits (userland_port_no_buildinfra_changes). Stage in wip-gpt owned dir (agent_host_isolation).
- Verify first-hand on a booted image (the daemon actually gone from launchctl list) — a rc=0 in a log is a claim (background_exit_code_hygiene; op-195 found this exact verb DARK at runtime despite the code shipping).

## MARKERS
```
OP199_CMD_UNLOAD     # cmd_unload implemented + registered in the command table; composes load's plist-parse + remove's unregister
OP199_UNLOAD_LIVE    # on a booted image: load a daemon, unload its plist → daemon stops + gone from launchctl list, rc=0 (first-hand)
OP199_VERDICT        # unload-live | walled
OP199_TERMINAL
```

## RELATIONS
- UPSTREAM: op-195 [Retired] (li-008 calibration; unload classed DARK rc=64, "use remove instead" — this fills it; sequencing tranche 2a "small, independent").
- DOWNSTREAM: li-008 progress toward full-NextBSD-launchd-green. The OTHER li-008 DARK items are HELD: **xpc_domain service plane** (large, rides libxpc servicing → gated AFTER op-185 soak; flag-set points core.c:7064/:10375 are dormant because no XPC service job triggers domain creation) and **bootout-domain/spawnattr** (catalog-only, lowest priority). Do NOT scope those here.
- PEER: op-197 (libxpc pure-userland accessor fill) — same "small independent fill" class on the wip-gpt seat, different service (li-007); serialize on the seat.
- feedback: no_conflate_gating_with_readiness (op-195 proved verbs DARK at runtime despite shipping → prove LIVE on a booted image, not compile), launchd_plist_macos_fidelity (unload = stop+unregister inverse of load), workload_class_needs_source_read (compose the real load/remove halves), userland_port_no_buildinfra_changes, background_exit_code_hygiene, agent_host_isolation, build_is_implementer. project: launchd_no_autoscan (the load/unload pair is the explicit-load mechanism, not a dir scan).
```
