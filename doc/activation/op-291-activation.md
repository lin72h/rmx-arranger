# op-291 — Gatekeeper: provenance-gated runtime acceptance of libxpc connection lifecycle

op-291 | role: **Gatekeeper Ruler** (runtime/evidence owner; no product write) | EXU:
**rmx-gatekeeper-rx-x64z** | state: **[Done — returned HARNESS-NOT-ACCEPTED 2026-07-11;
Arranger2 M-gate confirms one guest cell consumed, incomplete/invalid harness, and no product
verdict; retired op-310 accepts the static aliased-token premise and rejects op-306 prep, routing
op-307 plus a fresh post-op-005m harness→op-308; no second cell]** | parent: **op-285 / op-284 / id-021** | L1i:
**li-1005 / li-007** | related: **op-292 / op-295 / op-306 / op-307 / op-308 / id-040** | authored: **2026-07-10;
normalized and current-tip repinned 2026-07-11 by Arranger2**

## ARRANGER ADJUDICATION — 2026-07-11

The return is sized **M**: it ended at a clear non-promoting harness failure and contains no
positive product verdict requiring an independent L/XL acceptance gate. Arranger2 reproduced the
following first-hand:

- Gatekeeper commit `9a9e4cd852e9b8835b3662a8a37fe13e985a0818`, parent exact required base
  `8c1f269a498017c93778df1bfe24ae634ff6a85d`, is local-only at ahead 38 of
  `origin/main@4b16fd1b65e76cfcdb40de96069e13d3d702e3cf`; tracked worktree is clean and the
  preserved unrelated untracked set remains;
- exact staged artifact 200,208 bytes / SHA-256
  `b896e5866a7adf092283f852c17dae05244182c539dbf20afce7c18a273d46ad` matches the
  commissioned file; op-285 is an ancestor of product `alpha@ceb46edc` and the pinned libxpc
  source identities still match;
- `GK_OP291_RUNTIME_START` appears once, so the only authorized cell is consumed. The raw stream
  reaches `DONE < All buffers synced < Powering system off` with no panic/KASSERT/DEADLKRES;
- the evidence note's claimed serial SHA `2a120047...` is actually the **host** log. The real serial
  SHA is `7229f31b41b52d382be95b108a44c6974f0a794c1c09ee37875e6f7be03f4956`;
- the reported probe bug is real: `dlsym("_xpc_type_connection")` already returns the address used
  by public `XPC_TYPE_CONNECTION`; line 40 incorrectly dereferences it. But a one-line correction
  would be non-discriminating: `readelf`/`nm` on the accepted artifact show all sixteen exported
  `_xpc_type_*` objects as size zero at the same address `0xc440`. Thus dictionary, array, error,
  and connection tokens all compare equal. This is a separate source/binary-confirmed product
  premise, not an op-285 header regression;
- the observed connection bytes `04 00 00 00 01 00 00 00` are banked only as a non-promoting
  observation that type=4/refcount=1 initialization was present. They cannot establish public type
  identity or lifecycle acceptance;
- both finalizer-zero observations are invalid product evidence: cancellation drains
  asynchronously, while the probe reads immediately, reuses/resets one global counter, and gates
  only the final named count; and
- the commissioned preflight/record is otherwise incomplete: no fail-closed validator or controls,
  known-bad calibration, resource census, managed aslmanager drive, handler/message order, live
  probe/aslmanager mapping, image/harness identity record, committed executable, or command/rc
  records. `procstat -v $$` targeted the shell and returned no libxpc mapping; the raw verdict is
  merely `pending_probe_analysis`.

Canonical disposition is `HARNESS-NOT-ACCEPTED`; provenance hash matching is a useful partial, not
the commissioned provenance PASS. No second cell exists inside op-291 and no product failure or
acceptance is inferred. Recovery is the bounded chain op-306 zero-cell premise/harness preflight →
op-307 held Implementer type-token fix → op-308 held exact-artifact runtime acceptance. op-285 and
id-021 remain open.

## DISPATCH BOUNDARY

DISPATCHED by Coordinator on 2026-07-11 to `rmx-gatekeeper-rx-x64z` only. Write only
`/Users/me/wip-mach/rmx-gatekeeper/`. The product, Arranger, Explorer, Oracle, and Validator trees
are read-only.

This op may copy the accepted Implementer-built libxpc artifact into Gatekeeper-owned staging and
a disposable Gatekeeper guest image. It may not edit or build product source, push any repository,
or change the shipped image/configuration. One primary guest cell is authorized; no automatic
second cell or repair-forward is authorized.

## REQUIRED BASE IDENTITIES

### Gatekeeper execution repository

- repository: `/Users/me/wip-mach/rmx-gatekeeper/`;
- required base: `main@8c1f269a498017c93778df1bfe24ae634ff6a85d`;
- parent: `fb9040db5106d07f1722834665dddbab5ee29cd6`;
- `origin/main@4b16fd1b65e76cfcdb40de96069e13d3d702e3cf`, ahead 37; and
- preserve every unrelated untracked artifact. Do not reset, amend, rebase, clean, or push.

### Accepted product source

- repository: `/Users/me/wip-mach/wip-gpt/wip-rmxos/`;
- clean local/tracking/live-remote branch:
  `alpha@ceb46edc5f910660d4fa7ecd9e90501ebd86b1ba`;
- op-285 fix `778cb07442e61cdd8fb3e766b91676f2e9a261b8` is an ancestor;
- `lib/libxpc/xpc_connection.c`: SHA-256
  `b327fd4138c2721c9a87d4873cdb974b9d2047f0a1756c07405a2431aaa06709`, Git blob
  `7c5677e81de7ee79f93839ab43b43c20643d3b09`;
- `lib/libxpc/xpc_internal.h`: SHA-256
  `becd6d0f66409d60d132fec503cfd6efd8917659167aa3f820a8dce8c75bbca2`, Git blob
  `20fa07007c039791832eaf0f51afd206e848bf3a`; and
- `lib/libxpc/xpc_misc.c`: SHA-256
  `913fceb24f1eea8d7f717662903b30f99d39e5a473d9d878c5fd3fc51bc881bf`, Git blob
  `0100332316ae3f4461177188df1024ca5e906b65`.

### Accepted current-tip artifact

Use exactly the Implementer-built op-295 artifact:

`/Users/me/wip-mach/wip-gpt/build/op295-libxpc/obj/Users/me/wip-mach/wip-gpt/wip-rmxos/amd64.amd64/lib/libxpc/libxpc.so.5`

- size: `200208` bytes;
- SHA-256: `b896e5866a7adf092283f852c17dae05244182c539dbf20afce7c18a273d46ad`;
- format: FreeBSD 15 x86-64 ELF shared object; and
- op-292 and op-295 independently reported the same runtime binary identity; op-295 was built at
  current product tip after its header-only cleanup.

Stop with `BLOCKED IDENTITY-DRIFT` if any required identity differs. Do not silently rebuild,
repin, substitute another libxpc, or consume the obsolete op-285 artifact hash `9854f45b...`.

## PURPOSE

op-284 established the known-bad runtime premise: anonymous and named connections both returned
NULL type on an unknown/stale guest libxpc, and its lifecycle drive was incomplete. op-285 then
landed a coordinated correction: real object header/refcount, connection-specific teardown,
handler guards, and serialized first-message delivery. Later accepted commits changed neighboring
libxpc behavior but preserved this lifecycle implementation.

This op establishes whether that published correction actually works on a guest using the exact
accepted artifact. A landed edit is not runtime acceptance.

## FAIL-CLOSED HOST PREFLIGHT — ZERO CELLS

Before guest start:

1. Reproduce every base/source/artifact identity above and copy the artifact only into
   Gatekeeper-owned `build/op291/` staging. Rehash after the copy.
2. Pin the disposable base-image path, byte size, SHA-256, kernel identity/configuration, and the
   exact staging/install commands. Do not modify the only copy of a prior evidence image.
3. Extend or replace the op-284 probe in Gatekeeper-owned paths. Record source/binary hashes and
   link/map expectations. The probe must compare types by equality with `XPC_TYPE_CONNECTION`, not
   merely print a non-NULL pointer.
4. Calibrate the detector against the historical known-bad op-284 record, without promoting its
   unknown artifact provenance:
   - serial: `build/op284/op284-serial.log`, SHA-256
     `44d442c79c3de783cb7eff09b2cf0e40198964efcbc27d19fef4ae07e0412b70`;
   - probe source: `build/op284/xpc_layout_probe.c`, SHA-256
     `1ac959271dbd5517ea93501353b553f6a0346d0a239235460f2e3aae038e2f77`; and
   - required negative observation: anonymous and named `xpc_get_type` both `0x0`.
5. Add a small fail-closed validator that consumes the real serial. Its host-only controls must
   reject at least: wrong guest artifact hash, missing/duplicate terminal marker, nonzero resource
   delta, missing finalizer count, type mismatch, and message-before-handler ordering.

Any preflight failure consumes zero cells and returns `PREFLIGHT-NOT-ACCEPTED`; do not boot.

## ONE AUTHORIZED GUEST CELL

The cell is consumed once `GK_OP291_RUNTIME_START` is printed. Preserve complete host and serial
streams. An observer or serial truncation, boot/image collision, artifact mismatch, or harness
failure is not a product verdict and does not release another cell.

### A. Artifact provenance — hard gate before behavior

In both host and guest serial, record:

- staged host artifact path/size/SHA;
- installed guest path, symlink resolution, size/SHA;
- `ldd` for the probe and aslmanager; and
- a runtime mapping (`procstat` or equivalent) proving both load the installed guest
  `/usr/lib/libxpc.so.5`, not a second copy.

The installed and mapped artifact must equal
`b896e5866a7adf092283f852c17dae05244182c539dbf20afce7c18a273d46ad`.
Any mismatch immediately returns `PROVENANCE-NOT-ACCEPTED`; all later observations are void.

### B. Object identity

On the provenance-established artifact:

- create one anonymous connection and one named/Mach-service connection;
- require `xpc_get_type(connection) == XPC_TYPE_CONNECTION` for both;
- record the first object-header bytes and confirm type/refcount are initialized; and
- arm a crash catcher before each call.

Both comparisons must pass. “Non-NULL” without exact equality is insufficient.

### C. Full lifecycle and owned-resource reclamation

For both connection forms, exercise:

`create → set context/finalizer → retain → resume → cancel → balanced releases → finalizer`

Require:

- no early free, UAF, crash, hang, or double finalizer;
- finalizer fires exactly once per final-released connection after cancellation drains;
- all callbacks/dispatch sources drain before terminal accounting; and
- a bounded repeated lifecycle drive with before/after Mach send-right, receive-right, fd, thread,
  and process-memory census. Perform one throwaway warm-up cycle and quiescence before taking the
  baseline so process-global dispatch worker creation is not mislabeled a connection leak. After
  the final drain/quiescence interval, owned Mach-right and fd deltas must be zero; thread count
  must return to the warmed baseline; memory samples must not show monotonic per-cycle growth.

If the required Mach-right census API/observer cannot be kept alive, return
`HARNESS-NOT-ACCEPTED`; do not substitute “no crash” for the commissioned leak bar.

### D. Real managed-service reachability and first-message order

Use a disposable donor-faithful launchd job with `MachServices/com.apple.aslmanager` to start the
actual current `/usr/sbin/aslmanager` managed-server branch. Do not change product source or choose
id-040's production mechanism.

Drive one real client request through the listener and prove, with raw ordered events rather than
source inference:

1. launchd reports the process managed;
2. the listener accepts a peer whose type equals `XPC_TYPE_CONNECTION`;
3. peer-handler installation completes; then
4. the first message is delivered to that peer handler and receives the bounded expected response
   or explicit protocol-level disposition.

`first_message_index` must be greater than `handler_installed_index`. Record whether the managed
consumer is reachable and functional; do not turn this into an ASL reclaim/scheduling verdict.

### E. Terminal safety

Require zero guest panic/KASSERT/WITNESS/DEADLKRES signals, a live observer through final
inventory, exact-one verdict/terminal/DONE markers, `DONE < buffers synced < power-off`, and a
clean shutdown. Missing or reordered terminal evidence is `HARNESS-NOT-ACCEPTED`.

## CLASSIFICATION

Return exactly one:

- `ACCEPTANCE-PASS <commit>` — provenance gate plus B–E all pass;
- `PRODUCT-FAIL <bounded failed assertion>` — only when provenance is exact and every required
  observer/terminal remains valid;
- `PROVENANCE-NOT-ACCEPTED <reason>`;
- `HARNESS-NOT-ACCEPTED <reason>`; or
- `PREFLIGHT-NOT-ACCEPTED <reason>`.

Do not collapse infrastructure, harness, provenance, and product outcomes. No result from an
unknown artifact may support green.

## DELIVERABLE / COMMIT

Write and commit by explicit Gatekeeper-owned paths under `build/op291/`:

- exact harness/probe source and executable;
- launchd plist/rc or staging inputs;
- fail-closed validator plus its negative-control output;
- complete raw host and serial logs;
- artifact/image/harness identity record;
- validator output and final evidence note; and
- exact command/rc records needed to reproduce the classification.

Do not commit the guest image, core dumps, caches, or unrelated files. Create one additive commit;
do not push. Report commit/parent, complete changed paths, full-repository status, cell count,
every artifact/hash, marker counts, resource deltas, event-order indices, validator result, and
terminal classification.

The return will be sized and independently gated before op-285 or id-021 can retire.

## BOUNDARIES

- Gatekeeper runtime/harness/evidence work only; no product or control-tree edits.
- No product build or substitute artifact. Any product defect is routed later to Implementer.
- No ASL reclaim/periodicity claim and no id-040 production-mode decision.
- No pack/unpack, array, reply-correlation, modern XPC session/listener, or wider parity work.
- No second guest cell, repair-forward, commit amendment, or push without new Coordinator authority.

## MARKERS

`GK_OP291_BASE_IDENTITY`

`GK_OP291_KNOWN_BAD_CONTROL`

`GK_OP291_RUNTIME_START`

`GK_OP291_ARTIFACT_PROVENANCE`

`GK_OP291_TYPE_IDENTITY`

`GK_OP291_LIFECYCLE`

`GK_OP291_RESOURCE_CENSUS`

`GK_OP291_MANAGED_REACHABILITY`

`GK_OP291_FIRST_MESSAGE_ORDER`

`GK_OP291_PANIC_CHECK`

`GK_OP291_VERDICT`

`GK_OP291_TERMINAL`

## RELATIONS

op-285 (published fix under acceptance) / op-284 (known-bad premise and incomplete prior bar) /
op-292 and op-295 (current-tip artifact lineage) / id-021 / li-1005 / li-007 / id-040 (managed
aslmanager relation only; production-mode decision excluded).

feedback: `artifact_identity_needs_content_check`, `code_reasoned_verdict_is_hypothesis`,
`soak_is_gatekeeper`, `agent_host_isolation`, `no_conflate_gating_with_readiness`,
`op_state_dispatch_boundary`, `background_exit_code_hygiene`.
