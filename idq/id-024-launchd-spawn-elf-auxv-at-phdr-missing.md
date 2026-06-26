# id-024 — launchd-spawned process gets a malformed ELF auxv (missing AT_PHDR) → libc dl_init_phdr_info SIGSEGV

- id: id-024
- state: **ROOT CAUSE LOCATED 2026-06-25 (Arranger-verified first-hand against source; op-143 Explorer recon).**
  The crash is a **static-vs-dynamic linking mismatch in asld's build** — NOT a kernel/exec auxv bug.
  asld statically links `libsys.a` (`usr.sbin/asl/Makefile:57`, inside a `--start-group` static block;
  `MK_PIE=no` → ET_EXEC), dragging libsys's non-PIC `__init_elf_aux_vector` + a LOCAL BSS
  `__elf_aux_vector` (0x41c170) into asld. But asld is itself a DYNAMIC binary (has `_DYNAMIC` at
  0x402cb8, interpreter ld-elf.so.1, NEEDED libc.so.7). The non-PIC `__init_elf_aux_vector` bails for
  any binary with a `_DYNAMIC` section (`lib/libsys/auxv.c:64` `if (&_DYNAMIC != NULL) return;` —
  Arranger-confirmed in source), so asld's local BSS slot is **never populated**. rtld populates only the
  shared libsys.so.7 dynamic copy, never asld's local BSS. When an INIT_ARRAY ctor (likely
  `_libdispatch_init`/`mach_init`) reaches `dl_iterate_phdr`→`dl_init_phdr_info`, it reads asld's NULL
  local `__elf_aux_vector` → SIGSEGV at 0x3165fb `movq (%rax),%rcx`, rax=0 (matches op-138 core regs +
  disassembly first-hand). **PIE hypothesis DEAD** — readelf shows asld, notifyd, AND the op-139 probe
  are all ET_EXEC; the discriminator is the LOCAL BSS copy (asld has `B __elf_aux_vector`; notifyd/probe
  IMPORT it from shared libsys → rtld populates theirs). That is why op-139's auxv-confirm saw a complete
  auxv (it read the shared copy) yet asld still crashes (it reads its own NULL BSS copy). **Both prior
  exec-path hypotheses (op-141 AND the PIE reframe) are CLOSED.** Fix = build-system delink (Implementer
  op-144), NOT a kernel change.
- raised: 2026-06-25.
- roadmap parent: foundation/kernel-libc track (the launchd-spawn process-environment path). Blocks
  **[l1i/li-008](../l1i/li-008-launchd-core-service.md)** real-service hosting (daemons that use dladdr)
  and the asl bring-up (id-011/op-124).

## The bug (source-verified crash site; cause hypothesis to confirm)

asld, started under launchd, SIGSEGVs **before its own `main()`** — in libc's ELF auxiliary-vector
processing. Backtrace (op-138, lldb on the 13.5M core): RIP `0x3165fb` → `addr2line` →
`dl_init_phdr_info` at `lib/libc/gen/dlfcn.c:180`.

**Verified first-hand in source (`nx/NextBSD/lib/libc/gen/dlfcn.c`):**
- `:166-171` — `dl_init_phdr_info` iterates `__elf_aux_vector`, setting `dlpi_phdr` from `AT_PHDR` and
  `dlpi_phnum` from `AT_PHNUM`.
- `:175-181` — loops `for (i=0; i<dlpi_phnum; i++) { if (dlpi_phdr[i].p_type == PT_TLS) … }` with **NO NULL
  guard** on `dlpi_phdr`. If the auxv lacks a valid `AT_PHDR` (so `dlpi_phdr` stays NULL/unset) while
  `dlpi_phnum > 0`, this dereferences NULL → SIGSEGV. That is the crash.
- `:192` — `dl_iterate_phdr` guards `__elf_aux_vector == NULL` but **not** an auxv that exists yet is
  missing `AT_PHDR` → the guard doesn't catch this case.

**Why asld and not notifyd:** asld reaches `dl_iterate_phdr`/`dladdr` during init (likely via liblaunch's
IPC setup); notifyd's init path doesn't, so notifyd never trips the bad-auxv deref — which is why notify
works under the same launchd and asl doesn't. (Not a launchd capability gap; both use identical
`launch_msg(CHECKIN)`+MachServices — see the op-138 retraction.)

## Cause hypothesis (Explorer to confirm cheaply, then Implementer to fix)

The rmxOS `posix_spawn`/`exec` path may not propagate the ELF auxiliary vector (specifically `AT_PHDR`)
correctly for **launchd-spawned** processes. To confirm without burning Implementer cycles: a small probe
that dumps its own `__elf_aux_vector`/`getauxval(AT_PHDR)` when spawned **by launchd** vs **from a shell** —
if `AT_PHDR` is absent/NULL only in the launchd-spawned case, the kernel/launchd exec path is the cause.

## Fix shape (after confirm)
- **Root fix (Implementer, kernel/exec):** make the launchd-spawn exec path deliver a complete auxv
  (incl. `AT_PHDR`/`AT_PHNUM`) — the real bug.
- **Defense-in-depth (libc):** `dl_init_phdr_info` should NULL-guard `dlpi_phdr` before the `:175` loop
  (a missing `AT_PHDR` must not segfault). Secondary to the exec fix; observation-first.

## Relations
- **op-138** (`2bead3f`) — the diagnostic that found it (retired); its asld-as-syslogd staging overlay +
  rc.d-rename are proven-good and stand for the eventual op-124 re-run.
- **id-011 / op-124** (asl lifecycle/soak) — BLOCKED on this; asl can't come up under launchd until fixed.
- **li-008** (launchd service host) — any hosted daemon using dladdr/dl_iterate_phdr hits this; broader
  than asl.
- **id-016** (launchd-spawn bootstrap gap) — adjacent (both are "launchd-spawned process environment"),
  but a DISTINCT mechanism (ELF auxv/exec, not the Mach bootstrap port).
- carrier ops: op-139 (Explorer auxv-confirm — DONE, REFUTED the AT_PHDR-strip cause) →
  ~~op-141 (Implementer exec/auxv fix)~~ **CANCELLED** (cause refuted) → op-143 (Explorer recon — DONE,
  ROOT CAUSE LOCATED: static-libsys vs dynamic-binary; Arranger-verified first-hand against source) →
  op-144 (Implementer, asld Makefile delink — **DONE, Arranger-verified first-hand**: entire static
  `--start-group` block replaced with `LIBADD=`; all 16 deps now shared incl libsys.so.7; single
  libc.so.7 NEEDED (mixed-libc hazard avoided); ZERO local auxv/phdr symbols in asld (nm + dynsym) →
  bug trigger structurally removed. Commit `ffc4fcf`, branch op-144-asld-delink, authorized-to-merge) →
  op-145 (Gatekeeper guest-run, structural pre-clear by DS4P — **PASS, Arranger-verified first-hand**:
  serial sha 20ecf3bf…, `OP145_ASLD_MAIN_REACHED status=0`, asld execs past the INIT_ARRAY ctor into
  main() under launchd, NO SIGSEGV at dl_init_phdr_info; shared libdispatch/libmach ctors resolve
  dl_iterate_phdr to rtld-populated libsys.so.7 — runtime-proven. **id-024 RESOLVED.**) → op-144 RETIRED,
  **op-124 (asl lifecycle/soak) now OPEN.** [Process note: op-145 also exposed that the spec'd
  nxplatform-dev.img is a pre-overlay base lacking launchd/overlay — the proven base is the leg-4 staged
  image; op-140's record corrected accordingly.]
