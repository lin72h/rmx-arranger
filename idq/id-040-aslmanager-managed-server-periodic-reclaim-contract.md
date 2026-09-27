# id-040 — aslmanager managed-XPC-server versus periodic one-shot reclaim contract

- id: **id-040**
- state: **PRODUCT MECHANISM LANDED — op-314 retired at origin-reachable
  `26655e67872cd55cff0a272b32b7895f55368033`; contained runtime/leg-4 gate not yet issued.
  Coordinator ruled that preview product-mode work proceeds independently of the stopped
  historical record-repair chain and selected explicit bounded one-shot mode.**
- raised: 2026-07-11, from Arranger2's first-hand op-293 evidence/source adjudication.
- parent: **li-1004 / id-011** (ASL leg-4); related **li-1005/libxpc**, **li-1006/launchd**,
  **li-1011** (preview scoping).

## Verified problem statement

op-257's test image schedules `/usr/sbin/aslmanager -s /var/log/asl -size 500K -d` as a named
launchd job with `RunAtLoad` and `StartInterval=900`. That configuration cannot exercise
aslmanager's one-shot CLI path in the current source:

- `usr.sbin/aslmanager/aslmanager.c:1590-1592` calls `VPROC_GSK_IS_MANAGED`; only an unmanaged
  process calls `cli_main(argc, argv)`.
- The managed branch (`:1594-1605`) ignores those CLI arguments, creates the
  `com.apple.aslmanager` XPC listener, and deliberately enters `dispatch_main()`.
- `sbin/launchd/core.c:8401-8403` returns managed=1 for every non-anonymous launchd job.
- op-293 observed exactly that branch at runtime: one launchd child remained sleeping in the event
  loop through tick 1710. This is not evidence of a library constructor or a StartInterval defect.
- The donor/Ravyn plist uses `MachServices/com.apple.aslmanager` and no periodic interval. In the
  current rmxOS tree, the libasl/asld XPC trigger path is disabled (`asl_util.c` under `#if 0` and
  the asld call sites commented), so donor-faithful on-demand reclaim is not yet wired.

Adding `exit()` after `main` is invalid: managed mode intentionally never returns from
`dispatch_main`, and forced exit would destroy the XPC-service contract.

## Coordinator ruling — 2026-07-11

Proceed independently of op-296…op-302's incomplete historical record hygiene. For the narrow
1.0-preview feature stripe, select **option 2: bounded preview one-shot mode** and fetch it as
Implementer op-314.

The selected contract is an exact `-once` token, a distinct
`com.rmxos.aslmanager.once` periodic job at 900 seconds, stock production ASL retention settings,
and preservation of the zero-extra-argument managed XPC server. The source-controlled plist is
stageable to `/etc/launchd.d`; a later contained runtime op must explicitly load it because launchd
does not auto-scan that directory.

Alternatives retained for provenance but not selected now:

1. **Faithful XPC service:** install/use the MachServices plist, restore the trigger path, and
   validate request/reply, lifecycle, and reclaim. This intersects id-029 and op-291/libxpc runtime
   acceptance and is the larger integration path.
2. **SELECTED — bounded preview one-shot mode:** add an explicit, documented CLI/once mode that remains CLI
   even when launchd-managed, pair it with a periodic plist, and catalog the divergence. Do not use
   an implicit `argc` heuristic or break the zero-extra-argument XPC server mode.
3. **Harness-only direct invocation:** use the rc.local orchestrator solely to prove ASL store
   durability/reclaim in a soak. This can supply test evidence but is not a shipped production
   scheduling solution and cannot by itself retire this ID.

Ownership remains split: op-314's Implementer changes product source/config and builds it;
after correctness validation + publication, a new separately numbered Gatekeeper op performs
provenance-gated staging/runtime acceptance and the full leg-4 soak.

## Local correction return — 2026-07-11

op-314 returned the focused three-path commit `26655e67872cd55cff0a272b32b7895f55368033`.
Arranger2's M-sized first-hand gate accepted the exact-token/in-place parser route, preserved
managed XPC server, four-key 900-second plist, documentation, isolated build, and passive ELF
evidence. Its same-op S-sized publication gate now verifies clean local/tracking/live-remote
`alpha@26655e67`, 0/0; op-314 retires. No periodic invocation, reclaim, or leg-4 runtime claim
exists, so this ID remains open through the separately numbered Gatekeeper acceptance stage.

## Carried evidence limits

- op-293 Cell A proves TTL-eligible deletion only (56→48 KiB), not the commissioned >500-KiB
  size-threshold control.
- op-293 Cell B is truncated before two complete intervals and is
  `HARNESS-NOT-ACCEPTED`; op-296 owns additive evidence correction/freeze only.
- asld fd count rose 37→91 over 1710 seconds, but no fd-identity census exists. Bank as an
  observation under id-011; do not call or fix a leak without a dedicated premise gate.

## Relations

id-011 / li-1004 / op-257 / op-286 / op-293 / op-296 / op-314 / id-029 / op-291 / li-1011.

feedback: `verify_premise_before_mechanism`, `code_reasoned_verdict_is_hypothesis`,
`no_conflate_gating_with_readiness`, `launchd_plist_macos_fidelity`,
`agent_host_isolation`, `build_is_implementer`, `soak_is_gatekeeper`.
