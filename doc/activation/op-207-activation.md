# op-207 — Implementer: dynamic-link the static-libdispatch ASL tools (asld + aslutil) → close the op-205 census-found latent-SIGSEGV class

op-207 | role: **Implementer** (cost-30) | EXU: **wip-gpt** | state: **[Done — tools-run @ 986be5d; Arranger verified first-hand]** (2026-06-29). Both Makefiles now dynamic-link the Darwin runtime; verified `readelf -d` on the handoff binaries: **asld.op207** (sha 0c2fe9d) + **aslutil.op207** (sha 78266c3) NEEDED now carries libdispatch.so.5/libthr.so.3/libmach.so.5/libsys.so.7 (mirrors notifyd/op-204) and **zero** local `__elf_aux_vector`/`dl_init_phdr_info`/`__init_elf_aux_vector` symbols → the 0x309b7b NULL-deref root is structurally eliminated on both. asld rc=1 is the clean post-main launchd-checkin exit (reaches main + starting line, fails `LAUNCH_KEY_CHECKIN` run bare, exits cleanly — NOT the SIGSEGV; OP207_NO_CORE), aslutil rc=0. **op-205 latent-SIGSEGV class CLOSED** (aslmanager op-204 + asld/aslutil op-207 = all 3 fixed). **WIRING (Implementer-checked, D3): asld is staged-but-NOT-boot-wired in the current preview lineage** — `com.apple.syslogd.plist` points at FreeBSD `/usr/sbin/syslogd`, boot log runs FreeBSD rc syslogd → asld's crash was LATENT (not loaded), would NOT have crashed the current boot. SOURCE fixed for all 3; a future image rebuilt from HEAD carries the fixed binaries (the current 707936a6 image still holds the old static asld, harmless because unwired). Follow-on finding (track, not this op): asl is NOT the active system logger in the preview — FreeBSD syslogd is; bears on asl core-service readiness (id-011/li-1004). | parent id: id-011 (asl, leg-4) | L1i: li-1004 | cost: 30 | authored 2026-06-29 (Arranger seat, model Opus 4)

## WHY (one line)

op-205 census found the op-204 static-libdispatch startup-SIGSEGV signature is NOT a one-off: `asld` (the ASL syslog daemon — Arranger-verified MISSED by the census + falsely cleared) and `aslutil` both static-link libdispatch.a (NEEDED=libc.so.7-only + local `__elf_aux_vector`), so both SIGSEGV before main() via libdispatch's load-time ctor → `dl_init_phdr_info` → NULL `__elf_aux_vector` (the exact op-204 mechanism). asld is a boot-path daemon → a metal/dogfood preview boot would crash system logging at startup. Fix both the same way op-204 fixed aslmanager.

## ROOT CAUSE (already proven — do NOT re-derive; op-204 is authoritative)

Static-linked libdispatch.a + libthr.a flips the libdispatch load-time constructor (`libdispatch_init`, queue.c:935, run by ld-elf.so.1) ahead of csu's `__elf_aux_vector` setup → `_dispatch_thread_key_create` → `pthread_key_create` → `_thr_rtld_init` → libc `dl_init_phdr_info` (dlfcn.c:180) iterates a NULL `__elf_aux_vector` → SIGSEGV (addr 0x309b7b), arg-independent, before main. Working Darwin daemons (notifyd) link libdispatch.so.5/libthr.so.3 DYNAMICALLY → ctor ordering runs after libc init → no crash. **Arranger-verified the suspects first-hand:** `usr.sbin/asl/Makefile` (PROG=asld) + `usr.bin/aslutil/Makefile` both carry the static `--start-group ${OBJLIB}/{…,libdispatch,libthr,libsys,…}.a --end-group` block; the built asld in the op-149 v3 + op-182 cert obj has NEEDED=libc.so.7-only + `__elf_aux_vector` present.

## SCOPE / SUBJECT (EDITABLE — rmxOS overlay, userland only)

- `usr.sbin/asl/Makefile` — `PROG=asld`, static `--start-group` LDADD block (the libdispatch.a/libthr.a/libsys.a archives are the crash drivers).
- `usr.bin/aslutil/Makefile` — `PROG=aslutil`, identical static block.
- Reference the PROVEN fix: op-204's `usr.sbin/aslmanager/Makefile` change @ 15696df (replaced the static `--start-group ${OBJLIB}/*.a` archives with shared LIBADD libdispatch/libthr/libmach/libsys/… so NEEDED carries libdispatch.so.5 like notifyd). Mirror it for both.
- CONFIRM FIRST there's no load-bearing reason asld must be static (early-boot-before-.so's): notifyd is also a launchd daemon and links dynamically, and asld loads post-mount via launchd — so dynamic should be safe; verify asld's intended launchd invocation doesn't require a static binary.

## DELIVERABLES

**D1 — both Makefiles dynamic-link the Darwin runtime.** asld + aslutil link the SHARED libdispatch.so/libthr.so/… (mirror op-204/notifyd), not the static `--start-group` archives, so the ctor ordering matches the working daemons. → `OP207_LINK_FIX`

**D2 — prove both RUN, first-hand.** On YOUR build: `asld -h` (or its real no-crash startup path — asld is a daemon; if `-h` isn't supported, a controlled start that reaches its main/serial banner) and `aslutil -h` return NON-139, reach main, no core. rc=139 GONE, backtrace gone (not a different crash). Confirm NEEDED now carries libdispatch.so.5 on both. → `OP207_RUNS`

**D3 — disposition + preview-presence check.** Deliver the fixed binaries + NEEDED lists to the build dir. Note whether asld is actually staged/wired in the preview image lineage (op-149 707936a6) — if present, this was a live boot-path crasher now fixed; record it. Do NOT run a reclaim/integration soak yourself (soak_is_gatekeeper). → `OP207_VERDICT` (`tools-run` | `walled`) / `OP207_TERMINAL`

## BOUNDARIES
- Userland overlay only — edit the two `Makefile`s (+ at most the daemons' own link config); NO FB15 build-infra / share/mk / libc / libthr / libdispatch SOURCE edits (userland_port_no_buildinfra_changes). If either crash genuinely needs a libdispatch/libthr/csu source change, that's a FINDING to REPORT (it would affect the whole static-libdispatch class), not a fix here.
- Build is Implementer (build_is_implementer); stage in wip-gpt owned dir (agent_host_isolation). Do NOT run a soak.
- Verify first-hand that each binary REACHES main (rc≠139 + no core), not just "compiles/links" — the whole defect is a clean-link binary that crashes before main (no_conflate_gating_with_readiness; background_exit_code_hygiene).

## MARKERS
```
OP207_LINK_FIX   # asld + aslutil Makefiles link libdispatch.so/libthr.so dynamically (mirror op-204/notifyd), not static --start-group
OP207_RUNS       # asld + aslutil reach main, rc != 139, no core; NEEDED now carries libdispatch.so.5 — first-hand per binary
OP207_VERDICT    # tools-run | walled
OP207_TERMINAL
```

## RELATIONS
- UPSTREAM: op-205 [Done — census-found, Arranger-corrected] (found aslutil, MISSED asld — Arranger added asld first-hand: same signature on the v3+cert obj); op-204 [Done] (the authoritative aslmanager fix this mirrors).
- DOWNSTREAM: closes the op-205 latent-SIGSEGV class for the preview. asld fixed = the ASL daemon won't crash a metal/dogfood boot. Feeds the preview de-risk + (if asld is wired) the asl core-service readiness.
- feedback: build_is_implementer, soak_is_gatekeeper, userland_port_no_buildinfra_changes (Makefile link change, not a libc/libthr source edit), no_conflate_gating_with_readiness (rc=139 before main despite a clean link), verify_signature_divergence_claims (the census falsely cleared asld — Arranger refuted via readelf on the shipping obj; build on the corrected set), agent_host_isolation, background_exit_code_hygiene. project: 10preview_gate (asl core service), launchd_no_autoscan (asld loads via launchd, inert until rc.local loads it).
```
