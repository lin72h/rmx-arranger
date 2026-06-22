# mach_msg Milestone Review

Date: 2026-04-17
Reviewer: Claude (wip-claude)

## 1. Overall Verdict

Your interpretation is sound but slightly optimistic. The first `mach_msg`
pass is a genuine milestone — you exercised the full send and receive kernel
paths without a panic or WITNESS violation, and no donor-source fix was
needed. That is a real signal. But the two probes exercised the **narrowest
possible slice** of the copyin/copyout machinery, and the specific slice
they exercised is the one least likely to expose fd-bridge bugs.

Here's the key thing to internalize: both probes are **same-space,
same-receiver** operations. The copyin side looked up port names that the
current task owns receive rights for. The copyout side materialized names
in the same space that already owned the receive right. The reverse-map
path in `ipc_kmsg_copyout_header` found existing entries via
`ipc_right_reverse` for most names — the only fresh allocation was the
reply send-once name (`reply_send_name=18`). That single fresh-name
copyout is the most interesting thing in the entire batch, and it passed.

The next real frontier is **port-right descriptors in message bodies.**
Not richer header semantics. Not cross-process yet. Body-carried port
rights are where the copyin/copyout complexity actually lives, and they
exercise code paths that inline-only messages completely skip.

## 2. What the Current Strongest Evidence Actually Proves

### Proven (strong confidence)

1. **The `mach_msg_trap` syscall wiring is correct for the basic
   send+receive case.** `syscall(SYS_mach_msg_trap, ...)` with up to 7
   arguments dispatches correctly through `sys_mach_msg_trap` →
   `mach_msg_overwrite_trap` → `mach_msg_send` / `mach_msg_receive`.

2. **`ipc_kmsg_get` copyin works for inline messages on FreeBSD 15
   amd64.** The `copyinmsg()` path with `LEGACY_HEADER_SIZE_DELTA`
   handling produced a valid kernel message from a user-space
   `mach_inline_send_msg`.

3. **`ipc_kmsg_copyin_header` handles `COPY_SEND` to a same-space
   combined SEND|RECEIVE entry.** Specifically, this went through the
   `!MACH_PORT_NAME_VALID(reply_name)` fast path (case 1) and the
   `dest_name != reply_name` two-entry path (case 2). The
   `dest_name == reply_name` 25-combination special case was NOT
   exercised.

4. **`ipc_kmsg_copyin_header` handles `MAKE_SEND_ONCE` for a reply port
   in the two-entry path.** Case 2 used `MACH_MSG_TYPE_MAKE_SEND_ONCE`
   for `msgh_local_port`, and the copyin correctly acquired a send-once
   right on the reply port.

5. **`ipc_mqueue_send` + `ipc_mqueue_deliver` works for a same-space
   port with no waiting receiver.** The message was enqueued (msgcount
   0→1) and survived until the subsequent receive.

6. **`ipc_mqueue_receive` without blocking works.** The message was
   already queued, so the fast path fired. `MACH_RCV_TIMEOUT` with 50ms
   was specified but not needed.

7. **`ipc_kmsg_copyout_header` handles the receive side for both
   no-reply and reply-port cases.** For case 1 (no reply port), the
   simple `is_read_lock` path was taken. For case 2, `ipc_right_reverse`
   found the existing request-port entry, and `ipc_entry_get` allocated
   a fresh entry for the reply send-once right. The fresh name
   (`reply_send_name=18`) was correctly materialized.

8. **`MOVE_SEND_ONCE` in the reply message works.** Case 2's reply used
   `MACH_MSG_TYPE_MOVE_SEND_ONCE` for the remote disposition, consuming
   the send-once right that was materialized during the request copyout.
   This exercises a different `ipc_right_copyin` branch than `COPY_SEND`.

9. **Message queue depth tracking is correct.** `msgcount` transitions
   0→1→0 for both request and reply ports, confirming `ipc_mqueue_send`
   increments and `ipc_mqueue_receive` decrements correctly.

10. **Inline payload and header identity survive the round-trip.** Both
    `msgh_id` and the 4-byte inline payload matched on receive, confirming
    `ipc_kmsg_get` / `ipc_kmsg_put` don't corrupt inline body data.

### Not proven (and structurally cannot be proven by these two probes)

1. **Port-right descriptors in message bodies.** `ipc_kmsg_copyin_body`
   and `ipc_kmsg_copyout_body` were never called. These functions handle
   `MACH_MSG_PORT_DESCRIPTOR`, `MACH_MSG_OOL_DESCRIPTOR`, and
   `MACH_MSG_OOL_PORTS_DESCRIPTOR`. This is an entirely separate code
   path from inline-only messages. The `msgh_bits` in both probes had
   `MACH_MSGH_BITS_COMPLEX` unset, so the body copyin/copyout was
   skipped entirely.

2. **Cross-space right transfer.** Both probes operate in one task's
   space. The copyin looked up names owned by the current task. The
   copyout materialized names in the same space. No port reference ever
   crossed a space boundary.

3. **`MOVE_SEND` disposition in the header.** Only `COPY_SEND` and
   `MOVE_SEND_ONCE` were tested. `MOVE_SEND` in `ipc_right_copyin`
   takes a different branch that decrements `ip_srights` and may
   deallocate the entry. This has not been exercised via messages.

4. **`MAKE_SEND` disposition in the header.** Never tested. This is the
   disposition used by servers when replying with a send right to a
   client's port.

5. **Same-name dest==reply special case.** The 25-combination path in
   `ipc_kmsg_copyin_header` (lines 1073-1245) was not exercised. Both
   probes used distinct dest and reply names.

6. **Dead-name handling during copyin or copyout.** All ports were alive
   throughout both probes. The error/cleanup paths in copyin_header and
   copyout_header were never taken.

7. **Blocking receive.** `ipc_mqueue_receive` → `thread_block()` was
   never tested. Both probes had the message already queued before
   calling receive.

8. **Any receive from a port set.** Both probes received from a named
   port, not a port set.

9. **Any message with `msgh_size` larger than header + 4 bytes.** The
   inline payload is exactly one `uint32_t`. Larger messages exercise
   different `ipc_kmsg_get` / `ipc_kmsg_put` allocation paths.

10. **`ip_srights` accounting through the message path.** Case 1 used
    `COPY_SEND`, which does not modify `ip_srights`. Case 2's
    `MAKE_SEND_ONCE` creates a send-once right. Neither probe verified
    `srights` or `sorights` at each step — only `msgcount` was checked
    during the message flow.

## 3. The Most Fundamental Remaining Risk

**Port-right descriptors in message bodies (`MACH_MSGH_BITS_COMPLEX`).**

This is not one of the candidates you listed. Here's why it outranks them
all:

The entire purpose of Mach IPC is to transfer capabilities (port rights)
between tasks via messages. The header path handles the remote and local
ports (destination and reply). The body descriptor path handles **all
other port transfers**: passing a send right to a service, returning a
new port from a server, transferring multiple rights in one message.

`ipc_kmsg_copyin_body` (which has never been called) does:

1. Walks the descriptor array in the message body
2. For each `MACH_MSG_PORT_DESCRIPTOR`:
   - Calls `ipc_entry_lookup` to find the named port
   - Calls `ipc_right_copyin` with the descriptor's disposition
   - Stores the kernel `ipc_port_t` pointer in the kernel message
3. For each `MACH_MSG_OOL_PORTS_DESCRIPTOR`:
   - Copies in an array of port names from user space
   - Calls `ipc_right_copyin` for each one
4. Tracks total rights acquired for cleanup on error

`ipc_kmsg_copyout_body` does the reverse:

1. Walks the descriptor array
2. For each port descriptor:
   - Calls `ipc_object_copyout` to materialize a name in the receiver's
     space
   - This is the same reverse-map path that already needed a WITNESS fix
     (batch 16), but now called in a different locking context
3. For OOL ports: allocates user-space memory and copies out names

**Why this is the highest risk:**

- It exercises `ipc_entry_lookup` (fd bridge `fget()`) in a loop, not
  just once or twice
- It exercises `ipc_right_copyin` with dispositions that the header path
  may never use (e.g., `MOVE_SEND` for transferring a send right)
- It exercises `ipc_object_copyout` in the receiver's space, which is
  the reverse-map + fresh-entry allocation path — the same path that
  already had a WITNESS bug
- Error cleanup in `ipc_kmsg_clean_body` must destroy partially-copied
  rights, calling `ipc_object_destroy` for each — the same function
  that the implicit-close patch routes through
- The body copyin/copyout runs **while the space write lock is held** in
  some paths, creating locking combinations that inline-only messages
  never produce

### Ranking of your listed risks

1. **Body-carried rights / descriptors** — this IS the risk. Your
   candidate list had it, but I'm promoting it to #1. Everything else
   is either downstream of it or lower severity.
2. **Copyin/copyout mismatches that only appear with transferred rights**
   — yes, and body descriptors are where they'll manifest.
3. **Richer header semantics** — lower priority than body descriptors.
   `MOVE_SEND` and `MAKE_SEND` in the header are worth testing, but they
   exercise already-proven `ipc_right_copyin` paths with only minor
   branch differences. Body descriptors exercise entirely new code paths.
4. **Queue/wakeup semantics under less-trivial receive** — relevant for
   blocking receive and port-set receive, but not the next frontier.
   These can wait until body descriptors work.
5. **Another fd/filedesc bridge mismatch** — yes, and body descriptors
   are where you'll find it. The body copyin/copyout calls
   `ipc_entry_lookup` and `ipc_object_copyout` in loops with different
   locking contexts.
6. **`swtch`** — still orthogonal. Addressed below.

## 4. Best Next-Step Sequence

### The minimal honest body-descriptor probe

The smallest useful complex-message test is **same-process send-to-self
with one `MACH_MSG_PORT_DESCRIPTOR` carrying a send right.** This
exercises body copyin and copyout while staying in the same space:

```
1. Allocate receive right → recv_name
2. Make send right on recv_name → combined SEND|RECEIVE entry
3. Allocate a second receive right → cargo_recv
4. Make send right on cargo_recv → combined SEND|RECEIVE entry
5. Construct complex message:
   - msgh_bits = MACH_MSGH_BITS(MACH_MSG_TYPE_COPY_SEND, 0)
                 | MACH_MSGH_BITS_COMPLEX
   - msgh_remote_port = recv_name
   - msgh_local_port = MACH_PORT_NULL
   - msgh_size = sizeof(header) + sizeof(mach_msg_body_t)
                 + sizeof(mach_msg_port_descriptor_t)
   - body.msgh_descriptor_count = 1
   - descriptor[0].name = cargo_recv (send right to cargo port)
   - descriptor[0].disposition = MACH_MSG_TYPE_COPY_SEND
   - descriptor[0].type = MACH_MSG_PORT_DESCRIPTOR
6. mach_msg(MACH_SEND_MSG) → sends the message
7. Read recv_name status → msgcount should be 1
8. mach_msg(MACH_RCV_MSG) on recv_name → receives the complex message
9. Verify:
   - received body.msgh_descriptor_count == 1
   - received descriptor[0] is a valid port name
   - received descriptor[0] type is MACH_MSG_PORT_DESCRIPTOR
10. Read cargo_recv status → verify srights accounting
11. Destroy all names → return to baseline
```

This is the right first probe because:
- It forces `ipc_kmsg_copyin_body` to run (COMPLEX bit set)
- It forces `ipc_kmsg_copyout_body` to materialize a port name from
  a kernel ref
- It exercises the body-descriptor `ipc_right_copyin` path with
  `COPY_SEND` — the gentlest disposition (no entry deallocation)
- Since sender==receiver, the copyout might reverse-map to an existing
  entry (interesting!) or allocate fresh (also interesting!)
- The per-port observability can verify `srights` changes at each step
- If it panics, WITNESS will catch locking issues in the body path
- It stays same-process, avoiding cross-task complexity

### If COPY_SEND body descriptor works: add MOVE_SEND

```
1. Same setup as above
2. descriptor[0].disposition = MACH_MSG_TYPE_MOVE_SEND
3. Verify:
   - send right is consumed from cargo entry during copyin
   - received descriptor materializes a send right
   - srights accounting is correct
```

This tests the `MOVE_SEND` path in body copyin, which deallocates the
sender's entry. This is where the fd bridge's `ipc_entry_close` path
gets exercised in a new locking context.

### If MOVE_SEND body descriptor works: add MAKE_SEND header

```
1. Allocate recv_name
2. Send message with:
   - msgh_remote_port = recv_name
   - msgh_bits remote = MACH_MSG_TYPE_MAKE_SEND
   - (no body descriptors, just testing the header disposition)
3. Receive and check that the received message's remote port has a
   send right (not receive)
```

This fills the remaining header-disposition gap.

### Recommended 6-10 hour block

| Step | Time | What |
|------|------|------|
| 1 | 1h | Write same-process send-to-self with one COPY_SEND port descriptor |
| 2 | 1h | Build and run under MACHDEBUGDEBUG |
| 3 | 2h | Debug whatever breaks (expect WITNESS or copyin_body issues) |
| 4 | 1h | Once COPY_SEND descriptor passes: add MOVE_SEND descriptor variant |
| 5 | 1h | Run MOVE_SEND variant, debug |
| 6 | 1h | Add per-port observability checks around descriptor ops (srights, sorights changes through the message path) |
| 7 | 1h | Document findings, commit clean evidence |
| 8 | 1h | If time: add MAKE_SEND header disposition variant |

### What I expect to break

1. **`ipc_kmsg_copyin_body` → `ipc_entry_lookup`** in the descriptor
   walk. This calls `fget()` through the fd bridge while the space write
   lock is held — a locking context that inline-only messages don't
   create. WITNESS may flag a new lock-order issue.

2. **`ipc_kmsg_copyout_body` → `ipc_object_copyout`** when materializing
   the port descriptor name in the receiver's space. This is the
   reverse-map path. For same-space send-to-self with COPY_SEND, the
   port already has an entry in the current space, so `ipc_right_reverse`
   should find it. But the locking context (inside message receive, after
   mqueue operations) may differ from the lifecycle path that was already
   fixed.

3. **Descriptor count / size validation.** The kernel validates that
   `msgh_size` matches the declared descriptor count. If the size
   calculation in the probe is wrong, copyin will fail with
   `MACH_SEND_MSG_TOO_SMALL` before reaching the interesting code.

4. **`ipc_kmsg_clean_body` on error cleanup.** If copyin_body partially
   succeeds, the cleanup path calls `ipc_object_destroy` for each
   already-copied right. This exercises the same `ipc_object_destroy`
   function as the implicit-close patch, but in a different calling
   context.

## 5. What to Avoid

1. **Do not add more inline-only message variants.** The inline path
   is proven for the basic cases. Adding larger payloads, different
   inline sizes, or multiple inline sends in sequence will not find
   new bridge bugs. The complexity is in the body descriptor path, not
   the inline data path.

2. **Do not try cross-process before body descriptors work.** Cross-
   process adds fd-inheritance problems, bootstrap bootstrapping, and
   synchronization complexity. It also requires body-descriptor port
   transfer to be useful (the whole point of cross-process Mach IPC is
   transferring rights). Get body descriptors working same-process first.

3. **Do not add header-disposition variants before body descriptors.**
   `MOVE_SEND` and `MAKE_SEND` in the header are branches of the same
   `ipc_right_copyin` function already exercised. Body descriptors
   exercise `ipc_kmsg_copyin_body` and `ipc_kmsg_copyout_body` — entire
   functions that have never been called.

4. **Do not add blocking receive probes yet.** `thread_block()` in the
   receive path is a scheduler integration point that should wait until
   the non-blocking message path is thoroughly exercised. For now, always
   use `MACH_RCV_TIMEOUT`.

5. **Do not add port-set receive probes yet.** Port-set receive adds
   `ipc_mqueue_select` complexity that is independent of the body-
   descriptor question. It can come after body descriptors.

6. **Do not investigate `swtch` yet.** Still orthogonal. The message
   path is higher value per hour. `swtch` remains a scheduler-lock bug
   that doesn't affect IPC characterization.

7. **Do not add `srights`/`sorights` observability to the existing
   batch 17 probes retroactively.** The existing probes pass; they
   are committed evidence. Add richer observability to the NEW body-
   descriptor probes instead.

8. **Do not treat "no donor-source fix was required" as "the bridge is
   correct."** The inline path is the gentlest consumer of the fd
   bridge. Prior bugs were all found by exercising new consumers. Body
   descriptors are the next new consumer.

## 6. Open Assumptions

1. **`MACH_MSGH_BITS_COMPLEX` is correctly propagated through
   `ipc_kmsg_get`.** The copyin path checks `msgh_bits & MACH_MSGH_BITS_COMPLEX`
   to decide whether to call `ipc_kmsg_copyin_body`. If the legacy header
   translation strips or corrupts this bit, body copyin will be silently
   skipped and the message will appear to work (but without the descriptor).
   The probe should verify the received `msgh_bits` includes COMPLEX.

2. **`mach_msg_body_t` and `mach_msg_port_descriptor_t` layout matches
   between user-space headers and kernel expectations.** The struct
   packing must match exactly. If there's a padding difference between
   the user-space Mach headers and the kernel's expectations, the
   descriptor walk will read garbage.

3. **Same-space copyout of a COPY_SEND descriptor will reverse-map.**
   When the sender and receiver are the same task, and the descriptor
   carries a COPY_SEND of a port that already has an entry in the space,
   `ipc_object_copyout` should find it via `ipc_right_reverse` and
   increment the send count rather than allocating a fresh name. This
   is the expected behavior but hasn't been verified.

4. **The observability sysctl can read `srights` changes caused by
   body-descriptor copyin/copyout.** The per-port status reads
   `ip_srights` and `ip_sorights` from the port object. Body copyin
   with `COPY_SEND` calls `ipc_port_copy_send`, which increments
   `ip_srights`. The probe should verify this increment.

5. **`ipc_kmsg_copyout_body` handles the `MACH_MSG_PORT_DESCRIPTOR`
   case in the fd bridge.** The copyout path calls `ipc_object_copyout`,
   which eventually calls `ipc_entry_get` or `ipc_right_reverse` to
   find/create a name. Under the fd bridge, `ipc_entry_get` allocates
   an fd. If the fd allocation fails or the entry setup is incorrect
   for body-descriptor ports, the receive will fail.

6. **`swtch` can continue to be deferred without strategic cost.**
   This assumption has held through four review cycles. The `swtch` bug
   is a scheduler-lock ownership issue (`panic: mutex sched lock 1 not
   owned`) that is orthogonal to IPC. It would only become strategic if
   the message path needs `thread_block()` (blocking receive), which is
   not in the next block's scope.

## Delta Since Last Review

The last review (`donor-lane-frontier-review.md`) recommended:
1. Same-process send-to-self with inline-only message → **done, passed**
2. Add reply-port variant → **done, passed**
3. Debug whatever breaks → **nothing broke**
4. Document and commit → **done**

The "nothing broke" result is genuinely good news — it means the fd
bridge's `ipc_entry_lookup` and `ipc_object_copyout` paths are correct
for the simplest message-path consumer. But it also means the predicted
failure points (`ipc_kmsg_copyin_header`, `ipc_kmsg_copyout_header`)
were tested only on their easiest branches. The harder branches (body
descriptors, MOVE_SEND, dead-name handling) remain untouched.

The net effect: the message path has a first proof-of-life, but the
bridge's integration with message body processing is completely
unexercised. Body descriptors are the next honest probe.
