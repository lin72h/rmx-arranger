# op-153 — Explorer: hypervisor-level (bhyve -G / kgdb) capture of the id-025 deadlock stack + confirm identity

op-153 | role: Explorer — **rmx-explorer / `explorer-rx` (rx1)**, FREE | state: READY dispatch (authorized) | parent id: id-025 | authored 2026-06-26 (Fable)
assignment rationale: rx1 owns the id-025 line + authored the op-151 repro rig this builds directly on. Free role, critical path.

PRECONDITION — op-151 left the rig in place (Fable-verified first-hand @ rmx-explorer 8b6b106):
- The deterministic reproducer is CONFIRMED: 3/3 froze at ~1–4 min on the golden `build/op123-leg4/leg4-soak.img`
  + the op-150 churn probe (gatekeeper 4b16fd1). 60s baseline ran clean (`iter=60 fails=0`) → probe is NOT the
  culprit. Reuse the op-151 Elixir rig (`lib/rmx_os_oracle/id025/{repro_conductor,freeze_surviving_capture}.ex`)
  + the TCP-serial capture (`scripts/op151/op151-capture-ddb.py`). Do NOT re-author the repro.
- op-151 proved DDB-via-NMI is INSUFFICIENT: NMI lands, kernel responds (`going to debugger`), bhyve goes
  0%→99%, but DDB **echoes commands and produces no output** — the wedge holds a mutex DDB needs, so DDB
  self-deadlocks. A hypervisor-level vCPU debugger (bhyve `-G` gdb stub) bypasses DDB entirely. This op IS
  that finish.

UNPROVEN — DO NOT ASSUME (the load-bearing caution): op-151's `OP151_FINGERPRINT_MATCH=1` is OVER-CLAIMED.
The op-148 watchpoint **never emitted a single `OP148_HB`** because the freeze happens in the launchd+notifyd
SETUP path, BEFORE the churn probe/watchpoint start — so the op-123 port-slope/dead-name fingerprint was never
measured. Only coarse signals matched (STAT=IC + 0% CPU + NMI-responsive software deadlock — necessary, not
sufficient). The ACTUAL signal is a NEW, specific one: an `ipc_entry_lookup failed on 0` storm at
`sys/compat/mach/ipc/ipc_kmsg.c:1318` during "Starting local daemons:". op-153's JOB is to settle the
identity — is this the notifyd Mach-IPC deadlock (id-025), or a DIFFERENT boot-time Mach IPC wedge?

OBJECTIVE: capture the blocked-thread backtraces + lock owners across a real freeze via the bhyve gdb stub,
and from them CONFIRM (or refute) that this freeze is the id-025 notifyd Mach-IPC deadlock — the stack DDB
could not give. This is the evidence that lets op-142 reshape from race-hunt to fix-and-prove.

SETUP (host-side; host-isolation = rx1's own dir/guest, not rx2/op-140):
- `pkg install gdb` on the host (provides `kgdb` + `gdb` with the FreeBSD target). Record version.
- Relaunch bhyve with the gdb stub: `-G <port>` (e.g. `-G 12345`) alongside the existing TCP-serial backend.
- Keep the op-151 freeze-detect (serial-silence >90s + bhyve still alive) as the TRIGGER.

STEPS / DELIVERABLE:
1. On freeze-detect: attach `kgdb <kernel.debug>` then `target remote :<port>` (vCPU-level — works even with
   DDB wedged). Pull: `info threads`, `thread apply all bt`, the blocked threads' backtraces, and the
   owner/holder of any contended lock. Capture to a committed log.
2. IDENTIFY the deadlock: which threads, which locks, which IPC path — name them from the stacks. Do NOT
   stop at "it's wedged"; produce the lock-cycle / blocked-on-what.
3. CORRELATE to `ipc_kmsg.c:1318`: read that source line first-hand (name-0 = MACH_PORT_NULL entry lookup).
   Is the `entry_lookup failed on 0` storm the CAUSE (a spin/retry that wedges) or a SYMPTOM downstream of the
   real block? State which, with evidence.
4. IDENTITY VERDICT: notifyd Mach-IPC deadlock (id-025) — same locks/path as the op-123 characterization — OR
   a different boot-time wedge. This SUPERSEDES op-151's unproven fingerprint claim.

METHOD (op-147m — live-system capture op, pillar applies):
- **Elixir = orchestration**: extend `repro_conductor.ex` to launch with `-G`, detect freeze, drive the gdb
  attach + command script, collect output. No big shell harness.
- **gdb/kgdb = the capture** (host-side, survives the full-guest freeze): the EVIDENCE layer. A thin
  Python/one-shot for the attach+command-script is fine (observation only, op-151 precedent).
- **DTrace `.d`**: the op-148 watchpoint stays as a freeze DETECTOR up to onset; it cannot capture the wedge
  (dies with the guest) — do not rely on it for evidence.

GATE / VERDICT:
- Blocked stacks CAPTURED + deadlock IDENTIFIED as the notifyd Mach-IPC deadlock (locks/path match op-123) →
  fingerprint TRULY matched → BREAKTHROUGH completes → op-142 reshapes to **fix-and-prove against THIS stack**.
- Stacks captured but it's a DIFFERENT wedge (not the notifyd soak deadlock) → FINDING: the op-150/op-151
  fast-freeze is decoupled from the original id-025 soak deadlock; re-scope (the fast-freeze becomes its own
  id, id-025 stays the rare soak race). Either outcome is a win — it ends the guessing.
- gdb stub ALSO cannot introspect (unlikely — it's vCPU-level, below the kernel) → escalate: kernel core dump
  (`dumpdev` + forced panic) or in-kernel ring buffer (kernel change — Coordinator-gated) become the options.

MARKERS (Elixir-driven):
```
OP153_GDB_INSTALLED status=0
OP153_GDB_STUB_ATTACHED status=0            # target remote to bhyve -G across a real freeze
OP153_BLOCKED_STACKS_CAPTURED status=0      # the stacks DDB could not give
OP153_DEADLOCK_IDENTIFIED status=0          # threads + locks + IPC path named
OP153_IPC_KMSG_1318 cause=<0|1> symptom=<0|1>   # entry_lookup-failed-on-0: cause vs downstream
OP153_IDENTITY_VERDICT notifyd_ipc_deadlock=<0|1> different_wedge=<0|1>
OP153_FINGERPRINT_TRULY_MATCHED status=<0|1>    # supersedes op-151's unproven claim
OP153_TERMINAL status=0
```

PUSH: explorer branch (rx1); commit the captured backtraces + lock dump, the gdb-stub capture rig (Elixir
extension + attach glue), the `ipc_kmsg.c:1318` source analysis, the identity verdict. No multi-GB cores/images.
Report SHA → Fable first-hand verify → Coordinator. PUSH to origin (op-150/op-151 lesson: local-only commits
aren't fetchable by peers).

CHAIN (id-025): op-148 (watchpoint, 23eb927) → op-150 (freeze recurred, no dump) → op-151 (repro CONFIRMED
3/3 + DDB insufficient, 8b6b106) → **op-153** (this: hypervisor-level stack capture + deadlock identity) →
op-142 [Held] (reshapes to fix-and-prove on the captured stack IF identity confirms id-025; else re-scope) →
notify leg-4 / id-010 disposition.
