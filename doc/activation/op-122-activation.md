# op-122 — Dual-Explorer lockstep: libxpc SERVICE-PLANE conformance MATCH (rx-x64z vs mx-a64z) over the op-160 live send→reply→cancel→error plane

op-122 | role: **Explorer ×2 dual-lockstep** (FREE — mx-a64z macOS-truth + rx-x64z/rx1 rmxOS) | state: READY dispatch (authorized — UN-HELD by op-160 plane-live) | parent id: id-021 (libxpc / li-1005) | authored 2026-06-26 (Arranger seat, model Opus 4)
purpose: the conformance-MATCH leg for libxpc — diff rmxOS vs macOS-truth over the service plane op-160 just made live. This is li-1005's leg-3 (MATCH) analogue to asl op-116-cont / notify op-110-cont. Plane-live (op-160) is the prerequisite; THIS proves it conforms to macOS behavior. Runs after op-160 [Done]; parallel-OK with op-159 / asl leg-4 (different pipeline).

STATE OF THE WORLD (verified first-hand, do NOT re-derive):
- The pinned op-121 harness (`findings/*/dtrace/xpc-conformance/xpc-harness.c` @ ec25e50) covers **substrate only** — xpc_object/dictionary primitives, typed get/set, hash, data, and connection lifecycle create→resume→cancel **WITHOUT a live peer**. Its own header says *"NOT: send/reply round-trip (needs a registered XPC service + live bootstrap)."*
- **macOS-truth for xpc is NOT yet captured** — `findings/mx-a64z/dtrace/xpc-conformance/` has no `.c`. The oracle is missing.
- op-160 made the send→reply→cancel→error plane LIVE (MachService-hosted xpc_connection/nvlist, launchd-job model). So the exact cases op-121 deferred are now testable. THIS op closes that gap.

DELIVERABLE — extend the pinned harness to the LIVE plane, capture macOS-truth, diff:
1. **EXTEND the pinned blob** to the plane cases op-121 deferred (keep the existing substrate cases; ADD these against a registered service + live bootstrap):
   - send→reply round-trip: client sends `{op:ping}`, receives `{reply:pong}` with the **seqid correlated** (the XPC_SEQID echo op-160 wired).
   - typed payload fidelity OVER THE WIRE: the in-scope dict types (string / int64 / uint64 / bool / array) round-trip with **identical values** through the nvlist transport.
   - cancel → XPC_ERROR delivery: cancel yields an error object; capture its **description + code**.
   - reply on a connection with no live peer vs a live peer (graceful error vs real reply).
2. **CAPTURE macOS-TRUTH FIRST (mx-a64z)** — run the extended harness against a REAL launchd-hosted XPC service on macOS; this is the ORACLE. Do NOT let rmxOS define expected. Record the macOS reply payloads + XPC_ERROR code/description as the truth blob.
3. **RUN rmxOS (rx-x64z/rx1)** the SAME byte-identical harness against the op-160 live plane via the **launchd-JOB model** (id-016 — NOT shell-launch; shell-launch gets TASK_BOOTSTRAP_PORT=0).
4. **DIFF** per-case: MATCH or DIVERGENCE (name the case + rmxOS-value vs macOS-value).

APPLES-TO-APPLES GATE (mandatory — the id-011 trap, do NOT repeat it):
- The harness blob MUST be **byte-identical** on both sides. Prove it: `git diff` the harness across the mx-a64z and rx-x64z commits is EMPTY; record BOTH commit SHAs. A FAIL-on-both is a MATCH **only** if both ran identical logic — never weaken a success criterion to manufacture a match (the asl_search count>0→r!=NULL incident).
- **macOS-as-truth**: capture macOS first, diff rmxOS against it. Least-intrusive (donor > XNU-ref > local) for any harness code.
- **BAR = BEHAVIOR, not wire.** op-160 deferred byte-for-byte wire parity to li-1008; this op conforms on observable BEHAVIOR (reply payload values, error code/description, seqid correlation, type fidelity), NOT the nvlist byte layout. State this in the verdict so a wire-format difference is NOT miscalled a divergence.

EXPECT (surface, do not paper over): rmxOS currently delivers a minimal `"Connection invalid"` string from op-160's `xpc_connection_error()`. macOS's `XPC_ERROR_CONNECTION_INVALID` has a SPECIFIC description + code. This is a LIKELY divergence → if so, name it: catalog to li-1008 (behavior-gap) OR fast-signal op-160 for a description/code fix-back. Do not assume MATCH on the error case without checking the macOS description first-hand.

PROOF BOUNDARY (Explorer authors the MATCH; does NOT self-certify the gate):
- Explorers deliver: the extended pinned harness (both SHAs), the macOS-truth blob, the rmxOS run, the per-case diff + verdict. 
- This is the MATCH leg ONLY (conformance-match = leg-3; lifecycle/traced/soak are separate). The integration SOAK (li-1007) is a SEPARATE Gatekeeper op. Do NOT claim li-1005 truly-green from a MATCH alone.

MARKERS:
```
OP122_HARNESS_EXTENDED status=0    # pinned blob extended to send/reply/cancel-error plane cases; compiles both sides
OP122_APPLES_TO_APPLES status=0    # harness byte-identical rx-x64z vs mx-a64z (git diff EMPTY; both SHAs recorded)
OP122_MACOS_TRUTH status=0         # macOS-truth oracle captured (mx-a64z) over a real launchd-hosted XPC service
OP122_RMXOS_RUN status=0           # rmxOS run over op-160 live plane via launchd-JOB (id-016), NOT shell-launch
OP122_PLANE_DIFF status=0          # per-case MATCH | DIVERGENCE(case + rmxOS-val vs macOS-val)
OP122_VERDICT status=0             # MATCH(N/N) | DIVERGENCES(list → li-1008 catalog or op-160 fix-back)
OP122_TERMINAL status=0
```

PUSH: dual-explorer branches (the extended harness + macOS-truth blob + rmxOS run + diff). Report → **Arranger-seat first-hand verify** the apples-to-apples diff (both SHAs, empty harness diff) + any DIVERGENCE checked against the macOS header/source before it drives a catalog or fix-back (id-011/id-021 explorer-claim history) → if MATCH, libxpc conformance leg closes; if divergence on the error case, fold the description/code fix into op-160. Do NOT merge. MATCH artifact only — the soak (li-1007) gates truly-green separately.

CHAIN (li-1005 libxpc → preview): op-160 (plane live) → **op-122 (this — conformance MATCH, dual-explorer)** ∥ li-1007 integration soak (Gatekeeper) → li-1005 + li-1006 truly-green → with li-1003/notify (post id-025) + li-1004/asl (post leg-4) → li-1000 1.0-preview.

---

## AUTHORSHIP CLARIFICATION (2026-06-26, Arranger seat, model Opus 4) — resolves "who authors the byte-identical blob?"

Decision: **rx-x64z AUTHORS the plane extension; mx-a64z captures macOS-truth on the byte-identical blob** (option 1 + a mandatory record-don't-assert refinement). Rationale: the blob must LINK on both sides; the binding constraint is the smaller/less-certain surface = rmxOS post-op-160. Author from the side that cannot guess the other's surface (macOS is a superset → anything rx links, mm4 links). Matches the op-116-cont precedent. Authoring from the superset (assuming `XPC_ERROR_CONNECTION_INVALID` links on rmxOS) is the rework trap — rejected.

MANDATORY harness rule (folds in the smart half of the mx "draft" option, avoids a double round-trip):
- **ASSERT** only on the safe, expected-MATCH cases: send→reply payload, `XPC_SEQID` correlation, typed round-trip VALUES (string/int64/uint64/bool/array).
- **RECORD (do not assert a form)** on the cancel/error case and any case where divergence is expected: emit the observed value, e.g. `printf("cancel_error_description: %s\n", desc)` — NOT `R("error_is_connection_invalid", strcmp(...)==0)`. The rmxOS `"Connection invalid"` vs macOS `XPC_ERROR_CONNECTION_INVALID` delta is computed by DIFFING the two captured truth blobs, not baked into a harness pass/fail. This keeps the blob byte-identical AND divergence-safe in one pass (no "mx drafts → rx adjusts → mx re-captures" loop).
- rx authors to the rmxOS-LINKABLE INTERSECTION. If a case needs a symbol rmxOS lacks, that absence IS a divergence → catalog to li-1008, do NOT include the symbol (it would break the link / force a non-identical blob).
- macOS hosting = a user **LaunchAgent** echo service (`launchctl bootout` after); the plist stays macOS-faithful per the standing launchd-plist-fidelity directive.

Net: rx guarantees the link (option 1) + the error case is divergence-safe (option 2's good idea) with no extra round-trip. Apples-to-apples unchanged: both SHAs recorded, `git diff` of the harness EMPTY.
