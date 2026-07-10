# op-200 — Explorer: launchd-as-PID-1 RUNTIME calibration (does the inherited pid1 machinery come up live on our FB15/Mach stack?) → the live/dark ledger + the ambient-bootstrap gating read

op-200 | role: **Explorer** (FREE) | EXU: **rx-x64z** (rmx-explorer / rx1) | state: **[Retired — calibration-complete @ 6451c7e; Arranger source-verified, D3 verdict DOWNGRADED CLOSED→closes-by-construction-for-launchd-descendants/runtime-UNPROVEN]** (2026-06-29). **D1 LIVE accepted** (init_path=/sbin/launchd → pid1_magic activates → loads launchd.d → idle stable, no panic). **D2 accepted as the key finding**: PID-1 launchd runs its OWN launchd.d sequence, NOT FreeBSD /etc/rc → FS-remount/net/getty/devd all DARK; root stays read-only. Hybrid path = chain-load /etc/rc as a launchd.d job. **D3 — source insight ACCEPTED, verdict TIGHTENED.** The explorer correctly supersedes op-119/bl-016's misread: the brief's "only launchd_set_bport is the NULL-clear (core.c:6990) → children inherit MACH_PORT_NULL" is WRONG. Verified first-hand: runtime_fork (runtime.c:760-786) does `launchd_set_bport(bsport=jm_port)` BEFORE fork (:761) so the child inherits the job-manager bootstrap, then the PARENT resets its own to NULL (:781); core.c:6990's NULL-clear is deliberate ("We set this explicitly as we start each child"), NOT an inheritance gap. Under PID-1 the per-child bport = root jm_port = system bootstrap → launchd's job-descendants DO get it. BUT this is SOURCE-REASONED, not runtime-observed, and it only reaches rc.d-scripts/login-shells THROUGH the hybrid rc-chain-load job — which D2 itself classes DARK (rc does not run as tested). So bl-016 is **likely-de-architecturalized (mechanical, not kernel/Mach-plane), NOT proven-CLOSED**: the runtime confirm (a non-launchd child showing a non-null bootstrap port) is owed once the hybrid rc-chain-load job exists. Do NOT de-gate parked kernel/Mach work on a source-only "closed" — confirm at runtime first. | parent id: id-016 (launchd bootstrap) + bl-016 (ambient-bootstrap) | L1i: li-008 | cost: free | authored 2026-06-29 (Arranger seat, model Opus 4)

## WHY (one line)

Our launchd INHERITS the full macOS PID-1 machinery (pid1_magic, reaping, single-user, pid1 crash-diagnosis) but runs today as `/sbin/launchd -u` (non-PID-1) with FreeBSD init(8) as PID 1. The code is PRESENT but its behavior AS pid1 on our FB15/Mach-compat stack is UNKNOWN (present ≠ live). Measure ONCE — boot launchd as real PID 1 on a THROWAWAY image — so the "launchd as init" arc is scoped from evidence, and so the gating architectural piece (the op-119 bl-016 ambient-bootstrap gap) is read precisely rather than guessed.

## SCOPE / SUBJECT

- launchd source (READ to understand): `sbin/launchd` @ HEAD `d4a9946`. Inherited pid1 spine already located (take as given): `pid1_magic` self-activates at `getpid()==1` (runtime.c:1518-1519) → `pid1_magic_init()` (launchd.c:211-212); orphan reaping `jobmgr_reap_pid` via SIGCHLD (runtime.c:653); SIGTERM→single-user (runtime.c:133); single-user `-s` (launchd.c:188); PID-1 crash-diagnosis mode (launchd.c:322-489); `-u` = run-as-non-pid1 (launchd.c:189), abort-unless-pid1-or-`-u` (launchd.c:197). Ambient-bootstrap gap (op-119 bl-016): launchd NULL-clears its bootstrap port (core.c:6990); the only `launchd_set_bport` is that NULL-clear; non-launchd children inherit MACH_PORT_NULL → no system-wide bootstrap propagation.
- RUNTIME mechanism: FreeBSD kernel execs PID 1 from the `init_path` loader tunable (default `/sbin/init`). To boot launchd as pid1 = set `init_path="/sbin/launchd"` in the loader on a DISPOSABLE image (boot CONFIG, not a source/infra edit — userland-port principle respected). Drop the `-u`.
- Image: a THROWAWAY copy of a preview image (e.g. a private copy of `vm/runs/op149-preview-uefi-v3.img`) — see BOUNDARIES; booting a half-ready pid1 can wedge/panic the box, so it MUST be disposable.

## DELIVERABLES (DISCOVERY calibration — classify, don't fix)

**D1 — does it boot as PID 1?** Set init_path→/sbin/launchd, boot the throwaway image. Capture SERIAL. Classify: launchd comes up as pid1 / pid1_magic activates / reaches a usable multi-user state — LIVE / PARTIAL / DARK / PANIC, with serial evidence (a pid1 panic is itself a valid finding — capture it, don't improvise around it). → `OP200_PID1_BOOT`

**D2 — per-responsibility pid1 calibration.** For each inherited init duty, classify LIVE / PARTIAL / DARK with branch-fired evidence: orphan REAPING (zombies actually reaped), SINGLE-USER (`-s` / SIGTERM→single-user), SHUTDOWN/REBOOT signaling, CONSOLE/getty (login prompt), and BOOT SEQUENCING — including the key interaction: does launchd-as-pid1 run the FreeBSD `/etc/rc` sequence at all, or does the box come up with NO base services (mounts/network/devd dark)? → `OP200_INIT_RESPONSIBILITIES`

**D3 — the ambient-bootstrap gate (the load-bearing read).** Re-measure the op-119 bl-016 gap UNDER REAL pid1: does launchd-as-pid1 establish a SYSTEM bootstrap (host special ports) and propagate `TASK_BOOTSTRAP_PORT` to NON-launchd children (rc.d scripts, login shells), or do they still inherit MACH_PORT_NULL? This is the gating architectural piece — classify it precisely (closed by pid1 / still-a-gap / partial) with evidence. → `OP200_AMBIENT_BOOTSTRAP`

**D4 — ledger + sequencing recommendation.** {pid1 duty → status → evidence → est. work} + the minimal-competent-pid1 path: hybrid (launchd-as-pid1 chain-loads FreeBSD /etc/rc, base intact) vs full macOS-style (LaunchDaemons replace rc.d, large + crosses the userland-port line). Sequence the ambient-bootstrap fix explicitly as kernel/Mach-plane work (ties to the parked concurrency track + the libxpc MACH_RECV plane, gated behind op-185). Recommendation ONLY — Arranger decodes; author NO fills. → `OP200_LEDGER`

**VERDICT:** `calibration-complete` (boots-or-panics classed + per-duty ledger + ambient-bootstrap read + sequencing) | `walled` (can't even stage the init_path boot — report). → `OP200_VERDICT` / `OP200_TERMINAL`

## BOUNDARIES
- Explorer DISCOVERY — probe + classify + recommend ONLY; author NO fix, edit NO product. "LIVE" = the duty actually FIRED (observable behavior on serial), NOT code-present (the op-188/op-195 discipline; verify_signature_divergence_claims).
- **DISPOSABLE IMAGE ONLY.** Booting a not-yet-competent launchd as pid1 can panic/wedge the box — work on a PRIVATE THROWAWAY COPY in rx-x64z's owned dir; do NOT mutate or boot-as-pid1 the shared golden `vm/runs/` images (agent_host_isolation). A panic is data; capture serial and report, don't try to recover/repair the image.
- init_path is a loader tunable = boot CONFIG, NOT a kernel recompile or FB build-infra edit (userland_port_no_buildinfra_changes). If making it boot needs a SOURCE change, that's a FINDING to report, not a fix to apply.
- Harness = Elixir+Zig+`.d` + serial capture (dtrace_first_debugging); a pid1 userspace-crash bar = proc:::signal-clear / sigexit on the launchd PID, NOT an fbt:: userspace bar (fbt_traces_kernel_only). This is DISCOVERY calibration, not a regression soak (soak_is_gatekeeper).

## MARKERS
```
OP200_PID1_BOOT             # launchd booted via init_path as pid1: comes up / pid1_magic active / usable state — LIVE/PARTIAL/DARK/PANIC + serial
OP200_INIT_RESPONSIBILITIES # reaping/single-user/shutdown/console-getty/boot-sequencing each classed live-dark; FreeBSD /etc/rc interaction characterized
OP200_AMBIENT_BOOTSTRAP     # op-119 bl-016 gap measured under real pid1: system bootstrap propagates to non-launchd children? closed/gap/partial + evidence
OP200_LEDGER                # pid1 live/dark ledger + minimal-competent-pid1 path (hybrid-rc vs LaunchDaemons) + ambient-bootstrap sequenced as Mach-plane work
OP200_VERDICT               # calibration-complete | walled
OP200_TERMINAL
```

## RELATIONS
- UPSTREAM: op-195 [Retired] (launchd live/dark calibration — this extends it to the pid1 dimension); op-119/bl-016 (ambient-bootstrap characterization — the gating gap, re-measured here under REAL pid1 instead of the `-u` probe).
- DOWNSTREAM: **NOT a 1.0-preview gate** — the preview gate is the 4 core services truly-green with launchd HOSTING them, which it does fine as a `-u` daemon. If the "launchd as real init" arc is pursued post-preview, this ledger decodes into (a) pid1-robustness hardening (Gatekeeper soak — pid1 crash = kernel panic, highest bar), (b) the boot-ownership decision (hybrid-rc vs LaunchDaemons), (c) the ambient-bootstrap fix = kernel/Mach-compat-plane work (gated behind op-185 + the parked concurrency track).
- feedback: no_conflate_gating_with_readiness (present≠live; this is a fidelity arc NOT a preview gate — don't let it pre-empt the preview), verify_signature_divergence_claims (branch-fired evidence for each pid1 duty), dtrace_first_debugging, fbt_traces_kernel_only (pid1 crash bar via proc signal-clear), soak_is_gatekeeper (discovery calibration), role_costs (free Explorer off expensive cycles), agent_host_isolation (disposable image, never the golden), userland_port_no_buildinfra_changes (init_path is config). project: mach_rebase (ambient-bootstrap ties to the Mach IPC plane), launchd_no_autoscan.
```
