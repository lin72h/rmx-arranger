# Now

What matters this milestone, in order. Rewrite this page when the path changes; history lives in
Git and the journal. Op state comes from `tools/rob board`, problem state from `idq/id-000.md`.

## Milestone

**alpha2 regression** on the path to 1.0-preview (`li-1000`, `id-042`).

## Critical path

| # | Step | Owner / repo | Status |
|---|---|---|---|
| 1 | Exact-candidate cold build of `15c185c0` (op-335, build-only) | Implementer / wip-gpt | brief was chat-only; dispatch unknown |
| 2 | Release profile: NFS and Kerberos off in base (op-338, config-only) | Implementer / wip-gpt | brief was chat-only; dispatch unknown; serialize after 1 |
| 3 | Coordinator reviews build evidence by hand | Coordinator | waits on 1 |
| 4 | Accepted containment, then staging | Gatekeeper / rmx-gatekeeper | waits on 3 |
| 5 | Small regression slice: boot/base, Mach IPC, dispatch/workqueue | Gatekeeper / rmx-gatekeeper | waits on 4 |

Decisions in force: j-20260922-001 (this path; the generic preflight checker is off it),
j-20260922-003 (no NFS/Kerberos in base; keep OpenSSH/OpenSSL and filesystem ACLs).

## Open questions for the Coordinator

- Were op-335, op-338, op-323 or op-324 sent, and did anything come back? None has an op file.
  Once answered, record each with `tools/rob new` or re-issue it under a fresh number.

## Off the path (backlog, not live)

Open problems stay in their IDQ files: id-011 (asl leg 4), id-016 (PID-1 launchd; op-322's
staging/reaper contract still needs Validator review), id-021 (libxpc lifecycle), id-033/id-034/
id-037 (conformance pipeline), id-040/id-041 (asl/notifyd), id-012 (release image).
