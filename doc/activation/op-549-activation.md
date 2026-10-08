---
id: op-549
state: closed
agent: validator3
repo: rmx-validator3
idq: id-061
authority: none beyond the defaults: read-only; no guests
expected: 1h30m
issued-at: 2026-10-08T02:10Z
updated: 2026-10-08T02:24Z
---
# op-549 — Validator 3: review of op-547 (id-061 per-thread MIG reply port in libmach)

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Review the source.

**Expected time: about 1.5 hours.**

id-061: launchd sometimes did not answer a request, and shutdown then
hung. A kernel debugger dump (op-544) showed launchd's main thread and
its kqueue helper both waiting on the same empty reply port. Cause:
`lib/libmach/mach/mig_support.c` kept one process-wide
`mig_reply_port` for all threads, so concurrent synchronous MIG calls
shared it. op-547 is 3 commits on `mach-fixes-6`, from `cb664232` to
`wip-rmxos@e2fa6df9`: tests `b7707d87`, `e2fa6df9`; fix `c094d4ad`
(`mig_support.c` only). Source:
`/Users/me/wip-mach/rmx-implementer/build/op468/source` (read-only;
use `git show` or your own worktree). Record:
`/Users/me/wip-mach/rmx-implementer/docs/op547-mig-reply-port.md`.

Check:
1. **Per-thread port:** `mig_get_reply_port` returns the calling
   thread's port from a pthread key, created on first use; a failed
   `pthread_setspecific` releases the new port.
2. **Dealloc:** `mig_dealloc_reply_port` clears and releases only the
   calling thread's port; nothing else holds it afterwards.
3. **Thread exit:** the key destructor releases the receive right
   exactly once, and cannot itself create a new reply port (is
   `mach_port_mod_refs` a trap or a MIG call in our libmach?).
4. **Fork:** `mig_init`, called from `mach_init` in the child
   (`mach_init.c:42-50`), drops the inherited slot without releasing a
   name that belongs to the parent's space. Is there any path where
   the child still uses the parent's name?
5. **Callers:** every MIG stub and other caller of
   `mig_get_reply_port` / `mig_dealloc_reply_port` /
   `mig_put_reply_port` in libmach, libdispatch, libxpc and launchd
   still works with per-thread ports; `NULL` from `mig_get_reply_port`
   (key failure) is handled by the stubs.
6. **Static consumers:** is libmach linked statically anywhere
   (`rescue`), and was it rebuilt?
7. **Tests:** would `mig_reply_ports_test` (`identity`, `concurrent`,
   `dealloc`, `exit`, `fork`) detect the defect at `cb664232`, and is
   every wait bounded?

Distinguishing question: after op-547, can a MIG reply still be
received by a thread other than the one that sent the request, or can
one thread's call destroy a reply port another thread is waiting on?

Re-read OPS.md first: defaults and the reply block.
