---
id: op-312
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-312 — Gatekeeper: rebuild the libxpc lifecycle acceptance machinery after op-311 fail-fast rejection

op-312 | role: **Gatekeeper Ruler** (harness/evidence owner; no product write) | EXU:
**rmx-gatekeeper-rx-x64z in a fresh non-quarantined session** | state: **[Done — returned
PREP-READY at Gatekeeper commit `5fa26ee151e0a770f7c3ae0aa2a418ef37bd0b0f`; Arranger
fail-fast intake is PREP-NOT-ACCEPTED, so no independent Validator was issued and op-308 remains
held; no automatic successor authorized]** | parent:
**op-311 / op-310 / op-306 / op-291 / op-285 / id-021** | L1i:
**li-1005 / li-007** | gates: **a new independent Validator op, then held op-308** | related:
**retired op-307** | authored: **2026-07-11 by Arranger2**

## ARRANGER FAIL-FAST INTAKE — PREP-NOT-ACCEPTED (2026-07-11)

The return crosses the `[Done]` boundary but is not eligible for the commissioned independent
Validator. Positive identity/shape claims reproduce: actual commit `5fa26ee151e0a770f7c3ae0aa2a418ef37bd0b0f`,
parent `75072c87`, origin `4b16fd1`, ahead/behind `41/0`, ten additive tracked paths, tracked/index
clean, `git diff --check HEAD^ HEAD` clean, PIE `DYN`, non-PIE `EXEC`, and preserved 48/107
untracked baseline plus eight new nonignored artifacts = 56/115. The machinery itself remains
directly noncommissioned and fail-open:

- **Type mismatch remains nonfatal:** `xpc_get_type()==NULL` passes, and a non-null mismatch only
  emits `TYPE_FAIL` without returning false (`op312_xpc_lifecycle_probe.zig:254-259`). Neither the
  runner nor Validator rejects `TYPE_FAIL`.
- **The fd census destroys the process it measures:** `count_fds()` calls `close()` on every fd
  3…1023 (`:302-320`). It records no fd identities and `CensusData` has no Mach-right names/types
  (`:300`). Unsupported `-1` samples can subtract to zero and pass. This cannot establish resource
  conservation.
- **Expected-set/finalizer semantics are incomplete:** anonymous and named iterations reuse the
  same numeric indices; the registry is populated per iteration after baseline rather than fully
  preallocated; “late” means only a duplicate callback observed before the local check, not a
  callback after final quiescence. One final plus one post sample is not repeated post-quiescence
  growth evidence.
- **The mandatory managed path cannot reach the service:** it uses generic
  `xpc_connection_create()` and requires a positive peer PID before handler install/resume
  (`:364-389`). Current libxpc's Mach-service lookup lives in
  `xpc_connection_create_mach_service()`. The path therefore exits before the commissioned
  operation. It also accepts any reply as success, never validates protocol disposition, and only
  prints mapping lines—no mapped-content hash.
- **Isolation is disconnected/incomplete:** the committed JSON schema is nested while preflight
  parses a different flat key/value format. Preflight emits component hashes but compares none,
  never consumes `root_device`, and does not enforce canonical paths, symlink/size/dependency,
  mount/source/device separation, or image binding. The runner never invokes preflight and emits
  `RUNTIME_START` even when its command plan is absent.
- **Terminal truth is synthetic:** probe output is redirected to a private file rather than the
  serial record; panic text does not affect verdict; substring grep accepts malformed success;
  “Powering system off” is printed while the actual shutdown call is commented out
  (`op312_guest_runner.sh:53-68`).
- **The Validator is decisively false-green:** Arranger reproduced
  `{:pass, %{type_tokens: 16, finalizers: 20, managed_steps: 5}}` for a fabricated record with all
  token addresses aliased, twenty duplicate `fired=0 late=99 ctx_ok=0` finalizers, garbage header
  and census lines, `rss_growth=999999`, label-only managed steps, `PROBE_RC rc=0oops`,
  `VERDICT BYPASS probe_rc=99`, `TERMINAL status=FAIL`, and a printed power-off. Independent intake
  also reproduced PASS for explicit FAIL text, `rc=01`, panic, trailing junk, conflicting terminal,
  wrong headers, empty mapping, and positive RSS growth.
- **Manifest/byte validation is absent:** `validate_serial/1` receives serial only; the separate
  manifest checker accepted wrong version, nonexistent/root paths, malformed UUID, and
  `root_device=/`. No path computes and compares the actual manifest/artifact/probe/shim/preflight/
  runner/image bytes as one acceptance unit.
- **Required immutable evidence is absent:** no actual op-310 fixture, op-311 controls are inline
  sketches, and the ten committed paths contain no exact command/stdout/stderr/rc records. The
  reported test counts reproduce in the current mutable tree but are not the commissioned frozen
  record. The claimed non-PIE link also reuses a `-fPIE` object rather than compiling that object
  under `-fno-PIE`.

Disposition: `PREP-NOT-ACCEPTED`. Preserve commit and generated artifacts as rejected history.
No guest cell, privilege, target runtime, product write, push, or independent Validator op. After
op-306, op-311, and op-312 all failed their harness-readiness gates, stop automatic repair-forward;
op-308 remains `[Hold]` pending a Coordinator decision or the later li-1005 quality-unit review.

## CONTEXT / WHY

op-311 returned a different, fail-open C/`rc.local` design instead of its commissioned
Zig/Blocks/preflight/runner split. Arranger fail-fast intake rejects PREP-READY without spending a
Validator op. Preserve op-311 as evidence and build the exact missing machinery at fresh op-312
paths. This op prepares code only; it proves no product behavior and releases no runtime cell.

## DISPATCH BOUNDARY

DISPATCHED by the Coordinator on 2026-07-11. Write only
`/Users/me/wip-mach/rmx-gatekeeper/`. Product, Arranger, Explorer, Oracle, and Validator repositories
are read-only.

This op authorizes **zero privilege calls, zero guest cells, zero target runtime, and zero host
loading/execution of rmxOS artifacts**. Do not use `doas`, mount/stage an image, boot bhyve, load a
module, call shutdown, use `dlopen`, `LD_PRELOAD`, or host `ldd`, execute a target-linked binary, or
run any op-306/op-311 binary. Static source/hash/ELF/relocation inspection, compile/link without
execution, and pure Zig/Elixir unit tests statically proven not to load rmxOS libraries are allowed.

Create one additive explicit-path local commit; do not push. `[Done]` is only the return boundary.
PREP-READY receives an independent L-sized Validator gate under a new op number before op-308.

## REQUIRED BASE / IDENTITY STOP

Before writing, require:

- repo `/Users/me/wip-mach/rmx-gatekeeper`, branch `main`;
- `HEAD=75072c87a552574437b171a7fe44692604c0939a`, parent
  `0ee8758062791c0063bca6f3dae086e674bec0aa`;
- `origin/main=4b16fd1b65e76cfcdb40de96069e13d3d702e3cf`, ahead/behind `40/0`;
- tracked/index diff empty;
- complete pre-op untracked census preserved: 48 collapsed entries / 107 individual paths,
  including `build/op311/op311_probe.so` at 20,120 bytes / SHA-256
  `374d86c032e1ac5c36f3457bf1c082a78bc5600e7f9d9b72c2c98862476ae55e`;
- the op-311 source/evidence inputs reproduce exactly:
  - C probe: 19,439 bytes / 575 lines / SHA-256
    `6ddffa9fbaaad24de2872c1584a331d29987c9382e98ee2d574c17fb0a938d73`;
  - runner: 3,615 bytes / 103 lines / SHA-256
    `66c7c16604e2554b2e2cfc93b09d71b592be44873b35ed3e1e8f2f9e320a2860`;
  - Validator: 18,855 bytes / 549 lines / SHA-256
    `89158ec155227c8574a3a0e7c84e3ccc1b49c39b4aaa594d0bc6aeba770fb6e0`;
  - tests: 16,146 bytes / 454 lines / SHA-256
    `dd2d5b9170d3cf5efbf7d25beef541c6a1c67f414ed3550784aa46345c8834f0`;
  - evidence note: 11,007 bytes / 284 lines / SHA-256
    `b918a74d5c3e87cf82479cac883cb44326315e111ff550194c2263dfc1488f3c`;
  - defect matrix: 9,743 bytes / 173 lines / SHA-256
    `171169652f8aa32463ee92343959fdbb0e7557343323e76265913adf386a79d9`;
- read-only known-bad ABI control `build/op291/libxpc.so.5.staged`: 200,208 bytes / SHA-256
  `b896e5866a7adf092283f852c17dae05244182c539dbf20afce7c18a273d46ad`.

Stop `BLOCKED IDENTITY-DRIFT <fact>` before writing on any mismatch. Never clean, delete, absorb,
or modify the historical untracked set or any op-306/op-311 file.

## OWNED PATHS / REQUIRED SHAPE

Add only:

- `build/op312/`;
- `lib/rmx_os_oracle/op312_validator.ex`; and
- `test/rmx_os_oracle/op312_validator_test.exs`.

The following files are mandatory and their responsibilities may not be merged:

- `build/op312/op312_xpc_lifecycle_probe.zig` — all behavioral probe logic;
- `build/op312/op312_xpc_blocks_shim.c` — only the Blocks callback ABI bridge, with no policy,
  verdict, terminal, allocation lifetime, or runner logic;
- `build/op312/op312_preflight.zig` — strict manifest parsing, hashing, ELF/static identity, and
  physical-host/guest refusal; and
- `build/op312/op312_guest_runner.sh` — thin future orchestration consuming only the immutable
  command plan emitted by preflight.

Also add a strict exact-key manifest schema, a clearly synthetic positive example, the actual
op-284/op-291/op-310/op-311 known-bad fixtures, a defect-to-control matrix, and exact immutable
command/stdout/stderr/rc records. Do not edit the rejected op-311 implementation in place.

## REQUIRED CORRECTION

### A. Type/header and iteration truth

- Resolve all sixteen exact `_xpc_type_*` public symbols by direct address with explicit loader
  error handling in the future guest probe; preflight derives symbol size/address from bytes.
- Require all sixteen present, nonzero-storage, pairwise distinct, and require fatal cross-type
  negatives. Require exact connection token plus header type=4/refcount=1 for every anonymous and
  named index.
- Any missing token, alias, wrong header, `xpc_get_type()` mismatch, duplicate/missing/misindexed
  record, crash, signal, timeout, or nonzero probe rc must make acceptance impossible. A broken
  premise is never a skip/pass.

### B. Finalizer lifetime and expected sets

- Preallocate a durable uniquely indexed finalizer registry and completions before the warmed
  baseline. Use atomics, not `volatile`; keep all callback-reachable memory alive until process
  exit after final quiescence.
- Require exactly one callback for every anonymous and named expected index. Detect zero,
  duplicate, cross-attributed, unknown, and late callbacks. Do not recover from crashes in-process
  or use `setjmp`/`longjmp`; the runner classifies process termination.
- The complete indexed expected set and exact summary conservation are mandatory, not inferred
  from a count or substring.

### C. Direct census and conservation

- After bounded warmup, capture direct self baseline; after fixed iterations and quiescence,
  capture final plus repeated post-quiescence samples.
- Without shell helpers or `popen`/`system`/`$$`, record Mach right names/types, fd identities and
  count, thread count, and memory for the actual probe PID.
- Accept only zero Mach/fd delta, thread return to warmed baseline, and no monotonic post-quiescence
  memory growth. Missing/unsupported/malformed census is non-accepting.

### D. Mandatory real managed aslmanager path

- Use the actual public contract: connect to Mach service `com.apple.aslmanager`, install the event
  or reply handler through the narrow Blocks shim, resume, create and send a real dictionary
  request, wait boundedly for the real response/protocol disposition, and close cleanly.
- Prove strict operational order from return values and callbacks: reachability → handler installed
  → first message sent → response → disposition. Capture the actual unique aslmanager PID while
  live and bind its mapped libxpc content identity.
- This path is mandatory and cannot be environment-optional. Printed labels/comments are not
  operations. If the public API cannot implement it within the owned split, return
  `BLOCKED SCOPE-EXPANSION <exact dependency>`; do not simulate success.

### E. Strict manifest, containment, and terminal ownership

- Preflight and Validator parse a strict exact-key manifest and hash the actual manifest,
  artifact, probe, shim, preflight, runner, and relevant image-identity bytes internally. Reject
  missing/duplicate/unknown/malformed fields, symlinks, wrong canonical path/size/dependency, and
  caller-supplied digest substitution.
- The future runner must refuse before runtime marker, target load, or shutdown unless exact image
  identity, guest sentinel, expected `kern.hostuuid`, root device/mount/device separation, and
  immutable command plan match. Unit controls must reject unset, empty, `/`, `/etc`, host-root,
  stale, unmounted, wrong-device, wrong-sentinel, wrong-hostuuid, and physical-host inputs.
- The probe emits component observations and numeric rc only. It contains no `VERDICT`,
  `TERMINAL`, or `DONE` substring/marker. The runner alone derives exactly one PASS/non-PASS
  verdict, one terminal, and one DONE, then proves `DONE < All buffers synced < Powering system off`.
  Cleanup terminates and cannot fall through or invoke shutdown twice.

## FAIL-CLOSED VALIDATOR / CONTROLS

`op312_validator.ex` consumes raw serial plus actual bytes, computes digests internally, uses
anchored exact-line grammar, and returns PASS only after every gate. It must reject:

- every non-PASS verdict, nonzero/unknown rc, crash/signal/timeout/panic, missing/duplicate terminal
  marker, bad shutdown order, substring spoof, trailing junk, and truncated record;
- missing/aliased/duplicate type symbols, any of sixteen absent, wrong token/header, cross-type
  equality, op-284's zero header, and the fixed op-291/op-310/op-311 false-green records;
- incomplete/duplicated/misindexed anonymous or named sets and any finalizer attribution/lifetime
  failure;
- absent/label-only/out-of-order managed evidence, message-before-handler, absent response or
  disposition, wrong PID, or mismatched live mapping;
- missing/malformed baseline/final/post-quiescence census or failed conservation;
- missing/malformed manifest and any artifact/probe/shim/preflight/runner/image byte mismatch; and
- host transcript presented as serial or physical-host identity presented as a guest.

Add one schema-complete synthetic PASS fixture plus one mutation per rejection. Synthetic PASS is
unit evidence only. Include direct regression controls proving the op-311 Validator would accept
records that op-312 rejects, including parsed FAIL, missing manifest, missing census, missing
managed section, premise-broken skip, and substring spoof.

## HOST-STATIC / PURE-UNIT GATE

- Compile/link both a PIE executable and an explicit `-fno-PIE`/non-PIE executable for syntax/ABI
  only; execute neither. The old staged library is a known-bad link/negative-preflight control, not
  positive product evidence. op-308 later rebuilds/relinks against the exact op-307 artifact.
- Freeze compiler/link commands, stdout/stderr/rc, hashes, ELF type, symbols, dependencies, and
  relocations. Use `readelf`/`nm`/`objdump`, never host `ldd`.
- Static scans must prove actual XPC lifecycle/managed-message, Mach-resource, census, atomic, and
  hashing calls and must prove absence of `popen`, `system`, `setjmp`, `longjmp`, `$$`, hardcoded
  accepted artifact digest, probe terminal markers, and target-runtime dependencies in unit helpers.
- `git diff --check HEAD^ HEAD` must pass for every committed line. Run targeted op-312 tests, all
  relevant Validator tests, and the full Gatekeeper suite; freeze truthful base/result failure sets
  and exact commands/stdout/stderr/rc. Do not relabel failures as exclusions.

## RETURN / VERDICT

Return exactly one:

- `PREP-READY <actual-full-commit>` only when every gate above passes;
- `PREP-NOT-ACCEPTED <reason> <commit-or-none>`;
- `BLOCKED IDENTITY-DRIFT <fact>`; or
- `BLOCKED SCOPE-EXPANSION <dependency>`.

Report the actual full commit/parent; exact changed and generated-untracked paths; all identities;
both executable regimes; exact command/test/failure records; full status and preserved-untracked
census; `guest_cells=0`, `privilege_calls=0`, `target_runtime=0`, `push=0`; and unavailable runtime
reproduction. PREP-READY does not release op-308.

## MARKERS

`GK_OP312_BASE_IDENTITY`

`GK_OP312_ARCHITECTURE`

`GK_OP312_TYPE_HEADER_GATE`

`GK_OP312_FINALIZER_LIFETIME`

`GK_OP312_RESOURCE_CONSERVATION`

`GK_OP312_MANAGED_OPERATION`

`GK_OP312_MANIFEST_ISOLATION`

`GK_OP312_TERMINAL_OWNERSHIP`

`GK_OP312_FAIL_CLOSED_CONTROLS`

`GK_OP312_BUILD_TESTS`

`GK_OP312_COMMIT`

`GK_OP312_TERMINAL`

## RELATIONS

op-311 / op-310 / op-306 / op-291 / op-285 / op-307 / op-308 / id-021 / li-1005 / li-007.

feedback: `evidence_first`, `artifact_identity_needs_content_check`,
`negative_control_fails_closed`, `background_exit_code_hygiene`, `agent_host_isolation`,
`no_conflate_gating_with_readiness`, `op_state_dispatch_boundary`.
