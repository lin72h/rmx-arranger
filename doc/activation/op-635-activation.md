---
id: op-635
state: closed
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-063
authority: 6 boots max (4 + 2 spare) on copies of op552-overlay-base-r3 with the two overlays below; install boots 5 min, test boots 10 min; doas vmm.ko, bhyve; push rmx-gatekeeper1 main
expected: 2h
issued-at: 2026-10-11T09:23Z
updated: 2026-10-11T09:52Z
---
# op-635 — Gatekeeper 1: prove mach-fixes-6@93b3735d (send-possible and the MIG generator fixes) on RELEASE and KASAN

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 2 hours.**

Since your op-621 proof of `1cad29b5`, `mach-fixes-6` has six commits
up to `93b3735d1d8b` (`git log --oneline 1cad29b5..93b3735d` in
`/Users/me/wip-mach/rmx-implementer/wip-rmxos`): send-possible
notifications (`MACH_SEND_NOTIFY`, `MACH_NOTIFY_SEND_POSSIBLE`); MIG
counted inline arrays aligned to four bytes; MIG requests simple unless
they carry descriptors, as Apple's MIG, with the kernel servers,
libraries, launchd, `asld` and `notifyd` regenerated; tests moved to
that encoding. The kernel binary is op-610's; `mach.ko`, the libraries
and those programs change. The Implementer's runs pass 1042/1042 on
both profiles. This op is the independent proof; the earlier behaviour
is shown by source traces in `docs/op617-round3.md`, so no base boot.

1. Use your op-621 runner, including installed-image reuse.
2. **Fixed RELEASE, then fixed KASAN**: build your plan from the
   installed tests' own listings (`-l`) and reconcile it before
   booting with the Implementer's count, 1042 cases including the
   400-case repeat, then the five `mig_reply_ports_test` modes. Run
   every case even after one fails. Expected on both: every case
   passes; the five modes exit 0 and every kernel call in them returns
   0 (`a_rc`, `b_rc`, `kernel_rc`); normal power-off; no panic or
   assertion line; on KASAN, no KASAN report. Pass
   `-e kern.racct.enable=1` to bhyveload. `mach.ko` is identified by
   the manifest hash.
3. **WITNESS**: the Implementer's KASAN run printed one lock-order
   warning at shutdown (process lock at `kern/kern_sig.c:2145`, then
   btag lock at `kern/subr_vmem.c:758`); earlier KASAN runs had none.
   Record every `lock order reversal` block in either profile with its
   serial lines. It does not decide your disposition; it is evidence
   for a separate investigation.
4. Two spare boots, for a boot that stops before its commands run or
   a fault in your own plan or runner. A product failure is recorded
   and ends that profile.

Base image
`/Users/me/wip-mach/rmx-implementer/build/op552/images/op552-overlay-base-r3.raw`
sha256 `6f3b6e54606cecfbe3572cf5e2dee156c42499d113909351b811c41abe974059`.
Overlays (`manifest.tsv` beside each), under
`/Users/me/wip-mach/rmx-implementer/build/ci/93b3735d1d8bef1f15e013599d0a56bab3968b61/overlays/`:

| Run | Overlay | overlay.ufs sha256 | manifest.tsv sha256 |
| --- | --- | --- | --- |
| fixed RELEASE | `rmxos-release-op633-r2/` | `81b08b76f594431e7d83db97f9c353cfe3d603efcbb0e51599368c4e03f9b183` | `23beb745a77f3a4cd41f750afec1160ab6e3a9a1fa7d2808e4f4fa2d7d364c50` |
| fixed KASAN | `rmxos-kasan-op633-r2/` | `7b3a7452b5b52f9441248f2c55a3822aada1eede11b10dbb09c84a58ad1729fe` | `7ba5c957720fadc5731082666644a643c8b550a2fcba96e1b3fbb6dc04bf8f5a` |

Before each boot, wait until the host's 1-minute load average is
below 40 and record it.

Evidence: `build/op635/findings.md` with a table per run (expected
and observed, serial lines), the plan reconciliation, the MIG-mode
return codes, any WITNESS blocks, the attempt ledger and serial hashes,
and a disposition; remove the run images after recording their hashes;
commit and push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
