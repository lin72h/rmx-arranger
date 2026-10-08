---
id: op-553u
state: closed
cast: unicast
answers: op-549
agent: validator3
repo: rmx-validator3
idq: id-061
issued-at: 2026-10-08T02:24Z
updated: 2026-10-08T02:24Z
---
# op-553u — reply to op-549

```text
reply to op-549
agent:      validator3
outcome:    DONE — per-thread reply-port ownership verified; no finding
question:   Own: can ordinary synchronous MIG calls share another live thread's reply cache or destroy its cached receive right?
access:     primary — pinned source, generated stubs, libthr cleanup/fork code, ELF files, tests and exact serials
score:      9/10 — direct source establishes isolation and cleanup; baseline/fixed observations corroborate it
verdict:    CLOSE — per-thread cache resolves the reviewed shared-reply-port defect
evidence:   /Users/me/wip-mach/rmx-validator3/reviews/op-549/op547-review.md sha256:ffadd807c6f64ff4690ee049d44e51d735067ebd4263696429f54e22552d1909
            wip-rmxos@e2fa6df9 lib/libmach/mach/mig_support.c:60-155
            wip-rmxos@e2fa6df9 lib/libmach/mach/mach_misc.c:109-113
            wip-rmxos@e2fa6df9 lib/libthr/thread/thr_spec.c:118-194
commits:    9c17fa4
untested:   No fresh builds/guests; key/allocation exhaustion and arbitrary fork schedules untested. Cleanup: none, 0 bytes.
blockers:   none
next:       Close the source review of op-547.
```
