# op-226 — Gatekeeper: one-off INVARIANTS soak of the standing li-1002/li-1003 foundation greens on the op-182 MACHDEBUGDEBUG image (run the never-run assert corpus)

op-226 | role: **Gatekeeper** (regression soak) | EXU: **rmx-gatekeeper-rx-x64z** | state: **[Done — li-1002 PASS under INVARIANTS (M2 progress on the SHIP binary); committed 7f11896, Arranger-verified first-hand 2026-07-02]** — 3 carries surfaced (report under-weighted them): (1) MACH_RECV cross-op tension → op-242/C6; (2) ship-binary provenance gap; (3) notify hang UNRESOLVED + syslogd-confounded. See OUTCOME. | parent id: id-000 (op-223 LEG A synthesis, improvement N6) | parent id: id-000 (op-223 LEG A synthesis, improvement N6) | L1i: li-1000 (li-1013 Item 1 / op-225 M2, cheap subset) | cost: gatekeeper-tier (free role; machine-hours) | authored 2026-07-02 (Arranger seat, model Opus 4)

## CARRIES FROM op-234 (Arranger, 2026-07-02) — resolve on this cert-image run
1. **Engine-attribution capture:** the op-227 banner is SILENT by default (`_dispatch_log` init.c:474) — set `LIBDISPATCH_LOG=stderr` at boot to capture it for the regime `evidence_source: init_banner`, or fall back to dtrace of the twq syscalls. (op-234 finding.)
2. **SHA-pin reconciliation (artifact_identity_needs_content_check):** op-234 validated the banner on libdispatch `35dd592a` ("op-182 build, op-227 code present"), NOT op-227's reported `8623f0f4`. On this run — which boots the cert `c14e0904`-lineage MACHDEBUGDEBUG image — record the actual `libdispatch.so.5` sha256 the image carries and confirm it is a banner-validated (op-227-code) binary. Pins which libdispatch ships and closes the op-227 open hygiene item.

## OUTCOME (Arranger adjudication, 2026-07-02, first-hand — `git show --stat 7f11896` + read findings/op226-invariants-soak.txt in full)
**ACCEPTED (real):** li-1002 (dispatch 9-case) PASS ×3 on the MACHDEBUGDEBUG cert image with WITNESS/INVARIANTS armed — **zero KASSERT/WITNESS/DEADLKRES fires anywhere**. This is genuine M2 progress: the standing dispatch greens survive the assert corpus on the SHIP binary. Good positive signal into li-1013 Item 1 / C1.

**Three carries the report summary under-weighted (do NOT let the "clean-ish" summary bury them):**

1. **MACH_RECV cross-op TENSION (feeds op-242/C6) — the highest-value signal here.** findings line 25: `source-MACH_RECV: PASS` in li-1002 on the cert image (libdispatch **ab7a9058**) — while op-241's MACH_RECV probe PANICS the kernel on the alpha (**106f9d7fd160**). Same source *type*, opposite outcome. Strong first-hand evidence the panic is **path/version-specific** (the probe's double-drain / msg_receive_error path), NOT general MACH_RECV breakage. This is a direct lead for op-242's trace and likely **downgrades C6 severity**. Fed to id-036; flagged for relay to the in-flight op-242 seat.

2. **PROVENANCE GAP (not the "closed hygiene item" the report claims).** The sha-pin shows the cert ship binaries — libdispatch **ab7a9058** (pre-op-227, no banner) + mach.ko **9c7706a3** (ipc_pset_port_changed, op-156-patch) — differ from EVERY recent stress-evidence binary: op-235/op-239 layer-1 substrate greens ran on **35dd592a** + **ffc67eda**; op-241 panicked on the alpha **106f9d7fd160**. So the layer-1 stress greens (incl. the 5675145 grant-clamp fix) were **NOT collected on the ship binary**. Whether ab7a9058 even *contains* 5675145 is unverified. The pin closes the op-227 *banner* question (cert image has no banner code) but OPENS a "which fixes does the ship libdispatch actually carry" question. Do not report this as clean closure.

3. **notify HUNG — UNRESOLVED + syslogd-confounded (NOT "just WITNESS overhead").** li-1003 hung 20+ min (findings 36-38). The report's "likely WITNESS overhead on launchd locks" is not accepted as settled: op-165 ran the same driver 2h on this kernel WITHOUT hanging — the difference is build/op226/rc.local now starts **syslogd**, and syslogd is the **DROPPED** logger (asld is the preview logger). So the hang is confounded by a non-preview component and its cause is unknown (benign WITNESS overhead vs real liveness issue vs syslogd-specific lock contention). No KASSERT fired, so no new id — but this is an open question, not a closed one. Cheap disambiguation available: a Gatekeeper notify re-run WITHOUT syslogd (matching the real preview boot).

**Net:** li-1002 accepted as M2 progress + C1-positive; carries 1-3 explicitly not folded into a "clean" verdict.

## CONTEXT (read first)
Open-source OS engineering — an internal regression soak of OUR OWN Mach userland on OUR certified preview image. Not security/vulnerability work, no external target.

## WHY (one line)
op-223 QUALITY caveat 1: the kernel INVARIANTS/asserts have **never actually run** under our green suites (historical soaks booted MACHDEBUG = asserts compiled out). The op-182 preview image is MACHDEBUGDEBUG (INVARIANTS armed via `std.debug`), so the cheapest possible use of the assert corpus we already own is to re-run the existing greens on it — quiet confidence or early truth.

## SCOPE
- **Boot the op-182 MACHDEBUGDEBUG certified image.** Verify the running kernel ident FIRST-HAND (uname / boot log names MACHDEBUGDEBUG + INVARIANTS) — do NOT infer from filename (artifact_identity_needs_content_check).
- **Re-run, unmodified, the STANDING greens:** li-1002 (libdispatch 9-case core) + li-1003 (notify legs 1-3). No new suites — this is a re-host of the existing corpus onto asserts-armed, not new coverage.
- **Watch for:** any KASSERT/INVARIANTS panic, WITNESS lock-order warning, DEADLKRES report during the runs.
- **Regime-label the run (op-225 M1):** kernel ident, mach.ko build flags, libdispatch flags, and per-run engine evidence (dtrace of twq syscalls, or the op-227 banner if it has landed).

## DELIVERABLE
Pass/fail per suite under asserts-armed, with the regime label attached. Any assert fire = a real finding → report (Arranger files an id). Clean = the greens survive the assert corpus, materially strengthening the record.

## BOUNDARIES
- Gatekeeper **soaks, does not fix** — any assert fire is reported, not self-patched.
- **One-off:** this run does NOT by itself make INVARIANTS a standing preview-gate — that is E3 (Coordinator doctrine call). The result *informs* E3; it does not decide it (no_conflate_gating_with_readiness).
- No new kernel build (uses the existing op-182 image). Stage only in the Gatekeeper's own dir (agent_host_isolation).

## RELATIONS
op-223 N6 (source); op-225 M2 (this is the cheap subset — existing greens only, not the full P2 re-host) + M1 (labeling); li-1013 Item 1; li-9003 Item 2 (engine evidence). feedback: soak_is_gatekeeper, artifact_identity_needs_content_check, no_conflate_gating_with_readiness, long_ops_batch_mode (overnight), agent_host_isolation.
