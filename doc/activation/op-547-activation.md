---
id: op-547
state: returned
agent: implementer
repo: rmx-implementer
idq: id-061
authority: libmach build (and rescue if it links libmach statically), tests; no world; 2 ZFS images; 5 self-check boots; no push
expected: 4h
issued-at: 2026-10-07T11:25Z
updated: 2026-10-08T02:05Z
---
# op-547 — Implementer: id-061 per-thread MIG reply port in libmach (mig_support.c), then launchd repeat and shutdown

## Outcome

Context: ordinary debugging and testing of our own open-source OS
(rmxOS: FreeBSD 15 with Apple's open-source Mach, launchd and
libdispatch). Everything runs on the host or in a disposable bhyve VM
with no network.

**Expected time: about 4 hours** (tests 1 h, change 45 min, images and
self-checks 1.5 h, record 45 min).

Your op-544 dump (`docs/op544-stall-dump.md`) caught id-061's missing
reply: launchd's main thread and its kqueue helper both waiting in a
Mach receive on the same empty reply port. The cause in the source:
`lib/libmach/mach/mig_support.c:60` keeps one process-wide
`mig_reply_port`, and `mig_get_reply_port` (`:79-84`) gives that same
port to every thread. launchd's helper sends a synchronous
`handle_kqueue` request (`sbin/launchd/runtime.c:639`) and waits on
that port; if the main thread makes its own MIG call meanwhile, its
reply arrives on the same port and either thread can take it, leaving
both waiting. `mig_dealloc_reply_port` (`:91-102`) also destroys the
port that other threads are using. Apple's libsyscall keeps one reply
port per thread. Fix it on `mach-fixes-6` (local head `cb664232`).

Rules (confirm or correct from the source):
1. **One MIG reply port per thread.** `mig_get_reply_port` returns the
   calling thread's port, creating it on first use (thread-local
   storage or a pthread key).
2. `mig_dealloc_reply_port` releases only the calling thread's port and
   clears only its slot; `mig_put_reply_port` stays a no-op.
3. A thread's port is released when the thread exits (key destructor),
   exactly once.
4. After `fork`, the child starts with no cached reply port
   (`mig_init`, called from `mach_init` through `pthread_atfork`,
   `lib/libmach/mach/mach_init.c:42-50`, resets the current thread's
   slot).
5. Rebuild every consumer that links libmach statically (for example
   `rescue/rescue/Makefile`); dynamic consumers pick up the library.

Tests first (`tests/sys/mach` or `tests/lib/libmach`, Zig):
1. Two threads each make many synchronous MIG calls at the same time,
   one to a server thread in the same process and one to the kernel
   (say which MIG call you use): every call gets its own reply,
   bounded; no `MIG_REPLY_MISMATCH`.
2. The two threads observe different `mig_get_reply_port` names.
3. One thread calls `mig_dealloc_reply_port`; the other's calls keep
   working.
4. A thread that made a MIG call exits: its reply port's receive right
   is released (rights count before and after).
5. After `fork`, the child's first MIG call works and uses a port
   created in the child.

Then two ZFS images (from `op417-alpha2-zfs-gpt.raw`, kernel and
`mach.ko` from `4de4d9ae`): base = `cb664232` + the tests (name its
branch), fixed = the change + the same tests. METALOG/BOM diff: only
libmach (and any statically linked consumer) differs. Self-check: the
new cases fail on base as expected (say which cannot be shown on base
and why); fixed passes all cases; then on fixed, op-526's paced
launchd repeat for at least 400 launchd cases and a normal shutdown,
in up to two boots, with no missing reply and normal power-off.

Evidence: commits; your op record (`docs/op547-mig-reply-port.md`) with
each rule's change, test and base and fixed results, the repeat
record; both image hashes and BOMs (by path); the `selfcheck:` line.

## Limits

- `lib/libmach`, its tests and static relinks only: no kernel, launchd,
  libdispatch or libxpc change. No push.

Re-read AGENTS.md and OPS.md first: defaults and the reply block.
