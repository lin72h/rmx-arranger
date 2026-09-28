---
id: op-386
state: hold
agent: advisor4
repo: mm4:/Users/linz/Local/wip-mach/rmx-advisor4
idq: id-021
gate: self
authority: none
updated: 2026-09-28T11:18Z
---
# op-386 — Advisor 4: libxpc review at alpha2 against macOS 27

## Outcome

This is open-source OS engineering: an internal architecture and code-quality review of rmxOS
code we author and ship. It is also your first consult under the workflow adopted on 2026-09-28:
read AGENTS.md, OPS.md, and LOCAL.md first. The Oracle-era consults in your repo are history.

The question: at alpha2 `2884304b`, how solid is libxpc for the 1.0 preview, checked against real
macOS 27 XPC on your host?

Answer in one consult document:
1. Which items of the baseline below now hold at alpha2 (with source lines), which are still
   provisional, and which moved or regressed with the stable/15 merge.
2. The top risks for the preview, ranked by impact, each with its source lines, why it matters,
   and what would retire it.
3. Proposals, each labeled as a proposal and tied to one of the problem entries named here or to
   a new one you justify.

Architecture and risk only: correctness review of specific ops belongs to the Validators.
alpha2 `2884304b` is the preview candidate: alpha `26655e67` plus the upstream FreeBSD stable/15
merge and a release profile.

Scope for the preview: the Coordinator ruled on 2026-09-28 that MachServices plus nvlist is the
preview service plane; literal `xpc_domain` hosting (app and framework XPC services in
per-process domains) is deferred past the preview. The open preview acceptance for libxpc asks
for: object, type, and lifecycle behavior; Mach transport send, reply, cancel, and error;
conservation; managed-service behavior; and the 8,192-byte receive, 8-byte minimum, and 52-byte
audit-trailer boundary with exact-fit and one-byte-short controls. Say which of these the current
libxpc can meet, which it cannot, and where its API or semantics differ from macOS 27's
`xpc/*.h`.

Problem entries: id-042 (the 1.0-preview tracker), id-021 (libxpc core-service conformance, open).

## Inputs

- A read-only copy of the rmxOS source at `2884304b67fc454ee60187ce4731fca01cbefe6a` on your host:
  `/Users/linz/Local/wip-mach/rmx-reference/rmxos-alpha2-2884304b/` (lib/libxpc, lib/liblaunch,
  lib/libmach, lib/libnv, lib/libdispatch, sys/contrib/libnv, the nv headers, and sbin/launchd;
  225 files).
- The July baseline: `/Users/linz/Local/wip-mach/rmx-reference/july-consults/libxpc-9of10-checklist.md`,
  sha256 `f25d9d6c027d7f48f7a5780fca7444ec9b49df4f0c9d616a8c045a43acea7088`.
- The macOS 27 SDK headers:
  `/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/xpc/`.

Re-read OPS.md first: defaults and the REPORT block.
