---
id: op-581
state: draft
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-047
needs: op-567
authority: 1 test boot (+1 spare only for a boot that stops before its commands run) of op-567's retained fixed RELEASE pair; 10-minute cap; doas vmm.ko, bhyve; push rmx-gatekeeper1 main
expected: 1h
updated: 2026-10-09T00:27Z
---
# op-581 — Gatekeeper 1: finish op-567 — one RELEASE test boot of the retained fixed pair with the corrected plan

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch), in a disposable bhyve VM with no network.

**Expected time: about 1 hour.**

This finishes op-567 (your commit `6380913`). Base RELEASE and KASAN
stopped as expected and fixed KASAN is complete and clean. Fixed
RELEASE is missing only because the first plan left out cleanup calls
and the repeat's working directory; your corrected plan is
host-tested.

1. Check the retained fixed RELEASE pair
   (`build/op567/runtime/rmx-op567-fixed-release-20261008T080339Z-59489/`)
   before booting: root.raw sha256
   `4c1e8fe536ca0bff9d59af3f54000c1fa4b6a84318122f099d25005ed9b8d452`,
   overlay.ufs sha256
   `263a6383442aea0d08e3f0675e658d7ba66fdf8daf8c24f4de7706777cbfe7f5`.
2. Wait until the host's 1-minute load average is below 40
   (`sysctl -n vm.loadavg`, up to 30 minutes; the Implementer may be
   booting too) and record it.
3. One test boot with `build/op567/plans/fixed-release-retry.plan`,
   10-minute cap. Expected: 93/93 PASS, MIG 5/5 PASS, repeat 400/400,
   normal power-off, no panic or assertion lines.
4. A spare boot only if the boot stops before its commands run.
   Otherwise, whatever the result, record it and stop.

Evidence: add the run to `build/op567/findings.md`, the ledger and the
serial hashes; set the disposition; remove the retained pair after
recording its hashes; commit and push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
