# Workflow report

Periodic reviews of how the workflow performs: what works, what costs time, and what changed as a
result. Newest first. Decisions and op history stay in the journal (`arranger-swap.md`); milestones
in `worklog.md`.

## 2026-10-02 — Review after the Mach batch-1 and batch-2 rounds

Asked by the Coordinator. Scope: op-391 to op-425 (35 ops in about two days: 31 closed,
1 dropped, 2 running, 1 returned).

### What works

- **Verification pays for itself.** First-hand checks and the Validators caught problems that
  would otherwise have been believed:
  - product bugs: the fix-6 lock regression (op-407), launchd's `GetJob` exporting the caller
    (op-422, id-059), `mach.ko` without `MODULE_VERSION` (op-411);
  - evidence errors: the "leak-locals" misreading of ifunc symbols (op-396, op-397);
  - image errors: the `kernel=` form that silently booted RELEASE instead of KASAN (op-410);
  - platform facts: PID 1 cannot be traced on FreeBSD (op-400); `makefs -t zfs` drops file flags
    (op-419).
- **Parallel lanes.** Most of the time three or four agents worked at once on different repos and
  images, without collisions.
- **Cost tiering.** Advisors only for design (op-394, op-421); Validators for diffs that decide a
  result; build and documentation ops closed on the Arranger's own check (the 2026-10-01 sizing
  change).
- **The relay steers.** The Coordinator's decisions at key points shaped the work: fd-backed names
  kept for 1.0 and step 5 deferred (id-056), native close semantics instead of the EOF helper,
  ZFS-root images, the lighter evidence rules.

### What costs time

- **Brief quality is the largest waste**, much of it the Arranger's. About ten guest ops stopped on
  harness or brief problems rather than product findings.
  - Arranger brief errors: `kyua` assumed in the image (op-406), ZFS boot code required (op-414),
    a continuation message naming only step 1 (op-398), a NOTICE contradicting op-391's limits,
    the `.../kernel` loader form accepted unchecked (op-396).
  - Agents' own harness errors: a classifier that did not compile (op-391), a D collector format
    bug (op-405).
  - Now standing rules: check feasibility first; check guest commands against the image; compile
    scripts on the host; fix your own harness in the op; finish independent cases when one input
    fails.
- **Relay ambiguity.** op-407 and op-425 were recorded as sent from a "sent" that covered two
  ready ops. That was the Arranger's error. Proposed convention: reply "sent op-NNN".
- **Provider filter stops.** Five in one day. Addressed by `safety-flag-avoidance.md` and the
  shared project-context text in every role's instructions.

The relay's built-in costs (latency, an occasional missed relay) are accepted: the relay is
deliberate.

### Is it "graph engineering"?

There is no single agreed definition, so this maps the workflow onto a graph rather than claiming
a framework.

- **It is a graph in structure.** Ops are nodes (one agent, one repo, one result); IDQ problems are
  long-lived nodes. `needs`, `idq` and review links (Implementer → Validator → Gatekeeper → close)
  are edges. Roles are node types, gates are edge conditions, and `tools/rob` holds node state.
- **It is not executed automatically.** The Coordinator is the scheduler on every edge, on
  purpose, and much of the dependency structure lives in the Arranger's head and the journal, not
  in the graph (`needs` is often empty).
- **Possible next step**, keeping the relay: record every real dependency in `needs`, and add a
  `tools/rob graph` view of ops, their dependencies and which are ready, so "what's next" becomes a
  query.

### Changes adopted from this review

- Record an op as sent only when the Coordinator names it; ask if unsure (LOCAL.md).
- Proposed, pending the Coordinator: the "sent op-NNN" reply convention, and `tools/rob graph`.
