# bl-011 — libasl + syslogd/aslmanager: conformance bring-up (Gate B next rung, Gate C real-service)

- id: bl-011
- state: **WAITING** — preconditions: (1) the bl-006 libdispatch conformance+soak **template**
  blessed (matrix + conformance-diff legs are the pattern this copies; soak leg inherited);
  (2) Coordinator fetch decision. Sibling of **bl-010** (libnotify/notifyd) — same template, same
  no-USDT fbt-correlation approach. Does **not** block on the op-108 kernel soak to *start*.
- raised: 2026-06-23 (roadmap Gate B "notifyd/asl — next rung")
- roadmap parent: [roadmap.md](../roadmap.md) — **Gate B** (layer working + conformance-matched)
  and a named **Gate C** real service (launchd driving the Apple syslogd, not a fixture).
- relations: **bl-006** (template); **bl-010** (sibling — fetch ordering decided together);
  **bl-009/op-107** (shares the mach-ipc substrate — UAF fix benefits this port-churning layer
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

## Why this rung (sibling to bl-010)

ASL is the **log-path** Darwin daemon — higher message volume than notifyd, with on-disk store
(`asl_file`/`asl_store`) and a retention manager (aslmanager). It exercises the same Gate B +
Gate C shape as notifyd but stresses **sustained throughput + persistence**, making it a stronger
soak subject. Same substrate (Mach + dispatch) already proven; new surface = the ASL message
protocol, store format, and query path.

## Instrumentation note — no USDT

Same as bl-010: **no USDT** → pid/fbt + cross-layer correlation (asl client ↔ Mach IPC ↔
syslogd ↔ on-disk store), anchored on the op-099 mach-ipc fbt library. ASL adds a **filesystem**
dimension (store writes/rotation) the oracle must watch alongside the IPC balance.

## Scope (when promoted) — copies the bl-006 template

**In:**
1. **Bring-up:** the Apple ASL syslogd loads + stays up under launchd (Gate C lifecycle spine);
   resolve the two-syslogd ownership question.
2. **Functional matrix:** `asl_new`/`asl_log`/`asl_send`, key/value messages, level filtering,
   `asl_search`/query, file store write + read-back, aslmanager rotation. Client + daemon paths.
3. **Dual-explorer conformance:** same harness on mx-a64z (macOS truth) and rx-x64z, diffed via
   `macos-oracle.v1` — message round-trip + store-format + query-result parity.
4. **Invariant oracle over soak:** msg send/recv balance, no leaked Mach ports, store growth
   bounded + aslmanager reclaims, no stuck enqueue under sustained high-volume logging — fbt +
   filesystem assertions over an hours-scale run. Inherits the bl-006 soak-leg definition.

**Out:** product source edits (observation-first; defects ladder to fix ops); libnotify (bl-010);
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
- fetch order vs bl-010 (suggest notifyd first — smaller surface — then asl as the
  higher-volume soak subject).
