# id-002 — QoS-attr Darwin-parity: reject `QOS_CLASS_UNSPECIFIED` on set

- id: id-002
- state: WAITING (not fetched) — low priority; a parity-hardening item, not a blocker.
  Cataloged for overclaim-strict honesty, not yet scheduled.
- raised: 2026-06-21 (surfaced during op-090V Validator review of the libthr QoS-attr export)
- lane (when promoted): evidence-lane (touches a behavioral/parity claim), libthr userland
- relation to in-flight work: none blocking. Records a known divergence in the op-090
  artifact (commit 82d68c8e9c99) that the Validators accepted as a deliberate simplification.

## The deviation (first-hand verified)

`pthread_attr_set_qos_class_np` / `_pthread_qos_class_encode` **accept**
`QOS_CLASS_UNSPECIFIED` (0x00) and normalize it to `QOS_CLASS_DEFAULT` (0x15) on read-back:

- `_qos_class_valid` (thr_attr.c) and `twq_qos_class_valid` (thr_workq.c) both accept
  `QOS_CLASS_UNSPECIFIED`.
- `twq_qos_class_from_priority_token` (thr_workq.c) collapses the UNSPECIFIED token (0x00)
  into the **same switch case** as `TWQ_QOS_CLASS_DEFAULT` (0x15) → returns
  `QOS_CLASS_DEFAULT`.
- Net: `set(attr, QOS_CLASS_UNSPECIFIED, p)` then `get(attr, &c, ...)` yields
  `c == QOS_CLASS_DEFAULT`. **Non-idempotent.**

Constants confirmed first-hand: `thr_workq_kern.h` `TWQ_QOS_CLASS_UNSPECIFIED=0x00`,
`TWQ_QOS_CLASS_DEFAULT=0x15`; `include/pthread/qos.h` `QOS_CLASS_UNSPECIFIED=0x00`,
`QOS_CLASS_DEFAULT=0x15`.

## Darwin contract (the reference)

macOS `pthread_attr_set_qos_class_np` **rejects** `QOS_CLASS_UNSPECIFIED` with `EINVAL`
(UNSPECIFIED means "no/clear QoS", not a settable class). Our platform silently accepts and
remaps it.

## Why it's parked, not fixed now

- Non-gating for the dispatch_source QoS path (op-089/op-090): libdispatch needs the symbols
  to exist with sane behavior, which they do.
- The Validators (GLM + DS4P, both 9/10) judged the accept-and-normalize a *deliberate
  simplification*, not a bug — so op-090 retired with this known.
- It only matters once we make a *strict* QoS-attr macOS-parity claim.

## Scope (when promoted)

**In:** make `set`-path reject `QOS_CLASS_UNSPECIFIED` with `EINVAL` to match Darwin (or
make the round-trip idempotent if a deliberate non-Darwin choice is preferred — Coordinator
decides which). Explorer macOS reference vector for the UNSPECIFIED-on-set EINVAL behavior.

**Out:** the broader kqueue/kevent QoS surface (that's id-001's downstream).

## Open decision (Coordinator-held)

Match Darwin strictly (reject UNSPECIFIED → EINVAL), or keep the accept-and-normalize as a
documented intentional deviation? If the latter, this becomes a DROPPED bl with the rationale
recorded rather than an op.
