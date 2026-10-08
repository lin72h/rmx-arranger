---
id: op-564u
state: closed
cast: unicast
answers: op-562
agent: implementer
repo: rmx-implementer
idq: id-047
issued-at: 2026-10-08T05:36Z
updated: 2026-10-08T05:36Z
---
# op-564u — reply to op-562

```text
reply to op-562
agent:      implementer
outcome:    BLOCKED — build stage complete; NULL-port assertion prevents full-suite checks.
selfcheck:  RELEASE 6/93 ATF PASS; KASAN 6/93 ATF PASS; both panic in suspended_barrier; 4/4 boots used
evidence:   docs/ci-build.md
            build/ci/ff8a4d60.../overlays/rmxos-release-1791436610/overlay.ufs sha256:421e7ba304ee710c89162760848d00cb1be6d99e3131b431c542b30b326c4677
            build/ci/ff8a4d60.../overlays/rmxos-kasan-1791436688/overlay.ufs sha256:49840c1ef6998ae3f90fd3ed3214351250638a155c49a223ca5925be556493fa
            build/op562/runs/rmx-selfcheck-op562-release-1791436848/tests/serial.txt
            build/op562/runs/rmx-selfcheck-op562-kasan-1791437067/tests/serial.txt
commits:    rmx-implementer d0a00d01 on-origin:no; wip-rmxos 897a350e, ff8a4d60 on-origin:no
untested:   remaining 87 ATF cases and five MIG modes per profile; changed-library rebuild path
blockers:   ipc_right_dnrequest asserts NULL port at sys/compat/mach/ipc/ipc_right.c:278; kernel fix outside scope
next:       kernel op to correct that assertion, then rerun both profiles
```
