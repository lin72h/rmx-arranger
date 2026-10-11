---
id: op-644
state: closed
agent: implementer
repo: rmx-implementer
idq: id-048
authority: test-only commits on a new branch tests-op644 from mach-fixes-6@93b3735d in wip-rmxos; rebuild the RELEASE and KASAN overlays; 6 self-check boots (4 + 2 spare) with your op-633 runner; no push
expected: 4h
issued-at: 2026-10-11T10:03Z
updated: 2026-10-11T11:55Z
---
# op-644 — Implementer: a model-based test of Mach port rights and reference counts, added to the Mach suite

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 4 hours.**

Our Mach suite (1042 cases, all passing at
`mach-fixes-6@93b3735d1d8bef1f15e013599d0a56bab3968b61`) has one
hand-written case per behaviour. This op adds one model-based test,
in the style of property-based testing, that checks the bookkeeping
of port rights over many call orders instead of one.

1. **Test (Zig, `tests/sys/mach/mach_port_model.zig`, ATF case
   `mach_port_model_test:sequences`):**
   - A small model holds, for each port name in the task, its rights
     (receive, send, send-once, port set, dead name) and its
     user-reference count, following the Mach port documentation and
     our `EXPECTATIONS.md`.
   - From a seed, a deterministic generator picks a sequence of up to
     30 calls from this set: `mach_port_allocate` (receive, port set,
     dead name), `mach_port_insert_right`, `mach_port_mod_refs`,
     `mach_port_deallocate`, `mach_port_destroy`,
     `mach_port_move_member`, `mach_port_extract_right`, and a simple
     send and receive of a message with no descriptors.
   - After each call the test compares the return code with the
     model's, and `mach_port_type` and `mach_port_get_refs` for the
     names involved. At the end it checks `mach_port_names` against
     the model for the names the sequence created (the task holds
     other names too) and that each of them is gone after cleanup.
   - It runs a fixed list of 2000 seeds and prints one line per
     mismatch (seed, step, call, expected and observed) and a summary
     line.
   - Host-test the generator and the model first (seed to sequence is
     deterministic; the model's expected results for a few hand-made
     sequences).
2. **Self-check:** add the case to the installed suite, rebuild the
   RELEASE and KASAN overlays on `op552-overlay-base-r3.raw` (sha256
   `6f3b6e54606cecfbe3572cf5e2dee156c42499d113909351b811c41abe974059`),
   and run the whole plan on both profiles, the new case first.
   Expected: the existing 1042 cases still pass; the new case reports
   2000 seeds and its mismatch count; normal power-off; on KASAN, no
   KASAN report.
3. **Each mismatch:** if the model is wrong (check it against the
   documentation and XNU,
   `/Users/me/wip-mach/reference/xnu-xnu-12377.121.6/osfmk/ipc/`),
   fix the model and rerun within the boots. If our kernel differs,
   add the shortest failing seed's sequence as its own named case in
   the same file, record what our code does at which `file:line` and
   what the model expected; the fix comes in a later op.

Evidence: `docs/op644-port-model.md` (the call set and model rules,
host tests, each boot's load, counts and serial sha256, each mismatch
with its seed, `file:line` reading and named case); commit.

## Limits

- Test-only commits on `tests-op644`; `mach-fixes-6` stays at
  `93b3735d`. No product source change. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
