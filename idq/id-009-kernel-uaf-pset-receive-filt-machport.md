# id-009 — kernel use-after-free: `ipc_mqueue_pset_receive` via `filt_machport` (compat/mach IPC)

- id: id-009
- state: **RETIRED — fix `e101f9c` PROVEN both halves (correctness op-109 + under-load op-108).**
  op-107 landed commit `e101f9c1872e` on `alpha` (+2 with op-106, push held) — Arbiter-verified
  sound first-hand (see §Fix landed). **op-109 (Validator review) RETIRED: GLM 9/10 + DS4P 9/10
  PASS** — ref-balance sound across all 7 exit/restart paths, ABA blocked by the temp ref,
  `ip_active` sufficient, restart O(N²)-bounded not livelock. **op-108 (Gatekeeper 2h proving
  soak) ACCEPTED 2026-06-23** (Arbiter-verified first-hand): fresh symbol-verified `e101f9c`
  kernel (`mach.ko` 7c8a710d; objdump-differential 1 `ip_reference` + 3 `ip_release` in
  `ipc_mqueue_pset_receive` vs 0/0 pre-fix — confirmed against product source), 27293 iters / 0
  fails / 0 panic / exit 0 over 2h under the *identical* config that GPF'd op-105 on iter 1; port
  delta=2 FLAT across 120 checkpoints (no leak). Disposition `80dd4d4` (gatekeeper repo, +2 ff,
  push held). **op-105 RETIRED on this pass.** UAF window closed; nothing open.
- raised: 2026-06-23 (op-105 2h soak, first-iteration kernel panic)

## Fix landed — op-107 (`e101f9c1872e`, Arbiter-verified 2026-06-23, sound-on-inspection)

`sys/compat/mach/ipc/ipc_mqueue.c` (+19, single file). Variant = **temp reference + revalidate**:
`ip_reference(port)` (atomic, `ipc_object.h:188`) is taken *before* `ips_unlock(pset)`, then after
reacquiring the pset lock it revalidates `ip_active(port) && port->ip_pset == pset &&
port->ip_msgcount != 0`, else `ip_release` + restart. Temp ref released on all exit paths.

Both load-bearing locking assumptions confirmed first-hand:
1. `ip_reference` = `atomic_add_int` (lock-free) — safe to take holding only the pset lock.
2. The freer `ipc_port_clear_receiver` (`ipc_port.c:624-628`) unlinks the port from `ips_ports`
   via `ipc_pset_remove` **under `ips_lock(pset)`** — so "in-set under our pset lock ⇒ not yet
   freed ⇒ `io_references > 0`", which is exactly what the atomic ref needs to pin the memory
   across the lock-drop window. Preserves the port→pset (teardown) vs pset→port (receive) lock
   ordering the drop exists to avoid (ABBA).

Caveat: **sound-on-inspection ≠ race-proven.** Smoke found NO bounded repro on the *unfixed*
image (120s ran clean, matching op-104) — so the 120s smoke cannot confirm the fix; only op-108's
2h soak (the config that hit it on iter 1) can. Unfixed-image serial: `87c86c0a…`; fixed mach.ko
sha256 `7c8a710d…`.
- roadmap parent: [roadmap.md](../roadmap.md) — **Gate A (mach-ipc invariants) blocker** and a
  hard blocker on the libdispatch Gate-D soak (id-006/id-007). A kernel UAF under sustained
  dispatch load is exactly the class of defect "service-usable 1.0" cannot ship with.
- relations: **op-098** (proved the `filt_machport` kqueue path for a *single* MACH_RECV
  round-trip — the bug is under *concurrent create/destroy churn*, not the basic path);
  **id-006/op-105** (the soak that surfaced it); **op-104** (120s/451-iter proof did NOT hit it —
  intermittent race).

## The crash (explorer evidence, op-105)

First iteration of the 2h soak panicked; guest sat in the kernel debugger (`db>`), which is why
the background task looked "stuck" (not powering off). Serial sha
`a60387a55adf75bb9b9c093fe3b20f8b47863af666d9903160af8b8a48342994`.

```
Fatal trap 9: general protection fault while in kernel mode
rcx: deadc0dedeadc0d8  rax: deadc0dedeadc0de        ← DEADC0DE poison (freed memory)

ipc_mqueue_pset_receive()  +0xbf   ← locks a mutex on freed memory
filt_machport()            +0x269  ← kqueue MACHPORT filter knote callback
kqueue_scan() → kern_kevent() → sys_kevent()
current process = 2515 (harness)
```

## Root cause — first-hand confirmed mechanism (Arbiter read, 2026-06-23)

`sys/compat/mach/ipc/ipc_mqueue.c:644` `ipc_mqueue_pset_receive`, the port-walk lock dance:

```c
TAILQ_FOREACH(port, &pset->ips_ports, ip_next) {     // 658
    if (port->ip_msgcount != 0) {
        if (ip_lock_try(port) == 0) {
            ips_unlock(pset);                         // 663  drops pset lock
            ip_lock(port);                            // 664  locks port mutex  ← GPF here
            ips_lock(pset);                           // 665
        }
        break;
    }
}
```

The caller `ipc_mqueue_receive` holds a reference on the **port set** (`io_reference`,
ipc_mqueue.c:745) — but the **individual member ports in `ips_ports` are not ref-held** across
the walk. Lines 663-665 drop the pset lock and then take the port lock. A concurrent
`dispatch_source` MACH_RECV teardown that removes+frees that port during this window leaves
`port` dangling → `ip_lock(port)` operates on a freed (DEADC0DE-poisoned) mutex → GPF. The
`filt_machport` knote enters this path on kqueue MACHPORT events, so the soak's MACH_RECV
create/destroy churn drives both the receive walk *and* the concurrent port frees.

**Confidence:** the lock-drop window + unreferenced member-port lifetime is confirmed first-hand
in the source and matches the panic site/poison/trigger. NOT yet pinned first-hand: the exact
concurrent freer (which teardown path removes the port from `ips_ports` and frees it) — the fix
op confirms that and the precise serialization gap.

## Scope — three roles, do NOT collapse into one op

The fix, the evidence capture, and the proving soak are three different pipelines. The
Implementer must NOT run the 2h soak itself (author proving its own fix; wrong environment +
wrong role). The proving soak is a **fixed-bar regression gate** → Gatekeeper, not discovery.

**(1) Implementer fix op (op-107) — kernel, careful. Closes at fix + smoke-test.**
- **Diagnose:** confirm the concurrent port-destroy path and the exact unserialized window
  (DTrace `fbt::ip_lock`/`fbt::ipc_port_destroy` correlated with `filt_machport`, or KASAN-style
  reasoning on `ips_ports` membership vs port lifetime).
- **Fix candidate (Implementer to confirm):** hold a reference on the candidate port *before*
  dropping the pset lock (and release after), OR re-validate the port is still in the set + active
  after reacquiring the pset lock (re-`restart` if not), so a freed port is never dereferenced.
- **Smoke-test only:** a short bounded run (e.g. the op-104 120s/451-iter proof pattern) to
  confirm the fix doesn't panic immediately. NOT the 2h soak — that is the Gatekeeper's. Hand
  off when the smoke passes.

**(2) Explorer — commit the op-105 panic vector** into the evidence/mismatch record (serial
sha `a60387a5…`, the GPF/DEADC0DE capture). This is already an Explorer capture; just land it
(merge origin/main before push, never force-push — id-007 branch divergence).

> One-time exception (Coordinator, 2026-06-23): op-107's in-flight soak is allowed to finish
> this once. The go-forward rule stands — from the next fix on, the long proving soak is
> **issued to the Gatekeeper**, never run by the Implementer.

**(3) Gatekeeper proving soak (separate op, gated on op-107 landing) — RETIRES op-105.**
Re-run the 2h soak to completion (`soak_duration=7200`, `soak_fails=0`, no panic) on
`rmx-gatekeeper-rx-x64z`, reusing the op-104 oracle + driver as the regression harness. This
is a fixed-bar disposition (admit/block op-105's retirement), the Gatekeeper's defining
function — not discovery, so it does not return to the Explorer. This is the acceptance op-105
could not meet.

## Notes

- This is a **product kernel-source** change (compat/mach) → Coordinator-owned, careful blast
  radius. Isolate from pure additions per repo-strategy (merge-based; one focused commit).
- Do NOT weaken to a workaround in libdispatch userland — the defect is kernel-side serialization;
  fix it there (consistent with "Mach primitives outward" + least-intrusive donor>XNU-ref>local).
