---
id: op-222
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-222 — Gatekeeper: isolate the aslmanager all_max SIZE pass from TTL aging with today-dated oversize files → close op-198 leg-4 honestly

op-222 | role: **Gatekeeper** (cost-0) | EXU: **rmx-gatekeeper-rx-x64z** | state: **[Done — SIZE-RECLAIM-PROVEN 2026-06-30, commit 8692d74, Arranger-confirmed first-hand].** The op-198 v6 FLAG (size-pass not isolated from TTL; RIDER-1 path-markers empty) is RESOLVED here by test design, not marker capture. VERIFIED from the committed host log: `OP222_TTL_CONFIG = store_ttl 7` (TTL=7d, in-guest), 3× `2026.06.30.G80*.asl` files @ 4,885,270 b each, mtime `Jun 30 09:38` (today, 0-day), store_before=14504kb; `aslmanager -s /var/log/asl -size 500K -d L5` rc=0 → store_after=8kb, all three today-dated files purged (only StoreData 12 b remains). A 0-day file cannot be removed by a 7-day TTL/YMD sweep → the `all_max` SIZE pass is isolated BY CONSTRUCTION. aslmanager identity sha `301bfb1d` confirmed in-guest. | parent id: id-011 (li-1004 asl, leg-4) | L1i: li-1004 | cost: 0 | authored 2026-06-30 (Arranger seat, model Opus 4)

## WHY (one line)

op-198 v6 proved store-bound BEHAVIOR (reclaim fires, bounded 16cyc/4h, crash-clean) but did NOT isolate the SIZE pass: every pre-aged file was `touch -t` backdated OLD, so the TTL/YMD age sweep alone explains the purge, and the RIDER-1 path-markers came up empty. This op isolates the size pass with a test the outcome itself disambiguates — today-dated oversize files TTL cannot touch.

## SCOPE / SUBJECT (short confirm, NOT a re-soak)

- Same op-198 v6 image read-only (aslmanager `301bfb1d`, mach.ko `ffc67eda`); Gatekeeper's OWN dir (`agent_host_isolation`).
- Pre-stage oversize store files dated **TODAY** (real current date, NO `touch -t` backdate). TTL/YMD cannot age-delete 0-day files → a purge below `all_max` ⇒ SIZE pass, by construction. No debug-marker capture required.
- Confirm store TTL first-hand (asl.conf / aslmanager default) so the op-198 v6 <7d-purge counter-signal can be scored.
- If markers still wanted: verify in aslmanager SOURCE where the size/YMD/remove debug strings emit (`-d`/stderr vs asl_log) before trusting any channel — the v6 "routes through asld" claim was wrong.

## DELIVERABLES

**D1 — size pass isolated.** Today-dated oversize store purged below `all_max` ⇒ size pass fired (TTL excluded by construction). Report store before/after + file list. → `OP222_SIZE_ISOLATED`

**D2 — verdict.** `size-reclaim-proven` (→ op-198 leg-4 closes clean, asl truly-green) | `size-dark` (today-dated files SURVIVE despite all_max armed ⇒ real defect, escalate Implementer) | `walled`. → `OP222_VERDICT` / `OP222_TERMINAL`

## OUTCOME (Arranger-confirmed first-hand 2026-06-30)

- **D1 MET:** store 14504kb→8kb, 3 today-dated (0-day) files purged, TTL=7d verified → size pass isolated by construction.
- **D2 = size-reclaim-proven.** op-198 leg-4 closes clean; asl truly-green (legs 1/3 + native-submit op-216 + leg-4 store-bound MET).
- **Source correction (RIDER-1, bonus):** `debug_log()` = `vfprintf(stderr, ...)` NOT asl_log (the v5/v6 "routes through asld" claim was false — and this harness ran no asld anyway). `-d` defaults to `ASL_LEVEL_ERR`(3); markers emit at `ASL_LEVEL_NOTICE`(5); a `(i+i)` vs `(i+1)` parse bug at aslmanager.c:1512 stops `-d L5` raising the threshold → markers stay filtered. Real product bug, **non-blocking** for leg-4 (outcome proof stands). Candidate for a low-pri li-1004 cleanup issue.

## BOUNDARIES
- Short confirm, NOT a re-soak. Same v6 image read-only. Gatekeeper's OWN dir.
- Verify TTL + marker-emit path first-hand before inferring mechanism (verify-premise-before-mechanism).
- No rebuild; if the binary/store/config are wrong, REPORT (build_is_implementer).

## MARKERS
```
OP222_SIZE_ISOLATED  # today-dated oversize store purged below all_max ⇒ size pass (TTL excluded by construction)
OP222_VERDICT        # size-reclaim-proven | size-dark | walled
OP222_TERMINAL
```

## RELATIONS
- UPSTREAM: **op-198 v6** (store-bound behaviorally MET but size-pass not isolated + RIDER-1 markers empty — this op closes that gap), op-216 (native-submit green), op-204 (the fixed aslmanager `301bfb1d`), op-213 (reclaim mechanism one-pass smoke).
- DOWNSTREAM: closes asl leg-4 (id-011) → asl truly-green → all 4 core preview services {launchd, libxpc, notify, asl} green = 1.0-preview SERVICES gate met (Coordinator's stamp). Boot/deploy track (op-220 edk2 + real-HW Rocket Lake smoke) is SEPARATE, still owed before dogfooding.
- feedback: soak_is_gatekeeper, no_conflate_gating_with_readiness ("store shrinks" ≠ "size-pass armed" until TTL excluded), verify_premise_before_mechanism (the v5/v6 "routes through asld" was a wrong mechanism claim — corrected by source read), artifact_identity_needs_content_check (aslmanager 301bfb1d in-guest), agent_host_isolation, build_is_implementer. project: 10preview_gate (asl core service), li-1012 clean-provenance.
