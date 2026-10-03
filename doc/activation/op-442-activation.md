---
id: op-442
state: returned
agent: implementer
repo: rmx-implementer
idq: id-046
gate: self
authority: build: the Mach tests from mach-fixes-3 (and kernel or mach.ko only if a product change is needed); stage base and fixed test images with rmx-stage-image; no guest runs; no push
updated: 2026-10-03T04:04Z
---
# op-442 — Implementer: batch 3 — thread_control_death: check the port is unusable at exit and inactive after the reaper

## Outcome

Context: ordinary bug fixing in our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source Mach IPC). Everything runs in disposable bhyve guests with no network.

op-441 (gatekeeper1 `eae58f4`, `build/op441/findings.md`): the fixed image passes 40 of 41 cases.
`mach_lifetime_test:thread_control_death` reached its check for the first time and printed
`thread_control_after_exit expected_active=0 observed_active=1` (A2:2400).

Likely cause (Arranger, from source at `cf398822`; confirm or correct): the test polls for 1 second
(`tests/sys/mach/mach_lifetime.zig:89-94`). Mach disables the thread control port in the thread
destructor, which FreeBSD runs when it frees a zombie thread. Zombies are freed by a callout every
5 seconds, and only once they are more than 5 seconds old (`sys/kern/kern_thread.c:596,742,857`).
So the port stays active for about 5-10 seconds after exit. The exit gate marks the binding dying
at once, so conversions should already refuse it.

Decision (Arranger, under the Coordinator's delegation): keep the lazy disable for 1.0. Do not
add work to the exit gate. Change the case to check two things:
1. **Immediately after `pthread_join`:** the control port can no longer act on the thread. Use a
   thread call on it that must fail, or the fixture's conversion check. Record the result code.
2. **Eventually:** the port becomes inactive within a bound that covers the reaper (for example,
   poll for up to 15 seconds), and the elapsed time is printed.
If (1) does not hold on the fixed image, the dying gate does not refuse conversions. That is a
product defect: fix it test-first, and stop the case being green by waiting alone.

Update `EXPECTATIONS.md` (base FAIL, fixed PASS, and the reason). Rebuild only what changed; reuse
the op-437 kernel and `mach.ko` if the product is unchanged. Stage two images as before, with test
files byte-identical in both.

Evidence: the commits; a short note giving the cause, (1)'s result code on base and fixed from
source, and both image hashes and BOMs (by path).

## Limits

- Batch 3 scope only. No FreeBSD-side changes.
- No push of `wip-rmxos`.

Re-read OPS.md first: defaults and the REPORT block.
