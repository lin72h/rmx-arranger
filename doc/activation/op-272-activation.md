<!-- ROB tracking (not part of the paste): op-272 | role: Oracle (consult-only) | EXU: oracle2 | state: [Awaiting — RE-ISSUED to the oracle2 seat 2026-07-10 after oracle1 did NOT return this consult (one of op-270/272/276, the three oracle1 no-returns; re-dispatched rather than left dangling). Content unchanged from the 2026-07-04 single-feature form; oracle1-internal op-lineage softened out of the body for the fresh seat, file:line citations kept. Sibling to the asl query-MATCH read (op-269, already returned) — this is the RENDER path. Coordinator dispatches on oracle2 ack.] | parent id-011 (libasl/asld) | L1i li-1004 (asl) | cost oracle-tier | authored 2026-07-04, re-issued 2026-07-10 (Arranger seat, model Opus 4). Paste from the "#" title line down. -->

# Confirm the correctness of the ASL message rendering path (how a stored record becomes a formatted log line) — one feature, one file

## PREAMBLE — what this project is
rmxOS is an **open-source operating system** — a Darwin/Mach userland ported onto stock FreeBSD 15, developed in the open like FreeBSD or illumos. This is a **maintainer's own code-quality check of ONE feature of our system logger** — how a stored log message is turned into a formatted text line for a log file or a `syslog` display. Ordinary pre-release engineering on our own source — the goal is simply to confirm this one path is well-built for our own users. No target, no adversary, nothing to exploit.

## THE ONE FEATURE (this is the whole scope)
The ASL **message rendering** path — `asl_format_message` (`lib/libasl/asl_msg.c:126` decl; body + helpers around `:1916`) plus the format helpers it calls: given a message, a format name or template (`std` / `bsd` / `xml` / `msg` / `raw`, or a custom `$((Key))`-style template), a time format, and a text-encoding option, produce the text line a log sink writes. Confirm this one render path produces the right line — nothing wider.

## CONTEXT
Rendering is the last step before a message reaches a human-readable log: pick the fields the format calls for, lay them out in the documented order, format the timestamp, and render any control or non-printable bytes in a readable form. It is easy for a formatter to quietly emit the wrong field, drop a value on an absent key, or mis-size the output string — bugs that flat conformance lines rarely surface. This is the render companion to a prior store-framing read and a prior query-match read: store it, find it, and now render it. Plain software-engineering framing: format selection, field substitution, time formatting, and text-encoding fidelity.

## THE QUESTIONS (all about this one path)
1. **Format selection.** Does each built-in format (`std`, `bsd`, `xml`, `msg`/`raw`) and a custom template render the documented fields in the documented layout — no format that emits the wrong field, mislabels one, or produces an empty line where a record was present?
2. **Field substitution.** For a template referencing a key that is present versus absent in the message, is the result consistent (an absent key yields the documented empty/placeholder rather than a stray dereference), and do repeated or positional key references resolve correctly?
3. **Time formatting.** Does the timestamp render per the requested time format (raw seconds, UTC, local) consistently — including any sub-second and timezone handling — always producing a well-formed timestamp field?
4. **Text-encoding fidelity.** Does the text-encoding pass that renders control characters and non-printable bytes in a readable form leave ordinary text unchanged, render unusual bytes deterministically, and always return a complete NUL-terminated string whose reported length matches its contents?

## DELIVERABLE
A short staged note in your own consult dir: for each of the 4 questions, a finding characterized **solid / uncertain / needs-runtime-check**, each a hypothesis with an `asl_msg.c` file:line citation. Anything uncertain, bucket by effort/risk. Every finding is a hypothesis the maintainers route to verification or a milestone seed — not a product edit, not a release decision.

## BOUNDARIES
- Read + advise only; propose, do not edit; stage the note in your own dir.
- Scope is EXACTLY the render path (`asl_format_message` + its format/time/encoding helpers) — do NOT expand into the query-MATCH function `asl_msg_cmp` (a separate read covered it), the store write/read-back framing, the message submit path, or the client API matrix. No interface-shape or cross-platform comparison work.
- Treat every observation as a hypothesis to confirm at source before it drives an edit; read the actual helper body before asserting a field is mishandled (a couple of prior asl reviews produced signature claims that turned out already-correct-by-design once the body was read — verify at source).
- Does not decide release timing or milestone placement.

## RELATIONS
The prior asl store write/read-back framing read + the query-MATCH `asl_msg_cmp` read in the same file (this is the RENDER sibling, fenced off from the matcher) / the same narrow single-feature consult style as our recent asl-store and launchd-supervision reviews / the asl subsystem milestone (li-1004). Every finding is a hypothesis the maintainers verify at source before it drives any edit.
