---
id: op-448
state: dropped
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-016
gate: self
authority: guest boots: up to 2 on copies of op436-boot-zfs.raw, a 70-minute cap each; doas: load vmm.ko if absent, and the runner's bhyve calls; push rmx-gatekeeper1 main
updated: 2026-10-03T07:12Z
---
# op-448 — Gatekeeper 1: isolate launchd PID-1 memory growth — orphan churn alone, job churn alone, then idle with a calendar job

## Outcome

Context: ordinary engineering on our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source Mach IPC and launchd). Everything runs in disposable bhyve guests with no network.

**Expected time: about 1.5 hours** (setup about 20 minutes reusing your op-445 overlay and
scripts; one boot of about 55 minutes; write-up about 15 minutes).

Your op-445 soak (`c1a55c5`, `build/op445/tables/health.md`) showed PID 1's RSS rising steadily,
about 18 KiB per 30-second sample (4,436 to 6,580 KiB over the hour). It kept 2,160 KiB after the
drain. Find which load causes it, and whether it keeps rising or levels off.

Image (work on copies): `/Users/me/wip-mach/stage/images/op436-boot-zfs.raw`
sha256 `caddd3b35664ed553ee60de0865975953141213cc041d6897e3d2f711eaceb81`.

One boot, phases in order, sampling PID 1's RSS every 30 seconds throughout:
1. Baseline: 3 minutes idle.
2. **Orphan churn only**, at the op-445 rate (about 10 per second), 20 minutes; then 3 minutes idle.
3. **Job churn only**, the op-445 job load, 20 minutes; then 3 minutes idle.
4. **Idle with a calendar job** due every minute and nothing else running, 5 minutes. Record each
   run's lateness. This answers id-060's open question: delivery in an otherwise idle guest.
Then `shutdown -p now`.

For each of phases 2 and 3: the RSS slope (KiB per minute and per event), whether it levels off,
and what remains after its idle period. If one phase shows the growth, say so plainly. Use the
second boot only to finish after a harness fault.

Evidence by path; hash only each boot's raw serial log. Commits on origin.

## Limits

- No product or image edits; overlays on copies only for load and check helpers.

Re-read OPS.md first: defaults and the REPORT block.
