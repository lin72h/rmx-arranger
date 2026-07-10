# op-170 — Explorer: why did aslmanager NOT reclaim during the op-163 asl leg-4 soak? (wiring + trigger audit)

op-170 | role: **Explorer** (FREE) | EXU: **rx-x64z** (rmx-explorer / rx1) | state: **[Retired — verdict aslmanager-not-wired; closes the op-163 store-bound FLAG]** (commit 263c21c origin/main; findings/nx-r64z/20260627-op170-aslmanager-wiring-audit.md; source-verified asl_store.c file_cache fixed-size + on-disk FILE* backing → RSS = I/O buffering not retention) | parent id: id-011 (li-1004 asl, leg-4) | L1i: li-1004 | cost: free | authored 2026-06-27 (Arranger seat, model Opus 4)

## WHY (one line)

op-163 (asl leg-4 soak, Arranger-verified) FLAGGED bar 3: asld RSS grew monotonically 6→45MB over 4h/7234
iters with **ZERO aslmanager reclaim observed** (0 reclaim markers in the serial), so the leg-4 truly-green
criterion "store growth bounded + aslmanager reclaims" is UNMET. The tree ships `usr.sbin/aslmanager/` — so
the question is whether it is wired + triggered, not whether it exists. This audit answers that UP FRONT
(free role) so the re-soak is shaped correctly instead of blindly re-running. READ-ONLY: proposes, does not
build/edit/soak.

## CONTEXT (Arranger-verified first-hand 2026-06-27 — take as given)

- Soak image: `build/op162-leg2/op162-leg2.img` (asld overlay). Soaked PID 973 = Apple asld on
  com.apple.system.logger (provenance held).
- Growth profile: decelerating (2.56→0.76 pg/it) → leak-INCONSISTENT, consistent with store accumulation
  pending a reclaim that never fired. RSS is the ONLY sampled quantity — fd count + on-disk store size were
  NOT sampled in op-163.
- `usr.sbin/aslmanager/` exists in the rmxOS tree (id-011 line 140: "log rotation/retention daemon").

## DELIVERABLES (cite file:line / config for every claim — verify-first; explorers have made false claims)

**Q1 (GATE) — is aslmanager wired into the soak image's launchd at all?**
- Is there an aslmanager launchd job/plist in the `op162-leg2` image (e.g. `com.apple.aslmanager.plist` or a
  StartCalendarInterval/periodic trigger)? Report present/absent + the load path. If ABSENT → that alone
  explains zero reclaim (store grows unbounded because nothing prunes it).

**Q2 — what TRIGGERS an aslmanager reclaim, and would it have fired in a 4h/7234-iter window?**
- Read `usr.sbin/aslmanager/aslmanager.c`: what gates a reclaim cycle — a size threshold, a TTL/age, a timer,
  or an on-demand signal? Cite the trigger condition + its default threshold (file:line).
- Given the soak wrote ~29K messages / ~45MB RSS over 4h, would the default threshold have been crossed? If
  the threshold is e.g. a multi-GB store size or a 7-day TTL, the reclaim simply never had cause to fire →
  the growth is EXPECTED-pending-threshold, not a defect.

**Q3 — does asld retain the store in memory, or only on disk?**
- Trace whether the RSS growth plausibly maps to in-memory store retention vs purely on-disk store +
  page-cache. Cite the asl_store/asl_file structures asld holds resident. (This separates "needs aslmanager
  on-disk reclaim" from "asld in-memory accumulation/leak" — different fixes.)

**VERDICT (one of):**
- `aslmanager-not-wired` → fix = wire the aslmanager job into the soak image's launchd (Implementer) + re-soak.
- `wired-but-threshold-not-hit` → re-soak longer / lower the threshold to force ≥1 reclaim cycle (Gatekeeper);
  NOT a code defect.
- `wired-and-should-have-fired` → real aslmanager/store bug → route to Implementer with the failing trigger.

## BOUNDARIES
- READ-ONLY: source + image-config audit. Do NOT build, edit, mount-and-modify, or soak. Builds are
  Implementer-only; soaks are Gatekeeper's.
- Stage strictly inside rx-x64z's own owned dir; no host-global paths.
- Cite file:line / plist path for every claim. A "suspected" trigger with no source backing must be labeled
  suspected, not asserted.

## MARKERS
```
OP170_ASLMANAGER_WIRED      # present|absent in op162-leg2 launchd; load path cited
OP170_RECLAIM_TRIGGER       # trigger condition + default threshold (aslmanager.c file:line)
OP170_WOULD_HAVE_FIRED      # given ~29K msgs/45MB/4h: yes|no, with reasoning
OP170_STORE_RETENTION       # asld in-memory store retention vs on-disk only (struct cite)
OP170_VERDICT               # aslmanager-not-wired | wired-but-threshold-not-hit | wired-and-should-have-fired
OP170_TERMINAL
```

## RELATIONS
- id-011 / li-1004 leg-4 — the soak criterion this unblocks. op-163 [Done/FLAGGED] is the upstream finding.
- DOWNSTREAM (RESERVED, author after this reports): leg-4 RE-SOAK (Gatekeeper) instrumenting {fd, RSS, on-disk
  store size} + aslmanager-reclaim watch, threshold-forced to observe ≥1 reclaim cycle; pass-bar = store/RSS
  PLATEAU across a reclaim. Possibly preceded by an Implementer aslmanager wire-up if VERDICT=not-wired.
- feedback: verify_signature_divergence_claims (cite source), build_is_implementer / soak_is_gatekeeper
  (this op only audits), role_costs (free discovery off the soak cycle), agent_host_isolation.
