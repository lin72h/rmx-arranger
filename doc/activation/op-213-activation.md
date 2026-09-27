---
id: op-213
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-213 — Explorer: op-198 v5 reclaim PRE-FLIGHT SMOKE — confirm the op-204 fixed-aslmanager image boots + aslmanager-reclaim ARMS and FIRES once, so the Gatekeeper's scarce hours-scale soak slot runs one-pass (not a wasted night on a setup bug)

op-213 | role: **Explorer** (FREE) | EXU: **rmx-explorer** (rx1) | state: **[Done — `soak-cleared` (attempt-2 @ a823526, 3752123..a823526), Arranger-verified first-hand].** D1: booted aslmanager sha `301bfb1d` / NEEDED `libdispatch.so.5` (the dynamic op-204 fix, verified on disk last turn) → `aslmanager starting`→`finished` rc=0, reaches main, no pre-main core. D2: reclaim ARMS + FIRES — pre-aged 600KB `2026.06.28.asl` + 200KB `BB.2026.06.28.asl` = 819200B; `-size 500K` → all_max=512000; 819200 > 512000 → FIRED → both files removed (store→0). **TTL ruled out** (files 1-day-old vs `store_ttl 7`) → the removal IS the `all_max` SIZE trigger under test. Verdict `soak-cleared` ACCEPTED: op-198 v5 can run one-pass. **TWO CARRY-FORWARDS for op-198 v5 (not smoke blockers — riders the soak MUST add to be complete-once):** (1) **debug_log capture** — the briefed markers (`Data Store Size > all_max` / `Additional YMD Scan` / `remove`) went to SYSLOG not stderr (because asld-is-logger/op-210 is live — the debug flowed through the asl stack), so the smoke proved the OUTCOME not the PATH; the soak harness must route `aslmanager_debug` to a captured file. (2) **trim-vs-purge semantics** — size-reclaim removed the WHOLE store (→0), not trimmed to just-under-500K; the soak must characterize whether full-purge is intended (bounded-store vs sawtooth-purge-to-0). | parent id: id-011 (asl) + id-025 (reclaim regression) | L1i: li-1004 (asl) | cost: free | authored 2026-06-29 (Arranger seat, model Opus 4)

## ATTEMPT-1 ADJUDICATION 2026-06-29 (Arranger, first-hand) — FALSE-ABSENCE CORRECTED, RE-RELEASED

attempt-1 (sha 732971a) reported `blocked — op-204 fixed binary sha 301bfb1d NOT on disk; only static variants found`. **REJECTED — the binary IS on disk** (untracked_not_absent: the Explorer searched `/Users/me/wip-mach/build/` — the static `block-068`/`block-075` obj trees — but NOT `/Users/me/wip-mach/wip-gpt/build/`, the Implementer's (wip-gpt EXU) staging area where op-204 actually placed it). Verified first-hand:
- **`/Users/me/wip-mach/wip-gpt/build/op204-aslmanager-link-fix/aslmanager.op204`** — sha `301bfb1dcb2b…` (matches the op-204 `.sha256` sidecar EXACTLY); `readelf -d` NEEDED carries **`libdispatch.so.5`** + `libthr.so.3` + `libsys.so.7` + `libmach.so.5` (mirrors notifyd) → the dynamic fix, the static `__elf_aux_vector` deref root is GONE. This is THE op-204 handoff.
- second identical copy: `/Users/me/wip-mach/wip-gpt/build/op177-clean-env-v3/obj/Users/me/wip-mach/wip-gpt/wip-rmxos/amd64.amd64/usr.sbin/aslmanager/aslmanager` (same sha `301bfb1d`).

**RESOLVED INPUT for the re-run:** consume the op-204 handoff at **`/Users/me/wip-mach/wip-gpt/build/op204-aslmanager-link-fix/aslmanager.op204`** (sha `301bfb1d`). rx1 already reads the host tree (it cited `block-075` under the sibling `build/`), so this path is reachable — NO Implementer re-stage/re-build is needed (build_is_implementer was correctly invoked, but the premise — "absent" — was wrong; nothing needs building). If a cross-EXU read of `wip-gpt/` is genuinely blocked for rx1, the fallback is a trivial `cp` of that handoff into rx1's owned dir (a copy, not a build) — but try the path first. Then run the OP213_ASLMGR_RUNS → OP213_RECLAIM_FIRES smoke as briefed below.

## WHY (one line)

op-198 v5 is a Gatekeeper hours-scale aslmanager-reclaim regression soak that serializes on the single overloaded soak host — a scarce slot. This Explorer SMOKE proves, in minutes not hours, that the image boots the op-204 FIXED aslmanager and the reclaim mechanism ARMS + FIRES once, so the Gatekeeper's overnight slot is spent on the SOAK, not on discovering a boot/arming bug. Complete-once pre-flight (offloaded off the Gatekeeper).

## SCOPE / SUBJECT (short smoke — boot + a single reclaim cycle, NOT hours-scale)

- **Image identity FIRST (artifact_identity_needs_content_check):** boot an image carrying the op-204 fixed aslmanager — confirm first-hand the BOOTED aslmanager is sha `301bfb1d…` (`build/op204-aslmanager-link-fix/aslmanager.op204`) / NEEDED carries `libdispatch.so.5`, NOT the broken op-196 libc-only binary that SIGSEGVs before main. If the image carries the static one, STOP + REPORT (the soak would be dark).
- **R1 (arming):** `launchctl load` + kickstart aslmanager; confirm it reaches main + stays up (live pid, no pre-main core) — the op-204 fix actually runs on THIS image.
- **R2b (single fire):** pre-age a couple of store files over the armed limit; arm `all_max` via `-size 500K` (NOT `-dd`); confirm the aslmanager debug_log emits the reclaim evidence ONCE: `Data Store Size > all_max` + `Additional YMD Scan` + a `remove` line. Proves the mechanism ARMS + FIRES — the precondition the hours-scale soak depends on.
- **Image choice (flag at dispatch):** smoke on the op-204 image is sufficient (reclaim is store-FILE-level, logger-independent). If the Coordinator wants the integrated op-204+op-210 image (asld-as-logger feeding the store while aslmanager reclaims), note that as the soak's image — but the ARMING smoke doesn't need it.

## DELIVERABLES

**D1 — fixed-binary boot confirmed.** Booted aslmanager = sha `301bfb1d…` / NEEDED libdispatch.so.5 (first-hand), launchctl-loaded + kickstarted, reaches main + live pid, no pre-main core. → `OP213_ASLMGR_RUNS`

**D2 — reclaim arms + fires once.** Pre-aged store over limit + `all_max` armed (`-size 500K`, not `-dd`); debug_log shows `Data Store Size > all_max` + `Additional YMD Scan` + `remove` — a single reclaim cycle. → `OP213_RECLAIM_FIRES`

**D3 — pre-flight disposition.** GREEN (image + arming + single-fire all good → the Gatekeeper op-198 v5 hours-scale soak is cleared to run one-pass) | BLOCKED (image carries the static binary / arming fails / reclaim won't fire — REPORT the blocker so it's fixed BEFORE the soak slot is spent). → `OP213_PREFLIGHT` / `OP213_VERDICT` (`soak-cleared` | `blocked`) / `OP213_TERMINAL`

**VERDICT:** `soak-cleared` (the op-198 v5 Gatekeeper soak can run one-pass — mechanism proven to arm+fire on the fixed-binary image) | `blocked` (a boot/identity/arming defect to fix before the soak — names it).

## BOUNDARIES
- **SMOKE, NOT THE SOAK.** This is a short single-cycle discovery check; the hours-scale fixed-bar regression soak stays Gatekeeper op-198 v5 (soak_is_gatekeeper — Explorer de-risks, never IS the gate). Do NOT run hours-scale here; do NOT claim a soak/regression result.
- Confirm the BOOTED binary identity first-hand (artifact_identity_needs_content_check) — the v4 darkness was a wrong/broken binary; don't smoke the static one.
- Explorer owned dir (agent_host_isolation, NO host /tmp); consume the image read-only. No source edits, no build (build_is_implementer — if a new/combined image is needed, REQUEST it, don't build).
- Verify the reclaim evidence from the debug_log first-hand (background_exit_code_hygiene; no_conflate: "aslmanager up" ≠ "reclaim fires" — assert the `remove` line).

## MARKERS
```
OP213_ASLMGR_RUNS    # booted aslmanager sha 301bfb1d / NEEDED libdispatch.so.5, launchctl-loaded+kickstarted, reaches main, live pid, no core
OP213_RECLAIM_FIRES  # pre-aged store + all_max armed (-size 500K, not -dd) → debug_log: Data Store Size > all_max + Additional YMD Scan + remove
OP213_PREFLIGHT      # soak-cleared | blocked (+ the blocker if blocked)
OP213_VERDICT        # soak-cleared | blocked
OP213_TERMINAL
```

## RELATIONS
- UPSTREAM: op-204 [Done] (fixed aslmanager sha 301bfb1d — the binary this smokes), op-198 v5 [Awaiting] (the Gatekeeper hours-scale soak this de-risks), op-196 (the broken-binary image to AVOID).
- DOWNSTREAM: `soak-cleared` → op-198 v5 runs one-pass on the next soak slot; `blocked` → fix the named defect (Implementer) before spending the slot. Coordinates with op-210 (if the soak wants the integrated asld-logger image).
- PARALLEL/NON-BLOCKING to op-185 + op-212 — different work, rx1 host, off the soak host. (op-212 + op-213 both on rx1 → serialize on rx1, order = Coordinator's call; op-212 is the higher-leverage one.)
- NOTE: rx1 only. rx2 parked-for-cause — do NOT route here.
- feedback: soak_is_gatekeeper (smoke de-risks, the soak stays Gatekeeper), artifact_identity_needs_content_check (booted-binary sha first-hand), build_is_implementer (request images, don't build), agent_host_isolation, background_exit_code_hygiene, no_conflate_gating_with_readiness (arms+fires asserted, not "up"). project: 10preview_gate (asl), launchd_no_autoscan (launchctl-load aslmanager).
```
