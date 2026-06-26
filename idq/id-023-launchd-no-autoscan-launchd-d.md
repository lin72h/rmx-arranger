# id-023 — rmxOS launchd does NOT auto-scan `/etc/launchd.d/` at startup (no self-bootstrap of staged daemons)

- id: id-023
- state: **RAISED 2026-06-25 (Arranger, from op-134 GREEN discovery — explorer filed it as "bl-017"; renumbered
  id-023 here because `bl-`→`id-` and id-017 is already buildworld-skip-llvm). Architectural-divergence ledger
  item; cataloged as a li-005 known gap, NON-BLOCKING for the 1.0 preview (the floor is met via a generic
  boot-load). The macOS-faithful fix is a li-008 "get it right" target, depth-first HELD behind notify/asl soak.**
- raised: 2026-06-25.
- roadmap parent: **[l1i/li-008-launchd-core-service.md](../l1i/li-008-launchd-core-service.md)** (launchd as
  service host — self-bootstrapping its daemon directory is part of "get it right"). Cataloged as a known gap
  under li-005.

## The divergence (op-134 first-hand, verified by Arranger)

macOS launchd, as **PID 1**, auto-scans `/System/Library/LaunchDaemons` during bootstrap and starts the
declared daemons. **rmxOS launchd does NOT** — it runs `-u` (non-PID-1; see id-016) and performs no equivalent
scan of `/etc/launchd.d/`. Proven by op-134 run-1: with `com.apple.notifyd.plist` staged in `/etc/launchd.d/`
and launchd started, `launchctl list` came back **empty** and notifyd was inert. `launchctl` references the
path in its binary strings but nothing loads it automatically.

This is the source-invisible kind of fact that only a boot proved — the launchd source does not advertise the
absent scan.

## The mechanism that works now (preview floor, op-134)

A **generic boot-load**: after launchd starts, iterate `/etc/launchd.d/*.plist` and `launchctl load` each;
with `KeepAlive:true` the job starts at load and restarts on exit. This is generic (loads whatever is staged —
notifyd, syslogd, devd), NOT a notifyd-specific test-harness injection — the rmxOS equivalent of macOS's PID-1
auto-scan. op-134 ships it as an `rc.local` (`scripts/op134/op134-coldboot-probe.sh`) on the staged image and
cold-boot-validated notifyd up + notify round-trip GREEN.

## Decision (Arranger recommendation; Coordinator owns the scope call)

Two options surfaced by op-134:
1. **Make launchd auto-scan** `/etc/launchd.d/*.plist` on `-u` startup — macOS-faithful, Implementer change;
   the staged plist alone would then suffice. Entangles with the id-016 PID-1/ambient-bootstrap question.
2. **Accept rc.d boot-load as the rmxOS model** — promote op-134's `rc.local` to a proper `/etc/rc.d/launchd-*`
   script (rc.conf-enabled) that generic-loads after launchd starts. Less invasive; launchd stays
   non-self-bootstrapping.

**Recommendation:** adopt **(2) for the preview** (floor already met; least-intrusive per design philosophy;
does not entangle the id-016 PID-1 work now), with the concrete preview deliverable = promote the `rc.local`
to a real `/etc/rc.d/launchd-*` script (small follow-up, queued — NOT dispatched now under depth-first).
File **(1) launchd self-scan as the li-008 "get it right" destination** ("think like Apple engineers": a real
launchd service host self-bootstraps its daemon directory) — opened only after notify/asl close their
truly-green soak legs. Both meet the preview floor; (1) is the macOS-faithful end state, (2) is the bridge.

## Relations
- **id-016** (no ambient/PID-1 bootstrap) — sibling launchd-architecture gap; option (1) couples to the
  PID-1/ambient question. Both are "launchd is not PID 1 on rmxOS" consequences.
- **id-015** (preview staging model) — op-134 closed id-015's last retirement blocker (cold-boot notify
  reachability without a notifyd-specific prop) via the generic boot-load; the self-scan purity is THIS item.
- **li-008** (launchd core service) — self-scanning is part of the service-host "get it right" plan.
- **li-005** (known gaps cataloged) — this divergence is tracked here as non-blocking for preview.
- carrier op: **op-134 DONE** (`d245948`, Arranger-verified first-hand) — discovered + bridged the gap.
