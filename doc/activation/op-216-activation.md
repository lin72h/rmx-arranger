---
id: op-216
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-216 — Explorer: asl NATIVE-submit launchd-context re-test → close the last asl-green leg by proving `asl_log`/aslutil over `com.apple.system.logger` lands in the asld store when the client holds a valid bootstrap

op-216 | role: **Explorer** (FREE) | EXU: **rx-x64z** (rmx-explorer / rx1) | state: **[Done — `native-green`, Arranger SOURCE-verified first-hand @ f2e4b45 (a823526..f2e4b45)].** D1 bootstrap-OK: harness ran as a launchd child (run-as-launchd-job.sh, inherited bootstrap) → asl_open PASS ⟹ `bootstrap_look_up2(com.apple.system.logger)` resolved non-null. D2 native-lands: all 9 cases PASS (matrix_fails=0); asl_log + asl_search_roundtrip PASS; store file `/var/log/asl/2026.06.29.G80.asl` (1665B) carries the submitted msg. **NATIVE-vs-SOCKET CONFIRMED AT SOURCE (the brief's no_conflate trap):** `asl.c:1132` gates the whole send on `_asl_global.server_port != MACH_PORT_NULL`; the only send in-block is `:1163 _asl_server_message(server_port,…)` — the Mach RPC to com.apple.system.logger; there is NO socket fallback in the asl_log path. So the op-210 `found=0`→op-216 `found>0` flip IS the `:1132` guard flipping null→non-null server_port (exactly op-212's trace), and a landed msg necessarily went native-Mach, NOT the `/var/run/syslog` BSD socket. **NOTE (no baseline reversal):** asl_search_roundtrip PASS here ≠ overturning the id-011 leg-3 shared-FAIL (that was an in-process 200ms write→search race vs a not-yet-flushed fixture; op-216 reads back from the LIVE asld on-disk store with time to persist — different setup, both true). asl's last native-submit leg CLOSED. | parent id: id-011 (asl, native-submit leg) + id-016 (ambient-bootstrap) | L1i: li-1004 (asl) | cost: free | authored 2026-06-29 (Arranger seat, model Opus 4)

## WHY (one line)

op-210 made asld the live logger but proved it ONLY over the BSD `/var/run/syslog` socket; the ASL **native** Mach submit (`asl_log`/aslutil over `com.apple.system.logger`) returned `found=0`. op-212 source-traced that to the **id-016 ambient-bootstrap gap, NOT a Mach/asl defect** (Arranger-verified first-hand @ bdd0fdc): the submit client ran with `bootstrap_port==0` → `asl_core.c:110 bootstrap_look_up2` fails → `asl.c:1132` guard skips the send (never reaches the kernel); verdict `independent` (separate from the benign printf and from debt-#21). So asl's last native-submit leg is a **cheap bootstrap-CONTEXT re-test**: re-run the client **launchd-HOSTED** (so it inherits a valid system bootstrap, exactly like notify's probe-child path) and confirm the message lands in the store. The mechanism PREDICTS pass (valid bootstrap → `bootstrap_look_up2` resolves → send proceeds) — this op proves it at runtime so asl can be called FULLY green. It is NOT a Mach-receive investigation and NOT a soak.

## SCOPE / SUBJECT (functional round-trip — boot + one native submit + one store read-back; NOT hours-scale)

- **Image:** the **asld-as-live-logger** image (op-210 wiring, the op-212 lineage @ bdd0fdc — asld answering `com.apple.system.logger`). Confirm first-hand the booted logger is the dynamic asld (op-207-fixed, NEEDED `libdispatch.so.5`), NOT static/unwired (artifact_identity_needs_content_check). Consume read-only.
- **The re-test (the whole op):** run `aslutil`/`asl_log` as a **launchd-hosted job** — reuse the op-133 `/root/run-as-launchd-job.sh` runner (the same probe-child path notify used to cross the id-016 gap). The client MUST be a direct launchd-job child so it inherits launchd's bootstrap (launchd is the bootstrap server for its own children regardless of PID-1 status — the id-016 gap is for NON-launchd descendants, which this deliberately is not).
- **Confirm the bootstrap context FIRST (the operative premise — verify before asserting outcome):** in the launchd-hosted client, read `TASK_BOOTSTRAP_PORT` / confirm `bootstrap_look_up2(com.apple.system.logger)` RESOLVES non-null. If it's still null in the launchd-job context, STOP + report — that re-opens the id-016 closure assumption, a high-value negative (do NOT paper over it by reading the store).
- **Then the round-trip:** submit a uniquely-tagged native ASL message; read it back out of the asld store (`asl_search` / inspect the on-disk `YYYY.MM.DD.asl`). `found>0` for the unique tag = the native Mach submit path works end-to-end under a valid bootstrap.

## DELIVERABLES

**D1 — bootstrap context confirmed.** Launchd-hosted client's `bootstrap_look_up2(com.apple.system.logger)` resolves non-null (the id-016-valid context) — first-hand, the operative premise. → `OP216_BOOTSTRAP_OK`

**D2 — native submit lands.** A uniquely-tagged `asl_log`/aslutil native Mach submit (over `com.apple.system.logger`, NOT the `/var/run/syslog` BSD socket) is read back from the asld store (`found>0` for the tag). Show it's the NATIVE path (Mach submit), not the socket fallback. → `OP216_NATIVE_LANDS`

**D3 — asl native-submit disposition.** `native-green` (valid bootstrap + message lands → asl's last leg closed, mechanism prediction confirmed) | `bootstrap-gap` (launchd-hosted client STILL gets null bootstrap → id-016 closure assumption fails for this path — REPORT precisely, do NOT improvise) | `native-dark` (bootstrap valid but message does NOT land → a genuine native-submit defect beyond id-016 — capture the send return + store state, escalate to Implementer). → `OP216_VERDICT` / `OP216_TERMINAL`

## BOUNDARIES
- **Explorer functional confirmation — observe + classify, no fix, no soak** (soak_is_gatekeeper; this is a single round-trip, not hours-scale). No product source edits (build_is_implementer — if the runner/client needs a (re)build, REQUEST it).
- **Verify the bootstrap premise FIRST, then the outcome** (verify_signature_divergence_claims / no_conflate: "message in store" alone doesn't prove the NATIVE path — assert the Mach submit + non-null bootstrap, not just `found>0`, since the BSD socket could also populate the store). Distinguish native-Mach-submit from socket-fallback first-hand.
- Confirm the booted asld identity first-hand (artifact_identity_needs_content_check — dynamic op-207 asld, not the static SIGSEGV variant or stock syslogd).
- Off the soak host; rx1 owned dir (agent_host_isolation, NO host /tmp). rx2 PARKED — do NOT route.

## MARKERS
```
OP216_BOOTSTRAP_OK   # launchd-hosted client: bootstrap_look_up2(com.apple.system.logger) resolves non-null (id-016-valid context)
OP216_NATIVE_LANDS   # uniquely-tagged asl_log/aslutil NATIVE Mach submit read back from the asld store (found>0); native path, not socket fallback
OP216_VERDICT        # native-green | bootstrap-gap | native-dark
OP216_TERMINAL
```

## RELATIONS
- UPSTREAM: op-212 [Done] (source-traced the `found=0` to id-016 bootstrap gap, verdict `independent`), op-210 [Done] (asld-as-live-logger, but proven only over the BSD socket), op-133 [Retired] (the `run-as-launchd-job.sh` probe-child runner this reuses), id-016 (the bootstrap closure this leg depends on).
- DOWNSTREAM: `native-green` → asl's last native-submit leg closes → asl FULLY green for the 1.0-preview gate (folds with the op-198 v5 reclaim soak + the green conformance/lifecycle legs). `bootstrap-gap` → re-opens the id-016-closure assumption for the launchd-job path (Arranger adjudicates). Does NOT touch the soak host or any in-flight artifact.
- PARALLEL/NON-BLOCKING — off the soak host, independent of op-185/op-165/op-198 v5/op-215.
- feedback: soak_is_gatekeeper (functional re-test, not a soak), verify_signature_divergence_claims (assert native-Mach path + non-null bootstrap, not just store presence), no_conflate_gating_with_readiness, artifact_identity_needs_content_check (booted asld identity), build_is_implementer, agent_host_isolation. project: 10preview_gate (asl core service — last native-submit leg), asld_is_preview_logger, launchd_no_autoscan (client is a launchd-hosted job, not auto-scanned). id-016 (ambient-bootstrap closure under a launchd-job child).
```
