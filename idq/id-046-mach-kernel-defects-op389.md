# id-046 — Mach kernel defects inherited from the NextBSD port (op-389)

- id: **id-046**
- state: **WAITING — Coordinator: schedule an Implementer fix batch, and decide whether it gates the preview**
- raised: **2026-09-28 by the Arranger, from advisor2 op-389 (rmx-advisor2 2f6c337)**
- parent: id-042 (1.0-preview), beside id-045

## Problem

advisor2's op-389 deep dive found 14 confirmed defects and one suspect in `sys/compat/mach/` at
alpha2 `2884304b`. Almost all are inherited unchanged from NextBSD's FreeBSD 12.0 port. Several can
be reached from ordinary user code, and some of those panic the kernel or use freed kernel memory.
Consult: `/Users/me/wip-mach/rmx-advisor2/op-389-mach-freebsd12-assumptions-alpha2.md`.

## Arranger first-hand check (`git show 2884304b:…`)

Traced at source; each holds as stated:
- **3** `mach_fileops` sets only close/stat/kinfo (`ipc_entry.c:224-230`), and `poll(2)` calls
  `fo_poll` through that NULL pointer (`sys_generic.c:1809-1822`, `file.h:400-404`). Any process
  that polls one of its Mach port names panics the kernel. The same holds for `fcntl(F_SETFL)` via
  `fo_ioctl`.
- **2** the port-name lookup returns `fp->f_data` after `fdrop` (`ipc_entry.c:353-368`).
- **4** fork copies registered, exception and bootstrap send rights into the child
  (`ipc_tt.c:193-210`). Ordinary exit never releases them.
- **5** `mach_msg_receive_results` clears `ith_kmsg` and then calls the error helper
  (`mach_msg.c:590-597`), which rereads it and passes NULL to `msg_receive_error` (`:505`).
- **9** Capsicum check is `CAP_ALL1` only and the fd is installed with NULL filecaps (`ipc_entry.c:383-395`).
- **12** `kern_finstall` takes its own hold (`:967`); the transfer path drops its reference only
  on failure (`:432-433`), so each successful transfer leaks one file reference.
- **13** `ipc_pset_alloc_name` omits the TAILQ, sx and knlist init that `ipc_pset_alloc` has
  (`ipc_pset.c:215-220` vs `250-259`).
- **1** is real code, but the shipped module does not compile its assertion. The op-364 `mach.ko`
  was built as a standalone module with an empty `opt_global.h` (`build-mach-module.log`), and has
  no assertion strings, while the RMXOS-RELEASE kernel does. So 1 (and 11's assertion) is latent
  in the shipped build and fires only in an INVARIANTS module build. With the assertion compiled
  out, 11's alternative applies: Mach cleanup closes descriptors in a shared table.
- **10** there is no `HZ` override in RMXOS-RELEASE, MACHDEBUGDEBUG or std.debug. A bhyve guest
  defaults to hz=100, so Mach millisecond timeouts run 10× long there.

Not independently traced: 6, 7, 8, 11, 14, 15 (15 is advisor2's own "suspected").

## Separate build finding

`mach.ko` is built outside the kernel configuration, so it does not share the kernel's options
(INVARIANTS and the rest). Decide whether the module should build with `KERNBUILDDIR` of its
kernel. Enabling INVARIANTS there turns 1 and 11 into panics until they are fixed.

## Proposed route (Arranger)

One Implementer fix batch with a regression probe per fix, smallest first. Order: 3, 5, 13, 12, 2,
9, 4, then 7 and 8. Then one Validator. 3 alone is a user-triggerable kernel panic, and that
argues for gating the preview on at least 3, 5 and 13. 1, 10 and 11 need the build decision
above. 14 belongs with id-045 (module load and unwind). The batch touches no PID-1 or launchd
code, so it can run alongside op-391.

## Shape (Arranger, after discussion with the Coordinator, 2026-09-28)

No fundamental mismatch: ports as fds, Mach events as kqueue filters, and task state in FreeBSD's
proc storage all remain viable on stable/15. The route is repair, not redesign, in two parts:
1. Local fixes, a few lines each: 3, 5, 13, 12, 9.
2. Pattern fixes: direct receive consumes messages during kqueue's readiness checks (6; needs
   XNU's readiness/delivery split); object lifetime across lock drops and fdrop (2, 7, 15; sweep for the
   pattern, not only three sites); task teardown on ordinary exit (4); the module build outside
   its kernel's configuration.
Part 2 decides architecture: the Mach receive and event model, the object lifetime model, and
task lifetime on FreeBSD. It starts with an Advisor architecture proposal and a Coordinator
decision before any code (Coordinator: architecture correctness first, 2026-09-28).
Caveat: one source-only review. It shows where bugs are, not that the list is complete.
