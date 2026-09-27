---
id: op-276
state: dropped
updated: 2026-09-27T22:54Z
legacy-state: Draft
reset: j-20260927-004
---
# op-276 — Oracle2: ASL UTF-8-only encoding-model simplification design

op-276 | role: **Oracle** (consult-only; no product or control write) | EXU:
**Oracle2 / rmx-oracle2** | state: **[Draft — op-304 is retired; legacy consult remains
non-dispatchable pending current-source repin/normalization and preview-scope decision]** |
parent: **id-011** | L1i: **li-1004** | related: **op-272 / op-303 / op-304 / op-305** |
authored: **2026-07-04; reissued 2026-07-10; ROB status reconciled 2026-07-11 by Arranger2**

## ROB CLEANUP — 2026-07-11

The former legacy `[Awaiting]` tracking state is superseded by the canonical header. op-304 is now
retired at origin-reachable `a52a2ef51560943f7af4fe0b38e27f83508fd9b6`, so that dependency is
clear. Do not dispatch this 2026-07-04 card as-is: the Arranger must still re-pin its exact current
source/artifact identities, normalize the Oracle2 deliverable/markers and boundaries, and decide
whether any residual simplification is preview-relevant or should be banked. Until then this op is
`[Draft]`, not `[Ready]`/`[Awaiting]`.

## LEGACY DESIGN BODY — NOT A DISPATCH ARTIFACT

### asl's text-encoding model — does it lean on libiconv/locale, and does a UTF-8-only commitment let it simplify? — one subsystem, one question

## WHAT THIS IS
Forward-looking simplification design on OUR OWN system logger. The question a maintainer is asking: our ASL text handling — does it lean on FreeBSD's kernel **libiconv** and the **locale** subsystem for character encoding, and if rmxOS commits to **UTF-8 only**, can the whole text-encoding path be simplified? rmxOS is an open-source Darwin/Mach userland on stock FreeBSD 15; ASL is its system logger, and its store/render path assumes a byte-string message model. This consult confirms the encoding model across the whole asl surface and answers the simplification question — what a UTF-8-only commitment lets us drop, collapse, or keep. Ordinary code-quality engineering on our own source — no target, no adversary.

## GROUND ALREADY SET (maintainer first-hand read, 2026-07-04 — state as given, confirm at source, do NOT re-derive from scratch)
A full-surface grep across `lib/libasl`, `usr.sbin/asl`, `usr.sbin/aslmanager`, and `usr.sbin/syslogd` found **zero** references to `iconv`, `setlocale`, `LC_CTYPE`, `nl_langinfo`, `mbrtowc`/`mbtowc`, `wchar`, or `MB_CUR_MAX`. Concretely:
- asl carries its **own self-contained UTF-8 validator** — `asl_is_utf8` / `asl_is_utf8_char` (`asl_util.c:45-178`), a hand-rolled byte-range DFA over the UTF-8 lead/continuation ranges — with NO dependency on libiconv or the locale/`LC_CTYPE` machinery.
- That validator is consumed narrowly: `asl_msg.c:2732` and `:2750` use it to choose, per value, an XML `<string>` tag when the bytes are valid UTF-8 vs. a base64 (`<data>`) fallback when they are not.
- Output is **byte-oriented**, driven by the encode modes `ASL_ENCODE_{NONE,SAFE,ASL(vis),XML}` (`asl.h:269-272`) and `asl_encode_buffer` (`asl.h:982`) — a byte-escaping scheme, not a charset conversion.
So the premise "asl uses the kernel libiconv + locale subsystem" appears **false at source**: asl is already locale-free and byte/UTF-8-oriented. The design question therefore is not "remove iconv" (there is none) but "given UTF-8-only, what of the existing encoding machinery collapses?"

## SCOPE — the design questions to answer
1. **Confirm the model across the full surface.** Verify the GROUND above at source and complete it: is there truly no path in libasl, the asl/syslogd daemon, aslmanager, or the store format where charset conversion, `setlocale`, or wide-char handling is relied on (including any transitive helper, the store read/write, or the client submit path)? Name anything the grep-level pass would miss (e.g. a `vis`/`strvis` call, an `isprint`-that-depends-on-locale, an 8-bit-cleanliness assumption). Characterize the model in one paragraph: what encoding asl assumes on input, what it emits, and where the only "is this UTF-8?" decision lives.
2. **What a UTF-8-only commitment lets us simplify.** Given rmxOS commits to UTF-8 everywhere, which parts of the current machinery become redundant vs. must stay? Specifically evaluate: (a) the XML-vs-base64 fallback keyed on `asl_is_utf8` (`asl_msg.c:2732/2750`) — does validation still earn its keep as an input-sanity gate, or does UTF-8-only let a value always take the string path?; (b) the four `ASL_ENCODE_*` modes — do any collapse or become no-ops?; (c) any locale-sensitive character classification (`isprint`/`iscntrl`) that could become a fixed byte-range test. State what is genuinely removable vs. what looks removable but guards a real case (e.g. embedded NULs, control bytes, non-UTF-8 input from a misbehaving logger).
3. **The keep-set — what UTF-8-only does NOT remove.** Make explicit what must remain even under UTF-8-only: the control-character / non-printable escaping for a readable log line (the `vis`/SAFE path), NUL-termination + length bookkeeping, and validation of untrusted input bytes that a client might submit ill-formed. Draw the line between "charset machinery we never had / can drop" and "byte-hygiene we must keep regardless of charset."
4. **Simplification shape + iteration-1.** Recommend the concrete minimal simplification for 1.0-preview: what to delete, what to fold, what to leave. Bucket by effort/risk. Keep it internal/changeable — do not propose a frozen encoding contract. Note any interaction with the render path (`asl_format_message`) so a later edit doesn't fight the renderer.

## DELIVERABLE
A staged design note in your own consult dir: the confirmed encoding-model characterization, the UTF-8-only simplification call (removable vs. keep-set, item by item with `asl_*.c` / `asl.h` file:line citations), and the iteration-1 simplification shape — each a **hypothesis/recommendation** bucketed by effort/risk so the maintainers can scope follow-on work. Not a product edit, not a release decision.

## BOUNDARIES
- Read + advise only; propose, do not edit; stage the note in your own dir.
- Scope is EXACTLY the text-encoding/charset model + its UTF-8-only simplification — do NOT expand into the render layout/fidelity of `asl_format_message` (a separate read covers it), the store framing, the query match `asl_msg_cmp`, or the client API matrix. No interface-shape or cross-platform comparison work.
- Treat the GROUND finding as a hypothesis to confirm at source before it drives an edit; read the actual validator/encoder body before asserting a path is removable (verify at source — prior asl reads produced a couple of claims that were already-correct-by-design).
- Treat encoding purely as **log-readability + byte-hygiene** engineering, not a hardening claim.
- Does not decide release timing or milestone placement.

## RELATIONS
The asl render path `asl_format_message` (read for FIDELITY separately — this reads the charset/encoding MODEL + simplification, fenced off from the renderer) / the store-framing and query-match single-feature asl reads / the same accepted design-note style as our recent installer/updater and concurrency-governor design consults / the asl subsystem milestone (li-1004). Every finding is a hypothesis the maintainers verify at source before it drives any edit.
