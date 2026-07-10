# op-183 — Implementer: PUBLISH the op-149 certified preview image to the soak-consume handoff path (deliver the artifact to the Gatekeeper) — unblocks op-168

op-183 | role: **Implementer** (cost-30) | EXU: **wip-gpt** | state: **[Done]** — `image-published` 2026-06-28; sha re-verified first-hand on the landed copy (`707936a6…ba8a` at `/Users/me/wip-mach/vm/runs/op149-preview-uefi-v3.img`, 17179869184 B logical / ~826M sparse). op-168 image precondition met; consume path `NXPLATFORM_VM_IMAGE=/Users/me/wip-mach/vm/runs/op149-preview-uefi-v3.img`. | parent id: id-026 | L1i: li-1009 / li-1012 | authored 2026-06-28 (Arranger seat, model Opus 4)

## WHY (one line)

op-168 (Gatekeeper soak) BLOCKED — correctly — because the op-149 preview image lives in the BUILD EXU's
output dir (`wip-gpt/build/op149-preview-image/`), which the Gatekeeper EXU cannot reach (host-isolation,
working as designed). The image was never published to the canonical soak-consume path. This op delivers it.

## CONTEXT (Arranger-verified first-hand 2026-06-28 — take as given)

- Image PRESENT + intact on the build host: `/Users/me/wip-mach/wip-gpt/build/op149-preview-image/
  op149-preview-uefi-v3.img`, sha256 `707936a615fd8ad0b63682fd5cdf2129d5097e68f47645969d79b343e6ffba8a`,
  17179869184 bytes. This is the li-1012-certified image (kernel `c526a91d…`, mach.ko `30d23616…`, HEAD
  `c14e0904`; boots multiuser, mach loaded — op-149 verified).
- The soak pipeline consumes from `${workspace_root}/vm/runs/${vm_name}.img` (`run-guest.sh:13,49`;
  `workspace_root = repo_root/..` = `/Users/me/wip-mach`). `vm/runs/` is the SHARED handoff location (the
  designed exchange point — NOT a host-isolation violation; it is outside any single EXU's build dir).
- Build EXU owns the artifact → build EXU delivers it (build_is_implementer: other agents request a build +
  RECEIVE the built file; they do not reach into the builder's dir).

## DELIVERABLES (verify identity first-hand on BOTH ends — sha, never filename/size)

**D1 — publish the image to the soak-consume handoff path.** Place the certified image at the canonical
shared path the Gatekeeper consumes: `/Users/me/wip-mach/vm/runs/op149-preview-uefi-v3.img` (create `vm/runs/`
if absent). Mechanism is the Implementer's call given the host topology:
- if the soak host shares this filesystem → copy/move into `vm/runs/`;
- if the soak host is a SEPARATE machine → rsync/scp the 16GB image to the soak host's
  `<workspace_root>/vm/runs/op149-preview-uefi-v3.img`.
Do NOT rebuild — this is a pure delivery of the EXISTING `707936a6` artifact.

**D2 — verify identity on the landed copy.** sha256 of the published image MUST equal
`707936a6…ba8a`. Report the final absolute path + sha + size. A mismatch = a truncated/corrupted transfer →
re-deliver, do not hand a bad image to the soak.

**D3 — state the consume contract for op-168.** Report the exact `NXPLATFORM_VM_IMAGE` (absolute path) the
Gatekeeper should set, so op-168 points at the published copy unambiguously.

**VERDICT:** `image-published` (landed at the handoff path, sha matches `707936a6`, consume path stated →
op-168 unblocks) | `delivery-walled` (transfer/space/permission failure → report it, do not improvise around it).

## BOUNDARIES
- Pure artifact delivery — no rebuild, no source edits, no image mutation (the published copy must be
  byte-identical: sha `707936a6`). If you find the image is somehow wrong/changed, STOP and report.
- Publish ONLY to the shared `vm/runs/` handoff path (the designed exchange point) — not host /tmp, not a
  random host-global path (agent_host_isolation).
- If the soak host is separate and the 16GB transfer is heavy, that's expected — overnight-ok; do not shortcut
  by rebuilding a fresh image on the soak host (that would break li-1012 single-source provenance).

## MARKERS
```
OP183_SRC_OK        # source image present on build host, sha=707936a6 re-confirmed
OP183_PUBLISHED     # final absolute path of the landed copy + size
OP183_SHA_MATCH     # sha256 of landed copy == 707936a6…ba8a (y/n)
OP183_CONSUME_PATH  # exact NXPLATFORM_VM_IMAGE for op-168
OP183_VERDICT       # image-published | delivery-walled
OP183_TERMINAL
```

## RELATIONS
- BLOCKS op-168 (Gatekeeper soak) — on `image-published`, op-168's image precondition is met and it can take the
  soak-host slot.
- UPSTREAM: op-149 (built the image), op-182 (li-1012 cert source). DOWNSTREAM: op-168 consumes the published
  image; the li-1012 P2 re-confirm legs run on the same artifact.
- feedback: build_is_implementer (builder delivers the file; consumer doesn't reach into builder's dir),
  agent_host_isolation (publish to the shared handoff path only), artifact_identity_needs_content_check (sha
  on both ends), no improvise-under-do-not-rebuild.
```
