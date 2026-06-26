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
