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

1.0 keeps fd-backed names (A1) and does op-394's steps 2-4. Step 5 waits until after 1.0, unless a
trigger in the record fires earlier. The record lists the limitations accepted in 1.0 and the rules
that keep step 5 possible.

## Done when

Step 5 is either adopted after 1.0, with the record's requirements met, or explicitly declined.
