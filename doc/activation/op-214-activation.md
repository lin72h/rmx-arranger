---
id: op-214
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-214 — Explorer: op-185 freeze interpretation probe — pin pid-973 identity, trace the 3.9M `ipc_entry_lookup failed on 0` null-dest flood source, and characterize the asld RSS explosion (6→110MB) — read-only, on the op196-aslmanager-wired-v3 image + source

op-214 | role: **Explorer** (FREE) | EXU: **rmx-explorer** (rx1) | state: **[Done — `flood-gated` VERDICT, Arranger-verified first-hand @ 3752123 (732971a..3752123)].** VERIFIED the load-bearing bound: the in-memory backlog is DOUBLE-capped — `daemon.c:78` `DEFAULT_WORK_QUEUE_SIZE_MAX 10240000` (10.24MB) / `:80` `4096000` (4MB embedded) (the cited "4-10MB work queue cap" exactly), PLUS `daemon.c:83` a per-second kernel-message QUOTA that discards excess (`QUOTA_KERN_EXCEEDED_MESSAGE`, an additional bound the report didn't cite); `daemon.c:85` `DEFAULT_DB_FILE_MAX 25600000` = the 25.6MB asl.conf store cap. So `flood-gated` HOLDS: the 1,127/s flood cannot drive an unbounded leak; 880MB RSS is NOT message retention (Explorer attributes it to malloc fragmentation/FILE* buffering/Block allocs — plausible, the soft spot, but the OOM verdict stands on the verified caps + 8.5x deceleration + host RSS stable 2.1/8GB → soak survives 4h). **D1 RESOLVED + corrects the op-185 fear:** pid-973 IS Apple asld (`/usr/sbin/asld -d`, op-210-wired lineage, DYNAMIC — not the static SIGSEGV variant); the Gatekeeper's "asld pid=973" was CORRECT, op-196 carries the op-210 wiring (no contradiction with op-205/op-207). **D2 KEY FINDING:** the flood is **STEADY-STATE** (1,127 lines/s, ~100% log density across 135min, 9.1M/9.1M) — NOT transient, NOT per-iteration — **ambient bl-016/id-016 null-bootstrap noise UNDER `-u launchd`**, rate-gated by console write throughput. → the asld balloon is a **`-u launchd` HARNESS ARTIFACT**: under PID-1 launchd the bootstrap gap closes (op-201) → flood largely vanishes. Root-fix leads (Coordinator): (1) gate the `ipc_kmsg.c:1318` printf (op-192: benign-noise) → kills the 1,127/s console flood; (2) PID-1 launchd (op-201: bootstrap CLOSED) → kills null-dest sends at source. | parent id: id-011/id-016 (asl/bootstrap) + id-026 (integration) | L1i: li-001 (Mach IPC), li-1007 (integration soak) | cost: free | authored 2026-06-29 (Arranger seat, model Opus 4)

## LIVE DATA 2026-06-29 (t=135min, soak still running — sharpens D3/D4)

asld RSS trajectory: ~110MB @ t=75m → ~854MB @ t=120m (+744MB, 16.5 MB/min) → ~880MB @ t=135m (+29MB, 1.9 MB/min) — **growth DECELERATING 8.5x**, bhyve host RSS stable 2.1GB/8GB. So NOT a linear-unbounded OOM trajectory. BUT the Gatekeeper's "caching the ASL store, plateauing" mechanism FAILS a number check: op-196's `/etc/asl.conf max_store_size = 25600000` (25.6 MB) caps the on-DISK store, yet asld RSS is 880MB = **~34x the store cap** → it is NOT "the store cache filling." The deceleration + 34x gap together favor the **flood-gated** hypothesis (D4): the 3.9M `ipc_entry_lookup failed on 0` storm → console → klog → asld's IN-MEMORY ingest backlog grows faster than it drains (store cap governs disk, not the in-memory queue); as the flood tapers, asld drains → growth decelerates. **TEST THIS:** is the 3.9M flood a STARTUP-TRANSIENT (front-loaded burst that subsides — would make the whole RSS episode a bounded transient, asld the victim not a leaker) or STEADY-STATE (per-iteration, never stops — RSS resumes climbing)? D2's flood-source + D3's klog→store-vs-in-memory-queue path decide it.

## WHY (one line)

op-185's 4-plane soak (kernel CARRIES the op-156 id-025 fix — verified, `3c2dd7f` in the op-196 lineage) is STILL RUNNING past t=108min — the earlier "freeze" was a pgrep-race misdiagnosis, RETRACTED — but it surfaced two real combined-load signals that the retraction does NOT explain away: a 3.9M `ipc_entry_lookup failed on 0` flood and an asld RSS climb to 110MB. Three cheap read-only questions: what daemon is pid-973 (which logger the ASL plane exercised), what raw-Mach caller emits 3.9M null-dest sends under combined load, and — most urgent — whether the asld RSS growth is bounded (klog-ingest that plateaus) or an unbounded leak that will OOM the soak before 4h.

## SCOPE / SUBJECT (READ-ONLY — image inspect + source trace; no edits, no build, no boot, no soak)

- **pid-973 identity** (op-185 brief verification #1, unmet). On the booted compose, pid-973 was called "asld" but op-205/op-207 say asld was static→SIGSEGV / unwired in the preview lineage and FreeBSD syslogd was the live logger. Resolve it on the **op196-aslmanager-wired-v3.img** itself: what does `/etc/launchd.d/com.apple.syslogd.plist` ProgramArguments point at (`/usr/sbin/asld` vs `/usr/sbin/syslogd`)? readelf the target binary — is it dynamically linked (NEEDED carries `libdispatch.so.5`, the op-207-fixed asld) or static? Is op-196's image the op-210-asld-wired lineage or the FreeBSD-syslogd one? Name the real daemon. → which logger the "ASL plane" actually exercised.
- **The 3.9M `ipc_entry_lookup failed on 0` flood source.** op-212 characterized this printf (`ipc_kmsg.c:1318`, benign `MACH_SEND_INVALID_DEST` on a null/stale dest) as coming from "other raw-Mach callers" — NOT the asl submit (that one skips at userspace). Under the 4-plane load SOMETHING emits it 3.9M times. Trace the caller(s): which of the four planes (oracle mach-IPC round-trip / notify churn / asl / dispatch) drives raw-Mach sends to a null dest? Cite the send site + file:line. Is it a retry loop (a caller re-sending to a dead/never-resolved port every iteration)? This is the candidate freeze driver — a console-bound printf storm.
- **The asld RSS explosion (6,392→7,780→110,096 kB, accelerating).** Mechanism: does the booted logger ingest kernel console messages (klog / `/dev/klog` / the `kern.*` facility) such that the 3.9M printf flood becomes 3.9M store records → unbounded growth? Read the logger's klog-ingest path + the asl store-append path. Is the RSS blow-up DOWNSTREAM of the printf flood (one root: kill the flood, the RSS bounds) or an independent asld leak? Cite file:line.

## DELIVERABLES

**D1 — pid-973 pinned.** Binary path (from the syslogd plist on the op-196 image) + static|dynamic (readelf NEEDED) + the real daemon name (asld | FreeBSD syslogd) + which lineage op-196 is. → `OP214_PID973`

**D2 — flood source traced.** Which plane + which raw-Mach send site emits the null-dest `ipc_entry_lookup failed on 0`, file:line, and whether it is a per-iteration retry storm. → `OP214_FLOOD_SOURCE`

**D3 — RSS chain characterized.** Whether the asld RSS explosion is downstream of the printf-flood (via klog ingest → store append) or an independent leak; file:line for the ingest+append path. → `OP214_RSS_CHAIN`

**D4 — asld RSS-growth verdict (read-only; the live OOM risk).** Given D2/D3, is the asld RSS climb to 110MB `bounded` (klog-ingest that plateaus at the asl.conf max_store_size / a self-trimming store → the soak survives 4h) | `unbounded-leak` (monotonic growth with no cap → will OOM the still-running soak; name the missing bound + file:line) | `flood-gated` (bounded ONLY if the 3.9M null-dest flood from D2 is stopped — i.e. RSS is downstream of the flood)? This is the one with a clock on it — report it FIRST if the soak is still live. REPORT — do NOT fix (the fix is a separate Implementer op). → `OP214_RSS_VERDICT` / `OP214_TERMINAL`

## BOUNDARIES
- **READ-ONLY, code+image-reasoned** — mount/readelf the op-196 image, read source; no edits, no build (build_is_implementer), no boot, no soak (soak_is_gatekeeper). Stage notes in the rx1 owned dir (agent_host_isolation, NO host /tmp).
- **Cite file:line / readelf output for every claim** — "pid-973 is asld" and "flood comes from plane X" are identity/causation claims the Arranger adjudicates first-hand before they re-class the freeze or scope a fix (verify_signature_divergence_claims; 3× prior false root-cause history; the op-185 "same id-025" stamp is itself an example to correct, not inherit).
- **Characterize, don't fix, don't re-open** (no_conflate_gating_with_readiness) — name the root + file:line; the freeze CAPTURE is op-165's watchpoint rig, the id-025 re-open call is the Arranger's, any fix is a separate Implementer op.
- Non-contending: does NOT touch the soak host or any in-flight artifact; rx1 only (rx2 parked — do NOT route).

## MARKERS
```
OP214_PID973         # pid-973 binary path + static|dynamic (NEEDED) + real daemon name + op-196 lineage
OP214_FLOOD_SOURCE   # which plane + raw-Mach send site emits the 3.9M null-dest reject, file:line, retry-storm?
OP214_RSS_CHAIN      # asld RSS explosion downstream-of-flood (klog→store) | independent leak, file:line
OP214_RSS_VERDICT    # asld RSS growth: bounded | unbounded-leak | flood-gated (downstream of the D2 flood)
OP214_TERMINAL
```

## RELATIONS
- UPSTREAM: op-185 [Done — FLAGGED] (the freeze + RSS + flood evidence), op-212 [Done] (the `ipc_entry_lookup failed on 0` = benign null-dest reject characterization), op-205/op-207 (asld static/unwired census), op-210 (asld-as-logger wiring), op-196 (the op196-aslmanager-wired-v3 image), id-025 (the freeze, op-156-patched kernel).
- DOWNSTREAM: a clean re-classification de-risks the op-185 re-run (op-165 carries the freeze-capture rig); `id-025-deadlock` → Arranger re-opens id-025 + escalates; `printf-flood-stall`/`rss-oom` → a NEW (non-id-025) defect, scope the flood-source fix as an Implementer op. Either way the freeze CAPTURE is op-165, the fix is a separate op.
- PARALLEL/NON-BLOCKING to op-165 (notify leg-4 soak) — read-only, no host contention; settles the interpretation BEFORE the next overnight soak burns the host.
- feedback: verify_signature_divergence_claims (file:line; correct the "same id-025" stamp, don't inherit it), no_conflate_gating_with_readiness (characterize not fix/re-open), build_is_implementer/soak_is_gatekeeper (read-only), agent_host_isolation, artifact_identity_needs_content_check (pin pid-973 from the image, not the report). project: 10preview_gate (integration confidence), asld_is_preview_logger (which logger pid-973 is), mach_rebase (li-001).
```
