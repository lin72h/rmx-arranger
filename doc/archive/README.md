# Archive

Point-in-time documents kept for provenance. Nothing here is current procedure; where one of these
disagrees with a live document, the live document wins. Files moved here unchanged on 2026-09-28,
except two relative links in `cost-factor.md` re-pointed after the move; `git log --follow` traces
their history. Most were imported with the repository on 2026-06-22, so their Git dates are import
dates, not authoring dates.

## Superseded workflow and process

| File | What it was | Superseded by |
|---|---|---|
| `discovery-implementation-pipeline.md` | Explorer/Implementer split plan (phases A–C), Validators-vs-Gatekeeper, and the review rule | `roles.md` (flow, edges, review rule) |
| `arranger-block-workflow.md` | Block-era operating loop | `arranger-rulebook.md` operating loop |
| `validator-bench-calibration.md` | GLM vs DS4P strengths for routing | `roles.md` Validator definitions |
| `cost-factor.md` | Per-role cost weights for parallel issue | Rule 11 (depth by risk) and `roles.md` § Choosing a Validator (cost among Validators) |
| `arranger-swap-legacy-frozen-cp103.md` | Pre-unified journal through cp-103; immutable, SHA-256 `c4e20689…b009d` | `arranger-swap.md` journal |

## One-time onboarding packages

| File | Sent to |
|---|---|
| `role-model-onboarding.md` | the swift-rmxOS Arranger (role model, Block era) |
| `rmx-explorer-onboarding.md` | the Explorer, at the June repo split |
| `rmx-gatekeeper-onboarding.md` | the Gatekeeper, at the June repo split |

## Reviews and assessments

| File | Topic |
|---|---|
| `libdispatch-assessment.md` | libdispatch base/lineage decision (backs `doc/subsystem/subsystem-libdispatch.md`) |
| `xpc-libxpc-assessment.md` | libxpc NextBSD vs ravynos (backs `doc/subsystem/subsystem-libxpc.md`) |
| `parity-explorer-strategy.md` | first parity-loop strategy (replaced by `explorer-parity-cycle-workflow.md`) |
| `swift-darwin-native-path.md` | Swift on rmxOS: Darwin-native vs Linux-mimic path |
| `phase1-runtime-testing.md` | Phase 1 runtime testing plan |
| `phase2-architecture-review.md`, `-v2`, `-v3`, `-v4` | Phase 2 architecture reviews (v4: DMO/DMI foundation) |
| `r6c-blocker-review.md` | R6C port-destroy panic review |
| `mach-msg-milestone-review.md` | mach_msg milestone review |
| `implicit-close-investigation-review.md` | implicit-close investigation review |
| `donor-lane-frontier-review.md`, `donor-lane-next-risk-review.md` | donor-lane reviews |
| `codex-feedback.md` | April review of Codex's implementation work |
| `xe-port-review-feedback.md` | feedback on the Xe port review prompt |
| `repo-strategy.md`, `commit-plan.md` | initial repository strategy and commit plan |
