---
id: op-212
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-212 — Explorer: Mach-IPC-receive convergence probe — is one port-0 receive defect (`ipc_entry_lookup failed on 0` @ ipc_kmsg.c:1318) behind BOTH the asld ASL-native Mach-submit drop (op-210) AND the debt-#21 MACH_RECV dispatch-source servicing (notify/libxpc foundation)?

op-212 | role: **Explorer** (FREE) | EXU: **rmx-explorer** (rx1) | state: **[Done — `independent`, Arranger-verified first-hand @ bdd0fdc].** Pushed 7fb01ab..bdd0fdc. VERDICT `independent` VERIFIED at source: (D2) the ASL-native submit "drop" is a **userspace skip**, not a Mach loss — `asl_core.c:110` `bootstrap_look_up2(bootstrap_port, ASL_SERVICE_NAME, …)` fails when `bootstrap_port==0` → returns `MACH_PORT_NULL` (:111) → `asl.c:1132` guard `if (server_port != MACH_PORT_NULL && eval&EVAL_SEND)` SKIPS the whole block, so the MIG call `_asl_server_message` (asl.c:1163, "send a mach message to syslogd") is never reached, never enters the kernel, never crosses port-0. (D1) `ipc_kmsg.c:1318` printf = benign reject: `ipc_entry_lookup(space, dest_name)==IE_NULL` on a null/stale dest → `MACH_SEND_INVALID_DEST` (own comment :1300) — noisy, not a valid-message loss. (D3 de-link) the MACH_RECV path drains a SELF-allocated port — `xpc_connection.c:90` `mach_port_allocate(mach_task_self(), MACH_PORT_RIGHT_RECEIVE, &xc_local_port)` — bootstrap-independent, so debt-#21 does NOT share this root. NET: the op-210 port-0/`found=0` correlation was a red herring (correctly hedged "unproven"); the asl-native-submit drop is the **id-016 ambient-bootstrap gap** (≡ explorer's "bl-016"; the submit client ran without a `bootstrap_port`), NOT a new asl/Mach defect and NOT debt-#21. CAVEAT: "CLOSED under PID-1 launchd (op-201 bootstrap_port=0x13)" is a MECHANISM-sound PREDICTION (valid bootstrap → lookup succeeds → send proceeds) but NOT yet runtime-proven — the proof is an ASL-native submit from a **launchd-hosted** client landing in the store (no_conflate_gating_with_readiness). Minor line drift in report (asl_core.c:112→:111, xpc_connection.c:73→:90); mechanisms all correct. | parent id: id-010 (notify) + id-011 (asl) + id-021 (libxpc) — a shared-foundation probe | L1i: li-001 (Mach IPC) | cost: free | authored 2026-06-29 (Arranger seat, model Opus 4)

## WHY (one line)

op-210 proved asld is the live logger via the BSD `/var/run/syslog` socket, but the ASL **native Mach submit** path (`asl_log`/aslutil over the `com.apple.system.logger` MachService) returns success yet DROPS the message (`OP210_ASLUTIL_QUERY found=0`), correlated with recurring `ipc_entry_lookup failed on 0 … /usr/src/sys/compat/mach/ipc/ipc_kmsg.c:1318` through the boot. Separately, debt #21 (the libdispatch `DISPATCH_SOURCE_TYPE_MACH_RECV` servicing) is the open foundation question for notifyd + libxpc. BOTH are Mach-message-RECEIVE problems. This probe determines whether ONE port-0 receive defect sits behind both — a convergence that would collapse two open lanes to a single root.

## SCOPE / SUBJECT (READ-ONLY source + consume op-210 evidence — no edits, no build, no boot)

- **The kmsg port-0 failure:** read `sys/compat/mach/ipc/ipc_kmsg.c` around :1318 + the `ipc_entry_lookup` path. What triggers a lookup on port name 0? Is it a benign/ignorable path (e.g. a null reply/voucher slot) or a real message-DROP? Cite file:line; name the caller(s) that pass 0.
- **The ASL-native submit path (asl drop):** trace `asl_log`/`asl_send` → the libasl Mach send → asld receive over `com.apple.system.logger`. Where does a submitted message get lost such that asld returns success but the store stays empty (op-210 `found=0`)? Does it cross the port-0 lookup?
- **The MACH_RECV servicing path (debt #21):** read libdispatch `DISPATCH_SOURCE_TYPE_MACH_RECV` servicing (the dispatch-source mach receive drain) + how it pulls from the port set. Does the SAME `ipc_entry_lookup`/port-0 mechanism gate it?
- **Inputs to CONSUME (don't re-derive):** op-210 final serial (sha `0a97c9bb…`, the port-0 lines + `found=0`); li-007 §"Critical convergence" (one MACH_RECV fix, three consumers); op-205/op-207 asl runtime context. Canonical tree `wip-gpt/wip-rmxos` @ `op-171-x86-64-v3-alpha`.

## DELIVERABLES

**D1 — port-0 failure characterized.** `ipc_entry_lookup failed on 0` @ ipc_kmsg.c:1318: benign-noise | real-drop, with the trigger path + file:line + which caller passes name 0. → `OP212_PORT0_CHARACTERIZED`

**D2 — ASL-submit drop traced.** Where the ASL-native Mach submit is lost (asld returns success, store empty) — file:line, and whether it crosses the port-0 path. → `OP212_ASL_SUBMIT_TRACED`

**D3 — convergence verdict.** Does the same defect bear on the debt-#21 MACH_RECV dispatch-source servicing? `shared-root` (one Mach-receive defect → both ASL-submit drop AND MACH_RECV servicing; fixing it serves asl+notify+libxpc) | `independent` (two unrelated causes; characterize each) | `inconclusive` (what live evidence is needed). REPORT — do NOT fix (Explorer characterizes; the fix is an Implementer op the Arranger scopes after). → `OP212_CONVERGENCE` / `OP212_VERDICT` (`shared-root` | `independent` | `inconclusive`) / `OP212_TERMINAL`

**VERDICT:** `shared-root` (high-leverage: one fix collapses both lanes) | `independent` (two separate fixes, each scoped) | `inconclusive` (names the live repro/evidence the Arranger must commission next).

## BOUNDARIES
- **READ-ONLY, code-reasoned** — source read + consume op-210 serial; no edits, no build (build_is_implementer), no boot, no soak. Stage notes in the rx1 owned dir (agent_host_isolation, NO host /tmp).
- **Cite file:line for every claim** — "benign" vs "real-drop" and "shared-root" are divergence/causation claims; the Arranger adjudicates first-hand before any fix is scoped (verify_signature_divergence_claims — 3× prior false root-cause/divergence history; a `shared-root` overclaim would mis-scope an Implementer dive).
- **Characterize, don't fix** (no_conflate_gating_with_readiness) — name the root + file:line; the fix is a separate Implementer op.
- **Don't assert causation from correlation** — the op-210 port-0/`found=0` correlation is a LEAD, not proof; trace the actual path before declaring `shared-root`.
- Non-contending: does NOT touch the op-185 soak host or any in-flight artifact.

## MARKERS
```
OP212_PORT0_CHARACTERIZED  # ipc_kmsg.c:1318 lookup-on-0: benign | real-drop + trigger path + caller, file:line
OP212_ASL_SUBMIT_TRACED    # where ASL-native Mach submit is lost (success-but-empty), file:line, crosses port-0?
OP212_CONVERGENCE          # does it bear on debt-#21 MACH_RECV servicing? shared-root | independent | inconclusive
OP212_VERDICT              # shared-root | independent | inconclusive
OP212_TERMINAL
```

## RELATIONS
- UPSTREAM: op-210 [Done] (the ASL-submit drop + port-0 evidence), li-007 §critical-convergence (MACH_RECV one-fix-three-consumers), op-205/op-207 (asl runtime), li-001 (Mach IPC).
- DOWNSTREAM: a `shared-root` verdict → ONE Implementer fix serves the asl ASL-submit plane AND notifyd/libxpc MACH_RECV servicing (collapses the two open lanes' foundation); `independent` → two scoped fixes. Either way the FIX is a separate op (Implementer), Arranger-scoped after this characterizes.
- PARALLEL/NON-BLOCKING to op-185 (soak), op-165 (notify), op-198 v5 (asl reclaim) — different EXU (rx1), read-only.
- NOTE: rx1 only. rx2 (rmx-explorer-2) parked-for-cause — do NOT route here.
- feedback: verify_signature_divergence_claims (file:line, Arranger adjudicates; don't overclaim shared-root), no_conflate_gating_with_readiness (characterize not fix), soak_is_gatekeeper (this is discovery, correctly offloaded OFF the Gatekeeper), build_is_implementer (read-only), agent_host_isolation. project: 10preview_gate (asl+notify+libxpc foundation), mach_rebase (li-001 Mach IPC).
```
