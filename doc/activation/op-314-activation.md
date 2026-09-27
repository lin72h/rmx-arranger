# op-314 — Implementer: explicit preview one-shot aslmanager mode plus periodic launchd job

op-314 | role: **Implementer** | EXU: **wip-gpt / wip-rmxos Implementer** | state:
**[Retired — commit `26655e67872cd55cff0a272b32b7895f55368033` passed Arranger2's M-sized
ACCEPTED-LOCAL-CORRECTION gate plus S-sized publication/origin gate; clean and origin-reachable on
2026-07-12. Runtime/leg-4 acceptance remains separate and unissued.]** |
parent: **id-040 / id-011** | L1i: **li-1004 (ASL core service, leg 4)** | relations:
**op-257 / op-293 source-and-runtime premise; op-296…op-302 historical record chain is not a
dependency; later runtime acceptance gets a new Gatekeeper op after correctness + publication** |
authored: **2026-07-11 by Arranger2**

## ARRANGER RETIREMENT — 2026-07-12

Publication gate size: **S**. Arranger2 verified first-hand in the full product repository:

- branch `alpha`, local `HEAD`, local `origin/alpha`, and fresh
  `git ls-remote origin refs/heads/alpha` all equal
  `26655e67872cd55cff0a272b32b7895f55368033`;
- full worktree is clean, ahead/behind is 0/0, and both parent-to-result and result-to-origin
  ancestry checks pass;
- the published object still has sole parent `40c8a93d4b3fec707b2e6ecd7762a1b20948e6e3`,
  changes exactly the three commissioned paths `+58/-4`, and passes `git diff --check` plus
  `git show --check`; and
- publication added no source change, commit, force, build, guest, image, privilege, or host target
  execution.

**Verdict: RETIRED.** op-314 leaves the live ROB. id-042's “ASL production mode lands” item closes,
but id-011/id-040 and ASL leg 4 remain open until a separately numbered, contained Gatekeeper run
proves the origin artifact, explicit load path, repeated interval invocation, positive TTL and size
reclaim, resource bounds, survival, terminal ordering, and clean shutdown. Publication is not a
runtime-green claim.

## ARRANGER M-SIZED CORRECTNESS GATE — 2026-07-11

**Verdict: ACCEPTED-LOCAL-CORRECTION.** This return establishes the bounded product mechanism and
static/build contract only. It does not establish launchd activation, periodic invocation,
reclaim, or ASL leg-4 runtime acceptance.

Arranger2 verified first-hand:

- the live canonical Exe brief is exactly 14,264 bytes / 267 lines / SHA-256
  `8725fc67d10b217c47648ea53dc0ee38799780ed08a380ea864fcf0d0d6836f9`; it byte-matches the
  Implementer-cached activation, and its Ready predecessor is exactly 14,301 bytes / 267 lines /
  `5debad00cba66ffa81cf9f2424abbf4f4fb1ded732fe67199ce1f4f33d6b59b2`; their only semantic
  delta is the authorized dispatch-state field;
- product branch `alpha` is clean at `26655e67872cd55cff0a272b32b7895f55368033`, parent
  `40c8a93d4b3fec707b2e6ecd7762a1b20948e6e3`, tree
  `aa9d4f44716b0793ca4de6ae67c7d819cf7ab15d`, one ahead of local and live
  `origin/alpha@40c8a93d`; parent-to-result ancestry holds and result-to-origin reachability does not;
- the commit changes exactly the three commissioned paths, `+58/-4`, with committed blobs and
  SHA-256 values matching the return: `aslmanager.c` `9ff1fee4...` /
  `ef2be2e1...`, `aslmanager.8` `3782c03e...` / `405a9199...`, and the new 100644 plist
  `b82b5946...` / `e91db435...`; cached complete diff `843f6bd8...` byte-matches
  `git show --format= 26655e67`; `git diff --check` and `git show --check` pass;
- `aslmanager.c:1595-1602` scans only exact `-once`, without changing `argc` or `argv`, before
  managed routing. `cli_main:1468-1473` consumes each exact token in place. Unmanaged routing,
  managed exact-token routing, managed no-token server routing, repeats, near misses, and all four
  optional-value adjacency traps follow from those bodies. The XPC handler's `cli_main(0, NULL)`
  call and `com.apple.aslmanager` listener/resume/`dispatch_main()` body are unchanged;
- the new plist is regular mode 100644, parses non-networked as XML, and contains exactly four
  typed keys: label `com.rmxos.aslmanager.once`, four ordered arguments
  `/usr/sbin/aslmanager -once -s /var/log/asl`, `RunAtLoad=true`, and `StartInterval=900`. No
  forbidden key/argument or duplicate label/basename is present;
- the manual exposes `-once`, distinguishes the bounded rmxOS preview route from the preserved
  managed XPC server and macOS parity, renders successfully, and adds no normalized lint diagnostic;
- preserved evidence records base/result isolated builds at rc 0 with identical 23-warning / zero-
  error diagnostics and environments. Reproduced artifacts are FreeBSD 15 x86-64 PIE binaries,
  44,736 / 44,832 bytes with SHA-256 `301bfb1...` / `8647673...`, identical 17-entry NEEDED sets,
  and no RPATH/RUNPATH. Passive strings/disassembly also place the exact selector in the result,
  not the base. No Arranger build or target execution was performed.

Evidence qualification: the supplied Elixir checker is deliberately pre-commit-state-bound and
now rejects the clean committed tree because it expects the three dirty paths. Its stored rc-0
result, source-normalization logic, cached-diff equality, and every load-bearing source/plist/manual
assertion were independently inspected or reproduced. This limits replay ergonomics, not the
accepted local correction. Target behavior remains unavailable until the contained runtime gate.

Publication/origin reachability is the sole product-retirement blocker. op-314 remains `[Done]` in
the live ROB and does not retire or make leg 4 green.

## PUBLICATION RELEASE — CONSUMED 2026-07-12

This no-change publication continuation consumed no new ROB number. The Coordinator dispatched it
to the same Implementer on 2026-07-12; the Implementer returned `PUBLISHED 26655e67`, and the
Arranger retirement section above records the first-hand origin gate. The historical instructions
below remain the exact consumed scope and grant no further authority.

### EXU and exact preflight

- EXU/repository: **wip-gpt / `/Users/me/wip-mach/wip-gpt/wip-rmxos/` Implementer**.
- Require branch `alpha`, clean full worktree, `HEAD=26655e67872cd55cff0a272b32b7895f55368033`,
  sole parent `40c8a93d4b3fec707b2e6ecd7762a1b20948e6e3`, and
  `origin/alpha=40c8a93d4b3fec707b2e6ecd7762a1b20948e6e3`.
- Fresh `git ls-remote origin refs/heads/alpha` must equal the same parent. Verify parent-to-result
  ancestry, the exact three-path `+58/-4` commit, `git diff --check HEAD^ HEAD`, and
  `git show --check HEAD`.
- Stop `PUBLICATION-BLOCKED <drift>` on any mismatch. Do not pull, fetch-and-merge, rebase, amend,
  reset, force, rebuild, or edit.

### Authorized publication

Push only the accepted commit by exact object name:

```text
git push origin 26655e67872cd55cff0a272b32b7895f55368033:refs/heads/alpha
```

After the push, obtain fresh `ls-remote`, local `HEAD`, `origin/alpha`, full status, and ancestry
proof. All three tips must equal `26655e67872cd55cff0a272b32b7895f55368033`; ahead/behind must be
0/0 and the worktree clean. No force, new commit, source change, build, guest, image, privilege, or
host target execution is authorized.

Return exactly `PUBLISHED 26655e67872cd55cff0a272b32b7895f55368033` or
`PUBLICATION-BLOCKED <reason>`, with pre/post tips, push rc/output, fresh remote proof, final full
status, and markers:

```text
IMPL_OP314_PUBLICATION_PREFLIGHT
IMPL_OP314_PUBLICATION_PUSH
IMPL_OP314_PUBLICATION_REMOTE
IMPL_OP314_PUBLICATION_TERMINAL
```

## COORDINATOR RULING

Proceed independently of the stopped historical record-repair chain. Select id-040 option 2 for
1.0-preview: an explicit bounded one-shot mode that remains CLI even when launchd marks the process
managed, paired with a periodic plist. Preserve the zero-extra-argument managed XPC-server path.

This is a preview-scope cut, not a claim of macOS fidelity. The faithful MachServices/XPC trigger
path remains a cataloged later direction.

## PREPROCESSING / DISPATCH BOUNDARY

READY, not dispatched. The Coordinator alone dispatches.

Oracle2 may review this prompt and return proposal-only amendments. That preprocessing is not op
execution, does not change the Implementer binding or deliverable, and authorizes no product/control
write or decision. The Arranger verifies any amendment before the Coordinator relays the final
normal form.

## PREPROCESSING RETURN / BINDING AMENDMENT — 2026-07-11

Oracle2 returned the proposal-only artifact:

`/Users/me/wip-mach/rmx-oracle2/op-314-implementer-refinement-proposal.md`

Arranger2 read it completely and reproduced **21,110 bytes / 397 lines / SHA-256
`ce7fba402a34f5c3e929febbfbef3c70744ccb5ad1eb1bb5638f8d3d0879724e`**. The product branch,
tree, four pinned source blobs/hashes, this activation's pre-amendment identity, id-040, and id-011
identities all reproduced exactly. Source inspection also confirmed the load-bearing premises:
the two-pass optional-value parser, safe `cli_main(0, NULL)` path, managed routing before server
allocation, launchd active-job/pending-trigger behavior, stale manual statement, and
`NO_WERROR=yes` build regime.

**Disposition: ACCEPTED AS THE BINDING DISPATCH AMENDMENT.** On Coordinator dispatch, the
Implementer must consume this canonical activation and the exact content-addressed proposal
together. Sections 1–7 and 9 refine the current Implementer scope and evidence gates without
adding a product path. Section 8 is a constraint/seed for a separately authored and dispatched
future Gatekeeper op; it grants no runtime, guest, staging, or cell authority now.

Binding corrections and identity clarifications prevent false blockers:

- the final dispatch package is the pair of files, each hashed independently; this activation does
  not embed a circular self-hash requirement;
- the proposal identity is immutable. Record the Coordinator-relayed activation identity and the
  current canonical activation identity/state. The sole permitted activation drift is the
  canonical dispatch-state field changing `[Ready]`→`[Exe]`; its semantic diff must be shown.
  Any other activation-content drift, or any proposal drift, requires a fresh Coordinator relay;
- run `mandoc -Tlint` on both base and result, preserving both return codes and diagnostics. The
  result must add no diagnostic attributable to the authorized edit; pre-existing unrelated base
  diagnostics may remain. Result rendering and the new synopsis/semantics must still succeed; and
- capture the complete build environment, or use `env -i` with an explicit whitelist. A subjective
  claim that only “relevant” environment variables were captured is insufficient.

Everything in the proposal not expressly scoped to the later Gatekeeper stage is additive to and
overrides the corresponding portion of this brief. All unmodified requirements and exclusions in
this canonical activation remain binding. Oracle2 has no Implementer or dispatch authority, and
the preprocessing return itself changes no product state or ROB state.

## SUPPLEMENTAL ORACLE1 ADVISORY / ARRANGER CONSUMPTION — 2026-07-11

The Coordinator relayed a later read-only Oracle1 verification of the Oracle2 amendment. It is
advisory preprocessing, not an Implementer return, an Arranger adjudication, or op-314 execution;
Oracle1 supplied no repository deliverable for this pass. Its quoted 10,003-byte/206-line
activation identity is correctly the historical pre-amendment pin, not this live canonical brief.

Arranger2 reproduced the useful refinements first-hand. Removing or compacting `-once` can rebind
the adjacent values in `-s -once /tmp`, `-module -once name`, `-d -once 3`, and
`-size -once 500K`; this final brief therefore mandates in-place exact-token recognition and
forbids argv compaction. The reported `wip-claude` id-011 sibling is a deprecated divergent copy
and is not an input; only the canonical `rmx-arranger` path below may be read. The source-coordinate
corrections are also accepted: `main` spans through line 1606 and the stale manual sentence is at
lines 46–47.

Oracle1's separate `asl_store_dst->path` null observation is real but out of this op's scope. The
shipped preview plist supplies exact `-s /var/log/asl`; the observation does not expand this
three-path commission or authorize downstream work.

On dispatch, the Implementer may write only:

- `/Users/me/wip-mach/wip-gpt/wip-rmxos/usr.sbin/aslmanager/aslmanager.c`;
- `/Users/me/wip-mach/wip-gpt/wip-rmxos/usr.sbin/aslmanager/aslmanager.8`;
- new `/Users/me/wip-mach/wip-gpt/wip-rmxos/usr.sbin/aslmanager/com.rmxos.aslmanager.once.plist`;
- uncommitted build/evidence records under
  `/Users/me/wip-mach/wip-gpt/build/op314-aslmanager-once/`.

Any required fourth product path is `BLOCKED SCOPE-EXPANSION`. Do not edit the Arranger,
Gatekeeper, Explorer, Oracle, Validator, host configuration, or any other repository.

## PINNED BASE — REPRODUCE BEFORE EDIT

Repository `/Users/me/wip-mach/wip-gpt/wip-rmxos/`:

- branch `alpha`;
- `HEAD=origin/alpha=40c8a93d4b3fec707b2e6ecd7762a1b20948e6e3`;
- live `refs/heads/alpha=40c8a93d4b3fec707b2e6ecd7762a1b20948e6e3`;
- tree `1b34024c749b5b6f4befe1fb8838a1e197e400d7`;
- full worktree clean.

Pinned inputs:

- `aslmanager.c`: 38,211 bytes / 1,606 lines / SHA-256
  `8a7a1e3c09acf6b8aba1f816ecf9359df80d8eb31bce9eb8886aa3eb651b75b9` / blob
  `6d9fbd5a7c47584191195d2e37af85e32e88fd62`;
- `aslmanager.8`: 6,729 bytes / 205 lines / SHA-256
  `5a4bc6e3b909dec0e8de6ecec2e6bfbae683806a527c5b5ad30671d322ec1663` / blob
  `9d5e7cd839c586f649963bae1cae5f2df640261e`;
- `Makefile` is read-only: 1,589 bytes / 44 lines / SHA-256
  `36180e9e0f26242d41dc93ac3f4240ffe1afab0ec46476a1e64ecc1df899d784` / blob
  `f92cc008324c4543c1013ec9ee22aec40258b90a`.

Stop `BLOCKED BASE-DRIFT` on mismatch. Do not rebase, merge, reset, clean unrelated files, or
silently repin.

Read before editing:

- `/Users/me/wip-mach/rmx-arranger/idq/id-040-aslmanager-managed-server-periodic-reclaim-contract.md`;
- `/Users/me/wip-mach/rmx-arranger/idq/id-011-libasl-syslogd-conformance-bringup.md` — current
  leg-4 state only; do not read or pin the deprecated `wip-claude` sibling;
- `aslmanager.c:1410-1606` — `cli_main`, XPC request path, and `main`;
- `sbin/launchd/core.c:2891-2900,4242-4245,8401-8403` read-only — interval re-arm and managed-job
  premise.

## REQUIRED CHANGE 1 — EXACT `-once` MODE

Add an exact startup token named **`-once`**. Only this exact token overrides managed routing.
Implement the following truth table:

```text
is_managed=0, -once absent  -> existing CLI path
is_managed=0, -once present -> existing CLI path, once
is_managed=1, -once absent  -> existing com.apple.aslmanager XPC listener + dispatch_main
is_managed=1, -once present -> existing CLI work exactly once, return cli_main status
```

Requirements:

- Detect the exact argv element; no `argc > 1`, generic “has arguments,” environment, label, or
  implicit heuristic.
- Near misses such as `-onceX`, `--once`, and ordinary legacy options do not select one-shot mode.
- **Binding parser design:** do not remove, compact, reorder, or rewrite `argv`. Scan exact tokens
  in `main` only to select routing, and add an explicit exact `-once` no-op/consume branch to the
  ordinary `cli_main` option pass. Every occurrence is recognized in place; repeats are idempotent
  and still produce one maintenance pass. This preserves the legacy optional-value adjacency of
  every non-control argument and supersedes the earlier strip/consume alternative. Accidental
  unknown-option ignoring is not consumption proof.
- Preserve the existing root check, ASL/module configuration, TTL/size defaults, reclaim
  algorithms, and natural `cli_main` return.
- Preserve the XPC request handler's root-authorized `cli_main(0, NULL)` behavior.
- Preserve zero-extra-argument managed server behavior: create the existing
  `com.apple.aslmanager` listener, resume it, and enter `dispatch_main()`.
- Never add `exit()` after `dispatch_main`, make the server periodic, or rename/reuse the faithful
  service label.

## REQUIRED CHANGE 2 — PREVIEW PERIODIC PLIST

Add `usr.sbin/aslmanager/com.rmxos.aslmanager.once.plist` with this exact load-bearing contract:

- `Label = com.rmxos.aslmanager.once`;
- `ProgramArguments = [ /usr/sbin/aslmanager, -once, -s, /var/log/asl ]`;
- `RunAtLoad = true`;
- `StartInterval = 900` seconds;
- no `MachServices`, `KeepAlive`, `StartCalendarInterval`, debug output path, `-d`, `-dd`, `-size`,
  `-ttl`, or test-only threshold.

The distinct `com.rmxos` label records the preview divergence and avoids collision with the later
faithful `com.apple.aslmanager` MachServices job. Production retention limits continue to come from
the installed ASL configuration/defaults; do not ship the soak's `500K` trigger.

The source tree has no automatic aslmanager-plist installation and rmxOS launchd does not auto-scan
`/etc/launchd.d`. This op delivers the product-owned, stageable plist but makes **no activation
claim**. The later contained runtime op must stage it as
`/etc/launchd.d/com.rmxos.aslmanager.once.plist` and explicitly `launchctl load` it through the
existing preview boot-load bridge. Do not expand this op into installworld, mtree, PID-1,
launchd-self-scan, rc.local, or image work.

## REQUIRED CHANGE 3 — USER DOCUMENTATION

Update `aslmanager.8` synopsis and description:

- `-once` forces one normal CLI maintenance pass even when launchd reports the process managed;
- the process returns after that pass, allowing a periodic job to re-arm;
- without `-once`, managed launchd execution retains the XPC-server behavior;
- identify this as the bounded rmxOS preview scheduling mode, not macOS parity.

Do not rewrite unrelated manual content.

## BUILD AND STATIC EVIDENCE

Use a clean, isolated object directory under `build/op314-aslmanager-once/` and record exact
commands, environment, stdout, stderr, and return codes.

Required checks:

1. clean-build `usr.sbin/aslmanager`; report binary path, size, SHA-256, ELF identity, and `NEEDED`;
2. `git diff --check` before commit and `git show --check` after commit;
3. parse the plist as XML and assert its exact load-bearing keys/values plus forbidden-key/argument
   absence;
4. lint/render `aslmanager.8` and show `-once` in synopsis plus its bounded semantics;
5. source-bound mode-selection proof covering all four truth-table rows and exact-token near misses.
   If the actual selector cannot be exercised without loading the target dependency chain, report
   source/preprocessor proof and defer runtime behavior honestly—do not substitute a copied model;
6. full-repository status before and after; one focused local commit containing only the three
   authorized product paths.

Do **not** execute, `dlopen`, or preload the target-linked aslmanager/libmach dependency chain on
the physical host. Do not boot a guest, mutate an image, invoke privilege, push, or claim runtime,
periodicity, reclaim, or leg-4 acceptance.

## EXCLUSIONS — STRIP FROM THE PREVIEW OP

- no faithful MachServices/XPC trigger restoration and no `asl_trigger_aslmanager` un-stub;
- no libasl, asld, libxpc, launchd, libdispatch, kernel, buildworld, release-pipeline, mtree, or
  host-configuration edit;
- no ASL renderer H4/H7/op-305 work;
- no fd-leak diagnosis or generic resource cleanup;
- no op-296…op-302 historical record/validator/manifest repair;
- no reclaim-algorithm, store-format, TTL/default-size, `-d` parser, or calendar behavior change;
- no `500K` production threshold, soak harness, guest run, final integration, or green claim.

## RETURN / VERDICTS

Return one of:

- `DONE <commit>` — focused local commit, clean tree, all build/static gates pass, no push;
- `BLOCKED BASE-DRIFT <fact>`;
- `BLOCKED SCOPE-EXPANSION <required path/reason>`;
- `BLOCKED BUILD <first load-bearing failure>`;
- `BLOCKED CONTRACT <failed mode/plist/doc invariant>`.

Report the complete diff; base/result/parent; changed-path census; source/blob/artifact identities;
all commands/rcs; unavailable reproduction; final full status; push/privilege/host-runtime/guest/image
counts.

Markers:

```text
IMPL_OP314_BASE_IDENTITY
IMPL_OP314_MODE_SELECTION
IMPL_OP314_MANAGED_SERVER_PRESERVED
IMPL_OP314_PERIODIC_PLIST
IMPL_OP314_DOCUMENTATION
IMPL_OP314_BUILD
IMPL_OP314_STATIC_CHECKS
IMPL_OP314_COMMIT
IMPL_OP314_TERMINAL
```

## DOWNSTREAM — NOT AUTHORIZED HERE

After return: independent correctness validation, origin publication, then a separately numbered
Gatekeeper op. That runtime gate must bind exact artifact/image/staging identities and prove at
least two clean periodic invocations, real size+TTL reclaim controls, bounded store/RSS/fd identity,
no crash/panic, and clean shutdown. No downstream op number is reserved here.

feedback: `agent_host_isolation`, `build_is_implementer`, `op_state_dispatch_boundary`,
`launchd_no_autoscan`, `launchd_plist_macos_fidelity`, `artifact_identity_needs_content_check`,
`verify_premise_before_mechanism`, `no_conflate_gating_with_readiness`, `preview_scope_cut`
