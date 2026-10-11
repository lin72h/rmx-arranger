# id-056 — XNU-style Mach name table (op-394 step 5): deferred past 1.0

- id: **id-056**
- state: **DEFERRED POST-1.0 (Coordinator, 2026-10-02)**
- raised: **2026-10-02 by the Coordinator, from op-394**
- parent: id-046; related: id-042
- record: [mach-names-step5-deferred.md](../mach-names-step5-deferred.md)

## Problem

rmxOS keeps NextBSD's design in which a Mach port name is a file descriptor. advisor2's op-394
proposal (`rmx-advisor2@519ec47`) recommends moving to a Mach-owned name table adapted from XNU,
which matches macOS and removes the fd-related limitations. It is a large ownership and ABI change.

## Decision

1.0 keeps fd-backed names and does op-394's steps 2-4. Step 5 waits until after 1.0, unless a
trigger in the record fires earlier. The record lists the limitations accepted in 1.0 and the rules
that keep step 5 possible.

## Done when

Step 5 is either adopted after 1.0, with the record's requirements met, or explicitly declined.

## Known 1.0 gap: `mach_port_names` (2026-10-11, op-644)

`sys/compat/mach/ipc/mach_port.c:233` returns `KERN_NOT_SUPPORTED`; the XNU-derived body is under
`#ifdef notyet` and walks a name table rmxOS does not have. No userland program in the tree calls
it (`git grep -w mach_port_names` at `93b3735d`, outside generated MIG code). Recorded as a known
gap with the name table (step 5); the op-644 test case `names_inventory` asserts the current
result so it changes when enumeration is implemented (op-646).
