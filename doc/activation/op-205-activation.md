---
id: op-205
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-205 — Explorer: static-libdispatch latent-SIGSEGV census — sweep shipped Darwin binaries for the op-204 aslmanager startup-crash signature → de-risk the preview before it bites

op-205 | role: **Explorer** (FREE) | EXU: **rx-x64z** (rmx-explorer / rx1) | state: **[Done — census-found, but CENSUS INCOMPLETE / one suspect MISSED; Arranger corrected first-hand @ 6e8d6f9]** (2026-06-29). Reported `census-found` = 2 crashers (aslmanager fixed, aslutil new) + "asld SAFE (dynamic), preview de-risked, both LOW." **Arranger REJECTS the de-risked conclusion: the census MISSED asld and FALSELY cleared it.** First-hand refutation: `usr.sbin/asl/Makefile` (`PROG= asld`) STILL static-links libdispatch.a via the identical `--start-group ${OBJLIB}/libdispatch/libdispatch.a … libthr.a … libsys.a --end-group` block (the aslmanager/aslutil signature); the explorer's cited "op-143 fix for asld" is absent from that Makefile's git history AND there is no op-143 doc. `readelf -d` on the ACTUAL built asld in BOTH the op-149 v3 image obj (`…/op149-alpha-x86-64-v3/obj-op171-clean/…/usr.sbin/asl/asld`) AND the op-182 clean-cert obj: **NEEDED = libc.so.7 ONLY** (no libdispatch.so.5) + **`__elf_aux_vector` local symbol PRESENT** — identical to aslmanager. asld is the ASL **syslog daemon** (launchd-loaded, boot-path) → the HIGHEST-priority crasher of the set, not absent/LOW. Source-side cross-check (grep `--start-group` over all overlay Makefiles) is exhaustive: signature set = exactly {aslmanager (fixed op-204), asld (MISSED, HIGH), aslutil (found, LOW)}. **Corrected verdict: census-found = 3; preview NOT de-risked until asld is fixed.** Runtime rc=139 for asld not yet booted by me — structurally identical to aslmanager (same load-time libdispatch ctor → NULL `__elf_aux_vector`), the fix op confirms runtime first-hand. → follow-on op-207 (Implementer batched dynamic-link fix: asld HIGH + aslutil LOW, mirror op-204). **CLOSED: op-207 [Done] @ 986be5d — asld+aslutil dynamic-linked + verified (NEEDED libdispatch.so.5, aux_vector gone); with op-204 (aslmanager) all 3 static-libdispatch crashers fixed → the latent-SIGSEGV class is closed. Wiring footnote: asld was staged-but-unwired in the current preview (FreeBSD syslogd is the active logger), so the crash was latent not live.** | parent id: id-011 (asl) + cross-service preview hardening | L1i: li-1004 (originating service) | cost: free | authored 2026-06-29 (Arranger seat, model Opus 4)

## WHY (one line)

op-204 found aslmanager SIGSEGV'd before main() because it STATIC-linked libdispatch.a+libthr.a (NEEDED=libc.so.7 only) → libdispatch's load-time ctor ran `pthread_key_create` before csu set `__elf_aux_vector` → NULL deref at dlfcn.c:180. Every working Darwin daemon links libdispatch DYNAMICALLY (notifyd). **Any other shipped binary with the same static-libdispatch signature has the same latent startup crash** — find them before a preview boot does.

## SCOPE / SUBJECT (DISCOVERY — classify, don't fix)

- Census the shipped preview image's Darwin userland binaries (`/sbin`, `/bin`, `/usr/sbin`, `/usr/bin`, `/usr/libexec`) — and/or the canonical source tree's built binaries (`amd64.amd64/.../{sbin,bin,usr.sbin,usr.bin}`). Confirm which binary set you swept (cite the image/obj path + provenance).
- The op-204 crash SIGNATURE (two-part, structural + runtime):
  - STRUCTURAL: the binary uses libdispatch (a `libdispatch_init` / `_dispatch_*` symbol or a local `__elf_aux_vector`/`dl_init_phdr_info`) BUT its `readelf -d` NEEDED does NOT list `libdispatch.so.5` (i.e. it static-linked it). The crisp cheap filter: Darwin binaries whose NEEDED is `libc.so.7`-only (or lacks libdispatch.so while clearly a libdispatch consumer).
  - RUNTIME (the decisive test): the suspect actually SIGSEGVs at startup — `rc=139` on `-h`/no-args, bt at the libdispatch-ctor→`dl_init_phdr_info`→NULL-`__elf_aux_vector` path. Present≠live: a static-libdispatch binary that never triggers the ctor path may NOT crash; classify from the RUNTIME test, not readelf alone (no_conflate_gating_with_readiness, verify_signature_divergence_claims).

## DELIVERABLES

**D1 — the suspect list (structural).** Every shipped Darwin binary matching the structural signature (static libdispatch / NEEDED lacks libdispatch.so while it consumes it). For each: path, NEEDED summary, the discriminating symbol. → `OP205_SUSPECTS`

**D2 — runtime classification (the load-bearing read).** Run each suspect (`-h` or no-args; if it needs the shared libs, run it where they resolve — on the booted image, not bare host) and classify: **CRASHES** (rc=139 + the 0x309b7b-family bt — same defect as aslmanager) | **RUNS** (reaches main / a usable rc — static-link but ctor path not triggered, benign) | **CANT-TEST** (needs args/env to even start — note it, don't force). Cite rc + bt per binary. → `OP205_RUNTIME_CLASS`

**D3 — disposition + hand-off ledger.** {binary → static-libdispatch? → crashes? → preview-relevance}. For each CRASHES binary: recommend the op-204 fix (dynamic-link the Darwin runtime, mirror notifyd), one Implementer op per binary or a batched fill — **recommendation only, author NO fix** (Explorer discipline; Arranger decodes into Implementer ops). Flag any CRASHES binary that is a preview-relevant service (a core-service daemon, a boot-path binary) as HIGH priority. → `OP205_LEDGER`

**VERDICT:** `census-clean` (no other binary crashes — aslmanager was the only one, preview de-risked) | `census-found` (N binaries crash — list + priority, hand to Implementer) | `walled` (can't boot the image / run the suspects — report). → `OP205_VERDICT` / `OP205_TERMINAL`

## BOUNDARIES
- Explorer DISCOVERY — sweep + classify + recommend ONLY; author NO fix, edit NO product (op-200/op-201 discipline). "CRASHES" = the binary actually SIGSEGV'd at runtime (rc=139 + bt), NOT "readelf says static-libdispatch" (present≠live).
- Runtime-test where the shared libs resolve (the booted image), not bare host (a host run may fail on missing .so's = a DIFFERENT failure, not the crash — don't misclassify a lib-not-found as the SIGSEGV). Use a DISPOSABLE/read-only consume; stage in rx-x64z owned dir (agent_host_isolation, NO host /tmp).
- The fix per binary is the op-204 dynamic-link Makefile change (userland overlay, not FB build-infra) — but that's the Implementer's; this op only IDs + prioritizes.
- A clean census is a real result (aslmanager was a one-off); a found-list is a high-value pre-preview catch. Either way, report — don't improvise fixes.

## MARKERS
```
OP205_SUSPECTS       # shipped Darwin binaries matching the static-libdispatch signature (NEEDED lacks libdispatch.so / libc-only) + discriminating symbol
OP205_RUNTIME_CLASS  # each suspect run: CRASHES (rc=139 + ctor→dl_init_phdr_info→NULL-auxv bt) | RUNS | CANT-TEST, with rc/bt cited
OP205_LEDGER         # {binary → static-libdispatch → crashes → preview-relevance} + per-crasher op-204-style fix recommendation (no fix authored)
OP205_VERDICT        # census-clean | census-found (N + priority) | walled
OP205_TERMINAL
```

## RELATIONS
- UPSTREAM: op-204 [Done] (the aslmanager fix that revealed the class — dynamic-link the Darwin runtime; NEEDED libc-only + static `__elf_aux_vector` was the signature); op-198 v4 (surfaced the crash).
- DOWNSTREAM: each `census-found` crasher → an Implementer op-204-style link-fix (Arranger decodes; prioritize preview-relevant daemons). A clean census closes the latent-crash risk for the preview.
- feedback: no_conflate_gating_with_readiness (static-link is structural; CRASHES is runtime — classify the runtime), verify_signature_divergence_claims (rc=139 + bt evidence per binary, not readelf inference), role_costs (free Explorer off the expensive seats, parallel to the soak), agent_host_isolation (rx-x64z dir, no host /tmp), userland_port_no_buildinfra_changes (the fix is an overlay Makefile change, not FB infra). project: 10preview_gate (catch latent crashes before the preview), launchd_no_autoscan (some suspects may only fire via launchd — note if a suspect can't be triggered standalone).
```
