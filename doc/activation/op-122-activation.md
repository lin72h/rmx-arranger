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

---

## ARRANGER-SEAT VERDICT (2026-06-26, model Opus 4) — rmxOS-side report REJECTED for harness miscalibration; HALT macOS-truth capture; fix-back required

Verified first-hand against rmx-explorer branch (`xpc-harness-plane.c` @ SHA c54e5261, commit bff9627), NOT relayed. id-011's false-divergence history made me read the actual send→reply target before letting "Expected divergence vs macOS" stand.

**FINDING — the send→reply "FAIL" is NOT a plane result and NOT a divergence. It is a harness-target error.** Two first-hand confirmations:

1. **Wrong service target.** `xpc-harness-plane.c:117`: `xpc_connection_create("com.apple.system.logger", NULL)`. That is the **ASL syslogd Mach service**, NOT an `xpc_connection` echo endpoint. The harness's own comment (lines 109-110) admits "Available on macOS; may or may not be registered on rmxOS" — then the report labels the resulting `kr=22 (EINVAL)` "Expected divergence vs macOS." This is the exact id-011 false-divergence trap: an uncertain target's failure miscast as a behavior divergence. `com.apple.system.logger` is not a generic XPC echo responder on macOS *either* — sending an `{op:ping}` dict and expecting `{reply:pong}` is not its protocol. So the case would mis-FAIL or mis-behave on BOTH sides for reasons unrelated to the plane.

2. **No companion responder authored.** `git show --stat bff9627` adds ONLY `xpc-harness-plane.c` (+ compiled binary + serial + findings md). There is **no service `.c` and no service plist**. The harness is the CLIENT half only. op-160's *proven* live plane used `org.rmxos.op160.xpc-service` WITH a companion `op160-xpc-service.c` echo responder + `com.rmxos.op160.xpc-service.plist`. op-122 never exercised op-160's live plane — it pointed a lone client at an unrelated daemon.

**CONSEQUENCE for the markers as reported:**
- `OP122_RMXOS_RUN` — the send→reply, cancel→error, and "typed payload OVER THE WIRE" plane cases did NOT run against the op-160 plane. The "typed payload: ALL PASS" is **local dict accessors** (the wire send returned EINVAL, so nothing crossed the transport — that PASS proves substrate, already covered by op-121, not wire fidelity). The cancel "event handler didn't fire within 1s" ran against an already-broken connection → uninterpretable, NOT a cancel-semantics finding.
- `OP122_APPLES_TO_APPLES status=0` is premature: byte-identical is necessary but the blob must exercise the *right* plane first. A byte-identical wrong-target harness is apples-to-apples on the wrong fruit.
- Substrate 14 PASS = fine, no regression (it re-runs op-121's covered surface).

**DISPOSITION:** rmxOS-side report **REJECTED as a conformance artifact** (no fault to the run mechanics — the harness DESIGN is wrong). **HALT mx-a64z macOS-truth capture on this harness** — capturing truth for `com.apple.system.logger` ping/pong would burn a cycle and risk cataloging an EINVAL that is a harness error, not an rmxOS gap.

**FIX-BACK (rx-x64z, before any truth capture):**
- The harness MUST include a **companion echo SERVICE** (responder) registered under a test name (e.g. `com.rmxos.op122.echo` / macOS-side a matching LaunchAgent label), loaded as a **launchd-JOB** on each side (id-016 — not shell-launch). The client half connects to THAT, sends `{op:ping}`, expects `{reply:pong}` with the `XPC_SEQID` echo. This mirrors op-160's proven `org.rmxos.op160.xpc-service` + responder pattern — reuse it, do not re-invent.
- Keep the ASSERT/RECORD split already decided (ASSERT send→reply payload + seqid + typed values; RECORD-don't-assert the cancel/error description).
- Plist for the echo service stays **macOS-plist-faithful** per the standing directive (Label, ProgramArguments, MachServices; `com.rmxos.op122.echo` label is a fine fixture name — the directive is about FORMAT/keys, not the label string).

**REAL rmxOS SURFACE GAP worth keeping (not a false one):** the `_XPC_TYPE_ERROR` copy-relocation issue on rmxOS LLD (harness lines 64/169/285-286 — can't reference the type-identity constant directly) is a GENUINE rmxOS toolchain/surface gap (consistent with op-121's `_XPC_TYPE_*` copy-reloc finding). Catalog to **li-1008** as a real divergence; the harness work-around (avoid referencing the constant) is correct.

**MARKER DISPOSITION (mine):** HARNESS_EXTENDED FAIL(wrong target + no responder) · APPLES_TO_APPLES HELD(premature) · RMXOS_RUN REJECTED(plane not exercised) · MACOS_TRUTH HALTED(do not capture on this harness) · PLANE_DIFF N/A · VERDICT **FIX-BACK** · TERMINAL not reached.

**op-122 → stays [In-flight], reverts to fix-back** (harness re-author at rx-x64z; mx-a64z capture HELD until the corrected harness lands). Not a divergence, not a MATCH — a harness correction. li-1005 libxpc conformance leg remains OPEN.

---

## RESPONDER CONTRACT (2026-06-26, Arranger seat, model Opus 4) — locked so rx and mx do NOT improvise two divergent echo services

Forced by the mx-a64z hold note (its Task #54 plans to author a macOS echo service independently). A byte-identical CLIENT pointed at two independently-authored RESPONDERS reintroduces the false-divergence risk just rejected. The responder behavior is therefore SPEC'd here once; both sides build to it. Reuse op-160's proven `op160-xpc-service.c` pattern — do not re-invent.

**Identity rule (the apples-to-apples line for this op):**
- **CLIENT (the harness) = BYTE-IDENTICAL** both sides. `git diff` of the client `.c` across the rx-x64z and mx-a64z commits is EMPTY; both SHAs recorded. (Unchanged from the original gate.)
- **RESPONDER (the echo service) = BEHAVIOR-IDENTICAL**, source MAY differ for build glue. The fixed contract below is what makes the responders equivalent; neither side may add/drop a key or change the protocol.

**Shared service name (ONE string, hardcoded in the byte-identical client → both responders MUST register exactly this):** `com.rmxos.op122.echo`
- macOS: a user **LaunchAgent** with `MachServices` key `com.rmxos.op122.echo` (= true); `launchctl bootout` after.
- rmxOS: a **launchd-job** (id-016, NOT shell-launch) with `MachServices` `com.rmxos.op122.echo`.
- Plist FORMAT macOS-faithful per standing directive (`Label`, `ProgramArguments`, `MachServices`); the `com.rmxos.op122.echo` label string is a fine fixture name.

**Protocol (request → reply):**
- Client sends a dict: `{ "op": "ping", "seqid": <unique uint64>, <typed-fidelity fields> }`.
- Responder builds its reply with `xpc_dictionary_create_reply()` (the op-160 path that requires `_XPC_FROM_WIRE`), sets `{ "reply": "pong" }`, **echoes the request `XPC_SEQID`** (the op-160 seqid mechanism), and **echoes every typed-fidelity field verbatim**.
- Typed-fidelity fields (the in-scope dict types, echoed value-for-value): `string` / `int64` / `uint64` / `bool` / `array`.

**ASSERT vs RECORD (unchanged, restated for the responder):**
- Client **ASSERTs**: `reply=="pong"`, `seqid` echoed == sent, each typed field round-trips identical value.
- Client **RECORDs-does-not-assert** the cancel→error case: `printf` the observed error `description` + `code`; the rmxOS `"Connection invalid"` vs macOS `XPC_ERROR_CONNECTION_INVALID` delta is computed by DIFFING the two captured truth blobs, never baked into a harness pass/fail.

**AUTHORING SPLIT under this contract:**
- **rx-x64z**: authors the byte-identical CLIENT + the **rmxOS responder** (re-point op-160's `op160-xpc-service.c` to `com.rmxos.op122.echo`, extend it to echo the typed fields), loads both as launchd-jobs, runs, REPORTs. This is the fix-back.
- **mx-a64z**: authors the **macOS responder LaunchAgent** to THIS contract — **may start NOW** (de-coupled from the client blob; the contract is fixed). On blob-landing: pull the canonical client `.c`, load the macOS responder, run the client UNMODIFIED, capture macOS-truth (error case recorded-not-asserted), `launchctl bootout`, commit (author lin), REPORT.

**`_XPC_TYPE_ERROR` copy-relocation (rmxOS LLD):** real surface gap → **li-1008** (already noted above). Client work-around (avoid referencing the type-identity constant directly) is correct and stays in the byte-identical blob, so it is benign on macOS too.

Net: one client, one contract, two responders that cannot diverge by construction. mx's responder authoring decouples from the blob; only the run + truth-capture waits on rx's landing.

---

## FIX-BACK DISPATCH BRIEF — rx-x64z (normal-form, 2026-06-26, Arranger seat, model Opus 4)

role: **Explorer (FREE — rx1/rmx-explorer)** | state: READY dispatch (authorized) | parent id-021 (libxpc / li-1005) | supersedes the REJECTED rmxOS-side run above
why: the prior run pointed a lone client at `com.apple.system.logger` (ASL daemon, not an XPC echo endpoint) with no responder → op-160's live plane was never exercised; the EINVAL was a harness-target error miscast as a divergence. This re-authors to the LOCKED RESPONDER CONTRACT above so the run actually crosses op-160's plane.

DELIVER (rx-x64z owns BOTH halves on the rmxOS side):
1. **rmxOS responder** — re-point op-160's `op160-xpc-service.c` to register `com.rmxos.op122.echo` via `MachServices`; extend its handler to reply `{reply:pong}` with the request `XPC_SEQID` echoed and every typed field (string/int64/uint64/bool/array) echoed verbatim. launchd-job plist, macOS-faithful FORMAT. NOT shell-launch (id-016).
2. **byte-identical CLIENT** — fix the existing `xpc-harness-plane.c`: change the Plane Case 1 target from `com.apple.system.logger` to `com.rmxos.op122.echo`; keep the substrate cases unchanged; ASSERT reply=="pong" + seqid-echo + each typed value; RECORD-don't-assert the cancel→error (printf description+code, NO strcmp-assert of any error constant). Keep the `_XPC_TYPE_ERROR` copy-reloc work-around (benign on macOS too).
3. **run** both as launchd-jobs over op-160's live plane; confirm the client reaches the responder via its launchd-provided bootstrap (id-016). Capture serial.
4. **REPORT** — the rmxOS run + the client `.c` SHA (this becomes the canonical blob mx pulls). Do NOT self-diff against macOS (mx holds the oracle); RECORD the rmxOS cancel error string, don't classify it.

GATES: client byte-identical-ready (mx will run the SAME `.c` unmodified — no rmxOS-only `#ifdef` in the client that mx can't compile; if a symbol is rmxOS-absent, that absence is the divergence → catalog li-1008, do NOT branch the client). Responder behavior to the locked contract, source-glue may differ. Substrate cases must still PASS (no regression).

MARKERS (re-run):
```
OP122_RESPONDER_RMXOS status=0     # rmxOS echo service registers com.rmxos.op122.echo; replies pong+seqid+typed echo
OP122_HARNESS_RETARGETED status=0  # client Plane Case 1 -> com.rmxos.op122.echo; substrate unchanged; compiles
OP122_RMXOS_PLANE_RUN status=0     # client reaches responder over op-160 plane via launchd-job bootstrap (id-016)
OP122_CLIENT_SHA recorded          # canonical byte-identical client .c SHA (mx pulls this exact blob)
OP122_RMXOS_CANCEL_RECORDED        # cancel error description+code printed (recorded, NOT asserted)
OP122_TERMINAL status=0
```

PUSH: rx branch (responder .c + plist + retargeted client + serial). Report → Arranger-seat first-hand verify the client actually hit the responder (serial shows pong+seqid, not EINVAL) + the client `.c` is mx-compilable (no rmxOS-only client branch) → release the CLIENT_SHA to mx-a64z #54b for macOS-truth capture. Do NOT merge. The apples-to-apples diff happens after mx captures truth on this exact SHA.
