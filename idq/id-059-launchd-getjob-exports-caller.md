# id-059 — launchd's GetJob exports the caller's job instead of the requested one

- id: **id-059**
- state: **READY — op-426 drafted**
- raised: **2026-10-02 by the Arranger, from op-422 (gatekeeper1 `2db74d1`)**
- parent: id-016; related: id-042

## Problem

`sbin/launchd/ipc.c` has two `LAUNCH_KEY_GETJOB` handlers (alpha2 `2884304b`). The one at line 441
exports the job it found (`job_export(j)`). The one at line 566 finds the requested job `j`, then
exports `ctx->j`, the calling client's job (line 570). `launchctl dump LABEL` therefore reports the
caller, not the named job. In op-422, all 30 requests returned the anonymous `launchctl` job, so no
managed job's `LastExitStatus` could be read.

## Done when

The handler exports the requested job, with a regression test, and the reaper cell can read
per-job status through `GetJob` again.
