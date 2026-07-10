# op-210 — Implementer: wire asld as the preview system logger (replace FreeBSD syslogd) + boot-load the op-207 fixed binary → make asl the live logger for the dogfood

op-210 | role: **Implementer** (cost-30) | EXU: **wip-gpt** | state: **[Done — asld-is-logger, Arranger-verified first-hand @ b7e470c2].** Product: `usr.sbin/asl/com.apple.syslogd.plist` ProgramArguments → `/usr/sbin/asld` (macOS-faithful: MachServices com.apple.system.logger + BSDSystemLogger /var/run/syslog preserved). Image `op210-asld-live-logger.img` sha fb388eb3; final serial (sha 0a97c9bb) VERIFIED first-hand: asld is the live com.apple.syslogd job (pid 874), booted asld DYNAMIC (libdispatch.so.5), FreeBSD syslogd absent before+after, crash-clean, and a unique-token message ROUND-TRIPPED into the store via asld (serial line 145 shows the actual stored line, token op210-store-proof-15…). asld now replaces FreeBSD syslogd as the live system logger. **TWO CARVE-OUTS (do NOT fail op-210, but asl is NOT fully truly-green):** (1) the ASL *native* Mach submit path drops messages — `OP210_ASLUTIL_QUERY found=0`; the green rode the BSD /var/run/syslog socket, NOT the asl_log/aslutil Mach submit over com.apple.system.logger. (2) Correlated: `ipc_entry_lookup failed on 0 … compat/mach/ipc/ipc_kmsg.c:1318` recurs through the boot incl. around the ASL submit — a credible (unproven) root for the Mach-path drop. → next asl item (investigate ASL-Mach submit + the port-0 kmsg failure). Handoff binary confirmed first-hand earlier: `build/op207-asl-dynamic-link/asld.op207` sha 0c2fe9d. Decodes the user's 2026-06-29 call: "use asld, I don't need FreeBSD's counterpart" → asl becomes the live system logger, FreeBSD syslogd dropped. | parent id: id-011 (asl, leg — live logger) | L1i: li-1004 | cost: 30 | authored 2026-06-29 (Arranger seat, model Opus 4)

## WHY (one line)

The preview lineage still boots **FreeBSD rc syslogd** — `com.apple.syslogd.plist` points at `/usr/sbin/syslogd`, asld staged-but-unwired (op-207 finding). The user's direction: rmxOS uses Darwin **asld** as THE system logger, no FreeBSD fallback. This wires asld in (pointing the syslog launchd job at the op-207 FIXED asld), disables FreeBSD syslogd, and proves a message flows end-to-end through asld — turning "asl" from a client-lib + reclaim story into the actual live logger.

## SCOPE / SUBJECT (EDITABLE — userland overlay: launchd config + rc wiring + the staged binary)

- **The asld binary MUST be the op-207 FIXED one** (dynamic-linked Darwin runtime — NEEDED carries libdispatch.so.5/libthr.so.3, no static `__elf_aux_vector`; handoff `build/op207-asl-dynamic-link/asld.op207` sha 0c2fe9d, from 986be5d). Confirm first-hand the image carries the FIXED asld, not the static one that SIGSEGVs before main (artifact_identity_needs_content_check) — wiring the broken binary just boot-crashes the logger.
- **The syslog launchd job** (`/etc/launchd.d/com.apple.syslogd.plist` or equivalent) — repoint ProgramArguments to `/usr/sbin/asld`. Keep the plist macOS-faithful on load-bearing keys (launchd plist fidelity); asld's real macOS job is `com.apple.syslogd`.
- **FreeBSD syslogd disable** — `rc.conf` `syslogd_enable="NO"` (+ ensure rc.d/syslogd doesn't start), so nothing contends for the syslog socket `/var/run/log` / klog with asld.
- **Boot-load** — launchd does NOT auto-scan /etc/launchd.d (launchd_no_autoscan): rc.local (or the real-boot productionization, cf op-202) must `launchctl load` + `start` com.apple.syslogd(asld), kickstarted directly. Mirror op-145/op-150.

## DELIVERABLES

**D1 — asld wired as the logger.** Syslog launchd job points at `/usr/sbin/asld` (the op-207 fixed binary staged in the image), FreeBSD `syslogd_enable="NO"`, rc.local launchctl-loads + starts it. → `OP210_WIRED`

**D2 — asld is the LIVE logger, first-hand.** Boot the image: asld comes up (launchctl list shows com.apple.syslogd + a live pid + a proc:::signal-clear/sigexit crash floor — NOT just "plist present"), NEEDED on the BOOTED asld carries libdispatch.so.5 (fixed binary, rc≠139, no core), and a **test message** (`logger "..."` / an `asl_log` client) actually lands in the asl store **via asld** — with FreeBSD syslogd confirmed NOT running. → `OP210_LIVE_LOGGER`

**D3 — disposition.** End-to-end logging works through asld; FreeBSD syslogd absent; crash-clean over a short window. Hand to the Gatekeeper for any sustained-logger soak (soak_is_gatekeeper — don't soak it here). → `OP210_VERDICT` (`asld-is-logger` | `walled`) / `OP210_TERMINAL`

**VERDICT:** `asld-is-logger` (asld wired + boots + is the live logger + a message round-trips through it + FreeBSD syslogd gone + crash-clean) | `walled` (image carries the static asld / asld won't boot-load / the syslog socket handoff fails — REPORT, don't force).

## BOUNDARIES
- **Use the op-207 FIXED asld.** If the image carries the static one (NEEDED libc-only), STOP and REPORT — the fix must be in the image first (don't wire a binary that SIGSEGVs at boot).
- Userland overlay only — launchd plist + rc.conf/rc.local wiring; macOS-faithful on load-bearing plist keys (launchd plist fidelity). NO FB build-infra edits.
- launchd_no_autoscan: the plist is INERT until rc.local loads it — "plist repointed" ≠ "asld runs." Verify the JOB runs.
- Verify a message ACTUALLY flows through asld first-hand (no_conflate_gating_with_readiness: "wired" ≠ "logging"); confirm FreeBSD syslogd is not also up (no dual-logger contention).
- Persistent real-boot productionization of the load-glue overlaps op-202 (PID-1 init_path + rc-chainload) — coordinate, don't duplicate; this op is the asld JOB wiring specifically.

## MARKERS
```
OP210_WIRED         # syslog launchd job → /usr/sbin/asld (op-207 fixed), syslogd_enable=NO, rc.local launchctl-loads it
OP210_LIVE_LOGGER   # asld boots (launchctl list + pid + signal-clear floor), NEEDED carries libdispatch.so.5, a test message lands in the asl store via asld, FreeBSD syslogd NOT running
OP210_VERDICT       # asld-is-logger | walled
OP210_TERMINAL
```

## RELATIONS
- UPSTREAM: op-207 [Done] (the FIXED asld this wires — dynamic-linked, runs); op-205 finding + op-207 wiring note (preview was on FreeBSD syslogd, asld unwired); op-196 (staged the asl service layer but at FreeBSD syslogd).
- DOWNSTREAM: sharpens asl truly-green (li-1004/id-011) — asl is now the LIVE logger, not just client-lib + reclaim. Feeds the dogfood installer (op-209 dist sets must carry this wiring) + the op-185 ASL plane semantics (the preview wants asld specifically). aslmanager reclaim (op-198 v5) runs against the store asld now owns.
- feedback: build_is_implementer, launchd plist fidelity (macOS-faithful keys), no_conflate_gating_with_readiness (wired≠logging), artifact_identity_needs_content_check (FIXED asld, not static), agent_host_isolation, background_exit_code_hygiene, soak_is_gatekeeper (hand sustained-logger soak to Gatekeeper). project: launchd_no_autoscan (rc.local loads it), 10preview_gate (asl core service), asld_is_preview_logger (this decode).
```
