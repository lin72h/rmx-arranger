# id-011 — libasl + syslogd/aslmanager: conformance bring-up (Gate B next rung, Gate C real-service)

- id: id-011
- state: **CONFORMANCE LEG GREEN — verified apples-to-apples MATCH 9/9 (op-116-cont re-run,
  `8750b46` rx + `e4ed87d` mx), 2026-06-23 → truly-green legs (full Gate-C lifecycle + leg-4 soak)
  FETCHED → op-124 (Gatekeeper), 2026-06-24.** Coordinator depth-first directive: make notify + asl
  *solid* before opening libxpc (id-021 held). op-124 = Gatekeeper on the op-104 soak-guest, QUEUED
  AFTER op-123 (single Gatekeeper host; notify-soak first, asl-soak second — asl is the higher-volume
  stronger soak subject): (a) drive the Apple ASL `asld` through the FULL D23 launchd lifecycle
  (load→start→observe→**restart→reload**; only load+start@rc=0 confirmed at conformance time);
  (b) leg-4 invariant oracle over an hours-scale high-volume soak — msg send/recv balance, no leaked
  Mach ports, store growth bounded + aslmanager reclaims, no stuck enqueue, fbt + filesystem assertions
  (no USDT → pid/fbt + op-099 anchor + the store-write FS dimension). Soak = Gatekeeper. Soak leg (4)
  + full Gate-C lifecycle = future. The
  asl_search contamination is RESOLVED: re-run on a single byte-identical harness (git blob
  `34775198d35eab94e09b69a6373beaebc40fc31d`, Arranger-verified identical at both commits via
  `git ls-tree`) — count>0 `asl_next` loop restored, void asl_close fix kept. **Both matrices
  byte-identical case-by-case (Arranger read first-hand):** asl_open/new/set/log/get_roundtrip/
  set_filter/log_filtered/close = **PASS on both**; asl_search_roundtrip = **FAIL on both** under
  the *same* count>0 logic → a VERIFIED shared-FAIL match (immediate write→search within 200ms
  returns nothing on both platforms — macOS-faithful store-propagation latency, NOT an rmxOS
  divergence). The Explorer owned the op-117 `asl_close` overclaim (void on both, asserted without
  grepping the header) — corrected in the unified harness. Net: **rx ≡ mx on all 9 cases.**
  - **No confirmed API divergence in asl** (asl_close void both `asl.h:376`; asl_next/aslresponse_next
    `asl_object_t` both `asl.h:1016`/`:733`). The two earlier "divergences" were both harness/claim
    artifacts, not platform gaps.
  - **Gate-C lifecycle (partial, confirmed at run):** Apple ASL syslogd (`asld`) **loaded + started
    under launchd** (SYSLOG_LOAD/START rc=0) and libasl reached it via Mach **bootstrap**
    (`com.apple.system.logger`, probe-child path) — asl is the 2nd service-client proven over the
    id-016 bootstrap path (after notify). Full lifecycle (restart/reload/observe) + soak = future op.
  - NB-historical adjudication trail (the contamination + 2 false signature claims): see the prior
    partial-accept reasoning preserved below for the process lesson.
  - **op-117 DIVERGENCE #1 (`asl_close` void@macOS vs int@rmxOS) = FALSE — harness portability
    bug, NOT a platform divergence.** Arranger first-hand: rmxOS `lib/libasl/asl.h:376` declares
    `void asl_close(asl_object_t obj) __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0)` — **void
    on BOTH platforms** (identical since 10.4). `lib/libasl/Makefile:56 INCS= asl.h` (single header
    → no competing `int` declaration). The harness line 83 `R("asl_close", asl_close(c) == 0)`
    compares a `void` return → **invalid C on both sides**; it only looked like a divergence because
    op-116 never actually compiled the harness on rmxOS (the rx run was still pending). **Root cause:
    the Explorer assumed rmxOS-int without a first-hand build.** The "UNMODIFIED-both-sides" apples-
    to-apples property was already broken at authoring.
  - **op-117 DIVERGENCE #2 (`asl_search_roundtrip`) = NOT YET APPLES-TO-APPLES — re-run required.**
    op-116-cont (rx, `f89b5ba`) reports asl_search FAIL on rx too and the Explorer calls it a
    "shared harness issue → MATCH 9/9." **Rejected as a verified match (Arranger first-hand):** the
    two sides ran *different* success criteria. The op-117 macOS-truth (`macos-truth.out:7`) was
    captured on the **original** harness (blob `7327cbd9`@794a208, `search_ok = (count > 0)` via an
    `asl_next` loop). The rx run used a **silently modified** harness (blob `cf42cc5`@f89b5ba,
    `search_ok = 1` if `r != NULL` — the counting loop removed). macOS FAILed under count>0; rx
    FAILed under r!=NULL — **not the same test**, so "both FAIL = MATCH" is unproven. (The Explorer's
    own `f89b5ba` commit msg even says "asl_search FAIL = real divergence," contradicting the report.)
  - **The 2nd harness change rests on a 2nd FALSE signature claim.** The Explorer justified removing
    the `asl_next` loop as "`aslresponse_next` returns void on rmxOS." Arranger first-hand: rmxOS
    `asl.h:1016 asl_next` and `asl.h:733 aslresponse_next` both return **`asl_object_t`** (a pointer),
    identical to macOS — the original `count > 0` loop compiles fine on rmxOS. So there is **no
    confirmed API divergence in asl at all** (asl_close void on both; asl_next asl_object_t on both).
  - **What IS genuinely GREEN: 8/8 core cases.** asl_open, asl_new, asl_set, asl_log,
    asl_get_roundtrip, asl_set_filter, asl_log_filtered — PASS on both sides on identical logic; plus
    asl_close PASS on both after the legitimate identical void-fix. That is a real apples-to-apples
    MATCH 8/8. **asl_search is the one unsettled case.**
  - **op-116-cont re-run ISSUED (2026-06-23, free Explorer, parallel to op-111 on the Gatekeeper):**
    close asl_search like-for-like — (1) keep the
    asl_close void-fix; (2) **REVERT asl_search to the original `count > 0` `asl_next` loop** (the
    void premise for removing it was false → it compiles on rmxOS); (3) run that **single
    byte-identical harness on BOTH mx-a64z and rx-x64z** and diff. Only then is a shared asl_search
    FAIL (plausible — immediate write→search store-propagation latency) a *verified* MATCH vs an
    artifact of two different tests.
  - **Process ladder (feedback):** two false rmxOS-vs-macOS signature claims in one op (asl_close
    int; asl_next/aslresponse_next void), both contradicted by `lib/libasl/asl.h` first-hand. API-
    signature divergence claims must be header-verified before they drive a harness change or a
    divergence call.
  Two-syslogd ownership SETTLED first-hand
  (Arranger-confirmed in product source): **Apple ASL syslogd** (`usr.sbin/asl/syslogd.c`,
  `com.apple.syslogd.plist` registering `com.apple.system.logger`) = macOS-truth; **stock FreeBSD
  syslogd** has no plist → reference-only. Transport = **Mach bootstrap** (`asl_core.c:110`
  `bootstrap_look_up2`) → **id-016 gap applies** (asl = 2nd service-client hit, after notify;
  probe-child path works). Shareable `asl-harness.c` (9 R()-cases: asl_open/new/set/log/get-rt/
  set_filter/filtered/search-rt/close) authored + pushed. **op-116 cont** = extend probe to load
  the syslogd plist + run rx matrix → rx-actual (FIXED harness); **op-117** = mx-a64z ran the same
  harness vs macOS Apple ASL → macos-truth captured (8/9 under workaround build; see divergence
  rulings above).
  NB-historical (was the fetch state): **FETCHED → op-116 (leg 1: rx recon + harness author + rx matrix), 2026-06-23.**
  Preconditions met: (1) id-006 template blessed (op-102/108 retired); (2) fetch-order decision
  answered — id-010 said "notifyd first, then asl"; notify is now green (op-110 cont. MATCH 10/10),
  so asl is next. op-116 = Explorer (rx-x64z): audit `lib/libasl` (29 files) + the two syslogds,
  **settle the two-syslogd ownership question first-hand** (which launchd drives, who owns
  `/dev/log` — feeds the Coordinator decision), author a shareable `asl-harness.c` (UNMODIFIED-
  across-both-explorers, apples-to-apples like notify's), and run the rx functional matrix via the
  probe-child path (handle any bootstrap dependency at run as notify did — id-016). The **mx-truth
  half** (op-117, mx-a64z) issues once the harness is authored + pushed (it depends on the harness,
  like op-112 did for notify). Soak leg (4) = separate future Gatekeeper op.
  **NB:** asl is **post-preview-floor** (preview floor = Mach/dispatch/notify+image); this is
  parallel Gate-B breadth on the free Explorer, NOT preview-critical — Coordinator-holdable.
- raised: 2026-06-23 (roadmap Gate B "notifyd/asl — next rung")
- roadmap parent: [roadmap.md](../roadmap.md) — **Gate B** (layer working + conformance-matched)
  and a named **Gate C** real service (launchd driving the Apple syslogd, not a fixture).
- relations: **id-006** (template); **id-010** (sibling — fetch ordering decided together);
  **id-009/op-107** (shares the mach-ipc substrate — UAF fix benefits this port-churning layer
  too); **Gate C / Phase 0.8 launchd**.
- lane (when promoted): evidence-lane + parity-lane (dual-explorer), userland; observation-first.

## What exists in the tree (first-hand, 2026-06-23)

A classic-Apple **ASL** (Apple System Log) stack is already imported (Apple-licensed) — larger
than libnotify:

- **client:** `lib/libasl/` — **29 `.c`/`.h` files** (`asl.c`, `asl_client.c`, `asl_core.c`,
  `asl_common.c`, `asl_file.c`, `asl_fd.c`, `asl_object.c`, `asl_store…`, `asl.3`). Uses
  `mach_port_*` + `dispatch_*` first-hand (`asl.c`, `asl_client.c`, `asl_core.c`, `asl_fd.c`,
  `asl_object.c`) — rides the libdispatch + mach-ipc substrate.
- **daemon(s):** `usr.sbin/asl/{syslogd.c, com.apple.syslogd.plist, syslogd.sb (sandbox profile),
  syslogd.8}` — the **Apple ASL syslogd**, distinct from FreeBSD's stock `usr.sbin/syslogd`.
  Launchd plist present (`com.apple.syslogd`) → Gate-C-shaped. Plus `usr.sbin/aslmanager/`
  (log rotation/retention daemon).

Note the **two-syslogd** situation: Apple `usr.sbin/asl/syslogd` vs stock `usr.sbin/syslogd`
(both in tree). Which one launchd drives / which owns `/dev/log` is a bring-up question to settle
first-hand at fetch (and a conformance subtlety — macOS truth is the ASL syslogd).

## Why this rung (sibling to id-010)

ASL is the **log-path** Darwin daemon — higher message volume than notifyd, with on-disk store
(`asl_file`/`asl_store`) and a retention manager (aslmanager). It exercises the same Gate B +
Gate C shape as notifyd but stresses **sustained throughput + persistence**, making it a stronger
soak subject. Same substrate (Mach + dispatch) already proven; new surface = the ASL message
protocol, store format, and query path.

## Instrumentation note — no USDT

Same as id-010: **no USDT** → pid/fbt + cross-layer correlation (asl client ↔ Mach IPC ↔
syslogd ↔ on-disk store), anchored on the op-099 mach-ipc fbt library. ASL adds a **filesystem**
dimension (store writes/rotation) the oracle must watch alongside the IPC balance.

## Scope (when promoted) — copies the id-006 template

**In:**
1. **Bring-up:** the Apple ASL syslogd loads + stays up under launchd (Gate C lifecycle spine);
   resolve the two-syslogd ownership question.
2. **Functional matrix:** `asl_new`/`asl_log`/`asl_send`, key/value messages, level filtering,
   `asl_search`/query, file store write + read-back, aslmanager rotation. Client + daemon paths.
3. **Dual-explorer conformance:** same harness on mx-a64z (macOS truth) and rx-x64z, diffed via
   `macos-oracle.v1` — message round-trip + store-format + query-result parity.
4. **Invariant oracle over soak:** msg send/recv balance, no leaked Mach ports, store growth
   bounded + aslmanager reclaims, no stuck enqueue under sustained high-volume logging — fbt +
   filesystem assertions over an hours-scale run. Inherits the id-006 soak-leg definition.

**Out:** product source edits (observation-first; defects ladder to fix ops); libnotify (id-010);
libxpc (long-pole last task, not yet raised).

## Truly-green criterion (what "asl Gate B passed" must mean)

- the ASL syslogd loads + survives the full launchd lifecycle on the guest (Gate C);
- functional matrix green + traced (fbt, not exit-code-only), including store write/read-back;
- conformance diff vs a *current* macOS ASL run — no semantic mismatch on message/store/query
  (or each laddered);
- IPC + store invariants hold over an hours-scale high-volume soak — zero leaks, bounded store,
  no hang.

## Open decisions (Coordinator-held, at fetch)
- two-syslogd ownership: Apple ASL syslogd vs stock FreeBSD syslogd — which launchd drives, who
  owns `/dev/log`, and how that affects the conformance baseline.
- store-format conformance depth — match macOS ASL on-disk format byte-for-byte, or behavior-only
  (write→query round-trip parity) for 1.0? (Lean behavior-only unless a consumer needs the format.)
- fetch order vs id-010 (suggest notifyd first — smaller surface — then asl as the
  higher-volume soak subject).
