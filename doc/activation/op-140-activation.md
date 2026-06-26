# op-140 Activation Record — notifyd-deadlock repro-ACCELERATE (id-025)

- op: op-140
- state: **CLOSED 2026-06-25 — DEFINITIVE NEGATIVE (stochastic).** Arranger-verified first-hand
  (rmx-explorer-2 `explorer-rx2` @ ddb5e3d; leg-4-exact oracle 88 ckpts to t=87m/alloc=49036, delta=-1
  flat, no freeze). 3 faithful re-runs past leg-4's onset, 0 freezes → the deadlock is a non-deterministic
  RACE, not a count/time threshold. Acceleration goal MOOT (no baseline to accelerate). Budget 3/5
  consumed, 2 left UNUSED (low value). Hands the race verdict to op-142 (reshaped — see id-025). Branch
  is LOCAL on `explorer-rx2`, not pushed (per Coordinator); Arranger verified from the working tree.
- role: Explorer (rmx-explorer-2 / explorer-rx2), FREE
- guest: **nxplatform-rx2** (dedicated bhyve guest — power-cycle authorized, see §0)
- parent id: **id-025** (kernel Mach IPC deadlock-on-wait under sustained notifyd churn)
- gates: op-142 (Implementer kernel-debugger fix, cost-30, [Queued]) — do NOT proceed to op-142 until this op delivers an accelerated repro + the count-vs-time verdict.
- authority: this committed record is the GOVERNING spec. If anything here conflicts with an in-band brief, THIS file wins. Commit a copy into `rmx-explorer-2/docs/` on the `explorer-rx2` branch before the first guest attempt.

## Objective (one sentence)

Drive the op-123 leg-4 deadlock — which took **~63 min** of single-client churn to manifest — in **minutes, not an hour**, by raising churn volume, and in doing so determine whether onset is **COUNT-driven** (scales with cumulative IPC operations) or **TIME-driven** (scales with wall-clock), so the Implementer (op-142) attaches the kernel debugger to a repro that fires on demand.

This is a CHEAP gate BEFORE the cost-30 Implementer dive. You are NOT fixing the deadlock. You are making it reproduce fast and characterizing its onset.

## The baseline you are accelerating (source-verified)

`op123-leg4-oracle-slope.log` (Arranger-verified first-hand, sha256=88ab17f7…):
- t=1m→t=63m: balanced churn, `delta=0` every sample; ~550 port alloc+destroy/min, ~3000 msg/min.
- t=63m: `alloc=34822 destroy=34822`.
- t=64m: partial tick then FROZEN identically — `alloc=35004 destroy=35002 delta=2 | dn: req=0 fire=0 | msg: s=193530 r=196197` — repeated byte-for-byte t=64m→t=112m (~48 min).
- bhyve at kill: **0.0% CPU, state IC (blocked/idle) → deadlock-on-wait, not a spin, not a leak.** `delta=2` = 2 ports in-flight at the freeze instant, NOT a growing leak.

The driver that produced this is `build/op123-leg4/notifyd-soak-driver.sh`: a **single** serial client looping `run-as-launchd-job.sh → bs_probe` with no inter-iteration sleep. Cumulative port-alloc at freeze ≈ **34800** after ~63 min ⇒ ~9.7 alloc/sec single-client.

---

## §0 — Dedicated guest (nxplatform-rx2)

- NAME: `nxplatform-rx2` (distinct from the Gatekeeper/other-explorer guests — no bhyvectl name collision).
- golden image (READ-ONLY, never mutate): **`/Users/me/wip-mach/build/op123-leg4/leg4-soak.img`** (6.4G — the ACTUAL staged image leg-4 ran the deadlock on; already ships /sbin/launchd, /bin/launchctl, notifyd, the 6 overlay libs, bs_probe, run-as-launchd-job.sh + notifyd plist). **CORRECTION (2026-06-25, Arranger):** an earlier draft pointed here at `vm/runs/nxplatform-dev.img` — that was WRONG (Gatekeeper op-145 mounted it first-hand: it is a pre-overlay FreeBSD image with NO launchd/launchctl/overlay libs; my "byte-identical size ⇒ same lineage" inference was unsound). Use the leg-4 staged image — it is the proven deadlock substrate, so no launchd/lib staging is needed at all.
- throwaway working copy (per attempt): `/Users/me/wip-mach/build/op140/op140-soak.img` (cp from the golden leg-4 image each attempt).
- **MANDATORY base sanity (the nxplatform-dev trap — verify, don't assume):** after mounting the working copy, confirm `/sbin/launchd`, `/bin/launchctl`, `/usr/sbin/notifyd`, the 6 overlay libs (libnotify/liblaunch/libxpc/libdispatch/libosxsupport/libmach), `/root/bs_probe`, `/root/run-as-launchd-job.sh` all PRESENT before boot. Absent = wrong base, STOP (do not consume an activation).
- launcher: `wip-gpt/scripts/bhyve/run-guest.sh` with
  `NXPLATFORM_VM_NAME=nxplatform-rx2`
  `NXPLATFORM_VM_IMAGE=/Users/me/wip-mach/build/op140/op140-soak.img`
  `NXPLATFORM_VM_VCPUS=2  NXPLATFORM_VM_MEMORY=4G`
  `NXPLATFORM_SERIAL_LOG=<your rmx-explorer-2 findings dir>/op140-serial.log`
- isolation: run-guest.sh adds NO network device (lo0 only in-guest); the guest cannot touch host state. Stage ONLY under your owned dirs (`rmx-explorer-2/…` and `build/op140/`). Host `/tmp` and host-global paths are OFF-LIMITS (agent host-isolation rule). Guest-internal `/tmp` is fine.
- power-cycle: AUTHORIZED. `doas bhyvectl --destroy --vm=nxplatform-rx2` is yours to call (the deadlock makes `shutdown -p` unreachable — see §4).

## §1 — Acceleration technique + the COUNT-vs-TIME disambiguation protocol

PRIMARY lever: **N concurrent churn clients.** The leg-4 driver runs ONE serial loop. Fork N independent `run-as-launchd-job.sh → bs_probe` loops in parallel (background each, `wait` at the end). The oracle is kernel-wide fbt (`mach_msg_*`, `ipc_port_*`, `ipc_mqueue_*`) so it counts ALL clients' IPC automatically — no oracle change needed for counting, only for tick period (§3).

SECONDARY lever (only if N-parallel alone underperforms): the loop already has no sleep; do NOT busy-spin harder per client. If needed, raise N rather than tightening a single client.

DISAMBIGUATION PROTOCOL (the actual deliverable):
- Run at ≥2 parallelism levels, e.g. **N=4** and **N=8** (and optionally N=2 as a bridge to the N=1 baseline).
- For each run, capture from the slope log at the freeze instant: (a) **wall-clock minutes to onset**, (b) **cumulative port alloc at onset** (= the COUNT).
- Verdict:
  - **COUNT-driven** if onset COUNT is roughly invariant across N (e.g. all freeze near ~34800 cumulative alloc) while wall-clock shrinks ∝ 1/N. ⇒ a per-operation resource/wakeup path (table slot, sequence wrap, lost wakeup after K ops). Strongest signal for the Implementer.
  - **TIME-driven** if onset wall-clock is roughly invariant (~63m) regardless of N while COUNT grows ∝ N. ⇒ an aging/timer/GC path. Different debugger anchor.
  - **MIXED** — report the numbers; do not force a verdict.
- Report the (N, minutes, count) triples in a small table. THAT table is the op-140 result.

## §2 — Base image contents + stage list

Because the base IS the proven leg-4 staged image, the harness is ALREADY present (`/sbin/launchd`, `/bin/launchctl`, `/usr/sbin/notifyd`, the 6 overlay libs, `/root/bs_probe`, `/root/run-as-launchd-job.sh` + notifyd plist, and the kldload-able dtrace providers). Staging is therefore an **overwrite of three harness files only** — you do NOT stage launchd, libs, the runner, bs_probe, or the plist (they're already there and proven).

Overwrite onto the working copy via `wip-gpt/scripts/bhyve/image-staging-guard.sh` (`nxplatform_image_guard_attach`/`cleanup`, root = `${mddev}s2a`):
- `/etc/rc.local` ← op140 variant of the in-image `rc.local` (markers renamed `OP140_*`; spawns N parallel clients; `SOAK_DURATION`/tick per §3). **KEEP its explicit `launchctl load` + `start com.apple.notifyd`** — op-145 proved first-hand that `launchd -u` does NOT auto-load `/etc/launchd.d/`; without the explicit load the daemon never starts and you get a false "no repro". The leg-4 rc.local already does this explicit load — preserve it.
- `/root/notifyd-soak-driver.sh` ← op140 variant (N parallel client loops, not one serial loop).
- `/root/notifyd-soak-oracle.d` ← op140 variant (tick periods per §3; counters UNCHANGED — they already sum all clients).
- Leave `/root/run-as-launchd-job.sh`, `/root/…/com.apple.notifyd.plist`, `/root/bs_probe` **UNTOUCHED** (li-005 port-inheritance path — direct bs_probe from shell gets port 0; route through the runner; changing the transport would change the experiment).
- Overwrite sanity (fail-closed): after writing, re-assert the three files updated + `root/bs_probe`, `root/run-as-launchd-job.sh`, `usr/sbin/notifyd`, `sbin/launchd`, `bin/launchctl` all present before detach. Any absent ⇒ setup FAIL, attempt NOT consumed.

Keep the runner path EXACTLY as leg-4 — the deadlock is in the kernel IPC substrate exercised by that path.

## §3 — SOAK_DURATION + oracle tick periods

- `SOAK_DURATION` ceiling = **1800s** (30 min). With N=4 at ~63m/N≈16m expected onset, and N=8 at ~8m, 1800s is a generous backstop; you should freeze well inside it. Do NOT set a 2h duration — this is an accelerated probe, not a soak (hours-scale soaks are overnight-batch Gatekeeper territory, not this op).
- Oracle slope tick: **tick-15s** (not tick-60s). At N=8 you may freeze in ~8 min; 15s slope gives ~32 checkpoints before onset to pin the freeze tick precisely and read cumulative count at onset.
- Oracle final/self-terminate tick: **tick-1800s** (must equal `SOAK_DURATION`). Change BOTH the `tick-60s`→`tick-15s` slope probe and the `tick-7200s`→`tick-1800s` final probe in the .d file (the op-104 lesson: tick is self-terminating, FreeBSD dtrace won't fire END on SIGINT).
- On a real freeze, the slope log goes byte-identical and the final tick NEVER fires (the guest is blocked) — that is expected; the host watchdog (§4) ends the attempt.

## §4 — Freeze detection / watchdog / force-destroy

`shutdown -p` is UNREACHABLE on a deadlock (the guest is blocked at 0% CPU) — so termination MUST be host-side. Run a host watchdog alongside `run-guest.sh`:
- Tail the serial/slope log: if the slope line is **byte-identical for ≥3 consecutive 15s ticks** (≈45s flat) OR bhyve shows **~0.0% CPU for ≥120s**, declare freeze.
- On freeze: FIRST capture evidence — record bhyve CPU% and process state (the leg-4 freeze was 0.0% CPU / state IC). Snapshot the last live slope line (the onset COUNT). THEN `doas bhyvectl --destroy --vm=nxplatform-rx2`.
- Absolute backstop: if neither freeze nor clean END by `SOAK_DURATION + 120s` (= 1920s), force-destroy anyway and mark the attempt inconclusive.
- run-guest.sh already destroys `nxplatform-rx2` on entry + traps EXIT/INT/TERM — but DO NOT rely on the trap for the freeze case; the explicit watchdog destroy is the path that captures the state snapshot first.

## §5 — Attempt budget

- **5 guest activations** total for op-140.
- Accounting (Explorer doctrine): a setup/stage failure BEFORE any `OP140_*` marker emits = NOT consumed. Any run that emits markers (reaches the churn) = consumed, freeze-or-not.
- Preflight (does NOT consume budget): `run-guest.sh --dry-run`, then the `--build-only`/`--stage-only` fail-closed preflight, then request greenlight for the first real activation.
- Suggested spend: 1× N=4, 1× N=8 (the two-point disambiguation), leaving 3 for a re-run, an N=2 bridge point, or a parallelism bump if N=8 under-accelerates.

## §6 — Success markers

op-140 SUCCEEDS when:
1. The leg-4 freeze SIGNATURE is reproduced — slope goes flat byte-identical, bhyve 0.0% CPU / state IC — at **≥2 parallelism levels**.
2. For each level you captured **(N, wall-clock minutes to onset, cumulative port-alloc at onset)**.
3. You deliver the **COUNT-vs-TIME verdict** (§1) backed by those triples.
rc.local markers: `OP140_START` / `OP140_LAUNCHD_UP` / `OP140_NOTIFYD_UP` / `OP140_PRECONDITION` / `OP140_SOAK_BEGIN` (+ client count) / freeze (no `OP140_SOAK_END` on a real hang — that absence IS the positive signal here).
PARTIAL/INCONCLUSIVE (still report): freeze reproduces but onset doesn't separate count-vs-time cleanly (MIXED) — hand the Implementer the raw triples anyway; a fast repro alone is still progress over ~63m.

## §7 — Push policy

- Work on the `explorer-rx2` branch in `rmx-explorer-2`. Commit findings (serial logs, slope logs, the op140 stage/driver/oracle scripts, the result table) there.
- Do NOT push to main. Do NOT commit any core dump or multi-hundred-MB artifact (logs + scripts + the result table only).
- Report the commit SHA in your REPORT block for Arranger first-hand verify → Coordinator merge.
- The throwaway `build/op140/op140-soak.img` is NOT committed (6.4G, regenerable from golden).

## Carrier chain (id-025)

op-140 (this — Explorer repro-accelerate, FREE) → **op-142** (Implementer kernel-debugger fix, cost-30, [Queued] pending this verdict) → Gatekeeper leg-4 re-run (hours-scale → overnight batch) → notify 4/4 truly-green (id-010).
