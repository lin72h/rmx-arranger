---
id: op-617
state: closed
agent: implementer
repo: rmx-implementer
idq: id-063
authority: product and test commits on mach-fixes-6 in wip-rmxos (one per item); rebuild the RELEASE and KASAN overlays; 6 self-check boots (4 + 2 spare) with the op-607 runner; test-only fixes under op-590's rule; no push
expected: 7h
issued-at: 2026-10-10T06:43Z
updated: 2026-10-10T07:30Z
---
# op-617 — Implementer: Mach round-3 fixes (id-063) on mach-fixes-6 — message header headroom, reply references, send-possible notifications, small items

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 7 hours.**

Round 3 of the Mach review read the parts round 2 did not reach. The
Arranger traced items 1-4 in the source at `b127415a`. Start from
`b127415a7435`; one commit per item, each with a Zig test. Before
choosing a return code, search the existing tests for the same call.
The "before" evidence for every item is the source trace below; do
not boot the unfixed code for them.

1. **Room below the message header.** `ikm_set_header` places the
   header at `kmsg + 1` (`sys/sys/mach/ipc/ipc_kmsg.h`), with all of
   `max_expanded_size` above it (`ipc/ipc_kmsg.c` `ipc_kmsg_alloc`).
   When copyin widens user port descriptors (12 bytes) to kernel ones
   (16), it moves `mach_msg_base_t` down by the difference
   (`ipc_kmsg.c:1862-1865`), so the base lands on the
   `struct ipc_kmsg` fields themselves, and with more than ten port
   descriptors below the allocation. Place the header so that the
   expansion space lies below it, as XNU does (the header at the end
   of the buffer, minus the size of the message and trailer), and
   check copyout's opposite move (`:2676-2681`) against the new
   placement. Test: messages with 1, 5, 11 and 64 port descriptors are
   delivered intact, and a kmsg's queue links and size are unchanged
   by copyin.
2. **OOL port-array deallocation length.** Copyin reads
   `pnlength` = 4 × count bytes of names but, with `deallocate` set,
   unmaps `plength` = 8 × count (`ipc_kmsg.c:1671-1693`). Unmap
   `pnlength`. Test: the page after the sender's name array stays
   mapped and unchanged.
3. **Reply-port references on a fresh entry.** In
   `ipc_kmsg_copyout_header`, the fresh-entry path takes a reference
   in the loop (`:2235` or `:2264`) and another after it (`:2272`);
   `ipc_right_copyout` moves one into the new entry (`ipc/ipc_right.c`,
   "transfer send right and ref to entry"), and the end of the function
   releases one (`:2375-2376`). The in-loop one is never released; for
   send-once replies that is every message. Keep one pair, as XNU does
   (`osfmk/ipc/ipc_kmsg.c:3379`). Test: after many request/reply round
   trips with send-once and send replies, the reply port's reference
   count returns to its starting value, and the port is freed when its
   last right goes.
4. **Send-possible notifications (`MACH_SEND_NOTIFY`).** The kernel
   ignores the flag. libdispatch sends with `MACH_SEND_TIMEOUT |
   MACH_SEND_NOTIFY` and, on `MACH_SEND_TIMED_OUT`, marks the channel
   "send-possible notification armed" and waits for that notification
   (`lib/libdispatch/src/source.c:3495`, `:3531-3535`); libnotify sets
   the flag too (`lib/libnotify/libnotify.c:517`). Today the
   notification never comes, so a channel whose peer's queue was full
   stays waiting. First read what libdispatch registers for it (the
   notification request and the kevent it watches) and XNU's
   `ipc_port_request_sparm` and its delivery; then implement
   `MACH_SEND_NOTIFY` and `MACH_NOTIFY_SEND_POSSIBLE` as XNU does for
   our users. If that is more than half of this op's time, stop after
   items 1-3 and 5, commit them, and return the design with its
   estimate instead. Test: a sender to a full queue with
   `MACH_SEND_TIMEOUT | MACH_SEND_NOTIFY` times out; after the receiver
   takes one message the sender gets the send-possible notification;
   plus one libdispatch-level test of a channel that recovers.
5. **Small items:**
   - OOL port arrays: allocate and free with one malloc type and the
     real size (`ipc_kmsg.c:1674` allocates `M_MACH_TMP`; descriptor
     cleanup frees through `KFREE`, which uses `M_MACH_KALLOC`,
     `sys/sys/mach/std_types.h:141-143`).
   - `mach_port_extract_right` on a file-context port: refuse it as
     named insertion does (op-607), with the same error.
   - Record as known 1.0 gaps: `EVFILT_MACHPORT` `data` is the ready
     member's name, not Darwin's message size (the readiness-only
     design, tested by `mach_readiness`); `mach_vm_write` returns
     `KERN_NOT_SUPPORTED`.

Then rebuild the RELEASE and KASAN overlays on the same base image
`op552-overlay-base-r3.raw` (sha256
`6f3b6e54606cecfbe3572cf5e2dee156c42499d113909351b811c41abe974059`),
recording each overlay's and manifest's sha256, and self-check both
profiles with the op-607 runner and settings. Expected on both: every
earlier and new case passes, the five MIG modes exit 0, the 400-case
repeat passes, normal power-off, no assertion or fatal trap; on KASAN,
no KASAN report. Two spare boots; a wrong new test may be fixed and
rerun within the boots (op-590's rule); a product failure or an
earlier accepted test failing stops the op.

Evidence: a new record `docs/op617-round3.md` (each item: commit, test,
source trace, after result; the known gaps; item 4's design if it
stopped there; overlay hashes; both runs with load, ATF counts, MIG
modes, power-off line, serial paths), commit, and a `selfcheck:` line.

## Limits

- Commits on `mach-fixes-6` in `wip-rmxos`, only for these items. No
  push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
