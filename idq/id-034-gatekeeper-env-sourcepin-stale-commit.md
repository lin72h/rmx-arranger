# id-034 — Gatekeeper env source-pin tests fail-closed on a stale hard-coded commit — re-baseline (and de-drift) the canonical-commit pin

- id: id-034
- state: **OPEN — verified first-hand 2026-07-02 (Arranger, during op-229/op-230 adjudication).** Cheap Gatekeeper-harness hygiene; non-blocking; free role.
- raised: 2026-07-02 (Arranger seat).
- roadmap parent: **li-1000 / id-007** (soak/evidence infra) — this is the Gatekeeper's own env-validation harness, not product.
- bucket: harness hygiene (the Gatekeeper is our evidence authority; its own suite should not run with a red baseline).

## The finding (verified)

The Gatekeeper repo (`rmx-gatekeeper`) carries **4 standing red tests** in `test/rmx_os_oracle/env_test.exs` + `test/rmx_os_oracle/stable15_env_matrix_test.exs`. They are NOT caused by op-229/op-230 (neither touched those files; confirmed still failing at parent `3b43f9d`).

**Root cause (confirmed at source):** `env_test.exs:13` hard-codes `@candidate_commit "a0c2a8fb822e"` as the expected canonical `stable15-active` source pin, and the tests assert `report["freebsd_src_commit"] == @candidate_commit`. The canonical tree `wip-gpt/wip-rmxos` HEAD is now **`106f9d7fd160`** ("dispatch: probe and report concurrency engine" — **op-227's commit**). So the pin check fail-closes correctly against a stale expectation. The tests are doing their job; the pinned value is out of date because the tree legitimately advanced.

## Why it matters (why file, not ignore)

- The Gatekeeper is the evidence/QA role. A 4-red baseline **masks regressions** — a real 5th failure blends into the known noise (`no_conflate_gating_with_readiness` in spirit: a dirty suite erodes the trust its greens are supposed to carry).
- The failure mode is **recurring by construction**: any commit to the canonical tree (op-227 was just the latest) re-breaks a hard-coded commit pin. This will keep re-reddening unless the pin is derived, not literal.

## Fix shape (cheap, free role)

1. **Re-baseline** `@candidate_commit` (+ any companion objdir paths in `env_test.exs:6-12` / the matrix test) to the current canonical `stable15-active` pin (`106f9d7fd160` as of 2026-07-02) so the 4 tests go green again.
2. **De-drift (recommended, small):** derive the expected canonical commit from a single manifest/source-pin registry rather than a literal in the test, so the pin advances with the tree and the suite stops re-breaking on every canonical bump. (If a source-pin registry already exists elsewhere in the harness, point the test at it.)
3. Confirm green: `mix test` returns 0 failures (currently 197/201, 2 park-excluded, 4 red → target 201/201-with-exclusions).

## Boundaries
- **Gatekeeper-harness only** — no product/source change; this is test-expectation hygiene (`harness_authoring_is_gatekeeper`).
- **Verify the new pin is the intended canonical** before baking it in (don't just chase HEAD blindly — confirm `106f9d7fd160` is the accepted `stable15-active` pin, not a transient).
- Small enough for a **Validator** targeted Change→Retired, or a Gatekeeper hygiene pass; free role either way.

## Relations
- **op-229 / op-230** — surfaced during their adjudication (the "suite GREEN" report-claim correction); not caused by them.
- **op-227** — the commit (`106f9d7fd160`) that most recently advanced the tree past the stale pin; illustrates the recurring drift.
- **li-1000 / id-007** — Gatekeeper evidence/soak infra.
- feedback: `no_conflate_gating_with_readiness` (a dirty baseline erodes green-trust), `artifact_identity_needs_content_check` (a source pin IS an artifact-identity check — keep it accurate), `verify-premise-before-mechanism` (root cause verified at source before filing). project: canonical source tree = `wip-gpt/wip-rmxos`.
- **First op when promoted:** a Validator (or Gatekeeper hygiene) op to re-baseline + optionally de-drift the pin; free role, non-blocking.
