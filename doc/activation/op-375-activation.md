---
id: op-375
state: draft
agent: validator1
repo: rmx-validator1
idq: id-042
gate: self
authority: none
updated: 2026-09-28T04:09Z
---
# op-375 — Validator 1: review op-372 contained boot of the op-364 image

## Outcome

Review op-372 (gatekeeper1, returned 2026-09-28): a contained boot of the op-364 alpha2 image
with the bounded Mach and dispatch slice. You are one of two reviewers (validator1 and validator2).
Return CLOSE, DO-NOT-CLOSE, or REMEDIATE on these claims:

1. Input and containment: attempt 1 booted a fresh, verified copy of
   `/Users/me/wip-mach/rmx-implementer/build/op364-20260928T001637Z/images/op364-alpha2-gpt.raw`
   with 2 vCPUs, 4 GiB, one virtio disk, serial console only, and no network, shares, or
   passthrough. The containment disposition was recorded before launch, and the host checks ran
   through the real shell and PTY path.
2. Module: the op-364 `mach.ko` loaded and initialized ("mach services loaded"), with
   `debug.link_elf_leak_locals: 1` and no undefined-symbol error.
3. Slice: the Mach probe (4 cases) and dispatch probe (4 cases) each passed in the raw bytes, not
   only in runner summaries. They ran from op360's passing basis, and the plan changed in exactly
   two ways: the module hash pin and the added leak-locals step.
4. Accounting and records: 1 of 2 attempts consumed, a clean power-off, no VM left, both
   dispositions recorded as new entries, and commits `e5d46af` and `a4a9836` on origin.

Suggested distinguishing question (sharpen it if you find a better one): do the raw serial and
probe bytes show the op-364 module and every probe case passing on a fresh copy of that exact
image, under the recorded containment?

## Inputs

In `/Users/me/wip-mach/rmx-gatekeeper1` at `a4a9836` (origin `lin72h/rmx-gatekeeper1`), sha256:
- Run dir `build/op372/runtime/rmx-op372-alpha2-20260928T033250Z-50738/`:
  `serial.raw` `d7112732f0fbeadf0436701b8adf0e7b11df090b0523c0e2cb9ff0a445b4e87b`,
  `host-orchestration.log` `4350705f3237589a668e67af772607cb7eb5a2ce00b8b3c6d29be4c5470ef6de`,
  `probe-mach-output.raw` `7c7367273879e2b4e67d83fe6434fb65bc914cfc505bc3f97131e4d76cd5bbd9`,
  `probe-dispatch-output.raw` `69f068d54b7a614362b460c994faf4424624ba80dd14f79cde99bd04f0b03ba3`,
  plus `attempt-marker.txt`, `run-command.txt`, `loader.raw`, `module-inventory.raw`, and
  `module-dmesg.raw`.
- Launcher `build/op360/run-op360-alignment-r1.sh` `a10382f63f3818b01f34bbdf58f74b1e4286f3d65492d6b507cbf62d594e08ab`
  with `build/op372/config.sh` `4d71305ef5e629bc81b87b8aa766cad32f8c10fbaa014ccda6e999f4d276bfc0`;
  Expect driver `build/op360/boot-op360-r2.expect` `7bcd0682098f430d39ef7ca48cc2838f81d80af7ebc3572591df4b92346bfbd9`.
- Plan `build/op372/guest-sequence.tsv` `a8dff3e16f77b1fa83b45c936ca246ad6faa9eaec47a4d0c1aca6d03cba47f54`
  from `build/op372/make_plan.exs` `97d0b37c6e9d15260069d771f84c953593df0be740b97ecc1f4777a0b6126122`;
  basis `build/op360/runtime-plan/guest-sequence-alignment-r1.tsv` `cc93815ac8ddea9552ae744e69e882cdabedfe395e2a9a935d011378bfe0e99a`.
- Probes `build/op360/alignment-r1/bin/mach_probe_diag` `72be4d2c65bbbdd167ccbda5ac96233012640bd8de3a0bdd6e6597e482207b7a`
  and `build/op355/bin/dispatch_probe` `f6c5201576963e1936def228bd37de13f5362e1622b4abf7da6dd4ee96666019`.
- Host checks in `build/op372/host-tests/`; dispositions `build/op372/dispositions/containment-20260928T0330Z.md`
  `c3180d5af88230c44c469cbbe952c7dd6c638ae1358a699db6e04728ab2fbd07` and
  `build/op372/dispositions/run-20260928T033250Z.md` `19e49b25845c2983fc3aaebd5b92e5beb8175f755885ef3ebab0aa2f06f56578`.
- The image: sha256 `8f546a930859ce537d1cb8f462dbf391171fd02c2bd004d2d10b1c8b498c7140`; its
  module `boot/RMXOS-RELEASE/mach.ko` sha256 `53e5a8cfc1b5e18801d62501312b3cc031e682cf7480b4aac16d0eb55ae2fcdb`.

Defaults and the REPORT block: OPS.md in your repo.
