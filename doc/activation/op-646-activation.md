---
id: op-646
state: draft
agent: implementer
repo: rmx-implementer
idq: id-048
authority: test-only commits on tests-op644 in wip-rmxos; rebuild the RELEASE and KASAN overlays; 6 self-check boots (4 + 2 spare) with your op-644 runner; no push
expected: 2h
updated: 2026-10-11T11:55Z
---
# op-646 — Implementer: record mach_port_names as a known 1.0 gap in the port-model test, then its RELEASE and KASAN self-check

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 2 hours.**

Your op-644 model test is accepted as written. On RELEASE every one
of the 2000 seeds matched the model on every call; the only
mismatches are the final `mach_port_names` inventory
(`names_rc expected=0 observed=46`), because
`sys/compat/mach/ipc/mach_port.c:233` returns `KERN_NOT_SUPPORTED`
with the real body under `#ifdef notyet`. No userland program in our
tree calls `mach_port_names`, and rmxOS 1.0 keeps NextBSD's
file-descriptor port names (the XNU-style name table is deferred
past 1.0), so the Arranger records it as a known 1.0 gap rather than
implementing it now.

1. **Test, on `tests-op644` from `f45bb3b1`:**
   - `names_inventory` asserts today's documented behaviour:
     `mach_port_names` returns `KERN_NOT_SUPPORTED`, with a comment
     naming the known gap, so the case changes when someone
     implements it.
   - `sequences` keeps every per-call check and the cleanup checks by
     `mach_port_type` and `mach_port_get_refs`, and leaves out the
     inventory step. Expected: 2000 seeds, 0 mismatches.
2. **Self-check:** rebuild the RELEASE and KASAN overlays on
   `op552-overlay-base-r3.raw` (sha256
   `6f3b6e54606cecfbe3572cf5e2dee156c42499d113909351b811c41abe974059`)
   and run the whole plan on both profiles, the op-644 cases first.
   Expected on both: 1072 cases pass (the 1042, ten each of
   `sequences`, `names_inventory` and `extract_make_send`); each
   `sequences` summary reports 2000 seeds and 0 mismatches; the five
   MIG modes return 0; normal power-off; on KASAN, no KASAN report.
3. **A remaining mismatch:** if the model is wrong, fix it and rerun
   within the boots; if our kernel differs, add the shortest failing
   seed as a named case, record what our code does at which
   `file:line`, and stop product work there (the fix comes in a later
   op).

Evidence: add `## op-646` to `docs/op644-port-model.md` (the change,
each boot's load, counts and serial sha256, any mismatch); commit.

## Limits

- Test-only commits on `tests-op644`; `mach-fixes-6` stays at
  `93b3735d`. No product source change. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
