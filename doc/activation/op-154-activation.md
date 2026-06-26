# op-154 — Explorer: COMPLETE capture of the daemon-startup freeze — resolve mach.ko symbols + walk BLOCKED threads (allproc/core), settle id-025 identity

op-154 | role: Explorer — **rmx-explorer / `explorer-rx` (rx1)**, FREE | state: **[Done]** (Fable-verified first-hand @ rmx-explorer f2f2d76, 2026-06-26) | parent id: id-025 | authored 2026-06-26 (Fable)

TERMINAL VERDICT (Fable, Rule-1 first-hand): COMPLETE capture DELIVERED — mach.ko symbols resolve + `allproc`
walked (26 procs PRS_NORMAL) + 51-thread walk, NONE in mach-IPC. **op-151's "fast-freeze" = a DETECTION
ARTIFACT** (rc.local `sleep 960` → serial-silence by design; the walk caught `pid=982 sleep`/`nanslp` + the
churn probe live in `nanslp`). The host-side complete-capture RIG is PROVEN end-to-end (primary deliverable).
id-025 is NOT refuted — it is still UNCAPTURED (the `different_wedge=1` marker is imprecise: no wedge at all at
capture time; op-150's iter≈400 freeze remains the live candidate). Methodological catch: the walk gave `wmesg`
only, and `wmesg=thread_block` is ambiguous (benign Mach msg-wait vs wedged `ipc_mqueue_receive` both block via
`thread_block`) → the REAL capture (op-155) MUST reconstruct per-blocked-thread backtraces. op-142 stays
[Hold]. Continued under **op-155** (NOT "op-154-cont"). Full analysis: idq/id-025.

---

assignment rationale: rx1 owns the id-025 line + authored the op-153 rig this extends directly. Free role, critical path.

PRECONDITION — op-153 left a PROVEN rig but an INCOMPLETE capture (Fable-verified first-hand @ rmx-explorer 3db63b9):
- The kgdb-via-bhyve-`-G` attach RIG works (`scripts/op151/op153-capture-gdb.py`). Reuse it — do NOT re-author.
- The freeze is reproducible and reaches **`Starting local daemons:` + 11× `ipc_entry_lookup failed on 0`
  (`sys/compat/mach/ipc/ipc_kmsg.c`)** — mach IS loaded + daemon startup began, THEN both CPUs go idle (HLT).
- **WHY op-153's "not id-025" verdict was REFUTED (do not repeat the error):** op-153 captured only the 2 vCPU
  contexts (`info threads` → 2 idle threads), never walked `allproc`, and its mach.ko `add-kld` failed on a
  sysroot/path issue. A bhyve `-G` stub exposes ONLY per-vCPU registers — every BLOCKED thread is descheduled
  and INVISIBLE. "Both CPUs idle" does NOT refute a deadlock: a fully-blocked userspace Mach-IPC deadlock
  parks both CPUs in HLT identically. Identity is UNRESOLVED, not refuted.

OBJECTIVE: turn the reproducible daemon-startup freeze into a COMPLETE capture — resolve mach.ko symbols AND
capture the BLOCKED thread stacks (not the idle CPUs) — and from them settle the identity: is any blocked
thread sitting in `ipc_mqueue_receive` / `ipc_mqueue_pset_receive` / mach IPC (→ id-025), or are they all in
unrelated waits (→ a genuinely different wedge, now PROVEN by stacks, not by an incomplete capture)?

SETUP (host-side, rx1's own dir/guest; reuse op-153 staging + the op-150 churn probe @ gatekeeper 4b16fd1):
- Symbols already located by op-153 — reuse: `kernel.debug` (`…/sys/MACHDEBUGDEBUG/kernel.debug`),
  **`mach.ko.debug`** (`…/block-075-alpha-final-obj/.../sys/modules/mach/mach.ko.debug`, has
  `ipc_mqueue_receive`/`ipc_mqueue_pset_receive`/`thread_pool_wakeup`).
- FIX the symbol resolution: `set sysroot` / `set solib-search-path` to the guest's `/boot/kernel` +
  `/boot/modules` (+ the matching `.debug` dirs) so `add-kld mach <mach.ko.debug>` actually resolves. Verify:
  `info address ipc_mqueue_receive` returns a real address BEFORE trusting any stack.

CAPTURE — pick by feasibility (either gives blocked-thread stacks; (a) is the gold standard):
- **(a) KERNEL CORE DUMP (allproc-aware):** configure a dump device in the guest image (`dumpon` + a dump/swap
  partition; `rc.conf` `dumpdev`). On freeze, force a dump — NMI→panic→dump, or from kgdb `call doadump()`, or
  `sysctl debug.kdb.panic` if reachable. Then `kgdb kernel.debug vmcore.N` — kgdb walks EVERY thread
  (`info threads` enumerates allproc, `thread apply all bt` gives all blocked stacks). Commit the bt TEXT.
- **(b) LIVE allproc WALK from the stub (no dump device):** with full symbols, from kgdb read `allproc`,
  iterate the proc/thread lists, and for each non-running thread reconstruct its stack from `td_pcb`
  (`pcb_rbp`/`pcb_rip`). Tedious but needs no guest dump config.
- NOTE: op-151 found DDB wedged under the freeze — BUT that was a 99%-CPU spin run; op-153 shows the CPUs
  IDLE. On an idle (not spinning) kernel, NMI→DDB `ps`/`bt`/`alltrace` may actually work now — cheap to try
  as a cross-check against (a)/(b).

DELIVERABLE / GATE:
- `info threads` enumerates **>2 threads** (real allproc walk, not just the 2 vCPUs) + mach.ko symbols
  resolved + the blocked stacks captured.
- **Any blocked thread in `ipc_mqueue_receive` / `ipc_mqueue_pset_receive` / mach IPC** → the id-025 stack is
  CAPTURED → BREAKTHROUGH (the real one) → op-142 releases to **fix-and-prove against THIS stack**.
- **All blocked threads in unrelated waits** (userspace mutex, device/timeout, a non-Mach rc.d wait) → the
  daemon-startup freeze is a DIFFERENT wedge, now PROVEN by actual stacks → re-scope it as its own id; op-142
  stays [Hold]; separately pursue op-150's iter≈400 freeze as the remaining id-025 candidate.
- Neither (a) nor (b) yields a walk → escalate (in-kernel ring buffer is a kernel change — Coordinator-gated).

METHOD (op-147m): Elixir orchestrates (extend the op-153 driver: dump-config / symbol-set / freeze→dump);
kgdb + the core/allproc walk = the host-side EVIDENCE layer (survives the wedge); reuse the op-153 Python
capture one-shot (observation only). No big shell harness. `.d` watchpoint = detector only.

MARKERS (Elixir-driven):
```
OP154_SYMBOLS_RESOLVED status=0          # add-kld mach resolves; info address ipc_mqueue_receive = real addr
OP154_BLOCKED_THREADS_CAPTURED count=0   # n>2 — real allproc walk, not just the 2 idle vCPUs
OP154_THREAD_IN_MACH_IPC status=0        # a blocked thread in ipc_mqueue_receive/pset_receive/mach IPC
OP154_IDENTITY_VERDICT id025=0 different_wedge=0
OP154_TERMINAL status=0
```

PUSH: explorer branch (rx1); commit the resolved-symbol capture script, the BLOCKED-thread backtraces (or the
vmcore-derived `thread apply all bt` TEXT — NOT the multi-GB vmcore itself), the identity analysis. Report SHA
→ Fable first-hand verify → Coordinator. PUSH to origin.

CHAIN (id-025): op-148 (watchpoint) → op-150 (freeze, no dump) → op-151 (repro, "is id-025" OVER-claimed) →
op-153 (rig PROVEN, "not id-025" REFUTED — capture saw only idle vCPUs) → **op-154** (this: complete capture
with blocked threads) → op-142 [Hold] (releases on a real mach-IPC blocked stack; else re-scope + chase
op-150's iter≈400 freeze) → notify leg-4 / id-010 disposition.
