# id-043 — Mach oversized-receive retain/report/retry contract

- id: **id-043**
- state: **WAITING — DEFERRED POST-1.0-PREVIEW; decoded/cataloged, not fetchable without a fresh
  Coordinator scope-in; no ROB op reserved**
- raised: **2026-07-11 by Coordinator scope ruling; authored by Arranger2**
- parent: **[li-9007](../l1i/li-9007.md)** (post-preview Mach compatibility track)
- preview disposition: **external/public syscall-`MACH_RCV_LARGE` callers excluded; op-281/op-282
  flushed; active libxpc trailer boundary remains under id-021**

## Problem

NextBSD and rmxOS expose `MACH_RCV_LARGE`/`MACH_RCV_LARGE_IDENTITY`, a queue-first retain branch,
required-size/identity result machinery, and a legacy `dispatch_mig_server` consumer shape. The
synchronous receive entry nevertheless passes only `option & MACH_RCV_TIMEOUT` to the mqueue, so
the queue-first layer cannot see `LARGE` or the requested trailer size. The receive-first/blocked
path also lacks a complete retain/wake/result contract after an oversized handoff.

No activated in-tree 1.0-preview syscall consumer was found. External/public consumers remain a
future compatibility surface; the gap is deferred rather than called nonexistent.

## Intended future outcome

For queue-first and genuinely blocked receives, an undersized caller using `MACH_RCV_LARGE` gets
`MACH_RCV_TOO_LARGE`, the correct required size and optional receiver identity, while the same
message and its rights/OOL resources remain available for one adequate retry. Ordinary
non-`LARGE`, timeout, trailer, port-set, readiness-only, and direct-kevent behavior must not regress.

This is not an OOL implementation. OOL payload memory is separately mapped; complex/OOL-bearing
messages are lifetime/conservation controls for the generic receive contract.

## Reactivation gate

Do not fetch this ID until the Coordinator scopes the public Mach compatibility surface back in.
At that point:

1. re-pin the then-current product and NextBSD/XNU comparator;
2. if new conformance content is needed, issue an Explorer-owned authoring op in `rmx-explorer`;
3. issue a separate Gatekeeper-owned register/stage/run premise in `rmx-gatekeeper` covering
   queue-first/blocked, size/identity, trailers, port sets, inline and complex/OOL-bearing messages,
   same-message retry, and known-bad controls;
4. accept that premise before reserving a high-blast-radius Implementer fix;
5. independently validate source/lifetime correctness and rerun the exact runtime matrix; and
6. require origin reachability before retirement.

The complete phase ladder and truly-green bar live in li-9007. Future work receives the then-next
free op IDs; never reuse flushed op-281/op-282 or closed id-036.

## Boundaries

- No product, harness, image, guest, build, or publication work is authorized by this IDQ entry.
- No current ROB op is reserved.
- Do not move id-021's active libxpc 8,192/8/52-byte trailer-admission premise here.
- Do not claim that NextBSD shipped a working syscall contract merely because the nominal symbols
  and branches exist.

## Relations

- **li-9007** — authoritative post-preview L1i contract and execution ladder.
- **li-9003 Item 5** — potential-feature catalog pointer promoted to li-9007/id-043.
- **li-9004 Items 1/5** — generic trailer honesty and receive coverage siblings.
- **li-1008 / li-1011** — known-gap catalog and bucket-3 preview exclusion doctrine.
- **id-021** — separate live libxpc trailer boundary.
- **id-042** — records the completed preview scope disposition.
- **op-313 / op-316** — consult and split-validation lineage, both retired.
- **op-281 / op-282** — flushed and never reusable.
- **op-261 / closed id-036** — provenance-only source lineage; neither is reopened.

feedback: `verify_premise_before_mechanism`, `code_reasoned_verdict_is_hypothesis`,
`no_conflate_gating_with_readiness`, `agent_host_isolation`, `build_is_implementer`,
`op_state_dispatch_boundary`
