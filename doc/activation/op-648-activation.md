---
id: op-648
state: issued
agent: implementer
repo: rmx-implementer
idq: id-048
authority: test-only commits on tests-op644 in wip-rmxos; rebuild the RELEASE and KASAN overlays; 8 self-check boots (6 + 2 spare) with your op-646 runner; no push
expected: 4h
issued-at: 2026-10-11T12:42Z
updated: 2026-10-11T12:42Z
---
# op-648 — Implementer: extend the port-model test to messages that carry port, port-array and out-of-line descriptors

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 4 hours.**

Your port-model test (`tests-op644` at `62a4a578`) passes on RELEASE
and KASAN: 2000 seeds, every call matching the model. Its messages
carry no descriptors. Most defects that review rounds 2 and 3 found
were in how rights and memory travel inside messages, so this op
extends the same model to messages with descriptors, within one task.

1. **Model and calls (same file, new ATF case
   `mach_port_model_test:descriptor_sequences`; the existing cases stay
   as they are):**
   - Add to the call set: send a message carrying one to four
     descriptors, then receive it:
     - port descriptors with each disposition (`MACH_MSG_TYPE_MOVE_SEND`,
       `COPY_SEND`, `MAKE_SEND`, `MOVE_SEND_ONCE`, `MAKE_SEND_ONCE`,
       `MOVE_RECEIVE`);
     - port-array descriptors of one to eight names with one
       disposition;
     - out-of-line memory descriptors of one to three pages, with and
       without `deallocate`.
   - The model moves rights through the queued message: the sender's
     rights and urefs change at send, the receiver gains them at
     receive, and destroying a receive right with queued messages
     releases the rights those messages carry. After receive, the
     out-of-line memory has the bytes that were sent, and with
     `deallocate` the sender's pages are gone.
   - Same checks as today after each call and at cleanup, with a fixed
     list of 2000 seeds; host-test the extended model first.
2. **Self-check, whole plan:** rebuild both overlays. Plan the KASAN
   profile as two test boots from the start, as op-646 ended up doing:
   the new and op-644 cases in one, the 1042 prior cases and the five
   MIG modes in the other. Expected: RELEASE 1082 cases pass (1042,
   ten each of the four model cases); every model summary reports 2000
   seeds and 0 mismatches; MIG modes 0; normal power-off; on KASAN,
   the same per boot and no KASAN report.
3. **A mismatch:** if the model is wrong (check against
   `/Users/me/wip-mach/reference/xnu-xnu-12377.121.6/osfmk/ipc/ipc_kmsg.c`
   and `ipc_right.c`), fix it and rerun within the boots; if our
   kernel differs, add the shortest failing seed as a named case,
   record what our code does at which `file:line` and what the model
   expected; the fix comes in a later op.

Evidence: add `## op-648` to `docs/op644-port-model.md` (the call set
and model rules added, host tests, each boot's load, counts and serial
sha256, any mismatch); commit.

## Limits

- Test-only commits on `tests-op644`; `mach-fixes-6` stays at
  `93b3735d`. No product source change. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
