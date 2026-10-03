---
id: op-447
state: issued
agent: implementer
repo: rmx-implementer
idq: id-046
gate: self
authority: build: kernel RMXOS-RELEASE, mach.ko, libmach and the Mach tests (no world build); stage base and fixed test images with rmx-stage-image; self-check guests per OPS.md; no push
updated: 2026-10-03T06:39Z
---
# op-447 — Implementer: Mach step 4, part 1 — pins and revalidation, the LARGE and trailer boundary, queued replies and receive waits, N6 (kernel only)

## Outcome

Context: ordinary bug fixing in our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source Mach IPC). Everything runs in disposable bhyve guests with no network.

Start Mach step 4 on a new branch `mach-fixes-4` from `mach-fixes-3@844112f4`. Batch 3's product
code is unchanged since its proof candidate. Its final Gatekeeper proof runs in parallel; if it
finds anything, it comes to you as a separate op.

The plan is advisor2's op-435 note: `/Users/me/wip-mach/rmx-advisor2/op-435-mach-step4-c1-d2-plan.md`
(`42dc8247`). Decisions on it are in
`/Users/me/wip-mach/rmx-arranger/mach-names-step5-deferred.md` § "Step 4 decisions". This op is
**part 1, the kernel work only**: the note's § 4 items 1-3, plus N6.
1. **Lifetime pins and revalidation** (§ 2 "Membership"; § 4 item 1): op-389 #7 and #15, and the
   pset part of op-392 S2.
2. **The common `mach_msg` LARGE and trailer boundary** (§ 2 "Receive boundary"; § 4 item 2).
3. **Queued MIG replies and receive waits** (§ 2 "Queue ownership" and "Waits"; § 4 item 3):
   op-393 N2 and op-392 F5. This removes parking in `ith_kmsg`, which batch 3 now releases at
   thread retirement.
4. **N6:** two concurrent first copyouts of one send right must not create two names
   (`sys/compat/mach/ipc/ipc_object.c:666-695`). Recheck the reverse lookup after the space lock
   is retaken, with candidate rollback (§ 5).
Keep the current kqueue filter and receive ABI working: consumer changes, pure C1 and D2 are part 2.

Each item: the regression test first (`tests/sys/mach` style; Mach behaviour, not fd numbers; prefer
user-visible calls over kernel fixtures), then the fix, as separate commits that each build. For the
races in items 1 and 4, use controlled interleavings where possible; say where a test can only
stress.

**Self-check before returning** (OPS.md § Self-check): base (`mach-fixes-3@844112f4` + the new
tests) shows each new case failing as expected; fixed shows every case PASS, including the 41
earlier ones. Fix and re-run within the op until that holds. Build only the kernel, `mach.ko`,
`libmach` and the tests.

Evidence: the commits; a note mapping each item to its commits, tests and expected results; the
selfcheck counts; both image hashes and BOMs (by path).

## Limits

- No FreeBSD-side changes beyond the five already allowed. If one seems needed, stop and report.
- No libdispatch, launchd or libxpc changes; no pure C1 filter; no D2 (part 2).
- No push of `wip-rmxos`.

Re-read OPS.md first: defaults and the REPORT block.
