---
id: op-621
state: draft
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-063
authority: 6 boots max (4 + 2 spare) on copies of op552-overlay-base-r3 with the two overlays below; install boots 5 min, test boots 10 min; doas vmm.ko, bhyve; push rmx-gatekeeper1 main
expected: 2h
updated: 2026-10-10T07:30Z
---
# op-621 — Gatekeeper 1: prove mach-fixes-6@1cad29b5 (op-617, round-3 fixes) on RELEASE and KASAN

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 2 hours.**

Since your op-610 proof of `b127415a`, the Implementer has added five
commits on `mach-fixes-6`, up to `1cad29b55719`
(`git log --oneline b127415a..1cad29b5` in
`/Users/me/wip-mach/rmx-implementer/wip-rmxos`): the message header
now has the descriptor-expansion space below it, as XNU places it;
OOL port arrays unmap the sender's name-array length and use one
malloc type; a fresh reply entry takes one reference pair; named
extraction of a file-context port is refused; one test fix. All
changes are `mach.ko` sources, so the kernel binary is op-610's. The
Implementer's runs pass 833/833 on both profiles. This op is the
independent proof of the fixed code; the earlier behaviour is shown
by source traces in the Implementer's record (`docs/op617-round3.md`),
so no base boot is needed.

1. Use your op-610 runner, including installed-image reuse.
2. **Fixed RELEASE, then fixed KASAN**: build your plan from the
   installed tests' own listings (`-l`) and reconcile it before
   booting with the Implementer's count: op-610's 773 cases plus the
   six new cases ten times each, 833 in all, then the five
   `mig_reply_ports_test` modes. Expected on both: every case passes,
   the five modes exit 0, normal power-off, no panic or assertion
   line; on KASAN, no KASAN report. Pass `-e kern.racct.enable=1` to
   bhyveload, as on op-598's fixed runs. `mach.ko` is identified by
   the manifest hash.
3. Two spare boots, for a boot that stops before its commands run or
   a fault in your own plan or runner. A product failure is recorded
   and ends that profile.

Base image
`/Users/me/wip-mach/rmx-implementer/build/op552/images/op552-overlay-base-r3.raw`
sha256 `6f3b6e54606cecfbe3572cf5e2dee156c42499d113909351b811c41abe974059`.
Overlays (`manifest.tsv` beside each), under
`/Users/me/wip-mach/rmx-implementer/build/ci/1cad29b55719958ac88b3b3c5abede76a2975be5/overlays/`:

| Run | Overlay | overlay.ufs sha256 | manifest.tsv sha256 |
| --- | --- | --- | --- |
| fixed RELEASE | `rmxos-release-op617/` | `b83fdbb95933067a33815bf48f1ec2e743ccbcc5b3d4c6d548a205478aeba896` | `be859499a85e88d7c333f760d444e286d734f15f5485ba6539c4dd6784d9b625` |
| fixed KASAN | `rmxos-kasan-op617/` | `1a04b348e9e7959af32259c4874ede98bc3c8367021af019d52c2942981eeb7a` | `6bd63ced95683f40d426a77569d9fc2f26ee5a574dfe0c0ef73df90daa54b862` |

Before each boot, wait until the host's 1-minute load average is
below 40 and record it.

Evidence: `build/op621/findings.md` with a table per run (expected
and observed, serial lines), the plan reconciliation, the attempt
ledger and serial hashes, and a disposition; remove the run images
after recording their hashes; commit and push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
