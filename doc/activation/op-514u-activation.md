---
id: op-514u
state: closed
cast: unicast
agent: implementer
repo: rmx-implementer
idq: id-000
issued-at: 2026-10-07T00:11Z
updated: 2026-10-07T00:11Z
---
# op-514u — Implementer: OPS.md self-check, pair identity from manifests

## Message

changed:  rmx-implementer OPS.md § Self-check (rmx-implementer@c3dc133,
          rendered from implementer0)
meaning:  Show that a base/fixed image pair differs only in the change from
          the build manifests: diff the two METALOGs or BOMs, which hash
          every file. A full readback of every file in both images is no
          longer part of the self-check; the Gatekeeper's boot is the
          independent check.
action:   re-read OPS.md § Self-check before your next op

This is a cast: no reply is expected.
