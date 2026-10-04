---
id: op-490u
state: draft
cast: unicast
agent: implementer
repo: rmx-implementer
idq: id-046
updated: 2026-10-05T00:00Z
---
# op-490u — Implementer: op-484 resume; ZFS images; drain case out of scope

## Message

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

Resume op-484 (launchd's Mach service handling) in this new session.
Read `AGENTS.md` and `OPS.md` first. Your own records hold the state:
`docs/op484-launchd.md`, `tools/selfcheck/op484*`, and branch
`mach-fixes-5` in `build/op468/source` (commits from `caa8f867` to
`3373d335` on top of `b2d5f5b7`). One of four boots is used.

Two changes to the plan:

1. **Scope.** The message-drain test cases (the ones that need
   `machservice_drain_port` to run) leave this op. Remove them from
   the test program and its registration in one commit; touch nothing
   else in that code. The drain change already committed stays and
   is checked by source review later.
   What remains: the demand-lookup check in `mportset_callback`
   (`b4870d84`), receive rights taken out of their set before
   `launchd_mport_close_recv` closes them, registered or not
   (`9b02aefd` and the fixture commits), the index check in
   `runtime_remove_mport`, and the late dead-name case
   (`do_mach_notify_dead_name` unchanged).
2. **ZFS only.** Stage both images as ZFS-root, not on op364's UFS
   image: start from `/Users/me/wip-mach/stage/images/op417-alpha2-zfs-gpt.raw`
   (alpha2, ZFS) with this branch's kernel, `mach.ko` and libraries,
   reusing the existing world; record the base image and its hash in
   the BOM. Drop the unbooted UFS r5 pair (record its hashes, then
   remove it).

Then: base = `b2d5f5b7` + the remaining tests, fixed = the changes +
the same tests (test files identical). Self-check within the three
remaining boots: the remaining new cases fail on base as recorded
(say which cannot be shown on base and why), all pass on fixed, and
the 65 earlier cases pass on fixed. No push. Then the op record
(each change, its test, base and fixed results, both ZFS image hashes
and BOMs by path, the `selfcheck:` line) and the reply to op-484.
