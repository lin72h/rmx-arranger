---
id: op-248
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-248 — Explorer (discovery + trace): resolve the INVARIANTS notify-hang — bisect the op-165-vs-op-243 harness delta, and if it reproduces, DTrace the stall to a named mechanism (harness-artifact vs real WITNESS/notify-path liveness)

op-248 | role: **Explorer** (discovery soak + DTrace root-cause; NO product-write, NO build) | EXU: **wip-gpt discovery seat (GPT-5.5 backend) — direct source-read + bhyve + DTrace on the op-182 image** | state: **[Done — VERDICT ACCEPTED: HARNESS ARTIFACT (confidence 8), op-243's premature-(b) REFUTED. The hang is the DTrace oracle's tick-Ns self-exit blocking `wait $DTRACE_PID` (driver line 55), NOT a notify/kernel liveness defect — Arranger-verified first-hand (driver structure + serial logs + benign-flood provenance). TWO corrections: (1) "notify HEALTHY" overstates — the 300s churn loop ran without hang/panic, but fails=0 was NEVER captured (summary eaten by the hang) → notify is NOT-YET captured-green; (2) Explorer omitted a 553-line `ipc_entry_lookup failed on 0` kernel flood (benign/pre-existing, verified). Commit 206b5a3, 2026-07-03]** | parent id: id-000 (op-243 open question) | L1i: li-1003 (notify legs) / li-1013 Item 1 M2 (notify = not-yet-green half) / li-1007 (notifyd exposure) | cost: 0 (discovery role; free) | authored 2026-07-02 (Arranger seat, model Opus 4)

## OUTCOME (Arranger adjudication, 2026-07-03, verified first-hand — driver source + serial logs)

**Verdict ACCEPTED: harness artifact, NOT a kernel/notify defect. op-243's "(b) real WITNESS/notify-path liveness" is REFUTED.** What I confirmed first-hand:
- **Churn is a synchronous 300s wall-clock loop** (notifyd-soak-driver.sh:41 `while [ now -lt end ]`), so the driver reaching ":54 waiting for oracle self-exit" DOES prove 300s of notify round-trips elapsed without hanging.
- **The hang is at :55 `wait "$DTRACE_PID"`** — the backgrounded DTrace oracle (:34) never self-terminated because its `tick-Ns` (profile-provider) probe never fired (oracle log = BEGIN only). Not notifyd/launchd/Mach IPC.
- **No panic / WITNESS / KASSERT fire** in the serial log (only the boot banner "WITNESS option enabled"). bhyve exited rc=4, no crash.
- **This matches the Arranger hypothesis op-248 was cut to test** ("op-165 2h-clean baseline leans harness-artifact"): op-165's `tick-7200s` fired after 2h; at 300s the profile/tick self-exit failed visibly.

**Two corrections (why I hold confidence at 8, not raise it):**
1. **"notify path HEALTHY / all round-trips completed" is stronger than the evidence.** The `notifyd_soak_iterations=/fails=` summary (driver :57) NEVER printed — the hang at :55 ate it (confirmed: no such line in any op248 log). So what's proven is "the 300s loop ran without hang or panic," NOT "fails=0." Notify is **NOT-YET captured-green** — it is "not the hang source." li-1013 M2 "re-hostable green" is demonstrated-plausible, NOT achieved.
2. **Completeness gap: the report omitted a 553-line `ipc_entry_lookup failed on 0` flood** (ipc_kmsg.c:1324-1328 = send to a null dest → `MACH_SEND_INVALID_DEST`, gated on `mach_ipc_entry_lookup_failed_log`) and asserted "no kernel issues, no kernel crash." I verified it is a **pre-existing benign diagnostic** — present across many prior runs incl. green ones (op123-leg4: 14,854×; block-078 asl; op163: 50,691×) — so it does NOT overturn the verdict, but a 553-line kernel-error flood must be dispositioned, not silently dropped.

**ROUTING:** the harness self-exit must be FIXED and re-run to actually CAPTURE fails=0 (the real M2 green) — that also resolves op-248's own confidence-8 open question (why tick-Ns didn't fire: profile load vs runtime). → op-250 (Gatekeeper harness-fix + re-host) authored. No id filed — no kernel defect. C1 (WITNESS-armed preview): positive signal — no notify liveness defect surfaced under WITNESS/INVARIANTS on the cert image (but M2 green still owed).

## CONTEXT (read first)
Open-source OS engineering — an internal discovery-soak + trace of OUR OWN notify path on OUR certified preview image. Not security work, no external target. Resolves the ambiguity op-243 left. This op **DIAGNOSES only** — if it names a kernel defect, an Implementer fix is a SEPARATE gated op (op-241→op-242 pattern); this seat does not fix or build.

## WHY (one line)
op-243 ruled OUT syslogd as the cause of the INVARIANTS notify hang, but concluded (b) "real WITNESS/notify-path liveness" **prematurely**: op-165 ran the SAME kernel + SAME driver 2h CLEAN (also no syslogd), so the op-165-vs-op-243 delta is one of 3 uncontrolled harness variables, not syslogd. The op-165 clean baseline leans **harness-artifact**. Bisect to name the trigger; if it's real, trace WHERE it stalls. The answer changes preview-relevance: harness-artifact ⇒ li-1003 is fine on the ship boot; real WITNESS-notify liveness ⇒ the MACHDEBUGDEBUG (WITNESS-armed) preview boot itself is implicated.

## SCOPE
1. **Single-variable bisection (op-165 discipline).** Same op-182 MACHDEBUGDEBUG cert image, no syslogd, WITNESS/INVARIANTS armed; verify kernel ident FIRST-HAND (uname/boot log). Reproduce op-165 EXACTLY at SOAK_DURATION=300 (direct driver, NO `| tail -10` pipe, NO `profile` kldload).
   - **CLEAN** ⇒ harness artifact → add elements back one at a time (tail pipe first, then profile kldload); first hang names the culprit → li-1003 fine on ship boot, re-hostable green with a corrected harness.
   - **HANGS** ⇒ trigger is deeper than the harness (reproduces on op-165's own harness short-duration) → go to step 2. (Also note: does op-165's harness hang at 300 but not 7200?)
2. **If it reproduces, DTrace the stall to a named mechanism** (source-read + bhyve + DTrace): where does it block — launchctl load/start, a WITNESS-tracked lock in launchd, or the notify RPC path? Name the lock/callsite. `fbt::` for kernel bars; `dispatch:::`/USDT for userland; no committed printf/dprintf (`dtrace_first_debugging`).

## DELIVERABLE
A named verdict — **(harness-artifact + which element)** OR **(b) real WITNESS/notify-path liveness + the specific stall site** — with the per-step clean/hang table + regime label (kernel ident, mach.ko/libdispatch sha). If harness ⇒ feeds li-1013 Item 1 M2 (notify re-hostable green). If (b) ⇒ Arranger files an id + the named mechanism seeds a SEPARATE gated Implementer fix op; it becomes a C1 WITNESS-armed-preview concern.

## BOUNDARIES
- **Discovery + trace ONLY — NO product-write, NO mach.ko/build, NO fix.** A named kernel defect → separate gated Implementer op (never diagnose-and-self-fix; `soak_is_gatekeeper` / independent-gate discipline).
- **One variable per run** — do not add back multiple elements at once (defeats the bisection).
- No new kernel build (existing op-182 image). Stage only in the seat's own dir (`agent_host_isolation`).
- **Do NOT re-litigate syslogd** — op-243 settled it (ruled out).
- **Model-honest labeling:** role is Explorer/discovery regardless of the GPT-5.5 seat; no product-write authority is conferred by the seat's capability.

## RELATIONS
op-243 (the premature-(b) result this resolves) / op-226 (original confounded hang) / op-165 (the 2h-clean baseline this bisects against) / li-1003 (notify legs) / li-1013 Item 1 M2 (notify not-yet-green; C1 WITNESS-armed-preview relevance) / li-1007 (notifyd exposure). Escalation twin: a gated Implementer fix op IF a kernel defect is named (op-241→op-242 pattern). feedback: soak_is_gatekeeper, no_conflate_gating_with_readiness (gate-right ≠ mechanism-right; the op-243 over-claim), dtrace_first_debugging, verify-premise-before-mechanism, artifact_identity_needs_content_check, agent_host_isolation, long_ops_batch_mode.
