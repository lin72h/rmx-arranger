---
id: op-544
state: draft
agent: implementer
repo: rmx-implementer
idq: id-061
authority: image configuration only (ddb.conf, rc.conf) on copies of existing images; 5 self-check boots; doas bhyve, bhyvectl, vmm.ko; no push
expected: 3h
updated: 2026-10-07T10:33Z
---
# op-544 — Implementer: id-061 kernel debugger dump of every thread when launchd stalls or shutdown hangs

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 3 hours** (image and runner 1 h, runs 1 h,
record 1 h).

op-541 (`docs/op541-request-chain.md`) ran the standalone request
chain 20,000 times with no stall, and its second boot did not power
off although no launchd test ran. So id-061's shutdown hang does not
need the launchd tests, and the chain test alone does not reproduce
the missing reply. Next, look at every thread in the kernel at the
moment of a hang, using the kernel debugger, with no change to
launchd, the kernel or the tests.

1. **Diagnostic image.** A copy of
   `op541-current-chain-r1.raw` (`mach-fixes-6@4de4d9ae` plus the chain
   test) with only image configuration added: `ddb_enable="YES"` in
   `/etc/rc.conf` and an `/etc/ddb.conf` script for
   `kdb.enter.panic` that prints `ps`, `alltrace`, `show allchains`,
   `show sleepchain` for launchd's threads if available, and `show
   alllocks` if the kernel has it, then continues to reboot. Show from
   the METALOG/BOM diff that only those two files differ.
2. **Runner.** When a run stalls (a launchd consumer case reports
   `launchd control reply missing`, or the guest does not power off
   within 45 s of "System shutdown time has arrived"), send the guest
   an NMI with `bhyvectl --inject-nmi` for that VM; the kernel treats
   it as a panic (`machdep.panic_on_nmi`, `nmi_call_kdb` in
   `sys/x86/x86/cpu_machdep.c`) and the DDB script writes the dump to
   the serial log. Then destroy the VM as usual. Check the NMI path on
   one boot first by sending it at a quiet prompt.
3. **Runs.** Paced repeat of the launchd consumer cases, as in op-526,
   until a stall, plus the normal shutdown. Use the remaining boots to
   catch at least one shutdown hang, and a missing reply if it
   occurs.
4. **Report** from the dump: what each launchd thread was waiting on
   (wait channel and stack), whether any thread was blocked on a lock
   or sleep that another thread holds, and which Mach or kqueue object
   each was in. Name a cause only with file:line from the source.

Do not fix anything in this op.

Evidence: commits; your op record (`docs/op544-stall-dump.md`) with
the image and runner change, each boot (what was run, any stall, the
dump's serial lines), image hash and BOM by path; the `selfcheck:`
line.

## Limits

- Image configuration and the runner only: no kernel, launchd,
  libdispatch, libxpc or test change. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
