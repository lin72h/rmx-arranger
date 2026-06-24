# id-016 — no ambient/system-wide Mach bootstrap port (non-launchd-child processes can't reach Mach services)

- id: id-016
- state: **WAITING (Coordinator decision) — characterize-first op-119 (Explorer rx-x64z, free) ISSUED
  but NOT YET DISPATCHED (2026-06-23 issued; bookkeeping corrected 2026-06-24).** Prior "in flight" was
  an overclaim — op-119 appears in NO rmx-explorer ref (Arranger-verified first-hand 2026-06-24; mx-a64z
  also reported absent — correct, since op-119 is an rx-x64z op, not mx). Dispatch text now authored;
  awaiting Coordinator relay to rx-x64z. The architecture/scope call (b-equiv vs catalog) stays
  Coordinator-held; op-119 is DISCOVERY-ONLY to *inform* it (does real-session-manager launchd already
  propagate bootstrap system-wide?), not a fix or a scope commitment. Surfaced by op-110 (notify),
  corroborated by op-116 (asl). NB: directly relevant to the depth-first notify/asl-solid directive —
  Gate-C "launchd as real session manager" is exactly the question op-119 characterizes.
- raised: 2026-06-23 — op-110 cont. STOP: three launch contexts (rc.local direct, `launchctl load`
  from rc.local, boot-scan plist) all failed to reach notifyd; the only working context is the
  nxplatform-probe's own child session.
- roadmap parent: [roadmap.md](../roadmap.md) — touches the **developer-usable floor** (run Darwin
  programs against Mach/dispatch/**notify** from a shell) and **Gate C** (launchd as the real
  session manager, not a contained test monolith).
- relations: **id-010/op-110** (the conformance op that hit it; unblocked via the probe-child path,
  not by fixing this); **project Phase 0.8 launchd** (lifecycle spine — but that's "launchd drives
  services," a *higher* layer than "bootstrap is ambient"); **id-015** (preview image — see the
  preview-scope question below).

## The gap (first-hand evidence from op-110)

- **macOS:** launchd is PID 1; the Mach bootstrap port (`TASK_BOOTSTRAP_PORT` special port) is
  inherited via fork/exec down the *entire* process tree. So **any** process — shell-launched or
  not — can `bootstrap_look_up` notifyd and call `notify_*`. Bootstrap is ambient/universal.
- **rmxOS (current):** the bootstrap port is set **only for the nxplatform-probe's children** (the
  probe brings up launchd+notifyd and sets bootstrap for what it spawns — serial:
  `BLOCK078_NOTIFY_CLIENT_START pid=986 bootstrap_port=19`). Processes *outside* that session
  (rc.local, `launchctl` from rc.local → `kr=10000003`, boot-scan plist) get `MACH_PORT_NULL` →
  `ipc_entry_lookup failed on 0`. The system PID 1 is FreeBSD `init`, which sets no Mach bootstrap.

**Scope of impact:** this hits **service-client layers reached via bootstrap** — notify (now), and
later asl + libxpc. It did NOT affect libdispatch (op-102 MATCH 9/9) because dispatch uses Mach
primitives directly (kqueue/workqueues), not a bootstrap-registered service. So bootstrap-ambient
is specifically a *service-layer* prerequisite.

**Corroborated by asl (op-116, 2026-06-23):** the prediction held — `lib/libasl/asl_core.c:110`
reaches the Apple ASL syslogd via `bootstrap_look_up2(bootstrap_port, "com.apple.system.logger")`,
so **asl is the 2nd confirmed service-client hit by this gap** (Arranger-verified first-hand). Same
mitigation as notify (probe-child inherits bootstrap from launchd). This makes the gap a *general
service-layer* property, not a notify-specific quirk — strengthening the case that the real fix
(b-equiv, ambient bootstrap) is the macOS-faithful answer for the whole service tier.

## The decision space (do NOT pick reflexively)

- **(b-equiv) make bootstrap ambient** — rmxOS provides a system-wide bootstrap port to
  init-spawned processes (launchd as session manager / a bootstrap server as a host special port
  that the process tree inherits). The macOS-faithful answer; the biggest change; overlaps Gate C
  (launchd as real PID-1-ish session manager).
- **(catalog) accept "run as a launchd job"** for now — document that Darwin service-clients must
  be launchd children in the preview; catalog the ambient-bootstrap gap as a known Gate-E item
  ("doesn't block use-case X if X launches via launchd"). Cheapest; preview-ASAP.
- characterize-first: does rmxOS launchd, when run as the *real* session manager (not the probe
  monolith), already propagate bootstrap system-wide? If yes, this is largely a test-model artifact
  and folds into Gate C. (Explorer/launchd-track question — cheap to investigate.)

## Preview-scope question (Coordinator-held, surfaced 2026-06-23)

The developer-usable floor says "build + run Darwin programs against Mach/dispatch/**notify**." If a
developer must run their notify program **as a launchd child** (not from a shell), is that an
acceptable preview floor (documented limitation), or does the preview require ambient bootstrap?
- lean (preview-ASAP, cut-scope): accept launchd-child execution for the preview, catalog ambient
  bootstrap as Gate-C/post-preview. But this is the Coordinator's floor-definition call.

## Truly-green criterion (if fetched to fix, not catalog)

- a process spawned by system `init` (NOT a launchd child) can `notify_post`/`notify_register` and
  reach notifyd — i.e. bootstrap is genuinely ambient — verified first-hand, matching macOS.
