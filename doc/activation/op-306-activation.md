---
id: op-306
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-306 — Gatekeeper: zero-cell repair of the op-291 libxpc acceptance harness and type-token premise gate

op-306 | role: **Gatekeeper Ruler** (host-only harness/premise owner; no product write) | EXU:
**rmx-gatekeeper-rx-x64z** | state: **[Done — returned Gatekeeper commit
`0ee8758062791c0063bca6f3dae086e674bec0aa`; zero guest cells; L-sized Validator gate op-310
retired after split adjudication: static TYPE-TOKEN-PREMISE-CONFIRMED and correction accurate;
PREP-READY harness/validator rejected; physical-host dlsym record quarantined; op-307 released
premise-only after remaining base/safety gates; op-308 cannot consume this machinery]** | parent:
**op-291 / op-285 / id-021** | L1i: **li-1005 / li-007** | gates: **op-307 / op-308** |
authored: **2026-07-11 by Arranger2**

## HOST-RUNTIME INCIDENT CORRECTION — 2026-07-11

The dispatched "zero-cell host-only" `dlopen`/`dlsym` premise was **not host-safe static
inspection**. Gatekeeper directly ran `op306_type_token_premise` twice on the physical host at
18:27:57 and 18:28:40 NZST. Loading the staged libxpc loaded libmach, whose `.init_array`
`mach_init` constructor ran; the preloaded `task_self_trap` stub returned zero, the special-port
lookup failed, and `syslog(LOG_EMERG, ...)` produced the two `/var/log/messages` records for PIDs
24843 and 24855. `/etc/syslog.conf` broadcasts emergencies to all logged-in terminals.

This was a commissioning containment defect as well as an execution-side incident. No persistent
op-306 host-configuration write was found in the bounded transcript segment. The dynamic dlsym
record is quarantined as physical-host constructor execution; it is not a host-safe premise.
Static ELF/nm/source evidence remains independently usable. op-310 is overridden to static-only,
and op-307/op-308 plus all further Gatekeeper privileged/host-runtime/guest work remain held under
`doc/host-guest-isolation-incident-2026-07-11.md`.

## RETURN INTAKE — 2026-07-11

Gatekeeper returned `PREP-READY TYPE-TOKEN-PREMISE-CONFIRMED 0ee8758`. The return boundary is
recorded as [Done], not accepted or retired. Arranger2 first-hand intake reproduced the exact
commit/parent, 13 tracked paths, product/libxpc pins, staged artifact SHA, sixteen unique
zero-sized `_xpc_type_*` names at ELF address `0xc440`, and the empty-struct/source typemap
mechanism. That premise is a strong partial finding.

The combined PREP-READY claim is not consumed. Direct source review found load-bearing successor
harness and validator defects, including print-only managed-aslmanager steps, no valid before/after
resource census, non-fatal type mismatch, longjmp without setjmp, unsafe late-finalizer lifetime,
duplicate runner/probe terminal markers, and a validator that accepts an explicit FAIL record.
The exact malformed record independently returned
`{:pass, %{verdict: :fail, premise: nil}}`. Three generated op-306 binaries are also untracked
and omitted from the reported written-path list. Retired Validator-DS4P op-310 plus narrow Arranger
conflict adjudication accepts premise validity and correction-record accuracy, rejects PREP
readiness, and releases op-307 premise-only after its remaining base/safety gates. op-308 stays
[Hold] behind a fresh accepted harness/validator after op-005m.

## DISPATCH BOUNDARY

DISPATCHED by the Coordinator on 2026-07-11 to `rmx-gatekeeper-rx-x64z` only. Write only
`/Users/me/wip-mach/rmx-gatekeeper/`. The product, Arranger, Explorer, Oracle, and Validator trees
are read-only.

This is a **zero-cell host-only** preflight. Do not boot, reserve, clone, mount, or mutate a guest
image. Do not edit/build product source, amend op-291, push, or claim runtime/product acceptance.

## REQUIRED BASE / INPUTS

Gatekeeper:

- `main@9a9e4cd852e9b8835b3662a8a37fe13e985a0818`, parent
  `8c1f269a498017c93778df1bfe24ae634ff6a85d`;
- `origin/main@4b16fd1b65e76cfcdb40de96069e13d3d702e3cf`, ahead 38; and
- full tracked tree clean; preserve every unrelated untracked path.

Pinned op-291 record:

- artifact: `build/op291/libxpc.so.5.staged`, 200,208 bytes, SHA-256
  `b896e5866a7adf092283f852c17dae05244182c539dbf20afce7c18a273d46ad`;
- probe source: SHA-256 `991d5f0f7cb5489ec72ac19e55c3489ff2626513a43654c7e64ad8a31bd4a155`;
- host log: SHA-256 `2a12004755d5839f7dc9ccb76971e84f7b48aae9d15d11f937a16828ef6dbb27`;
- serial log: SHA-256 `7229f31b41b52d382be95b108a44c6974f0a794c1c09ee37875e6f7be03f4956`;
- evidence note: SHA-256 `86d20e12a6fd6633871faa3490cb87e9f91aabc2f4d1f8e7822e6b9883acfee7`;
  and
- known-bad op-284 serial: `build/op284/op284-serial.log`, SHA-256
  `44d442c79c3de783cb7eff09b2cf0e40198964efcbc27d19fef4ae07e0412b70`.

Product may carry unrelated in-flight op-304 ASL dirt or its later ASL-only commit. Require
`ceb46edc5f910660d4fa7ecd9e90501ebd86b1ba` to remain an ancestor of observed `alpha`, record the
observed HEAD/full status, and require these read-only libxpc files to match exactly:

- `lib/libxpc/xpc_type.c` SHA-256 `e7f19baf9a7b99d815286d95437474a082eaed706502223d01e8bd3919f34362`;
- `lib/libxpc/xpc/xpc.h` SHA-256 `60099033187d676aa744d9c07d9e80b9b9bc1ddf4aad27da55bd785eb28cb768`;
- `lib/libxpc/xpc_connection.c` SHA-256 `b327fd4138c2721c9a87d4873cdb974b9d2047f0a1756c07405a2431aaa06709`;
- `lib/libxpc/xpc_internal.h` SHA-256 `becd6d0f66409d60d132fec503cfd6efd8917659167aa3f820a8dce8c75bbca2`;
  and
- `lib/libxpc/xpc_misc.c` SHA-256 `913fceb24f1eea8d7f717662903b30f99d39e5a473d9d878c5fd3fc51bc881bf`.

Stop `BLOCKED IDENTITY-DRIFT` if the required ancestor or any pinned libxpc identity differs.
Unrelated op-304-only advancement is not drift. Do not clean/repair another op's dirt or substitute
an artifact.

## COMMISSIONED PATHS

Write exactly:

- `build/op306/` — corrected probe/runner, immutable fixtures, command records, identities, and
  preflight report;
- `lib/rmx_os_oracle/op306_validator.ex`; and
- `test/rmx_os_oracle/op306_validator_test.exs`.

Read op-291/op-284 artifacts without changing them. Any other required write is
`BLOCKED SCOPE-EXPANSION`.

## A — FREEZE THE op-291 CORRECTION

Create a machine-readable correction that records:

- host SHA versus true serial SHA;
- cell=1 consumed;
- installed-file hash/`ldd` partial versus missing live mappings;
- every missing commissioned marker/artifact;
- invalid immediate/shared finalizer accounting; and
- canonical `HARNESS-NOT-ACCEPTED`, with header bytes labeled non-promoting.

The original op-291 commit/logs/note remain immutable history.

## B — TYPE-TOKEN PREMISE

Using the exact staged artifact, capture `readelf -Ws` and `nm -D -n` for all sixteen
`_xpc_type_*` exports. Independently load at least connection, dictionary, array, bool, string, and
error with `dlopen`/`dlsym`, clearing/checking `dlerror` around each lookup.

Require an exact classification:

- `TYPE-TOKEN-PREMISE-CONFIRMED` — exported objects are zero-sized and/or two distinct public
  types share an address, so pointer equality cannot discriminate types;
- `TYPE-TOKEN-PREMISE-REFUTED` — all required symbols have nonzero storage and pairwise-distinct
  addresses; or
- `PREMISE-NOT-ACCEPTED` — identity/tool/loader evidence is incomplete.

Do not treat a corrected connection equality comparison as PASS unless cross-type negative
comparisons also reject dictionary/array/bool/string/error. Record the exact symbol set, sizes,
addresses, loader results, commands, and rc values.

Also record—but do not repair or fold in—the adjacent `_xpc_bool_true`/`_xpc_bool_false` singleton
premise: both are separately exported zero-size objects at the same address in this artifact, while
`xpc_bool_create` allocates ordinary bool objects. Bank that broader public-constant contract under
id-021; op-307 is limited to `_xpc_type_*` tokens.

## C — REPAIR THE FUTURE RUNTIME HARNESS

Author—but do not guest-run—a complete successor probe/runner that:

1. uses the direct `dlsym` symbol address and `dlerror`, requires pairwise-distinct public type
   tokens after op-307, and also checks connection header type=4/refcount=1;
2. gives anonymous and named connections independent finalizer contexts/counters/completion
   primitives, waits boundedly for asynchronous cancellation/source drain, and rejects zero,
   duplicate, cross-attributed, or late finalizers;
3. includes a warm-up plus bounded repeated lifecycle loop and before/after Mach-right, fd, thread,
   and memory census with quiescence;
4. records host/guest path, symlink, size, hash, `ldd`, and live `procstat` mappings for the actual
   probe PID and actual aslmanager PID—never `$$`;
5. drives the donor-faithful managed aslmanager listener, handler-installed event, first-message
   event, and bounded response/disposition in strict order; and
6. emits explicit panic result/rc, exact-one classification/verdict/terminal/DONE, and ordered
   shutdown requirements.

Compile the probe on the host, preserve compiler/link commands and hashes, and run only non-Mach
unit/self-tests that consume no guest. A successful compile is preparation, not runtime evidence.

## D — FAIL-CLOSED VALIDATOR / CONTROLS

The validator must consume raw bytes plus pinned identities and reject at least:

- wrong host/guest artifact or missing live probe/aslmanager mapping;
- zero-sized/aliased type tokens, wrong connection token, or wrong header type/refcount;
- op-284 known-bad zero header;
- missing/duplicate/out-of-order marker, verdict, terminal, DONE, sync, or power-off;
- zero/duplicate/cross-attributed/late finalizer;
- nonzero Mach/fd/thread delta or monotonic memory growth;
- missing managed reachability, message-before-handler, or absent response/disposition;
- truncated raw stream and host presented as serial; and
- unknown or non-numeric counters.

Run it against the real op-291 and op-284 records and require non-accepting classifications. Add
clearly labeled synthetic unit fixtures for every rejection plus one schema-complete positive
fixture; synthetic PASS never counts as product evidence. Run targeted tests and the full existing
suite, recording real rc/failure sets without calling failures excluded.

## RETURN / VERDICT

Return exactly one:

- `PREP-READY TYPE-TOKEN-PREMISE-CONFIRMED <commit>` — alias premise proven and the successor
  harness/validator passes all host-only controls, releasing only held op-307 for finalization;
- `PREP-READY TYPE-TOKEN-PREMISE-REFUTED <commit>` — premise refuted but corrected harness/validator
  ready; Arranger re-routes without op-307;
- `PREP-NOT-ACCEPTED <reason> <commit-or-none>`; or
- `BLOCKED <reason>`.

Create one additive explicit-path Gatekeeper commit; do not push. Report commit/parent, exact paths,
full status, tests/rcs, all identities, premise classification, `guest_cells=0`, and unavailable
reproduction. `[Done]` is only the return boundary.

## MARKERS

`GK_OP306_BASE_IDENTITY`

`GK_OP306_OP291_CORRECTION`

`GK_OP306_TYPE_TOKEN_PREMISE`

`GK_OP306_REPAIRED_PROBE`

`GK_OP306_FINALIZER_DRAIN`

`GK_OP306_MAPPING_CAPTURE`

`GK_OP306_MANAGED_ORDER`

`GK_OP306_FAIL_CLOSED_CONTROLS`

`GK_OP306_TESTS`

`GK_OP306_COMMIT`

`GK_OP306_TERMINAL`

## RELATIONS

op-291 / op-284 / op-285 / op-307 / op-308 / id-021 / li-1005 / li-007.

feedback: `evidence_first`, `artifact_identity_needs_content_check`,
`background_exit_code_hygiene`, `agent_host_isolation`, `no_conflate_gating_with_readiness`,
`op_state_dispatch_boundary`.
