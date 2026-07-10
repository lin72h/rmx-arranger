# op-243 — Gatekeeper: disambiguate the op-226 li-1003 notify HANG — re-run the notify soak on the op-182 MACHDEBUGDEBUG image WITHOUT syslogd (isolate the syslogd confound)

op-243 | role: **Gatekeeper** (regression soak, disambiguation) | EXU: **rmx-gatekeeper-rx-x64z** | state: **[Done — syslogd RULED OUT (clean single-variable result); but the report's verdict (b) "real notify-path liveness issue" is PREMATURE — op-165 2h-clean baseline leans harness-artifact; 3 confounds remain → op-248 bisects. Commit 18107c8, 2026-07-02]** — see OUTCOME. | parent id: id-000 (op-226 carry 3) | L1i: li-1003 (notify legs 1-3) / li-1013 Item 1 M2 (notify not-yet-re-hosted-green on ship conf) | cost: gatekeeper-tier (free role; machine-hours) | authored 2026-07-02 (Arranger seat, model Opus 4)

## OUTCOME (Arranger adjudication, 2026-07-02)

**ACCEPTED (the controlled result):** the hang is **NOT syslogd-specific** — op-243 (no syslogd) hung just like op-226 (syslogd). That was the one variable this op controlled, and it's cleanly ruled out. Good, real progress.

**NOT ACCEPTED as settled — verdict (b) "real WITNESS/notify-path liveness issue" is PREMATURE (`no_conflate`, the gate-right/mechanism-wrong pattern).** The op-165-vs-op-243 comparison — both no-syslogd, op-165 CLEAN 2h, op-243 HUNG — still differs in **3 uncontrolled variables the report itself lists**: (1) op-243 kldloads the `profile` provider (op-165 doesn't — may add WITNESS-tracked timer locks); (2) op-243 pipes the driver through `| tail -10` (op-165 runs it directly — a **textbook harness stall**: if the driver's stdout fills the pipe and tail doesn't drain, the writer blocks); (3) SOAK_DURATION 300 vs 7200. The report collapsed to (b) but its own **op-165 2h-clean baseline on the same kernel+driver is strong evidence the notify path is NOT fundamentally broken under this kernel** — something specific to the op-226/op-243 harness triggers it. Leaning **harness-artifact**, not notify-path liveness. Two hypotheses remain live: (b) real WITNESS-notify liveness vs (harness) an op-226/op-243 harness artifact.

**Impact claim CORRECTED.** The report says "doesn't affect the real preview boot (non-INVARIANTS)." Per li-1013 Item 1, the preview as-cert-planned ships **MACHDEBUGDEBUG = INVARIANTS/WITNESS armed** (C1 Coordinator-pending, but that's the current cert). So IF the cause is real-WITNESS-notify AND C1=yes, it WOULD affect the WITNESS-armed preview boot — this is NOT low-stakes-by-default. Resolving (b)-vs-harness matters more than the report credits. (If it's a harness artifact, no preview impact — which is why the bisection is worth one cheap run.)

**No id filed (correct call, for a different reason than the report gives).** The report says "no assert fire = no new id." I hold the id because the cause is **ambiguous** (a harness bug would not warrant a notify-path id at all) — filing now would risk seeding a wrong-target investigation. id decision waits on op-248.

**NEXT:** op-248 (Gatekeeper) bisects the op-165-vs-op-243 harness delta — reproduce op-165's EXACT invocation at SOAK_DURATION=300 (direct driver, no profile kldload, no tail pipe); if clean, add the op-243 elements back one at a time (tail pipe first, then profile kldload) to NAME the trigger. Clean at 300s ⇒ harness artifact, li-1003 is fine on the ship boot; still hangs ⇒ (b) gains real support, escalate + file id.

## CONTEXT (read first)
Open-source OS engineering — an internal regression soak of OUR OWN Mach userland on OUR certified preview image. Not security/vulnerability work, no external target. This op resolves an ambiguity left by op-226, it does not open new coverage.

## WHY (one line)
op-226 re-ran li-1003 (notify) on the op-182 MACHDEBUGDEBUG cert image and it **HUNG 20+ min** with **zero KASSERT/WITNESS/DEADLKRES fires** — but the run is confounded: op-226's rc.local starts **syslogd** (the DROPPED logger; asld is the preview logger), whereas op-165 ran the same notifyd-soak-driver **2h without hanging** on this same kernel WITHOUT syslogd. So the hang could be (a) benign WITNESS overhead, (b) a real notify-path liveness issue under asserts, or (c) syslogd-specific lock contention that won't exist on the real preview boot. We need to know which before li-1013 Item 1 M2 can call notify "re-hosted green."

## SCOPE
- **Boot the SAME op-182 MACHDEBUGDEBUG cert image** op-226 used (WITNESS/INVARIANTS armed). Verify kernel ident FIRST-HAND (uname / boot log names MACHDEBUGDEBUG + INVARIANTS) — do NOT infer from filename (`artifact_identity_needs_content_check`).
- **Single controlled variable: syslogd.** Use an rc.local WITHOUT the syslogd startup (match the op-165 boot that ran clean), everything else identical to op-226. Do NOT change the driver, SOAK_DURATION, or the notify legs — this must be an apples-to-apples re-run so the syslogd delta is the only difference.
- **Re-run li-1003 (notify legs 1-3), unmodified**, to completion (SOAK_DURATION=300 expected ~5 min; give it the same generous ceiling op-226 used).
- **Watch for:** any KASSERT/WITNESS/DEADLKRES during the run (same as op-226); and specifically whether launchctl load/start of the notify job stalls.
- **Regime-label the run (op-225 M1):** kernel ident, mach.ko sha+flags, libdispatch sha+flags — should match op-226's (mach.ko 9c7706a3, libdispatch ab7a9058); confirm first-hand, don't assume.

## DELIVERABLE
A clear disambiguation verdict:
- **notify COMPLETES without syslogd** → the op-226 hang was syslogd-confounded (won't hit the real preview boot); li-1003 is re-hosted green on the ship conf → feeds li-1013 Item 1 M2. Report the completion + regime label.
- **notify STILL HANGS without syslogd** → the hang is a real WITNESS/notify-path liveness issue independent of syslogd → this is a genuine finding; capture where it stalls (launchctl? the notify RPC? a lock?) and report → Arranger files an id. Do NOT self-patch.
Either way: pass/hang per leg, regime label attached, and an explicit statement of which of (a)/(b)/(c) the evidence supports.

## BOUNDARIES
- Gatekeeper **soaks, does not fix** — a hang is characterized + reported, not self-patched.
- No new kernel build (uses the existing op-182 image). Stage only in the Gatekeeper's own dir (`agent_host_isolation`).
- **One variable only** — syslogd on/off. Resist the urge to also change the driver or logger; a multi-variable run can't disambiguate.
- Do NOT re-introduce syslogd as "the fix" — syslogd is the DROPPED logger; the question is whether notify is healthy on the *preview* boot shape, not how to make op-226's confounded boot pass.

## RELATIONS
op-226 (carry 3, the confounded hang — this op resolves it); op-165 (the clean 2h no-syslogd baseline this replicates); li-1003 (notify legs); li-1013 Item 1 M2 (notify is the not-yet-re-hosted-green half of the cheap subset); li-1007 (notifyd integration exposure). feedback: soak_is_gatekeeper, artifact_identity_needs_content_check, no_conflate_gating_with_readiness, long_ops_batch_mode (queue for overnight if the ceiling is long), agent_host_isolation.
