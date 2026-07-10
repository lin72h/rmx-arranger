# op-204 — Implementer: fix the aslmanager startup SIGSEGV (static libdispatch ctor derefs NULL __elf_aux_vector before main) → unblock asl leg-4 reclaim

op-204 | role: **Implementer** (cost-30) | EXU: **wip-gpt** | state: **[Done — aslmanager-runs @ 15696df; Arranger verified first-hand]** (2026-06-29). Fix = exactly the diagnosed one: `usr.sbin/aslmanager/Makefile` now dynamic-links the Darwin runtime (LIBADD libdispatch/libthr/libmach/… shared) instead of the static `--start-group` archives (+ removed obsolete MK_PIE=no). VERIFIED: handoff binary `aslmanager.op204` sha `301bfb1d…` NEEDED now carries libdispatch.so.5/libthr.so.3/libsys.so.7 (mirrors notifyd) and the local static `__elf_aux_vector`/`dl_init_phdr_info`/`__init_elf_aux_vector` symbols are GONE → the 0x309b7b NULL-deref root is structurally eliminated. Guest serial (sha `7880fa7f…`): `aslmanager starting` line PRESENT (reached main), OP204_HELP rc=0 + OP204_STORE rc=0 (`-h` and `-s -size 500K -d` both ≠139), zero signal-11, no core. Correctly did NOT run the reclaim soak (soak_is_gatekeeper → op-198 v5). | parent id: id-011 (asl, leg-4) | L1i: li-1004 | cost: 30 | authored 2026-06-29 (Arranger seat, model Opus 4)

## WHY (one line)

aslmanager SIGSEGVs (rc=139) on EVERY invocation — before main(), arg-independent (`-h`, no-args, real args all crash). Reproduced first-hand on the op182 clean-cert build + a genuine core dump (`from 'aslmanager -h', pid=19871`). The reclaim logic (SIZE/TTL/YMD passes) is source-present + macOS-faithful but UNREACHABLE because the binary dies at load time. Fix the startup crash so asl leg-4 reclaim can finally be soaked (op-198 re-runs after).

## ROOT CAUSE (Arranger-verified first-hand via gdb on the op182 build — do NOT re-derive, but confirm on YOUR build HEAD)

Authoritative backtrace (crash addr 0x309b7b):
```
#9 libdispatch_init()        lib/libdispatch/src/queue.c:935   <- LOAD-TIME CONSTRUCTOR (invoked by ld-elf.so.1)
#8 _dispatch_thread_key_create
#7 _thr_key_create(dispatch_queue_key)                          libthr thr_spec.c
#5 _libpthread_init  #4 _thr_rtld_init                          libthr thr_rtld.c:253
#3 _rtld_get_stack_prot  #0 dl_init_phdr_info                   libc gen/dlfcn.c:180
   -> for (auxp = __elf_aux_vector; auxp->a_type != AT_NULL; auxp++)  // __elf_aux_vector == NULL -> SIGSEGV
```
- The gatekeeper's address (0x309b7b) + "NULL global" observation are CORRECT, but its symbol/struct attribution ("_dl_iterate_phdr_locked / _r_debug near environ") is WRONG. It is libc `dl_init_phdr_info` dereferencing a NULL `__elf_aux_vector` (the ELF auxiliary vector), triggered by **libdispatch's load-time constructor running pthread TSD init before csu has populated `__elf_aux_vector`**. Do NOT chase the gatekeeper's weak-ref-`_r_debug` fix — it targets the wrong struct.
- **WHY aslmanager specifically (the diagnostic contrast):** aslmanager NEEDED = `libc.so.7` ONLY — it STATIC-links libdispatch.a + libthr.a + the Darwin runtime via `usr.sbin/aslmanager/Makefile:44-52` (`--start-group` of `${OBJLIB}/*.a`). Every WORKING Darwin daemon links them DYNAMICALLY — e.g. notifyd NEEDED carries `libdispatch.so.5`, `libthr.so.3`, `libmach.so.5`, … (op-165 soak proves notifyd runs fine). Static libdispatch flips the constructor init ordering ahead of the aux-vector setup → the NULL deref. Dynamic .so init runs after libc is ready → no crash.

## SCOPE / SUBJECT (EDITABLE — rmxOS overlay, userland only)

- `usr.sbin/aslmanager/Makefile` @ the rmxOS overlay HEAD (record the HEAD you build). The static `--start-group` LDADD block of `${OBJLIB}/{libdispatch,libthr,…}.a` (lines ~44-52) is the suspect.
- Reference the PROVEN-WORKING link pattern: how `usr.sbin/notifyd/Makefile` (or another libdispatch daemon) links the Darwin runtime dynamically (libdispatch.so.5/libthr.so.3). Mirror that.

## DELIVERABLES

**D1 — fix the link so the libdispatch/libthr constructor runs after libc init.** Least-intrusive, macOS-faithful path: link aslmanager against the SHARED Darwin runtime (libdispatch.so/libthr.so/…) like notifyd, instead of the static `--start-group` archives — so the ctor ordering matches the working daemons. (Alternative only if dynamic-link is genuinely infeasible: fix the constructor/aux-vector init ordering — but prefer matching the proven dynamic pattern.) CONFIRM FIRST: there is no load-bearing reason aslmanager must be static (early-boot-before-.so's etc.); notifyd is also a daemon and links dynamically, so this should be safe — but verify aslmanager's intended invocation (launchd job, post-mount) doesn't require static. → `OP204_LINK_FIX`

**D2 — prove it RUNS, first-hand.** On YOUR build: `aslmanager -h` and `aslmanager -s <store> -size 500K -d` return NON-139 (reach main, parse args, emit the `aslmanager starting` debug line) — rc=139 GONE, no core dumped. Confirm the backtrace is gone (not just a different crash). → `OP204_RUNS`

**D3 — hand off to op-198 re-soak.** Deliver the fixed binary + its NEEDED list (should now carry libdispatch.so.5 etc., like notifyd) into the build dir for the Gatekeeper. Do NOT run the reclaim soak yourself (soak_is_gatekeeper) — op-198 v5 consumes this binary to finally test the store-bound criterion. → `OP204_HANDOFF`

**VERDICT:** `aslmanager-runs` (rc≠139, reaches main, emits debug line, no core — fixed binary handed to op-198) | `walled` (the fix needs more than the link change / a libdispatch or libthr SOURCE change — REPORT the actual blocker, do not force). → `OP204_VERDICT` / `OP204_TERMINAL`

## BOUNDARIES
- Userland overlay only — edit `usr.sbin/aslmanager/Makefile` (and at most the daemon's own link config); NO FB15 build-infra / share/mk / libc / libthr / libdispatch SOURCE edits (userland_port_no_buildinfra_changes). If the crash genuinely needs a libdispatch/libthr/csu source fix (constructor ordering, aux-vector init), that is a FINDING to REPORT (it would affect every static-libdispatch binary), not a fix to apply here.
- Build is Implementer (build_is_implementer); stage in wip-gpt owned dir (agent_host_isolation). Do NOT run the reclaim soak — hand the binary to op-198 (soak_is_gatekeeper).
- Verify first-hand that the binary REACHES main (rc≠139 + the `aslmanager starting` line), not just "compiles/links" — the whole defect is a clean-link binary that crashes before main (no_conflate_gating_with_readiness; background_exit_code_hygiene).

## MARKERS
```
OP204_LINK_FIX   # aslmanager links the Darwin runtime dynamically (libdispatch.so/libthr.so) like notifyd, not static --start-group archives
OP204_RUNS       # aslmanager -h / -size run reach main, rc != 139, emit `aslmanager starting`, no core — first-hand
OP204_HANDOFF    # fixed binary + NEEDED list delivered to the build dir for op-198 v5 re-soak
OP204_VERDICT    # aslmanager-runs | walled
OP204_TERMINAL
```

## RELATIONS
- UPSTREAM: op-198 v4 [Held] (MANAGER-BINARY-BROKEN finding `rmx-gatekeeper/findings/op198-v4-aslmanager-sigsegv.txt` + core; this fixes the startup crash it surfaced); op-196 [Done] (wired aslmanager into the image — but the binary it staged is the broken one); op-170 (reclaim semantics, source-faithful — the logic is fine, it's just unreachable).
- DOWNSTREAM: op-198 v5 (Gatekeeper) re-runs the asl leg-4 reclaim soak on the FIXED binary — the store-bound criterion (id-011) can finally be evaluated. asl is 1 of 4 core preview services (10preview_gate).
- NOTE (broader, do NOT expand here): if ANY other shipped binary static-links libdispatch the same way, it has the same latent crash — flag for a census if you spot it, but this op fixes aslmanager only.
- feedback: no_conflate_gating_with_readiness (rc=139 before main despite a clean link — "links" ≠ "runs"), build_is_implementer, soak_is_gatekeeper, userland_port_no_buildinfra_changes (Makefile link change, not a libc/libthr source edit), agent_host_isolation, background_exit_code_hygiene, verify_signature_divergence_claims (the gatekeeper's mechanism symbol was wrong — Arranger corrected it via gdb; build on the corrected root cause). project: 10preview_gate (asl core service), launchd_no_autoscan (the plist that staged it is StartCalendarInterval-only — also why v3 never triggered it).
```
