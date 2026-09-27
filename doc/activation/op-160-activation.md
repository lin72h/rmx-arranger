---
id: op-160
state: dropped
updated: 2026-09-27T22:54Z
legacy-state: READY
reset: j-20260927-004
---
# op-160 — Implementer: bring the xpc_domain ↔ xpc_connection SERVICE PLANE live end-to-end over nvlist, launchd-hosted (li-1005 + li-1006 joint long pole)

op-160 | role: **Implementer** (cost-30) | state: READY dispatch (authorized — Coordinator "finish launchd+libxpc together") | parent ids: id-021 (libxpc/li-1005/li-007) + id-016 (launchd bootstrap/li-1006/li-008) | authored 2026-06-26 (Arranger seat, model Opus 4)
assignment rationale: product-source build work on the interconnected service plane = Implementer-exclusive. Runs IN PARALLEL with the overnight id-025 reachability soaks (op-155 ∥ op-159, free roles) — the Implementer cycle would otherwise idle while notify leg-4 soaks. These are the two open preview long poles; they share ONE fabric (the xpc_domain plane over nvlist), so they finish together in one branch, not split.

WHY ONE OP / THE INTERCONNECTION (verified first-hand against li-1000 + id-021 + id-016):
- libxpc two-plane (Arranger first-hand 2026-06-24): control plane (launchctl→launchd) = liblaunch/Mach/MIG, NOT XPC. **Service plane (launchd xpc_domain hosting ↔ app xpc_connection) = libxpc/nvlist = THE long pole.** That service plane is exactly li-1006's open "xpc_domain plane live over nvlist" AND li-1005's "Mach transport send/reply/cancel/error." Same fabric. Building either alone strands the other.
- Service-plane clients reach the domain via `bootstrap_look_up` (xpc_connection.c:121) → **id-016 applies**: bootstrap is ambient ONLY for launchd children. Validation MUST use the launchd-job run-model.

DELIVERABLE 1 — CALIBRATE FIRST (the id-021 "live-or-stubbed?" question; do this BEFORE gap-fill, report it):
- By inspection + a built-and-run minimal end-to-end attempt, determine the ACTUAL runtime state of the xpc_domain service path over nvlist: is it LIVE end-to-end (launchd hosts a domain, a client `xpc_connection` send gets a reply over the nvlist wire), partially live, or stubbed at a specific seam? Name the exact first broken seam with file:line.
- This calibration sets the gap-fill scope. Do NOT pre-commit to "build the whole plane" if it's mostly live, nor assume gaps are small if it's stubbed. Report calibration as the gate-0 deliverable.

DELIVERABLE 2 — MAKE THE PLANE LIVE (minimal set the end-to-end path requires, NO more):
- launchd side (li-1006): launchd hosts an `xpc_domain` and registers it so a launchd-job client resolves it via `bootstrap_look_up`. The domain accepts a connection, routes messages over nvlist.
- libxpc side (li-1005): `xpc_connection` create → connect → **send → reply → cancel → error** all function over the nvlist Mach transport. Fill ONLY the Class-C stubs / Class-B zero-impls the end-to-end path actually traverses — known critical-path suspects from the census: `xpc_connection_cancel` (empty), `xpc_endpoint_create` (empty/no-return), `xpc_main` (no-op), `XPC_ERROR_*` delivery (absent), `xpc_object` typed get/set on the path. Confirm against the calibration's named seam.
- Bar = **behavior-only nvlist round-trip** (NOT byte-for-byte wire — that depth bar is deferred per id-021 decisions). serializer = nvlist, LOCKED (no mpack).

EXPLICITLY DEFERRED — catalog as li-1008 known-gaps, do NOT build in this op (scope discipline; these are NOT the preview service-plane spine):
- Class-D whole missing API generation: `xpc_session_*` (×16), `xpc_listener_*` (×10), `rich_error`, `peer_requirement`, `connection_activate` — our tree is legacy `xpc_connection`/`resume`; the modern session/listener generation is a post-preview swift-rmxOS plan.
- `xpc_activity_*` subsystem (header-only), `xpc_shmem_*`, `xpc_fd_*`, typed dict get/set beyond the plane's need.
- launchd-as-PID1 / ambient shell bootstrap (id-016 decision (a), full-1.0). Preview stays launchd-job model.

VALIDATION MODEL (mandatory — id-016, the op-127 lesson):
- Demonstrate the plane via a **launchd-JOB client** (`launchctl load` a plist), NOT a shell-launched binary. A shell-launched client gets `TASK_BOOTSTRAP_PORT=0` and cannot reach the domain — that path is OUT of scope and is a known cataloged gap, not a bug to chase.

BUILD (Implementer owns; verify exit codes first-hand — a task "exit 0" is a claim):
- Clean `buildworld` (libxpc + launchd) + image as needed. Report built-artifact paths + SHAs, exit codes tailed from the log + artifacts checked. If the known current-tree walls (the op-156 trio: libc_nonshared `__iconv_bool`, kpilite `thread_lite`, dtrace `systrace_freebsd32`) block, report them as pre-existing and scope a path around them — do NOT silently mark BUILD_CLEAN over a partial build (the op-156 marker lesson).

PROOF BOUNDARY (Implementer does NOT self-prove conformance):
- Implementer delivers: calibration report, the live plane (diff on the Implementer branch), the launchd-job end-to-end demo + log, build evidence. 
- Conformance gating is NOT this op: the dual-explorer lockstep run (op-122, RESERVED/held) diffs the pinned blob rx-x64z vs mx-a64z; the integration soak (li-1007) is Gatekeeper. Those gate truly-green. This op makes the plane EXIST and WORK end-to-end; it does not self-certify parity.

ORDERING NOTE (surfaced for the Coordinator, not a block): this opens libxpc impl while asl conformance legs 2-4 (free-role) and notify leg-4 no-hang soak (id-025) are still open. That's fine — different roles/pipelines, no Implementer contention — but li-1000 retirement still needs all four services truly-green + the integration soak (li-1007). The plane being live ≠ preview-ready; it's the impl prerequisite.

MARKERS:
```
OP160_PLANE_CALIBRATED status=0        # live|partial|stubbed verdict, first broken seam file:line
OP160_LAUNCHD_DOMAIN_HOSTS status=0    # launchd hosts xpc_domain; launchd-job client resolves it via bootstrap_look_up
OP160_XPC_SENDREPLY status=0           # xpc_connection send→reply over nvlist transport works end-to-end
OP160_XPC_CANCEL_ERROR status=0        # cancel + XPC_ERROR_* delivery function (Class-C critical-path stubs filled)
OP160_E2E_LAUNCHD_JOB status=0         # full demo via launchctl-load client (NOT shell-launch); log captured
OP160_BUILD_CLEAN status=0            # buildworld libxpc+launchd green; artifact paths + SHAs; walls reported honestly
OP160_DEFERRALS_CATALOGED status=0     # Class-D / activity / shmem / fd entries written to li-1008 IDQ, not built
OP160_TERMINAL status=0
```

PUSH: Implementer branch; commit the calibration report, the plane diff (launchd + libxpc), the launchd-job e2e demo + log, build evidence. Report SHA + artifact paths → Arranger-seat first-hand verify → then op-122 dual-explorer conformance (un-hold) + li-1007 integration soak (Gatekeeper) gate truly-green. Do NOT merge to mainline pre-verification. PUSH to origin.

CHAIN (preview long poles): op-160 (this — service plane live, launchd+libxpc joint) → op-122 dual-explorer lockstep conformance (un-held) ∥ Gatekeeper soak → li-1005 + li-1006 truly-green → with li-1003/notify (post id-025) + li-1004/asl → li-1007 integration soak → li-1000 1.0-preview.

---

## ARRANGER-SEAT VERDICT (2026-06-26, model Opus 4) — op-160 PASS: service plane LIVE e2e over nvlist (launchd-job), honestly scoped → [Done] (NOT merged, NOT conformance-certified)

Verified first-hand against branch `op-160-xpc-domain-plane` @ af0dc2d (parent 15a6acc — correct) + the run artifacts. NOT relayed from the Implementer's report.

**PLANE IS LIVE — e2e proven (serial SHA 99d7821…, hashed by me):** launchd (pid 968) hosts the service via MachServices → listener (pid 974) → **launchd-JOB client (pid 983, launchctl-loaded NOT shell-launched)** connects → `OP160_XPC_SENDREPLY reply=pong sequence=160` (service: op=ping→SERVICE_REPLY, seqid correlated over nvlist) → `OP160_CLIENT_EVENT description="Connection invalid"` (cancel→error delivered). id-016 launchd-job model honored.

**Code is real impl, not paper-stubs (git show af0dc2d, 4 product files +489/-31):** `xpc_connection_cancel` (was empty `{ }`) now builds+delivers an `_XPC_TYPE_ERROR` via new `xpc_connection_error()` — the Class-C error-delivery the brief named absent; `xpc_dictionary_create_reply` now propagates `XPC_SEQID` (reply correlation, the load-bearing fix); `xpc_pack` fixes a memcpy-into-uninitialized-buf bug + nvlist leak; `xpc_unpack` adds recursive `_XPC_FROM_WIRE` marking; `xpc_dictionary_copy_mach_send` un-`#if-0`'d; nv2xpc UUID missing `break` fixed; retain/release across async send (UAF fix).

**CALIBRATION (Deliverable-1) = PARTIAL, first broken seam named:** plane was live through bootstrap+receive, stubbed at `xpc_dictionary_create_reply()` returning NULL because the unpacked request wasn't marked `_XPC_FROM_WIRE`. PLUS the architectural finding: the **literal launchd `xpc_domain` MIG subsystem is dormant** (`sbin/launchd/runtime.c` under `#ifdef notyet`, no generated MIG); the reachable plane is **MachServices-hosted `xpc_connection`/nvlist**, NOT a MIG xpc_domain. Consistent with the id-021 two-plane finding.

**MARKER DISPOSITION (Implementer disclaimed authority — these are mine):**
- OP160_PLANE_CALIBRATED → PASS (partial; seam = create_reply/`_XPC_FROM_WIRE`, file-cited)
- OP160_LAUNCHD_DOMAIN_HOSTS → PASS **with nuance** — MachService-hosted service plane, NOT literal xpc_domain MIG. li-1006 truly-green must be framed "service plane live via MachServices+nvlist," NOT "xpc_domain MIG live."
- OP160_XPC_SENDREPLY → PASS (pong/seq=160, real nvlist round-trip)
- OP160_XPC_CANCEL_ERROR → PASS (Connection-invalid error delivered)
- OP160_E2E_LAUNCHD_JOB → PASS (launchd-job client, id-016 honored)
- OP160_BUILD_CLEAN → **PASS-COMPONENT ONLY** — `make -C lib/libxpc` + `make -C sbin/launchd` clean (logs tailed + libxpc.so.5 SHA a4e6bf91… hashed by me). **NO full buildworld/image** — explicitly disclaimed (op-156 BUILD_CLEAN-over-claim lesson applied correctly). The op-156 trio walls still block a clean preview image; the smoke ran components dropped into an existing image.
- OP160_DEFERRALS_CATALOGED → PASS (li-1008 written; matches op-161's confirmed deferral line)
- OP160_TERMINAL → PASS

**DO-NOT-CONFLATE (readiness discipline):** plane-LIVE ≠ li-1005/li-1006 truly-green ≠ preview-ready. op-160 makes the plane EXIST + WORK e2e; it does NOT self-certify parity. Residual to truly-green: (1) op-122 dual-explorer lockstep conformance (UN-HOLD now) — pinned blob rx-x64z vs mx-a64z over the live plane; (2) li-1007 integration soak (Gatekeeper); (3) a clean full-buildworld preview image (op-156 walls). 

**op-160 → [Done]** (Implementer deliverable complete + honest). Branch stays on origin, **NOT merged** pre-conformance. Standing diagnostic surfaced: `ipc_entry_lookup failed on 0` (ipc_kmsg.c:1318) ×16 in the boot — pre-existing mach-compat noise (also in op-153), non-fatal, candidate for a low-priority catalog id, not gating.
