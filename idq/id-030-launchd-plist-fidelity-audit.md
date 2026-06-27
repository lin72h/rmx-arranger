# id-030 — launchd/launchctl config interchange: plist-fidelity audit + low-risk macOS alignment (the plist-not-JSON low-hanging fruit)

- id: id-030
- state: **OPEN — proposed bucket-2 (low-risk macOS-fidelity) under li-1011.** Audit-first; scope-in is Coordinator-owned.
- raised: 2026-06-27 (Arranger seat, codifying the Coordinator's release-scoping principle li-1011).
- roadmap parent: **li-1006 / li-008** (launchd core service); governed by **li-1011** (release-scoping principle); exotic-key catalog lands in **li-1008**.
- bucket: **2 — Low-Risk macOS-Fidelity** (the canonical "use plist, NOT JSON" exemplar the Coordinator named).

## The fruit

macOS launchd/launchctl speak **plist** (the LaunchDaemon/LaunchAgent property-list contract). Bringing our
launchd config interchange as close to that plist contract as practical — on the **load-bearing keys** —
is a cheap, bounded, macOS-faithful win that fits the preview's low-hanging-fruit bucket. The
`build/phase08-d15-launchctl-json-hardfail` lineage suggests a JSON interchange path existed in our
launchctl/harness track; the principle says plist is the faithful target.

## Audit-FIRST (do NOT assert a divergence before source-confirming it — feedback_verify_signature_divergence_claims)

This is an **audit-first** id. The premise ("we diverge from plist fidelity") is a *hypothesis to verify*,
not an established fact. Step 1 is to find the truth, THEN fix only the load-bearing divergences.

1. **Census the current interchange** — where does rmxOS launchd/launchctl read job config? Is the on-disk
   contract plist (`com.apple.*.plist`), JSON, or both? Source-confirm against `launchctl.c` / launchd job
   load path + the staged `/etc/launchd.d/*.plist` (op-134 boot-load) + the `phase08-d15-launchctl-json`
   artifacts. Establish: is JSON actually on the load-bearing path, or only a harness/test convenience?
2. **Diff the plist KEY handling vs macOS** on the keys we already honor (Label, ProgramArguments,
   MachServices, KeepAlive, RunAtLoad, …) — which load-bearing keys are faithful, which diverge, which are
   absent. Use the macOS LaunchDaemon plist schema as truth.
3. **Classify** each key/behavior: load-bearing (preview consumers depend on it) vs exotic (catalog).

## Fix shape (only AFTER the audit, only the load-bearing, low-risk subset)

- If JSON is on the load-bearing config path where plist is the faithful contract → align to plist
  (bounded, reversible). If JSON is only a harness convenience → no product change; note it.
- Make the **load-bearing** plist keys macheck-faithful (schema + semantics close to macOS) per
  feedback_launchd_plist_macos_fidelity — WITHOUT chasing exotic keys.
- **Catalog the exotic / deferred keys** as li-1008 known gaps with non-blocking justification.
- Hard boundary: this stays bucket-2 (cheap, low-risk). It must NOT creep into PID-1 launchd (id-016) or
  self-scan (id-023) — if the audit shows the faithful fix REQUIRES those, it is no longer low-hanging →
  re-classify + escalate to the Coordinator rather than absorbing the risk here.

## Why this matters for the preview

- Directly serves li-1011 bucket-2 (the Coordinator's named plist-not-JSON exemplar) — a concrete march
  toward 1.0-preview via cheap fidelity, not feature-chasing.
- launchd is THE service host (li-1006); faithful job-config plist handling is part of "launchd is a solid,
  macOS-faithful service host" without the risk of the deep launchd work (PID-1, xpc_domain plane).

## Relations
- **li-1011** — the release-scoping principle that spawned this (first seeded bucket-2 driver).
- **li-1006 / li-008** (launchd) — the carrier service; its plist job-config is the subject.
- **li-1008** — where exotic/deferred keys get cataloged.
- **id-023** (self-scan) + **id-016** (PID-1) — adjacent launchd gaps; the boundary above keeps id-030 from
  bleeding into them.
- feedback: `launchd_plist_macos_fidelity` (faithful on load-bearing, catalog exotic — the governing rule),
  `verify_signature_divergence_claims` (audit-first, no blind divergence claim).
- **First op when promoted:** a FREE-Explorer audit pass (bucket-2 is cheap → don't burn an Implementer on
  the census; Explorer authors the plist-fidelity diff, Coordinator scopes the fix, only THEN an Implementer
  touches launchd source).
