# id-027 — case-insensitive ZFS: phase design + base case-collision audit (li-1010)

- id: id-027
- state: **HELD — design-first** (no op dispatched). Careful per-phase design required before any execution.
- raised: 2026-06-25.
- L1i parent: li-1010 (case-insensitive OpenZFS, phased).

## What (design work, not execution)
Settle the create-time-immutable design decisions and audit the risk BEFORE creating the first
insensitive dataset. Nothing here mutates the system yet.

Deliverables when released:
1. **Property decision:** `casesensitivity=mixed` vs `insensitive`; `normalization=formC` vs `formD`;
   `utf8only` on/off. These are immutable post-creation — pin them once, document the rationale (target =
   macOS/APFS-like behavior).
2. **Phase-1 design:** `/Users/<user>` as a dedicated dataset created with the chosen properties; data
   migration plan (fresh home vs copy-in); how it mounts at boot.
3. **Base case-collision audit (governs P2/P3):** enumerate paths in base + `/usr/local` payloads that
   differ only by case (would collide/merge under insensitive). This audit is what tells us whether/how
   far insensitivity can safely extend, and substantiates the boot-break risk for root (li-1010 P3).

## Governing constraint (from li-1010)
FreeBSD base is case-sensitive by default; root-level insensitivity is expected to break boot if naive.
Whole-system end state = base remediation + new boot dataset, long-arc / post-preview.

## Carrier
HELD — no op. Release the design work (likely a FREE Explorer/DS4P design+audit pass) only when the
Coordinator wants P1 to move; whole-system phases stay parked pending the audit.

## Coordinator direction (2026-10-04)

Case-insensitivity matters for rmxOS and for the projects around it: move there **incrementally**,
ending with the whole system case-insensitive by default, as macOS is. First step: the swift-sdk
project's workspace gets its own dataset matching the one its toolchain was built and qualified on
(`zroot/wip-rnx-normd`: `casesensitivity=insensitive`, `normalization=formD`, `atime=off`). Its
behaviour there is the first evidence for this entry's property decision (deliverable 1). The
rmxOS-side phases stay design-first.

Refined the same day (Coordinator): **userspace is case-insensitive from day one** (workspaces,
toolchains, our own userland), so case problems fail fast and get fixed fast. **The FreeBSD kernel
and base move incrementally**: expect breakage there, and prepare each phase (case-collision audit,
build and install on an insensitive tree, rollback) before it runs.
