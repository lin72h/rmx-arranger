---
id: op-202
state: dropped
updated: 2026-10-02T13:19Z
legacy-state: Hold
---
# op-202 — Implementer: productionize the op-201 hybrid PID-1 boot (init_path + rc-chainload plist) into the SHIPPED image's real-boot config + close the root-rw remount residual

op-202 | role: **Implementer** (cost-30) | EXU: **wip-gpt / wip-rmxos** | state: **[Hold — PROMOTED TO 1.0-PREVIEW, but this legacy brief is NOT dispatchable. WAITING on op-318's exact PID-1 topology/image/BOM/containment contract, the disposable-image reaper premise, and any warranted op-280 correction before normalization.]** | parent id: id-016 (launchd bootstrap) + id-042 (preview ship gate) | L1i: li-1006 / li-008 | cost: 30 | authored 2026-06-29; scope promoted 2026-07-12 by Coordinator ruling

## COORDINATOR SCOPE PROMOTION — 2026-07-12

The Coordinator requires **launchd to be PID 1 in 1.0-preview**. This supersedes this card's
historical post-preview classification; it does not waive the missing execution contract. op-202
remains held because its old body mixes Implementer staging with guest runtime acceptance and does
not name an exact current-tip base image, component BOM, approved staging helper, or post-incident
containment controls. op-318 must close those facts first. After the evidence-first disposable PID-1
reaper chain is adjudicated, this card is normalized into an Implementer-only production/config/image
stage; Gatekeeper owns runtime acceptance.

## WHY (one line)

op-201 PROVED the hybrid (PID-1 launchd chain-loads /etc/rc) brings base services LIVE on a THROWAWAY image — but the calibration apparatus (loader init_path + the chainload plist) lives only in the disposable copy; the SHIPPED image still boots FreeBSD init(8) as PID 1. Productionize the proven config into the real-boot path AND fix the one residual op-201 left: root never remounted rw (`root_rw=0`, `launchctl: unlink(): Read-only file system`).

## SCOPE / SUBJECT (EDITABLE — rmxOS overlay, CONFIG not product source)

- The SHIPPED preview image's real-boot config (NOT a throwaway): stage `init_path="/sbin/launchd"` (drop `-u`) into the shipped `/boot/loader.conf`, and the `com.rmxos.op201.rc-chainload` plist (ProgramArguments → `/bin/sh /etc/rc`) into the shipped `/etc/launchd.d/`. Mirror op-201's proven apparatus EXACTLY (it booted hybrid-live @ 06d4df6) — do not re-derive.
- launchd does NOT auto-scan /etc/launchd.d (launchd_no_autoscan): confirm FIRST-HAND which dir/set PID-1 launchd actually loads at init on the shipped image (op-201 confirmed it loaded the chainload job — replicate that exact mechanism, don't assume the dir).
- ROOT-RW RESIDUAL: trace why `/etc/rc`'s root-remount (the `root` rc.d / `mountcritlocal` step) did not flip root rw under PID-1 launchd. Likely an rc ordering / fstab / launchd-job-environment interaction, NOT a kernel issue. Fix in CONFIG (fstab/rc ordering/the chainload job's environment) — confirm rw before concluding.

## DELIVERABLES

**D1 — shipped-image hybrid boot config staged + builds into the real image.** init_path + the chainload plist in the SHIPPED image's real-boot config (not a private copy). The image must boot launchd as PID 1 and chain-load /etc/rc on a REAL (non-throwaway) boot. → `OP202_SHIPPED_HYBRID`

**D2 — root remounts rw (close the op-201 residual).** On the productionized boot: `root_rw=1` — root filesystem mounted read-write, first-hand on serial (the write that failed in op-201, `launchctl unlink`, now succeeds). → `OP202_ROOT_RW`

**D3 — base services + bootstrap parity with op-201, on the shipped image.** Re-confirm on the REAL boot (not the throwaway): rc runs to completion, hostname/devd/syslogd/cron/network LIVE, AND a non-launchd child still holds a non-null TASK_BOOTSTRAP_PORT (bl-016 stays runtime-CLOSED on the shipped config, not just the calibration image). getty: bring to LIVE if low-cost, else REPORT residual. → `OP202_SHIPPED_PARITY`

**VERDICT:** `shipped-hybrid-live` (shipped image boots PID-1 launchd + rc-chainload, root rw, base services LIVE, bootstrap non-null on a non-launchd child, first-hand) | `walled` (productionizing needs a SOURCE change to launchd or rc, not just config — REPORT it as a finding, do not apply a product fix). → `OP202_VERDICT` / `OP202_TERMINAL`

## BOUNDARIES
- CONFIG productionization ONLY (loader.conf + a launchd.d plist + fstab/rc ordering) — init_path is a loader tunable, the plist is boot config (userland_port_no_buildinfra_changes). If the hybrid needs a launchd/rc SOURCE edit, that is a FINDING to report, NOT a fix to apply here.
- Build/stage the shipped image (build_is_implementer); stage in wip-gpt owned dir (agent_host_isolation). Do NOT boot-as-PID-1 the shared golden `vm/runs/` images during iteration — iterate on your own copy, then produce the shipped artifact.
- Verify first-hand on a real boot — `root_rw=1` and the bootstrap-port read must FIRE on serial, not be inferred from config presence (no_conflate_gating_with_readiness; present≠live).
- pid1-robustness (crash/reap/shutdown soak) is NOT this op — that's op-203 (Gatekeeper). This op delivers the productionized config + the root-rw fix; the soak is separate (soak_is_gatekeeper).

## MARKERS
```
OP202_SHIPPED_HYBRID   # init_path + rc-chainload plist in the SHIPPED real-boot config; PID-1 launchd chain-loads /etc/rc on a real boot
OP202_ROOT_RW          # root filesystem remounted read-write (root_rw=1), first-hand on serial — closes the op-201 residual
OP202_SHIPPED_PARITY   # rc-complete + base services LIVE + non-launchd child holds non-null TASK_BOOTSTRAP_PORT, on the shipped image
OP202_VERDICT          # shipped-hybrid-live | walled
OP202_TERMINAL
```

## RELATIONS
- UPSTREAM: op-201 [Retired — hybrid-live @ 06d4df6] (proved the hybrid on a throwaway; this productionizes it + closes the root_rw residual); op-200 [Retired] (PID-1 LIVE, /etc/rc DARK under launchd.d-only).
- DOWNSTREAM: op-203 (Gatekeeper pid1-robustness soak) consumes the productionized shipped image. bl-016 stays runtime-CLOSED if D3 re-confirms the non-null bootstrap on the shipped config.
- PEER: this is now preview-gating, but remains sequenced behind op-318 plus the disposable PID-1
  reaper premise/fix decision. Do not infer dispatch from scope promotion.
- feedback: no_conflate_gating_with_readiness (root_rw + bootstrap must FIRE, not config-present), launchd_plist_macos_fidelity, userland_port_no_buildinfra_changes (init_path + plist are config; a source need = finding), build_is_implementer, soak_is_gatekeeper, agent_host_isolation, artifact_identity_needs_content_check. project: launchd_no_autoscan, 10preview_gate (PID-1 is now a required preview property).
```
