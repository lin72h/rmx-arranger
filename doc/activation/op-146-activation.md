# op-146 — Gatekeeper: validate op-124 asl leg-1 lifecycle

op-146 | role: Gatekeeper — **rmx-gatekeeper**, FREE | state: **DONE/RETIRED 2026-06-25 (Arranger-verified first-hand @ 864a107)** | parent id: id-011 | authored 2026-06-25 (Fable)
OUTCOME (ACCEPT — id-011 asl leg-1 VALIDATED): 7-rung lifecycle PASS, Elixir-driven, metal-probe-asserted.
3 distinct asld PIDs (A=969, B=971, C=fresh-exec), RESTART_ROUNDTRIP status=0, DISTINCT_PIDS=3,
LIFECYCLE_7RUNG=PASS, VERDICT leg1_validated=1, PROBE_TERMINAL fails=0. Serial: no SIGSEGV, no signal-11,
no Fatal-trap, no dl_init_phdr_info crash across the full churn.
**BRIEF-DEFECT (mine, recorded):** my §3/§MARKERS id-024 bar `fbt::dl_init_phdr_info:entry`==0 is
UN-OBSERVABLE — `dl_init_phdr_info` is a **userspace rtld symbol**; kernel fbt traces kernel fns only, so
the probe never matched (not a product fault). Gatekeeper correctly substituted **metal PID-identity
liveness** (3 fresh execs alive + round-tripping across 7 rungs ⇒ the id-024 startup-SIGSEGV path did not
fire) + serial no-crash. ACCEPTED on that substitute: id-024 was a *deterministic* startup crash, so a
live round-tripping exec is strong positive evidence the crash didn't fire. **For legs 2-4 / re-runs: drop
`dl_init_phdr_info`; use `fbt::sigexit`/`proc:::signal-clear` keyed on the asld PID to catch a kernel-side
signal-11** (the direct no-SIGSEGV observation my brief intended but could not get this run).
assignment rationale: the independent validation instance — distinct from `rmx-explorer` (`cf880c6`) where op-124 authored the leg-1 PASS being validated.
method: op-147m — Elixir spine + Zig probe + DTrace `.d`; NO big shell harness (direct CLI ad-hoc fine).
gates: id-011 asl **leg-1 of 4** → truly-green. Explorer authors → Gatekeeper validates; op-124's PASS does
NOT count until an independent Gatekeeper guest-run confirms it. This is validation, NOT a discovery re-run.

PRECONDITION: op-124/op-139/op-143 committed in **rmx-explorer `cf880c6`** (Fable-verified first-hand).
Validate against this SHA, not a working tree.

BASE + STAGING (proven substrate — never infer from size):
- base image **`build/op123-leg4/leg4-soak.img`** (op-108 base + leg-4 overlay). **NOT** `nxplatform-dev.img`
  — that is pre-overlay FreeBSD, no launchd/launchctl/overlay libs, same 6476638720 size (the op-145 trap).
- mandatory base sanity (BLOCKING, pre-boot): confirm `/sbin/launchd`, `/bin/launchctl`, `libsys.so.7`
  present on the mounted image. Abort on miss.
- product under test: op-144-fixed `asld` (161,120 B; 16 NEEDED all shared; libc count=1; zero local auxv
  syms) + `libasl.so.1` (219,688 B) from `build/block-075-alpha-final-obj/.../usr.sbin/asl/`.
- launchd runs `-u`, does NOT auto-load `/etc/launchd.d/` (op-145) → explicit `launchctl load` +
  `start com.apple.syslogd`.

TEST STRATEGY (binding):
- Do NOT reuse op-124's `op124-lifecycle-probe.rc` (250-line `.rc` orchestration + `emit` verdicts +
  `pgrep`/`grep`/`ls` asserts) as the evidence layer — retired anti-pattern.
- **Elixir = orchestration**: scenario module issues `launchctl load/start/remove/reload`, kills the daemon,
  sequences the rungs, captures the ledger (replaces the `.rc` driver).
- **Zig = metal assertion**: PID identity across restart/reload (3 distinct asld PIDs A≠B≠C, not `pgrep`);
  launchd→asld→asl round-trip at observe/restart/reload (not stdout-`grep`).
- **`.d` = observation (id-024 regression bar)**: `fbt::dl_init_phdr_info:entry` fires 0× AND
  `proc:::signal-clear`/`fbt::sigexit` shows no SIGSEGV to asld — observe the *absence*, don't scavenge a
  corefile. Load providers individually (`opensolaris dtrace fbt fasttrap systrace`), NOT `dtraceall`.

VALIDATION MATRIX (7-rung lifecycle; Elixir drives, Zig probe/`.d` returns PASS/FAIL; cross-check op-124 PID seq, NOT its echo log):
| rung | observed assertion | op-124 PID xcheck |
|---|---|---|
| launchd up | launchd exec (`.d` proc) | pid 970 |
| load | job registered, no asld exec | — |
| start | asld exec → pid A | pid 976 |
| observe | asl round-trip Zig probe PASS | live |
| restart | pid A exit + pid B exec; round-trip re-passes | 976→1011 |
| remove | pid B exit, NO respawn | remove |
| reload | pid C exec; round-trip re-passes | 1041 |

PASS conditions: all 7 rungs Elixir-driven in order; 3 distinct asld PIDs (A≠B≠C) from Zig/`.d`; asl
round-trip PASS at observe/restart/reload; **`dl_init_phdr_info:entry` 0× AND no SIGSEGV across the full
churn** (load-bearing — id-024 crash stays eliminated under lifecycle stress, not just first main()).

VERDICT:
- PASS → id-011 asl leg-1 GREEN; reserve/hold legs 2-4 (traced/MATCH/soak) depth-first; op-146 + op-124 → Retired.
- FAIL → capture serial + core; route to Explorer (harness defect) or Implementer (asld regression) per
  signature. Do NOT auto-rollback asld unless a true id-024 regression signature reappears.

MARKERS (Elixir-driven, Zig/`.d`-asserted):
```
OP146_BASE_SANITY status=0
OP146_DTRACE_PROVIDERS_LOADED status=0     # individual kldload, not dtraceall
OP146_LIFECYCLE_7RUNG status=PASS          # Elixir spine; Zig/.d, not echo
OP146_DISTINCT_PIDS=3                       # Zig probe / .d proc trace
OP146_DLINITPHDR_ENTRY_COUNT=0             # .d — the id-024 bar
OP146_NO_SIGSEGV status=0                   # .d signal-clear / sigexit
OP146_VERDICT leg1_validated=1
OP146_TERMINAL status=0
```

RETIREMENT CRITERION (binding, per op-147m): op-146 retires ONLY if (a) the run is Elixir-driven and every
assertion comes from a Zig probe or `.d` (not echo / `pgrep` / stdout-grep / corefile-scavenging), and
(b) no big shell `.rc`/`.sh` harness is committed as the evidence artifact. A PASS produced by a shell
harness is NOT a valid PASS — re-author in Elixir + Zig (+ `.d`).
