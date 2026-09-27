# li-007 — libxpc as a CORE preview service (the C-side IPC fabric)

- tier: **L1i** instruction (`li-007`). Dedicated file (promoted out of the li-002 layer-bundle because
  libxpc is big enough to warrant its own milestone). Index entry: [roadmap.md](../roadmap.md) ladder.
- promotion chain: this `li-007` decodes into IDQ item **id-021** (libxpc conformance bring-up), which
  fetches into ops (op-121 leg 1 DONE, op-122 leg 2 held, + the fill ops below).
- raised: 2026-06-24 (Coordinator elevation: "make NextBSD's libxpc and launchd work to meet our preview
  quality… they are not optional but core… get it right both libxpc and launchd").
- current closure delta (2026-07-11): op-291 did **not** accept the landed connection-lifecycle work;
  its sole cell is `HARNESS-NOT-ACCEPTED`. First-hand binary inspection found a separate public
  object-model defect: all sixteen `_xpc_type_*` tokens in accepted `libxpc.so.5` are zero-sized and
  share one address, so cross-type equality is non-discriminating. Retired op-310 accepts that
  static premise from `0ee8758` but rejects its successor-harness/validator readiness; the unsafe
  physical-host dlsym record is quarantined. op-307 returned local commit `40c8a93d`; its M-sized
  source/static-ABI gate accepts sixteen distinct one-byte tokens and correct PIE/non-PIE bindings;
  after an exact publication re-relay it is retired at clean origin-reachable `alpha@40c8a93d`.
  op-311 returned but failed Arranger intake before Validator: it substituted a C/`rc.local`
  design, print-only managed path, unsafe finalizer lifetime, incomplete census/containment, and
  fail-open Validator. Fresh op-312 returned `5fa26ee` but also failed direct intake: destructive
  fd census, no Mach/fd-identity conservation, nonfatal type mismatches, inoperative managed
  service path, disconnected isolation, synthetic shutdown, and another reproduced false-green
  Validator. No independent gate was spent. The separate isolation process is Coordinator-resolved,
  but automatic harness repair-forward is stopped after op-306/op-311/op-312; held op-308 has no
  accepted machinery pending Coordinator or the later li-1005 quality-unit review.
  Header initialization `type=4/refcount=1` was observed but is
  explicitly non-promoting. The adjacent aliased `XPC_BOOL_TRUE`/`XPC_BOOL_FALSE` singleton contract
  is banked under id-021 and excluded from op-307 because `xpc_bool_create` currently allocates
  ordinary objects; it is not a storage-only extension of the token fix.

## What this instruction means

libxpc is the **service-plane IPC fabric** for the Darwin userland — the transport beneath app-level
`xpc_connection` and beneath launchd's `xpc_domain` service hosting (see li-008). It is a **core preview
service**, no longer "classification-only pre-1.0." Bring the NextBSD libxpc (Mach-native transport +
nvlist serialization) to preview quality: connection setup/send/reply/cancel/error/lifecycle solid, and
conformance-matched to macOS behavior on the exercised surface.

**Serialization: nvlist LOCKED (Coordinator 2026-06-24).** The NextBSD FreeBSD-nvlist path is the
serializer; the ravynos-mpack fork is rejected; launchd already rides libnv. The fork is **CLOSED** — not
a pending design decision. Conformance is behavior-round-trip (not byte-for-byte wire) for the preview.

**Transport: Mach-native, already correct** (xpc_connection.c: `mach_port_allocate` RECEIVE / `MAKE_SEND`
/ `bootstrap_check_in` / `bootstrap_look_up` :121 / `DISPATCH_SOURCE_TYPE_MACH_RECV` :186). libxpc rides
exactly our Mach IPC + bootstrap/launchd + libdispatch stack — a genuine foundation exerciser, not a
skeleton (~6.3k lines, full 16-type object model).

## Divergences from Apple's libxpc (Arranger first-hand census 2026-06-24)

Method: `nx/NextBSD/lib/libxpc` (~6.3k lines, 7 `.c`). Diffed every public function declared in the
`xpc/*.h` headers (134 decls) against the function bodies actually defined in the `.c` files (119 defs).
Verify file:line before acting — source moves. Three classes of divergence:

**Class A — architectural (by design, not a bug):**
- **Serialization = FreeBSD nvlist, NOT Apple's XPC wire format** (`subr_nvlist.c`/`subr_nvpair.c`, ~4k of
  the 6.3k). Self-consistent on our stack; NOT macOS-XPC-wire-compatible. **nvlist LOCKED** (see top).
  Conformance bar = behavior round-trip, not byte-for-byte wire.
- **Control plane diverges** (launchctl→launchd rides liblaunch/Mach, not XPC unlike macOS) — see li-008.

**Class B — DECLARED in headers but ZERO `.c` implementation (15+ symbols → undefined at link/load):**
- **Activity subsystem — entirely header-only (7 fns):** `xpc_activity_register` / `unregister` /
  `copy_criteria` / `set_criteria` / `get_state` / `set_state` / `should_defer`. Full `xpc/activity.h`
  surface present + wired (`xpc/xpc.h:327`), zero impl. On macOS this is a *launchd-coordinated background
  scheduler* (system evaluates power/thermal/disk/idle criteria + static-plist `CHECK_IN`) → a real impl
  needs li-008 launchd support + FreeBSD-absent condition inputs (battery/HDD-spinning/screen-sleep). **Out
  of preview scope** (catalog as li-005 known gap unless a preview consumer needs scheduled activities).
- **Typed dictionary/array value coverage INCOMPLETE:** dictionary get/set for **double, date, data, uuid,
  fd, connection** are all unimplemented (`set_data`/`get_data` were the 2 already cataloged in id-021
  leg 1; the gap is wider). **PROGRESS: data+double FILLED op-197; date+uuid FILLED op-206 @ 7a02d29
  (date also got its silent-drop `_XPC_TYPE_DATE` serialization fixed; uuid wire serialization pre-existed).
  Remaining dict typed gaps: fd, connection.** Only **bool / string / value / mach_send / mach_recv** round-trip. Also absent:
  `xpc_dictionary_dup_fd`, `get_remote_connection`, `create_connection`, `xpc_array_create_connection`.
  Impact: a dict carrying a uuid/double/date/data/fd can't be read back via its typed accessor.
- **No shared-memory objects:** `xpc_shmem_create` / `xpc_shmem_map` absent — the large-payload transfer
  path macOS uses for big messages.
- **No standalone fd object:** `xpc_fd_create` / `xpc_fd_dup` absent.
- **No deep copy:** `xpc_copy` absent (a core object-model op).
- **No service-side runtime helpers:** `xpc_service_main`, `xpc_set_event_stream_handler` absent — the
  launchd event-stream delivery surface (iokit-matching / scheduled / file-system event streams).
- **Misc absent:** `xpc_copy_entitlements_for_pid`, `xpc_debugger_api_misuse_info`, `xpc_object_validate`,
  `xpc_unreachable`, `xpc_connection_get_egid` (euid/guid/pid/asid are present; egid is not).

**Class C — DEFINED but STUB (symbol links, body empty/partial → silent no-op, the dangerous class):**
- **`xpc_connection_cancel`** (:263) — empty `{}` no-op. Cancel does nothing.
- **`xpc_endpoint_create`** (:337) — ~~empty body with **NO return value** (UB / returns garbage)~~ **FILLED op-206 @ 7a02d29** (returns a real `_XPC_TYPE_ENDPOINT` from the connection's local port; paired with a fix to `xpc_connection_create_from_endpoint`'s bogus pointer-as-port cast).
- **`xpc_connection_set_finalizer_f`** (:330) — empty no-op (finalizer never runs).
- **`xpc_main`** (:343) — ignores the handler, just calls `dispatch_main()`.
- **`xpc_transaction_begin` / `end`** (:350/:356) — empty no-ops (no idle-exit transaction tracking).
- **`xpc_connection_get_name`** — ~~returned literal `"unknown"`~~ **FILLED op-197 @ `4983b913`**:
  retains/returns the service name for named connections and returns `NULL` for anonymous/peers;
  conformance-checked and origin-reachable. Stale duplicate id-032 retired 2026-07-11.
- **error/interruption delivery (behavioral):** no `XPC_ERROR_*` delivered anywhere — send-fail only
  `debugf` :373; recv-fail returns :411; no dead-name/no-senders/peer-death wiring → handler never sees
  CONNECTION_INTERRUPTED/INVALID/TERMINATION_IMMINENT.
- **(works ✅, for contrast):** `send_message`, `send_message_with_reply`(+`_sync`) — xc_pending
  id-correlation TAILQ + dispatch_semaphore; audit_token creds; Mach-native `bootstrap_check_in`/`look_up`.

**Also cataloged (id-021 leg 1):** `XPC_TYPE_*` macros = `&_xpc_type_*` extern-object address → FreeBSD LLD
copy-reloc from the `.so` (rx built `-fno-PIE` as corroboration).

## macOS-truth join (op-135, DONE — Arranger-verified first-hand 2026-06-24)

explorer-mx (rmx-explorer-mx-a64z) authored the macOS-27 reference from
`MacOSX.sdk/usr/lib/system/libxpc.tbd` (802 exported symbols — the shipped dylib is shared-cache-only on
macOS 27, so the `.tbd` is the linker-authoritative `nm -gU` equivalent). Evidence (rmx-explorer `ffddfce`,
Arranger-fetched + sha-checked):
`findings/mx-a64z/dtrace/xpc-conformance/macos-truth-surface.md` (sha256 `9ddf1199…34b8`) +
`libxpc-macos-exports.txt` (sha256 `5537e7bd…2d99`). The Arranger completed the per-symbol join first-hand
(grep of each Class-B/C symbol against the 802-export list — li-007 was not in the explorer repo, so the
join was done here rather than ferried):

- **Class C (historical 7-stub census) — ALL 7 are real Apple-shipped API.** The census was valid
  at its pin; `xpc_connection_get_name` was subsequently filled by op-197 at `4983b913` and is no
  longer a live gap. The remaining historical entries are `xpc_connection_cancel`,
  `xpc_endpoint_create`, `set_finalizer_f`, `xpc_main`, and `xpc_transaction_begin`/`end`, with
  their later dispositions recorded below.
- **Class B (33 declared/zero-impl) — 29 are real Apple API** (must implement for parity), **4 were listed as NOT in
  Apple's exported surface:** `xpc_debugger_api_misuse_info`, `xpc_object_validate`, `xpc_service_main`,
  `xpc_unreachable`. **CORRECTION (op-167 verify, 2026-06-27):** only `xpc_service_main` (`xpc.h:2441`) +
  `xpc_debugger_api_misuse_info` (`debug.h:21`) are actually declared/zero-impl header cruft.
  **Current-tip verification repeated at `alpha@0ccd5621`; id-031 was fetched and is now retired
  through op-295 at origin-reachable `ceb46edc` after removing exactly these two declarations.**
  `xpc_object_validate` + `xpc_unreachable` were **census errors** — no public decl exists; only internal
  `_xpc_object_validate` (inline `xpc.h:71`) + `_xpc_unreachable` (macro `base.h:99`) → legit helpers, NOT cruft.
  So the droppable set is **2, not 4**. The other 29 (activity ×7, typed dict accessors, shmem, fd, copy,
  set_event_stream_handler, get_egid, …) are real.
- **NEW — Class D: a whole API GENERATION missing.** macOS ships modern surfaces our legacy NextBSD libxpc
  has **no headers or impl** for: **`xpc_session_*` ×16** (the modern xpc_connection replacement),
  **`xpc_listener_*` ×10** (server side), **`xpc_rich_error_*`** + **`peer_requirement`**, and
  **`xpc_connection_activate`** (modern resume). Our tree is the `xpc_connection`/`resume` generation only
  (confirmed: no session.h/listener.h/rich_error.h; `resume` defined, `activate` absent). Also macOS
  `xpc_activity_*` = **20 symbols**, not the 7 in our header (missing `_defer_until_network_change`,
  `_defer_until_percentage`, `_run`, `_list`, `_add/remove_eligibility_changed_handler`, …). This is the
  largest divergence and it shapes the swift-rmxOS XPCSession/XPCListener plan (the Swift-modern API binds
  to surfaces we don't yet have).

**Bearing on preview scope:** Class C (7 stubs) + the connection-lifecycle Class-B items are the li-007
"get it right" core. Class D (modern session/listener) and the activity/shmem subsystems are **out of
preview** — catalog as li-005 known gaps; Class D is the long-tail toward the Swift-modern API, not the
developer-usable floor. The two verified declared-but-non-exported Class-B symbols are carried by
id-031→op-295; the other two historical names were census errors and are not public declarations.

**SCOPE CALL RESOLVED → REVISED ON EVIDENCE (2026-06-29, Arranger — Coordinator-delegated "you decide,
play safe"; op-211 demand-census then revised it).** The open op-189 question (does bucket-3 — real
`xpc_connection_cancel` + `XPC_ERROR_*` interruption delivery — gate the preview?) was first resolved
**YES, gates** on a get-it-right judgment; the op-211 free demand-census (rx1, Arranger-verified
first-hand) then supplied evidence that **SOFTENS it to an li-005 post-preview catalog item.** The
evidence, verified at source:
- **Supply already DONE (op-189's "empty `{}` stub" is STALE).** `xpc_connection_cancel`
  (xpc_connection.c:301-310) is a real impl — atomic-guarded → `xpc_connection_invalidate(conn,
  XPC_ERROR_CONNECTION_INVALID)`; peer-death path delivers `XPC_ERROR_CONNECTION_INTERRUPTED` (:482). op-191
  filled cancel+error AFTER op-189's inventory, op-194 verified. It is NOT a stub.
- **Zero gating demand.** Exhaustive grep (Arranger-confirmed): the ONLY caller of any bucket-3 API outside
  libxpc is `aslmanager.c:179`. **CORRECTION to op-211's classification:** it is NOT "not shipped + crashes"
  — aslmanager IS shipped + runs (op-204 fixed its startup crash; it's the asl-reclaim tool op-198 v5
  soaks). The real basis for "no demand" is that the call sits in `__attribute__((noreturn))
  xpc_server_exit()` (aslmanager.c:176-183) — `cancel(listener); release; exit(status)`, a
  teardown-before-exit that does NOT depend on cancel/error SEMANTICS (no handler observes the delivered
  error; the process dies immediately). XPC_ERROR_*/transaction/finalizer have ZERO callers anywhere.
- **Conclusion:** bucket-3 carries NO preview-blocking risk — supply implemented + op-194-verified, and the
  sole live call site can't observe a regression in it. The 4 core services run via MachServices/bootstrap,
  not via cancel/error/transaction/finalizer. The interrupted-path's reliability-under-load (it rides the
  libdispatch MACH_RECV servicing, debt #21) becomes **post-preview hardening**, NOT a preview gate.

**So: bucket-3 → li-005 post-preview catalog** (alongside shmem, standalone fd object, Class-D
session/listener, activity subsystem). **No cost-30 libxpc lifecycle fill is needed for the preview** — the
earlier "fill gated on MACH_RECV servicing" plan is obsoleted by op-191 having already landed the impl.
libxpc is effectively **preview-complete**: nvlist round-trip + Mach-transport send/reply work (op-187),
object-model typed accessors filled (op-197/op-206), cancel/error implemented (op-191/op-194) with no
gating consumer. Debt #21 MACH_RECV servicing still matters for **notifyd** (op-165) — characterize it
there, not as a libxpc preview blocker.

## Critical convergence (one fix, three consumers)

`xpc_connection_resume` creates a `DISPATCH_SOURCE_TYPE_MACH_RECV` (:186) → libxpc connection servicing
rides the **same MACH_RECV dispatch-source servicing** as notifyd (foundation debt #21). One fix serves
notifyd + libxpc + (later) Swift XPC. So libxpc connection-servicing reliability is **gated on that
dispatch sub-fix** — sequence the fill work after it.

## Get-it-right plan (depth-first, after notify/asl close their truly-green legs)

1. **Calibration probe (free Explorer, FIRST):** is launchd's `xpc_domain` service path LIVE end-to-end
   over nvlist, or stubbed? Measures how much we already have before scoping fix work. (Shared with li-008.)
2. **Conformance leg 2** (op-122, held): dual-explorer lockstep run of the pinned blob `3b6197bd…` on
   rx-x64z + mx-a64z; Arranger-diff = apples-to-apples.
3. **Fill the C-side lifecycle:** cancel (real), error/interruption delivery (dead-name/no-senders/
   peer-death), finalizer + transaction — after the MACH_RECV servicing sub-fix.

## Truly-green criterion

- nvlist object create/encode/decode round-trip + Mach-transport connection send/**reply** match macOS
  behavior (or each divergence laddered/cataloged);
- connection **cancel + error/interruption** deliver correctly (not stubs);
- the substrate harness builds + runs UNMODIFIED on both explorers (single pinned blob, shas match);
- holds under the li-004 integration soak with the li-001 invariants watching.

## op-263 seeds — reply-correlation path (Oracle consult, Arranger-verified first-hand 2026-07-07)

Consult read `xpc_connection.c` request/reply correlation; verified at source in the release base
`wip-gpt/wip-rmxos`. Mechanism is CORRECT for serial/single-threaded consumers (id alloc + wire SEQID echo
+ match-and-remove-before-handler + single wakeup, all resting on GOOD local commits over a skeletal
upstream). Two commissioned-fix candidates + hardening/conformance nits:

1. **[Q4 — commissioned, LOW effort / HIGH value] The second-epoch hang.** `xpc_connection_interrupt`
   (:477-482) gates the pending-drain on a one-shot `xc_interrupted` cmpset that is never reset; after the
   first interruption the connection stays API-usable but no send/park path re-drains — the 2nd `with_reply`
   parks, its send fails (:429), interrupt returns early (:480), the entry never drains, and `_sync` blocks
   FOREVER (:287). FIX: drain on every failed send (lift `complete_pending` out of the one-shot gate) OR
   fail-fast at park/send when `xc_interrupted`/`xc_cancelled` is set (return INTERRUPTED/INVALID, Apple
   shape). GATE on the conformance repro: kill service → sync (expect INTERRUPTED) → 2nd sync (currently hangs).
2. **[Q3 — commissioned, MED effort / low regression] Lock `xc_pending`.** The pending TAILQ is UNLOCKED and
   touched from ≥3 contexts (caller-thread INSERT :262, recv-queue REMOVE :594, drain REMOVE-all :439);
   atomics cover only flags, not list integrity. Funnel park/drain through one internal queue or a
   per-connection mutex BEFORE a multi-threaded/Swift layer lands. Removes Q2's degradation clause and most
   of Q4's race caveats.
3. **[hardening nits]** `xpc_pipe_receive` ignores the mach_msg receive status (makes the `kr` guard at
   recv_message dead code) + `xpc_unpack`'s result not NULL-checked → a malformed inbound message can poison
   the reply loop; check `malloc` at park (:258); `dispatch_release` the `_sync` semaphore (:278-288, leaks one
   per sync call).
4. **[conformance-matrix notes]** async `with_reply` handler receives the reply carrying a wire ref the library
   never releases (consumer-must-release — DIVERGES from Apple's borrow contract); `_sync`'s +1 return MATCHES
   Apple. Document before consumers assume Apple semantics.
5. **[design note on file]** id-space collision: request and event directions both allocate from independent
   counters starting at 1, so an unsolicited server→client push could be consumed as a parked request's reply
   — unreachable for canonical request/reply, becomes real when a service pushes events on a with_reply
   connection. Cheap wire-level fix (per-direction id parity or a kind flag) revisit when event-push arrives.

**Scope fence (NOT a 1.0-preview gate) — verified by consumer census, Arranger 2026-07-07.** Neither seed
gates the preview, for two DISTINCT reasons (do not conflate them):
- **Seed 2 (Q3 list lock)** bites ONLY under a multi-threaded consumer — genuinely concurrency-only → the
  Lane-B/Swift axis this li already fences as "NOT in scope" below (post-preview).
- **Seed 1 (Q4 second-epoch hang)** is SERIAL-reachable (repro is two sequential sync calls), so it is NOT a
  concurrency issue — BUT there is **no live preview consumer** of the `with_reply(_sync)` path. Census of the
  release base found the ONLY in-tree caller is `asl_trigger_aslmanager` (`lib/libasl/asl_util.c:344-359`),
  which sits in a `#if 0` DEAD block and is already superseded by op-257's external-StartInterval aslmanager
  trigger; the other two matches (tsan, krb5) are vendored contrib, not rmxOS service consumers. The path's
  first real consumer is the Lane-B Swift XPCSession/XPCListener layer (post-preview).
Both are hardening seeds owned by id-021/li-007's OWN post-preview criteria. **li-2000 (openclaw) is a
downstream CONSUMER, not a driver:** op-277 strategy-B/C would eventually exercise both gaps, so commission
them before THAT app boundary carries traffic — but li-2000 must NOT pull this (or any) scope into or gate the
1.0-preview.

## op-271 seeds — value-serialization roundtrip (Oracle consult, Arranger-verified first-hand 2026-07-10)

Consult read the `xpc_pack`/`xpc_unpack` conversion (`xpc_misc.c`) + the array/dict primitives; verified at
source in the release base `wip-gpt/wip-rmxos/lib/libxpc/`. The ten mapped types roundtrip faithfully (double
bit-exact). Findings split into an immediate fix op and two banked seeds:

1. **[op-283 FLUSHED → op-292 RETIRED — Implementer, wip-gpt, LOW effort / present-day value]
   Localized-fix bundle.** Three
   independently-safe fixes: **(a) array count bookkeeping** — `xpc_array_append_value` (`xpc_array.c:78-88`)
   inserts into the TAILQ but never increments `xo_size`, so `get_count:119` returns 0, `set_value:62` refuses
   every index, and `get_value:102` is off-by-one; add `xo->xo_size++` on append, leave count unchanged on
   replacement, and change the `get_value` guard to `>=`. **(b) `xpc_unpack` null-check** — `xpc_misc.c:128-137`
   dereferences `nvlist_unpack`'s result with no null-check (`:134`), so malformed/truncated peer bytes crash;
   return NULL cleanly on unpack failure. **(c) printf removal** — stray `printf` at `xpc_dictionary.c:251`
   pollutes launchd children's stdout. None of the three touch the leak/aliasing lifetime, so they are safe in
   isolation. **2026-07-11 execution outcome:** op-283 applied these six exact source edits and built, but its
   commissioned replacement check exposed reversed `TAILQ_INSERT_AFTER` operands in pre-existing
   `xpc_array_set_value`; strict scope excluded the correction, so no commit was delivered and op-283 was
   verified/flushed. Fresh op-292 carried the preserved three-file dirt plus the smallest complete replacement
   contract: correct operands, retain-new/release-old, and same-object no-op. **Landed 2026-07-11 at local
   product commit `0ccd5621`; Arranger2 M-gated first-hand.** Exact three-file commit, build identities, static
   allocator-junk microcheck, displaced-reference survival, same-object no-op, retained-after-caller-release,
   bounds, and count all pass. Coordinator-authorized publication made `0ccd5621` reachable from
   `origin/alpha` on 2026-07-11; op-292 retired and left the live ROB.
2. **[banked seed — MED effort, must-be-ONE-change] Leak + aliasing coupling.** `xpc_pack` (`xpc_misc.c:108-126`)
   never `nvlist_destroy`s the intermediate nvlist (leak) and `xpc_unpack` never destroys it either — BUT
   `nv2xpc` builds the returned xpc tree with keys/strings/data that ALIAS the nvlist's backing memory, and
   `xpc_object_destroy` (`:139-148`) has no nvlist handle to free. The leak is therefore LOAD-BEARING: a naive
   "add `nvlist_destroy`" = use-after-free on every aliased key/string/data. Fix must be coordinated — either
   copy-on-convert in `nv2xpc` (then free the nvlist) OR store the nvlist handle on the root xpc object and
   free it at `xpc_object_destroy`. One change, not a reflex.
3. **[banked seed — POLICY, needs a wire-semantics decision] Silent-drop set.** null / connection / endpoint /
   shmem / error values have no nvlist mapping and are silently skipped by `xpc2nv`; an FD value hard-fails the
   send; a zero-length data value poisons the WHOLE message (nvlist rejects it → `nvlist_pack` EINVAL fails the
   entire pack, not just that value). These are a fidelity-vs-wire-format decision (error vs. carry vs.
   document-as-unsupported), not a code bug to fix on reflex — decide the contract, then implement.
4. **[banked seed — container ownership/representation audit, surfaced during op-283 adjudication]
   Broader array/dictionary lifetime is not op-292.** First-hand source review found the array stores values
   through each object's single intrusive `xo_link` (so multi-container membership needs a design),
   `xpc_array_destroy` calls `xpc_object_destroy` directly rather than dropping the array's retain, and
   dictionary replacement overwrites `pair->value` without balanced retain/release. op-292 fixes only the
   indexed array-replacement contract needed by its commissioned microcheck. Census consumers and design the
   complete container-ownership correction as one later change; do not opportunistically fold it into op-292.

**Scope fence (NOT a 1.0-preview gate) — consumer census, Arranger 2026-07-10.** The serialization path has no
heavy live preview consumer: the `xpc_domain` service plane (this li's long pole) is still open, and the
launchd control plane rides liblaunch/MIG, not xpc pack/unpack. The op-283 fixes are commissioned on
PRESENT-DAY value (array-count breaks any local indexed array consumer; printf pollutes child stdout), not as a
gate. Seeds 2-4 are owned by id-021/li-007's own post-preview criteria; the first heavy pack/unpack consumer is
the Lane-B Swift XPC layer (post-preview).

## Solidity-consult finding #2 — connection object identity (Arranger-verified first-hand 2026-07-10)

The 1.0-preview solidity consult (oracle2) surfaced a SEPARATE, more serious libxpc defect than the op-271
serialization nits: **`struct xpc_connection` carries no generic object header.** Verified at source in
`wip-gpt/wip-rmxos/lib/libxpc/`: `xpc_object` begins type/flags/refcount (`xpc_internal.h:85-93`) but
`xpc_connection` begins `xc_name`/ports (`:109-136`), and `xpc_connection_create` (`xpc_connection.c:50-104`)
sets no type/refcount — yet `xpc_get_type` (`xpc_type.c:467-474`), `xpc_retain`/`xpc_release`
(`xpc_misc.c:151-176`), and `xpc_object_destroy` (`:139-149`) all cast a connection to `xpc_object` and read
type/flags/refcount from bytes that overlay the `xc_name` pointer. Consequences (source-confirmed): anon peer
→ `xpc_get_type` returns NULL not `XPC_TYPE_CONNECTION` (breaks the aslmanager accept comparison at
`aslmanager.c:1555-1603`); named conn → type byte / refcount are garbage from a heap pointer (OOB typemap
index; generic release never destroys → leak); and destroy runs no port/queue/source/block teardown.
**Runtime exposure is unproven** (aslmanager server path is managed-mode-conditional; op-206 released a stubbed
anon conn and never asked type). Routed evidence-first: **op-284** (Gatekeeper premise-probe, sizes it) →
**op-285** (RESERVED Implementer fix — one coordinated object-identity + destructor + first-message-ordering
correction, NOT a type-check patch). This is a real correctness landmine in a preview-gating service — carried
here as a live item, not a post-preview seed, pending op-284's exposure read.

## Relations

- **li-008** (launchd) — the primary consumer: launchd's service plane hosts `xpc_domain` over this fabric.
- **id-021** — the IDQ carrier (conformance bring-up).
- **id-016** (bootstrap-ambient) — libxpc is the 3rd `bootstrap_look_up` service-client after notify/asl.
- **li-002** (layer conformance) — libxpc was bundled there; promoted here. li-002 keeps the other layers.
- foundation dep: libdispatch MACH_RECV servicing (debt #21) + Mach IPC (li-001).
- **NOT in scope (Lane-B-gated):** the Swift consumer axis (XPCSession/XPCListener) — gated on rmxOS Swift
  solidity; this li is the C fabric only (the contract the Swift layer later binds to).
