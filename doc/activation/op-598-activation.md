---
id: op-598
state: issued
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-046
authority: runner change in rmx-gatekeeper1 (host-tested first); 10 boots max (8 + 2 spare) on copies of op552-overlay-base-r3 with the four overlays below; install boots 5 min, test boots 10 min; doas vmm.ko, bhyve; push rmx-gatekeeper1 main
expected: 4h
issued-at: 2026-10-09T22:09Z
updated: 2026-10-09T22:09Z
---
# op-598 — Gatekeeper 1: prove mach-fixes-6 to b61f0f91 (op-569, op-579, op-583, op-586, op-590) on RELEASE and KASAN; reuse installed images

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 4 hours.**

Since your op-581 proof of `13628bbe`, the Implementer has finished
the id-046 fix list on `mach-fixes-6`, up to
`b61f0f916417` (21 commits; `git log --oneline 13628bbe..b61f0f91` in
`/Users/me/wip-mach/rmx-implementer/wip-rmxos`). In short: Mach trap
results as values and MIG fields read from the message (op-569); on a
failed OOL copyout the caller alone now releases the copy (op-569); unsupported VM protection bits rejected before narrowing
(op-579); stock FreeBSD 15 struct offsets kept, VM wrapper results,
debug sysctl references and workqueue state at exec (op-583); host,
task and VM routines that report only what they did (op-586); test
fixes (op-590). The Implementer's own runs of `b61f0f91` pass 723/723
on both profiles. This op is the independent proof.

1. **Runner: reuse the installed image.** After an install boot, keep
   the installed root image read-only and record its sha256; start
   each test boot of that overlay from a fresh `cp` of it. On this
   host's ZFS the copy is block-cloned, so it costs no time or space.
   A retry then needs only a test boot. Host-test the change (copy,
   hash check, read-only original) and commit it before any boot.
2. **Base `26b8c8ed`** (op-565's code plus op-569's tests and the
   copyout fail point, without op-569's fixes). Run the four op-569
   cases, then the OOL case last:
   `mach_mig_pointers_test:vm_attribute`, `:clock_reply`,
   `mach_trap_returns_test:errors`, `:unsupported`,
   `mach_ool_failure_test:copyout_failure`. Expected on both
   profiles: the first four fail with their fact lines; then the guest
   stops in `copyout_failure`, because on the base both
   `vm_map_copyout_kernel_buffer` and its caller
   `ipc_kmsg_copyout_ool_descriptor` (through `vm_map_copy_discard`)
   release the same copy object. Record the stop lines and the frames
   the serial shows.
3. **Fixed `b61f0f91`**, RELEASE then KASAN: build your plan from the
   installed tests' own listings (`-l`), as in op-567, and reconcile it
   with the Implementer's count before booting: the 93 earlier cases,
   op-569's five cases ten times each, op-583's 8 and op-586's 10 new
   cases, the 400-case launchd repeat, then the five
   `mig_reply_ports_test` modes. Expected on both: every case passes,
   the five modes exit 0, normal power-off, no panic or assertion
   line; on KASAN, no KASAN report from boot to power-off. The loaded
   kernel line shows a newer build than op-581's (`n284063-…`), since
   op-583 moved struct fields; `mach.ko` is identified by the manifest
   hash, as before.
4. Two spare boots, for a boot that stops before its commands run or a
   fault in your own plan or runner. A product failure is recorded and
   ends that profile.

Base image
`/Users/me/wip-mach/rmx-implementer/build/op552/images/op552-overlay-base-r3.raw`
sha256 `6f3b6e54606cecfbe3572cf5e2dee156c42499d113909351b811c41abe974059`.
Overlays (`manifest.tsv` beside each), under
`/Users/me/wip-mach/rmx-implementer/build/ci/`:

| Run | Overlay | overlay.ufs sha256 | manifest.tsv sha256 |
| --- | --- | --- | --- |
| base RELEASE | `26b8c8ed7f9cc2cc5c9128bcfbb8e21af795aaa9/overlays/rmxos-release/` | `07e5eb75921984234859248405caf9be9feba6a75f744715946637269706f55d` | `50e472bbd4dc1f8408ed4af768e567ddaeb3b39143e57a15b0f668f05b3cc92c` |
| base KASAN | `26b8c8ed7f9cc2cc5c9128bcfbb8e21af795aaa9/overlays/rmxos-kasan/` | `5b89d5d8f8e3e7150d59cc514d11345af795b91cb0104937bf6dd0fd02a5fc45` | `3ba8cad7b9a4dbc70a783447ca252d4225382f562c8f1d47bc95f29fa8a6e532` |
| fixed RELEASE | `b61f0f9164170ed9d9d2b3fd312e34eee2603f09/overlays/rmxos-release-op590/` | `0dc0de0c632583e5703d9b300370cd66b69b44946a997a88da751f36ce2026e2` | `f17ca01157455f29622b35438756af75da421054b3816d43dc776d26cb7e30a1` |
| fixed KASAN | `b61f0f9164170ed9d9d2b3fd312e34eee2603f09/overlays/rmxos-kasan-op590/` | `9d865e0fb17f11ef70c86a103248ccf5f6df5df6c6f81b85c51cbb4b370f8259` | `6b8b6a695e142a3aa266ae7c6f79ba2034def7edaa480432a42f1c50f0253f32` |

The fixed overlays need `kern.racct.enable=1` at the loader for the
resource-limit case (the Implementer passes `-e kern.racct.enable=1`
to bhyveload); do the same on the fixed runs only.

Before each boot, wait until the host's 1-minute load average is
below 40 (`sysctl -n vm.loadavg`, up to 30 minutes) and record it.

Evidence: `build/op598/findings.md` with a table per run (expected
and observed, serial lines), the plan reconciliation, the attempt
ledger and serial hashes, and a disposition; commit and push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
