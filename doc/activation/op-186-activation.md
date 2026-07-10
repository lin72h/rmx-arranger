# op-186 — Explorer: inventory the integration-soak probe/harness surface (readiness matrix) — scopes the held op-185

op-186 | role: **Explorer** (free) | EXU: **rmx-explorer** (rx1) | state: **[Done]** — inventory complete, pushed to main @ `0b0a25b` (2026-06-28). 5-row matrix: notify/asl/mach-IPC-oracle RUNNABLE (artifact-level); libdispatch NEEDS-BUILD; libxpc NEEDS-BUILD (gated on op-187); orchestrator NEEDS-AUTHORING. Long pole = libdispatch-churn + orchestrator → carried into op-188. | parent id: id-026 | L1i: li-1007 | authored 2026-06-28 (Arranger seat, model Opus 4)

## WHY (one line)

The complete integration soak (held op-185, li-1007) needs a probe set — notify churn, asl lifecycle, libdispatch
churn, the mach-IPC li-1001 oracle, libxpc workload — driven together under sustained load. First-hand check
2026-06-28 found NONE of these staged as runnable artifacts on the build host; the harness lives at the DESIGN
level only (`idq/id-006` libdispatch soak harness, `idq/id-007` continuous-soak-harness-infra). Before op-185 can
be scoped (let alone run once, clean), we need to know exactly what exists, what needs a build, and what needs
authoring. This is that inventory — discovery only, off the Implementer/Arranger cost cycles.

## CONTEXT (take as given)
- Harness pillars (feedback_dtrace_first_debugging): Elixir orchestration + Zig metal probe + DTrace `.d`
  observation. Big shell `.rc`/`.sh` harness is BANNED; direct CLI is fine; `.d` providers load individually.
- The DTrace-enabled soak image is being built in parallel (op-184) — assume DTrace will be available at soak
  time; this op does NOT need it (it's a source/artifact inventory, not a run).
- Explorer roster: rx1 is IN; rx2 is OUT/parked — this is rx1's.

## DELIVERABLES — a READINESS MATRIX, one row per probe the li-1007 soak needs

For EACH workload below, report exactly one state — `RUNNABLE` (built artifact present + confirmed it is the
real workload, not a namesake) / `NEEDS-BUILD` (source present, not built) / `NEEDS-AUTHORING` (no source) — with
the path(s) you found and a one-line "what it actually drives":

1. **notify churn** — sustained notifyd register/post/cancel churn (the workload historically called the "op-123
   notify churn probe" — find its real artifact, don't trust the label).
2. **asl lifecycle/churn** — asld message lifecycle under load (the "op-146 asl probe").
3. **libdispatch churn** — `dispatch_async`/TWQ workload (per id-006).
4. **mach-IPC li-1001 oracle** — the `.d` that asserts the substrate invariants: send/recv balanced, port
   alloc/dealloc balanced, no stuck enqueue, dead-name delivered. Confirm it loads as an INDIVIDUAL provider.
5. **libxpc workload** — an xpc-call driver (note: libxpc is classification-only pre-1.0 — report whether any
   runnable driver exists at all, don't author one).

Then:

**D-summary — the long pole.** From the matrix, state which rows are `NEEDS-BUILD` / `NEEDS-AUTHORING` and a
rough sense of which is the heaviest lift. This is the input that lets op-185 be written ONCE with real
preconditions instead of guesses.

**D-orchestration — how they compose.** Note whether id-006/id-007 already define an Elixir orchestrator that can
run these concurrently, or whether composing them into one soak is itself unbuilt.

## BOUNDARIES
- READ-ONLY discovery. No edits, no builds, no authoring of probes — inventory + state-of-readiness ONLY
  (Explorer = discovery; building is Implementer's, op-185's downstream).
- VERIFY first-hand before calling a probe `RUNNABLE` — open it, confirm it actually drives the workload named
  (verify_signature_divergence_claims: a matching filename is not evidence the workload exists).
- Don't propose the soak design or pre-empt op-185's scope — just report the surface.

## MARKERS
```
OP186_MATRIX        # 5 rows, each RUNNABLE | NEEDS-BUILD | NEEDS-AUTHORING + path + what-it-drives
OP186_LONGPOLE      # which rows need build/authoring; heaviest lift
OP186_ORCHESTRATION # does an Elixir orchestrator to compose them exist, or is that unbuilt?
OP186_VERDICT       # inventory-complete | blocked (state what blocked the read)
OP186_TERMINAL
```

## RELATIONS
- SCOPES the held op-185 (li-1007 integration soak) — its output becomes op-185's preconditions.
- Independent of op-168 (soaking) and op-184 (dtrace image build) — runs parallel, free role.
- feedback: role_costs (discovery on the free Explorer, not Arranger/Implementer cycles),
  verify_signature_divergence_claims (confirm a probe is real before calling it runnable),
  dtrace_first_debugging (harness pillars; .d loads individually; no shell .rc harness),
  conformance_match_is_leg3_only (Explorer authors/inventories; Gatekeeper validates — not this op).
```
