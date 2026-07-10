# op-188 — Gatekeeper: author the li-1007 integration-soak harness (Elixir multi-workload orchestrator) + dry-run compose — makes op-185 runnable

op-188 | role: **Gatekeeper** (FREE) | EXU: **rmx-gatekeeper-rx-x64z** | state: **[Retired — 4-PLANE-COMPOSE-GREEN @ 1e20395; Arranger verified first-hand; op-185 RELEASED]** (2026-06-29 v6). v6/v6b serial verified first-hand: v6b sha `78612c2d…` (matches report) + v6 sha `dbd4c560…` BOTH show the dispatch plane GREEN — `op102_matrix_fails=0` + `op102_matrix_terminal status=0` (v6b:2951-2952) alongside NOTIFY `OP150_CHURN_START` (2920), ASL `op116_matrix_terminal status=0` (2931), ORACLE dtrace probes up → a real concurrent 4-plane compose (uptime 2m8s dry-run, NOT the hours-scale soak — that's op-185). **ARRANGER SELF-CORRECTION:** my v5 MECHANISM attribution was WRONG — the empty `<string></string>` I cited (v5:1217/1224) was DEAD Block-1 stdout pollution in the runner, NOT the operative plist; the live plist always populated ProgramArguments. The real compose-blocker was the **op-193 churn ELF never staged at `/root/`** → silent fork/exec fail. Fix that produced green = stage the ELF (995eabf1…, 36128 bytes, primary) + remove the dead Block-1 + stage the template (cosmetic). My v5 GATE was nonetheless CORRECT (dispatch plane genuinely DARK, op102 never emitted, op-185 rightly blocked) — I rejected the right overclaim for a partly-wrong reason; lesson logged (don't attribute runner mechanism from polluted serial stdout — read the runner source). ASL residual `op116_matrix_fails=1` persists (tracked separately; op-198 closes asl leg-4). | ~~[Awaiting — RE-DRY-RUN]~~ prior adjudication (2026-06-29 v5, Arranger, serial read first-hand, v5 sha `be427b1e…` MATCHES reported evidence). **REPORT OVERCLAIMED "4-plane proven / dispatch PARTIAL cosmetic" — the dispatch plane did NOT execute.** First-hand from `build/op188/op188-v5-serial.log:1224-1228`: `=== DISPATCH ===` → `<key>ProgramArguments</key><array>` → `<string></string>` (EMPTY arg) → `sed: /root/run-as-launchd-job.plist.template: No such file` → `=== DONE ===` — NO `op102_matrix_fails=`/`op102_matrix_terminal` output, the op-193 churn ELF NEVER RAN. Genuinely proven concurrent: ORACLE (mach round-trip live), ASL (`op116_matrix_fails=1` real matrix), NOTIFY (`OP150_CHURN_START` emitted). **ROOT: the launchd-job runner's inline plist builder produces EMPTY `ProgramArguments` when `run-as-launchd-job.plist.template` is missing — so the dispatch workload has nothing to exec; the SAME empty-`<string></string>` defect also hits the NOTIFY job-wrap (line 1217), so it's a RUNNER defect across planes, not a one-off dispatch cosmetic.** So the "minor fixes for op-185" #1 (stage template) + #3 (inline builder populates ProgramArguments) are **COMPOSE-BLOCKING for the dispatch plane, NOT cosmetic**; only #2 (asl 200ms settle, op-162) is truly minor. GATE before op-185 releases: fix the runner so the dispatch ELF actually execs, and re-dry-run proving the dispatch plane emits `op102_matrix_terminal` CONCURRENTLY with the other 3 (a real 4-plane compose, not 3+launch-attempt). Orchestrator authored ✓ (`integration_soak_conductor.ex`, 217 lines, present); op-193 ELF received ✓ (sha match); workload-class call recorded (looped_one_shot + mach-IPC confound = ACCOUNT) — but that call is UNTESTED until dispatch actually runs. | parent id: id-026 | L1i: li-1007 (integration soak) | authored 2026-06-28, re-roled 2026-06-29, re-dry-run gate 2026-06-29 (Arranger seat, model Opus 4)

## WHY (one line)

op-186's readiness matrix: the 4 core soak workloads exist as individual artifacts (notify op-150, asl op-116, mach-IPC oracle op-104; libdispatch churn delivered by op-193), but **no Elixir multi-workload composer exists** (the id025 modules are single-workload). That composer + a dry-run proving the 4 planes come up together is the last thing before op-185 (the hours-scale li-1007 soak) can run. Build the harness once, cleanly, then soak on it.

## SOURCE TREE / WORKSPACE (harness infra — NOT the product tree)

- The orchestrator is **harness infrastructure, not product source** — author it alongside the existing `id025/`
  Elixir modules (compose them), NOT inside the canonical rmxOS source tree.
- Consume (do NOT rebuild): op-193's libdispatch churn ELF and op-184's dtrace image. **EXPLICIT CONSUME PATHS
  (Arranger-verified on-host 2026-06-29 — search the RIGHT roots, not just `build/`):**
  - op-184 image: `NXPLATFORM_VM_IMAGE=/Users/me/wip-mach/vm/runs/op184-soak-dtrace-v3.img` (sha `cd71126e…`,
    provenance-intact kernel `c526a91d…`/mach.ko `30d23616…`). It is in the **shared `vm/runs/` handoff**, NOT
    under `build/` — confirmed present on-host, identity sha-matched. Do not report it absent without checking
    `vm/runs/`.
  - op-193 churn ELF: **PUBLISHED + verified present** at
    `/Users/me/wip-mach/build/op188-integration-soak/workloads/dispatch-churn-op193` (sha `995eabf…`, size 36128,
    Arranger-confirmed on-host 2026-06-29). D1 dependency satisfied — receive it from there (do NOT reach into
    wip-gpt's private `wip-gpt/build/…` tree, do NOT self-build).
- Canonical rmxOS source `wip-gpt/wip-rmxos` is READ-ONLY to this op (Gatekeeper does not edit product or build).

## CONTEXT (from op-186 @ `0b0a25b` + the closures since, take as given)

- The 4 core workloads + state: notify churn (op-150 probe, ELF) RUNNABLE; asl lifecycle (op-116 harness, ELF)
  RUNNABLE; mach-IPC oracle (5× `.d`: soak-oracle + 4 balance invariants, op-104 120s PASSED) RUNNABLE;
  libdispatch churn = delivered by **op-193** (consume its ELF, do not build).
- "RUNNABLE" = artifact present + loads individually — NOT "runs on today's bare image." The mach-IPC oracle
  needs DTrace, so the dry-run (and op-185) run on op-184's dtrace image, not the bare op-149 image.
- libxpc workload: its conformance gates (op-187 reply + op-191 cancel/error) are now BOTH [Done], but it is
  EXCLUDED from this op's 4-workload scope — no libxpc soak-CHURN artifact exists yet (op-191 shipped a focused
  conformance probe, not a sustained-load workload). It folds in as a fast-follow 5th workload (its own
  build op → then this harness), not scope-crept here.
- Harness pillars (dtrace_first_debugging): Elixir orchestration + Zig metal probe + DTrace `.d`. Big shell
  `.rc`/`.sh` harness BANNED (direct CLI fine); `.d` providers load individually.

## DELIVERABLES

**D1 — receive op-193's churn ELF (build_is_implementer) AND judge its workload class (load-bearing caveat).**
Take op-193's delivered libdispatch churn binary by path+sha (`dispatch-churn-op193`, sha `995eabf…`, size 36128,
links canonical libdispatch `f15acd60…` @ HEAD `501a1ef`); verify the sha matches `OP193_DELIVERED` and that it
loads/execs on the op-184 image. Do NOT rebuild it. If op-193 is `walled` or undelivered, this op is BLOCKED —
say so, do not improvise a build.
**CAVEAT carried from op-193 (Arranger source-read, take as given): the binary's source `harness.c` is the
op-102 libdispatch runtime-CONFORMANCE harness, NOT a purpose-built churn loop** — a one-shot PASS/FAIL matrix
(each dispatch API exercised ONCE: async/sync/apply/once/barrier/group/sem/timer/MACH_RECV → `op102_matrix_fails=N`,
then exits), with 1s timer + 1s MACH_RECV waits → wait-dominated, low-rate as sustained churn. Two consequences
the Gatekeeper MUST resolve before composing it as the dispatch plane:
  (1) **Churn adequacy:** decide whether looping this conformance one-shot under the orchestrator yields adequate
      sustained `dispatch_async`/TWQ load for an integration soak, or whether a purpose-built churn loop must be
      authored (Implementer build op) before op-185 can run for-real. Name the call; do not silently treat the
      conformance one-shot as churn.
  (2) **CRITICAL cross-plane confound (harness.c:93-116):** the harness does per-iteration
      `mach_port_allocate`→`mach_msg`→`MACH_RECV`→`mach_port_destroy`, so the "libdispatch" workload ALSO churns
      the mach-IPC plane — this WILL confound op-104's mach-IPC oracle balance invariants when the two run
      concurrently. Either account for this in the oracle's balance accounting (known extra port create/destroy
      per dispatch iteration) or strip the MACH_RECV leg from the dispatch role so the planes stay separable.
      The dry-run (D3) must surface this, not mask it.

**D2 (MAIN) — author the Elixir multi-workload orchestrator (to id-006/id-007 design).** A composer that runs the
4 core workloads CONCURRENTLY under sustained load: notify churn (op-150), asl lifecycle (op-116), libdispatch
churn (op-193 ELF), mach-IPC oracle (`.d`, loaded individually). Elixir orchestration + the existing Zig/ELF
probes + `.d` observation — NOT a shell `.rc`/`.sh` harness (banned). The single-workload id025 modules are the
building blocks — compose, don't rewrite.

**D3 — dry-run compose (NOT the full soak).** On op-184's `op184-soak-dtrace-v3.img`, prove the orchestrator
starts all 4 concurrently AND the `.d` oracle loads live, then tears down clean — a short smoke (minutes), enough
to show the 4 planes up together. NOT the hours-scale soak (that is op-185). **"Up together" = each plane emits
its real workload terminal (oracle round-trip + `OP150_CHURN_START` + `op116_matrix_terminal` +
`op102_matrix_terminal`), NOT merely that the runner attempted a launch.**

**D4 (RE-DRY-RUN GATE — added 2026-06-29 after the dispatch-dark finding) — fix the runner + re-prove a REAL
4-plane compose.** The first dry-run (v5, serial `be427b1e…`) left the DISPATCH plane DARK: the launchd-job
runner's inline plist builder emits EMPTY `ProgramArguments` (`<string></string>`) when
`run-as-launchd-job.plist.template` is absent, so the op-193 ELF never execs (no `op102_matrix_terminal` on
serial — `op188-v5-serial.log:1224-1228`). Fix the runner: stage `run-as-launchd-job.plist.template` AND make the
inline fallback populate `ProgramArguments` correctly (cross-plane runner defect — the same empty-arg also hit the
notify job-wrap at line 1217). Then RE-DRY-RUN on the op-184 image and prove the dispatch plane emits
`op102_matrix_terminal` CONCURRENTLY with oracle+notify+asl — a genuine 4-plane compose. Only then is the
workload-class call (looped_one_shot adequate? mach-IPC confound balanced?) actually TESTED rather than asserted.
Re-report the new serial sha.

**VERDICT:** `harness-ready` (op-193 ELF received + verified, orchestrator composes all 4 with the DISPATCH plane
PROVEN executing — `op102_matrix_terminal` concurrent — dry-run clean → op-185 unblocked) | `walled` (a plane
that won't compose, `.d` won't load → do NOT improvise a shell driver or a self-built binary). NOTE: 3-of-4 up
with the dispatch plane dark is NOT harness-ready — don't conflate a launch attempt with a workload that ran.

## BOUNDARIES
- Gatekeeper, FREE — authors test infra + validates; builds NO product and NO binary (op-193 supplies the ELF;
  build_is_implementer). Canonical rmxOS tree is read-only to this op.
- Harness infra (D2) lives with the id025 Elixir modules, NOT in the product source tree.
- NO shell `.rc`/`.sh` harness — Elixir + Zig/ELF + `.d` only; load `.d` providers individually.
- Do NOT author/build the libxpc workload — separate fast-follow op (no-fold, depth-first). First integration
  soak = the 4 proven-substrate services only.
- Do NOT run the full hours-scale soak — that's op-185 (the held li-1007 op, same Gatekeeper continues into it).
  This op only makes it runnable.
- Stage strictly inside rmx-gatekeeper-rx-x64z's owned dir (agent_host_isolation).

## MARKERS
```
OP188_CHURN_RECEIVED   # op-193 churn ELF received: sha matches OP193_DELIVERED + loads/execs on op184 image
OP188_WORKLOAD_CLASS   # judged: looped op-102 conformance one-shot = adequate churn? OR purpose-built loop needed; mach-IPC cross-plane confound (port alloc/destroy per iter) accounted-or-stripped
OP188_ORCHESTRATOR     # Elixir composer runs notify+asl+dispatch+mach-IPC concurrently (not shell)
OP188_DRYRUN           # short compose smoke on op184 dtrace image: 4 planes up together, .d oracle loads live
OP188_REDRYRUN         # runner fixed (plist ProgramArguments populated); re-dry-run proves DISPATCH plane emits op102_matrix_terminal CONCURRENT with the other 3 (real 4-plane compose) — new serial sha
OP188_VERDICT          # harness-ready (dispatch PROVEN executing) | walled
OP188_TERMINAL
```

## RELATIONS
- CONSUMES op-193 (the libdispatch churn ELF) + op-184 (the dtrace image). UNBLOCKS op-185 (the held li-1007
  integration soak, same Gatekeeper).
- UPSTREAM: op-186 (readiness inventory), op-193 (binary), op-184 (image).
- DOWNSTREAM: op-185 (hours-scale soak); libxpc folds in as a fast-follow 5th workload.
- feedback: harness_authoring_is_gatekeeper (this is the Gatekeeper half of the op-188 role-split — orchestrator
  + dry-run), build_is_implementer (receive op-193's ELF, never build it), soak_is_gatekeeper (the Gatekeeper
  owns the rig it'll soak on), dtrace_first_debugging (Elixir+Zig+.d pillars, no shell, providers individual),
  complete_once (compose the whole 4-workload surface so op-185 runs in one pass), no-fold (libxpc excluded),
  depth_first_conformance, agent_host_isolation.
```
