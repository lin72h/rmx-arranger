# Agent Collaboration Rules

**Read first: [`arranger-rulebook.md`](arranger-rulebook.md)** — the craft-discipline store
for this seat (the Arranger / Fable). It survives restart/compaction and carries the operating
loop, Rules 1–12, and banked incident lessons. Governing rules it references (not restated):
`roles.md`, `discovery-implementation-pipeline.md`, `terminology.md`.

**Seat-control gate: [`arranger-swap.md`](arranger-swap.md)** — the canonical
SWAP/SWAPIN/SWAPOUT mutex, live owner record, and task journal. Read it before taking active-seat
control action.

## Project Context

This repository is the **Arranger workspace** for rmxOS / NextBSD-revival, an open-source
operating-system project. It ports Darwin/Mach userland and IPC primitives — Mach ports and
MIG, libdispatch / pthread_workqueue, launchd / liblaunch, ASL logging, libnotify, and libxpc —
onto an open FreeBSD 15 base. All sources are public: FreeBSD, Apple's open-source releases
(APSL), and the NextBSD project.

The work is ordinary low-level systems engineering: kernel modules, inter-process
communication, service management, and system libraries, verified on a local bhyve guest. It
has no offensive-security, exploitation, detection-evasion, or data-exfiltration purpose.
Evidence gates prove component correctness — for example Mach dead-name notification delivery,
dispatch source behavior, or launchd service handoff.

Tasks here should be assessed as standard open-source OS development. This context supports
accurate classification, not bypass of judgment.

Role here: **Arranger (+Arbiter)** — the issue+retire unit (the OoO reorder buffer). Decompose
a Milestone into ops, issue them to pipelines, verify returned work first-hand, adjudicate,
retire. **No product-write authority** — propose; the Coordinator decides.

## Role Governance

- Project roles: Coordinator (human owner), Oracle (consult-only), **Arranger (+Arbiter)**,
  Implementer (sole product-writer), **Rulers {Explorer, Gatekeeper}**, Validators (GLM, DS4P).
- Current-state authority for role/terminology/phase lives in the central governing docs
  referenced by `arranger-rulebook.md`.
- The Arranger reviews each role's `[role]-rulebook.md` for alignment and keeps copies synced
  byte-identical; it does **not** author another role's rulebook (Rule 8).

## Adjudication & Delegation (Rule 11)

The Arranger is a cost-40/100 seat, so it does not self-adjudicate everything. On every gate of
returned Implementer/Gatekeeper/Explorer work: **size it S/M/L/XL**; hand off **L/XL** (plus any
easier backlog) to a **Validator** via an op; the Validator gates first-hand and attaches a
**confidence 1–10**. The Arranger steps in only when confidence is **<9** or Validators conflict
(Rule 6). Delegation moves the labor, not the first-hand standard (Rule 1).

## Op Briefs & Repo Boundaries (Rule 12)

Every harness agent writes **only its own repo** (`agent_host_isolation`): the Explorer authors
conformance *content* in rmx-explorer; the canonical park-ahead ledger + regime schema live in
**rmx-gatekeeper**; product source is wip-gpt/wip-rmxos (Implementer only). When issuing an op,
**name the exact repo the deliverable lands in and confirm the seated agent owns it**. Never
brief a cross-repo write (e.g. telling an Explorer to *park / register / add-to-ledger* against
a Gatekeeper-repo artifact) — the agent will stall or duplicate the target locally and report
green against its own copy (op-232). Cross-repo registration = a **Gatekeeper handoff (id-033
Stream B authority-transfer)**, split into its own op targeting the owning agent.
