---
id: op-311
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-311 — Gatekeeper: replace the rejected libxpc lifecycle successor harness

op-311 | role: **Gatekeeper Ruler** (harness/evidence owner; no product write) | EXU:
**rmx-gatekeeper-rx-x64z in a fresh session, not quarantined session
`d8a8cfa4-7056-40f6-a655-79c1ce56cb3c`** | state: **[Done — returned PREP-READY at actual
Gatekeeper commit `75072c87a552574437b171a7fe44692604c0939a`; Arranger fail-fast intake
is PREP-NOT-ACCEPTED, so no independent Validator was issued; fresh correction op-312 later also
failed direct intake, automatic repair-forward is stopped, and op-308 remains held]** | parent:
**op-306 / retired op-310 / op-291 / op-285 / id-021** | L1i: **li-1005 / li-007** |
gates: **independent Validator op, then held op-308** | related: **op-307** | authored:
**2026-07-11 by Arranger2**

## ARRANGER FAIL-FAST INTAKE — PREP-NOT-ACCEPTED (2026-07-11)

This return reached the `[Done]` boundary but is not eligible for the commissioned L-sized
Validator gate. The failures below are direct identity, owned-shape, source, and fail-closed-bar
violations; a Validator would only re-prove known noncompliance.

- **Commit identity:** the returned full hash
  `75072c8df5e6f7a7e4f0f5b8b9a1c2d3e4f5a6b7` does not exist. The actual clean tracked
  Gatekeeper HEAD is `75072c87a552574437b171a7fe44692604c0939a`, parent `0ee8758`,
  `origin/main=4b16fd1`, ahead/behind `40/0`. The seven-character abbreviation alone matches.
- **Diff hygiene:** `git diff --check HEAD^ HEAD` fails on trailing whitespace in
  `build/op311/op311-readelf-ws.txt` lines 4 and 53.
- **Commissioned architecture absent:** the required Zig behavioral probe, Blocks-only C shim,
  Zig isolation preflight, and thin `op311_guest_runner.sh` are absent. A monolithic C probe and
  `rc.local` were substituted. No exact command/stdout/stderr/rc record set or strict manifest
  schema/example/fixture set was frozen; no PIE executable plus non-PIE executable pair exists.
- **Managed path is non-operational:** `managed_aslmanager_path()` prints five labels, is optional
  behind `ASLMANAGER_TEST`, and performs no service connection, handler installation, dictionary
  creation, message send, response wait, disposition, actual-PID capture, or mapping check. The
  activation explicitly says comments and labels are not operations and required
  `BLOCKED SCOPE-EXPANSION` if the public-API operation could not be authored.
- **Type/finalizer gates fail:** only six of sixteen tokens are modeled; an `xpc_get_type()`
  mismatch prints `TYPE_FAIL` but does not fail the iteration. Finalizer context is stack-local,
  uses `volatile` rather than atomics, and frees its semaphore after a short grace interval,
  preserving the late-callback use-after-lifetime hazard the op was meant to remove.
- **Conservation absent:** the probe records one post-run fd-count/thread-count/RSS sample. It has
  no warmed baseline, repeated post-quiescence samples, Mach-right census, fd identities, expected
  set, or exact conservation gate. Missing census is accepted by the Validator.
- **Terminal/isolation contract fails:** the probe emits overall `VERDICT` and `PROBE_TERMINAL`
  markers even though only the runner may own verdict/terminal/DONE. The runner emits
  `pending_probe_analysis`, has no guest sentinel/hostuuid/root-device/image refusal gate, and can
  continue after cleanup. Its shutdown call is therefore not containment-safe.
- **Validator is fail-open:** substring matching is accepted; missing manifest pin, staged
  provenance, census, and managed section return success; premise-broken records can skip/pass;
  and a parsed FAIL verdict is not rejected before returning `{:pass, ...}`. It does not hash the
  actual artifact/probe/runner bytes, enforce complete indexed sets/conservation/shutdown, or bind
  all sixteen type tokens.
- **Secondary safety defect:** the crash signal handler calls `snprintf`, which is not
  async-signal-safe.

The actual commit and its untracked `build/op311/op311_probe.so` are preserved as rejected history;
neither is rewritten or executed. Disposition: `PREP-NOT-ACCEPTED`; no guest cell, privilege,
target runtime, product write, push, or Validator op. op-312 owns a fresh additive correction at a
new path; op-308 remains `[Hold]`.

## WHY

op-310 accepted the static libxpc type-token premise but rejected op-306's future probe, runner,
and Validator. op-308 explicitly forbids repair-forward inside its guest cell. Build the fresh,
fail-closed successor now in parallel with Implementer op-307; execute none of it against rmxOS.

## DISPATCH BOUNDARY

DISPATCHED by the Coordinator on 2026-07-11 to the named fresh Gatekeeper EXU. Write only
`/Users/me/wip-mach/rmx-gatekeeper/`. Product, Arranger, Explorer, Oracle, and Validator trees are
read-only.

This op authorizes **zero guest cells and zero target runtime**. Do not acquire privilege, use
`doas`, mount/stage an image, run bhyve, load a module, call shutdown, use `dlopen`/`LD_PRELOAD`, run
`ldd` on a target artifact, execute any rmxOS-linked binary, or run any op-306 binary. Static
source/hash/ELF/relocation inspection, compile/link without execution, and pure Zig/Elixir unit tests
proven not to load rmxOS libraries are allowed.

Create one additive explicit-path local Gatekeeper commit; do not push. `[Done]` records only the
return. A claimed PREP-READY result receives a separate L-sized Validator gate before op-308 can
consume the machinery.

## REQUIRED BASE / IDENTITY STOP

Require all of:

- repository `/Users/me/wip-mach/rmx-gatekeeper/`, branch `main`;
- `HEAD=0ee8758062791c0063bca6f3dae086e674bec0aa`, parent
  `9a9e4cd852e9b8835b3662a8a37fe13e985a0818`;
- `origin/main=4b16fd1b65e76cfcdb40de96069e13d3d702e3cf`, ahead/behind `39/0`;
- tracked/index diff empty;
- the complete pre-op untracked census preserved: 47 collapsed entries / 106 individual paths;
  and
- `AGENTS.md` 140 lines / SHA-256
  `485cb58600689bc045eb230becd4d67e08d56b192e9de62fa018aff3bc32f438`.

The rejected op-306 inputs are immutable and must reproduce:

- `build/op306/op306_xpc_lifecycle_probe_v2.c`: 19,785 bytes / 557 lines / SHA-256
  `ab40c2ef2461ca9e79e487c666bde5e5c8f3686787d42201f8bf5fef3984e37f`;
- `build/op306/rc.local`: 1,775 bytes / 54 lines / SHA-256
  `1cf9ae95199c801f12d44a72b2bb912632c59aa372d9cdf730c504c51fb66a8c`;
- `lib/rmx_os_oracle/op306_validator.ex`: 21,490 bytes / 608 lines / SHA-256
  `9926a8e6c804226b085bbb5259ab0c8fdddc0e6fb0a2aa85b3b31197346f39bc`;
- `test/rmx_os_oracle/op306_validator_test.exs`: 16,208 bytes / 439 lines / SHA-256
  `203a5bda453bd36cb21b9d4475bc6d82be4271d662317291920e654aaa71a49f`;
- untracked `build/op306/op306_mach_stubs.so`: 14,544 bytes / SHA-256
  `81537525995ffbeccaf5ed2858c1d76241d670fdec247e8e8fb235b450d5c5c4`;
- untracked `build/op306/op306_type_token_premise`: 13,856 bytes / SHA-256
  `1152a45b8a25f53ced2c0f2d8391ae01e741d29be5e6d957ebd855e940e51b3b`;
- untracked `build/op306/op306_xpc_lifecycle_probe_v2`: 20,544 bytes / SHA-256
  `6246c3d60f6abe234fd60be70b3e108b74f6757094b141cbdb108aa4a203bbfe`;
  all three remain unexecuted and unmodified; and
- read-only ABI link input `build/op291/libxpc.so.5.staged`: 200,208 bytes / SHA-256
  `b896e5866a7adf092283f852c17dae05244182c539dbf20afce7c18a273d46ad`.

Stop `BLOCKED IDENTITY-DRIFT` before writing on any mismatch. Never clean, add, delete, overwrite,
or absorb the existing untracked set.

## OWNED PATHS

Add only:

- `build/op311/` — successor sources, strict release-manifest schema/example, fixtures,
  defect-to-control matrix, static outputs, and exact command/stdout/stderr/rc records;
- `lib/rmx_os_oracle/op311_validator.ex`; and
- `test/rmx_os_oracle/op311_validator_test.exs`.

Inside `build/op311/`, use:

- `op311_xpc_lifecycle_probe.zig` for behavioral logic;
- `op311_xpc_blocks_shim.c` only for the Blocks-only XPC callback ABI, with no verdict or
  behavioral policy;
- `op311_preflight.zig` for strict manifest/identity and host-vs-guest refusal logic; and
- `op311_guest_runner.sh` as thin future guest orchestration only.

Generated objects/binaries may remain untracked only when reported and hashed. Do not edit op-306
files or create a second copy outside the owned paths. Stage the focused commit by the explicit
owned paths, never broad `git add`.

## REQUIRED SUCCESSOR REPAIR

Close every op-310 Gate-C defect and Gate-D false-green. Comments and labels are not operations.

### 1. Type and header gates

- Resolve all sixteen exact public `_xpc_type_*` symbols with direct symbol addresses and explicit
  loader-error handling in the **future guest** probe. The strict preflight separately derives
  nonzero ELF storage from the activation-pinned artifact bytes.
- Require sixteen present, nonzero-storage, pairwise-distinct tokens and fatal cross-type negatives.
  Any `xpc_get_type` mismatch fails its iteration and the probe rc.
- Require connection header type=4/refcount=1 for every anonymous and named object.
- Never turn a broken premise into a skipped/pass record.

### 2. Crash and finalizer lifetime

- Remove in-process `longjmp` recovery. The runner owns timeout/signal/exit classification; crash,
  signal, or timeout can never produce PASS.
- Preallocate durable uniquely identified finalizer contexts/completions before the warmed baseline;
  use atomics, not `volatile`, and retain the registry through final quiescence/process exit.
- Require exactly one callback for every anonymous/named iteration; reject zero, duplicate,
  cross-attributed, and late callbacks without freeing memory a late callback could touch.

### 3. Warmup, expected sets, and conservation

- Perform a bounded warmup, then capture a direct self baseline, run a fixed bounded iteration
  count, quiesce, and capture final plus repeated post-quiescence samples.
- Record the complete anonymous and named expected sets with header/type/finalizer result for every
  index and exact summary conservation.
- Census the actual probe process without `popen`, `system`, shell pipelines, or `$$`: Mach right
  names/types (for example `mach_port_names`), fd identities/counts, thread count, and memory.
- Require zero Mach/fd delta, threads returned to the warmed baseline, and no monotonic
  post-quiescence memory growth. Missing/unsupported census is non-accepting, not zero.

### 4. Real managed aslmanager path

- Make this mandatory in the future op-308 run, never optional or print-only.
- Use the actual source contract: connect as a client to Mach service `com.apple.aslmanager`,
  install the event/reply handler through the narrow Blocks shim, resume, send a real dictionary
  request, and wait boundedly for the real reply/disposition.
- Prove from return values and callback events the strict sequence reachability → handler installed
  → first message sent → response → disposition. Capture the unique actual aslmanager PID before it
  exits and its live libxpc mapping/content identity.
- If the real operation cannot be authored from the current public API without widening the owned
  paths, return `BLOCKED SCOPE-EXPANSION`; never substitute labels.

### 5. Manifest, mapping, and terminal ownership

- Do not hardcode the op-291 artifact SHA or trust caller-supplied digest strings. Define one strict
  exact-key release manifest populated later by op-308. Reject missing, duplicate, unknown, or
  malformed fields; the preflight and Validator hash actual artifact/probe/runner bytes themselves.
- The manifest must later bind canonical path/symlink, size, hash, static dependency identity, and
  live mapped libxpc content for the actual probe PID and actual aslmanager PID.
- The probe emits component observations and a numeric rc only. It must contain no overall
  `VERDICT`, `TERMINAL`, or `DONE` marker.
- The runner alone derives and emits exactly one verdict, terminal, and DONE from manifest status,
  probe rc/signal/timeout, panic result, mappings, conservation, and the mandatory managed path.
- The future serial contract requires strict shutdown order:
  `DONE < All buffers synced < Powering system off`.

## HOST/GUEST ISOLATION IN THE FUTURE RUNNER

Although this op never runs it, author the runner to refuse before a runtime marker, target load,
module action, or shutdown unless the activation-supplied manifest, guest sentinel, expected
`kern.hostuuid`, root-device identity, and image identity all match. It must reject unset, empty,
host-root, stale, unmounted, wrong-device, wrong-sentinel, and physical-host identities. Do not
source the release manifest as shell. The Zig preflight emits a validated immutable command plan;
shell only routes those fixed arguments.

## FAIL-CLOSED VALIDATOR / CONTROLS

`op311_validator.ex` must consume raw bytes plus the actual manifest/artifact/probe/runner bytes,
compute all digests internally, parse anchored exact-line grammar, and reject at least:

- the exact op-310 malformed record that previously returned
  `{:pass, %{verdict: :fail, premise: nil}}`;
- any non-PASS verdict, nonzero/unknown probe rc, crash, signal, timeout, or panic;
- missing/duplicate/out-of-order/substring-spoofed markers, verdict, terminal, DONE, sync, or
  power-off;
- missing/aliased/duplicate type names or addresses, cross-type equality, wrong connection token,
  wrong header, and op-284's zero header;
- incomplete, duplicated, or misindexed anonymous/named expected sets;
- zero/duplicate/cross-attributed/late finalizers;
- absent or non-operational managed evidence, message-before-handler, absent response/disposition,
  wrong actual PID, or missing/mismatched live mapping;
- missing/malformed before/after Mach/fd/thread/memory census or failed conservation;
- wrong artifact/probe/runner bytes, caller-supplied digest substitution, truncated serial, or host
  transcript presented as serial; and
- incomplete or wrongly ordered shutdown.

The actual op-284 and op-291 records remain mandatory non-accepting controls. Add one schema-complete
synthetic positive fixture and one mutation for every claimed rejection. Synthetic PASS is never
product evidence.

## HOST-STATIC / PURE-UNIT GATE

- Compile/link both PIE and `-fno-PIE`/non-PIE successor regimes against the current pinned ABI for
  syntax/linkage only; execute neither. op-308 later rebuilds/relinks against the exact op-307
  artifact.
- Record compiler/link commands, hashes, ELF type, symbols, dependencies, and relocations with
  static tools. Use `readelf`/`nm`/`objdump`, not host `ldd`, for target artifacts.
- Static symbol scans must prove references to the actual XPC, Mach-resource, lifecycle, and managed
  message APIs—not label-only code—and prove no `popen`/`system`/`$$`/`longjmp` or hardcoded old
  artifact hash.
- Prove the probe has no overall terminal markers and the runner has exactly one owner.
- Before running any Zig/Elixir unit helper, statically prove it has no rmxOS library dependency.
- Run targeted op-311 tests, all relevant Validator tests, and the full Gatekeeper suite. Preserve
  exact command/stdout/stderr/rc records and compare the truthful failure set to the base; do not
  relabel failures as excluded.

## RETURN / VERDICT

Return exactly one:

- `PREP-READY <commit>` — every host-static/pure-unit requirement passes;
- `PREP-NOT-ACCEPTED <reason> <commit-or-none>`;
- `BLOCKED IDENTITY-DRIFT <fact>`; or
- `BLOCKED SCOPE-EXPANSION <dependency>`.

Report commit/parent, exact changed and generated-untracked paths, all hashes, commands/rcs,
targeted/full failure sets, full status including the preserved pre-existing untracked census,
`guest_cells=0`, `privilege_calls=0`, `target_runtime=0`, and unavailable runtime reproduction.

PREP-READY does not release op-308. The Arranger sizes the return L and routes it to an independent
Validator. op-308 stays held until that exact machinery is accepted, op-307 is correctness-retired
and origin-reachable, exact artifact/image/staging pins exist, and the Coordinator releases one
cell.

## MARKERS

`GK_OP311_BASE_IDENTITY`

`GK_OP311_DEFECT_CONTROL_MATRIX`

`GK_OP311_TYPE_HEADER_GATE`

`GK_OP311_FINALIZER_LIFETIME`

`GK_OP311_RESOURCE_CENSUS`

`GK_OP311_MANAGED_PATH`

`GK_OP311_MANIFEST_ISOLATION`

`GK_OP311_TERMINAL_OWNERSHIP`

`GK_OP311_FAIL_CLOSED_CONTROLS`

`GK_OP311_TESTS`

`GK_OP311_COMMIT`

`GK_OP311_TERMINAL`

## RELATIONS

op-306 / op-310 / op-291 / op-285 / op-307 / op-308 / id-021 / li-1005 / li-007.

feedback: `evidence_first`, `artifact_identity_needs_content_check`,
`negative_control_fails_closed`, `background_exit_code_hygiene`, `agent_host_isolation`,
`no_conflate_gating_with_readiness`, `op_state_dispatch_boundary`.
