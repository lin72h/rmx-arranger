# op-192 — Explorer: diagnose the recurring `ipc_entry_lookup failed on 0` mach-IPC console spam surfaced by the op-168 soak — benign null-port path vs a dropped port right

op-192 | role: **Explorer** (FREE) | EXU: **rx-x64z** (rmx-explorer / rx1) | state: **[Done]** — `benign-noise`, adjudicated 2026-06-29 (Arranger, verified first-hand). Pushed `814febf`. CONFIRMED first-hand: canonical `ipc_kmsg.c:1318` = `printf("ipc_entry_lookup failed on %d %s:%d\n", dest_name,…)`, fires when `ipc_entry_lookup(space, dest_name)` returns `IE_NULL` (dest_name=0=`MACH_PORT_NULL`) → `goto invalid_dest` → `MACH_SEND_INVALID_DEST` = CORRECT rejection of a null-dest send (in `ipc_kmsg_copyin_header`). Donor `nx/NextBSD` has the BYTE-IDENTICAL printf at the same line 1318 → donor-inherited diagnostic, NOT rmxOS-local, NOT a defect. Startup burst attributed to procs starting without a bootstrap port (bl-016, launchd-domain — not chased; op-168 ran clean); shutdown burst = teardown sends. DISPOSITION: printf-gate is cosmetic serial-noise only → RESERVED as a cheap rider on the NEXT kernel rebuild, NOT a dedicated cost-30 (role_costs); does not gate preview. PRIOR state: [Awaiting] — released 2026-06-28. | parent id: id-026 | L1i: li-1009 (adoption-gate hygiene) | cost: free | authored 2026-06-28 (Arranger seat, model Opus 4)

## WHY (one line)

op-168's DURABLE serial (sha `30a39d6e…`) shows `ipc_entry_lookup failed on 0 /usr/src/sys/compat/mach/ipc/ipc_kmsg.c:1318` firing repeatedly at "Starting local daemons" AND again during shutdown (signal-15 teardown) — the soak ran 4h clean so it is NON-FATAL, but it is unexplained noise in the **mach IPC core** (the heart of the whole port), and the gatekeeper report omitted it. Settle statically whether it is an expected null-port path (gate the printf) or a symptom of a mishandled port right.

## CONTEXT (take as given)

- Canonical tree: `wip-gpt/wip-rmxos` @ `op-171-x86-64-v3-alpha` (HEAD `bc0ac550`). Donor `nx/NextBSD*` + stock FB-15 read-only.
- The exact site: `sys/compat/mach/ipc/ipc_kmsg.c:1318`, emitting `ipc_entry_lookup failed on 0`. The "on 0" is the lookup ARGUMENT — name/right value `0` (i.e. `MACH_PORT_NULL`).
- Timing: bursts during daemon startup (the `ipc_entry_lookup failed on 0` lines interleave "Starting local daemons:") and at syslogd `exiting on signal 15`. So it correlates with mach-port setup AND teardown.

## DELIVERABLES (read-only; cite file:line for every claim — verify-first, prior false-divergence record)

**Q1 — pin the call site + the message flow.** Read `ipc_kmsg.c:1318` and its enclosing function. Identify EXACTLY what is being looked up (which port-name field of which kmsg, in which translation path — `ipc_kmsg_copyin`/`copyout` of port rights, complex-message descriptor walk, header local/remote port). Name the caller(s) that pass `name==0` and the message that carries a null port there.

**Q2 — is name==0 a legitimately-reachable case?** Determine whether a kmsg with `MACH_PORT_NULL` in that right field is a NORMAL, spec-legal case the code should accept silently (macOS/XNU treats MACH_PORT_NULL as a valid no-port in many descriptor slots) vs a genuine lookup that should have succeeded. Check the donor `nx/NextBSD` `ipc_kmsg.c`: does the donor PRINT here too, or is this printf an rmxOS-local addition? (verify_signature_divergence_claims — read the donor first-hand; do not assert.)

**Q3 — noise or symptom + verdict.** Decide: is line 1318 a diagnostic printf that fires on an expected null-port and should be gated/removed (pure log noise), OR does the `failed` path then DROP/mistranslate a port right (a real defect — name the consumer that loses the right and the user-visible impact)? Use the startup-and-shutdown timing as the discriminator (both are bulk mach-port create/destroy phases).

**VERDICT (one of):**
- `benign-noise` → expected null-port path; recommend gating the printf (hand to an Implementer follow-up; do NOT edit here).
- `real-defect` → a port right is mishandled on the name==0 path → name the consumer + impact + the donor-faithful fix direction.
- `needs-trace` → cannot settle statically → propose a DTrace **fbt** bar on the caller (valid: this IS a kernel symbol, so fbt:: matches — unlike a userspace bar) to capture which right/flow hits name==0 at runtime.

## BOUNDARIES
- READ-ONLY source audit. Do NOT edit, build, or commit. NO printf change here — gating is an Implementer follow-up if Q3 says benign.
- Cite `file:line` for every claim; donor reads are first-hand (`nx/NextBSD` ipc_kmsg.c), not assumed.
- Stage strictly inside rx-x64z's owned dir; no host-global paths (agent_host_isolation).

## MARKERS
```
OP192_CALL_SITE      # ipc_kmsg.c:1318 enclosing fn + what's looked up + which kmsg path/right field (file:line)
OP192_NAME0_CASE     # is name==0 (MACH_PORT_NULL) spec-legal here? donor prints too y/n (donor file:line)
OP192_NOISE_OR_SYM   # diagnostic-printf-on-expected-null vs a dropped/mistranslated port right (named consumer)
OP192_VERDICT        # benign-noise | real-defect | needs-trace
OP192_TERMINAL
```

## RELATIONS
- UPSTREAM: op-168 (the soak whose durable serial surfaced this; sha `30a39d6e…`).
- DOWNSTREAM (RESERVED): if `benign-noise` → tiny Implementer printf-gate op; if `real-defect` → a mach-IPC fix op; if `needs-trace` → a DTrace fbt capture.
- feedback: verify_signature_divergence_claims (read donor ipc_kmsg.c first-hand before calling it rmxOS-local), role_costs (free Explorer diagnosis off the gatekeeper finding), fbt_traces_kernel_only (an fbt bar IS valid here — kernel symbol), build_is_implementer (no edit/printf change in this op), agent_host_isolation.
```
