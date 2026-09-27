# id-041 — notifyd shared-memory page/count/byte sizing guard

- id: **id-041**
- state: **WAITING — post-preview hardening, explicitly banked; no live preview configuration
  drives the defect premise and no product op is authorized.**
- raised: 2026-07-11 from Arranger2's first-hand adjudication of op-270.
- parent: **li-1003 / id-010** (libnotify/notifyd); related **li-1011** (preview scope) and
  **li-1012** (artifact/config provenance).

## Verified problem statement

At product commit `0ccd56212c172c27877eb613a7dc9f75ebcc0630`, notifyd derives
`global.nslots` from `-shm_pages` into `uint32_t`, then derives the shared-memory byte size into
another `uint32_t`:

- `usr.sbin/notifyd/notifyd.c:1181,1210-1213` — page count to slots;
- `usr.sbin/notifyd/notifyd.c:1093-1140` — narrowed byte size used by `ftruncate`, `mmap`,
  `malloc`, and zero-fill;
- `usr.sbin/notifyd/notify_proc.c:647-679` — scans/indexes against logical `nslots`, not the
  physically allocated cell count.

On a 4 KiB-page target, `-shm_pages 1048577` gives:

```text
nslots            = 1073742848 (0x40000400)
mathematical bytes = 4294971392
uint32_t bytes     = 4096
physical cells     = 1024
```

After 1023 distinct memory registrations occupy cells 1…1023, the next scan can read cell 1024
outside the physical refcount allocation while still remaining below logical `nslots`. Separately,
a hypothetical `nslots == 1` makes the exhaustion path select invalid cell 1, although the current
page-derived initializer cannot produce that state on the supported 4 KiB targets.

op-270 also proved the ordinary lifecycle sound within its scope: zero slots take plain IPC,
logical indices are bounded for initialized `nslots >= 2`, and every newly assigned/reused counter
cell resets to 1 before successful exposure.

## Explicit preview closure / consumer census

The shipped `usr.sbin/notifyd/com.apple.notifyd.plist` supplies only `/usr/sbin/notifyd`; it has no
`-shm_pages` override. Full searches of the product, Arranger, Gatekeeper, and Explorer trees found
no other live override/configuration. With the current 4 KiB base pages, the packaged invocation
therefore uses the default one page / 1024 cells.

No live 1.0-preview consumer reaches either defect premise. This item is banked hardening and does
not reopen retired id-010, invalidate its conformance/soak evidence, or block li-1003. A future
configuration that adds `-shm_pages` must fetch this item first or prove its count/byte relation
independently.

## Fetch contract

If the Coordinator promotes this item, split product edit and runtime acceptance into separate
ops. The product op must establish one checked relationship across page count, slot count, mapping
bytes, allocation bytes, and the signed size returned through the notify protocol; it must reject
missing, negative, malformed, one-cell, and overflow/truncation premises before mapping or indexing.
Do not preselect a cast-only fix.

Acceptance must cover:

1. default no-argument startup: one page / 1024 cells and the existing notify matrix;
2. explicit zero pages: shared memory disabled and plain registration retained;
3. the maximum accepted nonzero count, with exact physical/logical equality;
4. malformed/negative and boundary-overflow arguments, including `1048576` and `1048577`, failing
   closed without a zero/truncated mapping or array access; and
5. free-slot, exhaustion-reuse, and cancel behavior retaining op-270's reset/refcount semantics.

No product source, build, guest, or evidence work is authorized by this IDQ record.

## Source record

- op-270 Oracle2 note:
  `/Users/me/wip-mach/rmx-oracle2/op-270-notifyd-shared-memory-slot-lifecycle.md`
- local identity: 15,410 bytes / 327 lines / SHA-256
  `7b4c6c6da35e1b81901ea6ba3340c8f12cd67aad14ddd34a9972a58ae53bdc97`
- reviewed `notify_proc.c` blob at both `778cb074...` and `0ccd5621...`:
  `853dffd816bd3dd56f0167a0932e1413801d71fb`

feedback: `code_reasoned_verdict_is_hypothesis`, `verify_premise_before_mechanism`,
`no_conflate_gating_with_readiness`, `agent_host_isolation`, `build_is_implementer`.
