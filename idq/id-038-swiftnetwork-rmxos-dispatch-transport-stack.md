# id-038 — SwiftNetwork on rmxOS: Dispatch-backed system transport over FreeBSD sockets

- id: **id-038**
- state: **WAITING — design banked; post-preview/non-gating.** No implementation op is fetched.
  Coordinator must decide placement, dependency mirroring, external engagement, and the concrete
  Swift-side writable repository/executor before work is issued.
- raised: 2026-07-11 (Arranger2 adjudication of the unnumbered Oracle consult dated 2026-07-04).
- primary L1i: **li-9001** (Swift toolchain/integration umbrella).
- relations: **li-9005** (Swift priority/`dispatch_activate` sibling), **li-1002 / id-006**
  (native Dispatch substrate), **li-9003** (engine attribution/TWQ), **li-1012** (artifact
  provenance), and **li-9006 / id-039** (Zig borrowed-queue sibling).

## SOURCE RECORD AND DISPOSITION

Banked consult:

`/Users/me/wip-mach/rmx-oracle/swift-network-rmxos-integration-design.md`

- SHA-256: `d662724f472d876f1772ac1cf6bc7f78e2daffc419d13124f0ae507fcbb821bf`
- length: 305 lines
- verdict: **DESIGN-BANKED / PREP-SUFFICIENT**, not implementation-ready and not a preview gate.

Arranger2 read the note end-to-end and spot-verified the load-bearing FreeBSD kTLS constants in
the current product source: `TCP_TXTLS_ENABLE=39` and `TCP_RXTLS_ENABLE=41`. Remaining source and
toolchain assumptions below retain explicit verification gates; the consult does not authorize a
vendor import, clone, upstream PR, product change, or guest attempt.

## BANKED ARCHITECTURE

SwiftNetwork is a strong candidate for rmxOS's eventual base-system transport stack because its
default execution model already converges on the substrate rmxOS owns:

```text
SwiftNetwork NetworkContext
  → serial Dispatch queue
  → Dispatch read/write/timer sources
  → rmxOS libdispatch
  → kqueue + pthread_workqueue/TWQ
  → FreeBSD TCP/UDP sockets
```

The upstream stack uses Dispatch queues, read/write sources, and a timer wheel; its public
`Scheduler` seam is a bounded hedge, not the primary plan. The intended first port keeps the
FreeBSD Swift triple and routes FreeBSD through the BSD-shaped system code, rather than emulating
Linux or waiting for a Darwin identity layer.

The current platform split is the first compile/behavior risk to re-confirm at the pinned source:
the rmxOS FreeBSD toolchain exposes a Glibc-named libc module, while SwiftNetwork's Glibc arm is
Linux-shaped (netlink and Linux sockaddr assumptions). The Darwin-side system code is mostly
BSD-shaped but contains a small Apple-only seam such as `connectx`, continuous-time calls, and
interface functional-type classification. Treat “thin patchset” as a hypothesis until a complete
source/build census at the chosen revision proves the exact adaptation surface.

## DECODED SHORT-TERM LADDER

### S0 — dependency and source closure (Coordinator-gated)

- Pin SwiftNetwork and enumerate the exact dependency graph, including SwiftTLS, Swift Crypto,
  Collections/BasicContainers, and any later NIO/HTTP3 layer.
- Mirror/clone only after Coordinator network and repository approval.
- Read SwiftTLS first-hand before making any kTLS secret-export or record-backend claim.

### S1 — native Dispatch fd/timer substrate proof (first execution gate)

Before Swift build work, prove the exact socket-source shape independently:

- TCP and UDP fd read/write sources plus timer sources;
- drain-until-would-block, suspend/resume/backpressure, cancel, and teardown;
- pool-forced and TWQ regimes with explicit engine attribution;
- semantic completion/liveness bars, never timing/thread-placement equality.

This is a native libdispatch hardening gain even if SwiftNetwork remains deferred. Explorer owns
conformance content; Gatekeeper owns registration/runtime evidence in a separate op/repository.

### S2 — pinned FreeBSD-triple build probe

- Build a vendored/pinned SwiftNetwork revision in the Coordinator-named Swift repository.
- Audit manifest platform support, feature availability, libc-module selection, BSD struct layout,
  routing-socket/interface paths, `connectx` fallback, and clock selection.
- Keep the patchset upstream-shaped and localize C visibility shims; do not imitate netlink.
- TLS remains off until S0 establishes its source/dependency and key-export premises.

### S3 — loopback semantic parity

Use upstream IPUDPTransfer, SocketTransfer, QUICHandshake, QUICTransfer, and QUICStreamLoad shapes
where available. Capture macOS truth and rmxOS results through the established
park/xfail/activate pipeline. Compare semantic invariants—completion, counts, state transitions,
and errors—under both rmxOS engines.

### S4 — first-scope fence

Initial claim is TCP/UDP/QUIC loopback, Dispatch timers, and qlog-style observability only. No
listener/system-service commitment, socket-option expansion, NIO/HTTP3 stack, or TLS/kTLS claim is
implicitly included.

## LONG ARC (BANKED, NOT FETCHED)

- **TCP+TLS kTLS:** possible only if SwiftTLS exposes or can gain a traffic-secret/record-backend
  seam; explicitly does not apply to QUIC packet protection.
- **Darwin-path convergence:** later os/logging and target-identity work should delete local
  routing shims rather than grow them.
- **FreeBSD QUIC hardening:** ECN/TOS control messages and `SO_REUSEPORT_LB` are potential additive
  upstream work. No UDP GSO is currently established; do not claim Linux-class throughput.
- **System integration:** launchd socket activation and notify/config route-change publication are
  later work, gated by the relevant Mach-receive/service substrate.
- **NIO/HTTP3 and upstream PRs:** pkg/ecosystem and external-engagement lanes, both Coordinator
  decisions.

## FETCH GATES

This ID becomes fetchable only after the Coordinator names scope/placement and the writable Swift
executor/repository. The first runtime op is S1, not a Swift vendor/build op. Any S2 implementation
brief must pin source/dependencies and re-verify the platform-arm and API-surface claims first-hand.

## BOUNDARIES

- Post-preview and non-gating by default; no li-1000 scope change.
- No network clone, vendor import, upstream contact, or product edit is authorized by this ID.
- One op writes one role-owned repository. Explorer content, Gatekeeper registration/evidence,
  Swift package work, and native product work are separate ops.
- No Linux emulation, no second reactor by default, no timing-parity claims, and no kTLS-for-QUIC.
- feedback: `verify-premise-before-mechanism`, `verify_signature_divergence_claims`,
  `artifact_identity_needs_content_check`, `agent_host_isolation`, `build_is_implementer`,
  `no_conflate_gating_with_readiness`.
