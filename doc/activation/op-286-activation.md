# op-286 — Gatekeeper: asl leg-4 RE-SOAK #2 on the op-257 image — corrected harness (every observer compile-preflighted + known-bad-controlled) AND an explicit reclaim-trigger PREMISE-CHECK before the long run (does op-257's reclaim fire AT ALL past the 500K threshold?)

op-286 | role: **Gatekeeper** (soak owner) | EXU: **rmx-gatekeeper** | state: **[Ready / DISPATCH-RECOMMENDED — authored 2026-07-10 (Arranger1 seat) as the re-soak OWED by op-258's HARNESS-INVALID FAIL. Coordinator dispatches. NEW live signal folded in: a currently-running (unsanctioned, pre-invalidated) background asl soak in the Gatekeeper session shows the store growing monotonically with ZERO reclaims past the forced 500K trigger + fd flat at 37 — this is survival-only and does NOT count toward leg-4, BUT it sharpens the premise: op-257's reclaim path may not fire even when the store crosses the threshold. This op therefore front-loads a reclaim-trigger PREMISE-CHECK (known-good control) BEFORE committing to the hours-scale soak.]** | parent id: id-011 (asl li-002/li-003, leg-4) | L1i: li-1004 (asl) | cost: gatekeeper (short premise-check + hours-scale soak) | authored 2026-07-10 (Arranger seat, model Opus 4)

## CONTEXT (engineering framing)
Ordinary open-source OS engineering: durability/QA re-soak of our own ASL logging daemon — does the on-disk store stay bounded across a real aslmanager reclaim once wired. rmxOS = Darwin/Mach userland on FreeBSD 15. Not security work — no target, no adversary.

## WHY (one line)
op-258 met SURVIVAL but was HARNESS-INVALID (reclaim observer never compiled, its own compile-error was miscounted as the reclaim, plateau read a file the heartbeat never wrote, verdict fired from a shell bug) — leg-4 (bounded-store plateau across ≥1 REAL reclaim + record-conservation + ENOSPC) is UNMET; a live background run now adds evidence the reclaim may not fire at all. This re-soak proves the store plateaus across an OBSERVED reclaim, or names the reason it can't.

## PRECONDITION — reclaim-trigger PREMISE-CHECK (NEW; run FIRST, gate the long soak on it)
Before any hours-scale run, on the op-257 image, establish a KNOWN-GOOD control that op-257's reclaim actually fires:
- Drive the store deterministically PAST the configured 500K threshold (short, scripted flood — not an hours soak) and confirm, from a compile-preflighted observer, that aslmanager's reclaim path executes and the store size/file-count DROPS at least once.
- If it fires → proceed to the full soak. If it does NOT fire past threshold (matching the background-run signal), STOP and report THAT as the finding: op-257's aslmanager wiring/StartInterval/threshold does not trigger a reclaim — a **product/config defect distinct from harness validity**, which blocks leg-4 until fixed (hand the Arranger a scoped op-257-follow-up; do not fake a plateau without a real reclaim).

## THE FOUR op-258 HARNESS DEFECTS TO FIX (Arranger-verified first-hand; evidence in `rmx-gatekeeper/build/op258/`)
1. **Observer never ran.** `dtrace: failed to compile script /root/op257-reclaim-watch.d … syscall::unlink*:entry does not match any probes` — every observer MUST compile-preflight + demonstrate a KNOWN-BAD control fire before the long run (an observer that can't detect its own positive control is a FAIL, not a caveat).
2. **Compile-error miscounted as the reclaim.** `OP258_RECLAIM_COUNT reclaims=1` was the word "unlink" in the diagnostic matching the verdict grep — the reclaim signal MUST be an actual reclaim event (fbt on the aslmanager reclaim entry or a sampled store-size/file-count drop), never a log-line substring.
3. **Plateau read a dead file.** rc.local parsed `/tmp/op258-host.log` which the heartbeat never wrote (heartbeats went to serial) — heartbeat MUST write to the exact file the verdict parses; `PLATEAU_OBSERVED` must be able to fire.
4. **Verdict fired from a shell bug.** `[: 0: bad number` on the panic check fell through to else → FAIL was not principled. Fix the verdict shell; PASS/FAIL must be principled detection with numeric guards.

## SCOPE (inherits op-258 SCOPE 1–7 unchanged unless noted — re-read op-258 for the full instrumentation list)
1. Instrument fd count + RSS (secondary) + **on-disk store size (PRIMARY)** per tick; keep IPC-balance + port-slope invariants.
2. Reclaim-watch assertion, real-event-keyed (per defect-2 fix); ≥1 reclaim REQUIRED in the window, fail-loud on 0.
3. PASS-BAR = bounded sawtooth PLATEAU across a reclaim (grow → reclaim drops store → re-grow → re-reclaim), NOT monotonic growth; fd flat at quiescence; Mach-port/kmsg/mqueue balance (NOT send/recv equality — asld has legit asymmetry).
4. Record-conservation guard (op-260 SCOPE-5.1/5.2): sequence-numbered flood; post-soak union of msg_ids across ALL store files == sent-minus-explicitly-dropped; bucket any gap by same-second `rename(2)` roll-clobber vs aslmanager unlink-while-open on ACL'd (`.U`/`.G`) / rolled (`.T.asl`) files.
5. ENOSPC leg (op-260 SCOPE-5.3): fill the STORE fs (keep `/` headroom — do NOT repeat op-198 v5's `/`-fill OOM); asld MUST survive; examine the day-file chain for quiet forward-truncation at a torn record (unchecked body `fwrite`/`fflush`, `asl_file.c:1133-1134`) → outcome DECIDES whether to arm RESERVED op-266.
6. Read-after-write conformance probe (retry/latency dist); a SETTLED record a fresh store-open still misses = fail-loud (falsifies op-260 §3 timing-only).
7. Dry-run the augmented asserts (fail-loud on 0 reclaims / unbounded store / record-loss / settled-miss) BEFORE the hours run.

## LINEAGE (do not assume transfer)
op-257's image runs op-207 dynamic asld (`0c2fe9d2…`) + op-204 aslmanager on an op-210 base — NOT op-163's op-162 Apple asld. This is the FIRST durability observation of THIS asld+aslmanager combo; re-establish crash/PID/degrade durability from THIS run's own evidence alongside the store-plateau bar. Do NOT inherit op-163's durability GREEN.

## CONSUME (image — content-check provenance FIRST, op-253/li-1012 discipline)
`wip-gpt/build/op257-aslmanager-soak/op257-aslmanager-soak.img` SHA256 `3f6d73dffae04f146cc6533f79a659829b0cf24002e15d5321f3ab7be613e040` (aslmanager plist + rc.local load/start wired, `-size 500K` + asl.conf max_store_size=500000 forced trigger, `op257-reclaim-watch.d` marker stream). The serial MUST print the consumed image/libxpc-adjacent artifact sha before probe results count.

## DELIVERABLE
One soak verdict (staged in rmx-gatekeeper): the premise-check outcome FIRST (reclaim fires / does-not-fire-past-threshold), then leg-4 PASS (store plateaus across ≥1 OBSERVED reclaim, fd flat, IPC balanced, no hang/crash) or FAIL with the failing quantity + tick. Every quantity with its sampled series (fd/store/RSS + reclaim tick), not exit-code-only. If PASS → hand the Arranger the id-011 soak-leg retirement recommendation.

## BOUNDARIES
- Gatekeeper owns the soak + the FIXED BAR; the harness correction is Gatekeeper work; observer compile-preflight + known-bad control are MANDATORY (an observer dying/never-running is a FAIL).
- Do NOT edit product source; if the premise-check confirms the reclaim doesn't fire, characterize it and hand the Arranger a scoped op-257-follow-up (that finding does not itself become a product edit here).
- Any binary cross-build is Implementer's — request, don't build.
- Stage strictly in rmx-gatekeeper's owned dir (`agent_host_isolation`).
- Does NOT decide milestone placement — asl is post-preview-floor; green leg-4 retires id-011's soak leg, it does not move a preview gate.

## RELATIONS
op-258 (the HARNESS-INVALID FAIL this re-runs — its four defects fixed here) / op-257 (the aslmanager-wired image consumed; its reclaim-trigger is now premise-checked) / op-260 (Oracle store-path consult — SCOPE-4/5/6 folded) / op-163 (the original FLAGGED leg-4 soak) / op-198 (v5 harness-invalid OOM — lessons folded) / op-133 (asl soak harness + oracle) / RESERVED op-266 (unchecked-write fix, GATED on this op's ENOSPC leg) / id-011 / li-1004. feedback: oss_engineering_framing, soak_is_gatekeeper, harness_authoring_is_gatekeeper, build_is_implementer, dtrace_first_debugging, no_conflate_gating_with_readiness, verify_signature_divergence_claims, agent_host_isolation, op_state_dispatch_boundary.
