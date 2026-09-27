---
id: op-252
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-252 — Explorer-mx (macOS-side recon): map how macOS 27 exposes pthread_workqueue / the kernel-managed thread pool to PUBLIC API and SPI — so we can mimic the seam and save design effort

op-252 | role: **Explorer** (discovery/source-read recon; NO product-write, NO build) | EXU: **mx-a64z (macOS parity explorer)** | state: **[Done — RECON CAPTURED, Arranger-verified first-hand 2026-07-03. Fetched origin/main f8006a3; recon note `findings/mx-a64z/op252-threadpool-governor-seam-recon.md` sha256 221fb872…f7b00 (matches the report); cited symbols confirmed present in the artifact. MIMIC TARGET IDENTIFIED: macOS 27 (XNU 13361, mm4/M4 seat) did NOT replace the pthread_workqueue SPI — it kept the 2017-era SPI as the INTERNAL mechanism (19 `_pthread_workqueue_*` still exported in libsystem_pthread.tbd; our ported baseline matches) and LAYERED a PUBLIC width-sizing face on top: `os_workgroup_parallel_create` + join/leave + `os_workgroup_max_parallel_threads` (workgroup_object.h:329-336, API_AVAILABLE macos(11.0), hardware-aware recommended-concurrency query). Width signal is BIDIRECTIONAL (public max_parallel_threads pull + private add_cooperativethreads/should_narrow push). `os_workgroup_interval` is ORTHOGONAL (scheduling deadlines, NOT width) — not the mimic target. Precedent: Swift concurrency (OS_REFINED_FOR_SWIFT) consumes os_workgroup as a GOVERNOR. Findings are HYPOTHESES (macOS-header cites) — source-verify before any edit (`verify_signature_divergence_claims`). Feeds op-256 (libdispatch pthread_workqueue SPI exposure slice: keep 2017 SPI internal — split out of op-255 on 2026-07-03) + deferred op-251 SCOPE-6 (governor slice: os_workgroup_parallel public shape).]** | parent id: id-000 (post-preview runtime-substrate initiative) | L1i: li-1000 (substrate registry) | cost: 0 (Explorer, free) | authored 2026-07-03 (Arranger seat, model Opus 4)

## CONTEXT (read first)
Open-source OS engineering — a macOS-as-truth **recon** feeding a design consult (op-251). We are designing a kernel-load-informed concurrency governor on OUR OWN ported thread-pool substrate, and want to mimic macOS's public/SPI shape rather than invent one. **NOT security work, no external target, no reverse-engineering of protected binaries** — this is public-header + open-source-XNU + published-docs reading on the macOS seat, the standard parity loop (`project_parity_explorer`). Vocabulary like "override"/"kill"/"pri" is ordinary OS-runtime API naming.

## WHY (one line)
Our tree already carries the 2017-era Darwin `pthread_workqueue` private SPI (`SPI_VERSION 20170201`). macOS has moved on ~8 years; if macOS 27 exposes a cleaner PUBLIC seam for "a runtime declares a cooperating thread set the kernel schedules/sizes as a unit" (strong hypothesis: the **`os_workgroup`** family, `<os/workgroup.h>`), we should mimic THAT rather than extend the old addthreads SPI — saving op-251 from designing a shape Apple already shipped.

## SCOPE — what to map (public headers + open-source XNU/libpthread + published docs on the macOS seat)
1. **The current pthread_workqueue SPI surface** on macOS 27: what remains in `pthread/workqueue_private.h` / `pthread/qos_private.h` (is `_pthread_workqueue_should_narrow`, `_pthread_workqueue_addthreads`, the QoS-override family still the seam?), and the `workq_kernreturn` / thread-request kernel ABI shape as visible in open-source `xnu` (`libpthread`, `kern/kern_workqueue`). Note what is SPI (private-but-present) vs truly internal.
2. **`os_workgroup` / work-interval family** (`<os/workgroup.h>`, `<os/workgroup_interval.h>`, the parallel/audio workgroup APIs): is this the PUBLIC abstraction for "a runtime cooperatively shares a kernel-scheduled thread set"? Capture the create/join/leave/max-parallelism surface, whether it drives core WIDTH (concurrency sizing) or only scheduling INTERVALS/deadlines, and whether a foreign scheduler (not GCD) can adopt it. This is the load-bearing question for op-251 SCOPE-6.
3. **The dynamic-width signal**: does macOS expose to userspace a "recommended concurrency / should-narrow / current parallel width" query, or is width purely kernel-internal (the workqueue calls you up, `should_narrow` hints you down)? Name the exact public/SPI entry points a runtime would poll to size itself to load up to `activecpu`/`hw.ncpu`.
4. **Does any Apple/known runtime already consume this as a governor** (vs executor)? e.g. does anything drive its own thread count from the workqueue/workgroup signal the way we want ERTS to. If a precedent exists, capture the pattern.

## DELIVERABLE
A recon note (staged in the Explorer's own dir, GitHub-synced per the parity loop): the macOS-27 public-API-vs-SPI-vs-internal map for the thread-pool/governor seam, the `os_workgroup` verdict (is it the mimic target — width-sizing vs interval-only), and the exact entry points a foreign runtime would use to size to load. Each finding a **hypothesis** (source/header cited) feeding op-251's design — NOT a product edit, NOT a gating call. If a clean public seam exists ⇒ recommend mimic + cite it; if not ⇒ say so plainly so op-251 designs on our ported SPI.

## BOUNDARIES
- **Discovery/recon ONLY** — no product-write, no build, no harness. Public headers / open-source XNU / published docs; no protected-binary RE.
- **Source/header citations required** (`verify_signature_divergence_claims`): every "macOS 27 exposes X" claim carries the header path + symbol, since it will steer op-251's design.
- Stage in the Explorer's own dir (`agent_host_isolation`); this is the macOS (mx-a64z) seat of the parity loop.
- Feeds op-251; does NOT itself decide the design — supplies the mimic target.

## RELATIONS
op-251 (the Oracle design consult this feeds — SCOPE-6) / `project_parity_explorer` (macOS-as-truth loop, mx-a64z seat) / li-1000. Reference: `nx/apple-opensource-xnu` (open-source XNU cross-check if the macOS seat lacks a source), our ported `include/pthread/workqueue_private.h` (the 2017 baseline to diff against). feedback: oss_engineering_framing, verify_signature_divergence_claims, code_reasoned_verdict_is_hypothesis, agent_host_isolation, parity_explorer.
