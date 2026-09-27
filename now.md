# Now

What matters this milestone, in order. Rewrite this page when the path changes; history lives in
Git and the journal. Op state comes from `tools/rob board`, problem state from `idq/id-000.md`.

## Milestone

**alpha2 regression** on the path to 1.0-preview (`li-1000`, `id-042`).

## Onboarding (in progress)

The Coordinator is onboarding each role repo directly (j-20260927-007): rename to `rmx-<role>`,
rewrite its instructions for the current workflow, then relay one read-only onboarding op.

| Role | Repo | Status |
|---|---|---|
| Implementer | `rmx-implementer` (was `wip-gpt`) | repo updated (local commits `92a8d92`, `52b1789`); op-361 to relay |
| Gatekeeper | `rmx-gatekeeper` | next |
| Explorer | `rmx-explorer` | pending |
| Oracle | `rmx-oracle` | pending |
| Validators | `wip-glm`, `wip-ds4p`, `rmx-validator3` | pending |

`../wip-gpt` stays a symlink to `rmx-implementer` until no repo references the old path.

## Critical path

Decisions in force: j-20260922-001 (cold build of the exact candidate, manual review, accepted
containment and staging, then a small regression slice; the generic preflight checker is off the
path) and j-20260922-003 (no NFS or Kerberos in base; keep OpenSSH/OpenSSL and filesystem ACLs).

Known from disk (j-20260927-008): ops through op-360 ran from chat between 2026-09-22 and
2026-09-25 and were not recorded here. The alpha2 candidate (`15c185c0`, worktree
`../build/alpha2-stable15-sync-20260921`) carries the op-338/op-340 release profile as three
uncommitted paths. Builds exist under `rmx-implementer/build/` for op-335 through op-358; the
newest is `op358-alpha2-20260925T000042Z`. Their results are not yet established.

| # | Step | Owner | Status |
|---|---|---|---|
| 1 | Re-establish the baseline: candidate state and newest build result, from disk | Implementer (op-361) | draft |
| 2 | Coordinator reviews the build evidence by hand | Coordinator | waits on 1 |
| 3 | Accepted containment, then staging | Gatekeeper | waits on 2 |
| 4 | Small regression slice: boot/base, Mach IPC, dispatch/workqueue | Gatekeeper | waits on 3 |

## Off the path (backlog, not live)

Open problems stay in their IDQ files: id-011 (asl leg 4), id-016 (PID-1 launchd; op-322's
staging/reaper contract still needs Validator review), id-021 (libxpc lifecycle), id-033/id-034/
id-037 (conformance pipeline), id-040/id-041 (asl/notifyd), id-012 (release image).
