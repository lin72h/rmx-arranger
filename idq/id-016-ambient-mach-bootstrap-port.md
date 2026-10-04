# id-016 — no ambient/system-wide Mach bootstrap port (non-launchd-child processes can't reach Mach services)

- id: id-016
- state: **PREVIEW SCOPE PROMOTED — Coordinator ruling 2026-07-12: launchd MUST be PID 1 for
  1.0-preview. Option (a), the faithful PID-1 topology, replaces option (c)'s launchd-job-only
  workaround as the ship model.** The earlier launchd-job model remains valid historical/interim
  evidence, but it is no longer sufficient for the preview stamp. op-127 DONE 2026-06-24. op-119
  DONE (`17ee14f`, Arranger-verified) closed the
  characterize-first question: the gap is **architectural, NOT a test-model artifact** — rmxOS launchd,
  even as the real session manager, CANNOT propagate bootstrap system-wide, because it is **not PID 1**
  and the kernel primitive that would let it (`posix_spawnattr_setbport_np`) **does not exist**. Ambient
  bootstrap requires a deliberate architectural move (options a-d below); it will not emerge from running
  launchd correctly.
  - **2026-10-03 reaper premise NOT OBSERVED:** op-429's one cell on the op-388 image showed none of the three failure modes over 50 exits (validator1 and validator2 at 9/10; Arbiter ruling j-20261003-008 records two deviations). The result is bounded to this workload. op-280 stays held with no fix; the path moves to op-202, then op-203.
  - **2026-07-12 PID-1 preview ruling:** the Coordinator closed op-317's topology fork in favor of
    non-`-u` PID-1 launchd via `init_path`, using the op-201 `/etc/rc` chain-load hybrid as the proven
    starting point. This promotes PID-1 productionization, root-rw/base-service closure, reaper
    evidence, and robustness into the preview critical path. It does **not** make stale op-202,
    op-203, or op-279 dispatchable. op-318/op-321 banked the topology/no-base/census partials;
    op-322 has now returned the bounded helper/BOM/reaper correction at Explorer confidence 9.
    Its XL return is awaiting two independent parallel Validator gates: staging (C1/C2/staging C8)
    and reaper (C3-C7/reaper C8). A staging pass may release only Implementer helper/image brief
    authorship while the reaper gate continues. Current intended sequence: accepted staging gate →
    Implementer disposable PID-1 stage; accepted reaper gate + staged image → corrected op-279 →
    op-280 if evidence warrants → normalized op-202 → normalized op-203 → id-042 all-up.
  - **op-127 DONE (`0232318`, Arranger-verified consistent first-hand):** resolved the mechanism hinge
    with concrete port values, BOTH paths first-hand on the staging-model guest:
    - **Shell (off `init → rc.d`):** `TASK_BOOTSTRAP_PORT = 0` (NULL) → `bootstrap_look_up(notifyd)`
      `kr=268435459` (= `0x10000003`, the same non-launchd error signature op-110/op-119 saw) → notify
      round-trip **FAIL**.
    - **Launchd child:** `TASK_BOOTSTRAP_PORT = 19` (valid) → `bootstrap_look_up` `kr=0`, notifyd at
      port 21 → **FULL** round-trip (register→post→check=1).
    Corroborates op-119's init-vs-launchd characterization with measured values. truly-green for op-127.
  - **HISTORICAL decision (superseded 2026-07-12): (c) locked as an li-005 known-gap for the preview
    and (a) was deferred.** The evidence and rejection of (b)/(d) remain useful, but the Coordinator
    has now promoted (a) launchd-as-PID1 into the preview gate. Original rationale: the
    design philosophy explicitly prefers **cataloging a bounded known-gap over closing it with a
    complex/risky non-faithful impl** (roadmap §"Tempo + scope stance"); a (d) rc.d bootstrap shim is a
    paper-over that risks becoming a permanent non-faithful hack, and (a) is the real fix. So we catalog.
  - **HISTORICAL SCOPE (superseded 2026-07-12):** the preview's documented run-model was
    **"programs run as launchd jobs"** (notifyd, syslogd, and the developer's own agent/daemon loaded via
    `launchctl load` — the macOS-native way to run a service), NOT `cc foo.c && ./foo` from an interactive
    shell. op-127 PROVES a shell-launched notify client is broken today (`port=0`). We do NOT escalate to
    (d): a bootstrap shim faking ambient-bootstrap for arbitrary shell processes is the disfavored
    non-faithful paper-over; (a) launchd-as-PID1 is now the required preview fix.
  - **li-005 catalog entry (this id IS the catalog row):** "shell-launched (non-launchd-child) processes
    get `TASK_BOOTSTRAP_PORT=0` and cannot `bootstrap_look_up` notifyd; run notify programs as launchd
    jobs. Ambient shell bootstrap arrives with launchd-as-PID1 in full 1.0 (option a)." This was the
    historical preview catalog entry; it no longer supplies the ship disposition. **Historical non-blocking
    justification:** the preview floor ("build + run a Darwin program against notify") is satisfiable via
    the launchd-job path, proven by op-127 (`port=19`, full round-trip). dispatch_async needs no bootstrap
    (op-102 9/9) so dispatch samples run from a shell unaffected.
  - **DAEMON-SIDE evidence (op-138 `47eaad3`, Arranger-verified at the findings level 2026-06-25):** the gap
    hits the **daemon**, not just clients. Apple `asld` (installed as `/usr/sbin/syslogd`) calls
    `bootstrap_check_in("com.apple.system.logger")` at startup; launched by **rc.d** (off init PID 1,
    `TASK_BOOTSTRAP_PORT=0`) it **SIGSEGV'd (signal 11, core dumped)** — serial: `pid 834 (syslogd) … exited
    on signal 11`. So an Apple service daemon is **launchd-job-ONLY by construction** (needs the launchd
    bootstrap to check in its service port). This is macOS-faithful (macOS has no rc.d; syslogd is purely
    launchd-managed) and is **new evidence for the (a)-vs-(b) decision**: the launchd-job run-model is
    mandatory for the daemon population, reinforcing (a) launchd-as-PID1 as the real 1.0 answer. Caveat
    cataloged: `asld` crashes ungracefully on `MACH_PORT_NULL` rather than erroring — a daemon-robustness
    divergence, not worked around (observation-first).
  - **op-212 (2026-06-29, Explorer rx1, Arranger-verified first-hand @ bdd0fdc) — 3rd manifestation: the asl-native-submit "drop" IS this gap.** op-210 made asld the live logger but the ASL *native* Mach submit (asl_log/aslutil over `com.apple.system.logger`) returned `found=0`. op-212 source-traced it: the submit CLIENT ran with `bootstrap_port==0` → `asl_core.c:110 bootstrap_look_up2(bootstrap_port, ASL_SERVICE_NAME)` fails → returns MACH_PORT_NULL → `asl.c:1132` guard SKIPS the Mach send (never reaches the kernel, never crosses port-0). This is the SAME `bootstrap_port==0` gap, now hitting the asl *client-submit* plane (after notify-client op-110 and asld-daemon-checkin op-138). The recurring `ipc_entry_lookup failed on 0` (ipc_kmsg.c:1318) is a SEPARATE benign reject (MACH_SEND_INVALID_DEST on a null dest) — the op-210 correlation was a red herring; verdict `independent`, NOT debt-#21 (MACH_RECV drains a self-allocated port, xpc_connection.c:90). **Predicted-closed under PID-1 launchd / a launchd-hosted submit client (valid bootstrap → lookup succeeds → send proceeds), but NOT yet runtime-proven** — the close is the small re-test below (folds into id-011).
  - **op-273 calendar/SIGUSR1 finding requires PID-1 activation re-census.** Current-tip source still
    composes overdue-calendar `raise(SIGUSR1)` with init-compat `SIGUSR1→RB_HALT`, but the preview's
    locked non-PID-1 `-u` run model cannot enter the halt path (`job_mig_reboot2` rejects
    `!pid1_magic`) and the product ships zero interval plists. op-289/op-290 are flushed with no cell
    or edit. The PID-1 scope promotion invalidates the old topology reason for permanent banking,
    but does not create a live `StartCalendarInterval` consumer by itself. op-318 must census the
    exact shipped PID-1 job set; any actionable follow-on receives a new ID/op because op-289/op-290
    are flushed and never reused.
  - **Preview mitigation (faithful, not a shim):** the preview image ships a launchd-job runner (plist
    template + one-line `launchctl load` helper) so the documented launch-model is one command, using the
    REAL launchd path. Carried by id-015 leg-4 (op-128). Off the build critical path — blocks nothing.
  - Surfaced by op-110 (notify), corroborated by op-116 (asl).
- raised: 2026-06-23 — op-110 cont. STOP: three launch contexts (rc.local direct, `launchctl load`
  from rc.local, boot-scan plist) all failed to reach notifyd; the only working context is the
  nxplatform-probe's own child session.
- roadmap parent: [roadmap.md](../roadmap.md) — touches the **developer-usable floor** (run Darwin
  programs against Mach/dispatch/**notify** from a shell) and **li-003** (launchd as the real
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

## op-119 characterization (Explorer rx-x64z, free; commit `17ee14f`; Arranger-verified first-hand)

The boundary is the **FreeBSD-init / launchd split**, pinned to two facts I re-verified in the product
source:
- **launchd is not PID 1.** `runtime.c:1518` sets `pid1_magic = true` **only if `getpid() == 1`**; on
  rmxOS PID 1 is FreeBSD `init(8)`, so launchd always runs `pid1_magic=false` (user-session `-u` mode).
- **`posix_spawnattr_setbport_np` does not exist** (0 occurrences tree-wide). This is the macOS
  kernel-assisted primitive by which launchd hands a bootstrap port to spawned processes; without it,
  bootstrap inheritance is limited to launchd's own posix_spawn descendants.
- Propagation map: `init → rc.d → rc.local` ⇒ **no bootstrap** (MACH_PORT_NULL). `nxplatform-probe →
  launchd -u → notifyd/syslogd/harness` ⇒ **HAVE bootstrap** (launchd's internal fork mechanism). Not a
  bug in libnotify/libasl/launchd.

## The decision space — Coordinator's b-equiv-vs-catalog call (do NOT pick reflexively)

op-119 supplied four options; mapped to our design philosophy + roadmap:
- **(a) launchd as PID 1 (init replacement)** — the **macOS-faithful** answer (Darwin IS launchd-as-PID1;
  bootstrap is ambient because everything forks from launchd). Aligns with "Mach primitives outward,
  think like Apple engineers." But fundamental + huge blast radius (boot path, rc.d, single-user,
  shutdown all reroute through launchd). The right *eventual* answer for **service-usable full 1.0**; not
  a preview move.
- **(b) kernel-level ambient bootstrap (new kernel mechanism)** — invents a mechanism macOS does NOT
  have (Darwin does this in userland via PID1+setbport_np) and touches the parked/sensitive kernel track.
  Divergent from Darwin truth → **disfavored** (Linux-inward smell at the kernel layer).
- **(c) catalog the boundary (li-005)** — apps launched *by launchd* (notifyd, syslogd, harness, any
  launchd job) HAVE bootstrap and work; only non-launchd-spawned processes are hit. Honestly-labeled,
  bounded gap "doesn't block use-case X if X launches via launchd." Cheapest; **preview-ASAP**, matches
  the roadmap's "cut scope not quality; catalog in preference to a complex/risky impl."
- **(d) hybrid: rc.d bootstrap-setup shim** — an rc.d glue layer that seeds a session bootstrap for
  non-launchd processes. A pragmatic bridge, but a **shim** (paper-over) — risks becoming a permanent
  non-faithful hack. Keep as a *tactical fallback* only if a specific preview consumer turns out blocked.

**Historical recommendation (superseded by Coordinator 2026-07-12): (c) then + (a) eventual.** The
architecture call is now made: (a) launchd-as-PID1 is required for 1.0-preview. Avoid (b) outright;
hold (d) only as a narrow fallback if the faithful hybrid is proven impossible.

## The decision hinge (what (c) actually rides on) — Coordinator-held

option (c) holds **iff** the preview's "run a Darwin program against notify" path is a **launchd-spawned
job**, not an **interactive-shell** invocation. The developer-usable floor says "build + run Darwin
programs against Mach/dispatch/**notify**" — if that means *compile-and-run-from-a-shell-prompt*, the
program is off the `init → login → shell` branch ⇒ MACH_PORT_NULL ⇒ `notify_register`/`bootstrap_look_up`
fail, and (c) does NOT cover the preview floor (would need (d) session-shim or (a)). If it means
*`launchctl load` / launchd-spawned*, (c) holds cleanly.

So the open question is the **preview program-launch model**, not the bootstrap mechanism per se.

## op-127 — preview launch-model hinge (Explorer, free; FETCHED 2026-06-24)

Discovery-only, no source edits. Resolves whether decision (c) covers the preview floor:
1. On the preview staging-model image (op-104/id-015 guest), build a minimal notify client (`notify_register_dispatch` + `notify_post` + receive) and run it **two ways**: (a) **from an interactive shell** (off `init → login → shell`), and (b) **as a launchd-spawned job** (`launchctl load` a plist).
2. For each, record first-hand whether the client gets a usable `bootstrap_port` (not MACH_PORT_NULL) and whether `notify_register`/`bootstrap_look_up` to notifyd succeeds.
3. Report which launch paths work → tells us if the preview's "build + run a Darwin program against notify" floor is satisfiable via launchd-job alone (→ (c) locks) or needs shell-launch (→ (c) escalates to (d)/(a)).
- truly-green for op-127: both launch paths characterized first-hand with the actual bootstrap-port value + notify round-trip result; no inference.

## Truly-green criterion (if fetched to fix, not catalog)

- a process spawned by system `init` (NOT a launchd child) can `notify_post`/`notify_register` and
  reach notifyd — i.e. bootstrap is genuinely ambient — verified first-hand, matching macOS.

## op-383 consult (2026-09-28)

advisor2 op-383 consult `rmx-advisor2/op-383-mach-kernel-alpha2-integration-consult.md` (433838e), risk R4 and proposal P3: demonstrate the bootstrap lineage. Show the right PID 1 installs, inherited through fork, recovered after exec, used for lookup, and kept across daemon restart, plus a deliberately unrelated process to establish how processes outside the lineage join or are excluded. Tie extract-right reachability to the real preview launch path before choosing work.

## Mach caller identity (2026-09-28, id-046 op-392 F1)

launchd trusts the audit token in each Mach message's trailer, and rmxOS sets that token only at
fork. Jobs that drop privileges after fork appear to launchd as root. The PID-1 preview's service
trust depends on the fix (id-046).

## Mach timebase and task ports (2026-09-29, id-046 op-393 N1, N5)

launchd's respawn throttle runs about 53 times too fast (N1): a crashing job respawns after about
0.19 s instead of 10 s. launchd's post-fork task-port calls act on launchd itself rather than
the child (N5). Both bear on PID-1 behavior and on reading op-391's results.

## PID-1 logging (2026-10-04, op-449, op-470)

- op-449 bounded launchd's log queue and logs through `syslog(3)` when asld is not running
  (`pid1-boot-1@21c11e10`); op-470 soak: PID-1 RSS flat (4,484/4,488 KiB vs op-445's 6,596).
- Follow-ups, small, not on the critical path:
  - launchd messages from before `syslogd` starts reach the console only (op-470 serial lines
    94-95), not `/var/log/messages`; `syslog(3)` is called without `LOG_CONS`.
  - `launchd_log_dropped()` has no caller: dropped queue entries are counted, never reported.
  - Every job stop logs `Job was sent unexpected signal: 0` at `LOG_ERR | LOG_CONSOLE`
    (`sbin/launchd/core.c:1080`, the `default:` case of the signal switch): signal 0 is an
    existence check and should not log. Previously invisible because the queue was never drained.
  - Old debug `syslog(LOG_ERR, …)` lines ("jobmgr created!!!!", "kevent_moddding") now reach
    `/var/log/messages`.
