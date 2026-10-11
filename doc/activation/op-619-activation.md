---
id: op-619
state: hold
agent: implementer
repo: rmx-implementer
idq: id-048
needs: none
authority: a new RMXOS-KASAN-KCOV kernel config and tools in rmx-implementer; new regression tests as test-only commits on a new branch gen-op619 from mach-fixes-6@93b3735d (never on mach-fixes-6); 12 boots (each a disposable copy, at most 30 min of guest time each); no push
expected: 6h
issued-at: 2026-10-11T09:57Z
updated: 2026-10-11T10:00Z
---
# op-619 — Implementer: randomized state-machine tests of our Mach port and message API, with coverage measurement, on the KASAN kernel (id-048, step 1)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 6 hours.**

Our Mach test suite (1042 cases, all passing at
`mach-fixes-6@93b3735d1d8bef1f15e013599d0a56bab3968b61`) checks the
cases we thought of. Review rounds 2 and 3 each found defects in
cases nobody had written a test for. This op adds a randomized
state-machine test, in the style of property-based testing: a seeded
generator builds sequences of ordinary Mach API calls, a small model
says what each call should return, and the test checks our kernel
against the model, with KASAN and INVARIANTS as extra checkers. kcov(4)
measures which lines of `sys/compat/mach/` the sequences reach, so the
test keeps the seeds that reach new code.

1. **Kernel profile:** `RMXOS-KASAN-KCOV`: `include RMXOS-KASAN` plus
   `options COVERAGE` and `options KCOV` (both in `sys/conf/options`;
   kcov(4) is `sys/kern/kern_kcov.c`). Build it with `mach.ko` as for
   the other profiles, and make an overlay on
   `op552-overlay-base-r3.raw` (sha256
   `6f3b6e54606cecfbe3572cf5e2dee156c42499d113909351b811c41abe974059`).
2. **Test program (Zig, in `rmx-implementer/tools/`):**
   - From a seed, build a short sequence of calls: allocate and
     destroy ports and port sets, insert and extract rights, move
     receive rights into and out of sets, send and receive messages
     (header bits, port, port-array and out-of-line descriptors, sizes
     within and at the documented limits), request notifications,
     register kevents on ports and sets, and end a thread or a process
     that still holds rights, so that cleanup runs.
   - A model tracks the expected rights and user-reference counts per
     name, and the return code each call should give. After each call,
     compare our return code with the model's; at the end of the
     sequence, compare `mach_port_get_refs` for every name with the
     model, and check that the task's port count is back to where it
     started.
   - Each sequence runs in its own child process, so the run carries
     on after a failing sequence. Keep a seed when it reaches new
     kcov lines; save the kept seeds on the guest disk; print one line
     per kept seed and per mismatch, and a summary line, to the serial
     console.
   - Host-test the generator, the model and the seed store first; the
     Mach calls need the guest.
3. **Runner:** your op-633 runner. One test boot runs the program for
   up to 30 minutes of guest time. The next boot starts from the saved
   seeds on a fresh copy of the installed image. Record the load at
   each boot start; wait until it is below 40.
4. **Campaign:** up to 12 boots. For each distinct failure (a model
   mismatch, a KASAN report, or a kernel assertion that ends the
   boot), shrink its sequence to the smallest one that still fails the
   same way, and add it as a Zig test under `tests/sys/mach/` in a
   test-only commit on `gen-op619`, failing on the current code.
   Record what our code does at which `file:line` and what the model
   expected; the fix comes in a later op. Stop after three distinct
   failures. Known and not counted: `pid 1 comm launchd: signal 11`
   lines after `All buffers synced.` at shutdown (tracked separately).

Evidence: `docs/op619-state-machine-tests.md` with the kernel profile
and overlay hashes, the program's commit and host tests, each boot
(load, duration, kcov lines reached, seeds kept, outcome), each
distinct failure with its test and `file:line` reading; commit.

## Limits

- No product source change; new tests only, as test-only commits on
  `gen-op619`; `mach-fixes-6` stays at `93b3735d`.
- No network in any guest. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
