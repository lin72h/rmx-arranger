---
id: op-613
state: draft
agent: volta-arranger
repo: /Users/me/wip-volta/volta-arranger
idq: meta-000
authority: edit volta-arranger as the setup needs; create role repos when the owner approves the seats; host-only checks; no product code; no push
expected: 3h
updated: 2026-10-10T02:51Z
---
# op-613 — Volta Arranger: adopt the shared workflow (independent root): tools, records, templates, and seats for H2 and H3

## Outcome

**Expected time: about 3 hours** (reading 45 min; setting up the repo
and rendering 75 min; the seat proposal and the first ops 60 min).

Volta adopts the shared workflow that rmxOS, zenoh-swift, depthai,
swift-sdk and fstack use (owner, 2026-10-10): all of it, now, as an
independent project (no parent Arranger). The workflow lives in
`~/wip-workflow`: the method, base templates, a scaffold and four
tools (`rob` for op state, `roles` for rendering role repos, `last`
for the resume log, `brief-check` for text an agent will read). You
are Volta's Arranger: you do this setup yourself, in your repo, and
decide the details; this brief says what the result must be.

0. **Before changing anything:** finish or park the piece of work in
   hand, check that arranger2 (mm4) and arranger3 (rkl) have nothing
   uncommitted in `volta-arranger`, and tell the owner the switch is
   starting.
1. **Read the workflow:** `~/wip-workflow/README.md`,
   `docs/onboarding.md`, `docs/method.md` (roles, dynamic roles,
   review, records, templates, wording), `docs/forms.md`, and
   `CHANGELOG.md`. The newest change is `meta-018`
   (`git -C ~/wip-workflow tag`).
2. **Make `volta-arranger` a workflow Arranger repo, keeping its
   history.** Copy in everything from
   `~/wip-workflow/scaffold/arranger/` that this repo lacks
   (`ls -A ~/wip-workflow/scaffold/arranger` lists it: the four tool
   wrappers, the two templates, the instance file, the workflow pin,
   the brief-check settings, the problem index, the op directory, the
   journal, the resume log, the critical-path page and the roster),
   and add `.workflow/` to `.gitignore`. Pin `meta-018` in
   `workflow.lock`. The prefix is `volta-`; role repos will be
   `volta-<role>N` beside the product forks (`volta`, `volta-aro`,
   `volta-ispc`, `volta-zig`), and no name collides today.
3. **Project facts:** in `role0/template.json` put the pins as vars
   (Zig, LLVM and ISPC versions and commits from
   `volta/TOOLCHAIN.lock`, the hosts H1, H2, H3); in
   `role0/partials/project-context.md` the paragraph every agent reads
   first: what Volta is, that ISPC is the specification, the five
   principles, the hosts. `AGENTS.md` becomes a rendered file: move
   what it says now (the repo list; no AI attribution in commits or
   pull requests) into `role0` or `arranger0` blocks first, so nothing
   is lost. Then `tools/roles render volta-arranger` and
   `tools/roles check`; no unresolved `{{ }}` in what renders.
4. **Records:** keep `README.md` (status, decision register,
   changelog), `onboarding.md` (the owner's directives), the roadmap
   and the design documents as the project's documents. The scaffold's
   critical-path page holds the critical path and links the roadmap.
   The resume log, written with `tools/last add`, takes over the "where I stopped" job of
   onboarding.md § 1 and the handoff files: write its first entry.
   `journal.md` starts today, one entry per state change or decision;
   history stays in Git and the changelog. From now on work is an op
   (`tools/rob new`), and every brief, answer or handoff you write for
   another agent goes through `tools/brief-check` first. Put the
   phrasings that have stopped your agents before into
   `brief-check.conf`.
5. **Seats (a decision for the owner; present it, then act on the
   answer).** Today one agent per host holds every role; H2's and
   H3's agents guard H1's releases on their venues and also own
   development work (onboarding.md § Round 7), and they commit to
   `volta-arranger`. In the workflow only the Arranger writes the
   Arranger repo; other agents work in their own repos and reply
   through the owner. Present two options with your recommendation:
   (a) H2 and H3 become Implementer instances (`volta-implementer2`
   on mm4, `volta-implementer3` on rkl, from the scaffold's
   implementer template), with guard runs as ops; (b) they become
   Gatekeeper instances (no scaffold yet; rmxOS's
   `/Users/me/wip-mach/rmx-gatekeeper0/` is a reference) and their
   development work moves to H1. Either way, an instance on another
   host lives only there: ops name its repo as `host:/path`; to
   render it, copy its `instance.json`, `.rendered.lock`, `LOCAL.md`
   and rendered files into a temporary workspace beside `role0` and
   the class template, run
   `ROLES_WORKSPACE=<that workspace> tools/roles render <instance>`,
   and copy the rendered files and lock back. Their host facts and
   handoffs move to their own repos.
6. **First ops:** turn the work in flight into ops: the ISPC pin bump
   (0.17.71) and H3's start. Show each to the owner as one copy-paste
   block; it stays `draft` until the owner says it was sent.
7. **Register:** tell the owner that Volta is set up, so the
   workflow's `projects.md` can list it as an independent project.

Record this op `issued` in your own board when you receive it. End
your reply with:

```text
reply to op-613
agent:      volta-arranger
outcome:    DONE | PARTIAL | BLOCKED — one line
verified:   <what you checked first-hand: renders, roles check, board, last>
changed:    <files changed and why>
seats:      <the two options and your recommendation, or the owner's answer>
evidence:   <commits>
untested:   <what you could not check, or none>
next:       <the first ops, ready to send>
```

## Limits

- No product code in this op. No push unless the owner asks.
- Do not change other projects' repos (`/Users/me/wip-mach/`,
  `~/wip-workflow`); read them only.
