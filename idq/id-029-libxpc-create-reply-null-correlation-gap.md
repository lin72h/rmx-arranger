# id-029 — libxpc: `xpc_dictionary_create_reply` returns NULL at runtime → XPC request-reply correlation broken (`send_message_with_reply_sync` blocks)

- id: id-029
- state: **OPEN — REAL runtime gap, Arranger-verified first-hand (op-122 fix-back @ rmx-explorer `a41c8ce`, 2026-06-27).** Substantive (core XPC request-reply pattern), distinct from the cosmetic items already under li-1008. Likely BLOCKS libxpc truly-green (id-021/li-007) for the 1.0-preview — Coordinator owns the li-1008-split-vs-new-li cataloging call + the preview-scope impact.
- raised: 2026-06-27 (op-122 rx-x64z fix-back; Arranger-verified against the committed blob + serial).
- roadmap parent: **li-007** (libxpc core preview service); sibling defect of id-021 (libxpc conformance bring-up).

## The gap (Arranger-verified first-hand from op-122 @ a41c8ce)

op-122 ran the byte-identical XPC client (`xpc-harness-plane.c`, sha256 `34a9cac9…`, target `com.rmxos.op122.echo`) against a launchd-job echo responder over op-160's live service plane. From the serial:

- **Plane IS live (bidirectional):** client `xpc_send` (id=1) → responder `recv_message … new peer on port <28>` → `OP122_ECHO_PEER status=0`. Responder unpacks the 196B request; client unpacks the 20B response. Messages cross both ways.
- **The break:** the responder's `xpc_dictionary_create_reply()` returns **NULL** at runtime (`OP122_ECHO_REPLY status=1 reason=create_reply_null_fallback`). The symbol EXISTS in `libxpc.so.5` (@ `0x12d30`) — it is present but returns NULL. The responder fell back to sending a FRESH dict via `xpc_connection_send_message`.
- **Consequence:** the client used `xpc_connection_send_message_with_reply_sync`, which needs a **correlated** reply (reply-context metadata that `create_reply` would have set up). The fallback fresh dict arrived on the connection's event-handler path, NOT the reply-correlation path → `…_with_reply_sync` **blocked indefinitely** (no `reply_valid`/`seqid_correlation`/pong assertion ever fired; the run was torn down at uptime 30s).

So: **XPC message DELIVERY works, but the reply-ROUTING/correlation mechanism is broken** — `xpc_dictionary_create_reply` does not set up the correlation metadata. Request-reply (the central XPC pattern) does not complete on rmxOS.

## Why this matters for the preview (Arranger flag — Coordinator decides)

- request-reply (`send_message_with_reply` / `_sync`) is the **core** XPC interaction, not an edge case. A daemon answering a client query relies on it.
- This likely **blocks id-021 libxpc truly-green** for the 1.0-preview: the truly-green criterion includes "Mach-transport connection send/**reply** match macOS truth." A blocking reply path cannot match.
- **li-1008 is being overloaded.** It currently holds cosmetic libxpc items (`_XPC_TYPE_ERROR` copy-relocation; op-160 wire byte-parity deferral). This correlation gap is a different, load-bearing class. Coordinator call: split it out (this id-029, or a dedicated li) vs fold into li-1008.

## Fix shape (when promoted — observation-first ladder)
- **Locate** where `xpc_dictionary_create_reply` returns NULL: `lib/libxpc/` (the reply-construction + correlation path; the serial points at `xpc_misc.c:458` unpack + the reply dict creation). Determine whether it's (a) a missing reply-context/connection-association on the incoming message object, or (b) an unimplemented stub returning NULL.
- **Cross-check macOS truth (op-122 mx-a64z, pending):** the SAME client blob on macOS with a contract-path responder (`xpc_dictionary_create_reply`) is expected to COMPLETE the round-trip (pong + seqid echo + typed echo). That diff pins the exact divergence and the macOS-faithful target behavior.
- Then a `lib/libxpc` fix op (Implementer or Explorer-authored fix-on-inspection) to wire the reply correlation; re-run op-122's client unmodified → round-trip must complete.

## Relations
- **id-021 / li-007** (libxpc conformance bring-up) — this is the headline divergence its leg-2 conformance run surfaced; likely gates its truly-green.
- **op-122** (dual-explorer libxpc plane conformance) — the carrier that found it; rx side [Done] @ `a41c8ce`, mx macOS-truth capture pending (will quantify the divergence).
- **op-160** (libxpc live service plane) — the plane this rides; op-160 proved delivery works, op-122 found reply-correlation does not.
- **li-1008** (libxpc catalog) — currently holds the cosmetic XPC items; Coordinator to decide split vs fold.
