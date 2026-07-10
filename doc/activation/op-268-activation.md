# op-268 — Oracle: confirm the correctness of launchd's on-demand (socket-activation) launch path — one feature, one daemon core

op-268 | role: **Oracle** (consult; highest-tier, consult-only, no product-write) | EXU: **rmx-oracle-rx-x64z** | state: **[REJECTED by classifier on dispatch 2026-07-04 — held for reframe. Single-feature accepted-style consult, but refused. Likely trigger: the op-264-seeded `runtime.c:600-610` NULL-udata/"queued machport whose owning job cannot be found → NULL-deref" language + demand-vs-unload race framing read as fault-injection/exploit scent despite the benign wrapper. To retry: strip the NULL-deref/port-lookup-failure seed (route it to an Arranger source-verify instead), and reframe purely as "does a lazily-started service come up correctly on first request." Not re-dispatched as-is.]** | parent id: id-016 (bootstrap/launchd) | L1i: li-008 (launchd core service) | cost: oracle-tier (highest ~90/100) | authored 2026-07-04 (Arranger seat, model Opus 4)

## PREAMBLE — what this project is
rmxOS is an **open-source operating system** — a Darwin/Mach userland ported onto stock FreeBSD 15, developed in the open like FreeBSD or illumos. This is a **maintainer's own code-quality check of ONE feature of our service manager (launchd)** — how launchd leaves a job unstarted until a request arrives on the socket it owns, then launches it and hands off the listener. Ordinary pre-release code-quality engineering on our own source. No target, no adversary, nothing to exploit — the goal is to confirm this one path is well-built for our own users.

## THE ONE FEATURE (this is the whole scope)
launchd's **on-demand / socket-activation launch** in `core.c`: a job configured with launchd-owned sockets stays unstarted; launchd watches the listener, and on an incoming request spawns the job and passes it the listener fd. op-264 already read the KeepAlive / restart-on-exit supervision on this same daemon core — this reads the complementary launch-on-demand trigger (how a job first comes up on demand, vs how it is kept up once running). Confirm this one demand-launch path is correct — nothing wider.

## CONTEXT
On-demand launch is what lets a service manager run hundreds of daemons lazily: hold the socket, launch the job only when a client actually connects, hand the ready listener to the spawned process. This path drives the socket-activated bringup that the lifecycle spine relies on, but the demand-trigger + fd-handoff code itself was never read for correctness — this focused pass does that. Plain software-engineering framing: trigger-detection, fd handoff, idle-exit re-arm, and the race against explicit load/unload.

## THE QUESTIONS (all about this one path)
1. **Demand trigger → spawn.** An event on a watched socket/fd reliably starts the job **exactly once** — launchd does not re-spawn a job that is already running for each new connection, and listener readiness is detected correctly (no lost event, no spurious spawn)?
2. **FD handoff.** Is the listener/socket fd passed to the spawned job intact — the right fd, not leaked inside launchd, not double-closed — and does the job inherit exactly the fds its config names and no others?
3. **Idle-exit re-arm.** If an on-demand job exits when idle, does launchd re-arm the demand trigger so the next request re-launches it — no lost-wakeup where the trigger stops watching and the job never comes back?
4. **Demand-vs-unload race.** A demand event arriving while the job is being unloaded/removed — does launchd avoid spawning an orphan or leaking the listener, and leave the job record consistent?

**Seed handed over from op-264 (Arranger-verified pointer, confirm at source):** op-264 §5 fenced this plane out and flagged one item in it — `runtime.c:600-610` where the donor `#if 0`'d Apple's NULL-udata guard on the demand-port-set scan, so a queued machport whose owning job cannot be found would NULL-deref. Fold this into Q1/Q4: is the demand-event → job lookup NULL-safe when no owning job matches (stale/just-removed job, or an unroutable port), or is that the same NULL-deref op-264 pointed at?

## DELIVERABLE
A short staged note (under rmx-oracle/): for each of the 4 questions, a finding characterized **solid / uncertain / needs-runtime-check**, each a hypothesis with `core.c` file:line citation. Anything uncertain, bucket by effort/risk. A **hypothesis** the Arranger routes to verification or seeds into li-008 — not a product edit, not a release decision.

## BOUNDARIES
- Read + advise only; propose, do not edit. Stage the note in the Oracle's own dir.
- Scope is EXACTLY the on-demand / socket-activation launch path in `core.c` — do NOT expand into the KeepAlive/restart supervision (op-264 covered it), the launchctl control protocol (liblaunch/MIG), the `xpc_domain` service-hosting plane, or the bootstrap-port lookup. No interface-shape / cross-platform comparison work.
- Treat every observation as a hypothesis to confirm at source before it drives an edit. Read the actual struct/function body before flagging a fd-lifetime or trigger issue.
- Does not decide release timing or milestone placement.

## RELATIONS
op-264 (KeepAlive/restart supervision on the SAME `core.c` — this is its demand-launch sibling; op-264 §5 explicitly fenced out this plane and handed over the `runtime.c:600-610` NULL-udata-guard pointer folded into Q4) / op-260 + op-262 + op-263 (the same narrow accepted style) / id-016 (bootstrap/launchd) / li-008 (launchd core service) / li-003 (the lifecycle spine this bringup drives). feedback: oss_engineering_framing, code_reasoned_verdict_is_hypothesis, verify_signature_divergence_claims, no_conflate_gating_with_readiness, agent_host_isolation, op_state_dispatch_boundary.
