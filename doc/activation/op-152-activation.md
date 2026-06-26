# op-152 — Explorer: author + run the asl leg-2 TRACED functional matrix (id-011 leg-2 of 4)

op-152 | role: Explorer — **rmx-explorer / `explorer-rx` (rx1)** when free | state: **HELD 2026-06-26 — un-assigned from rx2 (rx2 OUT of roster); re-home to rx1 after the id-025 line, or whenever asl depth-first resumes** | parent id: id-011 | L1i: li-002/li-003 | authored 2026-06-26 (Fable)
assignment rationale: ORIGINALLY rx2 (rmx-explorer-2); rx2 was removed from the roster 2026-06-26 (under-onboarded, miscalibrated — see roster memory). rx2 only reached PLAN stage (no artifacts authored yet), so nothing is lost. asl leg-2 is **non-preview-critical breadth** (id-011 NB) → do NOT pull rx1 off the id-025 critical path (op-151) for it; HOLD until rx1 frees. The drafted plan rx2 produced was substantively sound (Fable-verified: harness blob 34775198 + op-099 anchor real) and may serve as a reference for the eventual runner. No OS build needed (op-146 binaries staged), so NO Implementer dependency.

OBJECTIVE: author and run the asl **leg-2 (TRACED functional matrix)** on rx-x64z — re-exercise the 9-case
asl matrix, but with cross-layer TRACING that PROVES each operation actually traverses the real path
(asl client → Mach IPC → asld → on-disk store → asl_search read-back), not just returns PASS at the API
boundary. This is the leg-3 conformance-MATCH's evidence-grade complement: leg-3 proved rx≡mx on results;
leg-2 proves the results are produced by genuinely traversing the daemon + store, traced (fbt, not
exit-code-only). Explorer AUTHORS the traced-matrix artifact; a Gatekeeper validates later (separate op).

LEG CONTEXT (id-011, 4 legs to truly-green): leg-1 lifecycle GREEN-VALIDATED (op-146); leg-3 conformance
MATCH 9/9 GREEN; **leg-2 traced matrix = THIS**; leg-4 hours-scale soak RESERVED (Gatekeeper, after leg-2).

BASE + STAGING (proven substrate — never infer from size; the op-145 trap):
- base image **`build/op123-leg4/leg4-soak.img`** (op-108 base + leg-4 overlay). NOT `nxplatform-dev.img`
  (pre-overlay FreeBSD, same 6476638720 size, no launchd/overlay libs).
- mandatory base sanity (BLOCKING, pre-boot): `/sbin/launchd`, `/bin/launchctl`, `libsys.so.7` present on
  the mounted image. Abort on miss.
- product under test: the op-144-fixed `asld` (161,120 B) + `libasl.so.1` (219,688 B) already staged for
  op-146 — reuse them, do NOT rebuild (builds are Implementer-only; if a binary is genuinely missing,
  request it from the Implementer, do NOT build it yourself).
- launchd runs `-u`, does NOT auto-load `/etc/launchd.d/` → explicit `launchctl load` + `start
  com.apple.syslogd`.
- HOST ISOLATION: run rx2's OWN guest instance (rx2 guest name + staging); not rx1/op-140 guests. Stage only
  in rx2's owned dir.

DAEMON-IDENTITY (BLOCKING carry-forward from op-124, do NOT skip): base FreeBSD also ships
`/usr/sbin/syslogd` and rc may start one at boot. Confirm FIRST-HAND the daemon under test is the **Apple
asld** (answers `com.apple.system.logger` Mach bootstrap; overlay provenance) and no base syslogd confounds
the match — else the matrix traces the wrong daemon and paper-greens.

METHOD (op-147m — this IS a live-system trace op, so the pillar fully applies):
- **Elixir = orchestration**: drives the matrix sequencing (launchctl load/start; issue each asl case;
  capture the ledger). Replaces any shell driver.
- **Zig = metal assertion**: the API-boundary results per case (the 9 cases) + the store read-back assertion.
- **DTrace `.d` = the TRACE layer (the leg-2 deliverable)**: cross-layer correlation anchored on the op-099
  mach-ipc fbt library — assert each logged message actually traverses Mach IPC to asld (send/recv balance,
  no leaked ports) AND lands as an on-disk **store write** (the filesystem dimension id-011 calls out), AND
  asl_search reads it back from the store. Load providers individually (`opensolaris dtrace fbt fasttrap
  systrace`), NOT `dtraceall`.
- id-024 regression bar (USE THE CORRECTED FORM — my op-146 brief-defect): DROP `fbt::dl_init_phdr_info`
  (userspace rtld symbol, un-observable by kernel fbt). Use `fbt::sigexit` / `proc:::signal-clear` keyed on
  the asld PID to catch a kernel-side SIGSEGV across the matrix.
- NO big shell `.rc`/`.sh` harness as the evidence artifact (op-124's 250-line `.rc` is the banned
  anti-pattern). Direct CLI ad-hoc + thin glue is fine.

THE 9 CASES (reuse the leg-3 byte-identical harness, blob `34775198…`; do NOT re-author the logic):
asl_open / asl_new / asl_set / asl_log / asl_get_roundtrip / asl_set_filter / asl_log_filtered /
asl_search_roundtrip / asl_close. NB asl_search_roundtrip is the verified shared-FAIL (immediate
write→search within 200ms returns nothing on BOTH platforms — store-propagation latency, NOT a divergence);
leg-2 TRACES that to confirm the store write lands but the within-200ms query races it (i.e. the trace should
SHOW the write hitting disk after the query, evidencing the latency explanation rather than a lost message).

NEW vs leg-3 (what leg-2 must add): leg-3 was result-parity; leg-2 adds (a) the **IPC traversal trace**
(message really goes client→Mach→asld), (b) the **on-disk store write + read-back trace** (the FS
dimension), (c) the no-SIGSEGV trace across the matrix. Optional if cheap: observe one **aslmanager**
rotation/reclaim. Soak (sustained hours-scale volume) is leg-4, NOT this op — keep leg-2 bounded.

VERDICT:
- All 9 cases traced through the real path (IPC + store write/read-back evidenced, not boundary-only) +
  no SIGSEGV + daemon-identity confirmed Apple asld → id-011 leg-2 artifact GREEN (authored); route to a
  Gatekeeper for independent validation (separate op), then leg-4 soak is the last leg.
- A case PASSes at the API boundary but the trace shows it did NOT traverse IPC/store (boundary-faked) →
  that's a finding: report it; do not green leg-2.
- Daemon-identity ambiguous / base syslogd confounds → STOP, resolve identity first.

MARKERS (Elixir-driven, Zig/`.d`-asserted):
```
OP152_BASE_SANITY status=0
OP152_DAEMON_IDENTITY apple_asld=1 base_syslogd_confound=0
OP152_DTRACE_PROVIDERS_LOADED status=0        # individual kldload, not dtraceall
OP152_MATRIX_CASES_TRACED=<n>/9               # traced through the real path, not boundary-only
OP152_IPC_TRAVERSAL status=0                  # op-099 fbt anchor: client→Mach→asld, balanced
OP152_STORE_WRITE_OBSERVED status=0           # the FS dimension: log lands on disk
OP152_STORE_READBACK status=0                 # asl_search reads it back from the store
OP152_NO_SIGSEGV status=0                      # .d sigexit/signal-clear on asld PID
OP152_VERDICT leg2_traced=<0|1>
OP152_TERMINAL status=0
```

PUSH: explorer branch (rx2); commit the Elixir matrix module + Zig probe + `.d` trace script + the run
ledger + the per-case traversal evidence. No multi-GB images/cores. PUSH to origin (op-150/op-148 lesson:
local-only commits aren't fetchable by the validating Gatekeeper). Report SHA → Fable first-hand verify →
Coordinator.

CHAIN (id-011 → asl truly-green): leg-1 lifecycle (op-146, GREEN) + leg-3 MATCH 9/9 (GREEN) → **op-152**
(this: leg-2 traced matrix) → Gatekeeper validates leg-2 → leg-4 hours-scale soak (Gatekeeper) → asl
truly-green = a 1.0-preview core-service gate met.
