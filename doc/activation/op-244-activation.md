---
id: op-244
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-244 — Oracle: cort (os_object) lifetime review — retain/release/dispose correctness on the libdispatch+libxpc refcount base, scoped to feed op-242's MACH_RECV UAF trace

op-244 | role: **Oracle** (consult; highest-tier, consult-only, no product-write) | EXU: **rmx-oracle-rx-x64z** | state: **[Done — CONSULT DELIVERED, high-grade; Arranger-verified R1 first-hand. Reframes op-242: cort CLEARED, panic trigger is receive-ERROR path (undersized probe buffer), not the filter. Staged rmx-oracle/op-244-cort-lifetime-findings.md, 2026-07-02]** — see OUTCOME. | parent id: id-036 (MACH_RECV NULL-lock panic, UAF/double-servicing suspect) | L1i: li-1002 (libdispatch/IPC substrate) / subsystem-cort | cost: oracle-tier (highest) | authored 2026-07-02 (Arranger seat, model Opus 4)

## OUTCOME (Arranger adjudication, 2026-07-02, R1 verified first-hand)

**Grade: high.** This consult read the actual source first-hand (cort object.c/object_internal.h/inline_internal.h full, init.c, source.c ranges, libxpc, the kernel mach_msg/ipc_kmsg/ipc_mqueue/ipc_pset path, the op-241 probe, and the git history of every touched libdispatch file), reconciled the record, and delivered ranked *falsifiable* bars with honest caveats. Not a verdict — code-reasoned hypotheses framed "trace-this-next" (`code_reasoned_verdict_is_hypothesis`), exactly as commissioned.

**Commissioned answer (cort): CLEARED.** The cort os_object base is canonical (matches dispatch-500.x) and **locally UNMODIFIED** since vendor import 7f9f2a5ff50b (zero post-import commits to object.c/object_internal.h/inline_internal.h/init.c). No unbalanced retain/release on the MACH_RECV path. The op-241 double-drain UAF hypothesis that scoped this op is **not supported at the cort layer** — the ownership that can be double-consumed/over-released on a MACH_RECV round-trip lives **kernel-side** (kmsg refs, pset/mqueue state, ith_* thread state). One residual kept on file: production-silent internal-count underflow (checked only under DISPATCH_DEBUG) — the *mode* a future unbalanced release would take, not a live defect here.

**R1 — the reframing finding, Arranger-VERIFIED FIRST-HAND.** The probe's handler receives into `simple_msg_t` = bare `mach_msg_header_t`, `MACH_RCV_MSG`, **no `MACH_RCV_LARGE`** (probe.c:74-83, confirmed). Kernel: `rcv_size + REQUESTED_TRAILER_SIZE(=min 8) > max_size` → `MACH_RCV_TOO_LARGE` (ipc_mqueue.c:620; message.h:493/702, confirmed), and the keep-on-queue early return is **LARGE-only** (:621) so it **dequeues anyway** (:632) → msg_receive_error → copyout_dest → the null-`io_lock` panic. So the panic's proximate trigger is the probe's **undersized userland receive**, deterministic, no race — matching the `mach_msg_overwrite_trap` backtrace, NOT `filt_machport`. This also cleanly explains the id-036 cross-op clue **without** the version/sha hypothesis: op-098's round-trip and op-226's li-1002 cert PASS used adequately-sized buffers → never hit TOO_LARGE.

**CONSEQUENCE for op-242 (the key adjudication).** op-242's flag-collision fix is REAL and CORRECT (post-fix, the plain-source filter does a non-dequeuing LARGE peek — op-244 §2 confirms that is the intended behavior). BUT op-244 shows the panic trigger (R1) is in the **receive-error path**, reachable by any undersized receive **independent of the filter** — so op-242's fix may be **necessary-but-not-sufficient**. The real defect may be that `msg_receive_error`→`copyout_dest` panics on a stale/invalid `dest` (R2: dest is mapped but its lock word is non-null garbage — freed/recycled memory; IO_VALID can't catch it, the assert is INVARIANTS-only) instead of handling TOO_LARGE gracefully. That is op-242 scope-2's "kernel robustness" branch — possibly the actual fix.

**ROUTING:**
1. **op-246 (in-flight validator) — RELAY op-244 now.** It directly answers op-246's Q1 (why the error path: undersized buffer) and Q3 (why li-1002 passed: adequate buffers), and it sharpens Q2 (R2's KGDB-on-existing-core bars: print `dest` lock word vs the `ETAP_IPC_RPC`/MTX_DEF baseline; kmsg-header sanity = kmsg-UAF vs port-UAF). If the validator concludes op-242's filter fix does not address the R1 trigger, its confidence on "fix stops the panic" should drop — which is the right outcome, caught before op-247's boot.
2. **op-247 (acceptance rerun, when authored) MUST include R1's A/B:** rerun BOTH the original undersized probe AND a trailer-sized-buffer variant on the fixed mach.ko. Original still panics ⇒ op-242's fix is insufficient and the error-path hardening (a NEW gated Implementer op) is the real fix. Original passes ⇒ the filter fix removed the corrupting receive; keep the A/B as the confirmation.
3. **Probe hygiene:** the op-241 reproducer is undersized (no trailer room, no LARGE). That's a probe characteristic that *forces* the error path — but the error-path panic is a real kernel-robustness bug regardless (a graceful TOO_LARGE must never panic), and §4 shows libxpc reaches it at message-size boundaries → C6 stays live (Coordinator).

**Net:** consult over-delivered — cleared its commissioned target (cort), then handed op-242 a verified, cheaper root-cause lead and a one-run discriminator (R1 A/B). No product/test writes; staged in the Oracle's own dir.

## CONTEXT (read first)
Open-source OS engineering — a code-reasoned second opinion on OUR OWN os_object refcount base (`cort`, co-located in lib/libdispatch: object.c/object.m), the retain/release/dispose foundation under both libdispatch AND libxpc. Not security work, no external target. This consult FEEDS an in-flight first-hand kernel trace (op-242); it does not gate or decide anything.

## WHY (one line)
op-242 (Implementer, in-flight) is tracing a live kernel panic on the MACH_RECV dispatch-source path whose leading hypothesis is a **use-after-free / double-servicing** of an os_object-backed message/port — i.e. a cort-lifetime defect. A focused Oracle read of the os_object retain/release/dispose ordering could shortcut op-242's root-cause by naming the lifetime seam most likely to double-free or under-retain on the MACH_RECV round-trip.

## SCOPE
- **Review the cort os_object lifetime model** (core default `OS_OBJECT_USE_OBJC=0`): retain/release counting, dispose ordering, and the boundary where an os_object is handed across the libdispatch↔libxpc↔mach-IPC seam.
- **Aim at op-242's live question:** on a `DISPATCH_SOURCE_TYPE_MACH_RECV` round-trip where BOTH the source servicing AND the handler's own `mach_msg(MACH_RCV_MSG)` touch the same port/message (the probe's double-drain, id-036), where — in os_object terms — could ownership be double-consumed or released once too many, leaving a freed/nulled object the kernel then `io_lock`s? Name the specific retain/release/dispose site(s).
- **Reconcile with the cross-op clue (id-036):** li-1002's well-behaved single-receive MACH_RECV case PASSES on the cert image — so the suspect lifetime path is the *double-servicing* one, not the ordinary receive. Focus there.

## DELIVERABLE
A cort-lifetime findings note (staged under rmx-oracle/): the os_object retain/release/dispose sites most likely implicated in a MACH_RECV double-drain UAF, ranked, each as a **hypothesis with the reasoning** — routed explicitly INTO op-242's trace as candidate DTrace bars / KGDB inspection points, NOT as a standalone verdict.

## BOUNDARIES
- **Consult-only, no product-write** (oracle-tier). Stage findings in the Oracle's own dir (`agent_host_isolation`); propose, do not patch.
- **Code-reasoned = hypothesis, not verdict** (`code_reasoned_verdict_is_hypothesis`). The Oracle's cort read informs op-242's first-hand trace; it does not compete with or pre-empt it. Frame every finding as "trace-this-next," not "this is the bug."
- **Does NOT decide C6 preview-severity** (Coordinator, li-1013) and does NOT gate op-242.
- **Scoped to lifetime/os_object** — this is NOT the full libdispatch re-review-vs-1st-feedback round (that waits until op-242 SETTLES, then cort rejoins libdispatch for the comprehensive round).

## RELATIONS
id-036 / op-242 (the UAF trace this feeds; the reason cort is reviewed now) / op-241 (panic premise) / li-1002 (substrate hardening) / subsystem-cort (the os_object base). Later: the comprehensive mach-ipc + libdispatch re-review round (post-op-242-settle) folds cort back into libdispatch. feedback: code_reasoned_verdict_is_hypothesis, no_conflate_gating_with_readiness, agent_host_isolation, oss_engineering_framing.
