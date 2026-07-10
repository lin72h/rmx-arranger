# op-193 — Implementer: build + deliver the libdispatch churn ELF (the one binary the integration-soak harness needs) — the build half carved out of op-188

op-193 | role: **Implementer** (cost-30 build already spent; re-opened for a near-zero PUBLISH step) | EXU: **wip-gpt** | state: **[Done — built + PUBLISHED to shared handoff; WORKLOAD-CLASS caveat carried to op-188]** — publish adjudicated 2026-06-29 (Arranger, on-host verify first-hand: `/Users/me/wip-mach/build/op188-integration-soak/workloads/dispatch-churn-op193`, sha `995eabf…`, size 36128, byte-identical copy, correct FreeBSD amd64 ELF — `OP193_PUBLISHED status=0`, `OP193_VERDICT churn-elf-ready`). op-188's D1 dependency is now SATISFIED. Earlier adjudication (build sound, source-read caveat): BUILD VERIFIED: built `dispatch-churn-op193` (sha `995eabf…`, size 36128, FreeBSD amd64 ELF, not stripped, links canonical libdispatch `f15acd60…` @ HEAD `501a1ef`). **HANDOFF GAP (re-open reason): the ELF landed in wip-gpt's PRIVATE tree `/Users/me/wip-mach/wip-gpt/build/op188-integration-soak/workloads/` — unreachable to op-188 (different EXU; agent_host_isolation).** op-188 reported it "absent"; it is NOT absent, it is mis-staged. ROOT: this brief's handoff clause was self-contradictory ("stage strictly inside wip-gpt's owned dir" AND "publish where op-188 consumes" with no shared path named) — my brief defect, not an Implementer error. FIX (D4 below): PUBLISH the already-built ELF (do NOT rebuild — landed sha MUST stay `995eabf…`) to the shared, Gatekeeper-reachable root `/Users/me/wip-mach/build/op188-integration-soak/workloads/` (drop the `wip-gpt/` prefix — same relative path under the host-shared build root, mirroring how op-184 published its image to `vm/runs/`). **CAVEAT (load-bearing, carried to op-188): the source `harness.c` is the op-102 libdispatch runtime-CONFORMANCE harness, NOT a purpose-built churn loop** — a one-shot PASS/FAIL matrix (each API once: async/sync/apply/once/barrier/group/sem/timer/MACH_RECV → `op102_matrix_fails=N`, then exits), with 1s timer + 1s MACH_RECV waits → wait-dominated, low-rate as churn. The implementer's import-inspection couldn't catch this (a conformance harness imports every dispatch symbol); only reading the source did. **CRITICAL CONFOUND: harness.c:93-116 does per-iteration `mach_port_allocate`→`mach_msg`→`MACH_RECV`→`mach_port_destroy` → the "libdispatch" workload ALSO churns the mach-IPC plane**, which will confound/trip op-104's mach-IPC oracle balance invariants when run concurrently. ROOT: op-186's matrix mislabeled `harness.c` as "churn" and the op-193 brief inherited it (verify-first miss on MY brief, not an Implementer error — they built exactly what was specified). Carved out of op-188 (role-split 2026-06-29). | parent id: id-026 | L1i: li-1007 (integration soak) | authored 2026-06-29 (Arranger seat, model Opus 4)

## WHY (one line)

op-186's readiness matrix: 3 of 4 integration-soak workloads are runnable ELFs (notify op-150, asl op-116, mach-IPC oracle op-104) but **libdispatch churn = NEEDS-BUILD** (source `dispatch-conformance/harness.c`, no binary). That missing binary is the only Implementer-side item blocking the harness; build it once, hand it over.

## SOURCE TREE (canonical only — Coordinator directive)

- **CANONICAL (link the canonical libdispatch — build HERE):** `/Users/me/wip-mach/wip-gpt/wip-rmxos`, branch `op-171-x86-64-v3-alpha` (HEAD advances — verify first-hand; same provenance op-149/op-182/op-191 built from).
- **READ-ONLY refs (never edit):** donor `nx/NextBSD*`; stock `freebsd-src-official-stable-15`.
- **DEPRECATED — do NOT use:** `build/op156-*` snapshots; `build/wip-rmxos-*-obj` caches.

## DELIVERABLES

**D1 — build the libdispatch churn ELF.** Cross-build `dispatch-conformance/harness.c` with `-fblocks -D__APPLE__` against the **canonical** libdispatch → a runnable amd64 ELF for the v3 preview image. Build in wip-gpt's owned dir.

**D2 — prove it's the real workload, not a namesake.** Confirm the binary actually drives `dispatch_async` / thread-workqueue (TWQ) churn per the id-006 design (e.g. it enqueues/drains blocks under load), not a stub that merely links. A quick local exec or symbol/trace check is enough — name the evidence.

**D3 — deliver the file (build_is_implementer).** Report the absolute path + sha256 + size of the ELF, and stage it where the Gatekeeper harness op (re-roled op-188) consumes it. Hand over the BINARY — not a build-procedure doc. Note the link provenance (which libdispatch, which HEAD).

**D4 — PUBLISH to the shared handoff (re-open fix — the ONLY remaining work; do NOT rebuild).** The ELF is already built + identity-verified (sha `995eabf…`) but stranded in wip-gpt's private `wip-gpt/build/…` tree, unreachable to op-188. Publish (copy) the EXISTING binary to the shared, Gatekeeper-reachable root `/Users/me/wip-mach/build/op188-integration-soak/workloads/dispatch-churn-op193`. Content-check on landing: the published file's sha256 MUST equal `995eabf119cca612985fbf4ed498ca437e0db8aa4ef1c93d85570812001a121e` (byte-identical — a copy, not a rebuild; if it differs, STOP and report). Report the final shared path + sha. This is the agreed cross-EXU handoff (mirrors op-184 publishing its image to `vm/runs/`); do not stage anywhere host-global beyond this agreed path.

**VERDICT:** `churn-elf-ready` (ELF builds, drives real dispatch_async/TWQ churn, delivered with path+sha) | `walled` (build/link/blocks failure — report it, do not improvise).

## BOUNDARIES
- Build ONLY this one binary — NO buildworld/buildkernel/image (this is a single-target cross-build).
- Canonical tree only (SOURCE TREE above); link the canonical libdispatch, not a deprecated snapshot/obj cache.
- Deliver the file to the Gatekeeper; do NOT author the orchestrator or run any soak/dry-run — that's the re-roled Gatekeeper op-188 (role-split; harness authoring + dry-run = Gatekeeper).
- BUILD inside wip-gpt's owned dir, but PUBLISH the deliverable to the agreed shared handoff `/Users/me/wip-mach/build/op188-integration-soak/workloads/` so op-188 (a different EXU) can reach it — leaving it ONLY in `wip-gpt/build/…` strands it (the original defect). No host-global paths beyond this agreed handoff (mirrors op-184 → `vm/runs/`).

## MARKERS
```
OP193_CHURN_BUILT     # libdispatch churn ELF cross-built -fblocks -D__APPLE__ vs canonical libdispatch — path
OP193_DRIVES_CHURN    # evidence it drives real dispatch_async/TWQ churn (id-006), not a namesake/stub
OP193_DELIVERED       # abs path + sha256 + size + link provenance (which libdispatch HEAD) for op-188 to consume
OP193_PUBLISHED       # ELF copied to shared /Users/me/wip-mach/build/op188-integration-soak/workloads/ — landed sha==995eabf… (byte-identical copy, NOT a rebuild)
OP193_VERDICT         # churn-elf-ready (built + published to shared handoff) | walled
OP193_TERMINAL
```

## RELATIONS
- UNBLOCKS the re-roled op-188 (Gatekeeper harness: orchestrator + dry-run) — this binary is its missing 4th workload.
- UPSTREAM: op-186 (readiness inventory that flagged libdispatch NEEDS-BUILD).
- DOWNSTREAM: op-188 (Gatekeeper composes this + notify/asl/mach-IPC oracle), then op-185 (the hours-scale li-1007 soak).
- feedback: build_is_implementer (Implementer builds + hands over the FILE), harness_authoring_is_gatekeeper (this is the build half of the split; orchestrator/dry-run is the Gatekeeper half), role_costs (Implementer seat, but a light one-binary build), complete_once (deliver a workload that actually churns so op-188 composes in one pass), agent_host_isolation.
```
