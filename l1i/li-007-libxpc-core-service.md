# li-007 — libxpc as a CORE preview service (the C-side IPC fabric)

- tier: **L1i** instruction (`li-007`). Dedicated file (promoted out of the li-002 layer-bundle because
  libxpc is big enough to warrant its own milestone). Index entry: [roadmap.md](../roadmap.md) ladder.
- promotion chain: this `li-007` decodes into IDQ item **id-021** (libxpc conformance bring-up), which
  fetches into ops (op-121 leg 1 DONE, op-122 leg 2 held, + the fill ops below).
- raised: 2026-06-24 (Coordinator elevation: "make NextBSD's libxpc and launchd work to meet our preview
  quality… they are not optional but core… get it right both libxpc and launchd").

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
  leg 1; the gap is wider). Only **bool / string / value / mach_send / mach_recv** round-trip. Also absent:
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
- **`xpc_endpoint_create`** (:337) — empty body with **NO return value** (UB / returns garbage).
- **`xpc_connection_set_finalizer_f`** (:330) — empty no-op (finalizer never runs).
- **`xpc_main`** (:343) — ignores the handler, just calls `dispatch_main()`.
- **`xpc_transaction_begin` / `end`** (:350/:356) — empty no-ops (no idle-exit transaction tracking).
- **`xpc_connection_get_name`** (:269) — returns the literal string `"unknown"`.
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

- **Class C (7 stubs) — ALL 7 are real Apple-shipped API** → every rmxOS stub is a genuine behavioral parity
  gap that must be filled: `xpc_connection_cancel`, `xpc_endpoint_create`, `set_finalizer_f`, `xpc_main`,
  `xpc_transaction_begin`/`end`, `xpc_connection_get_name`.
- **Class B (33 declared/zero-impl) — 29 are real Apple API** (must implement for parity), **4 are NOT in
  Apple's exported surface:** `xpc_debugger_api_misuse_info`, `xpc_object_validate`, `xpc_service_main`,
  `xpc_unreachable`. These are likely macros/inlines or NextBSD-local header cruft (the `.tbd` lists exported
  symbols, not macros) → **not a link-level parity gap**; cheap header-level confirm deferred. The other 29
  (activity ×7, typed dict accessors, shmem, fd, copy, set_event_stream_handler, get_egid, …) are real.
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
developer-usable floor. The 4 non-exported Class-B symbols are candidates to drop from our headers.

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

## Relations

- **li-008** (launchd) — the primary consumer: launchd's service plane hosts `xpc_domain` over this fabric.
- **id-021** — the IDQ carrier (conformance bring-up).
- **id-016** (bootstrap-ambient) — libxpc is the 3rd `bootstrap_look_up` service-client after notify/asl.
- **li-002** (layer conformance) — libxpc was bundled there; promoted here. li-002 keeps the other layers.
- foundation dep: libdispatch MACH_RECV servicing (debt #21) + Mach IPC (li-001).
- **NOT in scope (Lane-B-gated):** the Swift consumer axis (XPCSession/XPCListener) — gated on rmxOS Swift
  solidity; this li is the C fabric only (the contract the Swift layer later binds to).
