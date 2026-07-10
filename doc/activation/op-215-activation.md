# op-215 — Implementer: gate the benign `ipc_entry_lookup failed on 0` console printf (ipc_kmsg.c:1318) → kill the 1,127/s id-016 null-bootstrap flood that balloons asld + the host log

op-215 | role: **Implementer** (cost-30) | EXU: **wip-gpt** | state: **[Done — `gated-clean`, Arranger SOURCE-verified first-hand @ 12b3495].** D1: printf at ipc_kmsg.c:1324 wrapped `if (mach_ipc_entry_lookup_failed_log) printf(...)`; the `dest_entry==IE_NULL` test + `goto invalid_dest` UNCHANGED (unconditional) → MACH_SEND_INVALID_DEST semantics intact (diff = 10 ins/1 del; only the printf is conditional). Gate = `static int mach_ipc_entry_lookup_failed_log` default-0 + `SYSCTL_INT(_debug_mach, ipc_entry_lookup_failed_log, CTLFLAG_RWTUN, …)` (sysctl + loader-tunable, silent-by-default/opt-in-loud). OUR overlay by construction (stock FB15 has no `sys/compat/mach`). D2: A/B smoke `default_count=0 / knob_count=10` (same boot — gate provably SUPPRESSES real events, not just a rate-drop); IPC health via ASL/syslog round-trip OK (reject path intact). mach.ko artifact sha `ffc67eda…` at `build/op215-ipc-entry-lookup-gate/.../mach.ko`. **ADOPTION PENDING (downstream):** images must pick up this mach.ko to benefit — de-noises every `-u launchd` image + removes the op-214 asld-balloon harness artifact (the flood that fed it is now silenced) → de-risks future integration soaks. Not a preview gate (quality fix). | parent id: id-016 (ambient-bootstrap gap — this is its runtime symptom) | L1i: li-001 (Mach IPC) | cost: 30 | authored 2026-06-29 (Arranger seat, model Opus 4)

## WHY (one line)

op-214 quantified a **steady-state 1,127 lines/sec** kernel flood of `ipc_entry_lookup failed on 0` (`ipc_kmsg.c:1318`) under `-u launchd` — ~100% of the host log (752MB→~1GB over a 4h soak) — from id-016 null-bootstrap callers doing `mach_msg` sends to `msgh_remote_port=0`. It is **benign** (op-192 characterized it benign-noise; op-212 confirmed it's a `MACH_SEND_INVALID_DEST` reject of a null/stale dest — the kernel correctly refuses the send), but the PRINTF cost is not benign: it floods the console → klog → balloons asld toward ~1GB RSS and fills the host log. Gate the printf so normal operation is quiet, without changing the error semantics. (This is the cheap SYMPTOM mitigation; the structural ROOT fix is PID-1 launchd closing the bootstrap so the null sends never happen — op-201/id-016. Both are valid; this one is a one-file kernel edit that helps EVERY image today, incl. the `-u launchd` test/dogfood path.)

## SCOPE / SUBJECT (product edit — OUR Mach overlay, in scope; build is yours)

- **The printf:** `sys/compat/mach/ipc/ipc_kmsg.c:1318` — in the `invalid_dest` path, `printf("ipc_entry_lookup failed on %d %s:%d\n", dest_name, __FILE__, __LINE__)` fired when `ipc_entry_lookup(space, dest_name) == IE_NULL` (:1316-1319). This is OUR `sys/compat/mach/` code (NOT FB15 base infra) — but **diff vs stock `freebsd-src-official-stable-15` first** to confirm it's our overlay add, not a base line (userland_port_no_buildinfra_changes spirit; the printf is almost certainly ours but verify).
- **CONFIRM benign FIRST (verify-first; do NOT silence a real defect):** re-confirm at source that this lookup-on-0 is exactly the null/stale-dest reject path (op-212: callers passing `msgh_remote_port=0` / a stale name → `MACH_SEND_INVALID_DEST`), and NOT a path that would mask a legitimate send failure. Only the **printf** gets gated; the `goto invalid_dest` + `MACH_SEND_INVALID_DEST` return semantics MUST be unchanged.
- **The gate (you pick the mechanism; meet the requirement):** make the printf SILENT in normal operation but recoverable when debugging — e.g. behind `bootverbose`, a `sysctl`/`debug.mach.*` knob, or a pps rate-limit (`ppsratecheck`). Default-off in a normal boot. Do NOT just delete it (it's a real debug aid for genuine bad-dest sends) — gate it.
- **Build:** kernel + `mach.ko` per the standalone-module path (`make -C sys/modules/mach`, MAKEOBJDIRPREFIX only — mach_ko_standalone_module). Hermetic env (scrub `C_INCLUDE_PATH`/`LIBRARY_PATH=/usr/local` — build_host memory).

## DELIVERABLES

**D1 — printf gated, semantics intact.** The `ipc_kmsg.c:1318` printf is silenced by default + recoverable via the chosen knob; `goto invalid_dest`/`MACH_SEND_INVALID_DEST` return UNCHANGED (show the diff — only the printf is conditional). → `OP215_GATED`

**D2 — flood gone, proven on a boot.** Boot a `-u launchd` image (the flood's repro config) + confirm first-hand the console/klog line-rate for `ipc_entry_lookup failed on 0` drops from ~1,127/s to ~0 (and recovers when the knob is enabled). Mach IPC otherwise unaffected (a quick notify/asl round-trip still works — gating the printf didn't break the reject path). → `OP215_FLOOD_GONE`

**D3 — disposition.** `gated-clean` (flood silenced, semantics intact, IPC healthy) | `walled` (the printf isn't ours / the path masks a real failure — REPORT, don't force it). → `OP215_VERDICT` / `OP215_TERMINAL`

## BOUNDARIES
- **Gate, don't delete; semantics unchanged** — this silences NOISE, it must not change which sends succeed/fail. Show the diff proving only the printf is conditional.
- **Confirm benign at source before silencing** (verify_signature_divergence_claims) — op-192/op-212 say benign, but YOU re-confirm the null/stale-dest path first-hand; if it could mask a legit failure, STOP + report.
- **OUR overlay only** — diff vs stock FB15 to confirm `ipc_kmsg.c:1318` is our add (userland_port_no_buildinfra_changes); do NOT touch base build infra.
- Build is Implementer (build_is_implementer); mach.ko standalone module path; hermetic env. Stage in the wip-gpt owned dir (agent_host_isolation).

## MARKERS
```
OP215_GATED       # ipc_kmsg.c:1318 printf silent-by-default + knob-recoverable; MACH_SEND_INVALID_DEST semantics unchanged (diff)
OP215_FLOOD_GONE  # -u launchd boot: ipc_entry_lookup-failed-on-0 line-rate ~1127/s → ~0; IPC round-trip still healthy
OP215_VERDICT     # gated-clean | walled
OP215_TERMINAL
```

## RELATIONS
- UPSTREAM: op-214 [Done] (quantified the 1,127/s flood + the asld-balloon cost), op-212 [Done] (the `MACH_SEND_INVALID_DEST` null-dest characterization @ ipc_kmsg.c:1300-1319), op-192 (benign-noise characterization — this is the fix it licenses), id-016 (the null-bootstrap root the flood expresses).
- DOWNSTREAM: a `gated-clean` build de-noises EVERY image (incl. the op-185 integration-soak repro + any `-u launchd` dogfood path) → asld no longer balloons under the flood, host logs stay small. Does NOT replace the structural root fix (PID-1 launchd / op-201 closes the bootstrap so the null sends stop) — it's the cheap parallel mitigation.
- PARALLEL/NON-BLOCKING — off the soak host, independent of op-185/op-165/op-198 v5.
- feedback: build_is_implementer, verify_signature_divergence_claims (re-confirm benign before silencing), userland_port_no_buildinfra_changes (diff vs stock; our overlay only), mach_ko_standalone_module (build path), agent_host_isolation. project: 10preview_gate (preview-health — quiet logger, small logs), mach_rebase (li-001).
```
