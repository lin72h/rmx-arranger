# op-237 — Implementer: branch-cleanup feedback + the one salvage — premise-check the archived fd-backed dead-name uref fix against alpha, cherry-pick ONLY on a proven gap

op-237 | role: **Implementer** (source dive + conditional product-write) | EXU: **wip-gpt (Implementer seat)** | state: **[Done — no live gap, branch (a); salvage retired no-op, 2026-07-02]** — premise-check returned NEGATIVE; no cherry-pick, no build. Arranger-verified at source (light provenance check, Rule 11). | parent id: id-035 (→ li-1014 → li-1001 dead-name invariant) | L1i: li-1014 / li-1001 | cost: 30 (code-reasoned dive; conditional small cherry-pick) | authored 2026-07-02 (Arranger seat, model Opus 4)

## OUTCOME (branch (a) — no live gap; Arranger-verified at source, 2026-07-02)
The archived opus commits are **divergent from alpha's current accounting model, not missing.** Premise-check evidence (Implementer, confirmed first-hand by Arranger at the decisive lines):
- Fresh dead names set `MACH_PORT_TYPE_DEAD_NAME | 1` **without** `ipc_entry_hold()` in both allocation paths — `ipc_object.c:177` (Arranger-confirmed) + `:216` (Arranger-confirmed).
- Alpha's helper `ipc_entry_mach_urefs()` **deliberately special-cases dead names**: dead names return raw `ipc_entry_refs()` (`ipc_entry.c:668`, Arranger-confirmed), while non-dead rights subtract the fd backing ref (`refs - 1`, `ipc_entry.c:671`, Arranger-confirmed).
- `ipc_right_info()` already reports through `ipc_entry_mach_urefs()` (`ipc_right.c:1260`); MOVE_SEND uses the helper alpha reintroduced after the broad revert (`ipc_right.c:1553`).
- The broad opus translation commit (`8e2912e6127b`) was **previously reverted on alpha, then selectively reintroduced as targeted fixes**; current dead-name paths use raw refs consistently.

**Why not safe as-is:** with alpha's dead-name-special helper, adding `ipc_entry_hold()` to a fresh dead name (afa158860c29) would make it count as **2, not 1**. Reapplying `8e2912e6127b` would re-open the broad fd-backed translation alpha explicitly moved away from. → **no cherry-pick.** Working tree clean; commits: none. **id-035 + li-1014 retire no-op**; the archive stays as the record. No Validator/Gatekeeper handoff for this archived pair.

## BRANCH-CLEANUP FEEDBACK (Arranger, first-hand, 2026-07-02) — the consolidation is CLEAN
The consolidation to a single source-of-truth `alpha` @ `106f9d7fd160` was audited first-hand across **every** archived `backup/*` ref (not just the listed five). Verdict: **nothing useful was thrown away.** All refs are already-in-alpha (op-156-id025-waitpath, op-171-x86-64-v3-alpha, build/*, donor/userland-import, official-stable15-*: 0 ahead), superseded (op-160 — alpha's libxpc is newer; op-144 — `986be5d` supersedes; op-149 attempts — iconv fixes already landed, header work superseded), or vendor/history (releng/15.1 = FreeBSD release commits mis-attributed to author `lin`; milestone/snapshot = intentional snapshots). **Removal from origin was archival, not deletion** — all 27 refs live in the `backup` remote. **alpha needs nothing merged to be a complete source of truth.**

**One durability note (not a loss — a risk to flag):** the `backup` remote is a **local** bare repo (`/Users/me/wip-mach/remotes/rmxOS.git`), not pushed off-host. The archived history is only as safe as that disk. Recommend (Coordinator call) pushing `backup` to an off-host remote so the removed branches survive a host loss. Not this op's work; flagged.

## THE ONE SALVAGE CANDIDATE (this op's actual work)
The audit found exactly ONE piece of genuinely-useful, not-yet-in-alpha content: a fd-backed **dead-name user-reference** fix, preserved in `backup/opus/mach-uref-fix` (also in `backup/donor/full-import`):
- `afa158860c29` — ipc: bump f_count for initial dead-name user reference → `sys/compat/mach/ipc/ipc_object.c` (+2)
- `8e2912e6127b` — ipc_entry: Mach-uref translation layer for fd-backed entries → `sys/compat/mach/ipc/ipc_entry.c` (+16), `ipc_right.c` (±14), `sys/sys/mach/ipc/ipc_entry.h` (+3)

The parent branch is **598 commits behind alpha** (drags all of releng/15.1 + the donor import) → a branch merge is categorically OUT. Only these two commits are the candidate.

## SCOPE (premise-first; do NOT blind-merge)
1. **Premise-check FIRST (`verify-premise-before-mechanism`).** Read alpha's fd-backed initial-dead-name uref path (`sys/compat/mach/ipc/ipc_entry.c` / `ipc_right.c` / `ipc_object.c` — alpha already carries uref/f_count logic: 12 / 34 / 2 matches). Determine, at source, whether the archived behavior is **present**, **absent (live gap)**, or **divergent**. Report the finding with the exact lines compared — this is a claimed dead-name divergence, a repeat false-claim area (`verify_signature_divergence_claims`), so it is verified at source, not asserted from commit titles.
2. **If already-handled or divergent → STOP and report "no live gap."** No cherry-pick. id-035 + li-1014 retire no-op; the archive stays as the record.
3. **If a real, currently-unfixed gap → cherry-pick/adapt the two commits onto alpha** as a **`mach.ko` standalone-module build** (`make -C sys/modules/mach`, MAKEOBJDIRPREFIX only — NOT a branch merge). Diff-vs-stock discipline; minimal adaptation to alpha's current ipc layer. Build clean + record the built `mach.ko` sha.

## NON-SCOPE
- Does NOT merge the branch or bring in ANY other archived commit (all others are already-in-alpha / superseded / vendor — see feedback above).
- Does NOT adjudicate its own kernel semantics (Validator gate) or run its own dead-name soak (Gatekeeper, li-1001 leg) — those are separate hops.
- Does NOT push the `backup` remote off-host (Coordinator call; flagged, not this op).

## DELIVERABLE
Either **(a)** a source-grounded "no live gap — alpha already handles fd-backed dead-name uref" finding (exact lines), retiring the salvage; or **(b)** a clean `mach.ko` standalone-module build with the two commits adapted onto alpha, built + sha-recorded, handed to a Validator for the kernel-semantics gate (then a Gatekeeper dead-name soak leg). Report which branch (a/b) and the evidence.

## BOUNDARIES
- **build_is_implementer**; the Implementer builds + reasons the source, does not self-gate the semantics (Validator, Rule 11 — kernel semantics = L/XL, confidence 1–10; Arranger steps in <9) or self-soak (Gatekeeper).
- **mach.ko is a standalone module build** (`make -C sys/modules/mach`, MAKEOBJDIRPREFIX only, no KERNBUILDDIR) — do not fold into buildkernel.
- **Diff vs stock / userland-port discipline** — this is our compat-Mach ipc layer; adapt minimally, do not restructure alpha's ipc.
- Stage only in the Implementer's own tree (agent_host_isolation); the two commits come from the `backup` remote refs, cherry-picked — never a branch merge.

## RELATIONS
id-035 (parent — the premise-gated question) → li-1014 (salvage instruction) → li-1001 (dead-name delivery invariant, the soak leg if (b)). branch-consolidation audit (2026-07-02, Arranger first-hand). Archived commits: `afa158860c29` + `8e2912e6127b` on `backup/opus/mach-uref-fix`. feedback: `verify_signature_divergence_claims` (dead-name = repeat false-claim area), `verify-premise-before-mechanism` (premise-check is task 1), `build_is_implementer`, `soak_is_gatekeeper`, `mach_ko standalone module build`, Rule 11 Validator-gating, `op_state_dispatch_boundary` (authored [Awaiting]).
