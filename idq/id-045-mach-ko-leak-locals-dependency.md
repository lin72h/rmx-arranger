# id-045 — `mach.ko` loads only because the kernel resolves a LOCAL symbol

- id: **id-045**
- state: **WAITING — not on the preview critical path; decide accept, harden, or test (Coordinator)**
- raised: **2026-09-28 by the Arranger, from op-369 (prediction) and op-376 (observation)**
- parent: none (a robustness limit of the Mach module's link to the kernel)

## Problem

`mach.ko` calls `knote_enqueue`, which the kernel defines as a LOCAL (static) symbol, absent from
its exported `.dynsym`. The module links only because `debug.link_elf_leak_locals` defaults to 1
and the loader passes the kernel's full symbol table. op-369 predicted this from source; op-372
observed it (`debug.link_elf_leak_locals: 1`, module loaded), and op-376 confirmed that the run
read the shipped default rather than setting it. The failure branch is unexercised: with the
tunable at 0, or without the loader's symbol table, `kldload` would fail with
`symbol knote_enqueue undefined`.

## Why it matters

A default kernel setting silently holds the Mach module together. A future kernel, loader, or
tunable change would break Mach at boot, and nothing in the tree records the dependency.

## Options (for the Coordinator)

1. Accept and document it: record the dependency beside the module and in the release notes.
2. Harden the product: give the module a supported path to the enqueue operation (an exported
   kernel function or a module-local equivalent). This is Implementer work.
3. Test it: a contained negative-control boot with the tunable forced to 0, to observe the
   failure mode (validator2's proposal in op-376). This spends a guest attempt and proves only
   what the source already shows.

The Arranger's proposal: 1 now, 2 when Mach work resumes after the preview; 3 is not needed if
2 happens.

## op-383 consult (2026-09-28)

advisor2 op-383 consult `rmx-advisor2/op-383-mach-kernel-alpha2-integration-consult.md` (433838e) ranks this R1, the top Mach risk. Its proposal P1: option B, a narrow kernel-owned activation interface, instead of pinning the setting (option A) or redesigning around native knote APIs (option C). Making the symbol global is not enough. Retire only with a boot at leak_locals=0 plus readiness, direct receive, and concurrent teardown checks. The Implementer owns the code, and the Validators its review.

## Kernel-built profiles (op-396, checked first-hand 2026-10-01)

Building `mach.ko` with its kernel does not change the dependency. In all five op-396 profiles
(RMXOS-RELEASE, -KASAN, -KMSAN, -KCSAN, -KUBSAN), `knote_enqueue` is the only undefined symbol
that resolves to a LOCAL kernel symbol (`readelf -sW kernel.full`: `FUNC LOCAL`). op-396's
evidence also lists `copyin`, `copyout`, `memcpy`, `memmove`, `memset` and `sched_relinquish` as
"local/leak-locals", because `nm` prints them as `i`. In every profile, though, they are
`IFUNC GLOBAL`: `i` marks an indirect function, not a binding.
