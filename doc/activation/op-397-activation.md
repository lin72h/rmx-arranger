---
id: op-397
state: issued
agent: validator2
repo: rmx-validator2
idq: id-047
gate: self
authority: none beyond the defaults: read-only; no image mounts, no guest runs
updated: 2026-10-01T07:46Z
---
# op-397 — Validator 2: review op-396 — mach.ko built with its kernel, and five kernel profiles

## Outcome

Review op-396 (Implementer). You are the only reviewer. op-396's report says:
- five kernel configurations were built from branch `testing-1`: `RMXOS-RELEASE`, `-KASAN`,
  `-KMSAN`, `-KCSAN` and `-KUBSAN`;
- `mach.ko` was built as part of each kernel's build;
- one image per configuration was staged from the op-364 image.

No guest has booted them.

**Claims to check:**

1. **Source.** `wip-rmxos@42d1fdbf5b0691ff2a75bf0cef5e7453c8c906dc` and
   `wip-rmxos@7ccf16fa410c8764c91b1cdaf3f3be683e4ad549`, on top of
   `2884304b67fc454ee60187ce4731fca01cbefe6a`, change only:
   - the module list;
   - the mach module's `SRCS`;
   - one include in `mach_port.c`;
   - four configurations in `GENERIC-KASAN`'s form.

   Mach's code changes only as far as the kernel's option headers change it.
2. **Build.** Each configuration's `mach.ko` comes from that configuration's own `buildkernel`,
   built with that kernel's `opt_global.h` and the complete flag set for its sanitizer
   (`sys/conf/kern.mk:259-331`). The staged `mach.ko` is the file that build produced.
3. **Symbols.** Every undefined symbol in each `mach.ko` resolves in its own kernel. For each
   symbol, check that the resolution path in the evidence is true: global, or local through
   leak-locals.
4. **Images.** Each image differs from the op-364 image
   (`8f546a930859ce537d1cb8f462dbf391171fd02c2bd004d2d10b1c8b498c7140`) only in:
   - `/boot/<config>/`;
   - `/usr/lib/debug/boot/<config>/`;
   - `/boot/loader.conf`, which must select that kernel and its `mach.ko`.

   launchd, launchctl, libmach and libdispatch must be op-364's.
5. **Helper.** `rmx-implementer@9d718966866df316f0f8ad601221e46038d82587`
   `scripts/bhyve/rmx-stage-image.exs` must:
   - leave the behaviour of the `rmx-stage-image/v1` path, which op-388 and op-391 use,
     unchanged from `dd78a31`;
   - allow `rmx-stage-kernel/v1` to install only into the kernel, debug and loader paths.
6. **Option headers.** The list of code that changes under the kernel's option headers is complete
   for `sys/compat/mach` and `sys/sys/mach`.

**Distinguishing question:** is each image exactly its claimed profile, and is every claimed
resolution path true? "Exactly" means a kernel and a `mach.ko` from the same build, carrying that
profile's instrumentation, with nothing else changed.

**Artifacts:**

| Configuration | Image | BOM | Symbol check |
|---|---|---|---|
| RMXOS-RELEASE | `/Users/me/wip-mach/stage/images/op396-RMXOS-RELEASE.raw` sha256:dbeeac23beba9535045fa1df57f149d318a18404ea255e57f02293b45fc15700 | `/Users/me/wip-mach/stage/artifacts/op396-RELEASE/bom.json` sha256:86cb11e0e9703f24ba8d6984bfa87e2ff4bacef00420d396397c7275acee160b | `/Users/me/wip-mach/rmx-implementer/build/op396/evidence/RMXOS-RELEASE/symbol-resolution.json` sha256:aa1671f761f9a8a682f98b2255bb52a178f4d1ffb5c9d4ca1c0a56904a0477e7 |
| RMXOS-KASAN | `/Users/me/wip-mach/stage/images/op396-RMXOS-KASAN.raw` sha256:6385b61895fdb6232be1a9ac1457d1fb3d397aa379b50538c9583c870a0bbfd8 | `/Users/me/wip-mach/stage/artifacts/op396-KASAN/bom.json` sha256:892033456a6869a62f1237f4f11b2f8c61f68ca6212b2355fe97bc219f3c20a8 | `/Users/me/wip-mach/rmx-implementer/build/op396/evidence/RMXOS-KASAN/symbol-resolution.json` sha256:843fd358a07afa7b9087eccc96de8013f18f6a08d9e3e7ea24b57e7df2ef4ee9 |
| RMXOS-KMSAN | `/Users/me/wip-mach/stage/images/op396-RMXOS-KMSAN.raw` sha256:e07e2c6e2ebbde6c4e21bc2a76735089ff7fc90dc7b96ba01333596b7065d0e4 | `/Users/me/wip-mach/stage/artifacts/op396-KMSAN/bom.json` sha256:e163ef4c7ab4fe360f0889ee2242209088d6baf2c808cf75bd91bbb24ddfada9 | `/Users/me/wip-mach/rmx-implementer/build/op396/evidence/RMXOS-KMSAN-v2/symbol-resolution.json` sha256:4a4848bb3ba514c7bff16e041e8394fec0c20c4acfc29afdc78daf15dcca043d |
| RMXOS-KCSAN | `/Users/me/wip-mach/stage/images/op396-RMXOS-KCSAN.raw` sha256:35631343889d86b264e46821f387cfe869211dffa024fe92325fa39b5cfcc5e0 | `/Users/me/wip-mach/stage/artifacts/op396-KCSAN/bom.json` sha256:ec17ade486f78bfe1fb72d0f2b39cbe66eff3a9c4c682a4a14a7ca2d6659bb80 | `/Users/me/wip-mach/rmx-implementer/build/op396/evidence/RMXOS-KCSAN/symbol-resolution.json` sha256:75b32183db58c057f5e72fcfa3450d6070c94b76fb863b3824c500fad6487a83 |
| RMXOS-KUBSAN | `/Users/me/wip-mach/stage/images/op396-RMXOS-KUBSAN-final.raw` sha256:76e4bba7f5a6f7fa5efd84243fb9a26f6164f396531ff1b33a8b99f3d725626e | `/Users/me/wip-mach/stage/artifacts/op396-KUBSAN-final/bom.json` sha256:9d81c627c180b601fa8bf5d0a08a6301760551ecc47cb4c118488c275b7de7ab | `/Users/me/wip-mach/rmx-implementer/build/op396/final-kubsan/evidence/RMXOS-KUBSAN/symbol-resolution.json` sha256:da514f7534f51e77c74c8c16c4d1a705e06cc54de34fded31c36efd3ec67b3c7 |

Beside each BOM: `in-image.json`, `host-before.json` and `host-after.json`.

Further artifacts:
- the evidence index: `/Users/me/wip-mach/rmx-implementer/docs/op396-testing-1.md`
  sha256:cdba95f5ccd75db22ea937d12b5612d545bb2cc99fce1cb22208564b4534ea84;
- its manifest: `/Users/me/wip-mach/rmx-implementer/build/op396/evidence/deliverable-artifacts.json`
  sha256:9f09a9285ec95106f5f5b20f86700513f556880a76cd9660c5d37948c58b0697;
- `flag-audit.json` sha256:986e79dc9200a8f97cf30d422c94efc1dcfa08d8bfb115000374415a5b241371;
- `option-header-changes.md`
  sha256:73080eb3903eb2b1309d8f34579e96b7d27d01ca9b9ea0a8ac0baea8ef1721c3.

## Inputs

- Build outputs: `kernel.full`, the modules and the logs, under
  `/Users/me/wip-mach/rmx-implementer/build/op396/obj/`, `.../build/op396/final-kubsan/` and
  `.../build/op396/logs/`.
- The source is in the worktree `/Users/me/wip-mach/rmx-implementer/build/op396/source`, on
  branch `testing-1`.
- The op-364 record: `/Users/me/wip-mach/rmx-implementer/build/op364-20260928T001637Z/`.

## Limits

- Do not mount the images or boot guests. `in-image.json` is the helper's record of what each
  image contains.
- The KUBSAN trial image `op396-RMXOS-KUBSAN.raw` and the first KMSAN evidence directory are
  superseded attempts. Review only the final artifacts above.

Re-read OPS.md first: defaults and the REPORT block.
