# op-163 — Gatekeeper: asl leg-4 (SOAK) — sustained launchd-hosted asld stability over the 9-case asl churn; the last bar to li-1004 truly-green

op-163 | role: **Gatekeeper** (FREE) | EXU: **rmx-gatekeeper-rx-x64z** (soak host — boot the asld/launchd image, NOT the base kernel) | state: **[Awaiting]** — blocker cleared (op-159 [Retired] 2026-06-27 → soak host free) + boot image staged (`build/op162-leg2/op162-leg2.img`, asld overlay, provenance-proven at op-162: pid 979 = `/usr/sbin/asld` answering com.apple.system.logger). Released for **overnight batch** (long soak; NOT interactive) — Coordinator dispatches | parent id: id-011 (li-1004 asl) | authored 2026-06-26 (Arranger seat, model Opus 4)
purpose: close the SOLE remaining leg on asl. legs done: leg-1 lifecycle GREEN (op-146), leg-2 traced GREEN (op-162), leg-3 conformance-MATCH 9/9 GREEN (op-116-cont). leg-4 (soak) proves launchd-hosted asld survives SUSTAINED 9-case churn over the overnight window with no crash / no leak / no store runaway / no degradation — i.e. asl is not point-green but durable. PASS here → asl is the FIRST core service truly-green → joins {launchd, libnotify, libxpc} toward li-1000 1.0-preview.

ROLE BOUNDARY: this is a **fixed-bar regression soak = Gatekeeper's** (feedback_soak_is_gatekeeper). leg-3's MATCH and leg-2's trace are the fixed bars; leg-4 holds them over duration. NOT Explorer (no discovery) and NOT the Implementer proving its own fix. Distinct from op-159 (id-025 notifyd soak) — different subject, different boot image; the two CONTEND for the single soak host → op-163 QUEUES BEHIND op-159 (kernel blocker wins the slot; asld image ≠ base-kernel boot target).

RUN MODEL (mandatory — inherits op-146/op-162):
- asld is launchd-hosted → drive via the **launchd-JOB model**, NOT shell-launch (id-016: shell-launch gets TASK_BOOTSTRAP_PORT=0). Load asld as a launchd job; confirm it answers the `com.apple.system.logger` Mach bootstrap.
- **PROVENANCE GATE (id-011 standing caveat):** confirm FIRST-HAND the soaked PID is the **Apple asld** (overlay provenance, answers com.apple.system.logger), NOT a base FreeBSD syslogd confound shadowing the port. If base syslogd shadows, the soak observes the wrong daemon and paper-greens → flag and stop.
- Workload = the existing compiled `/root/asl-harness` (9 R()-cases: asl_open / asl_new / asl_set / asl_log / asl_get_roundtrip / asl_set_filter / asl_log_filtered / asl_close / asl_search_roundtrip), the SAME 9 cases leg-2/leg-3 used. leg-4 adds DURATION, not new cases. Keep the op-162 `usleep(200000)` 200ms settle before asl_search (it resolves the immediate-write→search store-propagation timing; do NOT remove it).

SOAK BARS (fixed — what durability must hold over the overnight window):
1. **No crash / no abnormal signal on the asld PID** across the full soak — crash bar = `fbt::sigexit:entry` AND/OR `proc:::signal-clear` **predicated on the asld PID** (NEVER a userspace asl/asld symbol as an fbt:: bar — it never matches; feedback_fbt_traces_kernel_only). A clean SIGTERM at planned shutdown is fine; any sigexit/SIGSEGV/SIGABRT/SIGBUS mid-soak = FAIL with the captured stack + iteration.
2. **asld stays UP — no silent restart** masking a crash. Watch the PID: if it changes, a crash was masked by a launchd KeepAlive restart → FLAG (a restart-hidden crash is the exact paper-green leg-4 exists to catch).
3. **No resource runaway** — fd count, RSS, and the asl STORE size must not grow unbounded over sustained logging. The store-write path is the leg-4-specific risk (leg-2 was a single pass; sustained asl_log can leak fds or grow the store without bound). Sample fd/RSS/store periodically; FAIL on monotonic runaway.
4. **No case degradation under load** — the 9 cases keep their leg-3 dispositions over the soak. asl_search_roundtrip (the 200ms-settle case, count>0 criterion — NOT the weakened r!=NULL trap) must stay PASS; if its PASS rate decays as the store grows / under sustained churn, that is a real durability finding → capture it (degradation curve), do NOT average it away.

PROBE MODEL (harness pillar — op-147m): crash bar + the fd/RSS/store samplers as a DTrace `.d` / Elixir-orchestrated observation; load each provider INDIVIDUALLY; NO printf/dprintf added to product source (printf in the `.d` is fine); `.d` committed to the harness, not product edits.

DELIVERABLE / GATE (Gatekeeper validates; Arranger-seat first-hand confirms before truly-green):
- The soak run: 9-case asl-harness churn against launchd-hosted asld over the overnight window, asld PID under the crash bar + the fd/RSS/store samplers.
- Iteration count + elapsed wall-clock (report the REAL number — no loose 354-vs-828 looseness like op-162; the count IS the durability evidence).
- VERDICT: **SOAK-CLEAN** (no crash, no restart, no runaway, no degradation over the full window) OR **FLAGGED** (name the bar + iteration + captured stack/sample). Source-cite the provenance check (which binary answered com.apple.system.logger).

MARKERS:
```
OP163_ASLD_PROVENANCE status=0    # soaked PID confirmed Apple asld on com.apple.system.logger (not base syslogd); cite
OP163_LAUNCHD_JOB_SOAK status=0   # asld driven as launchd-job; 9-case churn sustained over overnight window; iters+elapsed logged
OP163_CRASH_BAR_CLEAN status=0    # fbt::sigexit/proc:::signal-clear on asld PID: clean | FLAGGED(bar+iter+stack)
OP163_NO_RESTART status=0         # asld PID stable across soak (no KeepAlive-masked crash) | FLAGGED
OP163_NO_RUNAWAY status=0         # fd/RSS/store bounded over duration | FLAGGED(which + growth curve)
OP163_NO_DEGRADE status=0         # 9 cases hold leg-3 dispositions; asl_search PASS-rate stable | FLAGGED(degradation curve)
OP163_VERDICT status=0            # SOAK-CLEAN | FLAGGED(bar+iter+evidence)
OP163_TERMINAL status=0
```

PUSH: harness branch (the `.d` + soak log + iter/elapsed + verdict). Report → Arranger-seat first-hand verify the crash-bar log (grep sigexit/SIGSEGV/SIGABRT/SIGBUS = 0 over the window, not just the summary line) + the PID-stable + the no-runaway samples (id-011 explorer-claim history — verify the artifact, not the relayed verdict) → if SOAK-CLEAN, asl leg-4 closes → **asl truly-green (li-1004)** → first core service done. Do NOT merge from this op (harness/observation artifact only).

CHAIN (li-1004 asl → preview): leg-1 GREEN (op-146) + leg-2 GREEN (op-162) + leg-3 MATCH 9/9 GREEN (op-116-cont) → **op-163 (leg-4 soak, this — QUEUED behind op-159 for the soak host)** → asl truly-green → joins {launchd, libnotify (post id-025), libxpc (post op-122)} → li-1000 1.0-preview + li-1007 integration soak.
