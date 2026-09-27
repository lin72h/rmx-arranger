# op-304 — Implementer: correct five validated ASL rendering paths

op-304 | role: **Implementer** (sole product writer) | EXU: **wip-gpt / wip-rmxos** | state:
**[Retired — commit `a52a2ef51560943f7af4fe0b38e27f83508fd9b6` passed op-309
VALIDATED-CORRECTION at confidence 9/10 and is clean, origin-reachable, and the live `alpha` tip]** | parent:
**op-303 / op-272 / id-011** | L1i: **li-1004** | related: **op-305 / id-040** | authored:
**2026-07-11 by Arranger2**

## ARRANGER RETIREMENT — 2026-07-11

Publication gate size: **S** (the L-sized source/evidence correctness gate already retired as
op-309). Arranger2 verified first-hand in the full product repository:

- branch, `HEAD`, `origin/alpha`, and fresh `ls-remote origin refs/heads/alpha` all equal
  `a52a2ef51560943f7af4fe0b38e27f83508fd9b6`;
- full worktree status is clean and `alpha...origin/alpha` is `0/0`;
- the sole parent is `ceb46edc5f910660d4fa7ecd9e90501ebd86b1ba` and both parent/result and
  result/`origin/alpha` ancestry checks pass;
- the published commit still changes exactly the four commissioned ASL paths, `+48/-6`, with no
  source change during publication; and
- `git diff --check` and `git show --check` remain clean.

The Arranger did not rerun builds or microchecks at publication consumption; op-309's confidence-9
correctness verdict and disclosed evidence qualifications stand. Publication/origin was the sole
remaining retirement blocker. **Verdict: RETIRED.** op-304 leaves the live ROB. This does not make
ASL leg 4 green and does not by itself dispatch held op-305.

## PUBLICATION RELEASE — CONSUMED 2026-07-11

op-309 returned VALIDATED-CORRECTION at confidence 9/10 and Arranger2 consumed it under Rule 11
after light identity checks. The Coordinator dispatched this exact no-change publication stage to
**wip-gpt / wip-rmxos**. It remained part of op-304 and consumed no new ROB number.
For this later stage only, this publication block supersedes the original implementation-stage
no-push sentence below; every other original boundary remains in force.

### Required preflight

In /Users/me/wip-mach/wip-gpt/wip-rmxos/, require all of:

- branch alpha;
- clean full-repository status;
- local HEAD exactly a52a2ef51560943f7af4fe0b38e27f83508fd9b6;
- parent exactly ceb46edc5f910660d4fa7ecd9e90501ebd86b1ba;
- local tracking ref origin/alpha exactly ceb46edc5f910660d4fa7ecd9e90501ebd86b1ba;
- fresh git ls-remote origin refs/heads/alpha exactly
  ceb46edc5f910660d4fa7ecd9e90501ebd86b1ba; and
- the remote tip is the direct parent/ancestor of the result.

Stop PUBLICATION-BLOCKED <drift> on any mismatch. Do not fetch-and-merge, pull, rebase, amend,
clean, create a commit, alter source/build evidence, or force.

### Authorized publication

Perform one non-force fast-forward of only the accepted commit to refs/heads/alpha:

    git push origin a52a2ef51560943f7af4fe0b38e27f83508fd9b6:refs/heads/alpha

No tag, other branch, submodule, artifact, image, guest, or control repository is in scope.

### Post-push proof

After a successful push:

1. fetch/refresh only the ordinary remote-tracking observation;
2. run fresh git ls-remote origin refs/heads/alpha;
3. require local HEAD, origin/alpha, and live remote all equal
   a52a2ef51560943f7af4fe0b38e27f83508fd9b6;
4. require full status clean and no ahead/behind count; and
5. require git merge-base --is-ancestor a52a2ef... origin/alpha succeeds.

Return exactly PUBLISHED a52a2ef51560943f7af4fe0b38e27f83508fd9b6 or
PUBLICATION-BLOCKED <reason>, with pre/post tips, push output/rc, fresh live-remote output,
full final status, source_changes=0, commits_created=0, force=0, guest=0.

Publication does not itself retire op-304 or release op-305. Arranger2 first verifies origin
reachability, then performs those control-state transitions.

Markers:

IMPL_OP304_PUBLICATION_PREFLIGHT

IMPL_OP304_PUBLICATION_PUSH

IMPL_OP304_PUBLICATION_REMOTE

IMPL_OP304_PUBLICATION_TERMINAL

## DISPATCH BOUNDARY

DISPATCHED by the Coordinator on 2026-07-11 to **wip-gpt / wip-rmxos** only. Write only
`/Users/me/wip-mach/wip-gpt/wip-rmxos/` and Implementer-owned build output. The Arranger, Oracle,
Validator, Explorer, and Gatekeeper trees are read-only.

Create one focused local product commit; do not push, stage a guest, modify the shipped image, or
claim runtime/ASL-leg-4 acceptance. Gatekeeper vectors are a separate held op-305.

## REQUIRED BASE

- repository: `/Users/me/wip-mach/wip-gpt/wip-rmxos/`;
- branch/local tracking/live remote: clean
  `alpha@ceb46edc5f910660d4fa7ecd9e90501ebd86b1ba`;
- validated input note:
  `/Users/me/wip-mach/rmx-oracle2/op-272-asl-message-rendering-findings.md`, 27,694 bytes / 419 lines /
  SHA-256 `02a431709085027ed989a0f8e98b271f20d8eab8ad2e0df15dd0fda5568a96ca`; and
- gate: op-303 `VALIDATED-SOURCE-FINDINGS`, confidence 9/10.

Stop with `BLOCKED BASE-DRIFT` if the branch, worktree, note, or relevant source differs. Do not
repin, pull, merge, clean, or absorb unrelated work.

## AUTHORIZED PRODUCT PATHS

The expected edit ceiling is exactly:

- `lib/libasl/asl_msg.c` — H1, H2 renderer selection, H3;
- `lib/libasl/asl_util.c` — H5 validator;
- `usr.bin/aslutil/syslog.c` — H2/H6 tool selection; and
- `usr.sbin/asl/asl_action.c` — H6 configured asld sink.

Read surrounding helpers and contracts wherever required, but edit no other product path. If a
correct fix needs a fifth path or a public/build-system change, return `BLOCKED SCOPE-EXPANSION`
with the exact dependency; do not widen the commit.

## OBJECTIVE

Implement exactly the five validated, preview-relevant rendering corrections H1/H2/H3/H5/H6.
Preserve ordinary RAW/STD/BSD/MSG/XML output, ownership, newline/NUL behavior, and every unrelated
ASL path.

## REQUIRED CORRECTIONS

### H1 — documented NULL default

Make `asl_format(..., msg_fmt=NULL, ...)` select the documented STD layout. Explicit `raw`, `std`,
`bsd`, `msg`, and `xml` selections must remain unchanged. Do not alter the public signature or
silently change explicit RAW callers.

### H2 — documented `xml.N`

Recognize documented XML fractional-time suffixes in both the renderer and `aslutil` option path.
Mirror the existing RAW/STD/BSD suffix grammar, precision validation/clamping, and time-format
construction; do not invent a second parser. `xml.4` must select XML output with four fractional
digits, wrappers/encoding included, rather than render literal custom text. Preserve invalid/custom
format fallback outside the documented suffix grammar.

### H3 — terminal backslash

Guard the custom-template escape path before advancing beyond NUL. Define a terminal `\` as one
literal backslash, then finish normally. Preserve `\$`, numeric escapes, ordinary backslashes,
placeholder parsing, final newline, NUL termination, and returned length.

### H5 — UTF-8 completeness and surrogate rejection

Correct `asl_is_utf8` narrowly so a successful result requires the state machine to end in the
complete state and UTF-8 surrogate encodings such as `ED A0 80` are rejected. Preserve every valid
1/2/3/4-byte boundary already accepted. Preserve the renderer's existing type-specific behavior:
invalid/truncated **keys are omitted with their pair**, while invalid/truncated **values** select the
existing XML base64/`<data>` path rather than raw `<string>` content. Do not rewrite the encoding
subsystem.

### H6 — configured XML encoding

Ensure configured `format=xml` and documented `xml.N` paths use `ASL_ENCODE_XML`, not hard-coded
SAFE, through both asld configured-file output and `aslutil`. Non-XML configured output remains SAFE
unless explicitly selected otherwise. Do not change default shipped configuration or enable a new
XML sink.

## REQUIRED NEGATIVE/POSITIVE MICROCHECKS

Create Implementer-owned host-side test inputs under `build/op304-asl-render/`; do not add an
unreviewed product test framework. Test the freshly built artifacts, not system libasl:

1. H1: NULL format yields STD; explicit RAW remains RAW.
2. H2: exact XML and `xml.4` both produce XML; `xml.4` carries four fractional digits and is not
   the literal line `xml.4`.
3. H3: `abc\` returns deterministic `abc\` plus the normal newline/NUL, with no out-of-bounds report;
   `\$` and one numeric escape remain unchanged.
4. H5: as values, truncated 2/3/4-byte sequences plus `ED A0 80` select `<data>`; as keys, each
   invalid sequence causes its complete key/value pair to be omitted; representative valid boundary
   keys and values remain `<key>`/`<string>`.
5. H6: configured XML content containing `& < > " '` is entity-escaped and parses as XML; a normal BSD
   configured line remains byte-compatible.

Use allocator junk and an available sanitizer or equivalent bounds detector for H3; if unavailable,
state that plainly and still run the deterministic output/guard-path check. Record exact commands,
return codes, source hashes, binary/library hashes, and outputs.

## BUILD / SOURCE GATE

- Build `lib/libasl`, `usr.bin/aslutil`, and `usr.sbin/asl` with the established clean FreeBSD target
  environment. A component not affected after dependency analysis may be skipped only with the exact
  reason and a successful consumer compile/link covering it.
- Run `git diff --check` and `git show --check`.
- Full-repository status must be clean after the focused commit.
- Commit only validated source changes. Test artifacts/logs stay in Implementer-owned build output
  unless an existing product test location is deliberately used and justified.

## EXCLUSIONS

- Do not fix H4 fractional textual timezone parsing or H7 empty/sparse XML iteration; they are
  confirmed post-preview seeds banked under id-011.
- No OOM, multi-gigabyte-template, malformed-time policy, socket framing, query, store, submit,
  aslmanager scheduling/reclaim, id-040, or ASL leg-4 work.
- No interface redesign, encoding-model simplification (op-276), broad cleanup, build-system change,
  guest run, image edit, push, or release claim.

## RETURN / VERDICT

Return exactly one:

- `DONE <commit>` — all five corrections, builds, and microchecks pass in one focused commit;
- `BLOCKED <reason>` — a required contract/build/vector cannot be completed without expanding scope;
  preserve coherent work and report exact dirt; or
- `NO-CHANGE <source proof>` — only if the pinned source already satisfies every commissioned case.

Report base/result commits, parent, complete diff and paths, build identities, every vector result,
full status, push=0, and unavailable reproduction. The return becomes `[Done]` only and receives a
separate Validator gate before retirement; op-305 remains held until exact artifact acceptance.

## MARKERS

`IMPL_OP304_BASE_IDENTITY`

`IMPL_OP304_H1_NULL_DEFAULT`

`IMPL_OP304_H2_XML_SUFFIX`

`IMPL_OP304_H3_TERMINAL_SLASH`

`IMPL_OP304_H5_UTF8`

`IMPL_OP304_H6_XML_ENCODING`

`IMPL_OP304_BUILD`

`IMPL_OP304_COMMIT`

`IMPL_OP304_TERMINAL`

## RELATIONS

op-272 / op-303 / op-305 / id-011 / li-1004 / id-040.

feedback: `validated_source_finding`, `build_is_implementer`, `agent_host_isolation`,
`no_conflate_gating_with_readiness`, `op_state_dispatch_boundary`.
