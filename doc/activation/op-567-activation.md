---
id: op-567
state: issued
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-047
authority: 9 boots max (8 + 1 spare) on copies of op552-overlay-base-r3 with the four overlays below; install boots 5 min, test boots 10 min; doas vmm.ko, bhyve; push rmx-gatekeeper1 main
expected: 3h
issued-at: 2026-10-08T07:50Z
updated: 2026-10-08T07:50Z
---
# op-567 — Gatekeeper 1: prove op-565's INVARIANTS assertion fix on RELEASE and KASAN against op-562's overlays

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 3 hours.**

CI now builds a candidate with `mach.ko` compiled together with its
kernel, so the module's INVARIANTS assertions run, for two kernel
profiles: RELEASE and KASAN (op-562). Both stopped at
`xpc_receive_test:suspended_barrier` (case 7) with a kernel panic in
`ipc_right_dnrequest`: `port` starts as `NULL`
(`sys/compat/mach/ipc/ipc_right.c:270`) and `ip_unlock_assert(port)`
reads it on the first loop pass (`:278`). op-565 (`mach-fixes-6`
`13628bbe`, parent `ff8a4d60`) checks `port != IP_NULL` before that
assertion and changes nothing else. Records:
`/Users/me/wip-mach/rmx-implementer/docs/ci-build.md` (op-562) and
`/Users/me/wip-mach/rmx-implementer/docs/op565-invariants.md`.

These overlays also replace the kernel and its modules under
`/boot/RMXOS-RELEASE/` (the base loader's path; both profiles install
there). Your runner's install-boot-then-reboot route handles this
unchanged; check the loaded kernel line on the test boot's serial
(`n284044-ff8a4d604e50 RMXOS-RELEASE` or `... RMXOS-KASAN`). Both
candidates reuse the same kernels, so `mach.ko` is identified by the
manifest hash, as before.

Base image
`/Users/me/wip-mach/rmx-implementer/build/op552/images/op552-overlay-base-r3.raw`
sha256 `6f3b6e54606cecfbe3572cf5e2dee156c42499d113909351b811c41abe974059`.
Overlays (`manifest.tsv` beside each), under
`/Users/me/wip-mach/rmx-implementer/build/ci/`:

| Run | Overlay | overlay.ufs sha256 | manifest.tsv sha256 |
| --- | --- | --- | --- |
| base RELEASE | `ff8a4d604e50bc8c51b2d40ae22e1628a727fb46/overlays/rmxos-release-1791436610/` | `421e7ba304ee710c89162760848d00cb1be6d99e3131b431c542b30b326c4677` | `c9e42b9df8be3f3d8c8b92f895f9b41a1d18fde1734df4115e9607660df0104d` |
| base KASAN | `ff8a4d604e50bc8c51b2d40ae22e1628a727fb46/overlays/rmxos-kasan-1791436688/` | `49840c1ef6998ae3f90fd3ed3214351250638a155c49a223ca5925be556493fa` | `1b4f77162d314bcb2feed8e322f22485b1203df49a799da64363fe0bc279d70f` |
| fixed RELEASE | `13628bbe681acb64308b5f8a7d584b86704d9914/overlays/rmxos-release/` | `263a6383442aea0d08e3f0675e658d7ba66fdf8daf8c24f4de7706777cbfe7f5` | `1bd4d0ba4b93f89c9b036ed533e757dbfcf66eddd1e770b2ff0a08239ac74588` |
| fixed KASAN | `13628bbe681acb64308b5f8a7d584b86704d9914/overlays/rmxos-kasan/` | `e55c0529b53b40bf9900cf36b208e559d561998c8dcfdd8f150f6979c64cce2b` | `5ebf84cd16963e4813a931266356881a052d92c4437a752ec8d8bc7f2ceca9d2` |

Each base/fixed pair's manifests differ in one row only,
`/boot/RMXOS-RELEASE/mach.ko`. Ignore the other timestamped
directories under `ff8a4d60.../overlays/`.

Proof (each run: an install boot, then a test boot):
1. Base RELEASE and base KASAN: the suite in its usual order up to and
   including `xpc_receive_test:suspended_barrier`. Expected: the six
   `mach_readiness_test` cases PASS, then the guest stops with a panic
   whose serial lines name `ipc_right.c:278` (or the `ip_unlock_assert`
   / `ipc_right_dnrequest` frames). Record those lines.
2. Fixed RELEASE and fixed KASAN: all 93 earlier cases (expected PASS,
   including `suspended_barrier`), the five `mig_reply_ports_test`
   modes (all PASS, as in op-560), the paced launchd repeat
   (`/usr/tests/lib/launchd/op526_repeat 100`, 400 cases, no
   `launchd control reply missing`), then a normal power-off. On
   KASAN, also expected: no KASAN report, assertion message or other
   panic anywhere in the serial log.
One spare boot, only for a boot that fails before its commands run.

Result: one table, expected against observed per run, with the serial
line for each case or mode, the repeat counts, the loaded kernel line,
the power-off line, every mismatch listed, and a separate line saying
whether the fixed KASAN run is clean of reports from boot to
power-off.

Evidence by path; hash only each boot's raw serial log. Commits on
origin.

## Limits

- No product edits. If one case cannot run, record it and finish the
  others.

Re-read OPS.md first: defaults and the reply block.
