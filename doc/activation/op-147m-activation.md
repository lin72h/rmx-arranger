# op-147m — META op: write tests/harnesses in Elixir + Zig only (no shell)

- op: op-147m   (the `m` suffix = this op retools the TARGET AGENT's own working
  method; it is NOT about any product/task deliverable)
- role: ALL guest-run / test-authoring roles — Explorer, Gatekeeper, DS4P, GLM.
- state: DONE 2026-06-25 — broadcast delivered; all roles acked
  (explorer/gatekeeper/ds4p/glm OP147M_METHOD_ACK status=0). Method now in force;
  binds every future guest-run op via the §2a clause + retirement criterion.
- type: standing methodology directive (no expiry)
- authored: 2026-06-25 (Fable)
- governing doctrine: `wip-claude/test-pillar-partition.md` (+ `test-plan.md`,
  `explorer-parity-cycle-workflow.md`). THIS op just enforces it per-role.

## §0 — Why you are reading this — and the exact scope
Roles drifted back to **big shell-script test/automation harnesses** (ref op-124
`op124-lifecycle-probe.rc`, op-145 serial harness — 250-line `.rc` files doing
orchestration + assertions in `sh`). THAT is what's banned. The test-pillar
doctrine already decided the harness layer is Elixir + Zig.

**In scope (banned): a big shell script as the automation/test harness** — a
multi-step `.rc`/`.sh` that drives a lifecycle/soak and emits the verdicts.
**Out of scope (fine): direct CLI use** — running `grep`, `pgrep`, `ls`, `nm`,
`readelf`, `kldstat` etc. at the prompt, or a couple of glue lines, is normal and
encouraged. The rule is about not building *large shell automation*, not about
avoiding the shell entirely.

## §1 — The decided partition (use these, nothing else)
| tier | language | what it does | examples |
|---|---|---|---|
| ORCHESTRATION | **Elixir** | drives runs, sequences multi-step lifecycle, soak / long-running control, captures env, normalizes, diffs vs macOS reference, classifies, owns the `findings/nx-r64z` ledger | launchctl load→start→remove→reload sequencing; soak loop + watchdog; comparator |
| LOW PROBE | **Zig** | the metal: C ABI / syscalls / Mach traps / struct & wire layout / port ops / substrate behavior; one source runs on both targets | "is asld alive + which pid", asl round-trip at the wire, libmach primitive checks |

**swift-testing** (the HIGH tier — Swift code, C++ interop, high-level macOS
APIs) is **deferred** until rmxOS's Swift runtime is solid (Lane B gate). Do NOT
introduce it as an rmxOS probe yet. macOS side may pre-capture reference-ahead
vectors only (parity PENDING, not a claim).

So **right now: Zig probes + Elixir spine. No shell.**

## §2 — The boundary (keep the conductor out of the probe)
- **Elixir owns "how the run is driven," never "what is asserted at the metal."**
  A point behavior = a Zig probe. A sequence/soak/lifecycle = Elixir wrapping
  repeated probe invocations.
- **Zig owns the metal assertion.** Liveness, PID identity across restart/reload,
  ABI/wire/syscall/Mach-trap facts, round-trip correctness — these are Zig
  probe results returned to the Elixir conductor.
- The committed deliverable = the Elixir driver + Zig probe sources + their
  output ledger. No committed multi-step `.rc`/`.sh` *harness*.

## §3 — What this replaces (the anti-pattern is the BIG shell harness)
The thing being retired is the large shell automation, not any single command.
A 250-line `.rc` lifecycle/soak driver that sequences steps and emits verdicts →
an Elixir scenario module; the metal checks inside it → Zig probes. Direct CLI
calls (`grep`, `pgrep`, `ls`, `nm`, `readelf`) remain fine ad-hoc and as thin
glue — just don't grow them into the harness.

## §4 — DTrace `.d` scripts are ENCOURAGED (as the observation tool, not the harness)
Write **DTrace `.d` scripts** for runtime observation/diagnosis of kernel↔userland
behavior — this is encouraged (op-094 doctrine; the op-140 soak oracle `.d` is the
model). The `.d` is **invoked from the Elixir conductor or a Zig probe**; it is the
preferred way to answer "what is the kernel/runtime doing" (slope/leak ticks,
`fbt`/`pid` correlation, signal/exec tracing) — far better than scraping logs in
shell. It is NOT the orchestration harness: Elixir still drives the run and Zig
still owns the metal assertion; the `.d` feeds them observation. So the encouraged
toolset is **Elixir (spine) + Zig (probe) + DTrace `.d` (observation)** — the one
thing retired is the big shell automation harness.

## §5 — Implementer clause
No ad-hoc `printf`/`dprintf` committed into product source to observe behavior.
Use built-in USDT / a Zig probe / DTrace. Observation-only, zero product change.

## §6 — Enforcement
- Every guest-run op activation record carries a `§2a Test Strategy` block naming
  the Elixir/Zig partition + a retirement criterion.
- **Gatekeeper retirement criterion (binding):** an op does NOT retire if any
  PASS/FAIL came from a shell echo-marker harness, `pgrep`, or stdout-`grep`.
  A PASS from a shell harness is not a valid PASS — re-author in Elixir+Zig.

## §7 — Ack markers (confirm you retooled)
```
OP147M_METHOD_ACK status=0 role=<explorer|gatekeeper|ds4p|glm>
OP147M_ELIXIR_SPINE_OK status=0      # run-driver/lifecycle/soak authored in Elixir
OP147M_ZIG_PROBE_OK status=0         # metal assertions authored in Zig
OP147M_NO_SHELL_HARNESS status=0     # zero committed .rc/.sh evidence harness
OP147M_TERMINAL status=0
```
