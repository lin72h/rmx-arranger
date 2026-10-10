---
id: op-610
state: draft
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-062
authority: 6 boots max (4 + 2 spare) on copies of op552-overlay-base-r3 with the two overlays below; install boots 5 min, test boots 10 min; doas vmm.ko, bhyve; push rmx-gatekeeper1 main
expected: 2h
updated: 2026-10-10T02:37Z
---
# op-610 — Gatekeeper 1: prove mach-fixes-6@b127415a (op-607, round-2 fixes) on RELEASE and KASAN

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 2 hours.**

Since your op-598 proof of `b61f0f91`, the Implementer has added five
commits on `mach-fixes-6`, up to `b127415a7435`
(`git log --oneline b61f0f91..b127415a` in
`/Users/me/wip-mach/rmx-implementer/wip-rmxos`): a reply right held as
a send right to a port received elsewhere is accepted, as XNU does;
`task_terminate` returns `KERN_NOT_SUPPORTED`; file-context ports are
refused for named insertion and for receive dispositions; small
clean-ups (descriptor-install failure releases the entry, unused
receive-resume code removed, dead names refuse a requested name). The
Implementer's runs pass 773/773 on both profiles. This op is the
independent proof of the fixed code; the earlier behaviour of these
items is shown by source traces in the Implementer's record
(`docs/op607-round2.md`), so no base boot is needed.

1. Use your op-598 runner, including installed-image reuse.
2. **Fixed RELEASE, then fixed KASAN**: build your plan from the
   installed tests' own listings (`-l`) and reconcile it before
   booting with the Implementer's count: op-598's 723 cases plus the
   new cases ten times each, 773 in all, then the five
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
`/Users/me/wip-mach/rmx-implementer/build/ci/b127415a7435d89be0a74ddd5aee094a0e5de100/overlays/`:

| Run | Overlay | overlay.ufs sha256 | manifest.tsv sha256 |
| --- | --- | --- | --- |
| fixed RELEASE | `rmxos-release-op607/` | `b4f961bfb25b2b946c34ec74ee8c1586480209caf811bba124298855aaf1a71d` | `b267ea800720c0461c53298a2fe1c30cce63313ec9447f7603722459b4966a5d` |
| fixed KASAN | `rmxos-kasan-op607/` | `e0f8d84f0464376c39ad449563975bccaef1bf01b2016495ac54eed3743ed28c` | `ec49b6fa239fe6e9ae45c9074f4381beded8f9939d801e62f1d04a849d4a55ca` |

Before each boot, wait until the host's 1-minute load average is
below 40 and record it.

Evidence: `build/op610/findings.md` with a table per run (expected
and observed, serial lines), the plan reconciliation, the attempt
ledger and serial hashes, and a disposition; remove the run images
after recording their hashes; commit and push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
